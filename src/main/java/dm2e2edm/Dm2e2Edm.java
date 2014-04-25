package dm2e2edm;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.hp.hpl.jena.rdf.model.Literal;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.rdf.model.Property;
import com.hp.hpl.jena.rdf.model.RDFNode;
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
public class Dm2e2Edm {
	
	private static final Logger log = LoggerFactory.getLogger(Dm2e2Edm.class);
	
	public static final String EDM_OWL_RESOURCE = "/edm/edm.owl";
	public static final String DM2E_OWL_RESOURCE = "/dm2e-model/DM2Ev1.1.owl";
	
	public static final Model edmModel;
	public static final Model dm2eModel;
	public static final Set<Resource> edmProperties = new HashSet<>();
	public static final Map<Resource,List<Resource>> dm2eSuperProperties = new HashMap<Resource, List<Resource>>();
	public static final Map<Resource,List<Resource>> dm2eSuperClasses = new HashMap<Resource, List<Resource>>();
	
	static {
		edmModel = ModelFactory.createDefaultModel();
		edmModel.read(Dm2e2Edm.class.getResourceAsStream(EDM_OWL_RESOURCE), null, "RDF/XML");
		
		dm2eModel = ModelFactory.createDefaultModel();
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
		Set<Resource> toCheck = new HashSet<>();
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
	
	private static ArrayList<Resource> findSuperIn(Model source, Resource thing, Model target, Property toParentProp) {
		final ArrayList<Resource> superProps = new ArrayList<Resource>();

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

	private static ArrayList<Resource> findSuperPropsIn(Model source, Resource thing, Model target) {
		final Property toParentProp = source.createProperty(NS.RDFS.PROP_SUB_PROPERTY_OF);
		return findSuperIn(source, thing, target, toParentProp);
	}

	private static ArrayList<Resource> findSuperClassesIn(Model source, Resource thing, Model target) {
		final Property toParentProp = source.createProperty(NS.RDFS.PROP_SUB_CLASS_OF);
		return findSuperIn(source, thing, target, toParentProp);
	}

	private static void convertResource(Model source, Resource res, Model target) {
		
		log.debug("Converting <{}>", res);
		StmtIterator stmtIter = source.listStatements(res, null, (RDFNode)null);
		if (stmtIter.hasNext()) {

			// add correct rdf:type
			Resource targetType = getRdfType(source, res);
			if (null == targetType) {
				log.debug("Resource {} has no rdf:type. Skipping.", res);
				return;
			}
			List<Resource> superTypes = dm2eSuperClasses.get(targetType);
			if (null == superTypes || superTypes.isEmpty()) {
				log.debug("No EDM type for DM2E type {}", targetType);
				return;
			}
			target.add(res, source.createProperty(NS.RDF.PROP_TYPE), superTypes.get(0));

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
							targetProp = target.createProperty(superProp.getURI());
							foundSuper = true;
							break;
						}
					if (! foundSuper) {
						log.debug("Didn't find an EDM compatible super property for {}", prop);
						continue;
					}
				}
				addStatementToTarget(source, targetSubject, targetObject, targetProp, targetType, target);
			}
		}
	}
	
	private static final Resource getRdfType(Model m, RDFNode res) {
		final Resource owlThing = m.createResource(NS.OWL.THING);
		if (! res.isResource()) {
			log.trace("Resource {} is not a resource. Skipping.", res);
			return owlThing;
		} else {
			final StmtIterator typeIter = m.listStatements(res.asResource(), m.createProperty(NS.RDF.PROP_TYPE), (RDFNode)null);
			if (! typeIter.hasNext()) {
				log.debug("Resource {} has no rdf:type. Skipping.", res);
				return owlThing;
			} else {
				return typeIter.next().getObject().asResource();
			}
		}
	}

	private static void addStatementToTarget(Model source, Resource targetSubject,
			RDFNode targetObject,
			Property targetProp,
			Resource targetType,
			Model target) {
		if (
				getRdfType(target, targetObject).getURI().equals(NS.EDM.CLASS_AGENT)
				||
				getRdfType(target, targetObject).getURI().equals(NS.SKOS.CLASS_CONCEPT)) {
			StmtIterator prefLabelStmtIter = source.listStatements(targetObject.asResource(),
					source.createProperty(NS.SKOS.PROP_PREF_LABEL),
					(RDFNode) null);
			if (prefLabelStmtIter.hasNext()){
				String prefLabel = prefLabelStmtIter.next().getObject().asLiteral().getLexicalForm();
				target.add(targetSubject, targetProp, prefLabel);
				target.add(targetSubject, targetProp, targetObject);
			}
		} else if (targetProp.getURI().equals(NS.DC.PROP_TYPE)) {
			if (targetObject.isResource()) {
				Literal literalObject = target.createLiteral(lastUriSegment(targetObject.asResource().getURI()));
				target.add(targetSubject, target.createProperty(NS.EDM.PROP_HAS_TYPE), literalObject);
			}
		} else {
			target.add(targetSubject, targetProp, targetObject);
		}
	}
	
	public static Model convertToEdm(Model m) {
		Model ret = ModelFactory.createDefaultModel();
		ResIterator iter = m.listSubjects();
		while (iter.hasNext()) {
			Resource res = iter.next();
			convertResource(m, res, ret);
		}
		return ret;
	}
	
	private static String lastUriSegment(String uri) {
		return uri.substring(uri.lastIndexOf('/')+1);
	}
}