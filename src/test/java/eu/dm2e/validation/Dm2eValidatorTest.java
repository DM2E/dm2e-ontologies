package eu.dm2e.validation;

import java.io.IOException;
import java.io.InputStream;

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
		String agg = "http://data.dm2e.eu/data/aggregation/uber/dingler/article/pj001/ar001001";
		log.debug("Size: " + m.size());
		Dm2eValidationReport report = Dm2eValidator.validateWithDm2e(m, agg);
		log.debug("FOO");
		log.debug(report.toString());
	}
	
	@Test
	public void testCompleteModel() throws IOException {
		InputStream inputStream = getClass().getResource("/dingler_example.ttl").openStream();
		Model m = ModelFactory.createDefaultModel();
		m.read(inputStream, "", "TURTLE");
		Dm2eValidationReport report = Dm2eValidator.validateWithDm2e(m);
		log.debug(report.toString());
		
	}

	@Test
	public void testMain() throws Exception {
		Dm2eValidator.main(new String[] {"--format", "TURTLE", "--stdout", "src/test/resources/dingler_example.ttl" });
//		Dm2eValidator.main(new String[] { "src/test/resources/dingler_example.ttl" });
	}

}
