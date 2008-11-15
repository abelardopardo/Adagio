<?xml version="1.0" encoding="UTF-8"?>

<!-- $Id: Dump.xsl 932 2006-11-02 08:28:52Z abel $ -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">
  
  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>  
  
  <!-- 
       Stylesheet to simply dump the input file. It is used to allow the
       processor to expand all the xinclude elements 
  -->

  <xsl:param name="profile.lang"/>

  <!-- Allow some basic language profiling -->
  <xsl:template match="*[@lang]">
    <xsl:if test="($profile.lang = '') or (@lang = $profile.lang)">
      <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <!-- Dump processing instruction -->
  <xsl:template match="processing-instruction()">
    <xsl:copy/>
  </xsl:template>

  <!-- Dump all elements and attributes -->
  <xsl:template match="@*|*">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
