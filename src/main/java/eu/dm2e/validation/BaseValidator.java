package eu.dm2e.validation;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import org.apache.jena.riot.RiotNotFoundException;
import org.joda.time.DateTime;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.base.Preconditions;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.rdf.model.NodeIterator;
import com.hp.hpl.jena.rdf.model.Property;
import com.hp.hpl.jena.rdf.model.RDFNode;
import com.hp.hpl.jena.rdf.model.ResIterator;
import com.hp.hpl.jena.rdf.model.Resource;
import com.hp.hpl.jena.rdf.model.Statement;
import com.hp.hpl.jena.rdf.model.StmtIterator;

import eu.dm2e.NS;

public abstract class BaseValidator implements Dm2eValidator {
	
	private static final Logger log = LoggerFactory.getLogger(BaseValidator.class);

	//
	// Store resources already validated so we don't validate twice
	//

	private Set<Resource> alreadyValidated = new HashSet<>();
	
	private boolean isAlreadyValidated(Resource res) {
		return alreadyValidated.contains(res);
	}
	private void setValidated(Resource res) {
		alreadyValidated.add(res);
	}

	//
	// Utility
	//

	protected static Resource res(Model m, String uri) {
		return m.createResource(uri);
	}

	protected static Property prop(Model m, String uri) {
		return m.createProperty(uri);
	}

	protected static Property isa(Model m) {
		return prop(m, NS.RDF.PROP_TYPE);
	}

	protected static boolean isa(Model m, Resource res, String type) {
		if (m.contains(res, isa(m), res(m, type))) {
			return true;
		}
		return false;
	}
	
	protected static Resource get_edm_ProvidedCHO_for_ore_Aggregation(Model m, Resource agg) {
		Resource cho = null;
		NodeIterator choIter = m.listObjectsOfProperty(agg, m .createProperty(NS.EDM.PROP_AGGREGATED_CHO));
		if (choIter.hasNext()) {
			cho = choIter.next().asResource();
		}
		return cho;
	}
	

	//
	// Validation methods for individual classes
	//

	/* (non-Javadoc)
	 * @see eu.dm2e.validation.Dm2eValidator#validateAggregation(com.hp.hpl.jena.rdf.model.Model, com.hp.hpl.jena.rdf.model.Resource, eu.dm2e.validation.Dm2eValidationReport)
	 */
	@Override
	public void validate_ore_Aggregation(Model m, Resource agg, Object context, Dm2eValidationReport report) {

		//
		// Check mandatory properties
		//
		Set<Property> aggregationProperties = build_ore_Aggregation_Mandatory_Properties(m);

		for (Property prop : aggregationProperties) {
			NodeIterator iter = m.listObjectsOfProperty(agg, prop);
			if (!iter.hasNext()) report.addError(agg, "Missing required property <" + prop + ">.");
		}

		//
		// Check recommended properties
		//
		Set<Property> aggregationRecommendedProperties = build_ore_Aggregation_Recommended_Properties(m);
		for (Property prop : aggregationRecommendedProperties) {
			NodeIterator iter = m.listObjectsOfProperty(agg, prop);
			if (!iter.hasNext()) report.addWarning(agg,
					"Aggregation is missing strongly recommended property <" + prop + ">.");
		}

		//
		// Find CHO and stop validating this aggregation if none is found
		//
		Resource cho = get_edm_ProvidedCHO_for_ore_Aggregation(m, agg);
		if (null == cho) {
			report.addError(agg, "Aggregation has no ProvidedCHO. Will not validate further.");
			return;
		}

		//
		// Make sure CHO and Aggregation are different things (was problem with ub-ffm data)
		//
		if (cho.getURI().equals(agg.getURI())) {
			report.addError(cho, "CHO is the same as the Aggregation. This is likely a mapping glitch.");
		}

		//
		// Check isShownAt / isShownBy
		//
		{
			NodeIterator isaIter = m.listObjectsOfProperty(agg, prop(m, NS.EDM.PROP_IS_SHOWN_AT));
			NodeIterator isbIter = m.listObjectsOfProperty(agg, prop(m, NS.EDM.PROP_IS_SHOWN_BY));
			if (!isaIter.hasNext() && !isbIter.hasNext()) report.addError(agg,
					"Aggregation needs either edm:isShownAt or edm:isShownBy.");
			else if (isaIter.hasNext() && isbIter.hasNext()) report.addNotice(agg,
					"Aggregation contains both edm:isShownAt and edm:isShownBy.");
		}

		//
		// Validate annotatable Web Resources
		//
		Set<Property> annotatableWebResources = build_ore_Aggregation_AnnotatableWebResource_Properties(m);
		for (Property prop : annotatableWebResources) {
			NodeIterator iter = m.listObjectsOfProperty(agg, prop);
			while (iter.hasNext())
				validate_Annotatable_edm_WebResource(m, iter.next().asResource(), prop, report);
		}

		//
		// Validate date-like properties
		validate_DateLike(m, agg, null, report);

	}

	/* (non-Javadoc)
	 * @see eu.dm2e.validation.Dm2eValidator#validateCHO(com.hp.hpl.jena.rdf.model.Model, com.hp.hpl.jena.rdf.model.Resource, eu.dm2e.validation.Dm2eValidationReport)
	 */
	@Override
	public void validate_edm_ProvidedCHO(Model m, Resource cho, Object context, Dm2eValidationReport report) {

		//
		// Check required properties
		//
		Set<Property> choProperties = build_edm_ProvidedCHO_Mandatory_Properties(m);
		for (Property prop : choProperties) {
			NodeIterator iter = m.listObjectsOfProperty(cho, prop);
			if (!iter.hasNext()) {
				report.addError(cho, "missing required property <" + prop + ">.");
			}
		}

		//
		// Range checks
		//
		Map<Property, Set<Resource>> choSubRanges = build_edm_ProvidedCHO_PropertyRanges(m);
		for (Entry<Property, Set<Resource>> entry : choSubRanges.entrySet()) {
			Property prop = entry.getKey();
			StmtIterator iter = cho.listProperties(prop);
			while (iter.hasNext()) {
				RDFNode obj = iter.next().getObject();
				if (!obj.isResource()) {
					report.addError(cho, "Object of <" + prop + "> must be a URI resource. ");
				} else {
					final Resource objRes = obj.asResource();
					boolean validRange = false;
					for (Resource allowedRange : entry.getValue()) {
						if (objRes.hasProperty(isa(m), allowedRange)) {
							validRange = true;
							break;
						}
					}
					if (!validRange) report.addError(objRes, " must be of rdf:type ", entry
						.getValue(), prop);
				}
			}
		}

		//
		// TODO VERSION SPECIFIC
		// dc:title and/or dc:description (p.26/27)
		//
		if (!(cho.hasProperty(prop(m, NS.DC.PROP_TITLE)) || cho.hasProperty(prop(m,
				NS.DC.PROP_DESCRIPTION)))) {
			report.addError(cho, "missing at least one of dc:title and/or dc:description");
		}

		//
		// Validate TimeSpans and xsd:dateTime
		//
		validate_DateLike(m, cho, null, report);

	}

	/* (non-Javadoc)
	 * @see eu.dm2e.validation.Dm2eValidator#validateDateLike(com.hp.hpl.jena.rdf.model.Model, com.hp.hpl.jena.rdf.model.Resource, eu.dm2e.validation.Dm2eValidationReport)
	 */
	@Override
	public void validate_DateLike(Model m, Resource res, Object context, Dm2eValidationReport report) {
		Set<Property> dateProps = build_DateLike_Properties(m);
		for (Property prop : dateProps) {
			StmtIterator iter = res.listProperties(prop);
			while (iter.hasNext()) {
				RDFNode thing = iter.next().getObject();
				if (thing.isResource() && isa(m, thing.asResource(), NS.EDM.CLASS_TIMESPAN)) {
					validate_edm_TimeSpan(m, thing.asResource(), prop, report);
				} else if (thing.isLiteral()) {
					if (thing.asLiteral().getDatatypeURI() == null) {
						report.addNotice(res, "has untyped literal date field.", prop);
					} else if (thing.asLiteral().getDatatypeURI().equals(NS.XSD.DATETIME)) {
						try {
							DateTime.parse(thing.asLiteral().getLexicalForm());
						} catch (IllegalArgumentException e) {
							report.addError(res, "Invalid xsd:dateTime '"
									+ thing.asLiteral().getLexicalForm() + "'. ", prop);
						}
					} else {
						report.addError(res, "has literal with disallowed datatype "
								+ thing.asLiteral().getDatatypeURI(), prop);
					}
				}
			}
		}
	}

	/* (non-Javadoc)
	 * @see eu.dm2e.validation.Dm2eValidator#validateTimeSpan(com.hp.hpl.jena.rdf.model.Model, com.hp.hpl.jena.rdf.model.Resource, com.hp.hpl.jena.rdf.model.Property, eu.dm2e.validation.Dm2eValidationReport)
	 */
	@Override
	public void validate_edm_TimeSpan(Model m, Resource ts, Object context, Dm2eValidationReport report) {
		for (Property prop : build_edm_TimeSpan_Mandatory_Properties(m)) {
			if (! ts.hasProperty(prop)) {
				report.addError(ts, "missing required property " + prop);
			}
		}
		if ( ! ts.hasProperty(prop(m, NS.EDM.PROP_BEGIN)) && ! ts.hasProperty(prop(m, NS.CRM.PROP_P79F_BEGINNING_IS_QUALIFIED_BY))) {
			report.addWarning(ts, "TimeSpan has no beginning.");
		}
		if ( ! ts.hasProperty(prop(m, NS.EDM.PROP_END)) && ! ts.hasProperty(prop(m, NS.CRM.PROP_P80F_END_IS_QUALIFIED_BY))) {
			report.addWarning(ts, "TimeSpan has no end.");
		}
	}

	/* (non-Javadoc)
	 * @see eu.dm2e.validation.Dm2eValidator#validateWebResource(com.hp.hpl.jena.rdf.model.Model, com.hp.hpl.jena.rdf.model.Resource, com.hp.hpl.jena.rdf.model.Property, eu.dm2e.validation.Dm2eValidationReport)
	 */
	@Override
	public void validate_Annotatable_edm_WebResource(Model m, Resource wr, Object context, Dm2eValidationReport report) {
		
		//
		// dc:format is required for Annotatable Web Resources (p. 45)
		//
		NodeIterator it = m.listObjectsOfProperty(wr, prop(m, NS.DC.PROP_FORMAT));
		if (!it.hasNext()) {
			report.addError(wr, "is an annotatable Web Resource but missing required dc:format.", context);
		} else {
			RDFNode dcformat = it.next();
			if (!dcformat.isLiteral()) {
				report.addError(wr, "<" + NS.DC.PROP_FORMAT + "> must be a literal.", context);
			} else {
				String dcformatString = dcformat.asLiteral().getString();
				switch (dcformatString) {
					case "text/html-named-content":
					case "text/html":
					case "text/plain":
					case "image/jpeg":
					case "image/png":
					case "image/gif":
						break;
					default:
						report.addError(wr, "Unsupported MIME type '" + dcformatString + "'.", context);
				}
			}
		}
	}

	/* (non-Javadoc)
	 * @see eu.dm2e.validation.Dm2eValidator#validate_edm_WebResource(com.hp.hpl.jena.rdf.model.Model, com.hp.hpl.jena.rdf.model.Resource, java.lang.Object, eu.dm2e.validation.Dm2eValidationReport)
	 */
	@Override
	public void validate_edm_WebResource(Model m, Resource wr, Object context, Dm2eValidationReport report) { 
		for (Property prop : build_edm_WebResource_Recommended_Properties(m)) {
			Statement stmt = wr.getProperty(prop);
			if (null == stmt) {
				report.addWarning(wr, "missing strongly recommended property " + prop, context);
			}

		}
	}

	//
	// Public functions
	//

	/* (non-Javadoc)
	 * @see eu.dm2e.validation.IDm2eValidator#validateWithDm2e(java.lang.String, java.lang.String)
	 */
	@Override
	public Dm2eValidationReport validateWithDm2e(String fileName, String rdfLang) throws FileNotFoundException, RiotNotFoundException {
		Preconditions.checkArgument(rdfLang.equals("RDF/XML") || rdfLang.equals("N-TRIPLE")
				|| rdfLang.equals("TURTLE"), "Invalid RDF serialization format '" + rdfLang + "'.");
		Preconditions.checkArgument(new File(fileName).exists(), "File does not exist: " + fileName);
		Model m = ModelFactory.createDefaultModel();
		FileInputStream fis = new FileInputStream(new File(fileName));
		m.read(fis, "", rdfLang);
		return validateWithDm2e(m);
	}

	/* (non-Javadoc)
	 * @see eu.dm2e.validation.IDm2eValidator#validateWithDm2e(com.hp.hpl.jena.rdf.model.Model)
	 */
	@Override
	public Dm2eValidationReport validateWithDm2e(Model m) {
		
		Dm2eValidationReport report = new Dm2eValidationReport(getVersion());

		// Validation order:
		// * ore:Aggregation
		// * edm:ProvidedCHO
		// * edm:WebResource
		// * edm:TimeSpan
		
		List<String> validationOrder = new ArrayList<>();
		validationOrder.add(NS.ORE.CLASS_AGGREGATION);
		validationOrder.add(NS.EDM.CLASS_PROVIDED_CHO);
		validationOrder.add(NS.EDM.CLASS_WEBRESOURCE);
		validationOrder.add(NS.EDM.CLASS_TIMESPAN);

		for (String currentClassUri : validationOrder) {
			validateWithDm2e(m, currentClassUri, report);
		}
		return report;

	}

	/* (non-Javadoc)
	 * @see eu.dm2e.validation.Dm2eValidator#validateWithDm2e(com.hp.hpl.jena.rdf.model.Model, java.lang.String, eu.dm2e.validation.Dm2eValidationReport)
	 */
	@Override
	public void validateWithDm2e(Model m, String currentClassUri, Dm2eValidationReport report) {
		ResIterator resIter = m.listSubjectsWithProperty(prop(m, NS.RDF.PROP_TYPE), res(m, currentClassUri));
		while (resIter.hasNext()) {
			Resource res = resIter.next();
			if (isAlreadyValidated(res)) {
				continue;
			};
			switch (currentClassUri) {
				case NS.ORE.CLASS_AGGREGATION:
					log.debug("About to validate ore:Aggregation " + res);
					validate_ore_Aggregation(m, res, null, report);
					break;
				case NS.EDM.CLASS_PROVIDED_CHO:
					log.debug("About to validate edm:ProvidedCHO " + res);
					validate_edm_ProvidedCHO(m, res, null, report);
					break;
				case NS.EDM.CLASS_WEBRESOURCE:
					log.debug("About to validate edm:WebResource " + res);
					validate_edm_WebResource(m, res, null, report);
					break;
				case NS.EDM.CLASS_TIMESPAN:
					log.debug("About to validate edm:TimeSpan " + res);
					validate_edm_TimeSpan(m, res, null, report);
					break;
				default:
//					log.error("Not implemented");
					break;
			}
			setValidated(res);
		}
	}


}
