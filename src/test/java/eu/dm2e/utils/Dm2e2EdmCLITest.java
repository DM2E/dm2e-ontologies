package eu.dm2e.utils;

import org.junit.Test;


public class Dm2e2EdmCLITest {
	
	@Test
	public void test() throws Exception {
		
		String[] args = "--file src/test/resources/dingler_example-new.ttl --inFormat TURTLE".split(" ");
		Dm2e2EdmCLI.main(args);
		
	}

}
