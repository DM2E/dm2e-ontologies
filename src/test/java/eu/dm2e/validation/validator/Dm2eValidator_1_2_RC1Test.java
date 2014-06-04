package eu.dm2e.validation.validator;

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


public class Dm2eValidator_1_2_RC1Test extends ValidationTest{
	
	private static final Logger log = LoggerFactory.getLogger(Dm2eValidator_1_2_RC1Test.class);

	@Test
	public void testCRM() throws Exception {
		Dm2eValidator val = Dm2eValidatorVersion.V_1_2_RC1.getValidator();
		log.info("OK WARNING: Old CRM Namespace not allowed");
		Model m = ModelFactory.createDefaultModel();
		final Resource res = res(m, "http://foo");
		m.add(res, prop(m, NS.CRM.PROP_P79F_BEGINNING_IS_QUALIFIED_BY), m.createLiteral("fuzzy"));
		Dm2eValidationReport report = val.validateWithDm2e(m);
		containsCategory(report, ValidationProblemCategory.FORBIDDEN_PROPERTY);
		log.debug(report.toString());
	}
}
