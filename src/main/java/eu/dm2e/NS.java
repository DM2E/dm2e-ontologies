package eu.dm2e;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
//CHECKSTYLE.OFF: JavadocVariable

/**
 * Central list of RDF entities.
 *
 * <p>
 * Every vocabulary is represented by a static final class, which must define
 * a BASE constant (the base URI of the vocabulary) and constants for all entities,
 * (by convention prefixed with CLASS_ for classes and PROP_ for properties).
 * </p>
 *
 * @author Konstantin Baierer
 *
 */
public final class NS {

	/**
	 * Annotation for static fields of static classes to describe their OWL properties.
	 * 
	 * @author Konstantin Baierer
	 */
	@Target(ElementType.FIELD)
	@Retention(RetentionPolicy.RUNTIME)
	public @interface OWLAnnotation {
		/**
		 * @return the rdfs:comment of this element
		 */
		String description();
		
		/**
		 * @return the type of this ontology element. Can be
		 *         {@link NS.OWL.DATATYPE_PROPERTY}, 
		 *         {@link NS.OWL.OBJECT_PROPERTY},
		 *         {@link NS.OWL.INSTANCE},
		 *         {@link NS.OWL.CLASS}
		 */
		String owlType() default NS.OWL.CLASS; // 
		/**
		 * @return the rdf:type of this ontology element. For instances.
		 */
		String rdfType() default NS.OWL.THING;
		/**
		 * @return the rdfs:domain of this property.
		 */
		String domain() default "";
		/**
		 * @return the rdfs:range of this property
		 */
		String[] range() default {};
		/**
		 * @return an optional rdfs:label for this ontology element
		 */
		String label() default "";
		/**
		 * @return whether this element is deprecated.
		 */
		boolean deprecated() default false;
	}

	/**
	 * Single place to collect all OmNom property and class names.
	 *
	 * @author Konstantin Baierer
	 *
	 */
	public static final class OMNOM {
		
		public static final String BASE = "http://onto.dm2e.eu/omnom/";

		@OWLAnnotation(description="A class representing an uploaded file.")
        public static final String CLASS_FILE                 = BASE + "File";

		@OWLAnnotation(description="A class representing a job.")
        public static final String CLASS_JOB                  = BASE + "Job";

		@OWLAnnotation(description="A class representing single entry in the log.")
        public static final String CLASS_LOG_ENTRY            = BASE + "LogEntry";

		@OWLAnnotation(description="A class representing a web service parameter.")
        public static final String CLASS_PARAMETER            = BASE + "Parameter";

		@OWLAnnotation(description="An assignement of a concrete value to a Parameter")
        public static final String CLASS_PARAMETER_ASSIGNMENT = BASE + "ParameterAssignment";

		@OWLAnnotation(description="A connector between input/output of Parameters of two Webservices")
        public static final String CLASS_PARAMETER_CONNECTOR  = BASE + "ParameterConnector";

		@OWLAnnotation(description="A webservice")
        public static final String CLASS_WEBSERVICE           = BASE + "Webservice";

		@OWLAnnotation(description="A configuration of a Webservice, i.e. a set of ParameterAssignments")
        public static final String CLASS_WEBSERVICE_CONFIG    = BASE + "WebserviceConfig";

		@OWLAnnotation(description="A workflow")
        public static final String CLASS_WORKFLOW             = BASE + "Workflow";
        
		@OWLAnnotation( description = "A job representing the execution of a Workflow with a specific configuration.",
				deprecated = true)
		public static final String CLASS_WORKFLOW_JOB = BASE + "WorkflowJob";
        public static final String CLASS_WORKFLOW_POSITION    = BASE + "WorkflowPosition";

		@OWLAnnotation( description = "Links a ParameterAssignment to a WebserviceConfig",
				owlType = NS.OWL.OBJECT_PROPERTY,
				range = NS.OMNOM.CLASS_PARAMETER_ASSIGNMENT,
				domain = NS.OMNOM.CLASS_WEBSERVICE_CONFIG)
		public static final String PROP_ASSIGNMENT          = BASE + "assignment";

		@OWLAnnotation( description = "Default Value for a parameter",
				owlType = NS.OWL.DATATYPE_PROPERTY,
				label = "Default Value",
				range = NS.XSD.STRING)
		public static final String PROP_DEFAULT_VALUE       = BASE + "defaultValue";
		
		@OWLAnnotation(description = "URI that points to a web location where a user can edit this resource.",
				owlType = NS.OWL.DATATYPE_PROPERTY,
				range = NS.XSD.ANY_URI)
		public static final String PROP_FILE_EDIT_URI       = BASE + "fileEditURI";

		@OWLAnnotation(description="The internal file location of a file on the server",
				owlType=NS.OWL.OBJECT_PROPERTY,
				domain=NS.OMNOM.CLASS_FILE,
				range=NS.XSD.STRING)
		public static final String PROP_FILE_LOCATION       = BASE + "internalFileLocation";

		@OWLAnnotation(description="The resolvable URI whence the file contents can be retrieved.",
				owlType=NS.OWL.OBJECT_PROPERTY,
				domain=NS.OMNOM.CLASS_FILE,
				range=NS.XSD.ANY_URI)
		public static final String PROP_FILE_RETRIEVAL_URI  = BASE + "fileRetrievalURI";

		@OWLAnnotation(description="The status of a file. Can be one of AVAILABLE (the file can be retrieved), "
				+ "WAITING (the file is not yet ready) or "
				+ "DELETED (the file was deleted)",
				owlType=NS.OWL.DATATYPE_PROPERTY,
				domain=NS.OMNOM.CLASS_FILE,
				range=NS.XSD.STRING)
		public static final String PROP_FILE_STATUS         = BASE + "fileStatus";

		@OWLAnnotation(description="The file type of a File in terms of the omnom_types ontology.",
				owlType=NS.OWL.OBJECT_PROPERTY,
				domain=NS.OMNOM.CLASS_FILE,
				range=NS.OMNOM_TYPES.CLASS_TYPE
				)
		public static final String PROP_FILE_TYPE           = BASE + "fileType";

		@OWLAnnotation(description="A completeted Webservice Job of this Workflow Job",
				owlType=NS.OWL.OBJECT_PROPERTY,
				domain=NS.OMNOM.CLASS_JOB,
				range=NS.OMNOM.CLASS_JOB)
		public static final String PROP_FINISHED_JOB        = BASE + "finishedJobs";
//		public static final String PROP_FINISHED_POSITION   = BASE + "finishedPositions";

		@OWLAnnotation(description="The Parameter this ParameterAssignment assigns a value for",
				owlType=NS.OWL.OBJECT_PROPERTY,
				domain=NS.OMNOM.CLASS_PARAMETER_ASSIGNMENT,
				range=NS.OMNOM.CLASS_PARAMETER)
		public static final String PROP_FOR_PARAM           = BASE + "forParam";

		@OWLAnnotation(description="To Be Deleted",
				owlType=NS.OWL.OBJECT_PROPERTY,
				deprecated=true)
		public static final String PROP_FOR_SLOT            = BASE + "forSlot";

		@OWLAnnotation(description="The originating Parameter for this ParameterConnector.",
				owlType=NS.OWL.OBJECT_PROPERTY,
				domain=NS.OMNOM.CLASS_PARAMETER_CONNECTOR,
				range=NS.OMNOM.CLASS_PARAMETER)
		public static final String PROP_FROM_PARAM          = BASE + "fromParam";

		@OWLAnnotation(description="The originating WorkflowPosition of this ParameterConnector.",
				owlType=NS.OWL.OBJECT_PROPERTY,
				domain=NS.OMNOM.CLASS_PARAMETER_CONNECTOR,
				range=NS.OMNOM.CLASS_WORKFLOW_POSITION)
		public static final String PROP_FROM_POSITION       = BASE + "fromPosition";

		@OWLAnnotation(description="The originating Workflow of this ParameterConnector.",
				owlType=NS.OWL.OBJECT_PROPERTY,
				domain=NS.OMNOM.CLASS_PARAMETER_CONNECTOR,
				range=NS.OMNOM.CLASS_WORKFLOW)
		public static final String PROP_FROM_WORKFLOW       = BASE + "fromWorkflow";

		@OWLAnnotation(description="An input Parameter for this Webservice",
				owlType=NS.OWL.OBJECT_PROPERTY,
				domain=NS.OMNOM.CLASS_WEBSERVICE,
				range=NS.OMNOM.CLASS_PARAMETER)
		public static final String PROP_INPUT_PARAM         = BASE + "inputParam";

		@OWLAnnotation(description="TODO",
				owlType=NS.OWL.OBJECT_PROPERTY,
				range=NS.OMNOM.CLASS_WORKFLOW)
		public static final String PROP_IN_WORKFLOW         = BASE + "inWorkflow";

		@OWLAnnotation(description="TODO",
				owlType=NS.OWL.DATATYPE_PROPERTY,
				range=NS.XSD.INT)
        public static final String PROP_HAS_ITERATIONS      = BASE + "hasIterations";

		@OWLAnnotation(description="Whether an assignment for this Parameter is required to create a valid WebserviceConfig",
				owlType=NS.OWL.DATATYPE_PROPERTY,
				domain=NS.OMNOM.CLASS_WEBSERVICE,
				range=NS.XSD.BOOLEAN)
        public static final String PROP_IS_REQUIRED         = BASE + "isRequired";

		@OWLAnnotation(description="(MINT) XPath to get the item label.",
				owlType=NS.OWL.DATATYPE_PROPERTY,
				domain=NS.OMNOM.CLASS_FILE,
				range=NS.XSD.STRING)
        public static final String PROP_ITEM_LABEL_XPATH    = BASE + "itemLabelXPath";

		@OWLAnnotation(description="(MINT) XPath to get the item root.",
				owlType=NS.OWL.DATATYPE_PROPERTY,
				domain=NS.OMNOM.CLASS_FILE,
				range=NS.XSD.STRING)
		public static final String PROP_ITEM_ROOT_XPATH     = BASE + "itemRootXPath";

		@OWLAnnotation(description="The temporary ID jobs get assigned while they are part of a workflow job",
				owlType=NS.OWL.DATATYPE_PROPERTY,
				domain=NS.OMNOM.CLASS_JOB,
				range=NS.XSD.STRING)
        public static final String PROP_JOB_TEMPID          = BASE + "temporaryID";

		@OWLAnnotation(description="Job status. Can be one of NOT_STARTED, STARTED, ITERATING, WAITING, FINISHED or FAILED",
				owlType=NS.OWL.DATATYPE_PROPERTY,
				domain=NS.OMNOM.CLASS_JOB,
				range=NS.XSD.STRING)
        public static final String PROP_JOB_STATUS          = BASE + "status";

		@OWLAnnotation(description="The set of started Jobs",
				owlType=NS.OWL.OBJECT_PROPERTY,
				domain=NS.OMNOM.CLASS_JOB,
				range=NS.OMNOM.CLASS_JOB)
        public static final String PROP_JOB_STARTED         = BASE + "startedJobs";

		@OWLAnnotation(description="The parent Job of this Job.",
				owlType=NS.OWL.OBJECT_PROPERTY,
				domain=NS.OMNOM.CLASS_JOB,
				range=NS.OMNOM.CLASS_JOB)
        public static final String PROP_JOB_PARENT          = BASE + "parentJob";

		@OWLAnnotation(description="TODO",
				owlType=NS.OWL.DATATYPE_PROPERTY)
        public static final String PROP_JOB_LATEST_RESULT   = BASE + "latestResult";

		@OWLAnnotation(description="Referring to the representation of a single logging event",
				owlType=NS.OWL.OBJECT_PROPERTY,
				domain=NS.OMNOM.CLASS_JOB,
				range=NS.OMNOM.CLASS_LOG_ENTRY)
        public static final String PROP_LOG_ENTRY           = BASE + "logEntries";

		@OWLAnnotation(description="Log level. One of TRACE, DEBUG, INFO, WARN, ERROR or FATAL.",
				owlType=NS.OWL.DATATYPE_PROPERTY,
				domain=NS.OMNOM.CLASS_LOG_ENTRY,
				range=NS.XSD.STRING)
		public static final String PROP_LOG_LEVEL           = BASE + "hasLogLevel";

		@OWLAnnotation(description="A string to be logged",
				owlType=NS.OWL.DATATYPE_PROPERTY,
				domain=NS.OMNOM.CLASS_LOG_ENTRY,
				range=NS.XSD.STRING)
		public static final String PROP_LOG_MESSAGE         = BASE + "hasLogMessage";

		@OWLAnnotation(description="Refers to the hexadecimal representation of a file",
				owlType=NS.OWL.DATATYPE_PROPERTY,
				domain=NS.OMNOM.CLASS_FILE,
				range=NS.XSD.STRING
				)
		public static final String PROP_MD5                 = BASE + "md5";

		@OWLAnnotation(description="The original name of an uploaded file",
				owlType=NS.OWL.DATATYPE_PROPERTY,
				domain=NS.OMNOM.CLASS_FILE,
				range=NS.XSD.STRING)
		public static final String PROP_ORIGINAL_NAME       = BASE + "originalName";

		@OWLAnnotation(description="Referring to an output parameter of a Webservice",
				owlType=NS.OWL.OBJECT_PROPERTY,
				domain=NS.OMNOM.CLASS_WEBSERVICE,
				range=NS.OMNOM.CLASS_PARAMETER)
		public static final String PROP_OUTPUT_PARAM        = BASE + "outputParam";

		@OWLAnnotation(description="Referring to a ParameterConnector of this Workflow",
				owlType=NS.OWL.OBJECT_PROPERTY,
				domain=NS.OMNOM.CLASS_WORKFLOW,
				range=NS.OMNOM.CLASS_PARAMETER_CONNECTOR)
		public static final String PROP_PARAMETER_CONNECTOR = BASE + "parameterConnector";

		@OWLAnnotation(description="The type of parameter value this parameter expects.",
				owlType=NS.OWL.DATATYPE_PROPERTY,
				domain=NS.OMNOM.CLASS_PARAMETER,
				range=NS.XSD.ANY_URI)
		public static final String PROP_PARAMETER_TYPE      = BASE + "parameterType";

		@OWLAnnotation(description="The parameter value of a ParameterAssignment",
				owlType=NS.OWL.DATATYPE_PROPERTY,
				domain=NS.OMNOM.CLASS_PARAMETER_ASSIGNMENT)
        public static final String PROP_PARAMETER_VALUE     = BASE + "parameterValue";

		@OWLAnnotation(description="TODO",
				owlType=NS.OWL.DATATYPE_PROPERTY)
        public static final String PROP_PARAMETER_SERIAL     = BASE + "parameterSerial";

		@OWLAnnotation(description="Referring to a WorkflowPosition within a workflow",
				owlType=NS.OWL.OBJECT_PROPERTY,
				domain=NS.OMNOM.CLASS_WORKFLOW,
				range=NS.OMNOM.CLASS_WORKFLOW_POSITION)
        public static final String PROP_WORKFLOW_POSITION   = BASE + "workflowPosition";

		@OWLAnnotation(description="The target Parameter of a ParameterConnector",
				owlType=NS.OWL.OBJECT_PROPERTY,
				domain=NS.OMNOM.CLASS_PARAMETER_CONNECTOR,
				range=NS.OMNOM.CLASS_PARAMETER)
		public static final String PROP_TO_PARAM            = BASE + "toParam";

		@OWLAnnotation(description="The target WorkflowPosition of a ParameterConnector",
				owlType=NS.OWL.OBJECT_PROPERTY,
				domain=NS.OMNOM.CLASS_PARAMETER_CONNECTOR,
				range=NS.OMNOM.CLASS_WORKFLOW_POSITION)
		public static final String PROP_TO_POSITION         = BASE + "toPosition";

		@OWLAnnotation(description="The target Workflow of a ParameterConnector",
				owlType=NS.OWL.OBJECT_PROPERTY,
				domain=NS.OMNOM.CLASS_PARAMETER_CONNECTOR,
				range=NS.OMNOM.CLASS_WORKFLOW)
		public static final String PROP_TO_WORKFLOW         = BASE + "toWorkflow";

		@OWLAnnotation(description="Referring to a Webservice",
				owlType=NS.OWL.OBJECT_PROPERTY,
				range=NS.OMNOM.CLASS_WEBSERVICE)
        public static final String PROP_WEBSERVICE          = BASE + "webservice";

		@OWLAnnotation(description="TODO",
				owlType=NS.OWL.DATATYPE_PROPERTY,
				range=NS.XSD.STRING)
        public static final String PROP_WEBSERVICE_ID          = BASE + "implementationID";

		@OWLAnnotation(description="TODO",
				owlType=NS.OWL.DATATYPE_PROPERTY,
				range=NS.XSD.ANY_URI)
        public static final String PROP_EXEC_WEBSERVICE          = BASE + "isExecutableAt";

		@OWLAnnotation(description="Referring to the WebserviceConfig of a Webservice",
				owlType=NS.OWL.OBJECT_PROPERTY,
				range=NS.OMNOM.CLASS_WEBSERVICE_CONFIG)
        public static final String PROP_WEBSERVICE_CONFIG   = BASE + "webserviceConfig";

		@OWLAnnotation(description="To Be Deleted",
				owlType=NS.OWL.OBJECT_PROPERTY,
				deprecated=true)
		public static final String PROP_WORKFLOW            = BASE + "workflow";

		@OWLAnnotation(description="A registered FileService for an Omnom User",
				owlType=NS.OWL.OBJECT_PROPERTY,
				domain=NS.FOAF.CLASS_PERSON,
				range=NS.OMNOM.CLASS_WEBSERVICE)
		public static final String PROP_FILE_SERVICE = BASE + "fileservice";

		@OWLAnnotation(description="The user who uploaded a file and hence owns it as far as the system is concerned",
				owlType=NS.OWL.OBJECT_PROPERTY,
				domain=NS.OMNOM.CLASS_FILE,
				range=NS.FOAF.CLASS_PERSON)
		public static final String PROP_FILE_OWNER = BASE + "fileOwner";

		@OWLAnnotation(description="TODO",
				owlType=NS.OWL.OBJECT_PROPERTY,
				range=NS.OMNOM.CLASS_JOB)
		public static final String PROP_RUNNING_JOB = BASE + "runningJob";

		@OWLAnnotation(description="TODO",
				owlType=NS.OWL.OBJECT_PROPERTY,
				range=NS.OMNOM.CLASS_WORKFLOW_POSITION)
		public static final String PROP_EXECUTES_POSITION = BASE + "executesPosition";

		@OWLAnnotation(description="The preferred theme of a user. Valid values are 'light' and 'dark'.",
				owlType=NS.OWL.DATATYPE_PROPERTY,
				domain=NS.FOAF.CLASS_PERSON,
				range=NS.XSD.STRING)
		public static final String PROP_PREFERRED_THEME     = BASE + "preferredTheme";

		@OWLAnnotation(description="Whether or not a user has his 'My Stuff' filter set",
				owlType=NS.OWL.DATATYPE_PROPERTY,
				domain=NS.FOAF.CLASS_PERSON,
				range=NS.XSD.BOOLEAN)
		public static final String PROP_GLOBAL_USER_FILTER     = BASE + "globalUserFilter";

		@OWLAnnotation(description="TODO",
				owlType=NS.OWL.OBJECT_PROPERTY,
				range=NS.OMNOM.CLASS_WORKFLOW_POSITION)
		public static final String PROP_POSITIONS_TO_RUN = BASE + "positionsToRun";
	}

	/**
	 * Resource types for files, used for content-negotiating webservices, validation...
	 */
	public static final class OMNOM_TYPES {

		public static final String BASE    = "http://onto.dm2e.eu/omnom-types/";
		@OWLAnnotation(description="Base class of all file types")
		public static final String CLASS_TYPE = BASE + "Type";
		@OWLAnnotation(description="Gzipped Tarball",
				owlType=NS.OWL.CLASS,
				rdfType=NS.OMNOM_TYPES.CLASS_TYPE)
		public static final String TGZ     = BASE + "TGZ";
		@OWLAnnotation(description="Gzipped Tarball containing exactly one XML file.",
				owlType=NS.OWL.CLASS,
				rdfType=NS.OMNOM_TYPES.CLASS_TYPE)
		public static final String TGZ_XML = BASE + "TGZ-XML";
		@OWLAnnotation(description="Single XML file.",
				owlType=NS.OWL.CLASS,
				rdfType=NS.OMNOM_TYPES.CLASS_TYPE)
		public static final String XML     = BASE + "XML";
		@OWLAnnotation(description="Single XSLT script.",
				owlType=NS.OWL.CLASS,
				rdfType=NS.OMNOM_TYPES.CLASS_TYPE)
		public static final String XSLT    = BASE + "XSLT";
		@OWLAnnotation(description="Zipped folder of XML files",
				owlType=NS.OWL.CLASS,
				rdfType=NS.OMNOM_TYPES.CLASS_TYPE)
		public static final String ZIP_XML = BASE + "ZIP-XML";
		@OWLAnnotation(description="Zipped folder of a set of XSLT scripts with exactly one containing the root template.",
				owlType=NS.OWL.CLASS,
				rdfType=NS.OMNOM_TYPES.CLASS_TYPE)
		public static final String ZIP_XSLT= BASE + "ZIP-XSLT";
		@OWLAnnotation(description="Fallback class for unknown file types.",
				owlType=NS.OWL.CLASS,
				rdfType=NS.OMNOM_TYPES.CLASS_TYPE)
		public static final String UNKNOWN = BASE + "UNKNOWN";
	}

	/**
	 * RDFS.
	 */
	public static final class RDFS {
		public static final String BASE = "http://www.w3.org/2000/01/rdf-schema#";
		public static final String PROP_LABEL = BASE + "label";
		public static final String PROP_COMMENT = BASE + "comment";
	}

	/**
	 * Collections Ontology.
	 */
	public static final class CO {

		public static final String BASE = "http://purl.org/co/";

		public static final String PROP_ITEM_CONTENT = BASE + "itemContent";
		public static final String PROP_SIZE		   = BASE + "size";
		public static final String PROP_INDEX        = BASE + "index";
		public static final String PROP_ITEM  	   = BASE + "item";
		public static final String PROP_FIRST_ITEM   = BASE + "firstItem";
		public static final String PROP_NEXT_ITEM   = BASE + "nextItem";
		public static final String PROP_LAST_ITEM   = BASE + "lastItem";

		public static final String CLASS_LIST = BASE + "List";
		public static final String CLASS_ITEM = BASE + "Item";
	}

	/**
	 * RDF.
	 */
	public static final class RDF {

		public static final String BASE      = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
		public static final String PROP_TYPE = BASE + "type";
	}

	/** SKOS. */
	public static final class SKOS {

		public static final String BASE       = "http://www.w3.org/2004/02/skos/core#";
		public static final String PROP_LABEL = BASE + "label";
		public static final String PROP_PREF_LABEL = BASE + "prefLabel";
		public static final String CLASS_CONCEPT	= BASE + "Concept";
	}

	/**
	 * Dublin Core Elements.
	 */
	public static final class DC {

		public static final String BASE       = "http://purl.org/dc/elements/1.1/";
		public static final String PROP_TITLE = BASE + "title";
		public static final String PROP_DATE  = BASE + "date";
		public static final String PROP_TYPE = BASE + "type";
		public static final String PROP_IDENTIFIER = BASE + "identifier";
		public static final String PROP_SUBJECT = BASE + "subject";
		public static final String PROP_PUBLISHER = BASE + "publisher";
		public static final String PROP_LANGUAGE = BASE + "language";
		public static final String PROP_FORMAT = BASE + "format";
		public static final String PROP_DESCRIPTION	= BASE + "description";
		public static final String	PROP_CREATOR	= BASE + "creator";
		public static final String	PROP_CONTRIBUTOR	= BASE + "contributor";

	}

	/**
	 * Dublin Core Terms.
	 */
	public static final class DCTERMS {

		public static final String BASE          = "http://purl.org/dc/terms/";
		public static final String PROP_FORMAT   = BASE + "format";
		public static final String PROP_CREATOR   = BASE + "creator";
		public static final String PROP_EXTENT   = BASE + "extent";
		public static final String PROP_MODIFIED = BASE + "modified";
		public static final String PROP_CREATED  = BASE + "created";
		public static final String PROP_IS_PART_OF = BASE + "isPartOf";
		public static final String PROP_TITLE = BASE + "title";
		public static final String PROP_ISSUED = BASE + "issued";
		public static final String PROP_TEMPORAL	= BASE + "temporal";
		public static final String	PROP_ALTERNATIVE	= BASE + "alternative";

	}

	/**
	 * PROV ontology.
	 */
	public static final class PROV {

		public static final String	BASE						= "http://www.w3.org/ns/prov#";
		public static final String	CLASS_ACTIVITY				= BASE + "Activity";
		public static final String	PROP_SPECIALIZATION_OF		= BASE + "specializationOf";
		public static final String	PROP_USED					= BASE + "used";
		public static final String	PROP_WAS_ASSOCIATED_WITH	= BASE + "wasAssociatedWith";
		public static final String	PROP_WAS_GENERATED_BY		= BASE + "wasGeneratedBy";
        public static final String	PROP_WAS_REVISION_OF		= BASE + "wasRevisionOf";
        public static final String	PROP_WAS_STARTED_AT		= BASE + "wasStartedAt";
        public static final String	PROP_WAS_ENDED_AT		= BASE + "wasEndedAt";


    }

	/**
	 * XML Schema.
	 */
	public static final class XSD {

		public static final String BASE = "http://www.w3.org/2001/XMLSchema#";
		public static final Object	DATETIME	= BASE + "dateTime";
		public static final String	ANY_URI		= BASE + "anyURI";
		public static final String	BOOLEAN		= BASE + "boolean";
		public static final String	INT			= BASE + "int";
		public static final String	INTEGER		= BASE + "integer";
		public static final String	STRING		= BASE + "string";
	}

	/**
	 * VOID dataset description.
	 */
	public static final class VOID {

		public static final String BASE          = "http://rdfs.org/ns/void#";
		public static final String CLASS_DATASET = BASE + "Dataset";
	}

	/**
	 * FOAF Friend of a Friend.
	 */
	public static final class FOAF {

		public static final String BASE         = "http://xmlns.com/foaf/0.1/";
		public static final String	CLASS_ORGANIZATION	= BASE + "Organization";
		public static final String	CLASS_PERSON		= BASE + "Person";
		public static final String	PROP_NAME			= BASE + "name";
	}

	public static final class DM2E {
		public static final String	BASE							= "http://onto.dm2e.eu/schemas/dm2e/1.1/";
		public static final String	CLASS_MANUSCRIPT				= BASE + "Manuscript";
		public static final String	CLASS_PAGE						= BASE + "Page";
		public static final String	CLASS_FILE						= BASE + "File";
		public static final String	CLASS_DOCUMENT						= BASE + "Document";
		public static final String	CLASS_PHOTO						= BASE + "Photo";
		public static final String	PROP_ARTIST						= BASE + "artist";
		public static final String	PROP_CALL_NUMBER				= BASE + "callNumber";
		public static final String	PROP_CONDITION					= BASE + "condition";
		public static final String	PROP_DISPLAY_LEVEL				= BASE + "displayLevel";
		public static final String	PROP_EXPLICIT					= BASE + "explicit";
		public static final String	PROP_HAS_ANNOTABLE_VERSION_AT	= BASE + "hasAnnotatableVersionAt";
		public static final String	PROP_INCIPIT					= BASE + "incipit";
		public static final String	PROP_LEVEL_OF_GENESIS			= BASE + "levelOfGenesis";
		public static final String	PROP_LEVEL_OF_HIERARCHY			= BASE + "levelOfHierarchy";
		public static final String	PROP_PAINTER					= BASE + "painter";
		public static final String	PROP_PRINTED_AT					= BASE + "printedAt";
		public static final String	PROP_PUBLISHED_AT				= BASE + "publishedAt";
		public static final String	PROP_SHELFMARK_LOCATION			= BASE + "shelfmarkLocation";
		public static final String	PROP_SUBTITLE					= BASE + "subtitle";
		public static final String	PROP_WATERMARK					= BASE + "watermark";
		public static final String	PROP_WRITER						= BASE + "writer";
		public static final String	CLASS_WORK						= BASE + "Work";
		public static final String	CLASS_PARAGRAPH						= BASE + "Paragraph";
		public static final String	CLASS_PUBLICATION						= BASE + "Publication";
	}

	public static final class DM2E_UNVERSIONED {
		public static final String	BASE							= "http://onto.dm2e.eu/schemas/dm2e/";
		public static final String	CLASS_MANUSCRIPT				= BASE + "Manuscript";
		public static final String	CLASS_PAGE						= BASE + "Page";
		public static final String	CLASS_FILE						= BASE + "File";
		public static final String	CLASS_DOCUMENT						= BASE + "Document";
		public static final String	CLASS_PHOTO						= BASE + "Photo";
		public static final String	PROP_ARTIST						= BASE + "artist";
		public static final String	PROP_CALL_NUMBER				= BASE + "callNumber";
		public static final String	PROP_CONDITION					= BASE + "condition";
		public static final String	PROP_DISPLAY_LEVEL				= BASE + "displayLevel";
		public static final String	PROP_EXPLICIT					= BASE + "explicit";
		public static final String	PROP_HAS_ANNOTABLE_VERSION_AT	= BASE + "hasAnnotatableVersionAt";
		public static final String	PROP_INCIPIT					= BASE + "incipit";
		public static final String	PROP_LEVEL_OF_GENESIS			= BASE + "levelOfGenesis";
		public static final String	PROP_LEVEL_OF_HIERARCHY			= BASE + "levelOfHierarchy";
		public static final String	PROP_PAINTER					= BASE + "painter";
		public static final String	PROP_PRINTED_AT					= BASE + "printedAt";
		public static final String	PROP_PUBLISHED_AT				= BASE + "publishedAt";
		public static final String	PROP_SHELFMARK_LOCATION			= BASE + "shelfmarkLocation";
		public static final String	PROP_SUBTITLE					= BASE + "subtitle";
		public static final String	PROP_WATERMARK					= BASE + "watermark";
		public static final String	PROP_WRITER						= BASE + "writer";
		public static final String	CLASS_WORK						= BASE + "Work";
		public static final String	CLASS_PARAGRAPH						= BASE + "Paragraph";
		public static final String	CLASS_PUBLICATION						= BASE + "Publication";
	}

	public static final class FABIO {
		public static final String BASE         = "http://purl.org/spar/fabio/";
		public static final String CLASS_ARTICLE = BASE + "Article";
		public static final String CLASS_CHAPTER = BASE + "Chapter";
	}
	public static final class BIBO {
		public static final String BASE         = "http://purl.org/ontology/bibo/";
		public static final String	CLASS_ISSUE	= BASE + "Issue";
		public static final String	PROP_EDITOR	= BASE + "editor";
		public static final String	PROP_ISBN	= BASE + "isbn";
		public static final String	PROP_ISSN	= BASE + "issn";
		public static final String	PROP_NUMBER	= BASE + "number";
		public static final String	PROP_PAGES	= BASE + "pages";
		public static final String	PROP_NUM_VOLUMES	= BASE + "numVolumes";
		public static final String	PROP_VOLUME	= BASE + "volume";
		public static final String CLASS_SERIES = "Series";
	}
	public static final class EDM {
		public static final String	BASE				= "http://www.europeana.eu/schemas/edm/";
		public static final String	CLASS_AGENT				= BASE + "Agent";
		public static final String	CLASS_EVENT				= BASE + "Event";
		public static final String	CLASS_PLACE				= BASE + "Event";
		public static final String	CLASS_PROVIDED_CHO		= BASE + "ProvidedCHO";
		public static final String	CLASS_TIMESPAN			= BASE + "TimeSpan";
		public static final String	CLASS_WEBRESOURCE		= BASE + "WebResource";
		public static final String	PROP_AGGREGATED_CHO		= BASE + "aggregatedCHO";
		public static final String	PROP_BEGIN				= BASE + "begin";
		public static final String	PROP_CURRENT_LOCATION	= BASE + "currentLocation";
		public static final String	PROP_DATA_PROVIDER		= BASE + "dataProvider";
		public static final String	PROP_END				= BASE + "end";
		public static final String	PROP_HAS_MET			= BASE + "hasMet";
		public static final String	PROP_HAS_VIEW			= BASE + "hasView";
		public static final String	PROP_IS_SHOWN_AT		= BASE + "isShownAt";
		public static final String	PROP_IS_SHOWN_BY		= BASE + "isShownBy";
		public static final String	PROP_OBJECT				= BASE + "object";
		public static final String	PROP_PROVIDER			= BASE + "provider";
		public static final String	PROP_RIGHTS				= BASE + "rights";
		public static final String	PROP_TYPE				= BASE + "type";
		public static final String	PROP_IS_NEXT_IN_SEQUENCE	= BASE + "isNextInSequence";
	}
	public static final class PRO {
		public static final String BASE = "http://purl.org/spar/pro/";
		public static final String PROP_AUTHOR = BASE + "author";
		public static final String	PROP_TRANSLATOR	= BASE + "translator";
	}
	public static final class DM2E_UNOFFICIAL {
		public static final String BASE = "http://onto.dm2e.eu/UNOFFICIAL/";
		public static final String PROP_HAS_COLLECTION = BASE + "hasCollection";
		public static final String PROP_HAS_VERSION    = BASE + "hasVersion";
        public static final String PROP_CONTAINS_CHO = BASE + "containsCHO";
        public static final String PROP_STABILITY = BASE + "stability";
        public static final String PROP_DM2E_VERSION = BASE + "dm2eVersion";
        public static final String PROP_VALIDATED_AT_LEVEL = BASE + "validatedAtLevel";
    }
	public static final class OAI {
		public static final String BASE = "http://www.openarchives.org/OAI/2.0/";
	}
	public static final class OAI_DC {
		public static final String BASE = "http://www.openarchives.org/OAI/2.0/oai_dc/";
	}
	public static final class OAI_RIGHTS {
		public static final String BASE = "http://www.openarchives.org/OAI/2.0/rights/";
	}
	public static final class CRM {
		public static final String BASE = "http://www.cidoc-crm.org/cidoc-crm/";
		public static final String PROP_P79F_BEGINNING_IS_QUALIFIED_BY= BASE + "P79F.beginning_is_qualified_by";
		public static final String PROP_P80F_END_IS_QUALIFIED_BY		= BASE + "P80F.end_is_qualified_by";
	}
	public static final class OWL {
		public static final String BASE = "http://www.w3.org/2002/07/owl#";
		public static final String THING = BASE + "Thing";
		public static final String CLASS = BASE + "Class";
		public static final String INDIVIDUAL = BASE + "Individual";
		public static final String DATATYPE_PROPERTY = BASE + "DatatypeProperty";
		public static final String OBJECT_PROPERTY = BASE + "ObjectProperty";
		public static final String DEPRECATED = BASE + "deprecated";
	}
	
	public static final class ORE {
		public static final String BASE = "http://www.openarchives.org/ore/terms/";
		public static final String CLASS_AGGREGATION = BASE + "Aggregation";
		
	}

	public static final class PRISM_3 {
		public static final String BASE = "http://prismstandard.org/namespaces/basic/3.0/";
		public static final String PROP_STARTING_PAGE = BASE + "startingPage";
	}
}
