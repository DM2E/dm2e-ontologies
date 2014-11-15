package eu.dm2e.validation;

public enum ValidationProblemCategory {
	
	MISMATCH_OF_DATASET_ID("Dataset ID of CHO '%s' doesn't match Ingestion Dataset '%s'."),
	IRRETRIEVABLE_DATASET_ID("Couldn't determine the dataset by parsing URLS for input '%s'."),
	
	MISSING_REQUIRED_PROPERTY(" is missing required property <%s>"),
	MISSING_RECOMMENDED_PROPERTY(" is missing strongly recommended property <%s>"),
	MISSING_CONDITIONALLY_REQUIRED_PROPERTY(" is missing required property <%s> (Condition: %s)"),
	MISSING_REQUIRED_ONE_OF(" is missing one of %s"),
	MISSING_CONDITIONALLY_REQUIRED_ONE_OF(" is missing required property <%s> (Condition: %s)"),
	
	UNTYPED_RESOURCE(" has no rdf:type."),

	INVALID_LITERAL(" Invalid literal value for <%s>: '%s' (%s)"),
	BAD_MIMETYPE(" has unsupported MIME type '%s'."),
	ILLEGALLY_UNTYPED_LITERAL(" illegally has untyped literal for property <%s>. Allowed values: %s"),
	UNTYPED_LITERAL(" has untyped literal for property <%s>."),
	SHOULD_BE_LITERAL(" has property <%s> which should be a literal but is a resource."),
	INVALID_DATA_PROPERTY_RANGE(" has data property with invalid datatype <%s>. Allowed rdf:datatype: %s"),
	INVALID_XSD_DATETIME(" has invalid xsd:datetime literal value '%s'"), 

	INVALID_OBJECT_PROPERTY_RANGE(" has object property with incompatible resource <%s>. Allowed rdf:type: %s"),
	SHOULD_BE_RESOURCE(" has property <%s> which should be a resource but is a literal."),
	NON_REPEATABLE(" repeats non-repeatable property <%s>"),
	MISC(" has specific Problem: %s"),
	FORBIDDEN_PROPERTY(" has forbidden property <%s>"),
	UNKNOWN_PROPERTY(" has unknown property <%s>"),
	RELATIVE_URL(" is a relative URL used with property <%s>"),
	INVALID_DC_TYPE(" uses an unknown dc:type <%s>"),
	
	ILLEGAL_URI_CHARACTER(" uses illegal URI character '%s'"),
	UNWISE_URI_CHARACTER(" uses unwise URI character '%s'"),
	LITERAL_NOT_IN_NFC(" has literal value for prop <%s> not in Unicode Normalization Form C: '''%s'''"),
	;
	
	private String msg;
	public String getMsg() {
		return msg;
	}
	private ValidationProblemCategory(String msg) {
		this.msg = msg;
	}
	

}
