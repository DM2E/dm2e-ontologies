package eu.dm2e.validation;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import com.hp.hpl.jena.rdf.model.Property;
import com.hp.hpl.jena.rdf.model.Resource;

public class Dm2eValidationReport {
	
	private final Set<Dm2eValidationException> errorList;
	private String	modelVersion;
	
	public Dm2eValidationReport(String modelVersion) {
		this.modelVersion = modelVersion;
		this.errorList = new HashSet<>();
	}

	public void add(Resource res, String msg) {
		this.errorList.add(new Dm2eValidationException(res, msg));
	}
	public void add(Resource res, String msg, Property prop) {
		this.errorList.add(new Dm2eValidationException(res, msg, prop));
	}
	
	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder();
		sb.append("Validation Report");
		sb.append(" (according to version ");
		sb.append(modelVersion);
		sb.append(")\n");
		for (int i = 0 ; i < 80 ; i++) sb.append('-');
		sb.append("\n\n");
		if (errorList.isEmpty()) {
			sb.append("Everything is hunky dory.");
		} else {
			Map<String, Set<Dm2eValidationException>> failedURIs = partitionByUri();
			for (Entry<String, Set<Dm2eValidationException>> entry: failedURIs.entrySet()) {
				sb.append("<");
				sb.append(entry.getKey());
				sb.append(">");
				sb.append(": \n");
				for (Dm2eValidationException exc : entry.getValue()) {
					sb.append("\t");
					sb.append(exc.toString());
					sb.append("\n");
				}
			}
		}
		return sb.toString();
	}

	private Map<String,Set<Dm2eValidationException>> partitionByUri() {
		Map<String,Set<Dm2eValidationException>> retMap = new HashMap<>();
		for (Dm2eValidationException exc : errorList) {
			if (! retMap.containsKey(exc.getThingUri())) {
				retMap.put(exc.getThingUri(), new HashSet<Dm2eValidationException>());
			}
			retMap.get(exc.getThingUri()).add(exc);
		}
		return retMap;
	}
}
