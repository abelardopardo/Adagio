<?xml version="1.0" encoding="ISO-8859-1"?>

<!-- $Id: Dump.xsl 932 2006-11-02 08:28:52Z abel $ -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">
  
  <xsl:output method="xml" encoding="ISO-8859-1" indent="yes"/>  

  <xsl:param name="profile.lang"/>

  <xsl:template match="*[@lang]">
    <xsl:if test="($profile.lang = '') or (@lang = $profile.lang)">
      <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="processing-instruction()">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="@*|*">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
