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
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  >
  
  
  <xsl:template name="Journal">
    <xsl:param name="theTEIHeader" as="node()"/>
    
      <ore:Aggregation>
        <xsl:attribute name="rdf:about">
          <xsl:value-of select="$aggregation"/>
          <xsl:value-of select="replace($DEF_DATAPROVIDER, ' ', '_')"/>
          <!-- <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:sourceDesc/tei:biblFull/tei:seriesStmt/tei:title">
            <xsl:if test="position() = 1">
              <xsl:value-of select="replace(., ' ', '_')"/>
            </xsl:if>
          </xsl:for-each> -->
        </xsl:attribute>
        
        <edm:aggregatedCHO>
          
          
          <!-- Begin CHO -->
                    
          <edm:ProvidedCHO>
            <xsl:attribute name="rdf:about">
              <xsl:value-of select="$cho"/>
              <xsl:value-of select="replace($DEF_DATAPROVIDER, ' ', '_')"/>
              <!-- <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:sourceDesc/tei:biblFull/tei:seriesStmt/tei:title">
                <xsl:if test="position() = 1">
                  <xsl:value-of select="replace(., ' ', '_')"/>
                  <xsl:value-of select="concat('journal/',.)"/> 
                </xsl:if>
              </xsl:for-each> -->
            </xsl:attribute>
            
            <edm:type>
              <xsl:text>TEXT</xsl:text>
            </edm:type>
            
            <dc:type>
              <xsl:attribute name="rdf:resource">
                <xsl:text>http://purl.org/ontology/bibo/Journal</xsl:text>
              </xsl:attribute>
            </dc:type>
            
            <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:sourceDesc/tei:biblFull/tei:seriesStmt/tei:title">
              <dc:title>
                <xsl:attribute name="xml:lang">
                  <xsl:text>de</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="."/>
              </dc:title>
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
            
            <dcterms:issued>
              <edm:TimeSpan>
                <xsl:attribute name="rdf:about">
                  <xsl:value-of select="$timespan"/>
                  <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:sourceDesc/tei:biblFull/tei:publicationStmt/tei:date">
                    <xsl:if test="position() = 1">
                      <xsl:call-template name="dateTimePeriod"/>
                    </xsl:if>
                  </xsl:for-each>
                </xsl:attribute>
                
                <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:sourceDesc/tei:biblFull/tei:publicationStmt/tei:date">
                                             
                  <edm:begin rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                    <xsl:if test="position() = 1">
                    <xsl:variable name="date" select="xs:date((concat(.,'-01-01')))"/>
                    <xsl:value-of select="dateTime($date,$start)"/>
                    </xsl:if>
                  </edm:begin>
                  
                </xsl:for-each>
                <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:sourceDesc/tei:biblFull/tei:publicationStmt/tei:date">
                  
                  <edm:end rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                    <xsl:if test="position() = 1">
                    <xsl:variable name="date" select="xs:date((concat(.,'-12-31')))"/>
                    <xsl:value-of select="dateTime($date,$end)"/>
                    </xsl:if>
                  </edm:end>
                  
                </xsl:for-each>
              </edm:TimeSpan>
            </dcterms:issued>
            
            <dm2e:publishedAt>
              <edm:Place>
                <xsl:attribute name="rdf:about">
                  <xsl:value-of select="$place"/>
                  <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:sourceDesc/tei:biblFull/tei:publicationStmt/tei:pubPlace">
                    <xsl:if test="position() = 1">
                      <xsl:value-of select="."/>
                    </xsl:if>
                  </xsl:for-each>
                </xsl:attribute>
                <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:sourceDesc/tei:biblFull/tei:publicationStmt/tei:pubPlace">
                  <xsl:if test="position() = 1">
                    <skos:prefLabel>
                      <xsl:attribute name="xml:lang">
                        <xsl:text>de</xsl:text>
                      </xsl:attribute>
                      <xsl:value-of select="."/>
                    </skos:prefLabel>
                  </xsl:if>
                </xsl:for-each>
              </edm:Place>
            </dm2e:publishedAt>
            
         <!--   <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:sourceDesc/tei:biblFull/tei:seriesStmt/tei:title">
              <dc:identifier>
                <xsl:value-of select="."/>
              </dc:identifier>
            </xsl:for-each> -->
            
            <dc:publisher>
              <foaf:Organization>
                <xsl:attribute name="rdf:about">
                  <xsl:value-of select="$agent"/>
                  <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:sourceDesc/tei:biblFull/tei:publicationStmt/tei:publisher/tei:name">
                    <xsl:if test="position() = 1">
                      <xsl:value-of select="replace(., ' ', '_')"/>
                    </xsl:if>
                  </xsl:for-each>
                </xsl:attribute>
                <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:sourceDesc/tei:biblFull/tei:publicationStmt/tei:publisher/tei:name">
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
            </dc:publisher>
            
            <bibo:editor>
              <foaf:Person>
                <xsl:attribute name="rdf:about">
                  <xsl:value-of select="$agent"/>
                  <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:sourceDesc/tei:biblFull/tei:titleStmt/tei:editor/tei:persName">
                    <xsl:if test="position() = 1">
                      <xsl:value-of select="replace(., ' ', '_')"/>
                    </xsl:if>
                  </xsl:for-each>
                </xsl:attribute>
                <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:sourceDesc/tei:biblFull/tei:titleStmt/tei:editor/tei:persName">
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
            </bibo:editor>
       
          
            <dm2e:levelOfHierarchy rdf:datatype="http://www.w3.org/2001/XMLSchema#int">
            <xsl:text>1</xsl:text>
          </dm2e:levelOfHierarchy>
      
            
          </edm:ProvidedCHO>
        </edm:aggregatedCHO>
        
        <!-- End of CHO -->
        
        
        <!-- Aggregation -->
        
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
              <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:idno">
                <xsl:if test="position() = 1">
                  <xsl:value-of select="substring(.,1,36)"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:attribute>     
          </edm:WebResource>
        </edm:object>
        
        <dm2e:hasAnnotatableVersionAt>
          <edm:WebResource>
            <xsl:attribute name="rdf:about">
              <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:idno">
                <xsl:if test="position() = 1">
                  <xsl:value-of select="substring(.,1,36)"/>
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
        
     <!--   <edm:isShownAt>
          <edm:WebResource>
            <xsl:if test="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:idno">
              <xsl:attribute name="rdf:about">
                <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:idno">
                  <xsl:if test="position() = 1">
                    <xsl:value-of select="substring(.,1,36)"/>
                  </xsl:if>
                </xsl:for-each>
              </xsl:attribute>
            </xsl:if>
          </edm:WebResource>
        </edm:isShownAt> -->
        
        <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:idno">
          <edm:isShownAt>
            <xsl:for-each select=".">
              <edm:WebResource>
                <xsl:if test=".">
                  <xsl:attribute name="rdf:about">
                    <xsl:for-each select=".">
                      <xsl:if test="position() = 1">
                        <xsl:value-of select="substring(.,1,36)"/>
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
              </edm:WebResource>
            </xsl:for-each>
          </edm:isShownAt>
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
        
        <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:date">
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

  </xsl:template>
  
  <xsl:template name="dateTimePeriod">
    <xsl:variable name="firstDate" select="xs:date((concat(.,'-01-01')))"/>
    <xsl:variable name="lastDate" select="xs:date((concat(.,'-12-31')))"/>
    <xsl:value-of select="encode-for-uri(replace(concat(dateTime($firstDate,$start), 'UG_' , dateTime($lastDate,$end), 'UG'),':',' '))"/>
  </xsl:template>
  
</xsl:stylesheet>
