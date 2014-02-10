<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/dc/"
    xmlns:oai_rights="http://www.openarchives.org/OAI/2.0/rights/"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dm2e_helper_ns="urn:x-dm2e:"
    >
    <xsl:output omit-xml-declaration="yes" indent="yes"/>
    <!-- <xsl:strip-space elements="*"/> -->

    <xsl:template match="oai_rights:rightsReference">
        <xsl:copy>
            <xsl:attribute name="ref">
                <xsl:value-of select="@rdf:resource"/>
            </xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="node()">
        <xsl:copy>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="oai:header">
        <oai:header>
            <xsl:apply-templates select="rdf:Description/oai:identifier"/>
            <oai:datestamp>2013-12-13</oai:datestamp>
        </oai:header>
    </xsl:template>

    <xsl:template match="oai:record">
        <oai:record>
            <xsl:apply-templates select="rdf:Description/oai:header"/>
            <xsl:apply-templates select="rdf:Description/oai:metadata"/>
            <xsl:apply-templates select="rdf:Description/oai:about"/>
        </oai:record>
    </xsl:template>

    <xsl:template match="rdf:RDF">
        <oai:OAI-PMH
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
            xmlns:oai="http://www.openarchives.org/OAI/2.0/"
            xmlns:oai_rights="http://www.openarchives.org/OAI/2.0/rights/"
            xmlns:dc="http://purl.org/dc/elements/1.1/"
            xmlns:dm2e_helper_ns="urn:x-dm2e:">
        <oai:responseDate>2013-12-13T14:44:45.070270</oai:responseDate>
        <oai:request />
        <oai:ListRecords>
            <xsl:apply-templates select="*"/>
            <!-- <xsl:call-template name="rdf_resource_to_element_value"> -->
            <!-- </xsl:call-template> -->
        </oai:ListRecords>
        </oai:OAI-PMH>
    </xsl:template>

    <!-- delete rdf:Descriptions, keep inner nodes -->
    <xsl:template match="rdf:Description">
        <xsl:apply-templates select="*"/>
    </xsl:template>
    <xsl:template match="oai:dc">
        <oai:dc>
            <xsl:apply-templates select="*"/>
        </oai:dc>
    </xsl:template>

    <!-- replace rdf:type -->
    <xsl:template match="dm2e_helper_ns:rdf_type">
        <!-- <rdf:type> -->
        <!--     <xsl:attribute name="rdf:resource"> -->
        <!--         <xsl:value-of select="@rdf:resource" /> -->
        <!--     </xsl:attribute> -->
        <!-- </rdf:type> -->
    </xsl:template>

    <!-- <xsl:template name="rdf_resource_to_element_value"> -->
    <!--     <xsl:copy> -->
    <!--         <xsl:value-of select="@rdf:resource"/> -->
    <!--     </xsl:copy> -->
    <!-- </xsl:template> -->

    <xsl:template match="dc:identifier">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="@rdf:datatype = 'urn:x-dm2e:fulltext'">
                    <xsl:attribute name="linktype">fulltext</xsl:attribute>
                </xsl:when>
                <xsl:when test="@rdf:datatype = 'urn:x-dm2e:thumbnail'">
                    <xsl:attribute name="linktype">thumbnail</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
