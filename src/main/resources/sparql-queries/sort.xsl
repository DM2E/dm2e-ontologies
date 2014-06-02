<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:ore="http://www.openarchives.org/ore/terms/"
    xmlns:edm="http://www.europeana.eu/schemas/edm/"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    version="1.0">

    <xsl:output method="xml" indent="yes"/>

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
