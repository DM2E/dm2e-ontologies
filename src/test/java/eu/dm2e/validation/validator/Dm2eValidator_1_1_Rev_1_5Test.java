package eu.dm2e.validation.validator;

import static org.fest.assertions.Assertions.*;

import java.util.HashSet;
import java.util.Set;

import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.hp.hpl.jena.datatypes.xsd.XSDDatatype;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.rdf.model.Resource;

import eu.dm2e.NS;
import eu.dm2e.validation.Dm2eValidationReport;
import eu.dm2e.validation.Dm2eValidator;
import eu.dm2e.validation.ValidationProblemCategory;
import eu.dm2e.validation.ValidationTest;


public class Dm2eValidator_1_1_Rev_1_5Test extends ValidationTest {
	
	@SuppressWarnings("unused") private static final Logger log = LoggerFactory.getLogger(Dm2eValidator_1_1_Rev_1_5Test.class);

	Dm2eValidator rev_1_5 = new Dm2eValidator_1_1_Rev_1_5();
	final String ex = "http://example.com/";
	
	@Test
	public void testWebResourceImage() throws Exception {
		Model m = ModelFactory.createDefaultModel();
		Set<String> allowedMime = rev_1_5.build_image_mimeType_List();

		for (String mimeType : allowedMime) {
			Dm2eValidationReport report = buildAggWrMime(m, mimeType);
			assertThat(report.exportToString(true)).doesNotContain("BAD_MIMETYPE");
		}

		Set<String> forbidden = new HashSet<>();
		forbidden.add("image/svg+xml");
		for (String mimeType : forbidden) {
			Dm2eValidationReport report = buildAggWrMime(m, mimeType);
			assertThat(report.exportToString(true)).contains("BAD_MIMETYPE");
		}
	}
	
	@Test
	public void testNumPagesUnsignedOrUntyped()
			throws Exception {
		{
			log.info("OK:  bibo:numPages '3'^^xsd:unsignedInt");
			Model m = ModelFactory.createDefaultModel();
			final Resource res = res(m, "http://foo");
			m.add(res, prop(m, NS.BIBO.PROP_NUM_PAGES), m.createTypedLiteral("3", XSDDatatype.XSDunsignedInt));
			Dm2eValidationReport report = new Dm2eValidationReport("");
			rev_1_5.validate_edm_ProvidedCHO(m, res, report);
			doesNotContainCategory(report, ValidationProblemCategory.INVALID_LITERAL);
		}
		{
			log.info("FAIL:  bibo:numPages '3'^^xsd:boolean");
			Model m = ModelFactory.createDefaultModel();
			final Resource res = res(m, "http://foo");
			m.add(res, prop(m, NS.BIBO.PROP_NUM_PAGES), m.createTypedLiteral("3", XSDDatatype.XSDboolean));
			Dm2eValidationReport report = new Dm2eValidationReport("");
			rev_1_5.validate_edm_ProvidedCHO(m, res, report);
			containsCategory(report, ValidationProblemCategory.INVALID_DATA_PROPERTY_RANGE);
		}
		{
			log.info("OK:  bibo:numPages '3'");
			Model m = ModelFactory.createDefaultModel();
			final Resource res = res(m, "http://foo");
			m.add(res, prop(m, NS.BIBO.PROP_NUM_PAGES), "3");
			Dm2eValidationReport report = new Dm2eValidationReport("");
			rev_1_5.validate_edm_ProvidedCHO(m, res, report);
			doesNotContainCategory(report, ValidationProblemCategory.INVALID_DATA_PROPERTY_RANGE);
		}

	}

	private Dm2eValidationReport buildAggWrMime(Model m, String mimeType) {
		m.removeAll();
		Resource agg = res(m, ex + "agg1");
		Resource wr = res(m, ex + "wr1");
		m.add(agg, isa(m), res(m, NS.ORE.CLASS_AGGREGATION));
		m.add(wr, isa(m), res(m, NS.EDM.CLASS_WEBRESOURCE));
		m.add(agg, prop(m, NS.EDM.PROP_OBJECT), wr);
		m.add(wr, prop(m, NS.DC.PROP_FORMAT), mimeType);
		Dm2eValidationReport report = new Dm2eValidationReport(rev_1_5.getVersion());
		rev_1_5.validate_ore_Aggregation(m, agg, report);
		return report;
	}

}
