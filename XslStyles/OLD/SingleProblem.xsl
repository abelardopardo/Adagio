<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  version="1.0" exclude-result-prefixes="exsl">
  
  <!-- ==================================================================== -->
  
  <xsl:import  href="file:///usr/share/sgml/docbook/stylesheet/xsl/nwalsh/html/profile-docbook.xsl"/>
  <xsl:include href="file:///usr/share/sgml/docbook/stylesheet/xsl/nwalsh/html/manifest.xsl"/>
  <xsl:include href="es-modify.xsl"/>

  <xsl:include href="submitsection.xsl"/>
  <xsl:include href="solutionsection.xsl"/>
  <xsl:include href="pguidesection.xsl"/>

  <xsl:output method="html" indent="yes" encoding="ISO-8859-1"/>

  <xsl:param name="xref.with.number.and.title" select="'0'"/>
  <xsl:param name="include.toc"                select="'yes'"/>
  <xsl:param name="include.solutions"          select="'no'"/>
  <xsl:param name="include.guide"              select="'no'"/>

  <xsl:param name="author" select="'Carlos III University of Madrid'"/>
  <xsl:param name="rootPrefix" select="'.'"/>

  <xsl:variable name="lang">
    <xsl:choose>
      <xsl:when test="/descendant::*/@lang">
        <xsl:value-of select="/descendant::*/@lang"/>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="'es'"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="given.title" select="/section/title/text()"/>

  <!-- Background color for the professor guide box  --> 
  <xsl:variable name="pguidebgn" select="'#CCD0D6'"/>

  <xsl:param name="toc.section.depth" select="'1'"/>
  <xsl:param name="generate.toc" select="'section/section toc'"/>
  <xsl:param name="generate.section.toc.level" select="'2'"/>
  <xsl:param name="xref.with.number.and.title" select="'0'"/>

  <xsl:template name="body.attributes">
    <xsl:attribute name="bgcolor">#FFFFFF</xsl:attribute>
    <xsl:attribute name="text">#000000</xsl:attribute>
    <xsl:attribute name="marginwidth">0</xsl:attribute>
    <xsl:attribute name="marginheight">1</xsl:attribute>
    <xsl:attribute name="topMargin">1</xsl:attribute>
    <xsl:attribute name="leftMargin">0</xsl:attribute>
    <xsl:attribute name="rightMargin">0</xsl:attribute>
  </xsl:template>

  <xsl:template name="user.head.content">
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"/>
    <xsl:element name="meta">
      <xsl:attribute name="name">Author</xsl:attribute>
      <xsl:attribute name="content">
        <xsl:value-of select="$author"/>
      </xsl:attribute>
    </xsl:element>
    <meta http-equiv="Content-Style-Type" content="text/css"/>
    <style type="text/css">
      table       { page-break-inside: avoid; 
                    border-collapse: collapse; 
                    margin-right: auto; 
                    margin-left: auto; 
                  }
      hr          { height: 2px; background: black; }
      table.data  { border: 2px solid black }
      th.data     { border: 2px solid black }
      td.data     { border: 2px solid black }
      tr.cabecera { background-color: #BBC7FB; }
      tr.clase    { background-color: rgb(240,240,240); }
      tr.festivo  { background-color: rgb(240,240,240); color: red; }
      td.msg      { color: red; }
      td.grey     { background-color: #C0C0C0}
      body        { background-color: #FFFFFF; }
    </style>
  </xsl:template>
  
  <xsl:template match="section">
    <xsl:if test="title/text() != ''">
      <h2 align="center"><xsl:copy-of select="title/node()"/></h2>
    </xsl:if>

    <xsl:if test="$include.toc = 'yes'">
      <table style="border:0" cellspacing="0" cellpadding="2" align="center">
        <tr><td><xsl:call-template name="section.toc"/></td></tr>
      </table>
    </xsl:if>

    <table width="95%" style="border:0" cellspacing="0" cellpadding="2" 
      align="center">
      <tr><td><xsl:apply-templates/></td></tr>
    </table>
  </xsl:template>
  
</xsl:stylesheet>
