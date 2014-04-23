package dm2e2edm;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.rdf.model.Property;
import com.hp.hpl.jena.rdf.model.RDFNode;
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
	
	static {
		edmModel = ModelFactory.createDefaultModel();
		edmModel.read(Dm2e2Edm.class.getResourceAsStream(EDM_OWL_RESOURCE), null, "RDF/XML");
		
		dm2eModel = ModelFactory.createDefaultModel();
		dm2eModel.read(Dm2e2Edm.class.getResourceAsStream(DM2E_OWL_RESOURCE), null, "RDF/XML");

		buildEdmProperties();
		
		buildDm2eSuperProperties();
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
			dm2eSuperProperties.put(dm2eProperty, findSuperProps(dm2eModel, dm2eProperty, true));
		}
	}

	private static ArrayList<Resource> findSuperProps(Model m, Resource prop, boolean recurse) {
		final ArrayList<Resource> superProps = new ArrayList<Resource>();
		StmtIterator iter = m.listStatements(prop, m.createProperty(NS.RDFS.PROP_SUB_PROPERTY_OF), (Resource)null);
		if (iter.hasNext()) {
			while (iter.hasNext()) {
				final Resource object = iter.next().getObject().asResource();
				superProps.add(object.asResource());
				if (recurse) {
					superProps.addAll(findSuperProps(m, object, recurse));
				}
			}		
		}
		return superProps;
	}

	private static void convertResource(Model source, Resource agg, Model target) {
		StmtIterator iter = source.listStatements(agg, null, (RDFNode)null);
		while (iter.hasNext()) {
			Statement stmt = iter.next();
			Property prop = stmt.getPredicate();
			if (edmProperties.contains(prop)) {
				target.add(stmt);
			} else if (dm2eSuperProperties.containsKey(prop)) {
				boolean foundSuper = false;
				for (Resource superProp : dm2eSuperProperties.get(prop)) {
					if (edmProperties.contains(superProp)) {
						target.add(stmt.getSubject(), target.createProperty(superProp.getURI()), stmt.getObject());
						foundSuper = true;
						break;
					}
				}
				if (! foundSuper) {
					log.debug("Didn't find an EDM compatible super property for {}", prop);
				}
			} else {
				log.debug("Not in DM2E: {}", prop);
			}
		}
	}
	
	public static Model convertToEdm(Model m) {
		HashSet<String> types = new HashSet<>();
		types.add(NS.EDM.CLASS_PROVIDED_CHO);
		types.add(NS.EDM.CLASS_AGENT);
		types.add(NS.EDM.CLASS_EVENT);
		types.add(NS.EDM.CLASS_PLACE);
		types.add(NS.EDM.CLASS_TIMESPAN);
		types.add(NS.EDM.CLASS_WEBRESOURCE);
		types.add(NS.ORE.CLASS_AGGREGATION);
		types.add(NS.FOAF.CLASS_ORGANIZATION);
		types.add(NS.FOAF.CLASS_PERSON);

		Model ret = ModelFactory.createDefaultModel();
		for (String type : types) {
			StmtIterator iter = m.listStatements(null, m.createProperty(NS.RDF.PROP_TYPE), m.createResource(type));
			while (iter.hasNext()) {
				Resource res = iter.next().getSubject();
				convertResource(m, res, ret);
				ret.add(res, m.createProperty(NS.RDF.PROP_TYPE), m.createResource(type));
			}
		}
		return ret;
	}
}