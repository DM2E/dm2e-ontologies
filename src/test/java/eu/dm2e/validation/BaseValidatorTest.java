package eu.dm2e.validation;

import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;


public class BaseValidatorTest {
	
	private static final Logger log = LoggerFactory.getLogger(BaseValidatorTest.class);
	
	private static Dm2eValidator v1_1_rev1_2 = new Dm2eValidator_1_1_Rev_1_2();
	private static Dm2eValidator v1_1_rev1_3 = new Dm2eValidator_1_1_Rev_1_3();

	@Test
	public void testEdmTimeSpan() throws Exception {
			Model m = ModelFactory.createDefaultModel();
			m.read(getClass().getResource("/edm_timespan.ttl").openStream(), "", "TURTLE");
			{
				Dm2eValidationReport report = new Dm2eValidationReport(v1_1_rev1_3.getVersion());
				v1_1_rev1_3.validate_edm_TimeSpan(m, m.createResource("foo"), null, report);
				log.debug(report.toString());
			}
			{
				Dm2eValidationReport report = new Dm2eValidationReport(v1_1_rev1_2.getVersion());
				v1_1_rev1_2.validate_edm_TimeSpan(m, m.createResource("foo"), null, report);
				log.debug(report.toString());
			}
	}
	@Test
	public void testEdmTimeSpan2() throws Exception {
		String fileName = getClass().getResource("/edm_timespan.ttl").getFile();
		Dm2eValidationReport report = v1_1_rev1_2.validateWithDm2e(fileName, "TURTLE");
		log.debug(report.toString());
	}
}
