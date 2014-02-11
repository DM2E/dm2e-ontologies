package eu.dm2e.validation;

/**
 * Level of severity of {@link Dm2eValidationProblem}s. 
 * 
 * @author Konstantin Baierer
 *
 */
public enum ValidationLevel {
	/**
	 * A notice: Something weird
	 */
	NOTICE,
	/**
	 * A warning: Missing recommended properties
	 */
	WARNING,
	/**
	 * An error: Missing mandatory properties, wrong ranges
	 */
	ERROR,
	;

}
