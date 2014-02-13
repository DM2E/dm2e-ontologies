package eu.dm2e.validation;

import static org.fest.assertions.Assertions.*;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.rdf.model.Property;
import com.hp.hpl.jena.rdf.model.Resource;

import eu.dm2e.NS;
import eu.dm2e.validation.validator.Dm2eValidator_1_1_Rev_1_2;
import eu.dm2e.validation.validator.Dm2eValidator_1_1_Rev_1_3;

public class ValidationTest {
	
	private static final Logger log = LoggerFactory.getLogger(ValidationTest.class);

	//
	// Validators
	//

	protected static Dm2eValidator v1_1_rev1_2 = new Dm2eValidator_1_1_Rev_1_2();
	protected static Dm2eValidator v1_1_rev1_3 = new Dm2eValidator_1_1_Rev_1_3();

	//
	// Utility
	//
	
	protected Model newModel() {
		return ModelFactory.createDefaultModel();
	}

	protected static Resource res(Model m, String uri) {
		return m.createResource(uri);
	}

	protected static Property prop(Model m, String uri) {
		return m.createProperty(uri);
	}

	protected static Property isa(Model m) {
		return prop(m, NS.RDF.PROP_TYPE);
	}

	protected static boolean isa(Model m, Resource res, String type) {
		if (m.contains(res, isa(m), res(m, type))) {
			return true;
		}
		return false;
	}

	protected void containsCategory(Dm2eValidationReport report, ValidationProblemCategory expected) {
		final String exportToString = report.exportToString(ValidationLevel.NOTICE, false, true);
		assertThat(exportToString).contains(expected.name());
	}

	protected void doesNotContainCategory(Dm2eValidationReport report, ValidationProblemCategory expected) {
		final String exportToString = report.exportToString(ValidationLevel.NOTICE, false, true);
		assertThat(exportToString).doesNotContain(expected.name());
	}

	protected void logReport(Dm2eValidationReport report) {
		log.debug(report.exportToString(ValidationLevel.NOTICE, true, true));
	}

}
