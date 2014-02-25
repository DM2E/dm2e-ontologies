package eu.dm2e.validation.validator;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
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
import com.hp.hpl.jena.rdf.model.Literal;
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
import eu.dm2e.validation.Dm2eValidationReport;
import eu.dm2e.validation.Dm2eValidator;
import eu.dm2e.validation.ValidationLevel;
import eu.dm2e.validation.ValidationProblemCategory;

abstract public class BaseValidator implements Dm2eValidator {

	public abstract InputStream getOwlInputStream();
	
	private Set<String> propertyWhiteList = new HashSet<>();
	
	public BaseValidator() {
		InputStream owlInputStream = getOwlInputStream();
		Model ontModel = ModelFactory.createDefaultModel();
		ontModel.read(owlInputStream, "RDF-XML");
		// Standards
		{
			propertyWhiteList.add(NS.RDF.PROP_TYPE);
			propertyWhiteList.add(NS.EDM.PROP_IS_NEXT_IN_SEQUENCE);
		}
		{
			StmtIterator iter = ontModel.listStatements(null, 
					ontModel.createProperty(NS.RDF.PROP_TYPE), 
					ontModel.createProperty(NS.OWL.DATATYPE_PROPERTY));
			while (iter.hasNext())
				propertyWhiteList.add(iter.next().getSubject().asResource().getURI());
		}
		{
			StmtIterator iter = ontModel.listStatements(null, 
					ontModel.createProperty(NS.RDF.PROP_TYPE),
					ontModel.createProperty(NS.OWL.OBJECT_PROPERTY));
			while (iter.hasNext())
				propertyWhiteList.add(iter.next().getSubject().asResource().getURI());
		}
	}
	
	public Set<String> getPropertyWhitelist() {
		return propertyWhiteList;
	}

	private static final Logger	log					= LoggerFactory.getLogger(BaseValidator.class);

	//
	// Store resources already validated so we don't validate twice
	//

	private Set<Resource>		alreadyValidated	= new HashSet<>();

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
		NodeIterator choIter = m.listObjectsOfProperty(agg, m
			.createProperty(NS.EDM.PROP_AGGREGATED_CHO));
		if (choIter.hasNext()) {
			cho = choIter.next().asResource();
		}
		return cho;
	}

	//
	// Generic checkers
	//

	protected void checkFunctionalProperties(Model m,
			Resource res,
			final Set<Property> properties,
			Dm2eValidationReport report) {
		for (Property prop : properties) {
			NodeIterator iter = m.listObjectsOfProperty(res, prop);
			if (iter.hasNext()) {
				iter.next();
				if (iter.hasNext()) report.add(ValidationLevel.ERROR,
						ValidationProblemCategory.NON_REPEATABLE,
						res,
						prop);
			}
		}
	}

	protected void checkMandatoryProperties(Model m,
			Resource res,
			Set<Property> properties,
			Dm2eValidationReport report) {
		for (Property prop : properties) {
			NodeIterator iter = m.listObjectsOfProperty(res, prop);
			if (!iter.hasNext()) report.add(ValidationLevel.ERROR,
					ValidationProblemCategory.MISSING_REQUIRED_PROPERTY,
					res,
					prop);
		}
	}

	protected void checkRecommendedProperties(Model m,
			Resource res,
			Set<Property> properties,
			Dm2eValidationReport report) {
		for (Property prop : properties) {
			NodeIterator iter = m.listObjectsOfProperty(res, prop);
			if (!iter.hasNext()) report.add(ValidationLevel.WARNING,
					ValidationProblemCategory.MISSING_RECOMMENDED_PROPERTY,
					res,
					prop);
		}
	}

	protected void checkLiteralPropertyRanges(Model m,
			Resource cho,
			Dm2eValidationReport report,
			final Map<Property, Set<Resource>> properties) {
		for (Entry<Property, Set<Resource>> entry : properties.entrySet()) {
			Property prop = entry.getKey();
			StmtIterator iter = cho.listProperties(prop);
			while (iter.hasNext()) {
				RDFNode obj = iter.next().getObject();
				if (obj.isLiteral()) {
					final Literal objLit = obj.asLiteral();
					boolean validRange = false;
					if (null == objLit.getDatatype()) {
						report.add(ValidationLevel.ERROR,
								ValidationProblemCategory.ILLEGALLY_UNTYPED_LITERAL,
								cho,
								prop,
								entry.getValue());
						continue;
					}
					for (Resource allowedRange : entry.getValue()) {
						// log.debug(objLit.getDatatype().getURI());
						// log.debug(allowedRange.getURI());
						if (objLit.getDatatype().getURI().equals(allowedRange.getURI())) {
							validRange = true;
							break;
						}
					}
					if (!validRange) report.add(ValidationLevel.ERROR,
							ValidationProblemCategory.INVALID_DATA_PROPERTY_RANGE,
							cho,
							prop,
							entry.getValue());
				} else {
					report.add(ValidationLevel.ERROR,
							ValidationProblemCategory.SHOULD_BE_LITERAL,
							cho,
							prop);
				}
			}
		}
	}

	protected void checkObjectPropertyRanges(Model m,
			Resource res,
			final Map<Property, Set<Resource>> properties,
			Dm2eValidationReport report) {
		for (Entry<Property, Set<Resource>> entry : properties.entrySet()) {
			Property prop = entry.getKey();
			StmtIterator iter = res.listProperties(prop);
			while (iter.hasNext()) {
				RDFNode obj = iter.next().getObject();
				if (obj.isLiteral()) {
					report.add(ValidationLevel.ERROR,
							ValidationProblemCategory.SHOULD_BE_RESOURCE,
							res,
							prop);
				} else if (obj.isResource()) {
					final Resource objRes = obj.asResource();
					boolean validRange = false;
					for (Resource allowedRange : entry.getValue()) {
						if (objRes.hasProperty(isa(m), allowedRange)) {
							validRange = true;
							break;
						}
					}
					if (!validRange) report.add(ValidationLevel.ERROR,
							ValidationProblemCategory.INVALID_OBJECT_PROPERTY_RANGE,
							res,
							objRes,
							entry.getValue());
				}
			}
		}
	}

	public void validateUnknownProperties(Model m, Dm2eValidationReport report) {
		StmtIterator stmtIter = m.listStatements();
		while (stmtIter.hasNext()) {
			Statement stmt = stmtIter.next();
			final Property prop = stmt.getPredicate();
			final Resource res = stmt.getSubject();
			checkProperty(res, prop, report);
		}
		
	}

	protected void checkProperty(final Resource res, final Property prop, Dm2eValidationReport report) {
		if (! propertyWhiteList.contains(prop.getURI())) {
			report.add(ValidationLevel.ERROR,
					ValidationProblemCategory.UNKNOWN_PROPERTY,
					res,
					prop);
		}
	}

	//
	// Validation methods for individual classes
	//

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * eu.dm2e.validation.Dm2eValidator#validateAggregation(com.hp.hpl.jena.
	 * rdf.model.Model, com.hp.hpl.jena.rdf.model.Resource,
	 * eu.dm2e.validation.Dm2eValidationReport)
	 */
	@Override
	public void validate_ore_Aggregation(Model m, Resource agg, Dm2eValidationReport report) {

		if (!agg.hasProperty(prop(m, NS.EDM.PROP_AGGREGATED_CHO))) {
			// This is bad enough to warrant a FATAL error since the graph is not connected
			report.add(ValidationLevel.FATAL, ValidationProblemCategory.MISSING_REQUIRED_PROPERTY, agg, NS.EDM.PROP_AGGREGATED_CHO);
		}

		//
		// Check mandatory properties
		//
		checkMandatoryProperties(m, agg, build_ore_Aggregation_Mandatory_Properties(m), report);

		//
		// Check recommended properties
		//
		checkRecommendedProperties(m, agg, build_ore_Aggregation_Recommended_Properties(m), report);

		//
		// Check functional properties (i.e. non-repeatable properties)
		//
		checkFunctionalProperties(m, agg, build_ore_Aggregation_FunctionalProperties(m), report);

		//
		// Object properties Range checks
		//
		checkObjectPropertyRanges(m, agg, build_ore_Aggregation_ObjectPropertyRanges(m), report);

		//
		// Literal properties Range checks
		//
		checkLiteralPropertyRanges(m, agg, report, build_ore_Aggregation_LiteralPropertyRanges(m));

		//
		// Find CHO and give stern error if none is found
		//
		Resource cho = get_edm_ProvidedCHO_for_ore_Aggregation(m, agg);
		if (null == cho) {
			report.add(ValidationLevel.ERROR,
					ValidationProblemCategory.MISC,
					agg,
					"Aggregation has no ProvidedCHO. This is very bad.");
		} else {

			//
			// Make sure CHO and Aggregation are different things (was problem
			// with ub-ffm data)
			//
			if (cho.getURI().equals(agg.getURI())) {
				report.add(ValidationLevel.ERROR,
						ValidationProblemCategory.MISC,
						agg,
						"CHO is the same as the Aggregation. This is likely a mapping glitch.");
			}
		}

		//
		// Check isShownAt / isShownBy
		//
		{
			NodeIterator isaIter = m.listObjectsOfProperty(agg, prop(m, NS.EDM.PROP_IS_SHOWN_AT));
			NodeIterator isbIter = m.listObjectsOfProperty(agg, prop(m, NS.EDM.PROP_IS_SHOWN_BY));
			if (!isaIter.hasNext() && !isbIter.hasNext()) report.add(ValidationLevel.ERROR,
					ValidationProblemCategory.MISC,
					agg,
					"Aggregation needs either edm:isShownAt or edm:isShownBy.");
//	Misleading people https://github.com/DM2E/dm2e-mappings/issues/18#issuecomment-36033484
//			else if (isaIter.hasNext() && isbIter.hasNext()) report.add(ValidationLevel.NOTICE,
//					ValidationProblemCategory.MISC,
//					agg,
//					"Aggregation contains both edm:isShownAt and edm:isShownBy.");

		}

		//
		// Validate annotatable Web Resources
		//
		Set<Property> annotatableWebResources = build_ore_Aggregation_AnnotatableWebResource_Properties(m);
		for (Property prop : annotatableWebResources) {
			NodeIterator iter = m.listObjectsOfProperty(agg, prop);
			while (iter.hasNext())
				validate_Annotatable_edm_WebResource(m, iter.next().asResource(), report);
		}

		//
		// Validate date-like properties
		validate_DateLike(m, agg, report);

	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * eu.dm2e.validation.Dm2eValidator#validateCHO(com.hp.hpl.jena.rdf.model
	 * .Model, com.hp.hpl.jena.rdf.model.Resource,
	 * eu.dm2e.validation.Dm2eValidationReport)
	 */
	@Override
	public void validate_edm_ProvidedCHO(Model m, Resource cho, Dm2eValidationReport report) {

		//
		// Check required properties
		//
		checkMandatoryProperties(m, cho, build_edm_ProvidedCHO_Mandatory_Properties(m), report);

		//
		// Check recommended properties
		//
		checkRecommendedProperties(m, cho, build_edm_ProvidedCHO_Recommended_Properties(m), report);

		//
		// Check functional properties (i.e. non-repeatable properties)
		//
		checkFunctionalProperties(m, cho, build_edm_ProvidedCHO_FunctionalProperties(m), report);

		//
		// Object properties Range checks
		//
		checkObjectPropertyRanges(m, cho, build_edm_ProvidedCHO_ObjectPropertyRanges(m), report);

		//
		// Literal properties Range checks
		//
		checkLiteralPropertyRanges(m, cho, report, build_edm_ProvidedCHO_LiteralPropertyRanges(m));

		//
		// dc:title and/or dc:description (p.26/27)
		//
		if (!(cho.hasProperty(prop(m, NS.DC.PROP_TITLE)) || cho.hasProperty(prop(m,
				NS.DC.PROP_DESCRIPTION)))) {
			report.add(ValidationLevel.ERROR,
					ValidationProblemCategory.MISSING_REQUIRED_ONE_OF,
					cho,
					"dc:title and/or dc:description");
		}

		//
		// Validate TimeSpans and xsd:dateTime
		//
		validate_DateLike(m, cho, report);

	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * eu.dm2e.validation.Dm2eValidator#validateDateLike(com.hp.hpl.jena.rdf
	 * .model.Model, com.hp.hpl.jena.rdf.model.Resource,
	 * eu.dm2e.validation.Dm2eValidationReport)
	 */
	@Override
	public void validate_DateLike(Model m, Resource res, Dm2eValidationReport report) {
		Set<Property> dateProps = build_DateLike_Properties(m);
		for (Property prop : dateProps) {
			StmtIterator iter = res.listProperties(prop);
			while (iter.hasNext()) {
				RDFNode thing = iter.next().getObject();
				if (thing.isResource() && isa(m, thing.asResource(), NS.EDM.CLASS_TIMESPAN)) {
					validate_edm_TimeSpan(m, thing.asResource(), report);
				} else if (thing.isLiteral()) {
					if (thing.asLiteral().getDatatypeURI() == null) {
						report.add(ValidationLevel.NOTICE,
								ValidationProblemCategory.UNTYPED_LITERAL,
								res,
								prop);
					} else if (thing.asLiteral().getDatatypeURI().equals(NS.XSD.DATETIME)) {
						try {
							DateTime.parse(thing.asLiteral().getLexicalForm());
						} catch (IllegalArgumentException e) {
							report.add(ValidationLevel.ERROR,
									ValidationProblemCategory.INVALID_XSD_DATETIME,
									res,
									prop,
									thing.asLiteral().getDatatypeURI());
						}
					}
				}
			}
		}
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * eu.dm2e.validation.Dm2eValidator#validateTimeSpan(com.hp.hpl.jena.rdf
	 * .model.Model, com.hp.hpl.jena.rdf.model.Resource,
	 * com.hp.hpl.jena.rdf.model.Property,
	 * eu.dm2e.validation.Dm2eValidationReport)
	 */
	@Override
	public void validate_edm_TimeSpan(Model m, Resource ts, Dm2eValidationReport report) {
		for (Property prop : build_edm_TimeSpan_Mandatory_Properties(m)) {
			if (!ts.hasProperty(prop)) {
				report.add(ValidationLevel.ERROR,
						ValidationProblemCategory.MISSING_REQUIRED_PROPERTY,
						ts,
						prop);
			}
		}
		if (!ts.hasProperty(prop(m, NS.EDM.PROP_BEGIN))
				&& !ts.hasProperty(prop(m, NS.EDM.PROP_END))) {
			report.add(ValidationLevel.WARNING,
					ValidationProblemCategory.MISSING_REQUIRED_ONE_OF,
					ts,
					"edm:begin or edm:end");
		}
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * eu.dm2e.validation.Dm2eValidator#validateWebResource(com.hp.hpl.jena.
	 * rdf.model.Model, com.hp.hpl.jena.rdf.model.Resource,
	 * com.hp.hpl.jena.rdf.model.Property,
	 * eu.dm2e.validation.Dm2eValidationReport)
	 */
	@Override
	public void validate_Annotatable_edm_WebResource(Model m,
			Resource wr,
			Dm2eValidationReport report) {

		//
		// dc:format is required for Annotatable Web Resources (p. 45)
		//
		final Property prop_dc_format = prop(m, NS.DC.PROP_FORMAT);
		NodeIterator it = m.listObjectsOfProperty(wr, prop_dc_format);
		if (!it.hasNext()) {
			report.add(ValidationLevel.FATAL,
					ValidationProblemCategory.MISSING_CONDITIONALLY_REQUIRED_PROPERTY,
					wr,
					prop_dc_format,
					"Annotatable WebResource");
		} else {
			RDFNode dcformat = it.next();
			if (!dcformat.isLiteral()) {
				report.add(ValidationLevel.ERROR,
						ValidationProblemCategory.SHOULD_BE_LITERAL,
						wr,
						prop_dc_format);
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
						report.add(ValidationLevel.ERROR,
								ValidationProblemCategory.BAD_MIMETYPE,
								wr,
								dcformatString);
				}
			}
		}
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * eu.dm2e.validation.Dm2eValidator#validate_edm_WebResource(com.hp.hpl.
	 * jena.rdf.model.Model, com.hp.hpl.jena.rdf.model.Resource,
	 * java.lang.Object, eu.dm2e.validation.Dm2eValidationReport)
	 */
	@Override
	public void validate_edm_WebResource(Model m, Resource wr, Dm2eValidationReport report) {
		for (Property prop : build_edm_WebResource_Recommended_Properties(m)) {
			Statement stmt = wr.getProperty(prop);
			if (null == stmt) {
				report.add(ValidationLevel.WARNING,
						ValidationProblemCategory.MISSING_RECOMMENDED_PROPERTY,
						wr,
						prop);
			}
		}
	}

	//
	// Public functions
	//

	/*
	 * (non-Javadoc)
	 * 
	 * @see eu.dm2e.validation.IDm2eValidator#validateWithDm2e(java.lang.String,
	 * java.lang.String)
	 */
	@Override
	public Dm2eValidationReport validateWithDm2e(String fileName, String rdfLang)
			throws FileNotFoundException, RiotNotFoundException {
		final File file = new File(fileName);
		Preconditions.checkArgument(file.exists(), "File does not exist: " + fileName);
		return validateWithDm2e(file, rdfLang);
	}

	@Override
	public Dm2eValidationReport validateWithDm2e(File rdfData, String rdfLang)
			throws FileNotFoundException {
		Preconditions.checkNotNull(rdfLang);
		Preconditions.checkArgument(rdfLang.equals("RDF/XML") || rdfLang.equals("N-TRIPLE")
				|| rdfLang.equals("TURTLE"), "Invalid RDF serialization format '" + rdfLang + "'.");
		FileInputStream fis = new FileInputStream(rdfData);
		Model m = ModelFactory.createDefaultModel();
		m.read(fis, "", rdfLang);
		return validateWithDm2e(m);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * eu.dm2e.validation.IDm2eValidator#validateWithDm2e(com.hp.hpl.jena.rdf
	 * .model.Model)
	 */
	@Override
	public Dm2eValidationReport validateWithDm2e(Model m) {

		Dm2eValidationReport report = new Dm2eValidationReport(getVersion());

		// * check unknown elements
		validateUnknownProperties(m, report);

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

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * eu.dm2e.validation.Dm2eValidator#validateWithDm2e(com.hp.hpl.jena.rdf
	 * .model.Model, java.lang.String, eu.dm2e.validation.Dm2eValidationReport)
	 */
	@Override
	public void validateWithDm2e(Model m, String currentClassUri, Dm2eValidationReport report) {
		ResIterator resIter = m.listSubjectsWithProperty(prop(m, NS.RDF.PROP_TYPE), res(m,
				currentClassUri));
		while (resIter.hasNext()) {
			Resource res = resIter.next();
			if (isAlreadyValidated(res)) {
				continue;
			}
			;
			switch (currentClassUri) {
				case NS.ORE.CLASS_AGGREGATION:
					log.debug("About to validate ore:Aggregation " + res);
					validate_ore_Aggregation(m, res, report);
					break;
				case NS.EDM.CLASS_PROVIDED_CHO:
					log.debug("About to validate edm:ProvidedCHO " + res);
					validate_edm_ProvidedCHO(m, res, report);
					break;
				case NS.EDM.CLASS_WEBRESOURCE:
					log.debug("About to validate edm:WebResource " + res);
					validate_edm_WebResource(m, res, report);
					break;
				case NS.EDM.CLASS_TIMESPAN:
					log.debug("About to validate edm:TimeSpan " + res);
					validate_edm_TimeSpan(m, res, report);
					break;
				default:
					// log.error("Not implemented");
					break;
			}
			setValidated(res);
		}
	}

}
