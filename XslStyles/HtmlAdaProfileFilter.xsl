<?xml version="1.0" encoding="UTF-8"?>

<!--
   Filters input HTML documents using the AdaProfile  filter.
   Imports the AdaProfile filter used for Docbook files. 
  -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">

  <!-- AdaProfile filter import -->
  <xsl:import href="AdaProfile.xsl"/>

  <xsl:param name="ada.profile.suppress.profiling.attributes">yes</xsl:param>

  <xsl:output method="xml" indent="yes" encoding="UTF-8"
              doctype-public="-//W3C//DTD XHTML 1.1//EN"
              doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd" />

  <!-- Params needed by AdaProfile -->
  <xsl:param name="stylesheet.result.type" select="'xhtml'"/>
  <xsl:param name="profile.baseuri.fixup" select="false()"/>

  <!-- Bootstrap the filter -->
  <xsl:template match="/">
      <xsl:apply-templates select="node()" mode="profile"/>
  </xsl:template>

</xsl:stylesheet>
