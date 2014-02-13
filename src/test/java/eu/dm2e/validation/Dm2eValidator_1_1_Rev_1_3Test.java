package eu.dm2e.validation;

import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.hp.hpl.jena.datatypes.xsd.XSDDatatype;
import com.hp.hpl.jena.rdf.model.Literal;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.rdf.model.Resource;

import eu.dm2e.NS;


public class Dm2eValidator_1_1_Rev_1_3Test extends ValidationTest {

	private static final Logger log = LoggerFactory.getLogger(Dm2eValidator_1_1_Rev_1_3Test.class);

	@Test
	public void test2014_02_13() throws Exception {
		{
			log.info("dm2e:displayLevel cannot be untyped");
			final Model m = ModelFactory.createDefaultModel();
			final Resource testRes = res(m, "http://foo");

			m.add(testRes, prop(m, NS.DM2E_UNVERSIONED.PROP_DISPLAY_LEVEL), "FaLsorrr");

			Dm2eValidationReport report = new Dm2eValidationReport("0");
			v1_1_rev1_3.validate_ore_Aggregation(m, testRes, report);
			ValidationProblemCategory expected = ValidationProblemCategory.ILLEGALLY_UNTYPED_LITERAL;
			containsCategory(report, expected);
		}
		{
			log.info("dm2e:displayLevel must be an xsd:boolean");
			final Model m = ModelFactory.createDefaultModel();
			final Resource testRes = res(m, "http://foo");

			m.addLiteral(testRes, prop(m, NS.DM2E_UNVERSIONED.PROP_DISPLAY_LEVEL), 42L);

			Dm2eValidationReport report = new Dm2eValidationReport("0");
			v1_1_rev1_3.validate_ore_Aggregation(m, testRes, report);
			ValidationProblemCategory expected = ValidationProblemCategory.INVALID_DATA_PROPERTY_RANGE;
			containsCategory(report, expected);
		}
		{
			log.info("dm2e:displayLevel must not be capitalized");
			final Model m = ModelFactory.createDefaultModel();
			final Resource testRes = res(m, "http://foo");

			Literal l = m.createTypedLiteral("True", XSDDatatype.XSDboolean);
			m.add(testRes, prop(m, NS.DM2E_UNVERSIONED.PROP_DISPLAY_LEVEL), l);

			Dm2eValidationReport report = new Dm2eValidationReport("0");
			v1_1_rev1_3.validate_ore_Aggregation(m, testRes, report);
			ValidationProblemCategory expected = ValidationProblemCategory.INVALID_LITERAL;
			containsCategory(report, expected);
		}
		{
			log.info("dm2e:displayLevel 'true'^^xsd:boolean is valid yay");
			final Model m = ModelFactory.createDefaultModel();
			final Resource testRes = res(m, "http://foo");

			Literal l = m.createTypedLiteral("true", XSDDatatype.XSDboolean);
			m.add(testRes, prop(m, NS.DM2E_UNVERSIONED.PROP_DISPLAY_LEVEL), l);

			Dm2eValidationReport report = new Dm2eValidationReport("0");
			v1_1_rev1_3.validate_ore_Aggregation(m, testRes, report);
			ValidationProblemCategory expected = ValidationProblemCategory.INVALID_LITERAL;
			doesNotContainCategory(report, expected);
		}
		{
			log.info("dm2e:displayLevel=true constraint fail");
			final Model m = ModelFactory.createDefaultModel();
			final Resource testRes = res(m, "http://foo");

			m.addLiteral(testRes, prop(m, NS.DM2E_UNVERSIONED.PROP_DISPLAY_LEVEL), true);

			Dm2eValidationReport report = new Dm2eValidationReport("0");
			v1_1_rev1_3.validate_ore_Aggregation(m, testRes, report);
			ValidationProblemCategory expected = ValidationProblemCategory.MISSING_CONDITIONALLY_REQUIRED_ONE_OF;
			containsCategory(report, expected);
		}
		{
			log.info("dm2e:displayLevel=true constraint pass (edm:isShownBy)");
			final Model m = ModelFactory.createDefaultModel();
			final Resource testRes = res(m, "http://foo");

			m.addLiteral(testRes, prop(m, NS.DM2E_UNVERSIONED.PROP_DISPLAY_LEVEL), true);
			m.add(testRes, prop(m, NS.EDM.PROP_IS_SHOWN_BY), res(m, "http://bar"));

			final Dm2eValidationReport report = new Dm2eValidationReport("0");
			v1_1_rev1_3.validate_ore_Aggregation(m, testRes, report);
			final ValidationProblemCategory expected = ValidationProblemCategory.MISSING_CONDITIONALLY_REQUIRED_ONE_OF;
			doesNotContainCategory(report, expected);
		}
		{
			log.info("dm2e:displayLevel=true constraint pass (edm:object)");
			final Model m = ModelFactory.createDefaultModel();
			final Resource testRes = res(m, "http://foo");

			m.addLiteral(testRes, prop(m, NS.DM2E_UNVERSIONED.PROP_DISPLAY_LEVEL), true);
			m.add(testRes, prop(m, NS.EDM.PROP_OBJECT), res(m, "http://bar"));

			final Dm2eValidationReport report = new Dm2eValidationReport("0");
			v1_1_rev1_3.validate_ore_Aggregation(m, testRes, report);
			final ValidationProblemCategory expected = ValidationProblemCategory.MISSING_CONDITIONALLY_REQUIRED_ONE_OF;
			doesNotContainCategory(report, expected);
		}
		{
			log.info("Using versioned DM2E namespace yields error");
			final Model m = ModelFactory.createDefaultModel();
			final Resource testRes = res(m, "http://foo");

			m.addLiteral(testRes, prop(m, NS.DM2E.PROP_DISPLAY_LEVEL), true);
			m.add(testRes, prop(m, NS.EDM.PROP_OBJECT), res(m, "http://bar"));

			final Dm2eValidationReport report = new Dm2eValidationReport("0");
			v1_1_rev1_3.validate_ore_Aggregation(m, testRes, report);
			final ValidationProblemCategory expected = ValidationProblemCategory.FORBIDDEN_PROPERTY;
			containsCategory(report, expected);
		}
	}

}
