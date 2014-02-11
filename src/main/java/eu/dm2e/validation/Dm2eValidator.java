package eu.dm2e.validation;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import org.apache.commons.cli.BasicParser;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.io.FileUtils;
import org.apache.jena.riot.RiotException;
import org.joda.time.DateTime;
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
import com.hp.hpl.jena.rdf.model.StmtIterator;

import eu.dm2e.NS;

/**
 * Static methods for validating RDF data against the DM2E Data Model
 * 
 * <p>
 * Based on v1.1_Rev1.2-DRAFT of the requirements
 * </p>
 * 
 * @author Konstantin Baierer
 */
public class Dm2eValidator {

	private static final Logger	log				= LoggerFactory.getLogger(Dm2eValidator.class);

	private static final String	modelVersion	= "v1.1_Rev1.2-DRAFT";

	private static Resource res(Model m, String uri) {
		return m.createResource(uri);
	}

	private static Property prop(Model m, String uri) {
		return m.createProperty(uri);
	}

	private static Property isa(Model m) {
		return prop(m, NS.RDF.PROP_TYPE);
	}
	
	private static boolean isa(Model m, Resource res, String type) {
		if (m.contains(res, isa(m), res(m, type))) {
			return true;
		}
		return false;
	}

	/**
	 * @return a set of those properties whose range are annotatable WebResources
	 * @param m
	 */
	private static Set<Property> buildAnnotatableWebResourceAggregationProperties(Model m) {
		Set<Property> req = new HashSet<>();
		req.add(prop(m, NS.EDM.PROP_IS_SHOWN_BY));
		req.add(prop(m, NS.EDM.PROP_IS_SHOWN_AT));
		req.add(prop(m, NS.EDM.PROP_OBJECT));
		req.add(prop(m, NS.DM2E.PROP_HAS_ANNOTABLE_VERSION_AT));
		return req;
	}

	/**
	 * @return a set of all required CHO properties
	 * @param m
	 */
	private static Set<Property> buildRequiredCHOProperties(Model m) {
		Set<Property> req = new HashSet<>();
		req.add(prop(m, NS.DM2E.PROP_DISPLAY_LEVEL));
		req.add(prop(m, NS.EDM.PROP_TYPE));
		req.add(prop(m, NS.DC.PROP_TYPE));
		req.add(prop(m, NS.DC.PROP_LANGUAGE));
		req.add(prop(m, NS.DC.PROP_SUBJECT));
		return req;
	}

	/**
	 * @return a map of CHO properties and the allowed ranges of the objects of
	 *         such statements
	 * @param m
	 *            the {@link Model}
	 */
	private static Map<Property, Set<Resource>> buildChoSubRanges(Model m) {
		Map<Property, Set<Resource>> choSubRanges = new HashMap<>();
		choSubRanges.put(prop(m, NS.DC.PROP_SUBJECT), new HashSet<Resource>());
		choSubRanges.get(prop(m, NS.DC.PROP_SUBJECT)).add(res(m, NS.SKOS.CLASS_CONCEPT));
		choSubRanges.get(prop(m, NS.DC.PROP_SUBJECT)).add(res(m, NS.EDM.CLASS_AGENT));
		choSubRanges.get(prop(m, NS.DC.PROP_SUBJECT)).add(res(m, NS.EDM.CLASS_TIMESPAN));

		choSubRanges.put(prop(m, NS.EDM.PROP_HAS_MET), new HashSet<Resource>());
		choSubRanges.get(prop(m, NS.EDM.PROP_HAS_MET)).add(res(m, NS.SKOS.CLASS_CONCEPT));
		choSubRanges.get(prop(m, NS.EDM.PROP_HAS_MET)).add(res(m, NS.EDM.CLASS_EVENT));
		choSubRanges.get(prop(m, NS.EDM.PROP_HAS_MET)).add(res(m, NS.EDM.CLASS_PLACE));
		choSubRanges.get(prop(m, NS.EDM.PROP_HAS_MET)).add(res(m, NS.EDM.CLASS_AGENT));
		choSubRanges.get(prop(m, NS.EDM.PROP_HAS_MET)).add(res(m, NS.EDM.CLASS_TIMESPAN));
		choSubRanges.get(prop(m, NS.EDM.PROP_HAS_MET)).add(res(m, NS.FOAF.CLASS_PERSON));
		choSubRanges.get(prop(m, NS.EDM.PROP_HAS_MET)).add(res(m, NS.FOAF.CLASS_ORGANIZATION));
		return choSubRanges;
	}

	/**
	 * @return the required properties of an {@link NS.ORE.AGGREGATION}
	 * @param m
	 *            the {@link Model}
	 */
	private static Set<Property> buildRequiredAggregationProperties(Model m) {
		Set<Property> req = new HashSet<>();
		req.add(prop(m, NS.EDM.PROP_AGGREGATED_CHO));
		req.add(prop(m, NS.EDM.PROP_PROVIDER));
		req.add(prop(m, NS.EDM.PROP_DATA_PROVIDER));
		req.add(prop(m, NS.EDM.PROP_RIGHTS));
		return req;
	}

	/**
	 * @return the strongly recommended properties of an
	 *         {@link NS.ORE.AGGREGATION}
	 * @param m
	 *            the {@link Model}
	 */
	private static Set<Property> buildRecommendedAggregationProperties(Model m) {
		Set<Property> ret = new HashSet<>();
		ret.add(prop(m, NS.EDM.PROP_OBJECT));
		ret.add(prop(m, NS.DM2E.PROP_HAS_ANNOTABLE_VERSION_AT));
		return ret;
	}
	
	/**
	 * @return the properties that can link to a timespan or an xsd:dateTime literal
	 * @param m
	 */
	private static Set<Property> buildDateLikeProperties(Model m) {
		Set<Property> ret = new HashSet<>();
		ret.add(prop(m, NS.DCTERMS.PROP_CREATED));
		ret.add(prop(m, NS.DCTERMS.PROP_MODIFIED));
		ret.add(prop(m, NS.DCTERMS.PROP_ISSUED));
		ret.add(prop(m, NS.DCTERMS.PROP_TEMPORAL));
		ret.add(prop(m, NS.CRM.PROP_P79F_BEGINNING_IS_QUALIFIED_BY));
		ret.add(prop(m, NS.CRM.PROP_P80F_END_IS_QUALIFIED_BY));
		ret.add(prop(m, NS.EDM.PROP_BEGIN));
		ret.add(prop(m, NS.EDM.PROP_END));
		ret.add(prop(m, NS.DC.PROP_SUBJECT));
		ret.add(prop(m, NS.EDM.PROP_HAS_MET));
		ret.add(prop(m, NS.DC.PROP_DATE));
		return ret;
	}

	public static Dm2eValidationReport validateWithDm2e(String fileName, String rdfLang)
			throws FileNotFoundException {
		Preconditions.checkArgument(rdfLang.equals("RDF/XML") || rdfLang.equals("N-TRIPLE")
				|| rdfLang.equals("TURTLE"), "Invalid RDF serialization format '" + rdfLang + "'.");
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
		ResIterator aggIter = m.listSubjectsWithProperty(prop(m, NS.RDF.PROP_TYPE), m
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
	public static Dm2eValidationReport validateWithDm2e(Model m, String aggUri) {

		Dm2eValidationReport report = new Dm2eValidationReport(modelVersion);
		Resource agg = res(m, aggUri);
		validateAggregation(m, agg, report);
		return report;

	}



	/**
	 * Validate an Aggregation against the requirements (p.16-24)
	 * 
	 * @param m
	 *            the Jena {@link Model} that contains the data
	 * @param agg
	 *            the {@link Resource} of the Aggregation
	 * @param report
	 *            the {@link Dm2eValidationReport} to write to
	 */
	private static void validateAggregation(Model m, Resource agg, Dm2eValidationReport report) {
		// find CHO
		NodeIterator choIter = m.listObjectsOfProperty(agg, m
			.createProperty(NS.EDM.PROP_AGGREGATED_CHO));
		if (!choIter.hasNext()) {
			report.addError(agg, "Missing required edm:aggregatedCHO! Fail!");
			return;
		}
		Resource cho = choIter.next().asResource();

		//
		// Check required properties
		//
		Set<Property> aggregationProperties = buildRequiredAggregationProperties(m);

		for (Property prop : aggregationProperties) {
			NodeIterator iter = m.listObjectsOfProperty(agg, prop);
			if (!iter.hasNext()) report.addError(agg, "Missing required property <" + prop + ">.");
		}

		//
		// Check isShownAt / isShownBy
		//
		{
			NodeIterator isaIter = m.listObjectsOfProperty(agg, m
				.createProperty(NS.EDM.PROP_IS_SHOWN_AT));
			NodeIterator isbIter = m.listObjectsOfProperty(agg, m
				.createProperty(NS.EDM.PROP_IS_SHOWN_BY));
			if (!isaIter.hasNext() && !isbIter.hasNext()) report.addError(agg,
					"Aggregation needs either edm:isShownAt or edm:isShownBy.");
			else if (isaIter.hasNext() && isbIter.hasNext()) report.addWarning(agg,
					"Aggregation musn't contain both edm:isShownAt and edm:isShownBy.");
		}

		//
		// Check recommended properties
		//
		Set<Property> aggregationRecommendedProperties = buildRecommendedAggregationProperties(m);
		for (Property prop : aggregationRecommendedProperties) {
			NodeIterator iter = m.listObjectsOfProperty(agg, prop);
			if (!iter.hasNext()) report.addWarning(agg,
					"Aggregation is missing strongly recommended property <" + prop + ">.");
		}

		//
		// Check web resources
		//
		Set<Property> aggregationWebResourceProperties = buildAnnotatableWebResourceAggregationProperties(m);
		for (Property prop : aggregationWebResourceProperties) {
			NodeIterator iter = m.listObjectsOfProperty(agg, prop);
			while (iter.hasNext())
				validateWebResource(m, iter.next().asResource(), prop, report);
		}

		//
		// Validate the CHO
		//
		validateCHO(m, cho, report);
	}

	/**
	 * Validate a CHO against the requirements (p.25-42)
	 * 
	 * @param m
	 *            the {@link Model} containing the data
	 * @param cho
	 *            the CHO {@link Resource}
	 * @param report
	 *            the {@link Dm2eValidationReport} to write to
	 */
	private static void validateCHO(Model m, Resource cho, Dm2eValidationReport report) {

		//
		// Check required properties
		//
		Set<Property> choProperties = buildRequiredCHOProperties(m);
		for (Property prop : choProperties) {
			NodeIterator iter = m.listObjectsOfProperty(cho, prop);
			if (!iter.hasNext()) {
				report.addError(cho, "missing required property <" + prop + ">.");
			}
		}

		//
		// Range checks
		//
		Map<Property, Set<Resource>> choSubRanges = buildChoSubRanges(m);
		for (Entry<Property, Set<Resource>> entry : choSubRanges.entrySet()) {
			Property prop = entry.getKey();
			StmtIterator iter = cho.listProperties(prop);
			while (iter.hasNext()) {
				RDFNode obj = iter.next().getObject();
				if (!obj.isResource()) {
					report.addError(cho, "Object of <" + prop + "> must be a URI resource. ");
				} else {
					final Resource objRes = obj.asResource();
					boolean validRange = false;
					for (Resource allowedRange : entry.getValue()) {
						if (objRes.hasProperty(isa(m), allowedRange)) {
							validRange = true;
							break;
						}
					}
					if (!validRange) report.addError(objRes, " must be of rdf:type ", entry
						.getValue(), prop);
				}
			}
		}

		//
		// dc:title and/or dc:description (p.26/27)
		//
		if (!(cho.hasProperty(prop(m, NS.DC.PROP_TITLE)) || cho.hasProperty(prop(m, NS.DC.PROP_DESCRIPTION)))) {
			report.addError(cho, "missing at least one of dc:title and/or dc:description");
		}
		
		//
		// Validate TimeSpans and xsd:dateTime
		//
		validateDateLike(m, cho, report);
		
	}

	/**
	 * @param m
	 * @param res
	 * @param report
	 */
	private static void validateDateLike(Model m, Resource res, Dm2eValidationReport report) {
		Set<Property> dateProps = buildDateLikeProperties(m);
		for (Property prop : dateProps) {
			StmtIterator iter = res.listProperties(prop);
			while (iter.hasNext()) {
				RDFNode thing = iter.next().getObject();
				if (thing.isResource() && isa(m, thing.asResource(), NS.EDM.CLASS_TIMESPAN)) {
					validateTimeSpan(m, thing.asResource(), prop, report);
				} else if (thing.isLiteral()) {
					if (thing.asLiteral().getDatatypeURI() == null) {
						report.addNotice(res, "has untyped literal date field.", prop);
					} else if (thing.asLiteral().getDatatypeURI().equals(NS.XSD.DATETIME)) {
						try {
							DateTime.parse(thing.asLiteral().getLexicalForm());
						} catch (IllegalArgumentException e) {
							report.addError(res, "Invalid xsd:dateTime '" + thing.asLiteral().getLexicalForm() + "'. ", prop); 
						}
					} else {
						report.addError(res, "has literal with disallowed datatype " + thing.asLiteral().getDatatypeURI(), prop );
					}
				}
			}
		}
	}

	/**
	 * Validate a WebResource against the requirements (p.44-48)
	 * 
	 * @param m
	 *            the Jena Model that contains the data
	 * @param wr
	 *            the WebResource Jena Resource
	 * @param prop
	 *            the property that referred to this WebResource
	 * @param report
	 *            the ValidationReport
	 */
	private static void validateWebResource(Model m, Resource wr, Property prop, Dm2eValidationReport report) {
		NodeIterator it = m.listObjectsOfProperty(wr, prop(m, NS.DC.PROP_FORMAT));
		if (!it.hasNext()) {
			report.addError(wr, "missing required property <" + NS.DC.PROP_FORMAT + ">.", prop);
		} else {
			RDFNode dcformat = it.next();
			if (!dcformat.isLiteral()) {
				report.addError(wr, "<" + NS.DC.PROP_FORMAT + "> must be a literal.", prop);
			} else {
				String dcformatString = dcformat.asLiteral().getString();
				switch (dcformatString) {
					case "text/html-named-content":
					case "text/html":
					case "text/plain":
					case "image/jpeg":
					case "image/png":
					case "image/gif":
						break;
					default:
						report
							.addError(wr, "Unsupported MIME type '" + dcformatString + "'.", prop);
				}
			}
		}
	}

	private static void validateTimeSpan(Model m, Resource ts, Property prop, Dm2eValidationReport report) {
		if ( ! ( ts.hasProperty(prop(m, NS.EDM.PROP_BEGIN))
				|| ts.hasProperty(prop(m, NS.CRM.PROP_P79F_BEGINNING_IS_QUALIFIED_BY)))) {
			report.addWarning(ts, "TimeSpan has no beginning.", prop);
		}
		if ( ! ( ts.hasProperty(prop(m, NS.EDM.PROP_END))
				|| ts.hasProperty(prop(m, NS.CRM.PROP_P80F_END_IS_QUALIFIED_BY)))) {
			report.addWarning(ts, "TimeSpan has no end.", prop);
		}
	}

	/**
	 * Main d
	 * <p>
	 * Usage is:
	 * <code>$invocation [--format N-TRIPLE] [--level NOTICE] [--stdout] [--suffix '.validation.txt'] file1.ttl file2.ttl ...</code>
	 * </p>
	 * 
	 * @param args
	 *            the command line arguments
	 */
	@SuppressWarnings("static-access")
	public static void main(String[] args) {

		Options options = new Options();
		options.addOption(OptionBuilder
			.hasArgs(1)
			.withArgName("NOTICE|WARNING|ERROR")
			.withDescription("Minimum Validation level [Default: NOTICE]")
			.create("level"));
		options.addOption(OptionBuilder
			.hasArgs(1)
			.withArgName("RDF/XML|N-TRIPLE|TURTLE")
			.withDescription("RDF input serialization format [Default: RDF/XML]")
			.create("format"));
		options.addOption("stdout", false, "Whether to write to STDOUT [default: No]");
		options.addOption(OptionBuilder
			.hasArgs()
			.withArgName("suffix")
			.withDescription("output file suffix [default: '.validation.txt']")
			.create("suffix"));

		// create the parser
		CommandLineParser parser = new BasicParser();
		CommandLine line = null;
		boolean showHelp = false;
		String format = "RDF/XML";
		try {
			// parse the command line arguments
			line = parser.parse(options, args);
			String formatArg = line.getOptionValue("format");
			String levelArg = line.getOptionValue("level");
			ValidationLevel minimumLevel = (null != levelArg) ? ValidationLevel.valueOf(levelArg) : ValidationLevel.NOTICE;
			if (null != formatArg) format = formatArg;
			if (line.getArgList().size() == 0) {
				showHelp = true;
				throw new ParseException("No files given");
			}
			for (Object fileArg : line.getArgList()) {
				String fileName = new File(fileArg.toString()).getAbsolutePath();
				Dm2eValidationReport report = validateWithDm2e(fileName, format);
				if (line.hasOption("stdout")) {
					System.out.println(report.exportToString(minimumLevel));
					System.err.println("DONE validating " + fileName);
				} else {
					String suffixVal = line.getOptionValue("suffix");
					if (null == suffixVal) suffixVal = ".validation.txt";
					File outfile = new File(fileName + suffixVal);
					FileUtils.writeStringToFile(outfile, report.exportToString(minimumLevel));
					System.err.println("DONE validating " + fileName + ". Output written to "
							+ outfile.getPath() + ".");
				}
			}
		} catch (ParseException exp) {
			// oops, something went wrong
			System.err.println("Error parsing command line options: " + exp.getMessage());
			showHelp = true;
		} catch (IllegalArgumentException e) {
			System.err.println("Error validating: " + e);
			showHelp = true;
		} catch (IOException e) {
			System.err.println("Couldn't write to outfile!");
			showHelp = true;
		} catch (RiotException e) {
			System.err.println("Jena croaked on the input. Are you sure this is " + format + " ?");
		}
		if (showHelp) {
			HelpFormatter formatter = new HelpFormatter();
			formatter.printHelp("dm2e-validate [options] <file> [<file>...]", options);
		}

	}
}
