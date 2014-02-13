package eu.dm2e.validation.validator;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import eu.dm2e.validation.Dm2eValidator;

public enum Dm2eSpecificationVersion {
	

	V_1_1_REV_1_2(Dm2eValidator_1_1_Rev_1_2.class, "1.1_Rev1.2"),
	V_1_1_REV_1_3(Dm2eValidator_1_1_Rev_1_3.class, "1.1_Rev1.3"),
	;
	
	public static Dm2eSpecificationVersion forString(String versionStr) throws NoSuchFieldException 
	{
		Dm2eSpecificationVersion foundSpecVersion = null;
		try {
			foundSpecVersion = Dm2eSpecificationVersion.valueOf(versionStr);
		} catch (Exception e) { }
		for (Dm2eSpecificationVersion needle : Dm2eSpecificationVersion.values()) {
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
	
	Dm2eSpecificationVersion(Class<? extends Dm2eValidator> clazz, String versionString) {
		this.versionString = versionString;
		try {
			this.validator = clazz.newInstance();
		} catch (InstantiationException | IllegalAccessException e) {
			final Logger log = LoggerFactory.getLogger(Dm2eSpecificationVersion.class);
			log.error("!! Could not instantiate Validator " + name() + " !!");
			e.printStackTrace();
		}
	}

}
