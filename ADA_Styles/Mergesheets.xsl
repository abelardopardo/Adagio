<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0" exclude-result-prefixes="exsl xi">

  <xsl:import href="AdaProfile.xsl" />

  <xsl:param name="mergesheets.file.to.fold" select="''"/>

  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

  <!-- Params needed by AdaProfile -->
  <xsl:param name="stylesheet.result.type" select="'xhtml'"/>
  <xsl:param name="profile.baseuri.fixup" select="false()"/>

  <xsl:param name="ada.profile.suppress.profiling.attributes">yes</xsl:param>

  <xsl:template match="xsl:stylesheet">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      
      <xsl:element name="xsl:import">
        <xsl:attribute name="href">
          <xsl:value-of select="$mergesheets.file.to.fold"/>
        </xsl:attribute>
      </xsl:element>
      
      <!-- <xsl:copy-of select="node()"/> -->
      
      <xsl:apply-templates select="node()" mode="profile"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>