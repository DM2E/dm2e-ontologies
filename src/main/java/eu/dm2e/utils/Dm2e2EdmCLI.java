package eu.dm2e.utils;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import org.apache.commons.cli.BasicParser;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import dm2e2edm.Dm2e2Edm;

/**
 * @author Konstantin Baierer
 * 
 * Options:
 * 		--input_dir 		Directory with the input RDF/XML files
 * 		--output_dir		Directory to write output RDF/XML files to
 * 		--max-threads		Maximum of parallel threads
 *
 */
public class Dm2e2EdmCLI {
	
	private static final int	NUMBER_OF_THREADS	= 5;

	private static final Logger log = LoggerFactory.getLogger(Dm2e2EdmCLI.class);

	private static final String	DEFAULT_IN_FORMAT	= "RDF/XML";
	private static final String	DEFAULT_OUT_FORMAT	= "RDF/XML-ABBREV";

	private static final String	DEFAULT_OUTPUT_DIR	= "dm2e2edm-output";
	
	public static void main(String[] args) throws ParseException {

		// Parse options
		CommandLine line = parseOptions(args);
		
		// Set up parameters
		String inFormat = line.getOptionValue("input_format");
		if (null == inFormat) inFormat = DEFAULT_IN_FORMAT;
		String outFormat = line.getOptionValue("output_format");
		if (null == outFormat) outFormat = DEFAULT_OUT_FORMAT;
		String suffix = line.getOptionValue("suffix");
		if (null == suffix) {
			suffix = ".edm.";
			switch (outFormat) {
				case "RDF/XML":
				case "RDF/XML-ABBREV":
					suffix += "xml";
					break;
				case "TURTLE":
					suffix += "ttl";
					break;
				case "N-TRIPLE":
					suffix += "n3";
					break;
			}
		}
		Path inputDir = Paths.get(line.getOptionValue("input_dir"));
		String outputDirStr = line.getOptionValue("output_dir");
		if (null == outputDirStr) outputDirStr = DEFAULT_OUTPUT_DIR;
		Path outputDir = Paths.get(outputDirStr);
		
		// Setup thread pool
		ExecutorService threadPool = Executors.newFixedThreadPool(NUMBER_OF_THREADS);
		
		// Run !
		Iterator<Path> inputFileIterator = null;
		try {
			inputFileIterator = Files.newDirectoryStream(inputDir).iterator();
		} catch (IOException e) {
			dieHelpfully("Couldn't list the input files");
		}
		while (inputFileIterator.hasNext()) {
			Path curIn = inputFileIterator.next();
			if (! (
					curIn.getFileName().endsWith("ttl")
					||
					curIn.getFileName().endsWith("xml")
					||
					curIn.getFileName().endsWith("n3")
					||
					curIn.getFileName().endsWith("nt")
					||
					curIn.getFileName().endsWith("rdf")
					)) {
				continue;
			}
			Path curOut = Paths.get(outputDir.toAbsolutePath().toString(), curIn.getFileName() + suffix );
			log.debug("{} --> {}", curIn, curOut);
			Dm2e2Edm worker = new Dm2e2Edm(curIn, inFormat, curOut, outFormat);
//			worker.run();
//			break;
			threadPool.execute(worker);
		}
		threadPool.shutdown();
		try {
			threadPool.awaitTermination(Long.MAX_VALUE, TimeUnit.NANOSECONDS);
		} catch (InterruptedException e) {
			e.printStackTrace();
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

			// --input_format
			// --output_format
			ArrayList<String> inOutFormatOpts = new ArrayList<>();
			inOutFormatOpts.add("input_format");
			inOutFormatOpts.add("output_format");
			for (String opt : inOutFormatOpts) {
				String formatArg = line.getOptionValue(opt);
				if (null != formatArg) {
					switch (formatArg) {
						case "RDF/XML": case "TURTLE": case "N-TRIPLE": case "N-QUADS":
							break;
						default:
							throw new ParseException("Invalid '" + opt + "' arg '" + formatArg + "'. ");
					}
				}
			}
			
			// --input_dir
			Path inputDir = Paths.get(line.getOptionValue("input_dir"));
			if (! Files.exists(inputDir)) {
				dieHelpfully("Input dir " + inputDir.toString() + " does not exist", null);
			} else if (! Files.isDirectory(inputDir)) {
				dieHelpfully("Input dir " + inputDir.toString() + " is not a directory", null);
			}

			// --output_dir
			final String outDirVal = line.getOptionValue("output_dir");
			if (null != outDirVal) {
				Path outputDir = Paths.get(outDirVal);
				if (! Files.exists(outputDir)) {
					dieHelpfully("Output dir " + outputDir.toString() + " does not exist", null);
				} else if (! Files.isDirectory(outputDir)) {
					dieHelpfully("Output dir " + outputDir.toString() + " is not a directory", null);
				}
			} else {
				try{
				Files.createDirectories(Paths.get(DEFAULT_OUTPUT_DIR));
				} catch (IOException e) {
					dieHelpfully("Error creating output directory: " + DEFAULT_OUTPUT_DIR, e, true);
				}
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
			.isRequired()
			.withDescription("Input directory of RDF files")
			.create("input_dir"));
		options.addOption(OptionBuilder
			.hasArgs(1)
			.withArgName("directory")
			.withDescription("Output directory of RDF files [Default: " + DEFAULT_OUTPUT_DIR + "]")
			.create("output_dir"));
		options.addOption(OptionBuilder
			.hasArgs(1)
			.withArgName("RDF/XML | N-TRIPLE | TURTLE")
			.withDescription("RDF input serialization format [Default: " + DEFAULT_IN_FORMAT + "]")
			.create("input_format"));
		options.addOption(OptionBuilder
			.hasArgs(1)
			.withArgName("RDF/XML | N-TRIPLE | TURTLE")
			.withDescription("RDF output serialization format [Default: " + DEFAULT_OUT_FORMAT + "]")
			.create("output_format"));
		return options;
	}

	private static void dieHelpfully(String msg) { dieHelpfully(msg, null, false); }
	private static void dieHelpfully(String msg, boolean showUsage) { dieHelpfully(msg, null, showUsage); }
	private static void dieHelpfully(String msg, Exception e) { dieHelpfully(msg, e, false); }
	private static void dieHelpfully(String msg, Exception e, boolean showUsage) {
		System.err.print("!! ");
		if (msg != null) System.err.print(msg + " ");
		if (e != null) System.err.println(e.getMessage());
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
