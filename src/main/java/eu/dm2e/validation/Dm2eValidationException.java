package eu.dm2e.validation;

import com.hp.hpl.jena.rdf.model.Property;
import com.hp.hpl.jena.rdf.model.Resource;

public class Dm2eValidationException extends Exception {

	private static final long	serialVersionUID	= 7677223365271547149L;
	private final String		thingUri;
	private final Property		context;

	public String getThingUri() {
		return thingUri;
	}

	protected Dm2eValidationException(Resource res, String msg) {
		this(res, msg, (Property) null);
	}

	protected Dm2eValidationException(Resource res, String msg, Throwable cause) {
		this(res, msg, cause, null);
	}

	protected Dm2eValidationException(Resource res, Throwable cause) {
		this(res, cause, null);
	}

	protected Dm2eValidationException(Resource res, String msg, Property context) {
		super(msg);
		this.thingUri = res.getURI();
		this.context = context;
	}

	protected Dm2eValidationException(Resource res, String msg, Throwable cause, Property context) {
		super(msg, cause);
		this.thingUri = res.getURI();
		this.context = context;
	}

	protected Dm2eValidationException(Resource res, Throwable cause, Property context) {
		super(cause);
		this.thingUri = res.getURI();
		this.context = context;
	}

	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder(super.toString());
		sb.replace(0, getClass().getCanonicalName().length() + 1, "");
		if (null != context) {
			sb.append(" [Context: <");
			sb.append(context.getURI());
			sb.append(">]");
		}
		return sb.toString();
	}
}
