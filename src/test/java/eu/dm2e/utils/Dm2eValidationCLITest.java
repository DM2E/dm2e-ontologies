package eu.dm2e.utils;

import org.junit.Test;


public class Dm2eValidationCLITest {

	@Test
	public void testMain() throws Exception {
		"foo bar".split(" ");
//		Dm2eValidationCLI.main(new String[] { "--version", "1.1_Rev1.2", "src/main/resources/dingler_example.ttl" });
//		Dm2eValidationCLI.main(new String[] { "--version", "1.1_Rev1.2", "src/test/resources/dingler_example.ttl" });
//		final String optString = "--stdout --format TURTLE --version 1.1_Rev1.2 src/test/resources/dingler_example.ttl";
		final String optString = "--stdout --terse --format TURTLE --version 1.1_Rev1.3 src/test/resources/dingler_example.ttl";
//		final String optString = "--format TURTLE --version 1.1_Rev1.3 src/test/resources/dingler_example.ttl";
		Dm2eValidationCLI.main(optString.split(" "));
	}

}
