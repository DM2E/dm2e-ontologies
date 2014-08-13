package eu.dm2e.validation.validator;

import static org.fest.assertions.Assertions.*;

import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.rdf.model.Resource;

import eu.dm2e.NS;
import eu.dm2e.validation.Dm2eValidationReport;
import eu.dm2e.validation.Dm2eValidator;
import eu.dm2e.validation.ValidationLevel;
import eu.dm2e.validation.ValidationProblemCategory;
import eu.dm2e.validation.ValidationTest;


public class Dm2eValidator_1_2_RC2Test extends ValidationTest{
	
	private static final Logger log = LoggerFactory.getLogger(Dm2eValidator_1_2_RC2Test.class);

	@Test
	public void testCRM() throws Exception {
		Dm2eValidator val = Dm2eValidatorVersion.V_1_2_RC2.getValidator();
		log.info("OK FATAL: Old CRM Namespace not allowed");
		Model m = ModelFactory.createDefaultModel();
		final Resource res = res(m, "http://foo");
		m.add(res, prop(m, NS.CRM.PROP_P79F_BEGINNING_IS_QUALIFIED_BY), m.createLiteral("fuzzy"));
		Dm2eValidationReport report = val.validateWithDm2e(m);
		log.debug(report.toString());
		containsCategory(report, ValidationProblemCategory.FORBIDDEN_PROPERTY);
		assertThat(report.getHighestLevel()).isEqualTo(ValidationLevel.FATAL);
	}

	@Test
	public void testWhitespace() throws Exception {
		Dm2eValidator val = Dm2eValidatorVersion.V_1_2_RC2.getValidator();
		Model m = ModelFactory.createDefaultModel();
		log.info("OK Pass: Mariana Damova's namespace is allowed");
		final Resource res = res(m, "http://foo");
		m.add(res, prop(m, NS.DAMOVA.BASE + "propFoo"), m.createLiteral("fuzzy"));
		Dm2eValidationReport report = val.validateWithDm2e(m);
		log.debug(report.toString());
		assertThat(report.getHighestLevel()).isEqualTo(ValidationLevel.WARNING);
	}

}
