package eu.dm2e.validation;

import java.io.IOException;
import java.io.InputStream;

import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;


public class Dm2eValidator_1_1_Rev_1_2Test {
	
	Logger log = LoggerFactory.getLogger(getClass().getName());
	BaseValidator val = new Dm2eValidator_1_1_Rev_1_2();
	
	@Test
	public void testValidationSingleAgg() throws IOException {
		InputStream inputStream = getClass().getResource("/dingler_example.ttl").openStream();
		Model m = ModelFactory.createDefaultModel();
		m.read(inputStream, "", "TURTLE");
		String agg = "http://data.dm2e.eu/data/aggregation/uber/dingler/article/pj001/ar001001";
		log.debug("Size: " + m.size());
		Dm2eValidationReport report = val.validateWithDm2e(m);
		log.debug("FOO");
		log.debug(report.toString());
	}
	
	@Test
	public void testCompleteModel() throws IOException {
		InputStream inputStream = getClass().getResource("/dingler_example.ttl").openStream();
		Model m = ModelFactory.createDefaultModel();
		m.read(inputStream, "", "TURTLE");
		Dm2eValidationReport report = val.validateWithDm2e(m);
		log.debug(report.exportToString(ValidationLevel.NOTICE, true, true));
		
	}

}
