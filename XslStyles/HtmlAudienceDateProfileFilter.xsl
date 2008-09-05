<?xml version="1.0" encoding="ISO-8859-1"?>

<!--
   Filters input HTML documents using the AudienceDateProfile filter.
   Imports the AudienceDateProfile filter used for Docbook files. 
  -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">

  <!-- Docbook imports -->
  <xsl:import 
     href="http://docbook.sourceforge.net/release/xsl/current/xhtml/profile-docbook.xsl"/>
  <xsl:import href="http://docbook.sourceforge.net/release/xsl/current/profiling/profile-mode.xsl"/>

  <!-- AudienceDateProfile filter import -->
  <xsl:import href="AudienceDateProfile.xsl"/>

  <xsl:output method="xml" indent="yes" encoding="UTF-8" />

  <!-- Bootstrap the filter -->
  <xsl:template match="/">
      <xsl:apply-templates select="node()" mode="profile"/>
  </xsl:template>

</xsl:stylesheet>
