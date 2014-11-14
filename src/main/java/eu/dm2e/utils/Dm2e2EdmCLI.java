package eu.dm2e.utils;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Iterator;

import org.apache.commons.cli.BasicParser;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.joda.time.DateTime;

import dm2e2edm.Dm2e2Edm;

/**
 * @author Konstantin Baierer
 * 
 * Options:
 * 		--input_file 		Input RDF files
 * 		--input_dir 		Directory with the input RDF files
 * 		--output_dir		Directory to write output RDF/XML files to
 * 		--max-threads		Maximum of parallel threads
 *
 */
public class Dm2e2EdmCLI {
	
	// TODO HACK -- there is a thread-related issue resulting in no results from SPARQL queries on the model
	// Probably has to do with static models for edm and dm2e in Dm2e2Edm. For now, reusing just one thread
	// avoids the problem, slow though it is: ~ 33 Records per second on a quadcore 2.7ghz i7 => days for DM2E whole :(
//	private static final int	NUMBER_OF_THREADS	= 1;

//	private static final Logger log = LoggerFactory.getLogger(Dm2e2EdmCLI.class);

	private static final String	DEFAULT_IN_FORMAT	= "RDF/XML";
	private static final String	DEFAULT_OUT_FORMAT	= "RDF/XML";

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
		String outputDirStr = line.getOptionValue("output_dir");
		if (null == outputDirStr) outputDirStr = DEFAULT_OUTPUT_DIR;
		Path outputDir = Paths.get(outputDirStr);
		
		// Setup thread pool
//		ExecutorService threadPool = Executors.newFixedThreadPool(NUMBER_OF_THREADS);
//		ExecutorService threadPool = Executors.newCachedThreadPool();
		
		String cutoffDateVal = line.getOptionValue("public_domain_date");
		
		// Run !
		if (line.hasOption("input_dir")) {
			Path inputDir = Paths.get(line.getOptionValue("input_dir"));
			Iterator<Path> inputFileIterator = null;
			long total = 0;
			try {
				inputFileIterator = Files.newDirectoryStream(inputDir).iterator();
				total = inputDir.toFile().listFiles().length;
			} catch (IOException e) {
				dieHelpfully("Couldn't list the input files");
			}
			int cur = 0;
			while (inputFileIterator.hasNext()) {
				Path curIn = inputFileIterator.next();
				if (! Files.isRegularFile(curIn)) {
					continue;
				}
				Path curOut = Paths.get(outputDir.toString(), curIn.getFileName() + suffix );
				System.out.print(String.format("[%d/%d] Converting %s -> %s.\r", ++cur, total, curIn, curOut));
				Dm2e2Edm worker = 
						null == cutoffDateVal
						? new Dm2e2Edm(curIn, inFormat, curOut, outFormat)
						: new Dm2e2Edm(curIn, inFormat, curOut, outFormat, DateTime.parse(cutoffDateVal));
				//			threadPool.execute(worker);
				worker.run();
			}
			System.out.println();
		} else {
			for (String filename : line.getOptionValues("input_file")) {
				Path curIn = Paths.get(filename);
				Path curOut = Paths.get(outputDir.toString(), curIn.getFileName() + suffix );
				System.out.print(String.format("Converting %s -> %s.\r", curIn, curOut));
				Dm2e2Edm worker = 
						null == cutoffDateVal
						? new Dm2e2Edm(curIn, inFormat, curOut, outFormat)
						: new Dm2e2Edm(curIn, inFormat, curOut, outFormat, DateTime.parse(cutoffDateVal));
				worker.run();
			}
		}
//		System.out.println("Shutting down thread pool.");
//		threadPool.shutdown();
//		System.out.println("Shut down thread pool.");
//		try {
//			System.out.println("Wait for workers to finish.");
//			threadPool.awaitTermination(Long.MAX_VALUE, TimeUnit.NANOSECONDS);
//			System.out.println("Workers finished.");
//		} catch (InterruptedException e) {
//			e.printStackTrace();
//		}
		System.exit(0);
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
			
			if (line.hasOption("help")) {
				HelpFormatter formatter = new HelpFormatter();
				formatter.setWidth(100);
				formatter.printHelp("java -jar dm2e2edm.jar --input_file <input_file> | --input_dir <input_dir> [options]",
						"Convert DM2E to EDM",
						getOptions(),
						""
						);
				System.exit(0);
			} else if (! line.hasOption("input_dir") && ! line.hasOption("input_file")) {
				dieHelpfully("Must set either 'input_dir' or 'input_file'");
			} else if (line.hasOption("input_dir")) {
				// --input_dir
				Path inputDir = Paths.get(line.getOptionValue("input_dir"));
				if (! Files.exists(inputDir)) {
					dieHelpfully("Input dir " + inputDir.toString() + " does not exist", null);
				} else if (! Files.isDirectory(inputDir)) {
					dieHelpfully("Input dir " + inputDir.toString() + " is not a directory", null);
				}
			} else {
				// --input_file
				for (String file : line.getOptionValues("input_file")) {
					Path inputFile = Paths.get(file);
					if (! Files.exists(inputFile)) {
						dieHelpfully("Input File " + inputFile.toString() + " does not exist", null);
					} else if (! Files.isRegularFile(inputFile)) {
						dieHelpfully("Input File " + inputFile.toString() + " is not a regular file", null);
					}
				}
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
			// --cutoff-date
			final String cutoffDateVal = line.getOptionValue("public_domain_date");
			if (null != cutoffDateVal) {
				try {
					DateTime.parse(cutoffDateVal);
				} catch (Exception e) {
					dieHelpfully("Error parsing date value for 'public_domain_date'");
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
			.withDescription("Show help")
			.create("help"));
		options.addOption(OptionBuilder
			.hasArgs()
			.withDescription("Input RDF file")
			.create("input_file"));
		options.addOption(OptionBuilder
			.hasArgs(1)
			.withDescription("Input directory of RDF files")
			.create("input_dir"));
		options.addOption(OptionBuilder
			.hasArgs(1)
			.withArgName("YYYY-MM-DD")
			.withDescription("Cutoff Date for works in the public domain [Default: 0000-01-01]")
			.create("public_domain_date"));
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
