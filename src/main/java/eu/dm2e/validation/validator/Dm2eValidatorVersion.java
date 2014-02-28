package eu.dm2e.validation.validator;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import eu.dm2e.validation.Dm2eValidator;

public enum Dm2eValidatorVersion {
	

	V_1_1_REV_1_2(Dm2eValidator_1_1_Rev_1_2.class, "1.1_Rev1.2"),
	V_1_1_REV_1_3(Dm2eValidator_1_1_Rev_1_3.class, "1.1_Rev1.3"),
	V_1_1_REV_1_4(Dm2eValidator_1_1_Rev_1_4.class, "1.1_Rev1.4"),
	V_1_1_REV_1_5(Dm2eValidator_1_1_Rev_1_5.class, "1.1_Rev1.5-DRAFT"),
	;
	
	public static Dm2eValidatorVersion forString(String versionStr) throws NoSuchFieldException 
	{
		Dm2eValidatorVersion foundSpecVersion = null;
		try {
			foundSpecVersion = Dm2eValidatorVersion.valueOf(versionStr);
		} catch (Exception e) { }
		for (Dm2eValidatorVersion needle : Dm2eValidatorVersion.values()) {
			if (needle.getVersionString().equals(versionStr)) {
				foundSpecVersion = needle;
				break;
			}
		}
		if (null == foundSpecVersion) {
			throw new NoSuchFieldException("Unknown version " + versionStr);
		}
		return foundSpecVersion;
	}

	private Dm2eValidator validator;
	private String	versionString;
	
	public String getVersionString() {
		return versionString;
	}
	
	public Dm2eValidator getValidator() {
		return validator;
	}
	
	Dm2eValidatorVersion(Class<? extends Dm2eValidator> clazz, String versionString) {
		this.versionString = versionString;
		try {
			this.validator = clazz.newInstance();
		} catch (InstantiationException | IllegalAccessException e) {
			final Logger log = LoggerFactory.getLogger(Dm2eValidatorVersion.class);
			log.error("!! Could not instantiate Validator " + name() + " !!");
			e.printStackTrace();
		}
	}

}
