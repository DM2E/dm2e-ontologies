package eu.dm2e.validation;

import org.fest.assertions.Assertions;
import org.junit.Test;

import com.hp.hpl.jena.rdf.model.Model;


public class Dm2eValidationReportTest extends ValidationTest {
	
	@Test
	public void testcontainsErrors() throws Exception {
		Dm2eValidationReport report = new Dm2eValidationReport("0");
		Assertions.assertThat(report.containsErrors()).isFalse();;
		Model m = newModel();
		report.add(ValidationLevel.ERROR, ValidationProblemCategory.MISC, res(m,"http://foo"), "just testing");
		Assertions.assertThat(report.containsErrors()).isTrue();;
	}

}
