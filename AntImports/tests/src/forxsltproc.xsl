<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="exsl" version="1.0">

  <xsl:param name="param1"/>
  <xsl:param name="param2"/>

  <xsl:output method="html" indent="yes" encoding="UTF-8"/>

  <xsl:template match="/data">
<html>
   <head>
      <title>Test page for xsltproc processing</title>
   </head>
  <body>
    <h3>Parameter values</h3>
    <ul>
      <li>Param1 = '<xsl:value-of select="$param1"/>'</li>
      <li>Param2 = '<xsl:value-of select="$param2"/>'</li>
    </ul>

    <h3>Data values</h3>
    <xsl:apply-templates/>
  </body>
</html>
  </xsl:template>

  <xsl:template match="list">
    <ol>
      <xsl:apply-templates/>
    </ol>
  </xsl:template>

  <xsl:template match="d">
    <li><xsl:value-of select="text()" /></li>
  </xsl:template>

</xsl:stylesheet>
