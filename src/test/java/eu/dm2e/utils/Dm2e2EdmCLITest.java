package eu.dm2e.utils;

import org.junit.Test;


public class Dm2e2EdmCLITest {
	
	@Test
	public void test() throws Exception {
		
//		{
//			String[] args = "--file src/test/resources/dingler_example-new.ttl --inFormat TURTLE".split(" ");
//			Dm2e2EdmCLI.main(args);
//		}
//		{
//			String[] args = "--streaming --endpoint http://localhost:9997/dm2e-direct/sparql --file test.nquads".split(" ");
//			Dm2e2EdmCLI.main(args);
//		}
		{
//			String[] args = "--input_dir src/test/resources/dingler --input_format RDF/XML".split(" ");
			String[] args = "--input_dir test --input_format RDF/XML".split(" ");
			Dm2e2EdmCLI.main(args);
		}
		
	}

}
