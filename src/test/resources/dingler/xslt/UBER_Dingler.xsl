<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="tei xml" version="2.0"
  xmlns:bibo="http://purl.org/ontology/bibo/" 
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:dcterms="http://purl.org/dc/terms/" 
  xmlns:dm2e="http://onto.dm2e.eu/schemas/dm2e/"
  xmlns:edm="http://www.europeana.eu/schemas/edm/" 
  xmlns:foaf="http://xmlns.com/foaf/0.1/"
  xmlns:korbo="http://purl.org/net7/korbo/vocab#" 
  xmlns:ore="http://www.openarchives.org/ore/terms/"
  xmlns:owl="http://www.w3.org/2002/07/owl#" 
  xmlns:pro="http://purl.org/spar/pro/"
  xmlns:rdaGr2="http://RDVocab.info/ElementsGr2/"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
  xmlns:skos="http://www.w3.org/2004/02/skos/core#" 
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:void="http://rdfs.org/ns/void#" 
  xmlns:wgs84_pos="http://www.w3.org/2003/01/geo/wgs84_pos#"
  xmlns:xalan="http://xml.apache.org/xalan" 
  xmlns:xml="http://www.w3.org/XML/1998/namespace"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


  <!--
	Mappings: Polytechnisches Journal (Dingler) to DM2E Version 1.1 Revision 1.3
	
	Version:	1.10
	Date:		  2014-02-19
	Authors:	Evelyn Dröge     evelyn.droege@ibi.hu-berlin.de
	          Julia Iwanowa    julia.iwanowa@ibi.hu-berlin.de
	          	
	         
	         
	LOG:
	
	Version:  1.10
	          - Updated page, issue, article URIs to page_, issue_, article_
	          - Corrected all isNextInSequence functions to refer to the previous CHOs and not to the next CHOs
	          - Removed isNextInsequence from front page
	          - Changed dcterms:created xsd:dateTime into rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime"
	          - Changed dm2e:displayLevel xsd:boolean in Page into rdf:datatype="http://www.w3.org/TR/xmlschema-2#boolean"
	          - Changed bibo:number
	          - Removed bibo:pages
	          - Changed pro:author
	          - Changed title and subtitle for articles
	          - Removed dcterms:hasPart
	          - Changed dcterms:isPart of for articles
	          - Added dm2e:levelOfHierarchy
	          
	          
	
	Version:  1.9
	          - Removed brackets from dc:subject
	          - Added datetime datatype in timespans
	          - Changed boolean datatype in displayLevel
	          - Removed dc:identifier from Journal (was not an unambigous identifier)
	          - Changed title and removed subtitle from Issue
	          - Corrected rightsHolder for WebResources
	          - Corrected dc:creator in Aggregations
	          - Adjusted edm:provider URIs to mapping recommendations
	          - Corrected dataProvider
	          - Replaced dm2e:isPartOfWebResource (Page)
	          - Changed dc:contributor in Aggregations
	          
	
	Version:  1.8
	          - Removed all obsolete dcterms properties
	          - Removed version number from DM2E namespace
	          - Added xsd:datetime datatype in dcterms:created
	          - Added xsd:boolean in dm2e:displayLevel
	
	Version:  1.7
	          - Changed all language "ger" and "eng" tags into "de" and "en" 2-character codes
	          

	Version:  1.6
	          - Replaced dm2e:hasPartCHO with dcterms:hasPart and dm2e:isPartOfCHO with dcterms:isPartOf
	          - Replaced dm2e:isDerivativeOfWebResource with edm:isDerivativeOf
	
	Version:  1.5
	           - Corrected subtitles
	Version:  1.4
	           - Checked mandatory elements
	           - Checked RDF result
	Version:  1.3 
	           - Journal: Removed alternativeTitle
	           - Journal: Changed dc:contributor
	           - Volume: Changed dc:contributor
	           - Article: Changed TableOfContents
	           - Article: Added type for dm2e:hasAnnotatableVersionAt
	           - Article: Remodved isPartOfWebResource for <edm:WebResource rdf:about="http://dingler.culture.hu-berlin.de">
	           - Article and Page: Changed isDerivativeOfWebResource in <edm:WebResource rdf:about="http://dingler.culture.hu-berlin.de">
	           - Page: Added type for dm2e:hasAnnotatableVersionAt; changed Urls
	           - Page: Removed bibo:imageNum
	           - Page: Changed dc:contributor
	           - Page: Changed edm:isShownBy
	Version:  1.2 Added Pages and Journal      
	Version:  1.1 Correction of the inital mapping. Page mapping is incomplete.
	Version:	1.0 Initial mapping (based on an MINT export; structure from Kilian Schmidtners TEItoEDM mappings)
	-->


  <!-- imports -->
  <xsl:import href="UBER_Dingler_Journal.xsl"/>
  <xsl:import href="UBER_Dingler_Article.xsl"/>
  <xsl:import href="UBER_Dingler_Page.xsl"/>
  <xsl:import href="UBER_Dingler_Issue.xsl"/>
  <!--<xsl:import href="UBER_Dingler_Recursion.xsl"/>-->
  
  <!-- output -->
  <xsl:output method="xml" encoding="utf-8" omit-xml-declaration="no" indent="yes"/>

  <!-- parameters and default values -->
  <!-- Target-Format: EDM | EDMplus -->
  <xsl:param name="TARGET_FORMAT">DM2E</xsl:param>
  <!--  Abbreviation of the data provider -->
  <xsl:param name="DATAPROVIDER_ABB">uber</xsl:param>
  <!-- Abbreviation of the data provider repository -->
  <xsl:param name="REPOSITORY_ABB">dingler</xsl:param>
  <!-- Default Web Resource URL -->
  <xsl:param name="DEF_URL">http://dingler.culture.hu-berlin.de/</xsl:param>
  <!-- Default data provider -->
  <xsl:param name="DEF_DATAPROVIDER">Polytechnisches Journal</xsl:param>
  <!-- Default Language -->
  <xsl:param name="DEF_LANGUAGE">de</xsl:param>
  <!-- Default type -->
  <xsl:param name="DEF_DCTYPE">text</xsl:param>
  <!-- Default rights -->
  <xsl:variable name="RIGHTS_RESOURCE">http://creativecommons.org/licenses/by-nc-sa/3.0/</xsl:variable>
  <!-- DM2E-ID-Root -->
  <xsl:param name="baseURI">http://data.dm2e.eu/data/</xsl:param>
  <!-- Dataprovider und Repostitory -->
  <xsl:variable name="PROV_REP" select="concat('/', $DATAPROVIDER_ABB, '/', $REPOSITORY_ABB, '/')"/>
  <!-- Default subject -->
  <xsl:param name="DEF_SUBJECT">19th century engineering and natural sciences</xsl:param>
  <xsl:variable name="DEF_SUBJECT_URI" select="replace($DEF_SUBJECT, ' ', '_')"/>

  <!-- DM2E URIs -->
  <!-- aggregation -->
  <xsl:variable name="aggregation" select="concat($baseURI, 'aggregation', $PROV_REP)"/>
  <!-- CHO -->
  <xsl:variable name="cho" select="concat($baseURI, 'item', $PROV_REP)"/>
  <!-- agent -->
  <xsl:variable name="agent" select="concat($baseURI, 'agent', $PROV_REP)"/>
  <!-- DM2E agent -->
  <xsl:variable name="dm2e_agent" select="concat($baseURI, 'agent/dm2e/')"/>
  <!-- concept -->
  <xsl:variable name="concept" select="concat($baseURI, 'concept', $PROV_REP)"/>
  <!-- place -->
  <xsl:variable name="place" select="concat($baseURI, 'place', $PROV_REP)"/>
  <!-- timespan -->
  <xsl:variable name="timespan" select="concat($baseURI, 'timespan', $PROV_REP)"/>
  <!-- event -->
  <xsl:variable name="event" select="concat($baseURI, 'event', $PROV_REP)"/>
  <!-- subject -->
  <xsl:variable name="subject" select="concat($baseURI, 'concept', $PROV_REP, $DEF_SUBJECT_URI)"/>


  <!-- Default Time -->
  <xsl:param name="start">00:00:00</xsl:param>
  <xsl:param name="end">23:59:59</xsl:param>
  
  <!-- adapted MINT part -->

  <!-- <xsl:template match="tei:teiHeader"> -->

  <xsl:template match="/">
    <rdf:RDF>

    <xsl:call-template name="Journal">
      <xsl:with-param name="theTEIHeader" select="tei:TEI/tei:teiHeader"/>
    </xsl:call-template>
    
    <xsl:call-template name="Issue">
      <xsl:with-param name="theTEIHeader" select="tei:TEI/tei:teiHeader"/>
    </xsl:call-template> 

    <xsl:call-template name="Article">
      <xsl:with-param name="theTEIHeader" select="tei:TEI/tei:teiHeader"/>
    </xsl:call-template> 

    <xsl:call-template name="Page">
      <xsl:with-param name="theTEIHeader" select="tei:TEI/tei:teiHeader"/>
    </xsl:call-template>
    
   
    </rdf:RDF>
  </xsl:template>



</xsl:stylesheet>
