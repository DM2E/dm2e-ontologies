package dm2e2edm;

import static org.fest.assertions.Assertions.*;

import java.io.IOException;
import java.io.StringWriter;
import java.net.MalformedURLException;
import java.net.URISyntaxException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import org.joda.time.DateTime;
import org.junit.Ignore;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.hp.hpl.jena.rdf.model.Literal;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.rdf.model.Property;
import com.hp.hpl.jena.rdf.model.RDFNode;
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
		log.debug("{}", Dm2e2Edm.dcTypesModel.size());
		assertThat(Dm2e2Edm.dcTypesModel.contains(res(m, NS.DM2E_UNVERSIONED.CLASS_MANUSCRIPT), null, (RDFNode)null)).isTrue();
//		log.debug("{}", Dm2e2Edm.SparqlQueries.SELECT_GET_LITERAL.getQuery());
//		assertThat(Dm2e2Edm.edmProperties).contains(Dm2e2Edm.edmModel.createResource(NS.CRM.PROP_P80F_END_IS_QUALIFIED_BY));
//		assertThat(Dm2e2Edm.edmProperties).contains(Dm2e2Edm.edmModel.createResource(NS.CRM.PROP_P79F_BEGINNING_IS_QUALIFIED_BY));
	}
	
	@Test
	public void testConvert() throws Exception {
		Model test = ModelFactory.createDefaultModel();
		Model ret = ModelFactory.createDefaultModel();
		test.read(Dm2e2Edm.class.getResourceAsStream("/dingler_example-new.ttl"), null, "TURTLE");
		Dm2e2Edm dm2e2edm = new Dm2e2Edm(test, ret);
		dm2e2edm.run();
		StringWriter sw = new StringWriter();
		ret.write(sw, "TURTLE");
		log.debug("{}", sw.toString());
		assertThat(ret.contains(null, prop(ret, NS.EDM.PROP_HAS_VIEW))).isFalse();
	}

	@Test
	@Ignore("WONTFIX because dm2e:hasAnnotatableVersion is a subproperty of edm:hasView")
	public void testIssue105() throws Exception {
		Model test = ModelFactory.createDefaultModel();
		Model ret = ModelFactory.createDefaultModel();
		test.read(Dm2e2Edm.class.getResourceAsStream("/uberdinglerarticle_pj001_ar001001.xml"), null, "RDF/XML");
		Dm2e2Edm dm2e2edm = new Dm2e2Edm(test, ret);
		dm2e2edm.run();
		StringWriter sw = new StringWriter();
		ret.write(sw, "TURTLE");
		log.debug("{}", sw.toString());
		assertThat(ret.contains(null, prop(ret, NS.EDM.PROP_HAS_VIEW))).isFalse();
	}
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
		assertThat(outputModel.contains(agg, outputModel.createProperty(NS.RDF.PROP_TYPE))).isTrue();
		assertThat(outputModel.contains(agg, outputModel.createProperty(NS.DC.PROP_DATE))).isFalse();
	}

	@SuppressWarnings("deprecation")
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
	public void testUntypedDateTime() throws Exception {
		Path inFile = Paths.get(Dm2e2Edm.class.getResource("/sbb-kpe-DE-611-HS-1778887.ttl").toURI());
		Path outFile = Files.createTempFile("dm2e-ontologies", ".rdf.xml");
		Dm2e2Edm dm2e2Edm = new Dm2e2Edm(inFile, "TURTLE", outFile, "RDF/XML");
		dm2e2Edm.run();

		Model m = ModelFactory.createDefaultModel();
		m.read(outFile.toFile().toURI().toURL().openStream(), null, "RDF/XML");
		StringWriter sw = new StringWriter();
		m.write(sw, "TURTLE");
		log.debug(sw.toString());
		log.debug("Out file {}", outFile);
		assertThat(m.contains(null, prop(m, NS.RDF.PROP_TYPE), res(m, NS.EDM.CLASS_TIMESPAN))).isFalse();
		assertThat(m.contains(null, prop(m, NS.DCTERMS.PROP_ISSUED), "1833-08-29")).isTrue();
	}

	private Resource res(Model m, String res) {
		return m.createResource(res);
	}

	private Property prop(Model m, String propUri) {
		return m.createProperty(propUri);
	}

	private Literal lit(Model m, String lit) {
		return m.createLiteral(lit);
	}
	
	@Test
	public void testOneYearTimespan() throws Exception {
		Path inFile = Paths.get(Dm2e2Edm.class.getResource("/mpiwgraraMPIWG_D59WXSP9.ttl").toURI());
		Path outFile = Paths.get(inFile.toString() + ".out.xml");
		Dm2e2Edm dm2e2Edm = new Dm2e2Edm(inFile, "TURTLE", outFile, "RDF/XML");
		dm2e2Edm.run();

		log.debug("{}", outFile);
		Model m = ModelFactory.createDefaultModel();
		m.read(outFile.toFile().toURI().toURL().openStream(), null, "RDF/XML");
		StringWriter sw = new StringWriter();
		m.write(sw, "TURTLE");
		log.debug(sw.toString());
		
		final Resource cho = m.createResource("http://data.dm2e.eu/data/item/mpiwg/rara/MPIWG_D59WXSP9");
		assertThat(m.containsResource(cho));
		assertThat(cho.hasProperty(m.createProperty(NS.DCTERMS.PROP_ISSUED), m.createLiteral("1751"))).isTrue();
		assertThat(cho.hasProperty(m.createProperty(NS.EDM.PROP_HAS_TYPE), m.createLiteral("Book")));
	}
	
	@Test
	public void testIssue106() throws Exception {
		Model m = ModelFactory.createDefaultModel();
		Model out = ModelFactory.createDefaultModel();

		m.read(Dm2e2EdmTest.class.getResourceAsStream("/onbcodices2BZ9671240X.xml"), "", "RDF/XML");

		Dm2e2Edm dm2e2Edm = new Dm2e2Edm(m, out);
		dm2e2Edm.run();
		
		StringWriter sw = new StringWriter();
		out.write(sw, "TURTLE");
		log.debug(sw.toString());

		assertThat(out.containsResource(res(out, "http://data.dm2e.eu/data/timespan/onb/codices/1727-01-01T000000UG_1727-12-31T235959UG"))).isFalse();
		assertThat(out.containsResource(res(out, "http://d-nb.info/gnd/118692925"))).isTrue();
		assertThat(out.containsResource(res(out, "http://data.dm2e.eu/data/agent/onb/authority_gnd/118692925"))).isFalse();
	}
	
	@Test
	public void testMultipleSkosPrefLabel() throws Exception {
		
		Model m = ModelFactory.createDefaultModel();
		Model out = ModelFactory.createDefaultModel();

		m.read(Dm2e2EdmTest.class.getResourceAsStream("/multipleSkosPrefLabelExample.ttl"), "", "TURTLE");

		Dm2e2Edm dm2e2Edm = new Dm2e2Edm(m, out);
		dm2e2Edm.run();

		StringWriter sw = new StringWriter();
		out.write(sw, "TURTLE");
		log.debug(sw.toString());

		final Property skosPrefLabel = m.createProperty(NS.SKOS.PROP_PREF_LABEL);
		final Property skosAltLabel = m.createProperty(NS.SKOS.PROP_ALT_LABEL);
		assertThat(m.listStatements(null, skosPrefLabel, (RDFNode)null).toList().size()).isEqualTo(3);
		assertThat(m.listStatements(null, skosAltLabel, (RDFNode)null).toList().size()).isEqualTo(0);
		assertThat(out.listStatements(null, skosPrefLabel, (RDFNode)null).toList().size()).isEqualTo(1);
		assertThat(out.listStatements(null, skosAltLabel, (RDFNode)null).toList().size()).isEqualTo(2);
	}
	
	@Test
	public void testDateOfBirth() throws Exception {
		
		Model m = ModelFactory.createDefaultModel();
		Model out = ModelFactory.createDefaultModel();

		m.read(Dm2e2EdmTest.class.getResourceAsStream("/dateOfBirthExample.xml"), "", "RDF/XML");

		Dm2e2Edm dm2e2Edm = new Dm2e2Edm(m, out);
		dm2e2Edm.run();

		StringWriter sw = new StringWriter();
		out.write(sw, "TURTLE");
		log.debug(sw.toString());
		
		// DOB was translated to simple literal
		assertThat(out.contains(
				res(m, "http://data.dm2e.eu/data/agent/onb/abo/Johann_Reislin"),
				prop(m, NS.RDA_GR2.PROP_DATE_OF_BIRTH),
				lit(m, "1784")
				)).isTrue();
		// timestamp is not contained
		assertThat(out.containsResource(
				res(m, "http://data.dm2e.eu/data/timespan/onb/abo/1784-01-01T000000UG_1784-12-31T235959UG")
				)).isFalse();
	}

	@Test
	public void testDctermsProvenanceIsKept() throws Exception {
		Model m = ModelFactory.createDefaultModel();
		Model out = ModelFactory.createDefaultModel();

		final Resource someCHO = m.createResource("http://example.org/someCHO");
		final Property dctermsProvenance = m.createProperty(NS.DCTERMS.PROP_PROVENANCE);
		
		m.add(someCHO, m.createProperty(NS.RDF.PROP_TYPE), m.createResource(NS.EDM.CLASS_PROVIDED_CHO));
		m.add(someCHO, dctermsProvenance, "Some provenance");

		assertThat(m.listStatements(null, dctermsProvenance, (RDFNode)null).toList().size()).isEqualTo(1);

		Dm2e2Edm dm2e2Edm = new Dm2e2Edm(m, out);
		dm2e2Edm.run();

		assertThat(out.listStatements(null, dctermsProvenance, (RDFNode)null).toList().size()).isEqualTo(1);
	}
	
	@Test
	public void testHoldingInst() throws Exception {
		Model m = ModelFactory.createDefaultModel();
		Model out = ModelFactory.createDefaultModel();

		final Resource stadtarchivHalle = m.createResource("http://data.dm2e.eu/data/agent/sbb/kpe_DE-Ha179_37172/Stadtarchiv%20Halle");
		final Property dm2eHI = m.createProperty(NS.DM2E_UNVERSIONED.PROP_HOLDING_INSTITUTION);
		final Property dctermsProvenance = m.createProperty(NS.DCTERMS.PROP_PROVENANCE);

		m.read(Dm2e2EdmTest.class.getResourceAsStream("/holdinginstitution-provenance.ttl"), "", "TURTLE");


		assertThat(m.listStatements(null, dctermsProvenance, (RDFNode)null).toList().size()).isEqualTo(0);
		assertThat(m.listStatements(null, dm2eHI, (RDFNode)null).toList().size()).isEqualTo(1);

		Dm2e2Edm dm2e2Edm = new Dm2e2Edm(m, out);
		dm2e2Edm.run();

		assertThat(out.listStatements(null, dm2eHI, (RDFNode)null).toList().size()).isEqualTo(0);
		assertThat(out.listStatements(null, dctermsProvenance, (RDFNode)null).toList().size()).isEqualTo(1);
		assertThat(out.containsResource(stadtarchivHalle)).isFalse();;

		StringWriter sw = new StringWriter();
		out.write(sw, "TURTLE");
		log.debug(sw.toString());
	}
	
	@Test
	public void testPublicDomain() throws Exception {
		Model m = ModelFactory.createDefaultModel();
		Model out1934 = ModelFactory.createDefaultModel();
		Model outNone = ModelFactory.createDefaultModel();

		final Property dctIssued = prop(m, NS.DCTERMS.PROP_ISSUED);
		final Property edmRights = prop(m, NS.EDM.PROP_RIGHTS);
		final Resource restrictiveLicense = res(m, "http://example.org/more-restrictive-license");
		final Resource pdLicense = res(m, NS.LICENSE.PUBLIC_DOMAIN_MARK);

		final Resource someCHO = m.createResource("http://example.org/someCHO");
		m.add(someCHO, prop(m, NS.RDF.PROP_TYPE), res(m, NS.EDM.CLASS_PROVIDED_CHO));
		m.add(someCHO, dctIssued, "1933-01-01");
		m.add(someCHO, edmRights, restrictiveLicense);
		
		new Dm2e2Edm(m, out1934, DateTime.parse("1934-01-01")).run();;
		new Dm2e2Edm(m, outNone).run();
		
		assertThat(out1934.contains(someCHO, edmRights, pdLicense)).isTrue();
		assertThat(out1934.contains(someCHO, edmRights, restrictiveLicense)).isFalse();
		assertThat(outNone.contains(someCHO, edmRights, pdLicense)).isFalse();
		assertThat(outNone.contains(someCHO, edmRights, restrictiveLicense)).isTrue();
		
	}
/*
	@Test
	public void testInversePartOf() throws Exception {
		Model m = ModelFactory.createDefaultModel();
		Model out = ModelFactory.createDefaultModel();

		final Property dctermsHasPart = m.createProperty(NS.DCTERMS.PROP_HAS_PART);
		final Property dctermsIsPartOf = m.createProperty(NS.DCTERMS.PROP_IS_PART_OF);

		m.read(Dm2e2EdmTest.class.getResourceAsStream("/inversePartOf.ttl"), "", "TURTLE");

		assertThat(m.listStatements(null, dctermsIsPartOf, (RDFNode)null).toList().size()).isEqualTo(1);
		assertThat(m.listStatements(null, dctermsHasPart, (RDFNode)null).toList().size()).isEqualTo(0);

		Dm2e2Edm dm2e2Edm = new Dm2e2Edm(m, out);
		dm2e2Edm.run();

		StringWriter sw = new StringWriter();
		out.write(sw, "TURTLE");
		log.debug(sw.toString());

		assertThat(out.listStatements(null, dctermsIsPartOf, (RDFNode)null).toList().size()).isEqualTo(1);
		assertThat(out.listStatements(null, dctermsHasPart, (RDFNode)null).toList().size()).isEqualTo(1);
	}
*/
}
