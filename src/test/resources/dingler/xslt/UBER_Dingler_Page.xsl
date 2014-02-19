<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="tei xml xs xsd" version="2.0"
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
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsd="http://www.w3.org/TR/xmlschema-2/"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
 
  <xsl:template name="Page">
    <xsl:param name="theTEIHeader" as="node()"/>
  
  
   <!-- Frontpage -->
    
      <ore:Aggregation>
        <xsl:attribute name="rdf:about">
          <xsl:value-of select="$aggregation"/>
            <xsl:for-each select="tei:TEI/tei:text/tei:front/tei:pb">
              <xsl:choose >
                <xsl:when test="position()=1">
                  <xsl:value-of select="concat('page_',@xml:id)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:variable name="withoutID">
                    <xsl:value-of select="$theTEIHeader/tei:fileDesc/tei:sourceDesc/tei:biblFull/tei:seriesStmt/tei:biblScope/@pages"/>
                  </xsl:variable> 
                  <xsl:value-of select="concat('page_', substring-after(substring-before($withoutID, ''),'-'))"/>
                </xsl:otherwise>
              </xsl:choose>
              
              
            </xsl:for-each>
        </xsl:attribute>
        
        <edm:aggregatedCHO>
          
          
          <!-- Begin CHO (Frontpage) -->
 
          <edm:ProvidedCHO>
              <xsl:attribute name="rdf:about">
                <xsl:value-of select="$cho"/>
                <xsl:for-each select="tei:TEI/tei:text/tei:front/tei:pb">
                  <xsl:value-of select="concat('page_',@xml:id)"/>
                </xsl:for-each>
              </xsl:attribute>
            
            <edm:type>
              <xsl:text>TEXT</xsl:text>
            </edm:type>
            
            <dc:type>
              <xsl:attribute name="rdf:resource">
                <xsl:text>http://onto.dm2e.eu/schemas/dm2e/Page</xsl:text>
              </xsl:attribute>
            </dc:type>
            
            <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:sourceDesc/tei:biblFull/tei:titleStmt/tei:title">
              <xsl:if test="position() = 1">
                <dc:title>
                  <xsl:attribute name="xml:lang">
                    <xsl:text>de</xsl:text>
                  </xsl:attribute> 
                  <xsl:value-of select="."/>
                </dc:title>
              </xsl:if>
              <xsl:if test="position() > 1">
                <dc:subtitle>
                  <xsl:attribute name="xml:lang">
                    <xsl:text>de</xsl:text>
                  </xsl:attribute> 
                  <xsl:value-of select="."/>
                </dc:subtitle>
              </xsl:if>
            </xsl:for-each>
            
              <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:head">
               <xsl:if test="position()=1">
                <dcterms:subtitle>
                <xsl:attribute name="xml:lang">
                  <xsl:text>de</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="."/> 
               </dcterms:subtitle>
             </xsl:if>
              </xsl:for-each> 
     
            <dc:language>
              <xsl:text>de</xsl:text>
            </dc:language>
            
            <dc:subject>
              <skos:Concept>
                <xsl:attribute name="rdf:about">
                  <xsl:value-of select="$subject"/>
                </xsl:attribute>
                <skos:prefLabel>
                  <xsl:attribute name="xml:lang">
                    <xsl:text>en</xsl:text>
                  </xsl:attribute>
                  <xsl:value-of select="$DEF_SUBJECT"/>
                </skos:prefLabel>
              </skos:Concept>
            </dc:subject>
            
            <bibo:number rdf:datatype="http://www.w3.org/2001/XMLSchema#int">
              <xsl:value-of select="number(@n)"/>
            </bibo:number>
                        
            <pro:author>
              <foaf:Person> 
                <xsl:attribute name="rdf:about">
                  <xsl:value-of select="$agent"/>
                  <xsl:for-each select="tei:TEI/tei:text/tei:front/tei:titlePart/tei:persName">
                    <xsl:if test="position() = 1">
                      <xsl:value-of select="encode-for-uri(replace(., ' ', '_'))"/>
                    </xsl:if>
                  </xsl:for-each>
                </xsl:attribute>
                <xsl:for-each select="tei:TEI/tei:text/tei:front/tei:titlePart/tei:persName">
                  <xsl:if test="position() = 1">
                    <skos:prefLabel>
                      <xsl:attribute name="xml:lang">
                        <xsl:text>de</xsl:text>
                      </xsl:attribute>
                      <xsl:value-of select="."/>
                    </skos:prefLabel>
                  </xsl:if>
                </xsl:for-each>
              </foaf:Person>
            </pro:author>
            
            <!-- Related CHOs (Frontpage) -->
            
            <dcterms:isPartOf>
              <edm:ProvidedCHO>
                <xsl:attribute name="rdf:about">
                  <xsl:value-of select="$cho"/>
                  <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:idno">
                    <xsl:if test="position() = 1">
                      <xsl:value-of select="replace($DEF_DATAPROVIDER, ' ', '_')"/>
                    </xsl:if>
                  </xsl:for-each>
                </xsl:attribute>
              </edm:ProvidedCHO>
            </dcterms:isPartOf>    
            
            <dcterms:isPartOf>
              <edm:ProvidedCHO>
                <xsl:attribute name="rdf:about">
                  <xsl:value-of select="$cho"/>
                  <xsl:for-each select="tei:TEI/tei:text/tei:front/tei:pb">  
                    <xsl:if test="position() = 1">
                      <xsl:value-of select="concat('issue_', substring-before(@xml:id,'_'))"/>
                    </xsl:if>
                  </xsl:for-each>
                </xsl:attribute>
              </edm:ProvidedCHO>
            </dcterms:isPartOf>
            
            <dm2e:levelOfHierarchy rdf:datatype="http://www.w3.org/2001/XMLSchema#int">
              <xsl:text>4</xsl:text>
            </dm2e:levelOfHierarchy>
            
            <!-- <edm:isNextInSequence>
              <edm:ProvidedCHO>
                <xsl:attribute name="rdf:about">
                  <xsl:value-of select="$cho"/>
                  <xsl:for-each select="tei:TEI/tei:text/tei:front/tei:pb">
                    <xsl:value-of select="concat('page_',(substring-before(@xml:id, '_')),'_pb00',(string(number(substring-after(@xml:id, '_pb'))-1)))"/>
                  </xsl:for-each>
                </xsl:attribute>
              </edm:ProvidedCHO>
            </edm:isNextInSequence> 
          </edm:ProvidedCHO>
          
          <dm2e:FrontPages>
            Kommt von front pages
          </dm2e:FrontPages> -->
            
            
              
          </edm:ProvidedCHO> 
        </edm:aggregatedCHO>
        
        <!-- End of CHO (Frontpage) -->


        <!-- Aggregation (Frontpage) -->
        
        <edm:provider>
          <foaf:Organization>
            <xsl:attribute name="rdf:about">
              <xsl:value-of select="$dm2e_agent"/>
              <xsl:text>DM2E</xsl:text>
            </xsl:attribute>
            <skos:prefLabel>
              <xsl:attribute name="xml:lang">
                <xsl:text>en</xsl:text>
              </xsl:attribute>
              <xsl:text>DM2E</xsl:text>
            </skos:prefLabel>
            <skos:altLabel>
              <xsl:attribute name="xml:lang">
                <xsl:text>en</xsl:text>
              </xsl:attribute>
              <xsl:text>Digitised Manuscripts to Europeana</xsl:text>           
            </skos:altLabel>
          </foaf:Organization>
        </edm:provider>
        
        <edm:dataProvider>
          <foaf:Organization>
            <xsl:attribute name="rdf:about">
              <xsl:value-of select="$agent"/>
              <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:persName">
                <xsl:if test="position() = 1">
                  <xsl:value-of select="encode-for-uri(.)"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:attribute>
            <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:persName">
              <xsl:if test="position() = 1">
                <skos:prefLabel>
                  <xsl:attribute name="xml:lang">
                    <xsl:text>de</xsl:text>
                  </xsl:attribute>
                  <xsl:value-of select="."/>
                </skos:prefLabel>
              </xsl:if>
            </xsl:for-each>
          </foaf:Organization>
        </edm:dataProvider>
 
        <edm:rights>
          <xsl:attribute name="rdf:resource">
            <xsl:value-of select="$RIGHTS_RESOURCE"/>
          </xsl:attribute>
        </edm:rights>
 
        <edm:object>
          <edm:WebResource>
            <xsl:attribute name="rdf:about">
              <xsl:for-each select="tei:TEI/tei:text/tei:front/tei:pb">
                <xsl:if test="position() = 1">
                  <xsl:value-of select= "concat('http://dingler.culture.hu-berlin.de/journal/page/',
                    substring-before(@xml:id,'_'),'?p=',substring-after(@facs,'/'))"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:attribute>     
          </edm:WebResource>
        </edm:object>
        
        
        <dm2e:hasAnnotatableVersionAt>
          <edm:WebResource>
            <xsl:attribute name="rdf:about">
              <xsl:for-each select="tei:TEI/tei:text/tei:front/tei:pb">
                <xsl:if test="position() = 1">
                  <xsl:value-of select= "concat('http://dingler.culture.hu-berlin.de/journal/page/',
                    substring-before(@xml:id,'_'),'?p=',substring-after(@facs,'/'))"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:attribute>     
                <dc:format>
                  <xsl:text>text/plain</xsl:text>
                </dc:format>
                <dc:format>
                  <xsl:text>image/jpeg</xsl:text>
                </dc:format>
          </edm:WebResource>
        </dm2e:hasAnnotatableVersionAt> 
        
           <edm:isShownBy>
            <xsl:for-each select=".">
              <edm:WebResource>
                <xsl:if test=".">
                  <xsl:attribute name="rdf:about">
                    <xsl:for-each select="tei:TEI/tei:text/tei:front/tei:pb">
                      <xsl:if test="position() = 1">
                        <xsl:value-of select="concat('http://dingler.culture.hu-berlin.de/journal/page/',
                          substring-before(@xml:id,'_'),'?p=',substring-after(@facs,'/'))"/>
                      </xsl:if>
                    </xsl:for-each>
                  </xsl:attribute>
                </xsl:if>
                <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:seriesStmt/tei:title">
                  <dc:description>
                    <xsl:attribute name="xml:lang">
                      <xsl:text>de</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                  </dc:description>
                </xsl:for-each>
                <dcterms:rightsHolder>
                  <foaf:Organization>
                    <xsl:attribute name="rdf:about">
                      <xsl:value-of select="$agent"/>
                      <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:persName">
                        <xsl:if test="position() = 1">
                          <xsl:value-of select="encode-for-uri(.)"/>
                        </xsl:if>
                      </xsl:for-each>
                    </xsl:attribute>
                    <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:persName">
                      <xsl:if test="position() = 1">
                        <skos:prefLabel>
                          <xsl:attribute name="xml:lang">
                            <xsl:text>de</xsl:text>
                          </xsl:attribute>
                          <xsl:value-of select="."/>
                        </skos:prefLabel>
                      </xsl:if>
                    </xsl:for-each>
                  </foaf:Organization>
                </dcterms:rightsHolder>
                <dcterms:isPartOf>
                  <edm:WebResource>
                    <xsl:if test=".">
                      <xsl:attribute name="rdf:about">
                        <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:idno">
                          <xsl:if test="position() = 1">
                            <xsl:value-of select="substring-before(.,'article')"/>
                          </xsl:if>
                        </xsl:for-each>
                      </xsl:attribute>
                    </xsl:if>
                  </edm:WebResource>
                </dcterms:isPartOf>
              </edm:WebResource>
            </xsl:for-each>
          </edm:isShownBy>
        
        <dc:creator>
          <foaf:Organization>
            <xsl:attribute name="rdf:about">
              <xsl:value-of select="$agent"/>
              <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:persName">
                <xsl:if test="position() = 1">
                  <xsl:value-of select="encode-for-uri(.)"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:attribute>
            <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:persName">
              <xsl:if test="position() = 1">
                <skos:prefLabel>
                  <xsl:attribute name="xml:lang">
                    <xsl:text>de</xsl:text>
                  </xsl:attribute>
                  <xsl:value-of select="."/>
                </skos:prefLabel>
              </xsl:if>
            </xsl:for-each>
          </foaf:Organization>
        </dc:creator>
        
        <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:date/@when">
          <dcterms:created rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                <xsl:if test="position() = 1">
                  <xsl:value-of select="dateTime(xs:date(.),$start)"/>
                </xsl:if>
          </dcterms:created>
        </xsl:for-each>
        
        <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:persName">
          <dc:contributor>
            <foaf:Person>
              <xsl:attribute name="rdf:about">
                <xsl:value-of select="$agent"/>
                <xsl:for-each select=".">
                  <xsl:if test="position() = 1">
                    <xsl:value-of select="encode-for-uri(.)"/>
                  </xsl:if>
                </xsl:for-each>
              </xsl:attribute>
              <xsl:for-each select=".">
                <xsl:if test="position() = 1">
                  <skos:prefLabel>
                    <xsl:attribute name="xml:lang">
                      <xsl:text>de</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                  </skos:prefLabel>
                </xsl:if>
              </xsl:for-each>
            </foaf:Person>
          </dc:contributor>
        </xsl:for-each>
        
        <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:orgName">
          <dc:contributor>
            <foaf:Organization>
              <xsl:attribute name="rdf:about">
                <xsl:value-of select="$agent"/>
                <xsl:for-each select=".">
                  <xsl:if test="position() = 1">
                    <xsl:value-of select="encode-for-uri(.)"/>
                  </xsl:if>
                </xsl:for-each>
              </xsl:attribute>
              <xsl:for-each select=".">
                <xsl:if test="position() = 1">
                  <skos:prefLabel>
                    <xsl:attribute name="xml:lang">
                      <xsl:text>de</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                  </skos:prefLabel>
                </xsl:if>
              </xsl:for-each>
            </foaf:Organization>
          </dc:contributor>
        </xsl:for-each>
        
        <dc:contributor>
          <foaf:Organization>
            <xsl:attribute name="rdf:about">
              <xsl:value-of select="$agent"/>
              <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:publisher/tei:orgName">
                <xsl:if test="position() = 1">
                  <xsl:value-of select="replace(., ' ', '_')"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:attribute>
            <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:publisher/tei:orgName">
              <xsl:if test="position() = 1">
                <skos:prefLabel>
                  <xsl:attribute name="xml:lang">
                    <xsl:text>de</xsl:text>
                  </xsl:attribute>
                  <xsl:value-of select="."/> 
                </skos:prefLabel>
              </xsl:if>
            </xsl:for-each>
          </foaf:Organization>
        </dc:contributor>
        
        <dm2e:displayLevel rdf:datatype="http://www.w3.org/2001/XMLSchema#boolean">
          <xsl:text>false</xsl:text>
        </dm2e:displayLevel>
        
      </ore:Aggregation>
    
  <!-- End of Frontpage -->
  
  
  <!-- Remaining pages --> 
    
    <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:pb">
      <ore:Aggregation>
        <xsl:attribute name="rdf:about">
          <xsl:value-of select="$aggregation"/>
          <xsl:value-of select="concat('page_',@xml:id)"/>
        </xsl:attribute>
 
        <edm:aggregatedCHO>
          
          
  <!-- Begin CHO (Remaining pages) -->
        
           <edm:ProvidedCHO>
              <xsl:attribute name="rdf:about">
                <xsl:value-of select="$cho"/>
                <xsl:value-of select="concat('page_',@xml:id)"/>
              </xsl:attribute>
 
            <edm:type>
              <xsl:text>TEXT</xsl:text>
            </edm:type>
             
            <dc:type>
              <xsl:attribute name="rdf:resource">
                <xsl:text>http://onto.dm2e.eu/schemas/dm2e/Page</xsl:text>
              </xsl:attribute>
            </dc:type>
             
             <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:sourceDesc/tei:biblFull/tei:titleStmt/tei:title">
               <xsl:if test="position() = 1">
                 <dc:title>
                   <xsl:attribute name="xml:lang">
                     <xsl:text>de</xsl:text>
                   </xsl:attribute> 
                   <xsl:value-of select="."/>
                 </dc:title>
               </xsl:if>
               <xsl:if test="position() > 1">
                 <dc:subtitle>
                   <xsl:attribute name="xml:lang">
                     <xsl:text>de</xsl:text>
                   </xsl:attribute> 
                   <xsl:value-of select="."/>
                 </dc:subtitle>
               </xsl:if>
             </xsl:for-each>
             
             <xsl:choose>
               <xsl:when test="following-sibling::tei:head">
                 <dcterms:subtitle>   
                   <xsl:attribute name="xml:lang">
                     <xsl:text>de</xsl:text>
                   </xsl:attribute>
                       <xsl:value-of select="following-sibling::tei:head"/>
                 </dcterms:subtitle>     
               </xsl:when>
               <xsl:otherwise> 
                 <xsl:choose>
                   <xsl:when test="following-sibling::tei:pb">
                     <dcterms:subtitle>   
                       <xsl:attribute name="xml:lang">
                         <xsl:text>de</xsl:text>
                       </xsl:attribute>
                     </dcterms:subtitle> 
                   </xsl:when>
                   <xsl:otherwise>
                     <xsl:choose>
                       <xsl:when test="not(parent::node()/following-sibling::*[1][child::*[1][self::tei:head]]) or following-sibling::*[child::*[self::tei:pb]]">
                         <dcterms:subtitle>   
                           <xsl:attribute name="xml:lang">
                             <xsl:text>de</xsl:text>
                           </xsl:attribute>
                         </dcterms:subtitle>
                       </xsl:when>
                       <xsl:otherwise>
                         <dcterms:subtitle>   
                           <xsl:attribute name="xml:lang">
                             <xsl:text>de</xsl:text>
                           </xsl:attribute>
                           <xsl:for-each select="following::tei:div/tei:head">
                             <xsl:if test="position()=1">
                               <xsl:value-of select="."/>
                             </xsl:if>
                           </xsl:for-each>
                         </dcterms:subtitle>
                       </xsl:otherwise>
                     </xsl:choose>
                   </xsl:otherwise>
                 </xsl:choose>
                 </xsl:otherwise> 
                </xsl:choose>
                       
            
            <dc:language>
              <xsl:text>de</xsl:text>
            </dc:language>
             
             <dc:subject>
              <skos:Concept>
                <xsl:attribute name="rdf:about">
                  <xsl:value-of select="$subject"/>
                </xsl:attribute>
                <skos:prefLabel>
                  <xsl:attribute name="xml:lang">
                    <xsl:text>en</xsl:text>
                  </xsl:attribute>
                  <xsl:value-of select="$DEF_SUBJECT"/>
                </skos:prefLabel>
              </skos:Concept>
            </dc:subject>
            
            
             
             <bibo:number rdf:datatype="http://www.w3.org/2001/XMLSchema#int">
               <xsl:value-of select="number(@n)"/>
             </bibo:number>
             
             
             <pro:author>
               <foaf:Person> 
                 <xsl:attribute name="rdf:about">
                   <xsl:value-of select="$agent"/>
                   <xsl:for-each select="tei:TEI/tei:text/tei:front/tei:titlePart/tei:persName">
                     <xsl:if test="position() = 1">
                       <xsl:value-of select="encode-for-uri(replace(., ' ', '_'))"/>
                     </xsl:if>
                   </xsl:for-each>
                 </xsl:attribute>
                 <xsl:for-each select="tei:TEI/tei:text/tei:front/tei:titlePart/tei:persName">
                   <xsl:if test="position() = 1">
                     <skos:prefLabel>
                       <xsl:attribute name="xml:lang">
                         <xsl:text>de</xsl:text>
                       </xsl:attribute>
                       <xsl:value-of select="."/>
                     </skos:prefLabel>
                   </xsl:if>
                 </xsl:for-each>
               </foaf:Person>
             </pro:author>
     
        <!-- Related CHOs (Remaining pages) -->
             
             <dcterms:isPartOf>
               <edm:ProvidedCHO>
                 <xsl:attribute name="rdf:about">
                   <xsl:value-of select="$cho"/>
                   <xsl:value-of select="concat('issue_', substring-before(@xml:id,'_'))"/>
                 </xsl:attribute>
               </edm:ProvidedCHO>
             </dcterms:isPartOf>      
             
             <edm:isNextInSequence>
               <edm:ProvidedCHO>
                 <xsl:attribute name="rdf:about">
                   <xsl:value-of select="$cho"/>
                   <xsl:variable name="stringback">
                     <xsl:value-of select="string(number(substring-after(@xml:id, '_pb'))-1)"/>
                   </xsl:variable>
                   <xsl:value-of select="if(string-length($stringback)=1)
                     then concat('page_',(substring-before(@xml:id, '_')),'_pb00', $stringback)
                     else if (string-length($stringback) = 2 )
                     then concat('page_',(substring-before(@xml:id, '_')),'_pb0', $stringback)
                     else concat('page_',(substring-before(@xml:id, '_')),'_pb', $stringback)"/>
                 </xsl:attribute>
               </edm:ProvidedCHO>
             </edm:isNextInSequence> 
             
             <dm2e:levelOfHierarchy rdf:datatype="http://www.w3.org/2001/XMLSchema#int">
               <xsl:text>4</xsl:text>
             </dm2e:levelOfHierarchy>
             
             <!-- <dm2e:remainingPages>
               Kommt von Remaining pages
             </dm2e:remainingPages> -->
            
            <!-- <!-\- TODO  -\->
             <dc:codePoint>
               <xsl:call-template name="Recursion">
                 <xsl:with-param name="count" select="48"/>
                 <xsl:with-param name="sequenceLenght" select="count(string-to-codepoints(substring-after((@xml:id),'_pb')))"/>
                 <!-\-select="subsequence(((string-to-codepoints(substring-after((@xml:id),'_pb')))),$sequenceLenght)"-\-> 
               </xsl:call-template>
               <xsl:value-of select="(codepoints-to-string(string-to-codepoints(substring-after((@xml:id),'_pb'))))"/>
               <!-\-<xsl:value-of select=" count(string-to-codepoints(substring-after((@xml:id),'_pb')))"/>-\->
             </dc:codePoint>-->
           
     
          </edm:ProvidedCHO>
        </edm:aggregatedCHO>
   
        <!-- End of CHO (Remaining pages) -->
        
        
        <!-- Aggregation (Remaining pages) -->
       <edm:object>
         <edm:WebResource>
           <xsl:attribute name="rdf:about">
             <xsl:for-each select="tei:TEI/tei:text/tei:front/tei:pb">
               <xsl:if test="position() = 1">
                 <xsl:value-of select= "concat('http://dingler.culture.hu-berlin.de/journal/page/',
                   substring-before(@xml:id,'_'),'?p=',substring-after(@facs,'/'))"/>
               </xsl:if>
             </xsl:for-each>
           </xsl:attribute>    
         </edm:WebResource>
       </edm:object>
       
        <dm2e:hasAnnotatableVersionAt>
          <edm:WebResource>
            <xsl:attribute name="rdf:about">
              <xsl:value-of select= "concat('http://dingler.culture.hu-berlin.de/journal/page/',
                  substring-before(@xml:id,'_'),'?p=',substring-after(@facs,'/'))"/>
            </xsl:attribute>
            <dc:format>
              <xsl:text>text/plain</xsl:text>
            </dc:format>
            <dc:format>
              <xsl:text>image/jpeg</xsl:text>
            </dc:format>
          </edm:WebResource>
        </dm2e:hasAnnotatableVersionAt>
        
        <edm:provider>
          <foaf:Organization>
            <xsl:attribute name="rdf:about">
              <xsl:value-of select="$agent"/>
              <xsl:text>DM2E</xsl:text>
            </xsl:attribute>
            <skos:prefLabel>
              <xsl:attribute name="xml:lang">
                <xsl:text>de</xsl:text>
              </xsl:attribute>
              <xsl:text>DM2E</xsl:text>
            </skos:prefLabel>
          </foaf:Organization>
        </edm:provider>
        
        <edm:dataProvider>
          <foaf:Organization>
            <xsl:attribute name="rdf:about">
              <xsl:value-of select="$agent"/>
              <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:publisher">
                <xsl:if test="position() = 1">
                  <xsl:value-of select="."/>
                </xsl:if>
              </xsl:for-each>
            </xsl:attribute>
              <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:publisher">
                <xsl:if test="position() = 1">
                  <skos:prefLabel>
                    <xsl:attribute name="xml:lang">
                      <xsl:text>de</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                  </skos:prefLabel>
                </xsl:if>
              </xsl:for-each>
          </foaf:Organization>
        </edm:dataProvider>
 
        <edm:rights>
          <xsl:attribute name="rdf:resource">
            <xsl:value-of select="$RIGHTS_RESOURCE"/>
          </xsl:attribute>
        </edm:rights>
        
        <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:idno">
          <edm:isShownBy>
            <xsl:for-each select=".">
              <edm:WebResource>
                <xsl:if test=".">
                  <xsl:attribute name="rdf:about">
                    <xsl:for-each select=".">
                      <xsl:if test="position() = 1">
                        <xsl:value-of select="substring-before(.,'/ar')"/>
                      </xsl:if>
                    </xsl:for-each>
                  </xsl:attribute>
                </xsl:if>
                <xsl:for-each select="../../tei:seriesStmt/tei:title">
                  <dc:description>
                    <xsl:attribute name="xml:lang">
                      <xsl:text>de</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                  </dc:description>
                </xsl:for-each>
                <dcterms:rightsHolder>
                  <foaf:Organization>
                    <xsl:attribute name="rdf:about">
                      <xsl:value-of select="$agent"/>
                      <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:persName">
                        <xsl:if test="position() = 1">
                          <xsl:value-of select="encode-for-uri(.)"/>
                        </xsl:if>
                      </xsl:for-each>
                    </xsl:attribute>
                    <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:persName">
                      <xsl:if test="position() = 1">
                        <skos:prefLabel>
                          <xsl:attribute name="xml:lang">
                            <xsl:text>de</xsl:text>
                          </xsl:attribute>
                          <xsl:value-of select="."/>
                        </skos:prefLabel>
                      </xsl:if>
                    </xsl:for-each>
                  </foaf:Organization>
                </dcterms:rightsHolder>
                
                <edm:isDerivativeOf>
                  <edm:WebResource>
                    <xsl:if test=".">
                      <xsl:attribute name="rdf:about">
                        <xsl:for-each select=".">
                          <xsl:if test="position() = 1">
                            <xsl:value-of select="substring-before(.,'article')"/>
                          </xsl:if>
                        </xsl:for-each>
                      </xsl:attribute>
                    </xsl:if>
                    <dcterms:rightsHolder>
                      <foaf:Organization>
                        <xsl:attribute name="rdf:about">
                          <xsl:value-of select="$agent"/>
                          <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:persName">
                            <xsl:if test="position() = 1">
                              <xsl:value-of select="encode-for-uri(.)"/>
                            </xsl:if>
                          </xsl:for-each>
                        </xsl:attribute>
                        <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:persName">
                          <xsl:if test="position() = 1">
                            <skos:prefLabel>
                              <xsl:attribute name="xml:lang">
                                <xsl:text>de</xsl:text>
                              </xsl:attribute>
                              <xsl:value-of select="."/>
                            </skos:prefLabel>
                          </xsl:if>
                        </xsl:for-each>
                      </foaf:Organization>
                    </dcterms:rightsHolder>
                  </edm:WebResource>
                </edm:isDerivativeOf>
              </edm:WebResource>
            </xsl:for-each>
          </edm:isShownBy>
        </xsl:for-each>
        
        <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:date/@when">
          <dcterms:created rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                <xsl:if test="position() = 1">
                  <xsl:value-of select="dateTime(xs:date(.),$start)"/>
                </xsl:if>
          </dcterms:created>
        </xsl:for-each>
        
        <dc:creator>
          <foaf:Organization>
            <xsl:attribute name="rdf:about">
              <xsl:value-of select="$agent"/>
              <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:persName">
                <xsl:if test="position() = 1">
                  <xsl:value-of select="encode-for-uri(.)"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:attribute>
            <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:persName">
              <xsl:if test="position() = 1">
                <skos:prefLabel>
                  <xsl:attribute name="xml:lang">
                    <xsl:text>de</xsl:text>
                  </xsl:attribute>
                  <xsl:value-of select="."/>
                </skos:prefLabel>
              </xsl:if>
            </xsl:for-each>
          </foaf:Organization>
        </dc:creator>
        
        <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:persName">
          <dc:contributor>
            <foaf:Person>
              <xsl:attribute name="rdf:about">
                <xsl:value-of select="$agent"/>
                <xsl:for-each select=".">
                  <xsl:if test="position() = 1">
                    <xsl:value-of select="encode-for-uri(.)"/>
                  </xsl:if>
                </xsl:for-each>
              </xsl:attribute>
              <xsl:for-each select=".">
                <xsl:if test="position() = 1">
                  <skos:prefLabel>
                    <xsl:attribute name="xml:lang">
                      <xsl:text>de</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                  </skos:prefLabel>
                </xsl:if>
              </xsl:for-each>
            </foaf:Person>
          </dc:contributor>
        </xsl:for-each>
        
        <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:orgName">
          <dc:contributor>
            <foaf:Organization>
              <xsl:attribute name="rdf:about">
                <xsl:value-of select="$agent"/>
                <xsl:for-each select=".">
                  <xsl:if test="position() = 1">
                    <xsl:value-of select="encode-for-uri(.)"/>
                  </xsl:if>
                </xsl:for-each>
              </xsl:attribute>
              <xsl:for-each select=".">
                <xsl:if test="position() = 1">
                  <skos:prefLabel>
                    <xsl:attribute name="xml:lang">
                      <xsl:text>de</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                  </skos:prefLabel>
                </xsl:if>
              </xsl:for-each>
            </foaf:Organization>
          </dc:contributor>
        </xsl:for-each>
        
        <dc:contributor>
          <foaf:Organization>
            <xsl:attribute name="rdf:about">
              <xsl:value-of select="$agent"/>
              <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:publisher/tei:orgName">
                <xsl:if test="position() = 1">
                  <xsl:value-of select="replace(., ' ', '_')"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:attribute>
            <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:publisher/tei:orgName">
              <xsl:if test="position() = 1">
                <skos:prefLabel>
                  <xsl:attribute name="xml:lang">
                    <xsl:text>de</xsl:text>
                  </xsl:attribute>
                  <xsl:value-of select="."/> 
                </skos:prefLabel>
              </xsl:if>
            </xsl:for-each>
          </foaf:Organization>
        </dc:contributor>
        
        <dm2e:displayLevel rdf:datatype="http://www.w3.org/2001/XMLSchema#boolean">
            <xsl:text>false</xsl:text>
        </dm2e:displayLevel>
        
      </ore:Aggregation>
    </xsl:for-each>
    
     <!-- Remaining pages under div:p:pb--> 
    
    <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:p/tei:pb">
      <ore:Aggregation>
        <xsl:attribute name="rdf:about">
          <xsl:value-of select="$aggregation"/>
          <xsl:value-of select="concat('page_',@xml:id)"/>
        </xsl:attribute>
 
        <edm:aggregatedCHO>
          
          
          <!-- Begin CHO (div:p:pb) -->
        
           <edm:ProvidedCHO>
              <xsl:attribute name="rdf:about">
                <xsl:value-of select="$cho"/>
                <xsl:value-of select="concat('page_',@xml:id)"/>
              </xsl:attribute>
 
            <edm:type>
              <xsl:text>TEXT</xsl:text>
            </edm:type>
             
            <dc:type>
              <xsl:attribute name="rdf:resource">
                <xsl:text>http://onto.dm2e.eu/schemas/dm2e/Page</xsl:text>
              </xsl:attribute>
            </dc:type>
             
             <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:sourceDesc/tei:biblFull/tei:titleStmt/tei:title">
               <xsl:if test="position() = 1">
                 <dc:title>
                   <xsl:attribute name="xml:lang">
                     <xsl:text>de</xsl:text>
                   </xsl:attribute> 
                   <xsl:value-of select="."/>
                 </dc:title>
               </xsl:if>
               <xsl:if test="position() > 1">
                 <dc:subtitle>
                   <xsl:attribute name="xml:lang">
                     <xsl:text>de</xsl:text>
                   </xsl:attribute> 
                   <xsl:value-of select="."/>
                 </dc:subtitle>
               </xsl:if>
             </xsl:for-each>
             
          
          <!-- To do: klappt nicht mehr -->
          
             <xsl:choose>
               <xsl:when test="following-sibling::tei:head">
                 <dcterms:subtitle2>   
                   <xsl:attribute name="xml:lang">
                     <xsl:text>de</xsl:text>
                   </xsl:attribute>
                   <xsl:value-of select="following-sibling::tei:head"/>
                 </dcterms:subtitle2>     
               </xsl:when>
               <xsl:otherwise> 
                 <xsl:choose>
                   <xsl:when test="following-sibling::tei:pb">
                     <dcterms:subtitle3>   
                       <xsl:attribute name="xml:lang">
                         <xsl:text>de</xsl:text>
                       </xsl:attribute>
                     </dcterms:subtitle3> 
                   </xsl:when>
                   <xsl:otherwise>
                     <xsl:choose>
                       <xsl:when test="not(parent::node()/parent::node()/following-sibling::*[1][child::*[1][self::tei:head]]) or following-sibling::*[child::*[self::tei:pb]]">
                         <dcterms:subtitle4>   
                           <xsl:attribute name="xml:lang">
                             <xsl:text>de</xsl:text>
                           </xsl:attribute>
                         </dcterms:subtitle4>
                       </xsl:when>
                       <xsl:otherwise>
                         <dcterms:subtitle5>   
                           <xsl:attribute name="xml:lang">
                             <xsl:text>de</xsl:text>
                           </xsl:attribute>
                           <xsl:for-each select="following::tei:div/tei:head">
                             <xsl:if test="position()=1">
                               <xsl:value-of select="."/>
                             </xsl:if>
                           </xsl:for-each>
                         </dcterms:subtitle5>
                       </xsl:otherwise>
                     </xsl:choose>
                   </xsl:otherwise>
                 </xsl:choose>
               </xsl:otherwise> 
             </xsl:choose>
            
            <dc:language>
              <xsl:text>de</xsl:text>
            </dc:language>
             
             <dc:subject>
               <skos:Concept>
                 <xsl:attribute name="rdf:about">
                   <xsl:value-of select="$subject"/>
                 </xsl:attribute>
                 <skos:prefLabel>
                   <xsl:attribute name="xml:lang">
                     <xsl:text>en</xsl:text>
                   </xsl:attribute>
                   <xsl:value-of select="$DEF_SUBJECT"/>
                 </skos:prefLabel>
               </skos:Concept>
             </dc:subject>
            
             
             <bibo:number rdf:datatype="http://www.w3.org/2001/XMLSchema#int">
               <xsl:value-of select="@n"/>
            </bibo:number>
             
      <!-- To do: Hier klappt pro:author nicht -->
      
             <pro:author>
               <foaf:Person> 
                 <xsl:attribute name="rdf:about">
                   <xsl:value-of select="$agent"/>
                   <xsl:for-each select="tei:TEI/tei:text/tei:front/tei:titlePart/tei:persName">
                     <xsl:if test="position() = 1">
                       <xsl:value-of select="encode-for-uri(replace(., ' ', '_'))"/>
                     </xsl:if>
                   </xsl:for-each>
                 </xsl:attribute>
                 <xsl:for-each select="tei:TEI/tei:text/tei:front/tei:titlePart/tei:persName">
                   <xsl:if test="position() = 1">
                     <skos:prefLabel>
                       <xsl:attribute name="xml:lang">
                         <xsl:text>de</xsl:text>
                       </xsl:attribute>
                       <xsl:value-of select="."/>
                     </skos:prefLabel>
                   </xsl:if>
                 </xsl:for-each>
               </foaf:Person>
             </pro:author>
     
             <!-- Related CHOs (div:p:pb) -->
             
             <dcterms:isPartOf>
               <edm:ProvidedCHO>
                 <xsl:attribute name="rdf:about">
                   <xsl:value-of select="$cho"/>
                   <xsl:value-of select="concat('issue_', substring-before(@xml:id,'_'))"/>
                 </xsl:attribute>
               </edm:ProvidedCHO>
             </dcterms:isPartOf>      
             
             <!-- TODOs the function for constructing the URI for the previous CHO has to be further develop -->
            <!-- <edm:isNextInSequence>
               <edm:ProvidedCHO>
                 <xsl:attribute name="rdf:about">
                   <xsl:value-of select="$cho"/>
                   <xsl:value-of select="concat('page_',(substring-before(@xml:id, '_')),'_pb',(string(number(substring-after(@xml:id, '_pb0'))-1)))"/>
                   </xsl:attribute>
               </edm:ProvidedCHO>
             </edm:isNextInSequence> -->
             
             <edm:isNextInSequence>
               <edm:ProvidedCHO>
                 <xsl:attribute name="rdf:about">
                   <xsl:value-of select="$cho"/>
                   <xsl:variable name="stringback">
                     <xsl:value-of select="string(number(substring-after(@xml:id, '_pb'))-1)"/>
                   </xsl:variable>
                   <xsl:value-of select="if(string-length($stringback)=1)
                     then concat('page_',(substring-before(@xml:id, '_')),'_pb00', $stringback)
                     else if (string-length($stringback) = 2 )
                     then concat('page_',(substring-before(@xml:id, '_')),'_pb0', $stringback)
                     else concat('page_',(substring-before(@xml:id, '_')),'_pb', $stringback)"/>
                 </xsl:attribute>
               </edm:ProvidedCHO>
             </edm:isNextInSequence> 
             
             <dm2e:levelOfHierarchy rdf:datatype="http://www.w3.org/2001/XMLSchema#int">
               <xsl:text>4</xsl:text>
             </dm2e:levelOfHierarchy>
        
            <!-- <dm2e:remainingPagesUnderDivPpB>
               Kommt von Remaining pages under div:p:pb 
             </dm2e:remainingPagesUnderDivPpB> -->
             
             
          </edm:ProvidedCHO>
        </edm:aggregatedCHO>
   
        <!-- End of CHO (div:p:pb) -->
        
        
        <!-- Aggregation (div:p:pb) -->
       
        <edm:object>
          <edm:WebResource>
            <xsl:attribute name="rdf:about">
              <xsl:value-of select= "concat('http://dingler.culture.hu-berlin.de/journal/page/',
                substring-before(@xml:id,'_'),'?p=',substring-after(@facs,'/'))"/>
            </xsl:attribute>
          </edm:WebResource>
        </edm:object>
        
        <dm2e:hasAnnotatableVersionAt>
          <edm:WebResource>
            <xsl:attribute name="rdf:about">
              <xsl:value-of select= "concat('http://dingler.culture.hu-berlin.de/journal/page/',
                  substring-before(@xml:id,'_'),'?p=',substring-after(@facs,'/'))"/>
            </xsl:attribute>
              <dc:format>
              <xsl:text>text/plain</xsl:text>
            </dc:format>
            <dc:format>
              <xsl:text>image/jpeg</xsl:text>
            </dc:format>
          </edm:WebResource>
        </dm2e:hasAnnotatableVersionAt>
        
        <edm:provider>
          <foaf:Organization>
            <xsl:attribute name="rdf:about">
              <xsl:value-of select="$agent"/>
              <xsl:text>DM2E</xsl:text>
            </xsl:attribute>
            <skos:prefLabel>
              <xsl:attribute name="xml:lang">
                <xsl:text>de</xsl:text>
              </xsl:attribute>
              <xsl:text>DM2E</xsl:text>
            </skos:prefLabel>
          </foaf:Organization>
        </edm:provider>
        
        <edm:dataProvider>
          <foaf:Organization>
            <xsl:attribute name="rdf:about">
              <xsl:value-of select="$agent"/>
              <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:publisher">
                <xsl:if test="position() = 1">
                  <xsl:value-of select="."/>
                </xsl:if>
              </xsl:for-each>
            </xsl:attribute>
              <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:publisher">
                <xsl:if test="position() = 1">
                  <skos:prefLabel>
                    <xsl:attribute name="xml:lang">
                      <xsl:text>de</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                  </skos:prefLabel>
                </xsl:if>
              </xsl:for-each>
          </foaf:Organization>
        </edm:dataProvider>
 
        <edm:rights>
          <xsl:attribute name="rdf:resource">
            <xsl:value-of select="$RIGHTS_RESOURCE"/>
          </xsl:attribute>
        </edm:rights>
        
        <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:idno">
          <edm:isShownBy>
            <xsl:for-each select=".">
              <edm:WebResource>
                <xsl:if test=".">
                  <xsl:attribute name="rdf:about">
                    <xsl:for-each select=".">
                      <xsl:if test="position() = 1">
                        <xsl:value-of select="substring-before(.,'/ar')"/>
                      </xsl:if>
                    </xsl:for-each>
                  </xsl:attribute>
                </xsl:if>
                <xsl:for-each select="../../tei:seriesStmt/tei:title">
                  <dc:description>
                    <xsl:attribute name="xml:lang">
                      <xsl:text>de</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                  </dc:description>
                </xsl:for-each>
                <dcterms:rightsHolder>
                  <foaf:Organization>
                    <xsl:attribute name="rdf:about">
                      <xsl:value-of select="$agent"/>
                      <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:persName">
                        <xsl:if test="position() = 1">
                          <xsl:value-of select="encode-for-uri(.)"/>
                        </xsl:if>
                      </xsl:for-each>
                    </xsl:attribute>
                    <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:persName">
                      <xsl:if test="position() = 1">
                        <skos:prefLabel>
                          <xsl:attribute name="xml:lang">
                            <xsl:text>de</xsl:text>
                          </xsl:attribute>
                          <xsl:value-of select="."/>
                        </skos:prefLabel>
                      </xsl:if>
                    </xsl:for-each>
                  </foaf:Organization>
                </dcterms:rightsHolder>
                
                <edm:isDerivativeOf>
                  <xsl:if test=".">
                    <xsl:attribute name="rdf:resource">
                      <xsl:for-each select=".">
                        <xsl:if test="position() = 1">
                          <xsl:value-of select="substring-before(.,'article')"/>
                        </xsl:if>
                      </xsl:for-each>
                    </xsl:attribute>
                  </xsl:if>
                </edm:isDerivativeOf>
              </edm:WebResource>
            </xsl:for-each>
          </edm:isShownBy>
        </xsl:for-each>
        
        <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:date/@when">
          <dcterms:created rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
            <xsl:if test="position() = 1">
              <xsl:value-of select="dateTime(xs:date(.),$start)"/>
            </xsl:if>
          </dcterms:created>
          <!-- <dcterms:created>
            <xsl:attribute name="xsd:dateTime">
            <xsl:if test="position() = 1">
              <xsl:value-of select="dateTime(xs:date(.),$start)"/>
            </xsl:if>
            </xsl:attribute>
          </dcterms:created> -->
        </xsl:for-each>
        
        <dc:creator>
          <foaf:Organization>
            <xsl:attribute name="rdf:about">
              <xsl:value-of select="$agent"/>
              <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:persName">
                <xsl:if test="position() = 1">
                  <xsl:value-of select="encode-for-uri(.)"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:attribute>
            <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:persName">
              <xsl:if test="position() = 1">
                <skos:prefLabel>
                  <xsl:attribute name="xml:lang">
                    <xsl:text>de</xsl:text>
                  </xsl:attribute>
                  <xsl:value-of select="."/>
                </skos:prefLabel>
              </xsl:if>
            </xsl:for-each>
          </foaf:Organization>
        </dc:creator>
        
        <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:persName">
          <dc:contributor>
            <foaf:Person>
              <xsl:attribute name="rdf:about">
                <xsl:value-of select="$agent"/>
                <xsl:for-each select=".">
                  <xsl:if test="position() = 1">
                    <xsl:value-of select="encode-for-uri(.)"/>
                  </xsl:if>
                </xsl:for-each>
              </xsl:attribute>
              <xsl:for-each select=".">
                <xsl:if test="position() = 1">
                  <skos:prefLabel>
                    <xsl:attribute name="xml:lang">
                      <xsl:text>de</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                  </skos:prefLabel>
                </xsl:if>
              </xsl:for-each>
            </foaf:Person>
          </dc:contributor>
        </xsl:for-each>
        
        <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:orgName">
          <dc:contributor>
            <foaf:Organization>
              <xsl:attribute name="rdf:about">
                <xsl:value-of select="$agent"/>
                <xsl:for-each select=".">
                  <xsl:if test="position() = 1">
                    <xsl:value-of select="encode-for-uri(.)"/>
                  </xsl:if>
                </xsl:for-each>
              </xsl:attribute>
              <xsl:for-each select=".">
                <xsl:if test="position() = 1">
                  <skos:prefLabel>
                    <xsl:attribute name="xml:lang">
                      <xsl:text>de</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                  </skos:prefLabel>
                </xsl:if>
              </xsl:for-each>
            </foaf:Organization>
          </dc:contributor>
        </xsl:for-each>
        
        <dc:contributor>
          <foaf:Organization>
            <xsl:attribute name="rdf:about">
              <xsl:value-of select="$agent"/>
              <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:publisher/tei:orgName">
                <xsl:if test="position() = 1">
                  <xsl:value-of select="replace(., ' ', '_')"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:attribute>
            <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:publisher/tei:orgName">
              <xsl:if test="position() = 1">
                <skos:prefLabel>
                  <xsl:attribute name="xml:lang">
                    <xsl:text>de</xsl:text>
                  </xsl:attribute>
                  <xsl:value-of select="."/> 
                </skos:prefLabel>
              </xsl:if>
            </xsl:for-each>
          </foaf:Organization>
        </dc:contributor>
        
        <dm2e:displayLevel rdf:datatype="http://www.w3.org/2001/XMLSchema#boolean">
            <xsl:text>false</xsl:text>
        </dm2e:displayLevel>
        
      </ore:Aggregation>
    </xsl:for-each>
   
  </xsl:template>
</xsl:stylesheet>
