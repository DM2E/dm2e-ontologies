package dm2e2edm;

import static org.fest.assertions.Assertions.*;

import java.io.IOException;
import java.io.StringWriter;
import java.net.MalformedURLException;
import java.net.URISyntaxException;
import java.nio.file.Path;
import java.nio.file.Paths;

import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.rdf.model.Resource;

import eu.dm2e.NS;


public class Dm2e2EdmTest {
	
	private static final Logger log = LoggerFactory.getLogger(Dm2e2EdmTest.class);
	
	@Test
	public void testStatic() throws Exception {
//		new Dm2e2Edm();
		final Model m = Dm2e2Edm.dm2eModel;
		log.debug("EDM props: {}", Dm2e2Edm.edmProperties);
		assertThat(Dm2e2Edm.edmProperties).contains(Dm2e2Edm.edmModel.createResource(NS.EDM.PROP_IS_NEXT_IN_SEQUENCE));
		log.debug(NS.CRM.PROP_P80F_END_IS_QUALIFIED_BY);
		log.debug("{}", Dm2e2Edm.dm2eSuperProperties);
		log.debug("{}", Dm2e2Edm.dm2eSuperProperties.get(m.createProperty(NS.CRM.PROP_P80F_END_IS_QUALIFIED_BY)));
		log.debug("{}", Dm2e2Edm.dm2eSuperProperties.get(m.createProperty(NS.CRM.PROP_P79F_BEGINNING_IS_QUALIFIED_BY)));
		log.debug("{}", Dm2e2Edm.dm2eSuperClasses.get(m.createResource(NS.FOAF.CLASS_PERSON)));
		log.debug("{}", Dm2e2Edm.dm2eSuperProperties.get(m.createResource(NS.DC.PROP_DATE)));
//		log.debug("{}", Dm2e2Edm.SparqlQueries.SELECT_GET_LITERAL.getQuery());
//		assertThat(Dm2e2Edm.edmProperties).contains(Dm2e2Edm.edmModel.createResource(NS.CRM.PROP_P80F_END_IS_QUALIFIED_BY));
//		assertThat(Dm2e2Edm.edmProperties).contains(Dm2e2Edm.edmModel.createResource(NS.CRM.PROP_P79F_BEGINNING_IS_QUALIFIED_BY));
	}
	
//	@Test
//	public void testConvert() throws Exception {
//		Model test = ModelFactory.createDefaultModel();
//		Model ret = ModelFactory.createDefaultModel();
//		test.read(Dm2e2Edm.class.getResourceAsStream("/dingler_example-new.ttl"), null, "TURTLE");
//		Dm2e2Edm dm2e2edm = new Dm2e2Edm(test, ret);
//		dm2e2edm.convertDm2eModelToEdmModel();
//		StringWriter sw = new StringWriter();
//		ret.write(sw, "TURTLE");
//		log.debug("{}", sw.toString());
//	}
//	
//	@Test
//	public void testSuperClasses()
//			throws Exception {
//		Model m = ModelFactory.createDefaultModel();
//		Model ret = ModelFactory.createDefaultModel();
//		m.add(m.createResource("foo"), m.createProperty(NS.RDF.PROP_TYPE), m.createResource(NS.FOAF.CLASS_PERSON));
//		Dm2e2Edm dm2e2edm = new Dm2e2Edm(m, ret);
//		dm2e2edm.convertDm2eModelToEdmModel();
//		StringWriter sw = new StringWriter();
//		ret.write(sw, "TURTLE");
//		log.debug("{}", sw.toString());
//	}
//
//	@Test
//	public void testRemote() throws Exception {
//		FileInputStream is = new FileInputStream("test.nquads");
//		FileOutputStream os = new FileOutputStream("test.nquads.foo");
//		Dm2e2Edm convert = new Dm2e2Edm("http://localhost:9997/dm2e-direct/sparql", is, os);
//		convert.convertDumptoEdm();
//	}
	
	@Test
	public void testHasMetInAggregation1()
			throws Exception {
		Model inputModel = ModelFactory.createDefaultModel();
		Model outputModel = ModelFactory.createDefaultModel();
		Resource agg = inputModel.createResource("http://agg1");
		agg.addProperty(inputModel.createProperty(NS.RDF.PROP_TYPE), inputModel.createResource(NS.ORE.CLASS_AGGREGATION));
		// allowed
		agg.addLiteral(inputModel.createProperty(NS.EDM.PROP_DATA_PROVIDER), "DM2E");
		// forbidden
		agg.addLiteral(inputModel.createProperty(NS.DCTERMS.PROP_MODIFIED), "2010");
		
		Dm2e2Edm dm2e2edm = new Dm2e2Edm(inputModel, outputModel);
		dm2e2edm.run();
		StringWriter sw = new StringWriter();
		outputModel.write(sw);
		log.debug(sw.toString());
		assertThat(outputModel.contains(agg, outputModel.createProperty(NS.DC.PROP_DATE))).isFalse();
	}

	@Test
	public void testHasMetInAggregation2() throws URISyntaxException, MalformedURLException, IOException {
		Path inFile = Paths.get(Dm2e2Edm.class.getResource("/onbcodices2BZ9671240X.xml").toURI());
		Path outFile = Paths.get(inFile.toString() + ".out.xml");
		Dm2e2Edm dm2e2Edm = new Dm2e2Edm(inFile, "RDF/XML", outFile, "RDF/XML");
		dm2e2Edm.run();

		log.debug("{}", outFile);
		Model m = ModelFactory.createDefaultModel();
		m.read(outFile.toFile().toURL().openStream(), null, "RDF/XML");
		StringWriter sw = new StringWriter();
		m.write(sw, "TURTLE");
		log.debug(sw.toString());
	}
	
	@Test
	public void testOneYearTimespan() throws Exception {
		Path inFile = Paths.get(Dm2e2Edm.class.getResource("/mpiwgraraMPIWG_D59WXSP9.ttl").toURI());
		Path outFile = Paths.get(inFile.toString() + ".out.xml");
		Dm2e2Edm dm2e2Edm = new Dm2e2Edm(inFile, "TURTLE", outFile, "RDF/XML");
		dm2e2Edm.run();

		log.debug("{}", outFile);
		Model m = ModelFactory.createDefaultModel();
		m.read(outFile.toFile().toURL().openStream(), null, "RDF/XML");
		StringWriter sw = new StringWriter();
		m.write(sw, "TURTLE");
		log.debug(sw.toString());
		
//		final Resource cho = m.createResource("http://data.dm2e.eu/data/item/mpiwg/rara/MPIWG_D59WXSP");
//		assertThat(cho.hasProperty(m.createProperty(NS.DCTERMS.PROP_ISSUED))).isTrue();
//		assertThat(cho.hasProperty(m.createProperty(NS.DC.PROP_SOURCE), cho)).isTrue();
//		assertThat(cho.hasProperty(m.createProperty(NS.DCTERMS.PROP_ISSUED), m.createLiteral("1751"))).isTrue();
	}
}
