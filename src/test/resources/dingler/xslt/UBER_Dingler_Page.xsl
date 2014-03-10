<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="tei xml xs xsd" version="2.0"
  xml:base="http://onto.dm2e.eu/schemas/dm2e/"
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
  
  
   <!-- Begin CHOs from frontpage with tei:pb-->
      <xsl:choose>
        <xsl:when test="exists(tei:TEI/tei:text/tei:front/tei:pb)">
      
     <!-- Begin Aggregation (Frontpage with tei:pb) -->
      <ore:Aggregation>
        
        <xsl:attribute name="rdf:about">
          <xsl:value-of select="$aggregation"/>
          <xsl:for-each select="tei:TEI/tei:text/tei:front/tei:pb">
                <xsl:if test="position()=1">
                  <xsl:value-of select="concat('page_',@xml:id)"/>
                </xsl:if>
          </xsl:for-each> 
        </xsl:attribute>
        
        <edm:aggregatedCHO>
          
          
          <!-- Begin CHO (Frontpage with tei:pb) -->
 
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
                <dm2e:subtitle>
                  <xsl:attribute name="xml:lang">
                    <xsl:text>de</xsl:text>
                  </xsl:attribute> 
                  <xsl:value-of select="."/>
                </dm2e:subtitle>
              </xsl:if>
            </xsl:for-each>
            
              <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:head">
               <xsl:if test="position()=1">
                <dm2e:subtitle>
                <xsl:attribute name="xml:lang">
                  <xsl:text>de</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="."/> 
               </dm2e:subtitle>
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
            
            <xsl:for-each select="tei:TEI/tei:text/tei:front/tei:pb">
              <xsl:if test="position() = 1">
              <bibo:number rdf:datatype="http://www.w3.org/2001/XMLSchema#unsignedInt">
                <xsl:value-of select="number(@n)"/>
              </bibo:number>
              </xsl:if>
            </xsl:for-each>
           
            
            <xsl:for-each select="tei:TEI/tei:text/tei:front/tei:titlePart/tei:persName">
              <pro:author>
                <foaf:Person> 
                  <xsl:attribute name="rdf:about">
                    <xsl:value-of select="$agent"/>
                    <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/> 
                  </xsl:attribute>
                  <skos:prefLabel>
                    <xsl:attribute name="xml:lang">
                      <xsl:text>de</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                  </skos:prefLabel>
                </foaf:Person>
              </pro:author>
            </xsl:for-each>  
            
            <!-- Related CHOs (Frontpage with tei:pb) -->
            
            <dcterms:isPartOf>
              <edm:ProvidedCHO>
                <xsl:attribute name="rdf:about">
                  <xsl:value-of select="$cho"/>
                  <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:idno">
                    <xsl:if test="position() = 1">
                      <xsl:value-of select="replace(substring-after(.,'.de/'),'/','_')"/>
                    </xsl:if>
                  </xsl:for-each>
                </xsl:attribute> 
              </edm:ProvidedCHO>
            </dcterms:isPartOf>
            
            <dm2e:levelOfHierarchy rdf:datatype="http://www.w3.org/2001/XMLSchema#unsignedInt">
              <xsl:text>4</xsl:text>
            </dm2e:levelOfHierarchy> 
            
          </edm:ProvidedCHO> 
        </edm:aggregatedCHO>
        
        <!-- End of CHO (Frontpage with tei:pb) -->


        <!-- Aggregation (Frontpage with tei:pb) -->
        
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
                  <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
                <owl:sameAs>
                  <xsl:value-of select="@ref"/>
                </owl:sameAs>
              </xsl:if>
            </xsl:for-each>
          </foaf:Organization>
        </edm:dataProvider>
        
        <dcterms:rightsHolder>
          <foaf:Organization>
            <xsl:attribute name="rdf:about">
              <xsl:value-of select="$agent"/>
              <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:persName">
                <xsl:if test="position() = 1">
                  <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
                <skos:note>
                  <xsl:attribute name="xml:lang">
                    <xsl:text>de</xsl:text>
                  </xsl:attribute>
                  <xsl:text>Rightsholder of the ranscriptions metadata.</xsl:text>
                </skos:note>
                <owl:sameAs>
                  <xsl:value-of select="@ref"/>
                </owl:sameAs>
              </xsl:if>
            </xsl:for-each>
          </foaf:Organization>
        </dcterms:rightsHolder>
        
        <dcterms:rightsHolder>
          <foaf:Organization>
            <xsl:attribute name="rdf:about">
              <xsl:value-of select="$agent"/>
              <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:orgName">
                <xsl:if test="position() = 1">
                  <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:attribute>
            <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:orgName">
              <xsl:if test="position() = 1">
                <skos:prefLabel>
                  <xsl:attribute name="xml:lang">
                    <xsl:text>de</xsl:text>
                  </xsl:attribute>
                  <xsl:value-of select="."/>
                </skos:prefLabel>
                <skos:note>
                  <xsl:attribute name="xml:lang">
                    <xsl:text>de</xsl:text>
                  </xsl:attribute>
                  <xsl:text>Rightsholder of the facsimiles.</xsl:text>
                </skos:note>
                <owl:sameAs>
                  <xsl:value-of select="@ref"/>
                </owl:sameAs>
              </xsl:if>
            </xsl:for-each>
          </foaf:Organization>
        </dcterms:rightsHolder>
 
        <edm:rights>
          <xsl:attribute name="rdf:resource">
            <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
          </xsl:attribute>
        </edm:rights>
        
        
        <edm:object>
          <edm:WebResource>
            <xsl:attribute name="rdf:about">
              <xsl:for-each select="tei:TEI/tei:text/tei:front/tei:pb">
                <xsl:if test="position() = 1">
                  <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                    substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/' , substring-after(@facs,'/'),
                    '.tif.thumbnail.jpg')"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:attribute>     
            <dc:format>
              <xsl:text>image/jpeg</xsl:text>
            </dc:format>
            <edm:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
              </xsl:attribute>
            </edm:rights>
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
              <xsl:text>text/html</xsl:text>
            </dc:format>
            <edm:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
              </xsl:attribute>
            </edm:rights>
            <dc:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
              </xsl:attribute>
            </dc:rights>
          </edm:WebResource>
        </dm2e:hasAnnotatableVersionAt> 
        
        <dm2e:hasAnnotatableVersionAt>
          <edm:WebResource>
            <xsl:attribute name="rdf:about">
              <xsl:for-each select="tei:TEI/tei:text/tei:front/tei:pb">
                <xsl:if test="position() = 1">
                  <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                    substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/' , substring-after(@facs,'/'),
                    '.tif.medium.jpg')"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:attribute>     
            <dc:format>
              <xsl:text>image/jpeg</xsl:text>
            </dc:format>
            <edm:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
              </xsl:attribute>
            </edm:rights>
          </edm:WebResource>
        </dm2e:hasAnnotatableVersionAt> 
        
        <edm:isShownBy>
          <edm:WebResource>
            <xsl:attribute name="rdf:about">
              <xsl:for-each select="tei:TEI/tei:text/tei:front/tei:pb">
                <xsl:if test="position() = 1">
                  <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                    substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/' , substring-after(@facs,'/'),
                    '.tif.medium.jpg')"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:attribute> 
            <edm:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
              </xsl:attribute>
            </edm:rights>
          </edm:WebResource>
        </edm:isShownBy> 
        
        <!-- <dm2e:erstesCHO>
              unter tei:pb
            </dm2e:erstesCHO>-->
        
           <edm:isShownAt>
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
                <edm:rights>
                  <xsl:attribute name="rdf:resource">
                    <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
                  </xsl:attribute>
                </edm:rights>
                <dc:rights>
                  <xsl:attribute name="rdf:resource">
                    <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
                  </xsl:attribute>
                </dc:rights>
              </edm:WebResource>
            </xsl:for-each>
          </edm:isShownAt>
        
        <dc:creator>
          <foaf:Organization>
            <xsl:attribute name="rdf:about">
              <xsl:value-of select="$agent"/>
              <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:persName">
                <xsl:if test="position() = 1">
                  <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
                    <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
                    <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
                  <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
  <!-- End of Frontpage with tei:pb -->
          
        </xsl:when>
        
        <xsl:otherwise>
    
    <!-- Beginn Frontpage without tei:pb -->
    
        <xsl:if test="exists($theTEIHeader/tei:fileDesc/tei:sourceDesc/tei:biblFull/tei:seriesStmt/tei:biblScope)">
        <!-- <xsl:for-each select="tei:TEI/tei:fileDesc/tei:sourceDesc/tei:biblFull/tei:seriesStmt/tei:biblScope"> -->
                <ore:Aggregation>
                    <xsl:attribute name="rdf:about">
                      <xsl:value-of select="$aggregation"/>
                      <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:sourceDesc/tei:biblFull/tei:seriesStmt/tei:biblScope">
                        <xsl:if test="position() = 3">    
                          <xsl:variable name="stringback">
                            <xsl:value-of select="string(substring-before(substring-after(. , 'S. '),'-'))"/>
                          </xsl:variable>
                          <!--<xsl:message>
                            DEF_art: <xsl:value-of select="$DEF_ARTICLE_NAME"/>
                            jjsdjdkdfkfklglgllg
                          </xsl:message>-->
                          <xsl:value-of select="if(string-length($stringback)=1)
                            then concat('page_', $DEF_ARTICLE_NAME , '_','pb00', $stringback)
                            else if (string-length($stringback) = 2 )
                            then concat('page_', $DEF_ARTICLE_NAME , '_','pb0', $stringback)
                            else concat('page_', $DEF_ARTICLE_NAME , '_','pb', $stringback)"/>
                        </xsl:if>
                      </xsl:for-each> 
                    </xsl:attribute>
            
                 <edm:aggregatedCHO>
              
              
              <!-- Begin CHO (Frontpage without tei:pb) -->
     
              <edm:ProvidedCHO>
                  <xsl:attribute name="rdf:about">
                    <xsl:value-of select="$cho"/>
                    <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:sourceDesc/tei:biblFull/tei:seriesStmt/tei:biblScope">
                      <xsl:if test="position() = 3">    
                        <xsl:variable name="stringback">
                          <xsl:value-of select="string(substring-before(substring-after(. , 'S. '),'-'))"/>
                        </xsl:variable>
                        <xsl:value-of select="if(string-length($stringback)=1)
                          then concat('page_', $DEF_ARTICLE_NAME , '_','pb00', $stringback)
                          else if (string-length($stringback) = 2 )
                          then concat('page_', $DEF_ARTICLE_NAME , '_','pb0', $stringback)
                          else concat('page_', $DEF_ARTICLE_NAME , '_','pb', $stringback)"/>
                      </xsl:if>
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
                    <dm2e:subtitle>
                      <xsl:attribute name="xml:lang">
                        <xsl:text>de</xsl:text>
                      </xsl:attribute> 
                      <xsl:value-of select="."/>
                    </dm2e:subtitle>
                  </xsl:if>
                </xsl:for-each>
                
                  <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:head">
                   <xsl:if test="position()=1">
                    <dm2e:subtitle>
                    <xsl:attribute name="xml:lang">
                      <xsl:text>de</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="."/> 
                   </dm2e:subtitle>
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
                
                <xsl:choose>
                  <xsl:when test="exists(tei:TEI/tei:text/tei:body/tei:div/tei:pb)">
                    <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:pb">
                      <xsl:if test="position() = 1">
                      <xsl:choose>
                        <xsl:when test="contains(@n,'S')">
                          <bibo:number rdf:datatype="http://www.w3.org/2001/XMLSchema#unsignedInt">
                            <xsl:value-of select="number(substring-after(@n, 'S. '))"/>
                          </bibo:number>
                        </xsl:when>
                        <xsl:otherwise>
                          <bibo:number rdf:datatype="http://www.w3.org/2001/XMLSchema#unsignedInt">
                            <xsl:value-of select="number(@n)"/>
                          </bibo:number>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:if>
                    </xsl:for-each>
                  </xsl:when> 
                  <xsl:when test="exists(tei:TEI/tei:text/tei:body/tei:div/tei:div/tei:pb)">
                    <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:div/tei:pb">
                      <xsl:if test="position() = 1">
                        <bibo:number rdf:datatype="http://www.w3.org/2001/XMLSchema#unsignedInt">
                          <xsl:value-of select="number(@n)"/>
                        </bibo:number>
                      </xsl:if>
                    </xsl:for-each>
                  </xsl:when> 
                  <xsl:when test="exists(tei:TEI/tei:text/tei:body/tei:div/tei:p/tei:q/tei:pb)">
                    <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:p/tei:q/tei:pb">
                      <xsl:if test="position() = 1">
                        <bibo:number rdf:datatype="http://www.w3.org/2001/XMLSchema#unsignedInt">
                          <xsl:value-of select="number(@n)"/>
                        </bibo:number>
                      </xsl:if>
                    </xsl:for-each>
                  </xsl:when> 
                  <xsl:when test="exists(tei:TEI/tei:text/tei:body/tei:div/tei:div/tei:p/tei:pb)">
                    <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:div/tei:p/tei:pb">
                      <xsl:if test="position() = 1">
                        <bibo:number rdf:datatype="http://www.w3.org/2001/XMLSchema#unsignedInt">
                          <xsl:value-of select="number(@n)"/>
                        </bibo:number>
                      </xsl:if>
                    </xsl:for-each>
                  </xsl:when> 
                  <xsl:otherwise>
                   <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:p/tei:pb">
                    <xsl:if test="position() = 1">
                      <bibo:number rdf:datatype="http://www.w3.org/2001/XMLSchema#unsignedInt">
                        <xsl:value-of select="number(@n)"/>
                      </bibo:number>
                    </xsl:if>
                   </xsl:for-each>
                  </xsl:otherwise>
                </xsl:choose>
                
                <xsl:for-each select="tei:TEI/tei:text/tei:front/tei:titlePart/tei:persName">
                  <pro:author>
                    <foaf:Person> 
                      <xsl:attribute name="rdf:about">
                        <xsl:value-of select="$agent"/>
                        <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
                      </xsl:attribute>
                      <skos:prefLabel>
                        <xsl:attribute name="xml:lang">
                          <xsl:text>de</xsl:text>
                        </xsl:attribute>
                        <xsl:value-of select="."/>
                      </skos:prefLabel>
                    </foaf:Person>
                  </pro:author>
                </xsl:for-each>
                
                <!-- Related CHOs (Frontpage without tei:pb) -->
                
                <dcterms:isPartOf>
                  <edm:ProvidedCHO>
                    <xsl:attribute name="rdf:about">
                      <xsl:value-of select="$cho"/>
                      <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:idno">
                        <xsl:if test="position() = 1">
                          <xsl:value-of select="replace(substring-after(.,'.de/'),'/','_')"/>
                        </xsl:if>
                      </xsl:for-each>
                    </xsl:attribute>
                  </edm:ProvidedCHO>
                </dcterms:isPartOf>
                
                <dm2e:levelOfHierarchy rdf:datatype="http://www.w3.org/2001/XMLSchema#unsignedInt">
                  <xsl:text>4</xsl:text>
                </dm2e:levelOfHierarchy>
                  
              </edm:ProvidedCHO> 
            </edm:aggregatedCHO>
            
            <!-- End of CHO (Frontpage without tei:pb) -->
    
    
            <!-- Aggregation (Frontpage without tei:pb) -->
            
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
                      <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
                    <owl:sameAs>
                      <xsl:value-of select="@ref"/>
                    </owl:sameAs>
                  </xsl:if>
                </xsl:for-each>
              </foaf:Organization>
            </edm:dataProvider>
     
            <edm:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
              </xsl:attribute>
            </edm:rights>
     
                  <xsl:choose>
                    <xsl:when test="exists(tei:TEI/tei:text/tei:body/tei:div/tei:pb)">
                      <edm:object>
                        <edm:WebResource>
                          <xsl:attribute name="rdf:about">
                            <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:pb">
                              <xsl:if test="position() = 1">
                                <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                                  substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/' , substring-after(@facs,'/'),
                                  '.tif.thumbnail.jpg')"/>
                              </xsl:if>
                            </xsl:for-each>
                          </xsl:attribute>
                          <dc:format>
                            <xsl:text>image/jpeg</xsl:text>
                          </dc:format>
                        </edm:WebResource>
                      </edm:object>
                    </xsl:when> 
                    <xsl:when test="exists(tei:TEI/tei:text/tei:body/tei:div/tei:div/tei:pb)">
                      <edm:object>
                        <edm:WebResource>
                          <xsl:attribute name="rdf:about">
                            <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:div/tei:pb">
                              <xsl:if test="position() = 1">
                                <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                                  substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/' , substring-after(@facs,'/'),
                                  '.tif.thumbnail.jpg')"/>
                              </xsl:if>
                            </xsl:for-each>
                          </xsl:attribute>
                          <dc:format>
                            <xsl:text>image/jpeg</xsl:text>
                          </dc:format>
                        </edm:WebResource>
                      </edm:object>
                    </xsl:when> 
                    <xsl:when test="exists(tei:TEI/tei:text/tei:body/tei:div/tei:div/tei:p/tei:pb)">
                      <edm:object>
                        <edm:WebResource>
                          <xsl:attribute name="rdf:about">
                            <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:div/tei:p/tei:pb">
                              <xsl:if test="position() = 1">
                                <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                                  substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/' , substring-after(@facs,'/'),
                                  '.tif.thumbnail.jpg')"/>
                              </xsl:if>
                            </xsl:for-each>
                          </xsl:attribute>
                          <dc:format>
                            <xsl:text>image/jpeg</xsl:text>
                          </dc:format>
                        </edm:WebResource>
                      </edm:object>
                    </xsl:when> 
                    <xsl:when test="exists(tei:TEI/tei:text/tei:body/tei:div/tei:p/tei:q/tei:pb)">
                      <edm:object>
                        <edm:WebResource>
                          <xsl:attribute name="rdf:about">
                            <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:p/tei:q/tei:pb">
                              <xsl:if test="position() = 1">
                                <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                                  substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/' , substring-after(@facs,'/'),
                                  '.tif.thumbnail.jpg')"/>
                              </xsl:if>
                            </xsl:for-each>
                          </xsl:attribute>
                          <dc:format>
                            <xsl:text>image/jpeg</xsl:text>
                          </dc:format>
                        </edm:WebResource>
                      </edm:object>
                    </xsl:when> 
                    <xsl:otherwise>
                      <edm:object>
                        <edm:WebResource>
                          <xsl:attribute name="rdf:about">
                            <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:p/tei:pb">
                              <xsl:if test="position() = 1">
                                <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                                  substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/' , substring-after(@facs,'/'),
                                  '.tif.thumbnail.jpg')"/>
                              </xsl:if>
                            </xsl:for-each>
                          </xsl:attribute>
                          <dc:format>
                            <xsl:text>image/jpeg</xsl:text>
                          </dc:format>
                        </edm:WebResource>
                      </edm:object>
                    </xsl:otherwise>
                  </xsl:choose>
                  
                  <xsl:choose>
                    <xsl:when test="exists(tei:TEI/tei:text/tei:body/tei:div/tei:pb)">
                      <dm2e:hasAnnotatableVersionAt>
                        <edm:WebResource>
                          <xsl:attribute name="rdf:about">
                            <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:pb">
                              <xsl:if test="position() = 1">
                                <xsl:value-of select= "concat('http://dingler.culture.hu-berlin.de/journal/page/',
                                  substring-before(@xml:id,'_'),'?p=',substring-after(@facs,'/'))"/>
                              </xsl:if>
                            </xsl:for-each>
                          </xsl:attribute>     
                          <dc:format>
                            <xsl:text>text/html</xsl:text>
                          </dc:format>
                          <edm:rights>
                            <xsl:attribute name="rdf:resource">
                              <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
                            </xsl:attribute>
                          </edm:rights>
                          <dc:rights>
                            <xsl:attribute name="rdf:resource">
                              <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
                            </xsl:attribute>
                          </dc:rights>
                        </edm:WebResource>
                      </dm2e:hasAnnotatableVersionAt> 
                      <dm2e:hasAnnotatableVersionAt>
                        <edm:WebResource>
                          <xsl:attribute name="rdf:about">
                            <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:pb">
                              <xsl:if test="position() = 1">
                                <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                                  substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/')"/>
                                <xsl:variable name="n">
                                  <xsl:value-of select="string(number(substring-after(@facs,'/'))-1)"/>
                                </xsl:variable>
                                <xsl:value-of select="if (string-length($n)=1)
                                  then concat('0000000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 2 )
                                  then concat('000000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 3 )
                                  then concat('00000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 4 )
                                  then concat('0000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 5 )
                                  then concat('000', $n, '.tif.medium.jpg')
                                  else if (string-length($n) = 6 )
                                  then concat('00', $n, '.tif.medium.jpg')
                                  else if (string-length($n) = 7 )
                                  then concat('0', $n, '.tif.medium.jpg')
                                  else concat($n, '.tif.medium.jpg')"/>
                              </xsl:if>
                            </xsl:for-each>
                          </xsl:attribute>     
                          <dc:format>
                            <xsl:text>text/html</xsl:text>
                          </dc:format>
                          <edm:rights>
                            <xsl:attribute name="rdf:resource">
                              <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
                            </xsl:attribute>
                          </edm:rights>
                        </edm:WebResource>
                      </dm2e:hasAnnotatableVersionAt>   
                    </xsl:when> 
                    <xsl:when test="exists(tei:TEI/tei:text/tei:body/tei:div/tei:div/tei:pb)">
                      <dm2e:hasAnnotatableVersionAt>
                        <edm:WebResource>
                          <xsl:attribute name="rdf:about">
                            <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:div/tei:pb">
                              <xsl:if test="position() = 1">
                                <xsl:value-of select= "concat('http://dingler.culture.hu-berlin.de/journal/page/',
                                  substring-before(@xml:id,'_'),'?p=',substring-after(@facs,'/'))"/>
                              </xsl:if>
                            </xsl:for-each>
                          </xsl:attribute>     
                          <dc:format>
                            <xsl:text>text/html</xsl:text>
                          </dc:format>
                          <edm:rights>
                            <xsl:attribute name="rdf:resource">
                              <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
                            </xsl:attribute>
                          </edm:rights>
                          <dc:rights>
                            <xsl:attribute name="rdf:resource">
                              <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
                            </xsl:attribute>
                          </dc:rights>
                        </edm:WebResource>
                      </dm2e:hasAnnotatableVersionAt> 
                      <dm2e:hasAnnotatableVersionAt>
                        <edm:WebResource>
                          <xsl:attribute name="rdf:about">
                            <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:div/tei:pb">
                              <xsl:if test="position() = 1">
                                <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                                  substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/')"/>
                                <xsl:variable name="n">
                                  <xsl:value-of select="string(number(substring-after(@facs,'/'))-1)"/>
                                </xsl:variable>
                                <xsl:value-of select="if (string-length($n)=1)
                                  then concat('0000000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 2 )
                                  then concat('000000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 3 )
                                  then concat('00000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 4 )
                                  then concat('0000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 5 )
                                  then concat('000', $n, '.tif.medium.jpg')
                                  else if (string-length($n) = 6 )
                                  then concat('00', $n, '.tif.medium.jpg')
                                  else if (string-length($n) = 7 )
                                  then concat('0', $n, '.tif.medium.jpg')
                                  else concat($n, '.tif.medium.jpg')"/>
                              </xsl:if>
                            </xsl:for-each>
                          </xsl:attribute>     
                          <dc:format>
                            <xsl:text>text/html</xsl:text>
                          </dc:format>
                          <edm:rights>
                            <xsl:attribute name="rdf:resource">
                              <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
                            </xsl:attribute>
                          </edm:rights>
                        </edm:WebResource>
                      </dm2e:hasAnnotatableVersionAt>   
                    </xsl:when> 
                    <xsl:when test="exists(tei:TEI/tei:text/tei:body/tei:div/tei:div/tei:p/tei:pb)">
                      <dm2e:hasAnnotatableVersionAt>
                        <edm:WebResource>
                          <xsl:attribute name="rdf:about">
                            <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:div/tei:p/tei:pb">
                              <xsl:if test="position() = 1">
                                <xsl:value-of select= "concat('http://dingler.culture.hu-berlin.de/journal/page/',
                                  substring-before(@xml:id,'_'),'?p=',substring-after(@facs,'/'))"/>
                              </xsl:if>
                            </xsl:for-each>
                          </xsl:attribute>     
                          <dc:format>
                            <xsl:text>text/html</xsl:text>
                          </dc:format>
                          <edm:rights>
                            <xsl:attribute name="rdf:resource">
                              <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
                            </xsl:attribute>
                          </edm:rights>
                          <dc:rights>
                            <xsl:attribute name="rdf:resource">
                              <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
                            </xsl:attribute>
                          </dc:rights>
                        </edm:WebResource>
                      </dm2e:hasAnnotatableVersionAt> 
                      <dm2e:hasAnnotatableVersionAt>
                        <edm:WebResource>
                          <xsl:attribute name="rdf:about">
                            <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:div/tei:p/tei:pb">
                              <xsl:if test="position() = 1">
                                <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                                  substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/')"/>
                                <xsl:variable name="n">
                                  <xsl:value-of select="string(number(substring-after(@facs,'/'))-1)"/>
                                </xsl:variable>
                                <xsl:value-of select="if (string-length($n)=1)
                                  then concat('0000000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 2 )
                                  then concat('000000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 3 )
                                  then concat('00000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 4 )
                                  then concat('0000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 5 )
                                  then concat('000', $n, '.tif.medium.jpg')
                                  else if (string-length($n) = 6 )
                                  then concat('00', $n, '.tif.medium.jpg')
                                  else if (string-length($n) = 7 )
                                  then concat('0', $n, '.tif.medium.jpg')
                                  else concat($n, '.tif.medium.jpg')"/>
                              </xsl:if>
                            </xsl:for-each>
                          </xsl:attribute>     
                          <dc:format>
                            <xsl:text>text/html</xsl:text>
                          </dc:format>
                          <edm:rights>
                            <xsl:attribute name="rdf:resource">
                              <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
                            </xsl:attribute>
                          </edm:rights>
                        </edm:WebResource>
                      </dm2e:hasAnnotatableVersionAt>   
                    </xsl:when> 
                    <xsl:when test="exists(tei:TEI/tei:text/tei:body/tei:div/tei:p/tei:q/tei:pb)">
                      <dm2e:hasAnnotatableVersionAt>
                        <edm:WebResource>
                          <xsl:attribute name="rdf:about">
                            <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:p/tei:q/tei:pb">
                              <xsl:if test="position() = 1">
                                <xsl:value-of select= "concat('http://dingler.culture.hu-berlin.de/journal/page/',
                                  substring-before(@xml:id,'_'),'?p=',substring-after(@facs,'/'))"/>
                              </xsl:if>
                            </xsl:for-each>
                          </xsl:attribute>     
                          <dc:format>
                            <xsl:text>text/html</xsl:text>
                          </dc:format>
                          <edm:rights>
                            <xsl:attribute name="rdf:resource">
                              <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
                            </xsl:attribute>
                          </edm:rights>
                          <dc:rights>
                            <xsl:attribute name="rdf:resource">
                              <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
                            </xsl:attribute>
                          </dc:rights>
                        </edm:WebResource>
                      </dm2e:hasAnnotatableVersionAt> 
                      <dm2e:hasAnnotatableVersionAt>
                        <edm:WebResource>
                          <xsl:attribute name="rdf:about">
                            <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:p/tei:q/tei:pb">
                              <xsl:if test="position() = 1">
                                <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                                  substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/')"/>
                                <xsl:variable name="n">
                                  <xsl:value-of select="string(number(substring-after(@facs,'/'))-1)"/>
                                </xsl:variable>
                                <xsl:value-of select="if (string-length($n)=1)
                                  then concat('0000000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 2 )
                                  then concat('000000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 3 )
                                  then concat('00000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 4 )
                                  then concat('0000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 5 )
                                  then concat('000', $n, '.tif.medium.jpg')
                                  else if (string-length($n) = 6 )
                                  then concat('00', $n, '.tif.medium.jpg')
                                  else if (string-length($n) = 7 )
                                  then concat('0', $n, '.tif.medium.jpg')
                                  else concat($n, '.tif.medium.jpg')"/>
                              </xsl:if>
                            </xsl:for-each>
                          </xsl:attribute>     
                          <dc:format>
                            <xsl:text>text/html</xsl:text>
                          </dc:format>
                          <edm:rights>
                            <xsl:attribute name="rdf:resource">
                              <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
                            </xsl:attribute>
                          </edm:rights>
                        </edm:WebResource>
                      </dm2e:hasAnnotatableVersionAt>   
                    </xsl:when> 
                    <xsl:otherwise>
                      <dm2e:hasAnnotatableVersionAt>
                        <edm:WebResource>
                          <xsl:attribute name="rdf:about">
                            <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:p/tei:pb">
                              <xsl:if test="position() = 1">
                                <xsl:value-of select= "concat('http://dingler.culture.hu-berlin.de/journal/page/',
                                  substring-before(@xml:id,'_'),'?p=',substring-after(@facs,'/'))"/>
                              </xsl:if>
                            </xsl:for-each>
                          </xsl:attribute>     
                          <dc:format>
                            <xsl:text>text/html</xsl:text>
                          </dc:format>
                          <edm:rights>
                            <xsl:attribute name="rdf:resource">
                              <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
                            </xsl:attribute>
                          </edm:rights>
                          <dc:rights>
                            <xsl:attribute name="rdf:resource">
                              <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
                            </xsl:attribute>
                          </dc:rights>
                        </edm:WebResource>
                      </dm2e:hasAnnotatableVersionAt>
                      <dm2e:hasAnnotatableVersionAt>
                        <edm:WebResource>
                          <xsl:attribute name="rdf:about">
                            <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:p/tei:pb">
                              <xsl:if test="position() = 1">
                                <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                                  substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/')"/>
                                <xsl:variable name="n">
                                  <xsl:value-of select="string(number(substring-after(@facs,'/'))-1)"/>
                                </xsl:variable>
                                <xsl:value-of select="if (string-length($n)=1)
                                  then concat('0000000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 2 )
                                  then concat('000000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 3 )
                                  then concat('00000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 4 )
                                  then concat('0000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 5 )
                                  then concat('000', $n, '.tif.medium.jpg')
                                  else if (string-length($n) = 6 )
                                  then concat('00', $n, '.tif.medium.jpg')
                                  else if (string-length($n) = 7 )
                                  then concat('0', $n, '.tif.medium.jpg')
                                  else concat($n, '.tif.medium.jpg')"/>
                              </xsl:if>
                            </xsl:for-each>
                          </xsl:attribute>     
                          <dc:format>
                            <xsl:text>text/html</xsl:text>
                          </dc:format>
                          <edm:rights>
                            <xsl:attribute name="rdf:resource">
                              <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
                            </xsl:attribute>
                          </edm:rights>
                        </edm:WebResource>
                      </dm2e:hasAnnotatableVersionAt>  
                    </xsl:otherwise>
                  </xsl:choose>
                  
                  <xsl:choose>
                    <xsl:when test="exists(tei:TEI/tei:text/tei:body/tei:div/tei:pb)">
                      <edm:isShownBy>
                        <edm:WebResource>
                          <xsl:attribute name="rdf:about">
                            <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:pb">
                              <xsl:if test="position() = 1">
                                <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                                  substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/')"/>
                                <xsl:variable name="n">
                                  <xsl:value-of select="string(number(substring-after(@facs,'/'))-1)"/>
                                </xsl:variable>
                                <xsl:value-of select="if (string-length($n)=1)
                                  then concat('0000000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 2 )
                                  then concat('000000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 3 )
                                  then concat('00000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 4 )
                                  then concat('0000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 5 )
                                  then concat('000', $n, '.tif.medium.jpg')
                                  else if (string-length($n) = 6 )
                                  then concat('00', $n, '.tif.medium.jpg')
                                  else if (string-length($n) = 7 )
                                  then concat('0', $n, '.tif.medium.jpg')
                                  else concat($n, '.tif.medium.jpg')"/>
                              </xsl:if>
                            </xsl:for-each>
                          </xsl:attribute> 
                          <edm:rights>
                            <xsl:attribute name="rdf:resource">
                              <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
                            </xsl:attribute>
                          </edm:rights>
                        </edm:WebResource>
                      </edm:isShownBy>   
                    </xsl:when> 
                    <xsl:when test="exists(tei:TEI/tei:text/tei:body/tei:div/tei:div/tei:pb)">
                      <edm:isShownBy>
                        <edm:WebResource>
                          <xsl:attribute name="rdf:about">
                            <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:div/tei:pb">
                              <xsl:if test="position() = 1">
                                <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                                  substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/')"/>
                                <xsl:variable name="n">
                                  <xsl:value-of select="string(number(substring-after(@facs,'/'))-1)"/>
                                </xsl:variable>
                                <xsl:value-of select="if (string-length($n)=1)
                                  then concat('0000000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 2 )
                                  then concat('000000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 3 )
                                  then concat('00000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 4 )
                                  then concat('0000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 5 )
                                  then concat('000', $n, '.tif.medium.jpg')
                                  else if (string-length($n) = 6 )
                                  then concat('00', $n, '.tif.medium.jpg')
                                  else if (string-length($n) = 7 )
                                  then concat('0', $n, '.tif.medium.jpg')
                                  else concat($n, '.tif.medium.jpg')"/>
                              </xsl:if>
                            </xsl:for-each>
                          </xsl:attribute>
                          <edm:rights>
                            <xsl:attribute name="rdf:resource">
                              <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
                            </xsl:attribute>
                          </edm:rights>
                        </edm:WebResource>
                      </edm:isShownBy>   
                    </xsl:when> 
                    <xsl:when test="exists(tei:TEI/tei:text/tei:body/tei:div/tei:div/tei:p/tei:pb)">
                      <edm:isShownBy>
                        <edm:WebResource>
                          <xsl:attribute name="rdf:about">
                            <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:div/tei:p/tei:pb">
                              <xsl:if test="position() = 1">
                                <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                                  substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/')"/>
                                <xsl:variable name="n">
                                  <xsl:value-of select="string(number(substring-after(@facs,'/'))-1)"/>
                                </xsl:variable>
                                <xsl:value-of select="if (string-length($n)=1)
                                  then concat('0000000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 2 )
                                  then concat('000000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 3 )
                                  then concat('00000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 4 )
                                  then concat('0000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 5 )
                                  then concat('000', $n, '.tif.medium.jpg')
                                  else if (string-length($n) = 6 )
                                  then concat('00', $n, '.tif.medium.jpg')
                                  else if (string-length($n) = 7 )
                                  then concat('0', $n, '.tif.medium.jpg')
                                  else concat($n, '.tif.medium.jpg')"/>
                              </xsl:if>
                            </xsl:for-each>
                          </xsl:attribute>
                          <edm:rights>
                            <xsl:attribute name="rdf:resource">
                              <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
                            </xsl:attribute>
                          </edm:rights>
                        </edm:WebResource>
                      </edm:isShownBy>   
                    </xsl:when> 
                    <xsl:when test="exists(tei:TEI/tei:text/tei:body/tei:div/tei:p/tei:q/tei:pb)">
                      <edm:isShownBy>
                        <edm:WebResource>
                          <xsl:attribute name="rdf:about">
                            <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:p/tei:q/tei:pb">
                              <xsl:if test="position() = 1">
                                <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                                  substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/')"/>
                                <xsl:variable name="n">
                                  <xsl:value-of select="string(number(substring-after(@facs,'/'))-1)"/>
                                </xsl:variable>
                                <xsl:value-of select="if (string-length($n)=1)
                                  then concat('0000000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 2 )
                                  then concat('000000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 3 )
                                  then concat('00000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 4 )
                                  then concat('0000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 5 )
                                  then concat('000', $n, '.tif.medium.jpg')
                                  else if (string-length($n) = 6 )
                                  then concat('00', $n, '.tif.medium.jpg')
                                  else if (string-length($n) = 7 )
                                  then concat('0', $n, '.tif.medium.jpg')
                                  else concat($n, '.tif.medium.jpg')"/>
                              </xsl:if>
                            </xsl:for-each>
                          </xsl:attribute>
                          <edm:rights>
                            <xsl:attribute name="rdf:resource">
                              <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
                            </xsl:attribute>
                          </edm:rights>
                        </edm:WebResource>
                      </edm:isShownBy>   
                    </xsl:when> 
                    <xsl:otherwise>
                      <edm:isShownBy>
                        <edm:WebResource>
                          <xsl:attribute name="rdf:about">
                            <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:p/tei:pb">
                              <xsl:if test="position() = 1">
                                <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                                  substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/')"/>
                                <xsl:variable name="n">
                                  <xsl:value-of select="string(number(substring-after(@facs,'/'))-1)"/>
                                </xsl:variable>
                                <xsl:value-of select="if (string-length($n)=1)
                                  then concat('0000000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 2 )
                                  then concat('000000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 3 )
                                  then concat('00000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 4 )
                                  then concat('0000', $n, '.tif.medium.jpg')
                                  else if(string-length($n) = 5 )
                                  then concat('000', $n, '.tif.medium.jpg')
                                  else if (string-length($n) = 6 )
                                  then concat('00', $n, '.tif.medium.jpg')
                                  else if (string-length($n) = 7 )
                                  then concat('0', $n, '.tif.medium.jpg')
                                  else concat($n, '.tif.medium.jpg')"/>
                              </xsl:if>
                            </xsl:for-each>
                          </xsl:attribute> 
                          <edm:rights>
                            <xsl:attribute name="rdf:resource">
                              <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
                            </xsl:attribute>
                          </edm:rights>
                        </edm:WebResource>
                      </edm:isShownBy>  
                    </xsl:otherwise>
                  </xsl:choose>
         
                 <!--  <dm2e:zweitesCHO>
                  without tei:pb
                </dm2e:zweitesCHO>-->
                  
          <xsl:choose>
            <xsl:when test="exists(tei:TEI/tei:text/tei:body/tei:div/tei:pb)">
               <edm:isShownAt>
                <xsl:for-each select=".">
                  <edm:WebResource>
                    <xsl:if test=".">
                      <xsl:attribute name="rdf:about">
                        <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:pb">
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
                    <edm:rights>
                      <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
                      </xsl:attribute>
                    </edm:rights>
                    <dc:rights>
                      <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
                      </xsl:attribute>
                    </dc:rights>
                  </edm:WebResource>
                </xsl:for-each>
              </edm:isShownAt>
            </xsl:when>
            <xsl:when test="exists(tei:TEI/tei:text/tei:body/tei:div/tei:div/tei:pb)">
              <edm:isShownAt>
                <xsl:for-each select=".">
                  <edm:WebResource>
                    <xsl:if test=".">
                      <xsl:attribute name="rdf:about">
                        <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:div/tei:pb">
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
                    <edm:rights>
                      <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
                      </xsl:attribute>
                    </edm:rights>
                    <dc:rights>
                      <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
                      </xsl:attribute>
                    </dc:rights>
                  </edm:WebResource>
                </xsl:for-each>
              </edm:isShownAt>
            </xsl:when>
            <xsl:when test="exists(tei:TEI/tei:text/tei:body/tei:div/tei:div/tei:p/tei:pb)">
              <edm:isShownAt>
                <xsl:for-each select=".">
                  <edm:WebResource>
                    <xsl:if test=".">
                      <xsl:attribute name="rdf:about">
                        <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:div/tei:p/tei:pb">
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
                    <edm:rights>
                      <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
                      </xsl:attribute>
                    </edm:rights>
                    <dc:rights>
                      <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
                      </xsl:attribute>
                    </dc:rights>
                  </edm:WebResource>
                </xsl:for-each>
              </edm:isShownAt>
            </xsl:when>
            <xsl:when test="exists(tei:TEI/tei:text/tei:body/tei:div/tei:p/tei:q/tei:pb)">
              <edm:isShownAt>
                <xsl:for-each select=".">
                  <edm:WebResource>
                    <xsl:if test=".">
                      <xsl:attribute name="rdf:about">
                        <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:p/tei:q/tei:pb">
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
                    <edm:rights>
                      <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
                      </xsl:attribute>
                    </edm:rights>
                    <dc:rights>
                      <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
                      </xsl:attribute>
                    </dc:rights>
                  </edm:WebResource>
                </xsl:for-each>
              </edm:isShownAt>
            </xsl:when>
            <xsl:otherwise>
              <edm:isShownAt>
                <xsl:for-each select=".">
                  <edm:WebResource>
                    <xsl:if test=".">
                      <xsl:attribute name="rdf:about">
                        <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:p/tei:pb">
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
                    <edm:rights>
                      <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
                      </xsl:attribute>
                    </edm:rights>
                    <dc:rights>
                      <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
                      </xsl:attribute>
                    </dc:rights>
                  </edm:WebResource>
                </xsl:for-each>
              </edm:isShownAt>
            </xsl:otherwise>
          </xsl:choose>
                  
                  
            <dc:creator>
              <foaf:Organization>
                <xsl:attribute name="rdf:about">
                  <xsl:value-of select="$agent"/>
                  <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:persName">
                    <xsl:if test="position() = 1">
                      <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
                        <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
                        <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
                      <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
       
              <!-- </xsl:for-each>  -->
        </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    
  <!-- End of CHOs from frontpage without tei:pb -->
  
  
    <!-- Begin CHOs under tei:body/tei:div/tei:pb --> 
    
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
                 <dm2e:subtitle>
                   <xsl:attribute name="xml:lang">
                     <xsl:text>de</xsl:text>
                   </xsl:attribute> 
                   <xsl:value-of select="."/>
                 </dm2e:subtitle>
               </xsl:if>
             </xsl:for-each>
             
             <xsl:choose>
               <xsl:when test="following-sibling::tei:head">
                 <dm2e:subtitle>   
                   <xsl:attribute name="xml:lang">
                     <xsl:text>de</xsl:text>
                   </xsl:attribute>
                       <xsl:value-of select="following-sibling::tei:head"/>
                 </dm2e:subtitle>     
               </xsl:when>
               <xsl:otherwise> 
                 <xsl:choose>
                   <xsl:when test="following-sibling::tei:pb">
                     <dm2e:subtitle>   
                       <xsl:attribute name="xml:lang">
                         <xsl:text>de</xsl:text>
                       </xsl:attribute>
                     </dm2e:subtitle> 
                   </xsl:when>
                   <xsl:otherwise>
                     <xsl:choose>
                       <xsl:when test="not(parent::node()/following-sibling::*[1][child::*[1][self::tei:head]]) or following-sibling::*[child::*[self::tei:pb]]">
                         <dm2e:subtitle>   
                           <xsl:attribute name="xml:lang">
                             <xsl:text>de</xsl:text>
                           </xsl:attribute>
                         </dm2e:subtitle>
                       </xsl:when>
                       <xsl:otherwise>
                         <dm2e:subtitle>   
                           <xsl:attribute name="xml:lang">
                             <xsl:text>de</xsl:text>
                           </xsl:attribute>
                           <xsl:for-each select="following::tei:div/tei:head">
                             <xsl:if test="position()=1">
                               <xsl:value-of select="."/>
                             </xsl:if>
                           </xsl:for-each>
                         </dm2e:subtitle>
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
            
           <xsl:choose>
             <xsl:when test="contains(@n,'S')">
               <bibo:number rdf:datatype="http://www.w3.org/2001/XMLSchema#unsignedInt">
                 <xsl:value-of select="number(substring-after(@n, 'S. '))"/>
               </bibo:number>
             </xsl:when>
             <xsl:otherwise>
               <bibo:number rdf:datatype="http://www.w3.org/2001/XMLSchema#unsignedInt">
                 <xsl:value-of select="number(@n)"/>
               </bibo:number>
             </xsl:otherwise>
           </xsl:choose> 
             
             <xsl:for-each select="../../../tei:front/tei:titlePart/tei:persName">
               <pro:author>
                 <foaf:Person> 
                   <xsl:attribute name="rdf:about">
                     <xsl:value-of select="$agent"/>
                     <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
                   </xsl:attribute>
                   <skos:prefLabel>
                     <xsl:attribute name="xml:lang">
                       <xsl:text>de</xsl:text>
                     </xsl:attribute>
                     <xsl:value-of select="."/>
                   </skos:prefLabel>
                 </foaf:Person>
               </pro:author>
             </xsl:for-each>
     
        <!-- Related CHOs (Remaining pages) -->
             
             <dcterms:isPartOf>
               <edm:ProvidedCHO>
                 <xsl:attribute name="rdf:about">
                   <xsl:value-of select="$cho"/>
                   <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:idno">
                     <xsl:if test="position() = 1">
                       <xsl:value-of select="replace(substring-after(.,'.de/'),'/','_')"/>
                     </xsl:if>
                   </xsl:for-each>
                 </xsl:attribute>
               </edm:ProvidedCHO>
             </dcterms:isPartOf> 
             
             <xsl:choose>
               <xsl:when test="contains(@xml:id,'pbzu')">
                 <edm:isNextInSequence>
                   <edm:ProvidedCHO>
                     <xsl:attribute name="rdf:about">
                       <xsl:value-of select="$cho"/>
                       <xsl:variable name="stringback">
                         <xsl:value-of select="string(number(substring-after(@xml:id, 'S._'))-1)"/>
                       </xsl:variable>
                       <xsl:value-of select="if(string-length($stringback)=1)
                         then concat('page_',(substring-before(@xml:id, '_pbzu')),'_pb00', $stringback)
                         else if (string-length($stringback) = 2 )
                         then concat('page_',(substring-before(@xml:id, '_pbzu')),'_pb0', $stringback)
                         else concat('page_',(substring-before(@xml:id, '_pbzu')),'_pb', $stringback)"/>
                     </xsl:attribute>
                   </edm:ProvidedCHO>
                 </edm:isNextInSequence> 
               </xsl:when>
               <xsl:otherwise>
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
               </xsl:otherwise>
             </xsl:choose> 
             
             <dm2e:levelOfHierarchy rdf:datatype="http://www.w3.org/2001/XMLSchema#unsignedInt">
               <xsl:text>4</xsl:text>
             </dm2e:levelOfHierarchy>        
     
          </edm:ProvidedCHO>
        </edm:aggregatedCHO>
   
        <!-- End of CHO (Remaining pages) -->
        
        
        <!-- Aggregation (Remaining pages) -->
        
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
              <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:persName">
                <xsl:if test="position() = 1">
                  <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
                <owl:sameAs>
                  <xsl:value-of select="@ref"/>
                </owl:sameAs>
              </xsl:if>
            </xsl:for-each>
          </foaf:Organization>
        </edm:dataProvider>
        
        <edm:rights>
          <xsl:attribute name="rdf:resource">
            <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
          </xsl:attribute>
        </edm:rights>
        
       
        <edm:object>
          <edm:WebResource>
            <xsl:attribute name="rdf:about">
                  <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                    substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/' , substring-after(@facs,'/'),
                    '.tif.thumbnail.jpg')"/>
            </xsl:attribute>     
            <dc:format>
              <xsl:text>image/jpeg</xsl:text>
            </dc:format>
            <edm:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
              </xsl:attribute>
            </edm:rights>
          </edm:WebResource>
        </edm:object>
       
        <dm2e:hasAnnotatableVersionAt>
          <edm:WebResource>
            <xsl:attribute name="rdf:about">
              <xsl:value-of select= "concat('http://dingler.culture.hu-berlin.de/journal/page/',
                  substring-before(@xml:id,'_'),'?p=',substring-after(@facs,'/'))"/>
            </xsl:attribute>
            <dc:format>
              <xsl:text>text/html</xsl:text>
            </dc:format>
            <edm:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
              </xsl:attribute>
            </edm:rights>
            <dc:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
              </xsl:attribute>
            </dc:rights>
          </edm:WebResource>
        </dm2e:hasAnnotatableVersionAt>
        
        <dm2e:hasAnnotatableVersionAt>
          <edm:WebResource>
            <xsl:attribute name="rdf:about">
                  <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                    substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/' , substring-after(@facs,'/'),
                    '.tif.medium.jpg')"/>
            </xsl:attribute>
            <dc:format>
              <xsl:text>image/jpeg</xsl:text>
            </dc:format>
            <edm:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
              </xsl:attribute>
            </edm:rights>
          </edm:WebResource>
        </dm2e:hasAnnotatableVersionAt>
        
        <edm:isShownBy>
          <edm:WebResource>
            <xsl:attribute name="rdf:about">
              <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/' , substring-after(@facs,'/'),
                '.tif.medium.jpg')"/>
            </xsl:attribute>
            <dc:format>
              <xsl:text>image/jpeg</xsl:text>
            </dc:format>
            <edm:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
              </xsl:attribute>
            </edm:rights>
          </edm:WebResource>
        </edm:isShownBy>
        
        <!--<dm2e:drittesCHO>
          Remaining pages
        </dm2e:drittesCHO>-->
        
      <!--  <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:idno">-->
          <edm:isShownAt>
            <xsl:for-each select=".">
              <edm:WebResource>
                <xsl:attribute name="rdf:about">
                  <xsl:value-of select= "concat('http://dingler.culture.hu-berlin.de/journal/page/',
                    substring-before(@xml:id,'_'),'?p=',substring-after(@facs,'/'))"/>
                </xsl:attribute>
                <!--<xsl:if test=".">
                  <xsl:attribute name="rdf:about">
                    <xsl:for-each select=".">
                      <xsl:if test="position() = 1">
                        <xsl:value-of select="substring-before(.,'/ar')"/>
                      </xsl:if>
                    </xsl:for-each>
                  </xsl:attribute>
                </xsl:if>-->
                <xsl:for-each select="../../tei:seriesStmt/tei:title">
                  <dc:description>
                    <xsl:attribute name="xml:lang">
                      <xsl:text>de</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                  </dc:description>
                </xsl:for-each>
                <edm:rights>
                  <xsl:attribute name="rdf:resource">
                    <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
                  </xsl:attribute>
                </edm:rights>
                <dc:rights>
                  <xsl:attribute name="rdf:resource">
                    <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
                  </xsl:attribute>
                </dc:rights>
<!--                TODO to check all isDerivativeOf-->
                <edm:isDerivativeOf>
                  <edm:WebResource>
                   <!-- <xsl:if test=".">-->
                      <xsl:attribute name="rdf:about">
                        <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:idno">
                          <xsl:if test="position() = 1">
                            <xsl:value-of select="substring-before(.,'article')"/>
                          </xsl:if>
                        </xsl:for-each>
                      </xsl:attribute>
                    <!--</xsl:if>-->
                    <edm:rights>
                      <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
                      </xsl:attribute>
                    </edm:rights>
                    <dc:rights>
                      <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
                      </xsl:attribute>
                    </dc:rights>
                  </edm:WebResource>
                </edm:isDerivativeOf>
              </edm:WebResource>
            </xsl:for-each>
          </edm:isShownAt>
        <!--</xsl:for-each>-->
        
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
                  <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
                    <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
                    <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
                  <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
    
    
     <!-- Begin Aggregations under tei:body/tei:div/tei:div/tei:pb --> 
    
    <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:div/tei:pb">
      <ore:Aggregation>
        <xsl:attribute name="rdf:about">
          <xsl:value-of select="$aggregation"/>
          <xsl:value-of select="concat('page_',@xml:id)"/>
        </xsl:attribute>
 
        <edm:aggregatedCHO>
          
          
          <!-- Begin CHOs under tei:body/tei:div/tei:div/tei:pb -->
        
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
                 <dm2e:subtitle>
                   <xsl:attribute name="xml:lang">
                     <xsl:text>de</xsl:text>
                   </xsl:attribute> 
                   <xsl:value-of select="."/>
                 </dm2e:subtitle>
               </xsl:if>
             </xsl:for-each>
             
             <xsl:choose>
               <xsl:when test="following-sibling::tei:head">
                 <dm2e:subtitle>   
                   <xsl:attribute name="xml:lang">
                     <xsl:text>de</xsl:text>
                   </xsl:attribute>
                       <xsl:value-of select="following-sibling::tei:head"/>
                 </dm2e:subtitle>     
               </xsl:when>
               <xsl:otherwise> 
                 <xsl:choose>
                   <xsl:when test="following-sibling::tei:pb">
                     <dm2e:subtitle>   
                       <xsl:attribute name="xml:lang">
                         <xsl:text>de</xsl:text>
                       </xsl:attribute>
                     </dm2e:subtitle> 
                   </xsl:when>
                   <xsl:otherwise>
                     <xsl:choose>
                       <xsl:when test="not(parent::node()/following-sibling::*[1][child::*[1][self::tei:head]]) or following-sibling::*[child::*[self::tei:pb]]">
                         <dm2e:subtitle>   
                           <xsl:attribute name="xml:lang">
                             <xsl:text>de</xsl:text>
                           </xsl:attribute>
                         </dm2e:subtitle>
                       </xsl:when>
                       <xsl:otherwise>
                         <dm2e:subtitle>   
                           <xsl:attribute name="xml:lang">
                             <xsl:text>de</xsl:text>
                           </xsl:attribute>
                           <xsl:for-each select="following::tei:div/tei:head">
                             <xsl:if test="position()=1">
                               <xsl:value-of select="."/>
                             </xsl:if>
                           </xsl:for-each>
                         </dm2e:subtitle>
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
            
           <xsl:choose>
             <xsl:when test="contains(@n,'S')">
               <bibo:number rdf:datatype="http://www.w3.org/2001/XMLSchema#unsignedInt">
                 <xsl:value-of select="number(substring-after(@n, 'S. '))"/>
               </bibo:number>
             </xsl:when>
             <xsl:otherwise>
               <bibo:number rdf:datatype="http://www.w3.org/2001/XMLSchema#unsignedInt">
                 <xsl:value-of select="number(@n)"/>
               </bibo:number>
             </xsl:otherwise>
           </xsl:choose> 
            
             <xsl:for-each select="../../../../tei:front/tei:titlePart/tei:persName">
               <pro:author>
                 <foaf:Person> 
                   <xsl:attribute name="rdf:about">
                     <xsl:value-of select="$agent"/>
                     <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
                   </xsl:attribute>
                   <skos:prefLabel>
                     <xsl:attribute name="xml:lang">
                       <xsl:text>de</xsl:text>
                     </xsl:attribute>
                     <xsl:value-of select="."/>
                   </skos:prefLabel>
                 </foaf:Person>
               </pro:author>
             </xsl:for-each>
     
             <!-- Related CHOs (under tei:body/tei:div/tei:div/tei:pb) -->
             
             <dcterms:isPartOf>
               <edm:ProvidedCHO>
                 <xsl:attribute name="rdf:about">
                   <xsl:value-of select="$cho"/>
                   <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:idno">
                     <xsl:if test="position() = 1">
                       <xsl:value-of select="replace(substring-after(.,'.de/'),'/','_')"/>
                     </xsl:if>
                   </xsl:for-each>
                 </xsl:attribute>
               </edm:ProvidedCHO>
             </dcterms:isPartOf>   
             
             <xsl:choose>
               <xsl:when test="contains(@xml:id,'pbzu')">
                 <edm:isNextInSequence>
                   <edm:ProvidedCHO>
                     <xsl:attribute name="rdf:about">
                       <xsl:value-of select="$cho"/>
                       <xsl:variable name="stringback">
                         <xsl:value-of select="string(number(substring-after(@xml:id, 'S._'))-1)"/>
                       </xsl:variable>
                       <xsl:value-of select="if(string-length($stringback)=1)
                         then concat('page_',(substring-before(@xml:id, '_pbzu')),'_pb00', $stringback)
                         else if (string-length($stringback) = 2 )
                         then concat('page_',(substring-before(@xml:id, '_pbzu')),'_pb0', $stringback)
                         else concat('page_',(substring-before(@xml:id, '_pbzu')),'_pb', $stringback)"/>
                     </xsl:attribute>
                   </edm:ProvidedCHO>
                 </edm:isNextInSequence> 
               </xsl:when>
               <xsl:otherwise>
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
               </xsl:otherwise>
             </xsl:choose> 
             
             <dm2e:levelOfHierarchy rdf:datatype="http://www.w3.org/2001/XMLSchema#unsignedInt">
               <xsl:text>4</xsl:text>
             </dm2e:levelOfHierarchy>        
     
          </edm:ProvidedCHO>
        </edm:aggregatedCHO>
   
        <!-- End of CHO (under tei:body/tei:div/tei:div/tei:pb) -->
        
        
        <!-- Aggregation (under tei:body/tei:div/tei:div/tei:pb) -->
        
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
              <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:persName">
                <xsl:if test="position() = 1">
                  <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
                <owl:sameAs>
                  <xsl:value-of select="@ref"/>
                </owl:sameAs>
              </xsl:if>
            </xsl:for-each>
          </foaf:Organization>
        </edm:dataProvider>
        
        <edm:rights>
          <xsl:attribute name="rdf:resource">
            <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
          </xsl:attribute>
        </edm:rights>
        
       
        <edm:object>
          <edm:WebResource>
            <xsl:attribute name="rdf:about">
                  <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                    substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/' , substring-after(@facs,'/'),
                    '.tif.thumbnail.jpg')"/>
            </xsl:attribute>     
            <dc:format>
              <xsl:text>image/jpeg</xsl:text>
            </dc:format>
            <edm:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
              </xsl:attribute>
            </edm:rights>
          </edm:WebResource>
        </edm:object>
       
        <dm2e:hasAnnotatableVersionAt>
          <edm:WebResource>
            <xsl:attribute name="rdf:about">
              <xsl:value-of select= "concat('http://dingler.culture.hu-berlin.de/journal/page/',
                  substring-before(@xml:id,'_'),'?p=',substring-after(@facs,'/'))"/>
            </xsl:attribute>
            <dc:format>
              <xsl:text>text/html</xsl:text>
            </dc:format>
            <edm:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
              </xsl:attribute>
            </edm:rights>
            <dc:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
              </xsl:attribute>
            </dc:rights>
          </edm:WebResource>
        </dm2e:hasAnnotatableVersionAt>
        
        <dm2e:hasAnnotatableVersionAt>
          <edm:WebResource>
            <xsl:attribute name="rdf:about">
                  <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                    substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/' , substring-after(@facs,'/'),
                    '.tif.medium.jpg')"/>
            </xsl:attribute>
            <dc:format>
              <xsl:text>image/jpeg</xsl:text>
            </dc:format>
            <edm:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
              </xsl:attribute>
            </edm:rights>
          </edm:WebResource>
        </dm2e:hasAnnotatableVersionAt>
        
        <edm:isShownBy>
          <edm:WebResource>
            <xsl:attribute name="rdf:about">
              <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/' , substring-after(@facs,'/'),
                '.tif.medium.jpg')"/>
            </xsl:attribute>
            <edm:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
              </xsl:attribute>
            </edm:rights>
          </edm:WebResource>
        </edm:isShownBy>
        
       <!-- <dm2e:viertesCHO>
          tei:div/tei:div/tei:pb
        </dm2e:viertesCHO>-->
        
        <edm:isShownAt>
          <xsl:for-each select=".">
            <edm:WebResource>
              <xsl:attribute name="rdf:about">
                <xsl:value-of select= "concat('http://dingler.culture.hu-berlin.de/journal/page/',
                  substring-before(@xml:id,'_'),'?p=',substring-after(@facs,'/'))"/>
              </xsl:attribute>
              <!--<xsl:if test=".">
                  <xsl:attribute name="rdf:about">
                    <xsl:for-each select=".">
                      <xsl:if test="position() = 1">
                        <xsl:value-of select="substring-before(.,'/ar')"/>
                      </xsl:if>
                    </xsl:for-each>
                  </xsl:attribute>
                </xsl:if>-->
              <xsl:for-each select="../../tei:seriesStmt/tei:title">
                <dc:description>
                  <xsl:attribute name="xml:lang">
                    <xsl:text>de</xsl:text>
                  </xsl:attribute>
                  <xsl:value-of select="."/>
                </dc:description>
              </xsl:for-each>
              <edm:rights>
                <xsl:attribute name="rdf:resource">
                  <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
                </xsl:attribute>
              </edm:rights>
              <dc:rights>
                <xsl:attribute name="rdf:resource">
                  <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
                </xsl:attribute>
              </dc:rights>
              <!--                TODO to check all isDerivativeOf-->
              <edm:isDerivativeOf>
                <edm:WebResource>
                  <!-- <xsl:if test=".">-->
                  <xsl:attribute name="rdf:about">
                    <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:idno">
                      <xsl:if test="position() = 1">
                        <xsl:value-of select="substring-before(.,'article')"/>
                      </xsl:if>
                    </xsl:for-each>
                  </xsl:attribute>
                  <!--</xsl:if>-->
                  <edm:rights>
                    <xsl:attribute name="rdf:resource">
                      <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
                    </xsl:attribute>
                  </edm:rights>
                  <dc:rights>
                    <xsl:attribute name="rdf:resource">
                      <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
                    </xsl:attribute>
                  </dc:rights>
                </edm:WebResource>
              </edm:isDerivativeOf>
            </edm:WebResource>
          </xsl:for-each>
        </edm:isShownAt>
        
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
                  <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
                    <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
                    <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
                  <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
    
    
  <!-- Begin Aggregations under tei:body/tei:div/tei:div/tei:p/tei:pb --> 
    
    <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:div/tei:p/tei:pb">
      <ore:Aggregation>
        <xsl:attribute name="rdf:about">
          <xsl:value-of select="$aggregation"/>
          <xsl:value-of select="concat('page_',@xml:id)"/>
        </xsl:attribute>
 
        <edm:aggregatedCHO>
          
          
          <!-- Begin CHOs under tei:body/tei:div/tei:div/tei:p/tei:pb -->
        
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
                 <dm2e:subtitle>
                   <xsl:attribute name="xml:lang">
                     <xsl:text>de</xsl:text>
                   </xsl:attribute> 
                   <xsl:value-of select="."/>
                 </dm2e:subtitle>
               </xsl:if>
             </xsl:for-each>
             
             <xsl:choose>
               <xsl:when test="following-sibling::tei:head">
                 <dm2e:subtitle>   
                   <xsl:attribute name="xml:lang">
                     <xsl:text>de</xsl:text>
                   </xsl:attribute>
                       <xsl:value-of select="following-sibling::tei:head"/>
                 </dm2e:subtitle>     
               </xsl:when>
               <xsl:otherwise> 
                 <xsl:choose>
                   <xsl:when test="following-sibling::tei:pb">
                     <dm2e:subtitle>   
                       <xsl:attribute name="xml:lang">
                         <xsl:text>de</xsl:text>
                       </xsl:attribute>
                     </dm2e:subtitle> 
                   </xsl:when>
                   <xsl:otherwise>
                     <xsl:choose>
                       <xsl:when test="not(parent::node()/following-sibling::*[1][child::*[1][self::tei:head]]) or following-sibling::*[child::*[self::tei:pb]]">
                         <dm2e:subtitle>   
                           <xsl:attribute name="xml:lang">
                             <xsl:text>de</xsl:text>
                           </xsl:attribute>
                         </dm2e:subtitle>
                       </xsl:when>
                       <xsl:otherwise>
                         <dm2e:subtitle>   
                           <xsl:attribute name="xml:lang">
                             <xsl:text>de</xsl:text>
                           </xsl:attribute>
                           <xsl:for-each select="following::tei:div/tei:head">
                             <xsl:if test="position()=1">
                               <xsl:value-of select="."/>
                             </xsl:if>
                           </xsl:for-each>
                         </dm2e:subtitle>
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
            
           <xsl:choose>
             <xsl:when test="contains(@n,'S')">
               <bibo:number rdf:datatype="http://www.w3.org/2001/XMLSchema#unsignedInt">
                 <xsl:value-of select="number(substring-after(@n, 'S. '))"/>
               </bibo:number>
             </xsl:when>
             <xsl:otherwise>
               <bibo:number rdf:datatype="http://www.w3.org/2001/XMLSchema#unsignedInt">
                 <xsl:value-of select="number(@n)"/>
               </bibo:number>
             </xsl:otherwise>
           </xsl:choose> 
          
             <xsl:for-each select="../../../../../tei:front/tei:titlePart/tei:persName">
               <pro:author>
                 <foaf:Person> 
                   <xsl:attribute name="rdf:about">
                     <xsl:value-of select="$agent"/>
                     <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
                   </xsl:attribute>
                   <skos:prefLabel>
                     <xsl:attribute name="xml:lang">
                       <xsl:text>de</xsl:text>
                     </xsl:attribute>
                     <xsl:value-of select="."/>
                   </skos:prefLabel>
                 </foaf:Person>
               </pro:author>
             </xsl:for-each>
     
             <!-- Related CHOs (under tei:body/tei:div/tei:div/tei:p/tei:pb) -->
             
             <dcterms:isPartOf>
               <edm:ProvidedCHO>
                 <xsl:attribute name="rdf:about">
                   <xsl:value-of select="$cho"/>
                   <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:idno">
                     <xsl:if test="position() = 1">
                       <xsl:value-of select="replace(substring-after(.,'.de/'),'/','_')"/>
                     </xsl:if>
                   </xsl:for-each>
                 </xsl:attribute>
               </edm:ProvidedCHO>
             </dcterms:isPartOf> 
             
             <xsl:choose>
               <xsl:when test="contains(@xml:id,'pbzu')">
                 <edm:isNextInSequence>
                   <edm:ProvidedCHO>
                     <xsl:attribute name="rdf:about">
                       <xsl:value-of select="$cho"/>
                       <xsl:variable name="stringback">
                         <xsl:value-of select="string(number(substring-after(@xml:id, 'S._'))-1)"/>
                       </xsl:variable>
                       <xsl:value-of select="if(string-length($stringback)=1)
                         then concat('page_',(substring-before(@xml:id, '_pbzu')),'_pb00', $stringback)
                         else if (string-length($stringback) = 2 )
                         then concat('page_',(substring-before(@xml:id, '_pbzu')),'_pb0', $stringback)
                         else concat('page_',(substring-before(@xml:id, '_pbzu')),'_pb', $stringback)"/>
                     </xsl:attribute>
                   </edm:ProvidedCHO>
                 </edm:isNextInSequence> 
               </xsl:when>
               <xsl:otherwise>
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
               </xsl:otherwise>
             </xsl:choose> 
             
             <dm2e:levelOfHierarchy rdf:datatype="http://www.w3.org/2001/XMLSchema#unsignedInt">
               <xsl:text>4</xsl:text>
             </dm2e:levelOfHierarchy>        
     
          </edm:ProvidedCHO>
        </edm:aggregatedCHO>
   
        <!-- End of CHO (under tei:body/tei:div/tei:div/tei:p/tei:pb) -->
        
        
        <!-- Aggregation (under tei:body/tei:div/tei:div/tei:p/tei:pb) -->
        
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
              <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:persName">
                <xsl:if test="position() = 1">
                  <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
                <owl:sameAs>
                  <xsl:value-of select="@ref"/>
                </owl:sameAs>
              </xsl:if>
            </xsl:for-each>
          </foaf:Organization>
        </edm:dataProvider>
        
        <edm:rights>
          <xsl:attribute name="rdf:resource">
            <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
          </xsl:attribute>
        </edm:rights>
        
       
        <edm:object>
          <edm:WebResource>
            <xsl:attribute name="rdf:about">
                  <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                    substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/' , substring-after(@facs,'/'),
                    '.tif.thumbnail.jpg')"/>
            </xsl:attribute>     
            <dc:format>
              <xsl:text>image/jpeg</xsl:text>
            </dc:format>
            <edm:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
              </xsl:attribute>
            </edm:rights>
          </edm:WebResource>
        </edm:object>
        
        <dm2e:hasAnnotatableVersionAt>
          <edm:WebResource>
            <xsl:attribute name="rdf:about">
              <!--<xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:div/tei:p/tei:pb">-->
              <xsl:value-of select= "concat('http://dingler.culture.hu-berlin.de/journal/page/',
                  substring-before(@xml:id,'_'),'?p=',substring-after(@facs,'/'))"/>
             <!--</xsl:for-each>-->
            </xsl:attribute>
            <dc:format>
              <xsl:text>text/html</xsl:text>
            </dc:format>
            <edm:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
              </xsl:attribute>
            </edm:rights>
            <dc:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
              </xsl:attribute>
            </dc:rights>
          </edm:WebResource>
        </dm2e:hasAnnotatableVersionAt>
        
        <dm2e:hasAnnotatableVersionAt>
          <edm:WebResource>
            <xsl:attribute name="rdf:about">
                  <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                    substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/' , substring-after(@facs,'/'),
                    '.tif.medium.jpg')"/>
            </xsl:attribute>
            <dc:format>
              <xsl:text>image/jpeg</xsl:text>
            </dc:format>
            <edm:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
              </xsl:attribute>
            </edm:rights>
          </edm:WebResource>
        </dm2e:hasAnnotatableVersionAt>
        
        <edm:isShownBy>
          <edm:WebResource>
            <xsl:attribute name="rdf:about">
              <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/' , substring-after(@facs,'/'),
                '.tif.medium.jpg')"/>
            </xsl:attribute>
            <edm:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
              </xsl:attribute>
            </edm:rights>
          </edm:WebResource>
        </edm:isShownBy>
        
     <!--   <dm2e:fuenftesCHO>
          tei:div/tei:div/tei:p/tei:pb
        </dm2e:fuenftesCHO>-->
        
        <edm:isShownAt>
          <xsl:for-each select=".">
            <edm:WebResource>
              <xsl:attribute name="rdf:about">
                <xsl:value-of select= "concat('http://dingler.culture.hu-berlin.de/journal/page/',
                  substring-before(@xml:id,'_'),'?p=',substring-after(@facs,'/'))"/>
              </xsl:attribute>
              <!--<xsl:if test=".">
                  <xsl:attribute name="rdf:about">
                    <xsl:for-each select=".">
                      <xsl:if test="position() = 1">
                        <xsl:value-of select="substring-before(.,'/ar')"/>
                      </xsl:if>
                    </xsl:for-each>
                  </xsl:attribute>
                </xsl:if>-->
              <xsl:for-each select="../../tei:seriesStmt/tei:title">
                <dc:description>
                  <xsl:attribute name="xml:lang">
                    <xsl:text>de</xsl:text>
                  </xsl:attribute>
                  <xsl:value-of select="."/>
                </dc:description>
              </xsl:for-each>
              <edm:rights>
                <xsl:attribute name="rdf:resource">
                  <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
                </xsl:attribute>
              </edm:rights>
              <dc:rights>
                <xsl:attribute name="rdf:resource">
                  <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
                </xsl:attribute>
              </dc:rights>
              <!--                TODO to check all isDerivativeOf-->
              <edm:isDerivativeOf>
                <edm:WebResource>
                  <!-- <xsl:if test=".">-->
                  <xsl:attribute name="rdf:about">
                    <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:idno">
                      <xsl:if test="position() = 1">
                        <xsl:value-of select="substring-before(.,'article')"/>
                      </xsl:if>
                    </xsl:for-each>
                  </xsl:attribute>
                  <!--</xsl:if>-->
                  <edm:rights>
                    <xsl:attribute name="rdf:resource">
                      <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
                    </xsl:attribute>
                  </edm:rights>
                  <dc:rights>
                    <xsl:attribute name="rdf:resource">
                      <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
                    </xsl:attribute>
                  </dc:rights>
                </edm:WebResource>
              </edm:isDerivativeOf>
            </edm:WebResource>
          </xsl:for-each>
        </edm:isShownAt>
        
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
                  <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
                    <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
                    <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
    <!-- End CHOs under div:div:p:pb--> 
  
    <!-- Begin CHOs under div:p:pb--> 
    
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
                 <dm2e:subtitle>
                   <xsl:attribute name="xml:lang">
                     <xsl:text>de</xsl:text>
                   </xsl:attribute> 
                   <xsl:value-of select="."/>
                 </dm2e:subtitle>
               </xsl:if>
             </xsl:for-each>
             
          
          <!-- To do: klappt nicht mehr -->
          
             <xsl:choose>
               <xsl:when test="following-sibling::tei:head">
                 <dm2e:subtitle>   
                   <xsl:attribute name="xml:lang">
                     <xsl:text>de</xsl:text>
                   </xsl:attribute>
                   <xsl:value-of select="following-sibling::tei:head"/>
                 </dm2e:subtitle>     
               </xsl:when>
               <xsl:otherwise> 
                 <xsl:choose>
                   <xsl:when test="following-sibling::tei:pb">
                     <dm2e:subtitle>   
                       <xsl:attribute name="xml:lang">
                         <xsl:text>de</xsl:text>
                       </xsl:attribute>
                     </dm2e:subtitle> 
                   </xsl:when>
                   <xsl:otherwise>
                     <xsl:choose>
                       <xsl:when test="not(parent::node()/parent::node()/following-sibling::*[1][child::*[1][self::tei:head]]) or following-sibling::*[child::*[self::tei:pb]]">
                         <dm2e:subtitle>   
                           <xsl:attribute name="xml:lang">
                             <xsl:text>de</xsl:text>
                           </xsl:attribute>
                         </dm2e:subtitle>
                       </xsl:when>
                       <xsl:otherwise>
                         <dm2e:subtitle>   
                           <xsl:attribute name="xml:lang">
                             <xsl:text>de</xsl:text>
                           </xsl:attribute>
                           <xsl:for-each select="following::tei:div/tei:head">
                             <xsl:if test="position()=1">
                               <xsl:value-of select="."/>
                             </xsl:if>
                           </xsl:for-each>
                         </dm2e:subtitle>
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
            
             <bibo:number rdf:datatype="http://www.w3.org/2001/XMLSchema#unsignedInt">
                <xsl:value-of select="number(@n)"/>
             </bibo:number>
            
             <xsl:for-each select="../../../../tei:front/tei:titlePart/tei:persName">
               <pro:author>
                 <foaf:Person> 
                   <xsl:attribute name="rdf:about">
                     <xsl:value-of select="$agent"/>
                     <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
                   </xsl:attribute>
                   <skos:prefLabel>
                     <xsl:attribute name="xml:lang">
                       <xsl:text>de</xsl:text>
                     </xsl:attribute>
                     <xsl:value-of select="."/>
                   </skos:prefLabel>
                 </foaf:Person>
               </pro:author>
             </xsl:for-each>
             
             <!-- Related CHOs (div:p:pb) -->
             
             <dcterms:isPartOf>
               <edm:ProvidedCHO>
                 <xsl:attribute name="rdf:about">
                   <xsl:value-of select="$cho"/>
                   <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:idno">
                     <xsl:if test="position() = 1">
                       <xsl:value-of select="replace(substring-after(.,'.de/'),'/','_')"/>
                     </xsl:if>
                   </xsl:for-each>
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
             
             <dm2e:levelOfHierarchy rdf:datatype="http://www.w3.org/2001/XMLSchema#unsignedInt">
               <xsl:text>4</xsl:text>
             </dm2e:levelOfHierarchy>
             
          </edm:ProvidedCHO>
        </edm:aggregatedCHO>
   
        <!-- End of CHO (div:p:pb) -->
        
        
        <!-- Aggregation (div:p:pb) -->
        
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
              <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:persName">
                <xsl:if test="position() = 1">
                  <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
                <owl:sameAs>
                  <xsl:value-of select="@ref"/>
                </owl:sameAs>
              </xsl:if>
            </xsl:for-each>
          </foaf:Organization>
        </edm:dataProvider>
        
        <edm:rights>
          <xsl:attribute name="rdf:resource">
            <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
          </xsl:attribute>
        </edm:rights>
       
        <edm:object>
          <edm:WebResource>
            <xsl:attribute name="rdf:about">
                  <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                    substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/' , substring-after(@facs,'/'),
                    '.tif.thumbnail.jpg')"/>
            </xsl:attribute>     
            <dc:format>
              <xsl:text>image/jpeg</xsl:text>
            </dc:format>
            <edm:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
              </xsl:attribute>
            </edm:rights>
          </edm:WebResource>
        </edm:object>
        
        <dm2e:hasAnnotatableVersionAt>
          <edm:WebResource>
            <xsl:attribute name="rdf:about">
              <xsl:value-of select= "concat('http://dingler.culture.hu-berlin.de/journal/page/',
                  substring-before(@xml:id,'_'),'?p=',substring-after(@facs,'/'))"/>
            </xsl:attribute>
            <dc:format>
              <xsl:text>text/html</xsl:text>
            </dc:format>
            <edm:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
              </xsl:attribute>
            </edm:rights>
            <dc:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
              </xsl:attribute>
            </dc:rights>
          </edm:WebResource>
        </dm2e:hasAnnotatableVersionAt>
        
        <dm2e:hasAnnotatableVersionAt>
          <edm:WebResource>
            <xsl:attribute name="rdf:about">
                  <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                    substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/' , substring-after(@facs,'/'),
                    '.tif.medium.jpg')"/>
            </xsl:attribute>
            <dc:format>
              <xsl:text>image/jpeg</xsl:text>
            </dc:format>
            <edm:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
              </xsl:attribute>
            </edm:rights>
          </edm:WebResource>
        </dm2e:hasAnnotatableVersionAt>
        
        <edm:isShownBy>
          <edm:WebResource>
            <xsl:attribute name="rdf:about">
              <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/' , substring-after(@facs,'/'),
                '.tif.medium.jpg')"/>
            </xsl:attribute>
            <edm:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
              </xsl:attribute>
            </edm:rights>
          </edm:WebResource>
        </edm:isShownBy>
        
       <!-- <dm2e:sechtesCHO>
          div:p:pb
        </dm2e:sechtesCHO>-->
        
        <edm:isShownAt>
          <xsl:for-each select=".">
            <edm:WebResource>
              <xsl:attribute name="rdf:about">
                <xsl:value-of select= "concat('http://dingler.culture.hu-berlin.de/journal/page/',
                  substring-before(@xml:id,'_'),'?p=',substring-after(@facs,'/'))"/>
              </xsl:attribute>
              <!--<xsl:if test=".">
                  <xsl:attribute name="rdf:about">
                    <xsl:for-each select=".">
                      <xsl:if test="position() = 1">
                        <xsl:value-of select="substring-before(.,'/ar')"/>
                      </xsl:if>
                    </xsl:for-each>
                  </xsl:attribute>
                </xsl:if>-->
              <xsl:for-each select="../../tei:seriesStmt/tei:title">
                <dc:description>
                  <xsl:attribute name="xml:lang">
                    <xsl:text>de</xsl:text>
                  </xsl:attribute>
                  <xsl:value-of select="."/>
                </dc:description>
              </xsl:for-each>
              <edm:rights>
                <xsl:attribute name="rdf:resource">
                  <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
                </xsl:attribute>
              </edm:rights>
              <dc:rights>
                <xsl:attribute name="rdf:resource">
                  <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
                </xsl:attribute>
              </dc:rights>
              <!--                TODO to check all isDerivativeOf-->
              <edm:isDerivativeOf>
                <edm:WebResource>
                  <!-- <xsl:if test=".">-->
                  <xsl:attribute name="rdf:about">
                    <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:idno">
                      <xsl:if test="position() = 1">
                        <xsl:value-of select="substring-before(.,'article')"/>
                      </xsl:if>
                    </xsl:for-each>
                  </xsl:attribute>
                  <!--</xsl:if>-->
                  <edm:rights>
                    <xsl:attribute name="rdf:resource">
                      <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
                    </xsl:attribute>
                  </edm:rights>
                  <dc:rights>
                    <xsl:attribute name="rdf:resource">
                      <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
                    </xsl:attribute>
                  </dc:rights>
                </edm:WebResource>
              </edm:isDerivativeOf>
            </edm:WebResource>
          </xsl:for-each>
        </edm:isShownAt>
        
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
                  <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
                    <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
                    <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
                  <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
   
    <!-- Begin CHOs under tei:TEI/tei:text/tei:body/tei:div/tei:table/tei:row/tei:cell/tei:pb -->
    
   <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:table/tei:row/tei:cell/tei:pb">
      <ore:Aggregation>
        <xsl:attribute name="rdf:about">
          <xsl:value-of select="$aggregation"/>
          <xsl:value-of select="concat('page_',@xml:id)"/>
        </xsl:attribute>
 
        <edm:aggregatedCHO>
          
          <!-- Begin CHO (div:table:row:cell:pb) -->
        
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
                 <dm2e:subtitle>
                   <xsl:attribute name="xml:lang">
                     <xsl:text>de</xsl:text>
                   </xsl:attribute> 
                   <xsl:value-of select="."/>
                 </dm2e:subtitle>
               </xsl:if>
             </xsl:for-each>
             
          
          <!-- To do: klappt nicht mehr -->
          
             <xsl:choose>
               <xsl:when test="following-sibling::tei:head">
                 <dm2e:subtitle>   
                   <xsl:attribute name="xml:lang">
                     <xsl:text>de</xsl:text>
                   </xsl:attribute>
                   <xsl:value-of select="following-sibling::tei:head"/>
                 </dm2e:subtitle>     
               </xsl:when>
               <xsl:otherwise> 
                 <xsl:choose>
                   <xsl:when test="following-sibling::tei:pb">
                     <dm2e:subtitle>   
                       <xsl:attribute name="xml:lang">
                         <xsl:text>de</xsl:text>
                       </xsl:attribute>
                     </dm2e:subtitle> 
                   </xsl:when>
                   <xsl:otherwise>
                     <xsl:choose>
                       <xsl:when test="not(parent::node()/parent::node()/following-sibling::*[1][child::*[1][self::tei:head]]) or following-sibling::*[child::*[self::tei:pb]]">
                         <dm2e:subtitle>   
                           <xsl:attribute name="xml:lang">
                             <xsl:text>de</xsl:text>
                           </xsl:attribute>
                         </dm2e:subtitle>
                       </xsl:when>
                       <xsl:otherwise>
                         <dm2e:subtitle>   
                           <xsl:attribute name="xml:lang">
                             <xsl:text>de</xsl:text>
                           </xsl:attribute>
                           <xsl:for-each select="following::tei:div/tei:head">
                             <xsl:if test="position()=1">
                               <xsl:value-of select="."/>
                             </xsl:if>
                           </xsl:for-each>
                         </dm2e:subtitle>
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
            
             <bibo:number rdf:datatype="http://www.w3.org/2001/XMLSchema#unsignedInt">
                <xsl:value-of select="number(@n)"/>
             </bibo:number>
          
             <xsl:for-each select="../../../../../../tei:front/tei:titlePart/tei:persName">
               <pro:author>
                 <foaf:Person> 
                   <xsl:attribute name="rdf:about">
                     <xsl:value-of select="$agent"/>         
                     <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
                   </xsl:attribute>
                   <skos:prefLabel>
                     <xsl:attribute name="xml:lang">
                       <xsl:text>de</xsl:text>
                     </xsl:attribute>
                     <xsl:value-of select="."/>
                   </skos:prefLabel>
                 </foaf:Person>
               </pro:author>
             </xsl:for-each>
   
             <!-- Related CHOs (div:tabel:row:cell:pb) -->
             
             <dcterms:isPartOf>
               <edm:ProvidedCHO>
                 <xsl:attribute name="rdf:about">
                   <xsl:value-of select="$cho"/>
                   <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:idno">
                     <xsl:if test="position() = 1">
                       <xsl:value-of select="replace(substring-after(.,'.de/'),'/','_')"/>
                     </xsl:if>
                   </xsl:for-each>
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
             
             <dm2e:levelOfHierarchy rdf:datatype="http://www.w3.org/2001/XMLSchema#unsignedInt">
               <xsl:text>4</xsl:text>
             </dm2e:levelOfHierarchy>
        
          </edm:ProvidedCHO>
        </edm:aggregatedCHO>
   
        <!-- End of CHO (div:tabel:row:cell:pb) -->
        
        
        <!-- Aggregation (div:tabel:row:cell:pb) -->
        
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
              <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:persName">
                <xsl:if test="position() = 1">
                  <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
                <owl:sameAs>
                  <xsl:value-of select="@ref"/>
                </owl:sameAs>
              </xsl:if>
            </xsl:for-each>
          </foaf:Organization>
        </edm:dataProvider>
        
        <edm:rights>
          <xsl:attribute name="rdf:resource">
            <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
          </xsl:attribute>
        </edm:rights>
       
        <edm:object>
          <edm:WebResource>
            <xsl:attribute name="rdf:about">
                  <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                    substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/' , substring-after(@facs,'/'),
                    '.tif.thumbnail.jpg')"/>
            </xsl:attribute>     
            <dc:format>
              <xsl:text>image/jpeg</xsl:text>
            </dc:format>
            <edm:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
              </xsl:attribute>
            </edm:rights>
          </edm:WebResource>
        </edm:object>
        
        <dm2e:hasAnnotatableVersionAt>
          <edm:WebResource>
            <xsl:attribute name="rdf:about">
              <xsl:value-of select= "concat('http://dingler.culture.hu-berlin.de/journal/page/',
                  substring-before(@xml:id,'_'),'?p=',substring-after(@facs,'/'))"/>
            </xsl:attribute>
            <dc:format>
              <xsl:text>text/html</xsl:text>
            </dc:format>
            <edm:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
              </xsl:attribute>
            </edm:rights>
            <dc:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
              </xsl:attribute>
            </dc:rights>
          </edm:WebResource>
        </dm2e:hasAnnotatableVersionAt>
        
        <dm2e:hasAnnotatableVersionAt>
          <edm:WebResource>
            <xsl:attribute name="rdf:about">
                  <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                    substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/' , substring-after(@facs,'/'),
                    '.tif.medium.jpg')"/>
            </xsl:attribute>
            <dc:format>
              <xsl:text>image/jpeg</xsl:text>
            </dc:format>
            <edm:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
              </xsl:attribute>
            </edm:rights>
          </edm:WebResource>
        </dm2e:hasAnnotatableVersionAt>
        
        <edm:isShownBy>
          <edm:WebResource>
            <xsl:attribute name="rdf:about">
              <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/' , substring-after(@facs,'/'),
                '.tif.medium.jpg')"/>
            </xsl:attribute>
            <dc:format>
              <xsl:text>image/jpeg</xsl:text>
            </dc:format>
            <edm:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
              </xsl:attribute>
            </edm:rights>
          </edm:WebResource>
        </edm:isShownBy>
       <!-- 
        <dm2e:siebtesCHO>
          div:table:row:cell:pb
        </dm2e:siebtesCHO>-->
        
        <edm:isShownAt>
          <xsl:for-each select=".">
            <edm:WebResource>
              <xsl:attribute name="rdf:about">
                <xsl:value-of select= "concat('http://dingler.culture.hu-berlin.de/journal/page/',
                  substring-before(@xml:id,'_'),'?p=',substring-after(@facs,'/'))"/>
              </xsl:attribute>
              <!--<xsl:if test=".">
                  <xsl:attribute name="rdf:about">
                    <xsl:for-each select=".">
                      <xsl:if test="position() = 1">
                        <xsl:value-of select="substring-before(.,'/ar')"/>
                      </xsl:if>
                    </xsl:for-each>
                  </xsl:attribute>
                </xsl:if>-->
              <xsl:for-each select="../../tei:seriesStmt/tei:title">
                <dc:description>
                  <xsl:attribute name="xml:lang">
                    <xsl:text>de</xsl:text>
                  </xsl:attribute>
                  <xsl:value-of select="."/>
                </dc:description>
              </xsl:for-each>
              <edm:rights>
                <xsl:attribute name="rdf:resource">
                  <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
                </xsl:attribute>
              </edm:rights>
              <dc:rights>
                <xsl:attribute name="rdf:resource">
                  <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
                </xsl:attribute>
              </dc:rights>
              <!--                TODO to check all isDerivativeOf-->
              <edm:isDerivativeOf>
                <edm:WebResource>
                  <!-- <xsl:if test=".">-->
                  <xsl:attribute name="rdf:about">
                    <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:idno">
                      <xsl:if test="position() = 1">
                        <xsl:value-of select="substring-before(.,'article')"/>
                      </xsl:if>
                    </xsl:for-each>
                  </xsl:attribute>
                  <!--</xsl:if>-->
                  <edm:rights>
                    <xsl:attribute name="rdf:resource">
                      <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
                    </xsl:attribute>
                  </edm:rights>
                  <dc:rights>
                    <xsl:attribute name="rdf:resource">
                      <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
                    </xsl:attribute>
                  </dc:rights>
                </edm:WebResource>
              </edm:isDerivativeOf>
            </edm:WebResource>
          </xsl:for-each>
        </edm:isShownAt>
        
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
                  <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
                    <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
                    <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
                  <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
<!--   End Aggregations tei:TEI/tei:text/tei:body/tei:div/tei:table/tei:row/tei:cell/tei:pb-->
    
<!-- Begin CHOs under tei:TEI/tei:text/tei:body/tei:div/tei:p/tei:q/tei:pb -->
    
    <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:div/tei:p/tei:q/tei:pb">
      <ore:Aggregation>
        <xsl:attribute name="rdf:about">
          <xsl:value-of select="$aggregation"/>
          <xsl:value-of select="concat('page_',@xml:id)"/>
        </xsl:attribute>
 
        <edm:aggregatedCHO>
          
          <!-- Begin CHO (div:table:row:cell:pb) -->
        
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
                 <dm2e:subtitle>
                   <xsl:attribute name="xml:lang">
                     <xsl:text>de</xsl:text>
                   </xsl:attribute> 
                   <xsl:value-of select="."/>
                 </dm2e:subtitle>
               </xsl:if>
             </xsl:for-each>
             
          
          <!-- To do: klappt nicht mehr -->
          
             <xsl:choose>
               <xsl:when test="following-sibling::tei:head">
                 <dm2e:subtitle>   
                   <xsl:attribute name="xml:lang">
                     <xsl:text>de</xsl:text>
                   </xsl:attribute>
                   <xsl:value-of select="following-sibling::tei:head"/>
                 </dm2e:subtitle>     
               </xsl:when>
               <xsl:otherwise> 
                 <xsl:choose>
                   <xsl:when test="following-sibling::tei:pb">
                     <dm2e:subtitle>   
                       <xsl:attribute name="xml:lang">
                         <xsl:text>de</xsl:text>
                       </xsl:attribute>
                     </dm2e:subtitle> 
                   </xsl:when>
                   <xsl:otherwise>
                     <xsl:choose>
                       <xsl:when test="not(parent::node()/parent::node()/following-sibling::*[1][child::*[1][self::tei:head]]) or following-sibling::*[child::*[self::tei:pb]]">
                         <dm2e:subtitle>   
                           <xsl:attribute name="xml:lang">
                             <xsl:text>de</xsl:text>
                           </xsl:attribute>
                         </dm2e:subtitle>
                       </xsl:when>
                       <xsl:otherwise>
                         <dm2e:subtitle>   
                           <xsl:attribute name="xml:lang">
                             <xsl:text>de</xsl:text>
                           </xsl:attribute>
                           <xsl:for-each select="following::tei:div/tei:head">
                             <xsl:if test="position()=1">
                               <xsl:value-of select="."/>
                             </xsl:if>
                           </xsl:for-each>
                         </dm2e:subtitle>
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
            
             <bibo:number rdf:datatype="http://www.w3.org/2001/XMLSchema#unsignedInt">
                <xsl:value-of select="number(@n)"/>
             </bibo:number>
          
             <xsl:for-each select="../../../../../tei:front/tei:titlePart/tei:persName">
               <pro:author>
                 <foaf:Person> 
                   <xsl:attribute name="rdf:about">
                     <xsl:value-of select="$agent"/>         
                     <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
                   </xsl:attribute>
                   <skos:prefLabel>
                     <xsl:attribute name="xml:lang">
                       <xsl:text>de</xsl:text>
                     </xsl:attribute>
                     <xsl:value-of select="."/>
                   </skos:prefLabel>
                 </foaf:Person>
               </pro:author>
             </xsl:for-each>
   
             <!-- Related CHOs (div:tabel:row:cell:pb) -->
             
             <dcterms:isPartOf>
               <edm:ProvidedCHO>
                 <xsl:attribute name="rdf:about">
                   <xsl:value-of select="$cho"/>
                   <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:idno">
                     <xsl:if test="position() = 1">
                       <xsl:value-of select="replace(substring-after(.,'.de/'),'/','_')"/>
                     </xsl:if>
                   </xsl:for-each>
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
             
             <dm2e:levelOfHierarchy rdf:datatype="http://www.w3.org/2001/XMLSchema#unsignedInt">
               <xsl:text>4</xsl:text>
             </dm2e:levelOfHierarchy>
        
          </edm:ProvidedCHO>
        </edm:aggregatedCHO>
   
        <!-- End of CHO (div:tabel:row:cell:pb) -->
        
        
        <!-- Aggregation (div:tabel:row:cell:pb) -->
        
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
              <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:persName">
                <xsl:if test="position() = 1">
                  <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
                <owl:sameAs>
                  <xsl:value-of select="@ref"/>
                </owl:sameAs>
              </xsl:if>
            </xsl:for-each>
          </foaf:Organization>
        </edm:dataProvider>
        
        <edm:rights>
          <xsl:attribute name="rdf:resource">
            <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
          </xsl:attribute>
        </edm:rights>
        
        <edm:object>
          <edm:WebResource>
            <xsl:attribute name="rdf:about">
                  <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                    substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/' , substring-after(@facs,'/'),
                    '.tif.thumbnail.jpg')"/>
            </xsl:attribute>     
            <dc:format>
              <xsl:text>image/jpeg</xsl:text>
            </dc:format>
            <edm:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
              </xsl:attribute>
            </edm:rights>
          </edm:WebResource>
        </edm:object>
        
        <dm2e:hasAnnotatableVersionAt>
          <edm:WebResource>
            <xsl:attribute name="rdf:about">
              <xsl:value-of select= "concat('http://dingler.culture.hu-berlin.de/journal/page/',
                  substring-before(@xml:id,'_'),'?p=',substring-after(@facs,'/'))"/>
            </xsl:attribute>
            <dc:format>
              <xsl:text>text/html</xsl:text>
            </dc:format>
            <edm:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
              </xsl:attribute>
            </edm:rights>
            <dc:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
              </xsl:attribute>
            </dc:rights>
          </edm:WebResource>
        </dm2e:hasAnnotatableVersionAt>
        
        <dm2e:hasAnnotatableVersionAt>
          <edm:WebResource>
            <xsl:attribute name="rdf:about">
                  <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                    substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/' , substring-after(@facs,'/'),
                    '.tif.medium.jpg')"/>
            </xsl:attribute>
            <dc:format>
              <xsl:text>image/jpeg</xsl:text>
            </dc:format>
            <edm:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
              </xsl:attribute>
            </edm:rights>
          </edm:WebResource>
        </dm2e:hasAnnotatableVersionAt>
        
        <edm:isShownBy>
          <edm:WebResource>
            <xsl:attribute name="rdf:about">
              <xsl:value-of select= "concat('http://www.polytechnischesjournal.de/fileadmin/data/',
                substring-before(@facs,'/'),'/', substring-before(@facs,'/'),  '_tif/jpegs/' , substring-after(@facs,'/'),
                '.tif.medium.jpg')"/>
            </xsl:attribute>
            <dc:format>
              <xsl:text>image/jpeg</xsl:text>
            </dc:format>
            <edm:rights>
              <xsl:attribute name="rdf:resource">
                <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
              </xsl:attribute>
            </edm:rights>
          </edm:WebResource>
        </edm:isShownBy>
        
     <!--   <dm2e:achtesCHO>
          div:p:q:pb
        </dm2e:achtesCHO>
        -->
        <edm:isShownAt>
          <xsl:for-each select=".">
            <edm:WebResource>
              <xsl:attribute name="rdf:about">
                <xsl:value-of select= "concat('http://dingler.culture.hu-berlin.de/journal/page/',
                  substring-before(@xml:id,'_'),'?p=',substring-after(@facs,'/'))"/>
              </xsl:attribute>
              <!--<xsl:if test=".">
                  <xsl:attribute name="rdf:about">
                    <xsl:for-each select=".">
                      <xsl:if test="position() = 1">
                        <xsl:value-of select="substring-before(.,'/ar')"/>
                      </xsl:if>
                    </xsl:for-each>
                  </xsl:attribute>
                </xsl:if>-->
              <xsl:for-each select="../../tei:seriesStmt/tei:title">
                <dc:description>
                  <xsl:attribute name="xml:lang">
                    <xsl:text>de</xsl:text>
                  </xsl:attribute>
                  <xsl:value-of select="."/>
                </dc:description>
              </xsl:for-each>
              <edm:rights>
                <xsl:attribute name="rdf:resource">
                  <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
                </xsl:attribute>
              </edm:rights>
              <dc:rights>
                <xsl:attribute name="rdf:resource">
                  <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
                </xsl:attribute>
              </dc:rights>
              <!--                TODO to check all isDerivativeOf-->
              <edm:isDerivativeOf>
                <edm:WebResource>
                  <!-- <xsl:if test=".">-->
                  <xsl:attribute name="rdf:about">
                    <xsl:for-each select="$theTEIHeader/tei:fileDesc/tei:publicationStmt/tei:idno">
                      <xsl:if test="position() = 1">
                        <xsl:value-of select="substring-before(.,'article')"/>
                      </xsl:if>
                    </xsl:for-each>
                  </xsl:attribute>
                  <!--</xsl:if>-->
                  <edm:rights>
                    <xsl:attribute name="rdf:resource">
                      <xsl:value-of select="$RIGHTS_RESOURCE_FACSIMILES"/>
                    </xsl:attribute>
                  </edm:rights>
                  <dc:rights>
                    <xsl:attribute name="rdf:resource">
                      <xsl:value-of select="$RIGHTS_RESOURCE_METADATA"/>
                    </xsl:attribute>
                  </dc:rights>
                </edm:WebResource>
              </edm:isDerivativeOf>
            </edm:WebResource>
          </xsl:for-each>
        </edm:isShownAt>
        
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
                  <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
                    <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
                    <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
                  <xsl:value-of select="encode-for-uri(translate(normalize-space(.),' ',''))"/>
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
    
    <!--   End Aggregations tei:TEI/tei:text/tei:body/tei:div/tei:table/tei:row/tei:cell/tei:pb-->
    
  </xsl:template>
  
  <!--<xsl:template match="tei:pb">
    <xsl:value-of select="@xml:id"></xsl:value-of>
  </xsl:template>-->
  
</xsl:stylesheet>
