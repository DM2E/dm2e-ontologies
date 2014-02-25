package eu.dm2e.validation;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.hp.hpl.jena.rdf.model.Resource;

/**
 * A collection of {@link Dm2eValidationProblem}s with logger-like utility functions.
 *
 * @author Konstantin Baierer
 */
public class Dm2eValidationReport {
	
	@SuppressWarnings("unused")
	private static final Logger log = LoggerFactory.getLogger(Dm2eValidationReport.class);
	
	private final Set<Dm2eValidationProblem> problemSet;
	private String	modelVersion;
	
	public Dm2eValidationReport(String modelVersion) {
		this.modelVersion = modelVersion;
		this.problemSet = new HashSet<>();
	}
	
	public void add(ValidationLevel level, ValidationProblemCategory category, Resource res, Object... things) {
		this.problemSet.add(new Dm2eValidationProblem(level, category, res, things));
	}
//	public void add(ValidationLevel level, ValidationProblemCategory category, Resource res, String msg) {
//		this.problemSet.add(new Dm2eValidationProblem(level, category, res, msg));
//	}

	public boolean containsErrors() {
		return containsErrors(ValidationLevel.ERROR);
	}

    public boolean containsErrors(ValidationLevel level) {
        boolean doesContainErrrors = false;
        for (Dm2eValidationProblem problem : problemSet) {
            if (problem.getLevel() == level) {
                doesContainErrrors = true;
                break;
            }
        }
        return doesContainErrrors;
    }
	
	@Override
	public String toString() {
		return exportToString(ValidationLevel.NOTICE, true, false);
	}
	
	public String exportToString(boolean terse) {
		return exportToString(ValidationLevel.NOTICE, true, terse);
	}

	/**
	 * Export the set of {@link Dm2eValidationProblem}s as a String.
	 * @param minimumLevel the minimum {@link ValidationLevel} problems must have to be included
	 * @param displayLevel whether to display the {@code ValidationLevel}
	 * @param terse whether to show a terse description of the problem without the actual message
	 * @return the string representation of this report
	 */
	public String exportToString(ValidationLevel minimumLevel, boolean displayLevel, boolean terse) {
		StringBuilder sb = new StringBuilder();
		StringBuilder sbPerUri = new StringBuilder();
		sb.append("Validation Report");
		sb.append(" (according to version ");
		sb.append(modelVersion);
		sb.append(")\n");
		for (int i = 0 ; i < 80 ; i++) sb.append('-');
		sb.append("\n\n");
		if (problemSet.isEmpty()) {
			sb.append("Everything is hunky dory.");
		} else {
			Map<String, Set<Dm2eValidationProblem>> failedURIs = partitionByUri();
			for (Entry<String, Set<Dm2eValidationProblem>> entry: failedURIs.entrySet()) {
				sbPerUri.setLength(0);
				boolean doNotSkip = false;
				sbPerUri.append("<");
				sbPerUri.append(entry.getKey());
				sbPerUri.append(">");
				sbPerUri.append(": \n");
				for (Dm2eValidationProblem exc : entry.getValue()) {
					if (exc.getLevel().ordinal() >= minimumLevel.ordinal()) {
						doNotSkip = true;
						if (displayLevel) {
							sbPerUri.append("\t[");
							sbPerUri.append(exc.getLevel().name().toUpperCase());
							sbPerUri.append("]");
						}
						if (terse) {
							sbPerUri.append("\t");
							sbPerUri.append(exc.getCategory());
							sbPerUri.append("\t");
							sbPerUri.append(exc.getFirstThing());
						} else {
							sbPerUri.append("\t");
							sbPerUri.append(exc.toString());
						}
						sbPerUri.append("\n");
					}
				}
				if (doNotSkip) {
					sb.append(sbPerUri);
				}
			}
		}
		return sb.toString();
	}

	/**
	 * Create a map of Sets of problems with URIs as keys so all the problems of a particular URI are in the same place.
	 * @return a map of sets of problems 
	 */
	private Map<String,Set<Dm2eValidationProblem>> partitionByUri() {
		Map<String,Set<Dm2eValidationProblem>> retMap = new HashMap<>();
		for (Dm2eValidationProblem exc : problemSet) {
			if (! retMap.containsKey(exc.getThingUri())) {
				retMap.put(exc.getThingUri(), new HashSet<Dm2eValidationProblem>());
			}
			retMap.get(exc.getThingUri()).add(exc);
		}
		return retMap;
	}


}
