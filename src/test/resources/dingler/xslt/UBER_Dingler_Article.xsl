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
  xmlns:xml="http://www.w3.org/XML/1998/namespace" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsd="http://www.w3.org/TR/xmlschema-2/"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:template name="Article">
    <xsl:param name="theTEIHeader" as="node()"/>
 
      <ore:Aggregation>
        <xsl:attribute name="rdf:about">
          <xsl:value-of select="$aggregation"/>
          <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:idno">
            <xsl:if test="position() = 1">
              <xsl:value-of select="replace(substring-after(.,'.de/'),'/','_')"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:attribute>
  
        <edm:aggregatedCHO>      
          
          
          <!-- Begin CHO -->
          
          <edm:ProvidedCHO>
            <xsl:attribute name="rdf:about">
              <xsl:value-of select="$cho"/>
              <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:idno">
                <xsl:if test="position() = 1">
                  <xsl:value-of select="replace(substring-after(.,'.de/'),'/','_')"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:attribute>
            
            <edm:type>
              <xsl:text>TEXT</xsl:text>
            </edm:type>
            
            <dc:type>
              <xsl:attribute name="rdf:resource">
                <xsl:text>http://purl.org/spar/fabio/Article</xsl:text>
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
            

            <bibo:pages>
                <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:sourceDesc/tei:biblFull/tei:seriesStmt/tei:biblScope">
                  <xsl:if test="position() = 3">
                    <xsl:value-of select="substring-after(.,'S. ')"/>
                  </xsl:if>
                </xsl:for-each>  
              </bibo:pages>
            
            
            <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:biblScope">
              <xsl:if test="position() = 1">
                <bibo:volume>
                  <xsl:value-of select="."/>
                </bibo:volume>
              </xsl:if>
            </xsl:for-each>
            
            <dcterms:tableOfContents>
              <xsl:attribute name="xml:lang">
                <xsl:text>de</xsl:text>
              </xsl:attribute>
              <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:head">
                <xsl:value-of select="replace(., '&#xa;                                    ', ' ')"/>
                <xsl:text>&#xa;</xsl:text>  
              </xsl:for-each>
            </dcterms:tableOfContents> 
            
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
            
            <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:p/tei:persName">
            <dm2e:mentioned>
              <foaf:Person>
                <xsl:attribute name="rdf:about">
                  <xsl:value-of select="$agent"/>
                  <xsl:value-of select="replace(replace(replace(., '&#xa;                                        ', ' '), ',', ''), ' ', '_')"/>
                </xsl:attribute>
                    <skos:prefLabel>
                      <xsl:attribute name="xml:lang">
                        <xsl:text>de</xsl:text>
                      </xsl:attribute>
                      <xsl:value-of select="replace(., '&#xa;                                        ', ' ')"/>
                    </skos:prefLabel>
              </foaf:Person>
            </dm2e:mentioned>
            </xsl:for-each>
            
            <!-- Related CHOs -->
        
           <!-- <dcterms:isPartOf>
              <edm:ProvidedCHO>
                <xsl:attribute name="rdf:about">
                  <xsl:value-of select="$cho"/>
                  <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:idno">
                    <xsl:if test="position() = 1">
                      <xsl:value-of select="concat('journal/',.)"/>
                    </xsl:if>
                  </xsl:for-each>
                </xsl:attribute>
              </edm:ProvidedCHO>
            </dcterms:isPartOf>   -->
            
            <dcterms:isPartOf>
              <edm:ProvidedCHO>
                <xsl:attribute name="rdf:about">
                  <xsl:value-of select="$cho"/>
                  <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:idno">
                    <xsl:if test="position() = 1">
                      <xsl:value-of select="concat('issue_',(substring-before(substring-after(substring-after(.,'http://dingler.culture.hu-berlin.de/'), '/'),'/')))"/>
                    </xsl:if>
                  </xsl:for-each>
                </xsl:attribute>
              </edm:ProvidedCHO>
            </dcterms:isPartOf>
            
            <dm2e:levelOfHierarchy rdf:datatype="http://www.w3.org/2001/XMLSchema#int">
              <xsl:text>3</xsl:text>
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
        
        <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:idno">
          <edm:isShownAt>
            <xsl:for-each select=".">
              <edm:WebResource>
                <xsl:if test=".">
                  <xsl:attribute name="rdf:about">
                    <xsl:for-each select=".">
                      <xsl:if test="position() = 1">
                        <xsl:value-of select="."/>
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
          </edm:isShownAt>
        </xsl:for-each>
        
        <edm:object>
          <edm:WebResource>
            <xsl:if test="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:idno">
              <xsl:attribute name="rdf:about">
                <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:idno">
                  <xsl:if test="position() = 1">
                    <xsl:value-of select="."/>
                  </xsl:if>
                </xsl:for-each>
              </xsl:attribute>
            </xsl:if>
          </edm:WebResource>
        </edm:object>
        
        <dm2e:hasAnnotatableVersionAt>
          <edm:WebResource>
            <xsl:if test="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:idno">
              <xsl:attribute name="rdf:about">
                <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:idno">
                  <xsl:if test="position() = 1">
                    <xsl:value-of select="."/>
                  </xsl:if>
                </xsl:for-each>
              </xsl:attribute>
              <dc:format>
                <xsl:text>text/plain</xsl:text>
              </dc:format>
            </xsl:if>
          </edm:WebResource>
        </dm2e:hasAnnotatableVersionAt>
         
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
          <xsl:text>true</xsl:text>
        </dm2e:displayLevel>
        
      </ore:Aggregation>
      
  </xsl:template>
</xsl:stylesheet>
