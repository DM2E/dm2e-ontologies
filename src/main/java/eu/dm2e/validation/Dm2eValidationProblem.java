package eu.dm2e.validation;

import com.hp.hpl.jena.rdf.model.Property;
import com.hp.hpl.jena.rdf.model.Resource;

/**
 * A problem with validating data against the DM2E data model.
 * 
 * @author Konstantin Baierer
 *
 */
public class Dm2eValidationProblem extends Exception {

	private static final long		serialVersionUID	= -5230774122416088740L;
	protected final String			thingUri;
	protected final Object			context;
	protected final ValidationLevel	level;
	protected final String			msg;

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

	protected Dm2eValidationProblem(ValidationLevel level, Resource res, String msg) {
		this(level, res, msg, (Property) null);
	}

	protected Dm2eValidationProblem(ValidationLevel level, Resource res, String msg, Throwable cause) {
		this(level, res, msg, cause, null);
	}

	protected Dm2eValidationProblem(ValidationLevel level, Resource res, String msg, Object context) {
		super(msg);
		this.msg = msg;
		this.thingUri = res.getURI();
		this.context = context;
		this.level = level;
	}

	protected Dm2eValidationProblem(ValidationLevel level, Resource res, String msg, Throwable cause, Object context) {
		super(msg, cause);
		this.msg = msg;
		this.thingUri = res.getURI();
		this.context = context;
		this.level = level;
	}

	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder(super.toString());
		sb.replace(0, Dm2eValidationProblem.class.getCanonicalName().length()+2, "");
		if (null != context) {
			sb.append("[ Context: ");
			sb.append(context);
			sb.append("]");
		}
		return sb.toString();
	}


	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((context == null) ? 0 : context.hashCode());
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
		if (context == null) {
			if (other.context != null) return false;
		} else if (!context.equals(other.context)) return false;
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