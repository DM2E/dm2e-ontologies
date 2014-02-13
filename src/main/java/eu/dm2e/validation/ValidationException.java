package eu.dm2e.validation;

@SuppressWarnings("serial")
public class ValidationException extends Exception {

	private final Dm2eValidationReport	report;
	
	public Dm2eValidationReport getReport() {
		return report;
	}

	public ValidationException(Dm2eValidationReport report) {
		this.report = report;
	}
	
	@Override
	public String toString() {
		return report.toString();
	}

}
