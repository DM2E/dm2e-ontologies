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
	

	private static final ValidationLevel	DEFAULT_LEVEL	= ValidationLevel.NOTICE;
	private static final String	DEFAULT_FORMAT	= "RDF/XML";

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

		// Model version
		final String version = line.getOptionValue("version");

		// Input format
		String format = (null == line.getOptionValue("format"))
				? DEFAULT_FORMAT
				: line.getOptionValue("format");
		
		// Minimum level
		final ValidationLevel level = (null == line.getOptionValue("level"))
				? DEFAULT_LEVEL
				: ValidationLevel.valueOf(line.getOptionValue("level"));

		// Output file suffix
		final String outputFileSuffix = (null == line.getOptionValue("suffix"))
				? ".validation." + version + ".txt"
                : line.getOptionValue("suffix") ;
		
		// Terse
		boolean terse = line.hasOption("terse");

		// Whether to write to stdout
		final boolean writeToStdout = line.hasOption("stdout");
		
		// Input files
		final List fileList = line.getArgList();

		//
		// Do the main work
		//
		Dm2eValidator validator = Dm2eSpecificationVersion.forString(version).getValidator();
		int numberOfFiles = fileList.size();
		int currentFile = 0;
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

			if (writeToStdout) {
				System.out.println(report.exportToString(level, true, terse));
				System.err.println("DONE validating " + fileName);
			} else {
				final String outputFileName = fileName + outputFileSuffix;
				File outfile = new File(outputFileName);
				try {
					FileUtils.writeStringToFile(outfile, report.exportToString(level, true, terse));
				} catch (IOException e) {
					dieHelpfully("Error writing file to output file", e);
				}
				StringBuilder sb = new StringBuilder();
				sb.append("DONE [");
				sb.append(++currentFile);
				sb.append("/");
				sb.append(numberOfFiles);
				sb.append("]");
				sb.append("[");
				sb.append(report.getHighestLevel().name());
				sb.append("] See '");
				sb.append(outputFileName);
				sb.append("'.");
				System.err.println(sb.toString());
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
					case DEFAULT_FORMAT:
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
			formatter.setWidth(100);
			formatter.printHelp("java -jar dm2e-validate.jar [options] <file> [<file>...]", getOptions());
		}
		throw new RuntimeException();
	}

	@SuppressWarnings("static-access")
	private static Options getOptions() {
		Options options = new Options();
		
		StringBuilder versionSB = new StringBuilder();
		for (Dm2eSpecificationVersion validatorVersion : Dm2eSpecificationVersion.values()) {
			versionSB.append(validatorVersion.getVersionString());
			if (validatorVersion.ordinal() < Dm2eSpecificationVersion.values().length -1)
				versionSB.append(" | ");
		}
		StringBuilder levelSB = new StringBuilder();
		for (ValidationLevel thisLevel : ValidationLevel.values()) {
			levelSB.append(thisLevel.name());
			if (thisLevel.ordinal() < ValidationLevel.values().length -1)
				levelSB.append(" | ");
		}
		options.addOption(OptionBuilder
			.hasArgs(1)
			.withArgName(versionSB.toString())
			.withDescription("DM2E Data Model version [REQUIRED]")
			.isRequired()
			.create("version"));
		options.addOption(OptionBuilder
			.hasArgs(1)
			.withArgName(levelSB.toString())
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
