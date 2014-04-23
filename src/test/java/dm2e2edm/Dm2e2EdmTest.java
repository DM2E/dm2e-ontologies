package dm2e2edm;

import static org.fest.assertions.Assertions.*;

import java.io.StringWriter;

import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;

import eu.dm2e.NS;


public class Dm2e2EdmTest {
	
	private static final Logger log = LoggerFactory.getLogger(Dm2e2EdmTest.class);
	
	@Test
	public void testStatic() throws Exception {
//		new Dm2e2Edm();
		log.debug("EDM props: {}", Dm2e2Edm.edmProperties);
		assertThat(Dm2e2Edm.edmProperties).contains(Dm2e2Edm.edmModel.createResource(NS.EDM.PROP_IS_NEXT_IN_SEQUENCE));
		log.debug(NS.CRM.PROP_P80F_END_IS_QUALIFIED_BY);
		log.debug("{}", Dm2e2Edm.dm2eSuperProperties);
		log.debug("{}", Dm2e2Edm.dm2eSuperProperties.get(Dm2e2Edm.dm2eModel.createProperty(NS.CRM.PROP_P80F_END_IS_QUALIFIED_BY)));
//		assertThat(Dm2e2Edm.edmProperties).contains(Dm2e2Edm.edmModel.createResource(NS.CRM.PROP_P80F_END_IS_QUALIFIED_BY));
//		assertThat(Dm2e2Edm.edmProperties).contains(Dm2e2Edm.edmModel.createResource(NS.CRM.PROP_P79F_BEGINNING_IS_QUALIFIED_BY));
	}
	
	@Test
	public void testConvert() throws Exception {
		Model test = ModelFactory.createDefaultModel();
		test.read(Dm2e2Edm.class.getResourceAsStream("/dingler_example.ttl"), null, "TURTLE");
		Model ret = Dm2e2Edm.convertToEdm(test);
		StringWriter sw = new StringWriter();
		ret.write(sw, "TURTLE");
		log.debug("{}", sw.toString());
	}

}
