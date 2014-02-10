package eu.dm2e.validation;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;

import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;


public class Dm2eValidatorTest {
	
	Logger log = LoggerFactory.getLogger(getClass().getName());
	
	@Test
	public void testValidationSingleAgg() throws IOException {
		InputStream inputStream = getClass().getResource("/dingler_example.ttl").openStream();
		Model m = ModelFactory.createDefaultModel();
		m.read(inputStream, "", "TURTLE");
		String cho = "http://data.dm2e.eu/data/item/uber/dingler/article/pj001/ar001001";
		String agg = "http://data.dm2e.eu/data/aggregation/uber/dingler/article/pj001/ar001001";
		log.debug("Size: " + m.size());
		Dm2eValidator dm2eValidator = new Dm2eValidator();
		Dm2eValidationReport report = dm2eValidator.validateWithDm2e(m, agg);
		log.debug(report.toString());
	}
	
	@Test
	public void testCompleteModel() throws IOException {
		InputStream inputStream = getClass().getResource("/dingler_example.ttl").openStream();
		Model m = ModelFactory.createDefaultModel();
		m.read(inputStream, "", "TURTLE");
		Dm2eValidator dm2eValidator = new Dm2eValidator();
		Dm2eValidationReport report = dm2eValidator.validateWithDm2e(m);
		log.debug(report.toString());
		
	}

	@Test
	public void testMain() throws Exception {
		Dm2eValidator.main(new String[] {"--format", "TURTLE", "--file", "src/test/resources/dingler_example.ttl"});
	}

}
