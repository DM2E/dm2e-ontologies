package eu.dm2e.validation;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
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
	
	private void add(ValidationLevel level, Resource res, String msg, Set<Resource> values, Object context) {
		StringBuilder sb = new StringBuilder(msg);
		if (null != values) {
			sb.append(" ");
			Iterator<Resource> valueIter = values.iterator();
			while (valueIter.hasNext()) {
				Resource val = valueIter.next();
				sb.append(val.toString());
				if (valueIter.hasNext())
					sb.append(", ");
			}
		}
		this.problemSet.add(new Dm2eValidationProblem(level, res, sb.toString(), context));
	}

	public void addError(Resource res, String msg) {
		this.add(ValidationLevel.ERROR, res, msg, null, null);
	}
	public void addError(Resource res, String msg, Object context) {
		this.add(ValidationLevel.ERROR, res, msg, null, context);
	}
	public void addError(Resource res, String msg, Set<Resource> value) {
		this.add(ValidationLevel.ERROR, res, msg, value, null);
	}
	public void addError(Resource res, String msg, Set<Resource> value, Object context) {
		this.add(ValidationLevel.ERROR, res, msg, value, context);
	}
	public void addWarning(Resource res, String msg) {
		this.add(ValidationLevel.WARNING, res, msg, null, null);
	}
	public void addWarning(Resource res, String msg, Object context) {
		this.add(ValidationLevel.WARNING, res, msg, null, context);
	}
	public void addWarning(Resource res, String msg, Set<Resource> value) {
		this.add(ValidationLevel.WARNING, res, msg, value, null);
	}
	public void addWarning(Resource res, String msg, Set<Resource> value, Object context) {
		this.add(ValidationLevel.WARNING, res, msg, value, context);
	}
	public void addNotice(Resource res, String msg) {
		this.add(ValidationLevel.NOTICE, res, msg, null, null);
	}
	public void addNotice(Resource res, String msg, Object context) {
		this.add(ValidationLevel.NOTICE, res, msg, null, context);
	}
	public void addNotice(Resource res, String msg, Set<Resource> value) {
		this.add(ValidationLevel.NOTICE, res, msg, value, null);
	}
	public void addNotice(Resource res, String msg, Set<Resource> value, Object context) {
		this.add(ValidationLevel.NOTICE, res, msg, value, context);
	}
	
	@Override
	public String toString() {
		return exportToString(ValidationLevel.NOTICE);
	}

	/**
	 * Export the set of {@link Dm2eValidationProblem}s as a String.
	 * @param minimumLevel the minimum {@link ValidationLevel} problems must have to be included
	 * @return the string representation of this report
	 */
	public String exportToString(ValidationLevel minimumLevel) {
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
						sbPerUri.append("\t[");
						sbPerUri.append(exc.getLevel().name().toUpperCase());
						sbPerUri.append("]\t");
						sbPerUri.append(exc.toString());
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
