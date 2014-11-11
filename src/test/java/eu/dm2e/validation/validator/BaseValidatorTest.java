package eu.dm2e.validation.validator;

import static org.fest.assertions.Assertions.*;

import java.text.Normalizer;
import java.text.Normalizer.Form;
import java.util.Set;

import org.junit.Ignore;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.hp.hpl.jena.datatypes.xsd.XSDDatatype;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.rdf.model.Resource;

import eu.dm2e.NS;
import eu.dm2e.validation.Dm2eValidationReport;
import eu.dm2e.validation.ValidationLevel;
import eu.dm2e.validation.ValidationProblemCategory;
import eu.dm2e.validation.ValidationTest;


public class BaseValidatorTest extends ValidationTest {
	
	private static final Logger log = LoggerFactory.getLogger(BaseValidatorTest.class);

	//
	// Tests
	//
	
	@Test
	public void testIssue85() throws Exception {
		Model m = ModelFactory.createDefaultModel();
		final Resource testAgg = res(m, "http://agg1");
		final Resource testCho = res(m, "http://cho1");
		testAgg.addProperty(prop(m, NS.EDM.PROP_AGGREGATED_CHO), testCho);
		Dm2eValidationReport report = v1_1_rev1_2.validateWithDm2e(m);
		ValidationProblemCategory expected = ValidationProblemCategory.UNTYPED_RESOURCE;
		log.debug(report.toString());
		containsCategory(report, expected);
	}

	@Test
    @Ignore
	public void testPropertyWhiteList() {
		Set<String> wl = ((BaseValidator) v1_1_rev1_3).getPropertyWhitelist();
		assertThat(wl.size()).isEqualTo(148);
		assertThat(wl).contains(NS.EDM.PROP_IS_NEXT_IN_SEQUENCE);
	}
	
	@Test
	public void testEdmTimeSpan() throws Exception {
			{
				Model m = ModelFactory.createDefaultModel();
				m.read(getClass().getResourceAsStream("/edm_timespan.ttl"), "", "TURTLE");
				Dm2eValidationReport report = new Dm2eValidationReport(v1_1_rev1_2.getVersion());
				v1_1_rev1_2.validate_edm_TimeSpan(m, m.createResource("foo"), report);
				log.debug(report.toString());
			}
			{
				log.info("Okay non-typed dcterms:issued");
				Model m = ModelFactory.createDefaultModel();
				Resource tsRes = res(m, "http://ts1");
				m.add(tsRes, prop(m, NS.DCTERMS.PROP_ISSUED), m.createLiteral("1523-01-01T00:00:00"));
				Dm2eValidationReport report = new Dm2eValidationReport("");
				v1_1_rev1_2.validate_DateLike(m, tsRes, report);
				log.debug(report.exportToString(true));
				containsCategory(report, ValidationProblemCategory.UNTYPED_LITERAL);
				assertThat(report.getHighestLevel().ordinal()).isLessThan(ValidationLevel.FATAL.ordinal());
			}
			{
				log.info("Bad xsd:Datetime (Pattern bad)");
				Model m = ModelFactory.createDefaultModel();
				Resource tsRes = res(m, "http://ts1");
				m.add(tsRes, prop(m, NS.EDM.PROP_BEGIN), m.createTypedLiteral("523-01-01T00:00:00", XSDDatatype.XSDdateTime));
				Dm2eValidationReport report = new Dm2eValidationReport("");
				v1_1_rev1_2.validate_DateLike(m, tsRes, report);
				containsCategory(report, ValidationProblemCategory.INVALID_XSD_DATETIME);
				log.debug(report.exportToString(true));
			}
			{
				log.info("Good xsd:Datetime (Zero-padded)");
				Model m = ModelFactory.createDefaultModel();
				Resource tsRes = res(m, "http://ts1");
				m.add(tsRes, prop(m, NS.EDM.PROP_BEGIN), m.createTypedLiteral("0523-01-01T00:00:00", XSDDatatype.XSDdateTime));
				Dm2eValidationReport report = new Dm2eValidationReport("");
				v1_1_rev1_2.validate_DateLike(m, tsRes, report);
				doesNotContainCategory(report, ValidationProblemCategory.INVALID_XSD_DATETIME);
				log.debug(report.exportToString(true));
			}
			{
				log.info("Good xsd:Datetime (Zero-padded, trailing 'Z')");
				Model m = ModelFactory.createDefaultModel();
				Resource tsRes = res(m, "http://ts1");
				m.add(tsRes, prop(m, NS.EDM.PROP_BEGIN), m.createTypedLiteral("0523-01-01T00:00:00Z", XSDDatatype.XSDdateTime));
				Dm2eValidationReport report = new Dm2eValidationReport("");
				v1_1_rev1_2.validate_DateLike(m, tsRes, report);
				doesNotContainCategory(report, ValidationProblemCategory.INVALID_XSD_DATETIME);
				log.debug(report.exportToString(true));
			}
			{
				log.info("Bad xsd:Datetime (Logical error)");
				Model m = ModelFactory.createDefaultModel();
				Resource tsRes = res(m, "http://ts1");
				m.add(tsRes, prop(m, NS.EDM.PROP_BEGIN), m.createTypedLiteral("0523-21-01T00:00:00", XSDDatatype.XSDdateTime));
				Dm2eValidationReport report = new Dm2eValidationReport("");
				v1_1_rev1_2.validate_DateLike(m, tsRes, report);
				containsCategory(report, ValidationProblemCategory.INVALID_XSD_DATETIME);
				log.debug(report.exportToString(true));
			}
	}


	@Test
	public void testEdmTimeSpan2() throws Exception {
		String fileName = getClass().getResource("/edm_timespan.ttl").getFile();
		Dm2eValidationReport report = v1_1_rev1_2.validateWithDm2e(fileName, "TURTLE");
		log.debug(report.toString());
	}
	
	@Test
	public void testRelativeUrlInFile() throws Exception {
//		{
//			String fileName = getClass().getResource("/relative_url.ttl").getFile();
//			Dm2eValidationReport report = v1_1_rev1_2.validateWithDm2e(fileName, "TURTLE");
//			containsCategory(report, ValidationProblemCategory.RELATIVE_URL);
//			assertThat(report.toString()).contains("FATAL");
//			log.debug(report.toString());
//		}
		{
			String fileName = getClass().getResource("/relative_url2.rdf").getFile();
			Dm2eValidationReport report = v1_1_rev1_2.validateWithDm2e(fileName, "RDF/XML");
			containsCategory(report, ValidationProblemCategory.RELATIVE_URL);
			assertThat(report.toString()).contains("FATAL");
			log.debug(report.toString());
		}
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
			doesNotContainCategory(report, expected);
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
		{
			log.info("Test FATAL (missign aggregatedCHO)");
			Model m = ModelFactory.createDefaultModel();
			final Resource testRes = res(m, "http://foo");
			Dm2eValidationReport report = new Dm2eValidationReport("0");
			v1_1_rev1_2.validate_ore_Aggregation(m, testRes, report);
			ValidationProblemCategory expected = ValidationProblemCategory.MISSING_REQUIRED_PROPERTY;
			assertThat(report.exportToString(true)).contains("FATAL");
			containsCategory(report, expected);
		}
		{
			log.info("Test FATAL (WebResource w/o dc:format)");
			Model m = ModelFactory.createDefaultModel();
			final Resource testRes = res(m, "http://foo");
			Dm2eValidationReport report = new Dm2eValidationReport("0");
			v1_1_rev1_2.validate_Annotatable_edm_WebResource(m, testRes, report);
			ValidationProblemCategory expected = ValidationProblemCategory.MISSING_CONDITIONALLY_REQUIRED_PROPERTY;
			assertThat(report.exportToString(true)).contains("FATAL");
			containsCategory(report, expected);
		}
		{
			log.info("Pass dc:type Test (Valid dc:type)");
			Model m = ModelFactory.createDefaultModel();
			final Resource testRes = res(m, "http://foo");
			final Resource testType = res(m, NS.BIBO.CLASS_BOOK);
			testRes.addProperty(prop(m, NS.DC.PROP_TYPE), testType);

			Dm2eValidationReport report = new Dm2eValidationReport("0");
			v1_1_rev1_2.validate_edm_ProvidedCHO(m, testRes, report);
			ValidationProblemCategory expected = ValidationProblemCategory.INVALID_DC_TYPE;
			doesNotContainCategory(report, expected);
		}
	}
	
	@Test
	public void testInvalidURI() {
		{
			log.info("Newline and Tab (plain)");
			Model m = ModelFactory.createDefaultModel();
			final Resource testRes = res(m, "http://foo.com/bla\n\tquux");
			testRes.addProperty(prop(m, NS.RDF.PROP_TYPE), "fnobeck");
			Dm2eValidationReport report = v1_1_rev1_2.validateWithDm2e(m);
			ValidationProblemCategory expected = ValidationProblemCategory.ILLEGAL_URI_CHARACTER;
			containsCategory(report, expected);
		}
		{
			log.info("Newline and Tab (url-encoded)");
			Model m = ModelFactory.createDefaultModel();
			final Resource testRes = res(m, "http://foo.com/bla%0A%09quux");
			testRes.addProperty(prop(m, NS.RDF.PROP_TYPE), "fnobeck");
			Dm2eValidationReport report = v1_1_rev1_2.validateWithDm2e(m);
			ValidationProblemCategory expected = ValidationProblemCategory.UNWISE_URI_CHARACTER;
			containsCategory(report, expected);
		}
		{
			log.info("URL-encoded Slash");
			Model m = ModelFactory.createDefaultModel();
			final Resource testRes = res(m, "http://foo.com/bla%2Fquux");
			testRes.addProperty(prop(m, NS.RDF.PROP_TYPE), "fnobeck");
			Dm2eValidationReport report = v1_1_rev1_2.validateWithDm2e(m);
			ValidationProblemCategory expected = ValidationProblemCategory.UNWISE_URI_CHARACTER;
			log.info(report.exportToString(false));
			containsCategory(report, expected);
		}
		{
			Model m = ModelFactory.createDefaultModel();
			final Resource testUri = res(m, "http://agg1/a[b]");
			testUri.addProperty(prop(m, NS.RDF.PROP_TYPE), res(m, NS.ORE.CLASS_AGGREGATION));
			Dm2eValidationReport report = v1_1_rev1_2.validateWithDm2e(m);
			ValidationProblemCategory expected = ValidationProblemCategory.ILLEGAL_URI_CHARACTER;
			log.debug(report.toString());
			containsCategory(report, expected);
		}
	}
	
	@Test
	public void testNFC() throws Exception {
		String sample = "ĥ̖̗̲â̲ᷜ̃ç̲︣̌̕k̲̈͆";
		log.info("Raw: {}", sample);
		log.info("Is NFC: {}", Normalizer.isNormalized(sample, Form.NFC));
		log.info("NFD: {}", Normalizer.normalize(sample, Form.NFD));
		log.info("NFC: {}", Normalizer.normalize(sample, Form.NFC));
		{
			log.info("Non-NFC");
			Model m = ModelFactory.createDefaultModel();
			final Resource testRes = res(m, "http://foo.com/bla");
			testRes.addProperty(prop(m, NS.DC.PROP_DESCRIPTION), sample);
			Dm2eValidationReport report = v1_1_rev1_2.validateWithDm2e(m);
			ValidationProblemCategory expected = ValidationProblemCategory.LITERAL_NOT_IN_NFC;
			log.info(report.exportToString(false));
			containsCategory(report, expected);
		}
		{
			log.info("NFC");
			Model m = ModelFactory.createDefaultModel();
			final Resource testRes = res(m, "http://foo.com/bla");
			testRes.addProperty(prop(m, NS.DC.PROP_DESCRIPTION), Normalizer.normalize(sample, Form.NFC));
			Dm2eValidationReport report = v1_1_rev1_2.validateWithDm2e(m);
			ValidationProblemCategory expected = ValidationProblemCategory.LITERAL_NOT_IN_NFC;
			log.info(report.exportToString(false));
			doesNotContainCategory(report, expected);
		}
	}


	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
};