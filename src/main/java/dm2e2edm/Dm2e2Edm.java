package dm2e2edm;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;

import org.apache.jena.riot.Lang;
import org.apache.jena.riot.RDFDataMgr;
import org.apache.jena.riot.system.StreamRDFBase;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.base.Preconditions;
import com.hp.hpl.jena.graph.Node;
import com.hp.hpl.jena.query.ParameterizedSparqlString;
import com.hp.hpl.jena.query.QueryExecution;
import com.hp.hpl.jena.query.QueryExecutionFactory;
import com.hp.hpl.jena.query.ResultSet;
import com.hp.hpl.jena.rdf.model.Literal;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.rdf.model.Property;
import com.hp.hpl.jena.rdf.model.RDFNode;
import com.hp.hpl.jena.rdf.model.ResIterator;
import com.hp.hpl.jena.rdf.model.Resource;
import com.hp.hpl.jena.rdf.model.Statement;
import com.hp.hpl.jena.rdf.model.StmtIterator;
import com.hp.hpl.jena.sparql.core.Quad;

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
public class Dm2e2Edm {
	
	private static final Logger log = LoggerFactory.getLogger(Dm2e2Edm.class);
	
	public static final String EDM_OWL_RESOURCE = "/edm/edm.owl";
	public static final String DM2E_OWL_RESOURCE = "/dm2e-model/DM2Ev1.1.owl";

	public static final Model edmModel = ModelFactory.createDefaultModel();
	public static final Model dm2eModel = ModelFactory.createDefaultModel();;

	public static final Set<Resource> edmProperties = new HashSet<>();
	public static final Map<Resource,LinkedHashSet<Resource>> dm2eSuperProperties = new HashMap<Resource, LinkedHashSet<Resource>>();
	public static final Map<Resource,LinkedHashSet<Resource>> dm2eSuperClasses = new HashMap<Resource, LinkedHashSet<Resource>>();

	private static final Resource	SKOS_CONCEPT	= edmModel.createResource(NS.SKOS.CLASS_CONCEPT);
	private static final Resource	EDM_AGENT	= edmModel.createResource(NS.EDM.CLASS_AGENT);
	private static final Property	SKOS_PREF_LABEL	= edmModel.createProperty(NS.SKOS.PROP_PREF_LABEL);
	public static final Resource OWL_THING = edmModel.createResource(NS.OWL.THING);
	public static final Resource RDFS_LITERAL = edmModel.createResource(NS.RDFS.CLASS_LITERAL);
	
	private static final Map<Resource, LinkedHashSet<Resource>> typeCache = new HashMap<>();
	private static final Map<RDFNode, Map<Property, String>> literalCache = new HashMap<>();
	
	private final Model dummyModel = ModelFactory.createDefaultModel();
	private final boolean streaming;
	private final String sparqlEndpoint;
	private final OutputStream outputStream;
	private final InputStream inputStream;
	private final Model inputModel;
	private final Model outputModel;
	private String	inputSerialization = "N-QUAD";
	private String	outputSerialization = "N-TRIPLE";

	
	public Dm2e2Edm(Model inputModel, Model outputModel) {
		this.inputModel = inputModel;
		this.outputModel  = outputModel;
		this.streaming = false;
		this.sparqlEndpoint = null;
		this.outputStream = null;
		this.inputStream = null;
	}
	
	public Dm2e2Edm(String sparqlEndpoint,
			InputStream inputStream,
			OutputStream outputStream
			) {
		super();
		this.streaming = true;
		this.sparqlEndpoint = sparqlEndpoint;
		this.inputStream = inputStream;
		this.outputStream = outputStream;
		// TODO validate
		this.inputModel = null;
		this.outputModel = ModelFactory.createDefaultModel();
	}

	static {
		edmModel.read(Dm2e2Edm.class.getResourceAsStream(EDM_OWL_RESOURCE), null, "RDF/XML");
		
		dm2eModel.read(Dm2e2Edm.class.getResourceAsStream(DM2E_OWL_RESOURCE), null, "RDF/XML");

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

	private  void convertResource(Resource res) {
		
		log.debug("Converting <{}>", res);
		StmtIterator stmtIter = inputModel.listStatements(res, null, (RDFNode)null);
		if (stmtIter.hasNext()) {

			// add correct rdf:type
			Resource targetType = null;
			for (Resource type : getRdfTypes(res)) {
				targetType = type;
				break;
			}
			if (null == targetType) {
				log.debug("Resource {} has no rdf:type. Skipping.", res);
				return;
			}
			Set<Resource> superTypes = dm2eSuperClasses.get(targetType);
			if (null == superTypes || superTypes.isEmpty()) {
				log.debug("No EDM type for DM2E type {}", targetType);
				return;
			}
			for (Resource superType : superTypes) {
				outputModel.add(res, inputModel.createProperty(NS.RDF.PROP_TYPE), superType);
				break;
			}

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
							targetProp = outputModel.createProperty(superProp.getURI());
							foundSuper = true;
							break;
						}
					if (! foundSuper) {
						log.debug("Didn't find an EDM compatible super property for {}", prop);
						continue;
					}
				}
				addStatementToTarget(targetSubject, targetProp, targetObject);
			}
		}
	}

	private final String getLiteral(RDFNode res, Property prop) {
		String ret = null;
		if (! literalCache.containsKey(res)) {
			literalCache.put(res, new HashMap<Property,String>());
		} else if (literalCache.get(res).containsKey(prop)) {
			return literalCache.get(res).get(prop);
		}
		if (! res.isResource()) {
			log.trace("Resource {} is not a resource. Skipping.", res);
		} else {
			if (! streaming) {
				final StmtIterator iter = inputModel.listStatements(res.asResource(), prop, (RDFNode)null);
				if (! iter.hasNext()) {
					log.debug("Resource {} has no {}. Skipping.", res, prop);
				} else {
					final RDFNode object = iter.next().getObject();
					if (! object.isLiteral()) {
						log.debug("Object of <{}> <{}> not a literal. Skipping.", res, prop);
					}
					ret = object.asLiteral().getLexicalForm();
				}
			} else {
				ParameterizedSparqlString rdfTypeQuery = new ParameterizedSparqlString("SELECT ?val WHERE { GRAPH ?g { ?res ?prop ?val } } LIMIT 1");
				rdfTypeQuery.setParam("res", res.asResource());
				rdfTypeQuery.setParam("prop", prop);
				QueryExecution qExec = QueryExecutionFactory.createServiceRequest(sparqlEndpoint, rdfTypeQuery.asQuery());
				ResultSet rs = qExec.execSelect();
				if (rs.hasNext()) {
					ret = rs.next().get("val").asLiteral().getLexicalForm();
				} 
			}
		}
		literalCache.get(res).put(prop, ret);
		return ret;
	}
	
	private  final LinkedHashSet<Resource> getRdfTypes(Resource res) {
		if (typeCache.containsKey(res)) {
			return typeCache.get(res);
		}
		final Resource owlThing = edmModel.createResource(NS.OWL.THING);
		final Resource rdfsLiteral = edmModel.createResource(NS.RDFS.CLASS_LITERAL);
		final LinkedHashSet<Resource> types = new LinkedHashSet<>();
		if (! streaming) {
			final StmtIterator typeIter = inputModel.listStatements(res.asResource(), inputModel.createProperty(NS.RDF.PROP_TYPE), (RDFNode)null);
			if (! typeIter.hasNext()) {
				log.debug("Resource {} has no rdf:type. Skipping.", res);
				types.add(owlThing);
			} else {
				types.add(typeIter.next().getObject().asResource());
			}
		} else {
			ParameterizedSparqlString rdfTypeQuery = new ParameterizedSparqlString("SELECT ?type WHERE { GRAPH ?g { ?res <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?type } } LIMIT 1");
			rdfTypeQuery.setParam("res", res.asResource());
			QueryExecution qExec = QueryExecutionFactory.createServiceRequest(sparqlEndpoint, rdfTypeQuery.asQuery());
			ResultSet rs = qExec.execSelect();
			if (rs.hasNext()) {
				types.add(rs.next().get("type").asResource());
			} else {
				types.add(owlThing);
			}
		}
		for (Resource type : types) {
			if (dm2eSuperClasses.containsKey(type)) {
				types.addAll(dm2eSuperClasses.get(type));
			}
		}
		typeCache.put(res, types);
		return types;
	}

	private void addStatementToTarget(
			Resource targetSubject,
			Property targetProp,
			RDFNode targetObject) {
		if ( targetObject.isResource() && (
				getRdfTypes(targetObject.asResource()).contains(EDM_AGENT)
				||
				getRdfTypes(targetObject.asResource()).contains(SKOS_CONCEPT))) {
			String prefLabel = getLiteral(targetObject.asResource(), SKOS_PREF_LABEL);
			if (null != prefLabel) {
				addToTarget(targetSubject, targetProp, prefLabel);
				addToTarget(targetSubject, targetProp, targetObject);
			}
		} else if (targetProp.getURI().equals(NS.DC.PROP_TYPE)) {
			if (targetObject.isResource()) {
				Literal literalObject = dummyModel.createLiteral(lastUriSegment(targetObject.asResource().getURI()));
				final Property EDM_HAS_TYPE = edmModel.createProperty(NS.EDM.PROP_HAS_TYPE);
				addToTarget(targetSubject, EDM_HAS_TYPE, literalObject);
			}
		} else {
			addToTarget(targetSubject, targetProp, targetObject);
		}
		if (streaming) {
			try {
				outputStream.flush();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}
	
	private void addToTarget(Resource targetSubject, Property targetProp, RDFNode targetObject) {
		if (streaming) {
			dummyModel.removeAll();
			dummyModel.add(targetSubject, targetProp, targetObject);
			dummyModel.write(outputStream, outputSerialization);
		} else {
			outputModel.add(targetSubject, targetProp, targetObject);
		}
	}
	private void addToTarget(Resource targetSubject, Property targetProp, String targetObject) {
		if (streaming) {
			dummyModel.removeAll();
			dummyModel.add(targetSubject, targetProp, targetObject);
			dummyModel.write(outputStream, outputSerialization);
		} else {
			outputModel.add(targetSubject, targetProp, targetObject);
		}
	}
	
	public void convertDumptoEdm() {
		Preconditions.checkArgument(streaming, "This method works only for streaming workflow");
		Dm2e2EdmConversionFilter filter = new Dm2e2EdmConversionFilter(this);
		RDFDataMgr.parse(filter, inputStream, "", Lang.NQUADS);
	}

	public void convertDm2eModelToEdmModel() {
		Preconditions.checkArgument(! streaming, "This method works only for non-streaming workflow");
		ResIterator iter = inputModel.listSubjects();
		while (iter.hasNext()) {
			Resource res = iter.next();
			convertResource(res);
		}
	}
	
	private static String lastUriSegment(String uri) {
		return uri.substring(uri.lastIndexOf('/')+1);
	}
	
	private static class Dm2e2EdmConversionFilter extends StreamRDFBase {
		
		private static final Logger log = LoggerFactory
			.getLogger(Dm2e2Edm.Dm2e2EdmConversionFilter.class);
		private Model dummyModel = ModelFactory.createDefaultModel();
		private final Dm2e2Edm dm2e2edm;
		private int counter = 0;

		public Dm2e2EdmConversionFilter(Dm2e2Edm dm2e2edm) {
			super();
			this.dm2e2edm = dm2e2edm;
		}

		@Override
		public void quad(Quad quad) {
			final Resource s = dummyModel.createResource(quad.getSubject().getURI());
			final Property p = dummyModel.createProperty(quad.getPredicate().getURI());
			final RDFNode o;
			Node oNode = quad.getObject();
			if (oNode.isLiteral()) {
				o = dummyModel.createLiteral(oNode.getLiteralLexicalForm());
			} else {
				o = dummyModel.createResource(oNode.getURI());
			}
			if (p.getURI().equals(NS.RDF.PROP_TYPE)) {
				if (! Dm2e2Edm.typeCache.containsKey(s)) {
					Dm2e2Edm.typeCache.put(s, new LinkedHashSet<Resource>());
				}
				final Resource type = o.asResource();
				Dm2e2Edm.typeCache.get(s).add(type);
				if (Dm2e2Edm.dm2eSuperClasses.containsKey(type)) {
					Dm2e2Edm.typeCache.get(s).addAll(Dm2e2Edm.dm2eSuperClasses.get(type));
				}
			}
			dm2e2edm.addStatementToTarget(s, p, o);
			counter++;
			if (counter % 1000 == 0) {
				System.out.print(counter);
				System.out.print(" <");
				System.out.print(s.toString());
				System.out.print(">\n");
			}
		}
		
		
	}
}