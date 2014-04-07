package eu.dm2e.validation.validator;

import java.util.ArrayList;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import eu.dm2e.validation.Dm2eValidator;

public enum Dm2eValidatorVersion {
	

	V_1_1_REV_1_2(Dm2eValidator_1_1_Rev_1_2.class),
	V_1_1_REV_1_3(Dm2eValidator_1_1_Rev_1_3.class),
	V_1_1_REV_1_4(Dm2eValidator_1_1_Rev_1_4.class),
	V_1_1_REV_1_5(Dm2eValidator_1_1_Rev_1_5.class),
	V_1_1_REV_1_6(Dm2eValidator_1_1_Rev_1_6.class),
	V_1_1_FINAL(Dm2eValidator_1_1_Rev_Final.class),
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
	
	Dm2eValidatorVersion(Class<? extends Dm2eValidator> clazz) {
		try {
			this.validator = clazz.newInstance();
			this.versionString = validator.getVersion();
		} catch (InstantiationException | IllegalAccessException e) {
			final Logger log = LoggerFactory.getLogger(Dm2eValidatorVersion.class);
			log.error("!! Could not instantiate Validator " + name() + " !!");
			e.printStackTrace();
		}
	}
	
	public static String valuesAsTerseString() {
		StringBuilder sb = new StringBuilder();
		ArrayList<Dm2eValidatorVersion> versions1_1 = new ArrayList<>();
		ArrayList<Dm2eValidatorVersion> versions1_2 = new ArrayList<>();
		for (Dm2eValidatorVersion thisVersion : values()) {
			if (thisVersion.getVersionString().startsWith("1.1_Rev")) {
				versions1_1.add(thisVersion);
			} else {
				versions1_2.add(thisVersion);
			}
		}
		if (versions1_1.size() > 0) {
			sb.append("1.1_Rev{");
			int i = 0;
			for (Dm2eValidatorVersion thisVersion : versions1_1) {
				sb.append(thisVersion.getVersionString().substring(7));
				if (i++ < versions1_1.size() -1) sb.append("|");
			}
			sb.append("}");
		}
		if (versions1_2.size() > 0) {
			sb.append(" | 1.2_Rev{");
			int i = 0;
			for (Dm2eValidatorVersion thisVersion : versions1_2) {
				sb.append(thisVersion.getVersionString().substring(7));
				if (i++ < versions1_2.size() -1) sb.append("|");
			}
			sb.append("}");
		}
		return sb.toString();
	}

}
