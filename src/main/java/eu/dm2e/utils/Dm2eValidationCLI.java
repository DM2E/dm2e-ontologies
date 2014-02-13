package eu.dm2e.utils;

import java.io.File;
import java.io.IOException;
import java.util.List;

import org.apache.commons.cli.BasicParser;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.io.FileUtils;
import org.apache.jena.riot.RiotException;

import eu.dm2e.validation.Dm2eValidationReport;
import eu.dm2e.validation.Dm2eValidator;
import eu.dm2e.validation.ValidationLevel;
import eu.dm2e.validation.validator.Dm2eSpecificationVersion;

public class Dm2eValidationCLI {
	

	/**
	 * Main method
	 * <p>
	 * Usage is:
	 * <code>$invocation [--format N-TRIPLE] [--level NOTICE] [--stdout] [--suffix '.validation.txt'] file1.ttl file2.ttl ...</code>
	 * </p>
	 * 
	 * @param args
	 *            the command line arguments
	 * @throws Exception 
	 */
	public static void main(String[] args) throws Exception {
		try {
			executeMain(args);
		} catch (RuntimeException e) {
			// Do nothing it has been handled
		} catch (Exception e) {
			e.printStackTrace();
			dieHelpfully("NOT CAUGHT", e);
		}
	}

	private static void executeMain(String[] args) throws Exception {

		// Parse options
		CommandLine line = parseOptions(args);

		// Input format
		String format = "RDF/XML";
		String formatArg = line.getOptionValue("format");
		if (null != formatArg) format = formatArg;
		
		// Model version
		String version = line.getOptionValue("version");

		// Minimum level
		ValidationLevel level = ValidationLevel.NOTICE;
		String levelArg = line.getOptionValue("level");
		if (null != levelArg) level = ValidationLevel.valueOf(levelArg);
		
		// Terse
		boolean terse = line.hasOption("terse");

		// Input files
		final List fileList = line.getArgList();

		//
		// Do the main work
		//
		Dm2eValidator validator = Dm2eSpecificationVersion.forString(version).getValidator();
		for (Object fileArg : fileList) {
			String fileName = new File(fileArg.toString()).getAbsolutePath();
			Dm2eValidationReport report = null;

			try {
				report = validator.validateWithDm2e(fileName, format);
			} catch (RiotException e) {
				dieHelpfully("Jena croaked on file " + fileName + ". Are you sure it is '" + format + "'. ", e);
			} catch (Exception e) {
				throw e;
			}

			if (line.hasOption("stdout")) {
				System.out.println(report.exportToString(level, true, terse));
				System.err.println("DONE validating " + fileName);
			} else {
				String suffixVal = line.getOptionValue("suffix");
				if (null == suffixVal) suffixVal = ".validation." + version + ".txt";
				File outfile = new File(fileName + suffixVal);
				try {
					FileUtils.writeStringToFile(outfile, report.exportToString(level, true, terse));
				} catch (IOException e) {
					dieHelpfully("Error writing file to output file", e);
				}
				System.err.println("DONE validating " + fileName + ". Output written to " + outfile.getPath() + ".");
			}
		}
	}

	private static CommandLine parseOptions(String[] args) throws ParseException {
		// Get the options
		Options options = getOptions();

		// create the parser
		CommandLineParser parser = new BasicParser();
		CommandLine line = null;
		// parse the command line arguments
		try {
			line = parser.parse(options, args);
			String formatArg = line.getOptionValue("format");
			if (null != formatArg) {
				switch(formatArg) {
					case "RDF/XML":
					case "TURTLE":
					case "N-TRIPLE":
						break;
					default:
						throw new ParseException("Invalid format arg '" + formatArg + "'. ");
				}
			}
			String levelArg = line.getOptionValue("level");
			if (null != levelArg) {
				try {
					ValidationLevel.valueOf(levelArg);
				} catch (IllegalArgumentException e) {
					throw new ParseException("Invalid validation level '" + levelArg +"'");
				}
			}
			String versionArg = line.getOptionValue("version");
			try {
				Dm2eSpecificationVersion.forString(versionArg);
			} catch (NoSuchFieldException e) {
				throw new ParseException("Unrecognized version string '" + versionArg +"'");
			} 
			if (line.getArgList().size() == 0) {
				throw new ParseException("No files given");
			}
			for (Object fileName: line.getArgList()) {
				if (! new File((String) fileName).exists()) {
					throw new ParseException("File does not exist: " + fileName);
				}
			}
		} catch (ParseException e) {
			dieHelpfully("Error parsing command line options: ", e, true);
		}
		return line;
	}
	
	private static void dieHelpfully(String msg, Exception e) { dieHelpfully(msg, e, false); }
	private static void dieHelpfully(String msg, Exception e, boolean showUsage) {
		System.err.print("!! ");
		if (msg != null) System.err.print(msg + " ");
		System.err.println(e.getMessage());
		if (showUsage) {
			HelpFormatter formatter = new HelpFormatter();
			formatter.printHelp("dm2e-validate [options] <file> [<file>...]", getOptions());
		}
		throw new RuntimeException();
	}

	@SuppressWarnings("static-access")
	private static Options getOptions() {
		Options options = new Options();
		
		StringBuilder sb = new StringBuilder();
		for (Dm2eSpecificationVersion validatorVersion : Dm2eSpecificationVersion.values()) {
			sb.append(validatorVersion.getVersionString());
			sb.append(" | ");
		}
		sb.replace(sb.length() - " | ".length(), sb.length(), "");
		options.addOption(OptionBuilder
			.hasArgs(1)
			.withArgName(sb.toString())
			.withDescription("DM2E Data Model version [REQUIRED]")
			.isRequired()
			.create("version"));
		options.addOption(OptionBuilder
			.hasArgs(1)
			.withArgName("NOTICE | WARNING | ERROR")
			.withDescription("Minimum Validation level [Default: NOTICE]")
			.create("level"));
		options.addOption(OptionBuilder
			.hasArgs(1)
			.withArgName("RDF/XML | N-TRIPLE | TURTLE")
			.withDescription("RDF input serialization format [Default: RDF/XML]")
			.create("format"));
		options.addOption("stdout", false, "Write to STDOUT [Default: false]");
		options.addOption("terse", false, "Output results very terse [Default: false]");
		options.addOption(OptionBuilder
			.hasArgs()
			.withArgName("suffix")
			.withDescription("output file suffix [default: '.validation.${model-version}.txt']")
			.create("suffix"));
		return options;
	}

}
