package dm2e2edm;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.io.Resources;
import com.hp.hpl.jena.query.ParameterizedSparqlString;
import com.hp.hpl.jena.query.QueryExecution;
import com.hp.hpl.jena.query.QueryExecutionFactory;
import com.hp.hpl.jena.query.ResultSet;
import com.hp.hpl.jena.rdf.model.Literal;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.rdf.model.Property;
import com.hp.hpl.jena.rdf.model.RDFNode;
import com.hp.hpl.jena.rdf.model.RDFWriter;
import com.hp.hpl.jena.rdf.model.ResIterator;
import com.hp.hpl.jena.rdf.model.Resource;
import com.hp.hpl.jena.rdf.model.Statement;
import com.hp.hpl.jena.rdf.model.StmtIterator;

import eu.dm2e.NS;

/**
 * Transforms a document of DM2E data to EDM data
 * 
 * <h2>Algorithm</h2>
 * 
 * <p>
 * For all classes that are part of the EDM: Just pass on.
 * </p>
 * 
 * <p>
 * For all classes that have a superclass that is part of the EDM: Use the superclass
 * </p>
 * 
 * @author Konstantin Baierer
 */
public class Dm2e2Edm implements Runnable {

	private static final Logger log = LoggerFactory.getLogger(Dm2e2Edm.class);
	
	enum SparqlQueries {
		SELECT_GET_RDF_TYPE("/sparql-queries/SELECT-get-rdf-type.rq"),
		SELECT_GET_LITERAL("/sparql-queries/SELECT-get-literal.rq"),
//		SELECT_LIST_AGGREGATIONS("/sparql-queries/SELECT-list-aggregations-in-dataset.rq"),
//		SELECT_LIST_LATEST_VERSIONED_DATASETS("/sparql-queries/SELECT-list-latest-versioned-datasets.rq"),
		;
		private static final String prefixesRes = "/sparql-queries/prefixes.rq";
		private final ParameterizedSparqlString query;
		public ParameterizedSparqlString getQuery() {
			return query;
		}
		private SparqlQueries(String resName) {
			ParameterizedSparqlString s = null;
			try {
				s = new ParameterizedSparqlString();
				s.append(Resources.toString(SparqlQueries.class.getResource(prefixesRes), Charset.forName("UTF-8")));
				s.append(Resources.toString(SparqlQueries.class.getResource(resName), Charset.forName("UTF-8")));
			} catch (IOException e) {
//				log.error("NOT FOUND: {}", resName);
				e.printStackTrace();
			}
			this.query = s;
		}
	}
	
	// ******************************
	// CLASS
	// ******************************
	public static final Map<String,String> nsPrefixes = new HashMap<>();
	public static final Model edmModel = ModelFactory.createDefaultModel();
	public static final Model dm2eModel = ModelFactory.createDefaultModel();;
	public static final Model dcTypesModel = ModelFactory.createDefaultModel();;

	public static final Set<Resource> edmProperties = new HashSet<>();
	public static final Map<Resource,LinkedHashSet<Resource>> dm2eSuperProperties = new HashMap<Resource, LinkedHashSet<Resource>>();
	public static final Map<Resource,LinkedHashSet<Resource>> dm2eSuperClasses = new HashMap<Resource, LinkedHashSet<Resource>>();

	private final static Resource OWL_THING = edmModel.createResource(NS.OWL.THING);
	private static final Resource[] prettyTypes = {
		edmModel.createResource(NS.ORE.CLASS_AGGREGATION),
		edmModel.createResource(NS.EDM.CLASS_AGENT),
		edmModel.createResource(NS.EDM.CLASS_EVENT),
		edmModel.createResource(NS.EDM.CLASS_PLACE),
		edmModel.createResource(NS.EDM.CLASS_PROVIDED_CHO),
		edmModel.createResource(NS.EDM.CLASS_TIMESPAN),
		edmModel.createResource(NS.EDM.CLASS_WEBRESOURCE),
	};
	
	static {
		nsPrefixes.put("edm", NS.EDM.BASE);
		nsPrefixes.put("foaf", NS.FOAF.BASE);
		nsPrefixes.put("skos", NS.SKOS.BASE);
		nsPrefixes.put("ore", NS.ORE.BASE);
		nsPrefixes.put("dcterms", NS.DCTERMS.BASE);
		nsPrefixes.put("dc", NS.DC.BASE);
		nsPrefixes.put("dm2e", NS.DM2E_UNVERSIONED.BASE);
		nsPrefixes.put("vocab-status", "http://www.w3.org/2003/06/sw-vocab-status/ns#");

		System.setProperty("http.maxConnections", String.valueOf(100));
		
		// Read ontologies
		edmModel.read(Dm2e2Edm.class.getResourceAsStream("/edm/edm.owl"), null, "RDF/XML");
		dm2eModel.read(Dm2e2Edm.class.getResourceAsStream("/dm2e-model/DM2Ev1.1.owl"), null, "RDF/XML");
		dcTypesModel.read(Dm2e2Edm.class.getResourceAsStream("/dm2e-model/skos_Concepts_DM2E.xml"), null, "RDF/XML");

		buildEdmProperties();
		buildDm2eSuperProperties();
		buildDm2eSuperClasses();
	}

	private static void buildEdmProperties() {
		// datatype properties
		{
			StmtIterator iter = edmModel.listStatements(null, 
					edmModel.createProperty(NS.RDF.PROP_TYPE), 
					edmModel.createProperty(NS.OWL.DATATYPE_PROPERTY));
			while (iter.hasNext())
				edmProperties.add(iter.next().getSubject().asResource());
		}
		// object properties
		{
			StmtIterator iter = edmModel.listStatements(null, 
					edmModel.createProperty(NS.RDF.PROP_TYPE),
					edmModel.createProperty(NS.OWL.OBJECT_PROPERTY));
			while (iter.hasNext())
				edmProperties.add(iter.next().getSubject().asResource());
		}
		// subproperties
		{
			StmtIterator iter = edmModel.listStatements(null, 
					edmModel.createProperty(NS.RDFS.PROP_SUB_PROPERTY_OF),
					(RDFNode)null);
			while (iter.hasNext())
				edmProperties.add(iter.next().getSubject().asResource());
		}
		// subproperties
		Set<Resource> subProperties = new HashSet<>();
		for (Resource edmProperty : edmProperties) {
			StmtIterator iter = edmModel.listStatements(null, 
					edmModel.createProperty(NS.RDFS.PROP_SUB_PROPERTY_OF),
					edmProperty);
			while (iter.hasNext())
				subProperties.add(iter.next().getSubject().asResource());		
		}
		edmProperties.addAll(subProperties);
		edmProperties.add(edmModel.createResource(NS.OWL.SAME_AS));
	}

	private static void buildDm2eSuperClasses() {
		LinkedHashSet<Resource> toCheck = new LinkedHashSet<>();
		// object properties
		{
			StmtIterator iter = dm2eModel.listStatements(null, 
					dm2eModel.createProperty(NS.RDF.PROP_TYPE),
					dm2eModel.createProperty(NS.OWL.CLASS));
			while (iter.hasNext())
				toCheck.add(iter.next().getSubject().asResource());
		}
		for (Resource dm2eClass : toCheck) {
			dm2eSuperClasses.put(dm2eClass, findSuperClassesIn(dm2eModel, dm2eClass, edmModel));
		}
	}
	
	private static void buildDm2eSuperProperties() {
		Set<Resource> toCheck = new HashSet<>();
		// datatype properties
		{
			StmtIterator iter = dm2eModel.listStatements(null, 
					dm2eModel.createProperty(NS.RDF.PROP_TYPE), 
					dm2eModel.createProperty(NS.OWL.DATATYPE_PROPERTY));
			while (iter.hasNext())
				toCheck.add(iter.next().getSubject().asResource());
		}
		// object properties
		{
			StmtIterator iter = dm2eModel.listStatements(null, 
					dm2eModel.createProperty(NS.RDF.PROP_TYPE),
					dm2eModel.createProperty(NS.OWL.OBJECT_PROPERTY));
			while (iter.hasNext())
				toCheck.add(iter.next().getSubject().asResource());
		}
		for (Resource dm2eProperty : toCheck) {
			dm2eSuperProperties.put(dm2eProperty, findSuperPropsIn(dm2eModel, dm2eProperty, edmModel));
		}
	}
	
	private static LinkedHashSet<Resource> findSuperIn(Model source, Resource thing, Model target, Property toParentProp) {
		final LinkedHashSet<Resource> superProps = new LinkedHashSet<Resource>();

		if (target.contains(thing, target.createProperty(NS.RDF.PROP_TYPE), (RDFNode)null)) {
			superProps.add(thing);
		}

		StmtIterator iter = source.listStatements(thing, toParentProp, (Resource)null);
		if (iter.hasNext()) {
			while (iter.hasNext()) {
				final Resource object = iter.next().getObject().asResource();
				if (target.containsResource(object)) {
					superProps.add(object.asResource());
				}
                superProps.addAll(findSuperIn(source, object, target, toParentProp));
			}		
		}
		return superProps;
	}

	private static LinkedHashSet<Resource> findSuperPropsIn(Model source, Resource thing, Model target) {
		final Property toParentProp = source.createProperty(NS.RDFS.PROP_SUB_PROPERTY_OF);
		return findSuperIn(source, thing, target, toParentProp);
	}

	private static LinkedHashSet<Resource> findSuperClassesIn(Model source, Resource thing, Model target) {
		final Property toParentProp = source.createProperty(NS.RDFS.PROP_SUB_CLASS_OF);
		return findSuperIn(source, thing, target, toParentProp);
	}
	
	
	// ******************************
	// INSTANCE
	// ******************************

	private final Model inputModel;
	private final Model outputModel;
	private final String inputSerialization;
	private final String outputSerialization;
	private final Path outputFile;
	private final Path inputFile;
	private final Properties configProps;
	private final Set<Resource> skipSet = new HashSet<>();
	private final Set<String> skosPrefLabelCache = new HashSet<>();
	
	public Dm2e2Edm(Model inputModel, Model outputModel) {
		this.inputModel = inputModel;
		this.outputModel  = outputModel;
		inputModel.setNsPrefixes(nsPrefixes);
		outputModel.setNsPrefixes(nsPrefixes);
		this.outputFile = null;
		this.outputSerialization = null;
		this.inputFile = null;
		this.inputSerialization = null;
		this.configProps = new Properties();
	}

	public Dm2e2Edm(Path inputFile, String inputSerialization,
			Path outputFile, String outputSerialization, Properties configProps) {
		super();
		this.inputModel = ModelFactory.createDefaultModel();
		this.outputModel = ModelFactory.createDefaultModel();
		inputModel.setNsPrefixes(nsPrefixes);
		outputModel.setNsPrefixes(nsPrefixes);
		this.inputFile = inputFile;
		this.inputSerialization = inputSerialization;
		this.outputFile = outputFile;
		this.outputSerialization = outputSerialization;
		this.configProps = configProps;
	}

	public Dm2e2Edm(Path inputFile, String inputSerialization,
			Path outputFile, String outputSerialization) {
		this(inputFile, inputSerialization, outputFile, outputSerialization, new Properties());
	}

	private synchronized void convertResourceInInputModel(Resource res) {
		
//		log.debug("Converting <{}>", res);
		StmtIterator stmtIter = inputModel.listStatements(res, null, (RDFNode)null);
		if (stmtIter.hasNext()) {

			// add correct rdf:type
			Resource origType = null;
			Resource targetType = null;
			for (Resource type : getRdfTypes(res)) {
				origType = type;
				break;
			}
			if (null == origType) {
				log.debug("Resource {} has no rdf:type. Skipping.", res);
				skipSet.add(res);
				return;
			}
			Set<Resource> superTypes = dm2eSuperClasses.get(origType);
			if (null == superTypes || superTypes.isEmpty()) {
				log.debug("No EDM type for DM2E type {}", origType);
				skipSet.add(res);
				return;
			} else {
				for (Resource thisSuperType : superTypes) {
					targetType = thisSuperType;
					break;
				}
			}
			outputModel.add(res, res(NS.RDF.PROP_TYPE), targetType);
			
			//
			// edm:ProvidedCHO
			//
			if (targetType.getURI().equals(NS.EDM.CLASS_PROVIDED_CHO)) {
				outputModel.add(res, res(NS.DC.PROP_SOURCE), res);
			}
			
			//
			// Walk the statements
			//
			while (stmtIter.hasNext()) {
				Statement stmt = stmtIter.next();
				Property prop = stmt.getPredicate();
				Resource targetSubject = stmt.getSubject().asResource();
				RDFNode targetObject = stmt.getObject();
				Property targetProp = null;
				
				if (! dm2eSuperProperties.containsKey(prop) || null == dm2eSuperProperties.get(prop)) {
					if (!(prop.getURI().equals(NS.RDF.PROP_TYPE))){
						log.debug("Not in DM2E: {}", prop);
					}
					continue;
				}
				if (edmProperties.contains(prop)) {
					targetProp = prop;
				} else {
					boolean foundSuper = false;
					for (Resource superProp : dm2eSuperProperties.get(prop))
						if (edmProperties.contains(superProp)) {
							log.debug("SUPER PROP {} --> {}", prop, superProp);
							targetProp = outputModel.createProperty(superProp.getURI());
							foundSuper = true;
							break;
						}
					if (! foundSuper) {
						log.debug("Didn't find an EDM compatible super property for {}", prop);
						continue;
					}
				}
				addToTarget(targetSubject, targetProp, targetObject);
			}
		}
	}

	private final synchronized Property res(String uri) {
		return inputModel.createProperty(uri);
	}
	
	private final synchronized String getLiteralString(RDFNode res, Property prop) {
		Literal lit = getLiteral(res, prop);
		return null != lit ? lit.getLexicalForm() : "";
	}

	private final synchronized Literal getLiteral(RDFNode res, Property prop) {
		Literal ret = null;
		if (! res.isResource()) {
			log.trace("Resource {} is not a resource. Skipping.", res);
		} else {
			ParameterizedSparqlString rdfTypeQuery = SparqlQueries.SELECT_GET_LITERAL.getQuery();
			rdfTypeQuery.setParam("res", res.asResource());
			rdfTypeQuery.setParam("prop", prop);
//			log.debug(rdfTypeQuery.toString());
			QueryExecution qExec = QueryExecutionFactory.create(rdfTypeQuery.asQuery(), inputModel);
			qExec.setTimeout(10000);
			ResultSet rs = qExec.execSelect();
			if (rs.hasNext()) {
				ret = rs.next().get("val").asLiteral();
			} else {
//				System.err.println("+*************+");
//				System.err.println("|*** ERROR ***|");
//				System.err.println(rdfTypeQuery.toString());
//				System.err.println("+*************+");
			}
		}
		return ret;
	}
	
	private final synchronized LinkedHashSet<Resource> getRdfTypes(Resource res) {
		final LinkedHashSet<Resource> types = new LinkedHashSet<>();
		ParameterizedSparqlString rdfTypeQuery = SparqlQueries.SELECT_GET_RDF_TYPE.getQuery();
		rdfTypeQuery.setParam("res", res.asResource());
		QueryExecution qExec = QueryExecutionFactory.create(rdfTypeQuery.asQuery(), inputModel);
//		qExec.setTimeout(5000);
		ResultSet rs = qExec.execSelect();
		if (rs.hasNext()) {
			types.add(rs.next().get("type").asResource());
		} else {
			types.add(OWL_THING);
		}
		qExec.close();
		for (Resource type : types) {
			if (dm2eSuperClasses.containsKey(type)) {
				types.addAll(dm2eSuperClasses.get(type));
			}
		}
		return types;
	}

	private synchronized void addToTarget(Resource targetSubject, Property targetProp, RDFNode targetObject) {
//		log.debug("STMT");
//		log.debug("  S: {}", targetSubject);
//		log.debug("  P: {}", targetProp);
//		log.debug("  O: {}", targetObject);

		
		// If this flag is set, skip adding the statement using the generic solution 
		boolean skipGeneric = false;

		if (targetObject.isResource() && targetProp.getURI().equals(NS.EDM.PROP_PROVIDER)) {
			//
			// HACK
			// Hard-code edm:provider to DM2E (Some providers didn't specify a skos:prefLabel here)
			//
			outputModel.add(targetSubject, targetProp, "DM2E");
			skipSet.add(targetObject.asResource());
			skipGeneric = true;
		} else if (targetProp.getURI().equals(NS.EDM.PROP_TYPE)) {
			//
			// HACK
			// Hard-code edm:type to "TEXT" (Some providers had the case wrong)
			//
			outputModel.add(targetSubject, targetProp, "TEXT");
			skipGeneric = true;
		} else if (getRdfTypes(targetSubject).contains(res(NS.ORE.CLASS_AGGREGATION)) 
				&& (
						dm2eSuperProperties.get(res(targetProp.getURI())).contains(res(NS.EDM.PROP_HAS_MET))
                )) {
			//
			// Don't add any edm:hasMet superproperties to an ore:Aggregation
			//
			if (targetObject.isResource())
				skipSet.add(targetObject.asResource());
			skipGeneric = true;
		} else if (targetObject.isResource() && (
				getRdfTypes(targetObject.asResource()).contains(res(NS.EDM.CLASS_TIMESPAN))
				||
				getRdfTypes(targetObject.asResource()).contains(res(NS.EDM.BASE + "timeSpan"))
				)) {
			//
			// Turn one-year timespans into xsd:gYear literals 
			//
			Resource res = targetObject.asResource();
			String begin = getLiteralString(res, res(NS.EDM.PROP_BEGIN));
			String end = getLiteralString(res, res(NS.EDM.PROP_END));
//			if ("true".equals(configProps.getProperty("shortenYear", "true"))) {
			if (null != begin && null != end && begin.length() >= 10 && end.length() >= 10) {
//				log.debug("TIMESTAMP");
				final String beginYear = begin.substring(0,4);
				final String endYear = end.substring(0,4);
				final String beginDM = begin.substring(5,10);
				final String endDM = end.substring(5,10);
				if (beginYear.equals(endYear)) {
					// one year timespan
					if (beginDM.equals("01-01") && endDM.equals("12-31")) {
//						log.debug("ONEYEAR TIMESTAMP");
						outputModel.add(targetSubject, targetProp, outputModel.createLiteral(beginYear));
						skipSet.add(res);
						skipGeneric = true;
					// one day timespan
					} else if (beginDM.equals(endDM)) {
//						log.debug("ONEDAY TIMESTAMP");
						outputModel.add(targetSubject, targetProp, outputModel.createLiteral(end.substring(0,10)));
						skipSet.add(res);
						skipGeneric = true;
					}
				}
			} else {
				log.error("Bad Timespan!");
			}
//			log.error("SKIPPING " + res);
//			skipGeneric = true;
//			}
		} else if (targetObject.isLiteral() 
				&& (
//						(targetObject.asLiteral().getDatatype() !=null &&  targetObject.asLiteral().getDatatypeURI().equals(NS.XSD.DATETIME))
//						||
						targetObject.asLiteral().getLexicalForm().matches("\\d{4}-\\d{2}-\\d{2}.*")
                    )) {
			//
			// xsd:datetime -> xsd:date
			//
			String newVal = targetObject.asLiteral().getLexicalForm().substring(0, "2000-01-01".length());
//			targetObject = inputModel.createTypedLiteral(newVal, XSDDatatype.XSDdate);
			targetObject = inputModel.createLiteral(newVal);
			outputModel.add(targetSubject, targetProp, targetObject);
			skipGeneric = true;
		} else if (targetObject.isResource() && targetProp.getURI().equals(NS.DC.PROP_TYPE)) {
			// dc:type -> lastUriSegment -> edm:hasType
			outputModel.add(targetSubject, outputModel.createProperty(NS.EDM.PROP_HAS_TYPE), lastUriSegment(targetObject.toString()));
			
			// Now add the data about the dc:type class here
			StmtIterator iter = dcTypesModel.listStatements(targetObject.asResource(), null, (RDFNode)null);
			while (iter.hasNext()) {
				outputModel.add(iter.next());
			}
			
		} else if (targetObject.isResource() && targetProp.getURI().equals(NS.EDM.PROP_DATA_PROVIDER)) {
			//
			// edm:provider and edm:dataProvider -> skos:prefLabel
			//
			Literal prefLabelLiteral = getLiteral(targetObject, inputModel.createProperty(NS.SKOS.PROP_PREF_LABEL));
			if (null == prefLabelLiteral) {
				log.error("No skos:prefLabel for dataProvider <%s>", targetObject);
			} else { 
				outputModel.add(targetSubject, targetProp, prefLabelLiteral);
			}
			skipSet.add(targetObject.asResource());
			skipGeneric = true;
		} else if (targetProp.getURI().equals(NS.OWL.SAME_AS)
					&& getRdfTypes(targetSubject.asResource()).contains(res(NS.SKOS.CLASS_CONCEPT))) {

			//
			// If prop is owl:sameAs and rdf:type of subject is skos:Concept, replace owl:sameAs with skos:exactMatch
			//
			outputModel.add(targetSubject, outputModel.createProperty(NS.SKOS.PROP_EXACT_MATCH), targetObject);
			skipGeneric = true;
		} else if (targetProp.getURI().equals(NS.SKOS.PROP_PREF_LABEL) && targetObject.isLiteral()) {

			//
			// Make sure that every thing in the output graph has at most 1 skos:prefLabel
			//
			String key = targetSubject.getURI() + targetObject.asLiteral().getLanguage();
			if (skosPrefLabelCache.contains(key)) {
				targetProp = outputModel.createProperty(NS.SKOS.PROP_ALT_LABEL);
			} else {
				skosPrefLabelCache.add(key);
			}
		} else if (targetObject.isResource()
				&& inputModel.contains(targetObject.asResource(), inputModel.createProperty(NS.OWL.SAME_AS))) {

			//
			// If object is owl:sameAs as something else and that something else is either a GND or VIAF link:
			// don't link to the object but the the GND or VIAF URI.
			//
			Set<Resource> sameAsSet = new HashSet<>();
			StmtIterator iter = targetObject.asResource().listProperties(inputModel.createProperty(NS.OWL.SAME_AS));
			while (iter.hasNext()) {
				RDFNode o = iter.next().getObject();
				if (o.isResource())
					sameAsSet.add(o.asResource());
			}
			String[] arr = { "gnd", "viaf" };
			SAME_AS_LOOP:
			for (String krz : arr) {
				for (Resource sameAsRes : sameAsSet) {
					if (sameAsRes.getURI().contains(krz)) {
						outputModel.add(targetSubject, targetProp, sameAsRes);
						skipGeneric = true;
						skipSet.add(targetObject.asResource());
						//
						// Also skip all the resources that were being linked to by the obsolete local agent
						//
//						StmtIterator resIter = inputModel.listStatements(targetObject.asResource(), null, (RDFNode)null);
//						while (resIter.hasNext()) {
//							RDFNode res = resIter.next().getObject();
//							if (res.isResource()) {
//								skipSet.add(res.asResource());
//							}
//						}
						break SAME_AS_LOOP;
					}
				}
			}
		}
		
		log.debug("PROP: {}", targetProp.getURI());

		//
		// Generic copying of statements from input to outpu
		//
		if (!skipGeneric) {
		
			// NOTE: Strip all rdf:datatypes, Europeana cannot handle them :(
			if (targetObject.isLiteral() && targetObject.asLiteral().getDatatype() != null) {
				Literal cleanedLiteral;
				if (targetObject.asLiteral().getLanguage().equals("")) {
					cleanedLiteral = outputModel.createLiteral(targetObject.asLiteral().getLexicalForm());
				} else {
					cleanedLiteral = outputModel.createLiteral(targetObject.asLiteral().getLexicalForm(), targetObject.asLiteral().getLanguage());
				}
				outputModel.add(targetSubject, targetProp, cleanedLiteral);
			} else {
				outputModel.add(targetSubject, targetProp, targetObject);
			}
		}
		
	}
//	private void addToTarget(Resource targetSubject, Property targetProp, String targetObject) {
//		outputModel.add(targetSubject, targetProp, targetObject);
//	}
	
	private synchronized static String lastUriSegment(String uri) {
		return uri.substring(uri.lastIndexOf('/')+1);
	}

	@Override
	public synchronized void run() {
		
		if (inputFile != null) {
			try {
				final InputStream is = Files.newInputStream(inputFile, StandardOpenOption.READ);
				inputModel.read(is, "", inputSerialization);
				is.close();
			} catch (Exception e) {
				System.out.println("Couldn't parse as RDF: " + inputFile);
				e.printStackTrace();
				return;
			}
		}

		// NOTE: We start with Aggregation and CHO and then the rest
		// so as to not add anything that is explicitly skipped (such as unconnected agents or timespans)
		ArrayList<Resource> resList = new ArrayList<Resource>();
		{
			ResIterator iter = inputModel.listSubjectsWithProperty(inputModel.createProperty(NS.RDF.PROP_TYPE), inputModel.createResource(NS.ORE.CLASS_AGGREGATION));
			while (iter.hasNext()) {
				final Resource agg = iter.next();
				StmtIterator choIter = agg.listProperties(inputModel.createProperty(NS.EDM.PROP_AGGREGATED_CHO));
				if (choIter.hasNext()) {
					Resource cho = choIter.next().getObject().asResource();
					
					// Skip Pages, #104
					if (inputModel.contains(cho, inputModel.createProperty(NS.DC.PROP_TYPE), inputModel.createResource(NS.DM2E_UNVERSIONED.CLASS_PAGE))) {
						continue;
					}

					resList.add(agg);
					resList.add(cho);
				}
			}
		}
//		{
//			ResIterator iter = inputModel.listSubjectsWithProperty(inputModel.createProperty(NS.RDF.PROP_TYPE), inputModel.createResource(NS.EDM.CLASS_PROVIDED_CHO));
//			while (iter.hasNext()) resList.add(iter.next());
//		}
		{
			ResIterator iter = inputModel.listSubjects();
			while (iter.hasNext()) {
				resList.add(iter.next());
			}
		}
		for (Resource res : resList) {
			if (!skipSet.contains(res)) {
				log.debug("CURRENT RESOURCE " + res);
				convertResourceInInputModel(res);
				skipSet.add(res);
			} else  {
//				log.debug("SKIP CURRENT RESOURCE " + res);
			}
		}
//		log.debug("IN: {}", inputModel.size());
//		log.debug("OUT: {}", outputModel.size());
		if (null != outputFile) {
			try {
				OutputStream out = Files.newOutputStream(outputFile, StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
				RDFWriter writer = outputModel.getWriter(outputSerialization);
				if (outputSerialization.equals("RDF/XML-ABBREV")) {
					writer.setProperty("prettyTypes", prettyTypes);
//					writer.setProperty("blockRules", "propertyAttr");
				}
				writer.write(outputModel, out, "");
				out.close();
			} catch (IOException e) {
				log.error("Couldn't write to output file {}: {}", outputFile, e);
			}
		}
	}
}