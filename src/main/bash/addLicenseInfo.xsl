<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:cc="http://creativecommons.org/ns#"
	xmlns:odrl="http://www.w3.org/ns/odrl/2/"
	xmlns:ore="http://www.openarchives.org/ore/terms/"
	xmlns:edm="http://www.europeana.eu/schemas/edm/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
    
    
    <xsl:output method="xml" encoding="utf-8" indent="yes"/>
    
    <!-- Identity template : copy all text nodes, elements and attributes -->   
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>
    
    <!-- When matching ore:Aggregation having edm rights europeana ooc-nc with appendix, append license info. -->
    <xsl:template match="ore:Aggregation">
		<xsl:copy-of select="."/>
	<!-- Attach license info -->
	<xsl:analyze-string select="./edm:rights/@rdf:resource" regex="http://www.europeana.eu/rights/out-of-copyright-non-commercial/(.+)">
		<xsl:matching-substring>
			<cc:License>
				<xsl:attribute name="rdf:about">
					<xsl:value-of select="."/>
				</xsl:attribute>
				<cc:inheritFrom rdf:resource="http://www.europeana.eu/rights/out-of-copyright-non-commercial/"/>
				<odrl:deprecatedOn rdf:datatype="http://www.w3.org/2001/XMLSchema-datatypes#date">
					<!--[YYYY-MM-DD]-->
					<xsl:value-of select="regex-group(1)"/>
				</odrl:deprecatedOn>
			</cc:License>	
		</xsl:matching-substring>
	</xsl:analyze-string>
    </xsl:template>    
            
    
</xsl:stylesheet>
