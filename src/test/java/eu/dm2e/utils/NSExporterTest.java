package eu.dm2e.utils;

import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import eu.dm2e.NS;
import eu.dm2e.NS.OMNOM;

public class NSExporterTest {
	
	private static final Logger log = LoggerFactory.getLogger(NSExporterTest.class);
	
	@Test
	public void testExportToOwl() throws IllegalArgumentException, IllegalAccessException {
		
		Class<OMNOM> cls = NS.OMNOM.class;
		String base = NS.OMNOM.BASE;
		String x = NSExporter.exportStaticClassToOWL(base, cls);
		log.debug(x);
	}

}
