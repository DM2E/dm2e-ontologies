package eu.dm2e.utils;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.util.ArrayList;

import org.apache.commons.cli.BasicParser;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;

import dm2e2edm.Dm2e2Edm;

public class Dm2e2EdmCLI {
	
	private static final Logger log = LoggerFactory.getLogger(Dm2e2EdmCLI.class);

	private static final String	DEFAULT_IN_FORMAT	= "RDF/XML";
	private static final String	DEFAULT_OUT_FORMAT	= "TURTLE";
	
	public static void main(String[] args) throws ParseException, FileNotFoundException {

		executeMain(args);
	}

	private static void executeMain(String[] args) throws ParseException, FileNotFoundException {
		// Parse options
		CommandLine line = parseOptions(args);
		
		String suffix = line.getOptionValue("suffix");
		String inFormat = line.getOptionValue("inFormat");
		if (null == inFormat) {
			inFormat = DEFAULT_IN_FORMAT;
		}
		String outFormat = line.getOptionValue("outFormat");
		if (null == outFormat) {
			outFormat = DEFAULT_OUT_FORMAT;
		}
		if (null == suffix) {
			suffix = ".edm.";
			suffix += outFormat.equals("RDF/XML") ? "xml" : outFormat.equals("TURTLE") ? "ttl" : outFormat.equals("N-TRIPLE") ? "n3" : "";
		}
		String filename = line.getOptionValue("file");
		String endpoint = line.getOptionValue("endpoint");
		System.out.println("Input Format: " + inFormat);
		System.out.println("Output Format: " + outFormat);
		if (line.hasOption("file")) {
			String outname = filename + suffix;
			Model input = ModelFactory.createDefaultModel();
			input.read(new FileInputStream(filename), "", inFormat);
			Model output = Dm2e2Edm.convertToEdm(input);
			output.write(new FileOutputStream(outname), outFormat);
		} else {
			
		}
	}

	private static CommandLine parseOptions(String[] args)
			throws ParseException {
		// Get the options
		Options options = getOptions();

		// create the parser
		CommandLineParser parser = new BasicParser();
		CommandLine line = null;
		// parse the command line arguments
		try {
			line = parser.parse(options, args);
			ArrayList<String> inOutFormatOpts = new ArrayList<>();
			inOutFormatOpts.add("inFormat");
			inOutFormatOpts.add("outFormat");
			for (String opt : inOutFormatOpts) {
				String formatArg = line.getOptionValue(opt);
				if (null != formatArg) {
					switch (formatArg) {
						case "RDF/XML": case "TURTLE": case "N-TRIPLE":
							break;
						default:
							throw new ParseException("Invalid '" + opt + "' arg '" + formatArg + "'. ");
					}
				}
			}
			String filename = line.getOptionValue("file");
			String endpoint = line.getOptionValue("endpoint");
			if (null == filename && null == endpoint) {
				dieHelpfully("Neither input file nor endpoint, nothing to do",  new Exception());
			} else if (null != filename) {
				try {
					File file = new File(filename);
					new FileReader(file);
				} catch (FileNotFoundException e) {
					dieHelpfully(filename, e);
				}
			} else {
				// TODO validate endpoint
			}
		} catch (ParseException e) {
			dieHelpfully("Error parsing command line options: ", e, true);
		}
		return line;
	}

	@SuppressWarnings("static-access")
	private static Options getOptions() {
		Options options = new Options();
		
		options.addOption(OptionBuilder
			.hasArgs(1)
			.withArgName("filename")
			.withDescription("Input file")
			.create("file"));
		options.addOption(OptionBuilder
			.hasArgs(1)
			.withArgName("endpoint")
			.withDescription("Input file")
			.create("endpoint"));
		options.addOption(OptionBuilder
			.hasArgs(1)
			.withArgName("RDF/XML | N-TRIPLE | TURTLE")
			.withDescription("RDF input serialization format [Default: RDF/XML]")
			.create("inFormat"));
		options.addOption(OptionBuilder
			.hasArgs(1)
			.withArgName("RDF/XML | N-TRIPLE | TURTLE")
			.withDescription("RDF input serialization format [Default: RDF/XML]")
			.create("outFormat"));
		options.addOption("stdout", false, "Write to STDOUT [Default: false]");
		options.addOption(OptionBuilder
			.hasArgs(1)
			.withArgName("suffix")
			.withDescription("output file suffix [default: '.edm.rdf']")
			.create("suffix"));
		return options;
	}

	private static void dieHelpfully(String msg, Exception e) { dieHelpfully(msg, e, false); }
	private static void dieHelpfully(String msg, Exception e, boolean showUsage) {
		System.err.print("!! ");
		if (msg != null) System.err.print(msg + " ");
		System.err.println(e.getMessage());
		if (showUsage) {
			HelpFormatter formatter = new HelpFormatter();
			formatter.setWidth(100);
			formatter.printHelp("java -jar dm2e-validate.jar [options] <file> [<file>...]",
					"DM2E 2 EDM Tool, Build Date: 'Fri Feb 28 23:41:10 CET 2014'",
					getOptions(),
					""
					);
		}
		throw new RuntimeException();
	}
}
