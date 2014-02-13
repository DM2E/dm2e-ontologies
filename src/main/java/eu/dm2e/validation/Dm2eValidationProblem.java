package eu.dm2e.validation;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.hp.hpl.jena.rdf.model.Resource;


/**
 * A problem with validating data against the DM2E data model.
 * 
 * @author Konstantin Baierer
 *
 */
@SuppressWarnings("serial")
public class Dm2eValidationProblem extends Exception {
	
	private static final Logger log = LoggerFactory.getLogger(Dm2eValidationProblem.class);

	private final String						thingUri;
	private final String						msg;
	private final ValidationLevel				level;
	private final ValidationProblemCategory	category;
	private final Object[]						things;

	//
	// Getters
	//
	
	/**
	 * @return the URI of the thing that has the problem as a String.
	 */
	public String getThingUri() {
		return thingUri;
	}
	
	/**
	 * @return the {@link ValidationLevel} of this problem.
	 */
	public ValidationLevel getLevel() {
		return level;
	}
	
	/**
	 * @return the {@link ValidationProblemCategory} of this problem.
	 */
	public ValidationProblemCategory getCategory() {
		return category;
	}

	public Object[] getThings() {
		return things;
	}
	
	public Object getFirstThing() {
		return things.length > 0 ? things[0] : null;
	}

	//
	// Constructor
	//

	protected Dm2eValidationProblem(ValidationLevel level, ValidationProblemCategory category, Resource thing, Object... things) {
		this.category = category;
		this.thingUri = thing.toString();
		this.things = things;
		this.msg = String.format(category.getMsg(), things);
		this.level = level;
	}

	//
	// toString
	//

	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder(msg);
//		sb.replace(0, Dm2eValidationProblem.class.getCanonicalName().length()+2, "");
//		if (null != context) {
//			sb.append("[ Context: ");
//			sb.append(context);
//			sb.append("]");
//		}
		return sb.toString();
	}	
	
	//
	// hashCode and equals
	//


	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((category == null) ? 0 : category.hashCode());
		result = prime * result + ((level == null) ? 0 : level.hashCode());
		result = prime * result + ((msg == null) ? 0 : msg.hashCode());
		result = prime * result + ((thingUri == null) ? 0 : thingUri.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj) return true;
		if (obj == null) return false;
		if (getClass() != obj.getClass()) return false;
		Dm2eValidationProblem other = (Dm2eValidationProblem) obj;
		if (category != other.category) return false;
		if (level != other.level) return false;
		if (msg == null) {
			if (other.msg != null) return false;
		} else if (!msg.equals(other.msg)) return false;
		if (thingUri == null) {
			if (other.thingUri != null) return false;
		} else if (!thingUri.equals(other.thingUri)) return false;
		return true;
	}



}