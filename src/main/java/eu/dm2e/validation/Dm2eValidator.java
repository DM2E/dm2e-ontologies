package eu.dm2e.validation;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.util.HashSet;
import java.util.Set;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.cli.PosixParser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.base.Preconditions;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.rdf.model.NodeIterator;
import com.hp.hpl.jena.rdf.model.Property;
import com.hp.hpl.jena.rdf.model.RDFNode;
import com.hp.hpl.jena.rdf.model.ResIterator;
import com.hp.hpl.jena.rdf.model.Resource;

import eu.dm2e.NS;

public class Dm2eValidator {

	private static final Logger	log				= LoggerFactory.getLogger(Dm2eValidator.class);

	private static final String	modelVersion	= "v1.1_Rev1.2-DRAFT";

	private static Set<Property> buildAnnotatableWebResourceAggregationProperties(Model m) {
		Set<Property> req = new HashSet<>();
		req.add(m.createProperty(NS.EDM.PROP_IS_SHOWN_BY));
		req.add(m.createProperty(NS.EDM.PROP_IS_SHOWN_AT));
		req.add(m.createProperty(NS.EDM.PROP_OBJECT));
		req.add(m.createProperty(NS.DM2E.PROP_HAS_ANNOTABLE_VERSION_AT));
		return req;
	}

	private static Set<Property> buildRequiredCHOProperties(Model m) {
		Set<Property> req = new HashSet<>();
		req.add(m.createProperty(NS.DM2E.PROP_DISPLAY_LEVEL));
		req.add(m.createProperty(NS.DC.PROP_TITLE));
		req.add(m.createProperty(NS.EDM.PROP_TYPE));
		req.add(m.createProperty(NS.DC.PROP_TYPE));
		req.add(m.createProperty(NS.DC.PROP_LANGUAGE));
		req.add(m.createProperty(NS.DC.PROP_SUBJECT));
		return req;
	}

	private static Set<Property> buildRequiredAggregationProperties(Model m) {
		Set<Property> req = new HashSet<>();
		req.add(m.createProperty(NS.EDM.PROP_AGGREGATED_CHO));
		req.add(m.createProperty(NS.EDM.PROP_PROVIDER));
		req.add(m.createProperty(NS.EDM.PROP_DATA_PROVIDER));
		req.add(m.createProperty(NS.EDM.PROP_RIGHTS));
		return req;
	}

	private static Set<Property> buildRecommendedAggregationProperties(Model m) {
		Set<Property> req = new HashSet<>();
		req.add(m.createProperty(NS.EDM.PROP_OBJECT));
		req.add(m.createProperty(NS.DM2E.PROP_HAS_ANNOTABLE_VERSION_AT));
		return req;
	}

	public static Dm2eValidationReport validateWithDm2e(String fileName, String rdfLang) throws FileNotFoundException {
		Preconditions.checkArgument(rdfLang.equals("RDF/XML") || rdfLang.equals("N-TRIPLE") || rdfLang.equals("TURTLE"), "Invalid RDF serialization format '" + rdfLang +"'.");
		Preconditions.checkArgument(new File(fileName).exists(), "File does not exist.");
		Model m = ModelFactory.createDefaultModel();
		FileInputStream fis = new FileInputStream(new File(fileName));
		m.read(fis, "", rdfLang);
		return validateWithDm2e(m);
	}

	/**
	 * Validates all aggregations within a Jena Model against the DM2E data
	 * model
	 * 
	 * @param m
	 *            the Jena Model that contains the data
	 * @return A {@link Dm2eValidationReport}
	 */
	public static Dm2eValidationReport validateWithDm2e(Model m) {
		ResIterator aggIter = m.listSubjectsWithProperty(m.createProperty(NS.RDF.PROP_TYPE), m
			.createProperty(NS.ORE.CLASS_AGGREGATION));
		Dm2eValidationReport report = new Dm2eValidationReport(modelVersion);
		while (aggIter.hasNext()) {
			Resource agg = aggIter.next();
			log.debug("About to validate aggregation " + agg);
			validateAggregation(m, agg, report);
		}
		return report;

	}

	/**
	 * Validates an aggregation within a Jena Model against the DM2E data model
	 * 
	 * @param m
	 *            the Jena Model that contains the data
	 * @param aggUri
	 *            the aggregation to start validation from
	 * @return A {@link Dm2eValidationReport}
	 */
	public Dm2eValidationReport validateWithDm2e(Model m, String aggUri) {

		Dm2eValidationReport report = new Dm2eValidationReport(modelVersion);
		Resource agg = m.createResource(aggUri);
		validateAggregation(m, agg, report);
		return report;

	}

	/**
	 * @param m
	 * @param cho
	 * @param report
	 */
	private static void validateCHO(Model m, Resource cho, Dm2eValidationReport report) {
		Set<Property> choProperties = buildRequiredCHOProperties(m);

		for (Property prop : choProperties) {
			NodeIterator iter = m.listObjectsOfProperty(cho, prop);
			if (!iter.hasNext()) report.add(cho, "missing required property <" + prop + ">.");
		}
	}

	/**
	 * @param m
	 * @param agg
	 * @param report
	 */
	private static void validateAggregation(Model m, Resource agg, Dm2eValidationReport report) {
		// find CHO
		NodeIterator choIter = m.listObjectsOfProperty(agg, m
			.createProperty(NS.EDM.PROP_AGGREGATED_CHO));
		if (!choIter.hasNext()) {
			report.add(agg, "Missing required edm:aggregatedCHO! Fail!");
			return;
		}
		Resource cho = choIter.next().asResource();

		//
		// Check required properties
		//
		Set<Property> aggregationProperties = buildRequiredAggregationProperties(m);
		Set<Property> aggregationRecommendedProperties = buildRecommendedAggregationProperties(m);
		Set<Property> aggregationWebResourceProperties = buildAnnotatableWebResourceAggregationProperties(m);

		for (Property prop : aggregationProperties) {
			NodeIterator iter = m.listObjectsOfProperty(agg, prop);
			if (!iter.hasNext()) report.add(agg, "Missing required property <" + prop + ">.");
		}

		//
		// Check isShownAt / isShownBy
		//
		{
			NodeIterator isaIter = m.listObjectsOfProperty(agg, m
				.createProperty(NS.EDM.PROP_IS_SHOWN_AT));
			NodeIterator isbIter = m.listObjectsOfProperty(agg, m
				.createProperty(NS.EDM.PROP_IS_SHOWN_BY));
			if (!isaIter.hasNext() && !isbIter.hasNext()) report.add(agg,
					"Aggregation needs either edm:isShownAt or edm:isShownBy.");
			else if (isaIter.hasNext() && isbIter.hasNext()) report.add(agg,
					"Aggregation musn't contain both edm:isShownAt and edm:isShownBy.");
		}

		//
		// Check recommended properties
		//
		for (Property prop : aggregationRecommendedProperties) {
			NodeIterator iter = m.listObjectsOfProperty(agg, prop);
			if (!iter.hasNext()) report.add(agg,
					"Aggregation is missing strongly recommended property <" + prop + ">.");
		}

		//
		// Check web resources
		//
		for (Property prop : aggregationWebResourceProperties) {
			NodeIterator iter = m.listObjectsOfProperty(agg, prop);
			while (iter.hasNext())
				validateWebResource(m, iter.next().asResource(), prop, report);

		}

		validateCHO(m, cho, report);
	}

	/**
	 * @param m
	 *            the Jena Model that contains the data
	 * @param wr
	 *            the WebResource Jena Resource
	 * @param prop
	 *            the property that referred to this WebResource
	 * @param report
	 *            the ValidationReport
	 */
	private static void validateWebResource(Model m,
			Resource wr,
			Property prop,
			Dm2eValidationReport report) {
		NodeIterator it = m.listObjectsOfProperty(wr, m.createProperty(NS.DC.PROP_FORMAT));
		if (!it.hasNext()) {
			report.add(wr, "missing required property <" + NS.DC.PROP_FORMAT + ">.", prop);
		} else {
			RDFNode dcformat = it.next();
			if (!dcformat.isLiteral()) {
				report.add(wr, "<" + NS.DC.PROP_FORMAT + "> must be a literal.", prop);
			} else {
				String dcformatString = dcformat.asLiteral().getString();
				switch (dcformatString) {
					case "text/html-named-content":
					case "text/html":
					case "text/plain":
					case "image/png":
					case "image/gif":
						break;
					default:
						report.add(wr, "Unsupported MIME type '" + dcformatString + "'.", prop);
				}
			}
		}
	}

	/**
	 * @param args
	 */
	@SuppressWarnings("static-access")
	public static void main(String[] args) {

		Options options = new Options();
		options.addOption(OptionBuilder
			.isRequired()
			.hasArgs()
			.withArgName("RDF/XML|N-TRIPLE|TURTLE")
			.withDescription("RDF input serialization format")
			.create("format"));
		options.addOption(OptionBuilder
			.isRequired()
			.hasArgs()
			.withArgName("file")
			.withDescription("RDF input file")
			.create("file"));

		// create the parser
		CommandLineParser parser = new PosixParser();
		CommandLine line = null;
		boolean showHelp = false;
		String fileVal = null;
		try {
			// parse the command line arguments
			line = parser.parse(options, args);
			fileVal = new File(line.getOptionValue("file")).getAbsolutePath();
			Dm2eValidationReport report = validateWithDm2e(fileVal, line.getOptionValue("format"));
			System.out.println(report.toString());
		} catch (ParseException exp) {
			// oops, something went wrong
			System.err.println("Error parsing command line options: " + exp.getMessage());
			showHelp = true;
		} catch (IllegalArgumentException e) {
			System.err.println("Error validating: " + e);
			showHelp = true;
		} catch (FileNotFoundException e) {
			System.err.println("File not found: " + fileVal);
			showHelp = true;
		}
		if (showHelp) {
			HelpFormatter formatter = new HelpFormatter();
			formatter.printHelp("dm2e-validate", options);
		}

	}
}
