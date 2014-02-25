package eu.dm2e.validation;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.util.Map;
import java.util.Set;

import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.Property;
import com.hp.hpl.jena.rdf.model.Resource;

import eu.dm2e.NS;

public interface Dm2eValidator {


	//
	// Model Version
	//
	public String getVersion();

	//
	// Validation methods for individual classes
	//

	/**
	 * Validate a {@link NS.EDM.CLASS_WEBRESOURCE} against the requirements (p.44-53)
	 * 
	 * @param m
	 *            the Jena Model that contains the data
	 * @param wr
	 *            the WebResource Jena Resource
	 * @param prop
	 *            the property that referred to this WebResource
	 * @param report
	 *            the ValidationReport
	 */
	public void validate_edm_WebResource(Model m, Resource wr, Dm2eValidationReport report);

	/**
	 * Validate an Annotable {@link NS.EDM.CLASS_WEBRESOURCE} against the requirements, i.e. it needs a dc:format.
	 * 
	 * @param m
	 *            the Jena Model that contains the data
	 * @param wr
	 *            the WebResource Jena Resource
	 * @param prop
	 *            the property that referred to this WebResource
	 * @param report
	 *            the ValidationReport
	 */
	public void validate_Annotatable_edm_WebResource(Model m, Resource wr, Dm2eValidationReport report);

	/**
	 * Validate an {@link NS.EDM.CLASS_TIMESPAN}
	 * @param m
	 * @param ts
	 * @param prop
	 * @param report
	 */
	public void validate_edm_TimeSpan(Model m, Resource ts, Dm2eValidationReport report);

	/**
	 * Validate that all date-like properties of this resource conform to the model
	 * @param m
	 * @param res
	 * @param report
	 */
	public void validate_DateLike(Model m, Resource res, Dm2eValidationReport report);

	/**
	 * Validate a {@link NS.EDM.CLASS_PROVIDED_CHO} against the requirements (p.25-42)
	 * 
	 * @param m
	 *            the {@link Model} containing the data
	 * @param cho
	 *            the CHO {@link Resource}
	 * @param report
	 *            the {@link Dm2eValidationReport} to write to
	 */
	public void validate_edm_ProvidedCHO(Model m, Resource cho, Dm2eValidationReport report);

	/**
	 * Validate an {@link NS.ORE.CLASS_AGGREGATION} against the requirements (p.16-24)
	 * 
	 * @param m
	 *            the Jena {@link Model} that contains the data
	 * @param agg
	 *            the {@link Resource} of the Aggregation
	 * @param report
	 *            the {@link Dm2eValidationReport} to write to
	 */
	public void validate_ore_Aggregation(Model m, Resource agg, Dm2eValidationReport report);
	
	
	// ***************************************************
	//
	// Sets of Properties and Maps of Properties to Ranges
	//
	// ***************************************************
	
	//
	// Generic
	//

	/**
	 * @return the properties that can link to a timespan or an xsd:dateTime
	 *         literal
	 * @param m
	 */
	public Set<Property> build_DateLike_Properties(Model m);

	//
	// CHO
	//

	/**
	 * @return a set of all required CHO properties
	 * @param m
	 */
	public Set<Property> build_edm_ProvidedCHO_Mandatory_Properties(Model m);

	/**
	 * @return the strongly recommended properties of an {@link NS.EDM.CLASS_PROVIDED_CHO}
	 * @param m
	 *            the {@link Model}
	 */
	public Set<Property> build_edm_ProvidedCHO_Recommended_Properties(Model m);

	/**
	 * @return a set of non-repeatable properties of this ProvidedCHO
	 * @param m the {@link Model}
	 */
	public Set<Property> build_edm_ProvidedCHO_FunctionalProperties(Model m);

	/**
	 * @return a map of CHO object properties with to their allowed ranges
	 * @param m the {@link Model}
	 */
	public Map<Property, Set<Resource>> build_edm_ProvidedCHO_ObjectPropertyRanges(Model m);

	/**
	 * @return a map of CHO literal properties with to their allowed ranges
	 * @param m the {@link Model}
	 */
	public Map<Property, Set<Resource>> build_edm_ProvidedCHO_LiteralPropertyRanges(Model m);
	
	//
	// Aggregation
	//

	/**
	 * @return the required properties of an {@link NS.ORE.AGGREGATION}
	 * @param m
	 *            the {@link Model}
	 */
	public Set<Property> build_ore_Aggregation_Mandatory_Properties(Model m);

	/**
	 * @return the strongly recommended properties of an {@link NS.ORE.AGGREGATION}
	 * @param m
	 *            the {@link Model}
	 */
	public Set<Property> build_ore_Aggregation_Recommended_Properties(Model m);

	/**
	 * @return a set of those properties whose range are annotatable {@link NS.EDM.CLASS_WEBRESOURCE}
	 * @param m
	 */
	public Set<Property> build_ore_Aggregation_AnnotatableWebResource_Properties(Model m);


	/**
	 * @return a map of ore:Aggregation object properties with to their allowed ranges
	 * @param m the {@link Model}
	 */
	public Map<Property, Set<Resource>> build_ore_Aggregation_ObjectPropertyRanges(Model m);

	/**
	 * @return a map of ore:Aggregation literal properties with to their allowed ranges
	 * @param m the {@link Model}
	 */
	public Map<Property, Set<Resource>> build_ore_Aggregation_LiteralPropertyRanges(Model m);
	
	/**
	 * @return a set of non-repeatable properties of an Aggregation
	 * @param m the {@link Model}
	 */
	public Set<Property> build_ore_Aggregation_FunctionalProperties(Model m);

	//
	// TimeSpan
	//

	/**
	 * @return the mandatory properties for an {@link NS.EDM.CLASS_TIMESPAN}
	 * @param m
	 */
	public Set<Property> build_edm_TimeSpan_Mandatory_Properties(Model m);

	/**
	 * @return the recommended properties for an {@link NS.EDM.CLASS_WEBRESOURCE}
	 * @param m
	 */
	public Set<Property> build_edm_WebResource_Recommended_Properties(Model m);
	
	// ****************
	//
	// Public Interface
	//
	// ****************
	

	/**
	 * Validates the RDF data in a file against the DM2E data model
	 * @param fileName
	 * @param rdfLang
	 * @return
	 * @throws FileNotFoundException
	 */
	public Dm2eValidationReport validateWithDm2e(String fileName, String rdfLang) throws FileNotFoundException;

	/**
	 * @param rdfData
	 * @param rdfLang
	 * @return
	 * @throws FileNotFoundException
	 */
	public Dm2eValidationReport validateWithDm2e(File rdfData, String rdfLang) throws FileNotFoundException;

//	public Dm2eValidationReport validateWithDm2e(InputStream filePart, String rdfLang) {
//		
//	}
	/**
	 * Validates all resources within a Jena Model against the DM2E data
	 * model
	 * 
	 * @param m
	 *            the Jena Model that contains the data
	 * @return A {@link Dm2eValidationReport}
	 */
	public Dm2eValidationReport validateWithDm2e(Model m);

	/**
	 * Validate all instances of the specified class within this Model against the Dm2e data model
	 * @param m the Jena {@link Model}
	 * @param currentClassUri the ontology class to validate
	 * @param report the report
	 */
	public void validateWithDm2e(Model m, String currentClassUri, Dm2eValidationReport report);

	public void validateUnknownProperties(Model m, Dm2eValidationReport report);



}