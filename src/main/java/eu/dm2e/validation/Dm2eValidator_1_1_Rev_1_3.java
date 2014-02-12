package eu.dm2e.validation;

import java.util.HashSet;
import java.util.Set;

import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.Property;
import com.hp.hpl.jena.rdf.model.Resource;
import com.hp.hpl.jena.rdf.model.Statement;

import eu.dm2e.NS;

/**
 * Static methods for validating RDF data against the DM2E Data Model
 * 
 * <p>
 * Based on v1.1_Rev1.2-DRAFT of the requirements
 * </p>
 * 
 * @author Konstantin Baierer
 */
public class Dm2eValidator_1_1_Rev_1_3 extends Dm2eValidator_1_1_Rev_1_2 {

	private static final String	modelVersion	= "1.1_Rev1.3";

	@Override public String getVersion() {
		return modelVersion;
	}
	
	@Override public Set<Property> build_ore_Aggregation_AnnotatableWebResource_Properties(Model m) {
		Set<Property> req = new HashSet<>();
		req.add(prop(m, NS.EDM.PROP_IS_SHOWN_BY));
		req.add(prop(m, NS.EDM.PROP_IS_SHOWN_AT));
		req.add(prop(m, NS.EDM.PROP_OBJECT));
		req.add(prop(m, NS.DM2E_UNVERSIONED.PROP_HAS_ANNOTABLE_VERSION_AT));
		return req;
	}

	@Override public Set<Property> build_ore_Aggregation_Mandatory_Properties(Model m) {
		Set<Property> req = new HashSet<>();
		req.add(prop(m, NS.DM2E_UNVERSIONED.PROP_DISPLAY_LEVEL));
		req.add(prop(m, NS.EDM.PROP_AGGREGATED_CHO));
		req.add(prop(m, NS.EDM.PROP_PROVIDER));
		req.add(prop(m, NS.EDM.PROP_DATA_PROVIDER));
		req.add(prop(m, NS.EDM.PROP_RIGHTS));
		return req;
	}

	@Override public Set<Property> build_ore_Aggregation_Recommended_Properties(Model m) {
		Set<Property> ret = new HashSet<>();
		ret.add(prop(m, NS.EDM.PROP_OBJECT));
		ret.add(prop(m, NS.DM2E_UNVERSIONED.PROP_HAS_ANNOTABLE_VERSION_AT));
		return ret;
	}
	
	@Override
	public Set<Property> build_edm_TimeSpan_Mandatory_Properties(Model m) {
		Set<Property> ret = super.build_edm_TimeSpan_Mandatory_Properties(m);
		ret.add(prop(m, NS.SKOS.PROP_PREF_LABEL));
		return ret;
	}

	@Override
	public void validate_ore_Aggregation(Model m, Resource agg, Object context, Dm2eValidationReport report) {
		
		// Basic validation is the same
		super.validate_ore_Aggregation(m, agg, context, report);

		
		// edm:isShownBy
		//
		// p.21: "mandatory (either edm:isShownBy or edm: isShownAt or if
		// dm2e:displayLe vel is true) not repeatable"
		Statement displayLevelStmt = agg.getProperty(prop(m, NS.DM2E_UNVERSIONED.PROP_DISPLAY_LEVEL));
		if (null != displayLevelStmt && displayLevelStmt.getObject().isLiteral()) {
			if ("true".equals(displayLevelStmt.getObject().asLiteral().getLexicalForm().toLowerCase())) {
				if (! agg.hasProperty(prop(m, NS.EDM.PROP_IS_SHOWN_BY))) {
					report.addError(agg, "Must set edm:shownBy because the dm2e:displayLevel is 'true'.");
				}
			}
		}
		
		
	}


}
