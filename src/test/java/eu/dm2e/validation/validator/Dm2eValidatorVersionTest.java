package eu.dm2e.validation.validator;

import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


public class Dm2eValidatorVersionTest {
	
	private static final Logger log = LoggerFactory.getLogger(Dm2eValidatorVersionTest.class);
	@Test
	public void testTerseValueString()
			throws Exception {
		log.debug(Dm2eValidatorVersion.valuesAsTerseString());
	}

}
