<?xml version="1.0" encoding="ISO-8859-1"?>

<!--
   Filters input HTML documents using the AdaProfile  filter.
   Imports the AdaProfile filter used for Docbook files. 
  -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">

  <!-- AdaProfile filter import -->
  <xsl:import href="AdaProfile.xsl"/>

  <xsl:output method="xml" indent="yes" encoding="UTF-8" />

  <!-- Bootstrap the filter -->
  <xsl:template match="/">
      <xsl:apply-templates select="node()" mode="profile"/>
  </xsl:template>

</xsl:stylesheet>
