<?xml version="1.0" encoding="ISO-8859-1"?>

<!-- $Id: syllabus.xsl,v 3.4 2005/06/18 20:42:03 abel Exp $ -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  version="1.0">
  
  <xsl:import href="../HeadTail.xsl"/>
  <xsl:import href="Felder.xsl"/>

  <xsl:param name="toc.section.depth" select="'0'"/>
  <xsl:param name="include.toc" select="'no'"/>

  <xsl:template match="chapter">
    <h2 align="center">Test de Felder/Silverman</h2>

    <xsl:apply-templates select="qandaset"/>
  </xsl:template>

</xsl:stylesheet>

<!--  Local Variables:  -->
<!--  compile-command: "ant local.build" -->
<!--  End:  -->
