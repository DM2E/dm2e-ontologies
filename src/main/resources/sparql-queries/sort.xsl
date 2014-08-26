<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:edm="http://www.europeana.eu/schemas/edm/"
    xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:ore="http://www.openarchives.org/ore/terms/"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:rdaGr2="http://rdvocab.info/ElementsGr2/" 
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:wgs84_pos="http://www.w3.org/2003/01/geo/wgs84_pos#" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    version="1.0">
    <xsl:output method="xml" indent="yes"/>


    <!-- <xsl:template match="//edm:ProvidedCHO"> -->
    <!--     <foo> bar</foo> -->
    <!--         item -->
    <!--     <xsl:text> -->
    <!--         item -->
    <!--     </xsl:text> -->
    <!--     <xsl:apply-templates select="*"> -->
    <!--         <xsl:sort select="name()"/> -->
    <!--     </xsl:apply-templates> -->
    <!-- </xsl:template> -->

    <xsl:template match="text/text()" name="dm2e_identify">
        <xsl:param name="text" select="."/>
        <xsl:param name="separator" select="'/'"/>
        <xsl:param name="level" select="1" />
        <xsl:param name="oaiIdentifier" select="''" />
        <xsl:choose>
            <xsl:when test="not(contains($text, $separator))">
                <dc:identifier type="dm2e">
                    <xsl:value-of select="concat($oaiIdentifier, concat(':', $text))"/>
                </dc:identifier>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="dm2e_identify">
                    <xsl:with-param name="text" select="substring-after($text, $separator)"/>
                    <xsl:with-param name="oaiIdentifier">
                        <xsl:choose>
                            <xsl:when test="$level = 7">
                                <xsl:value-of select="substring-before($text, $separator)"/>
                            </xsl:when>
                            <xsl:when test="$level > 7">
                                <xsl:value-of select=" concat($oaiIdentifier, concat(':',substring-before($text, $separator)))"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$oaiIdentifier"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="level" select="$level + 1"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*[*]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="name() = 'ore:Aggregation'">
                    <xsl:apply-templates select="edm:aggregatedCHO"/>
                    <xsl:apply-templates select="edm:dataProvider"/>
                    <xsl:apply-templates select="edm:hasView"/>
                    <xsl:apply-templates select="edm:isShownAt"/>
                    <xsl:apply-templates select="edm:isShownBy"/>
                    <xsl:apply-templates select="edm:object"/>
                    <xsl:apply-templates select="edm:provider"/>
                    <xsl:apply-templates select="dc:rights"/>
                    <xsl:apply-templates select="edm:rights"/>
                    <xsl:apply-templates select="edm:ugc"/>
                </xsl:when>
                <xsl:when test="name() = 'edm:Agent'">
                    <xsl:apply-templates select="skos:prefLabel"/>
                    <xsl:apply-templates select="skos:altLabel"/>
                    <xsl:apply-templates select="skos:note"/>
                    <xsl:apply-templates select="dc:date"/>
                    <xsl:apply-templates select="dc:identifier"/>
                    <xsl:apply-templates select="edm:begin"/>
                    <xsl:apply-templates select="edm:end"/>
                    <xsl:apply-templates select="edm:hasMet"/>
                    <xsl:apply-templates select="edm:isRelatedTo"/>
                    <xsl:apply-templates select="foaf:name"/>
                    <xsl:apply-templates select="rdaGr2:biographicalInformation"/>
                    <xsl:apply-templates select="rdaGr2:dateOfBirth"/>
                    <xsl:apply-templates select="rdaGr2:dateOfDeath"/>
                    <xsl:apply-templates select="rdaGr2:dateOfEstablishment"/>
                    <xsl:apply-templates select="rdaGr2:dateOfTermination"/>
                    <xsl:apply-templates select="rdaGr2:gender"/>
                    <xsl:apply-templates select="rdaGr2:professionOrOccupation"/>
                    <xsl:apply-templates select="owl:sameAs"/>
                </xsl:when>
                <xsl:when test="name() = 'edm:Place'">
                    <xsl:apply-templates select="wgs84_pos:lat"/>
                    <xsl:apply-templates select="wgs84_pos:long"/>
                    <xsl:apply-templates select="wgs84_pos:alt"/>
                    <xsl:apply-templates select="skos:prefLabel"/>
                    <xsl:apply-templates select="skos:altLabel"/>
                    <xsl:apply-templates select="skos:note"/>
                    <xsl:apply-templates select="dcterms:hasPart"/>
                    <xsl:apply-templates select="dcterms:isPartOf"/>
                    <xsl:apply-templates select="owl:sameAs"/>
                </xsl:when>
                <xsl:when test="name() = 'edm:TimeSpan'">
                    <xsl:apply-templates select="skos:prefLabel"/>
                    <xsl:apply-templates select="skos:altLabel"/>
                    <xsl:apply-templates select="skos:note"/>
                    <xsl:apply-templates select="dcterms:hasPart"/>
                    <xsl:apply-templates select="dcterms:isPartOf"/>
                    <xsl:apply-templates select="edm:begin"/>
                    <xsl:apply-templates select="edm:end"/>
                    <xsl:apply-templates select="owl:sameAs"/>
                </xsl:when>
                <xsl:when test="name() = 'edm:ProvidedCHO'">
                    <xsl:call-template name="dm2e_identify">
                        <xsl:with-param name="text" select="@rdf:about" />
                    </xsl:call-template>
                    <xsl:apply-templates select="*" />
                </xsl:when>
                <xsl:when test="name() = 'skos:Concept'">
                    <xsl:apply-templates select="skos:prefLabel"/>
                    <xsl:apply-templates select="skos:altLabel"/>
                    <xsl:apply-templates select="skos:broader"/>
                    <xsl:apply-templates select="skos:narrower"/>
                    <xsl:apply-templates select="skos:related"/>
                    <xsl:apply-templates select="skos:broadMatch"/>  
                    <xsl:apply-templates select="skos:narrowMatch"/>  
                    <xsl:apply-templates select="skos:relatedMatch"/>
                    <xsl:apply-templates select="skos:exactMatch"/>
                    <xsl:apply-templates select="skos:closeMatch"/>
                    <xsl:apply-templates select="skos:note"/>
                    <xsl:apply-templates select="skos:notation"/>
                    <xsl:apply-templates select="skos:inScheme"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="*">
                        <xsl:sort select="name()"/>
                    </xsl:apply-templates>
                </xsl:otherwise> 
            </xsl:choose>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
