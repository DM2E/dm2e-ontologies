package eu.dm2e.validation;

import static org.fest.assertions.Assertions.*;

import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.rdf.model.Property;
import com.hp.hpl.jena.rdf.model.Resource;

import eu.dm2e.NS;


public class BaseValidatorTest {
	
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

	private static final Logger log = LoggerFactory.getLogger(BaseValidatorTest.class);
	
	private void containsCategory(Dm2eValidationReport report, ValidationProblemCategory expected) {
		final String exportToString = report.exportToString(ValidationLevel.NOTICE, false, true);
		assertThat(exportToString).contains(expected.name());
	}
	private void containsCategoryNot(Dm2eValidationReport report, ValidationProblemCategory expected) {
		final String exportToString = report.exportToString(ValidationLevel.NOTICE, false, true);
		assertThat(exportToString).doesNotContain(expected.name());
	}

	//
	// Validators
	//

	private static Dm2eValidator v1_1_rev1_2 = new Dm2eValidator_1_1_Rev_1_2();
	private static Dm2eValidator v1_1_rev1_3 = new Dm2eValidator_1_1_Rev_1_3();

	//
	// Tests
	//
	
	
	@Test
	public void testEdmTimeSpan() throws Exception {
			Model m = ModelFactory.createDefaultModel();
			m.read(getClass().getResource("/edm_timespan.ttl").openStream(), "", "TURTLE");
			{
				Dm2eValidationReport report = new Dm2eValidationReport(v1_1_rev1_3.getVersion());
				v1_1_rev1_3.validate_edm_TimeSpan(m, m.createResource("foo"), report);
				log.debug(report.toString());
			}
			{
				Dm2eValidationReport report = new Dm2eValidationReport(v1_1_rev1_2.getVersion());
				v1_1_rev1_2.validate_edm_TimeSpan(m, m.createResource("foo"), report);
				log.debug(report.toString());
			}
	}


	@Test
	public void testEdmTimeSpan2() throws Exception {
		String fileName = getClass().getResource("/edm_timespan.ttl").getFile();
		Dm2eValidationReport report = v1_1_rev1_2.validateWithDm2e(fileName, "TURTLE");
		log.debug(report.toString());
	}
	
	@Test
	public void testByCategory() throws Exception {
		{
			log.info("Wrongly typed literal");
			Model m = ModelFactory.createDefaultModel();
			final Resource testRes = res(m, "http://foo");
			m.addLiteral(testRes, prop(m, NS.BIBO.PROP_NUMBER), 3L);
			Dm2eValidationReport report = new Dm2eValidationReport("0");
			v1_1_rev1_2.validate_edm_ProvidedCHO(m, testRes, report);
			ValidationProblemCategory expected = ValidationProblemCategory.INVALID_DATA_PROPERTY_RANGE;
			containsCategory(report, expected);
		}
		{
			log.info("Resource where literal is expected");
			Model m = ModelFactory.createDefaultModel();
			final Resource testRes = res(m, "http://foo");
			m.add(testRes, prop(m, NS.BIBO.PROP_NUMBER), res(m, "http://bar"));
			Dm2eValidationReport report = new Dm2eValidationReport("0");
			v1_1_rev1_2.validate_edm_ProvidedCHO(m, testRes, report);
			ValidationProblemCategory expected = ValidationProblemCategory.SHOULD_BE_LITERAL;
			containsCategory(report, expected);
		}
		{
			log.info("Bad MIME type");
			Model m = ModelFactory.createDefaultModel();
			final Resource testRes = res(m, "http://foo");
			m.add(testRes, prop(m, NS.DC.PROP_FORMAT), "bar/quux");
			Dm2eValidationReport report = new Dm2eValidationReport("0");
			v1_1_rev1_2.validate_Annotatable_edm_WebResource(m, testRes, report);
			ValidationProblemCategory expected = ValidationProblemCategory.BAD_MIMETYPE;
			containsCategory(report, expected);
		}
		{
			log.info("Repeat non-repeatable");
			Model m = ModelFactory.createDefaultModel();
			final Resource testRes = res(m, "http://foo");
			m.addLiteral(testRes, prop(m, NS.BIBO.PROP_NUMBER), 3);
			m.addLiteral(testRes, prop(m, NS.BIBO.PROP_NUMBER), 4);
			Dm2eValidationReport report = new Dm2eValidationReport("0");
			v1_1_rev1_2.validate_edm_ProvidedCHO(m, testRes, report);
			ValidationProblemCategory expected = ValidationProblemCategory.NON_REPEATABLE;
			containsCategory(report, expected);
		}
		{
			log.info("Neither dc:title nor dc:description");
			Model m = ModelFactory.createDefaultModel();
			final Resource testRes = res(m, "http://foo");
			Dm2eValidationReport report = new Dm2eValidationReport("0");
			v1_1_rev1_2.validate_edm_ProvidedCHO(m, testRes, report);
			ValidationProblemCategory expected = ValidationProblemCategory.MISSING_REQUIRED_ONE_OF;
			containsCategory(report, expected);
		}
		{
			log.info("Pass With dc:description");
			Model m = ModelFactory.createDefaultModel();
			final Resource testRes = res(m, "http://foo");
			m.add(testRes, prop(m, NS.DC.PROP_DESCRIPTION), "bar");
			Dm2eValidationReport report = new Dm2eValidationReport("0");
			v1_1_rev1_2.validate_edm_ProvidedCHO(m, testRes, report);
			ValidationProblemCategory expected = ValidationProblemCategory.MISSING_REQUIRED_ONE_OF;
			containsCategoryNot(report, expected);
		}
		{
			log.info("Bad dm2e:displayLevel");
			Model m = ModelFactory.createDefaultModel();
			final Resource testRes = res(m, "http://foo");
			m.add(testRes, prop(m, NS.DM2E.PROP_DISPLAY_LEVEL), "False");
			Dm2eValidationReport report = new Dm2eValidationReport("0");
			v1_1_rev1_2.validate_ore_Aggregation(m, testRes, report);
			ValidationProblemCategory expected = ValidationProblemCategory.INVALID_LITERAL;
			containsCategory(report, expected);
		}
	}


	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}