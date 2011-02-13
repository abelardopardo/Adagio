<?xml version="1.0" encoding="UTF-8"?>

<!-- $Id: TestExam.xsl 166 2005-12-13 15:04:16Z abel $ -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common" 
  xmlns="http://www.w3.org/1999/xhtml" 
  exclude-result-prefixes="exsl" version="1.0">
  
  <xsl:import
    href="file:///usr/share/sgml/docbook/stylesheet/xsl/nwalsh/xhtml/profile-docbook.xsl"/>
  <xsl:import
    href="file:///usr/share/sgml/docbook/stylesheet/xsl/nwalsh/xhtml/manifest.xsl"/>

  <!-- Figure/Section names go in lowercase -->
  <xsl:include href="es-modify.xsl"/>
  <xsl:include href="TestQuestions.xsl"/>
  <xsl:include href="solutionsection.xsl"/>
  <xsl:include href="pguidesection.xsl"/>
  <xsl:include href="submitsection.xsl"/>

  <xsl:output method="html" indent="yes" encoding="UTF-8"/>
  
  <xsl:template name="system.head.content">
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"/>
    <xsl:element name="meta">
      <xsl:attribute name="name">Author</xsl:attribute>
      <xsl:attribute name="content">
        Carlos III University of Madrid, Spain
      </xsl:attribute>
    </xsl:element>
    <title><xsl:value-of select="title"/></title>
    <style type="text/css">
      body { 
        color: black;
        background: white;
        padding: 2em 1em 2em 70px;
        font-family: sans-serif; 
        color: black; 
        background: white;
      }
      table             { page-break-inside: avoid; border-collapse: collapse; }
      hr                { height: 2px; background: black; }
      table.data        { border: 2px solid black }
      th.data           { border: 2px solid black }
      td.data           { border: 2px solid black }
      div.informaltable { text-align : center }
      tr                { page-break-inside: avoid; }
      code.code { 
        font-family: Courier New, Courier, monospace;
        font-style: normal;
        font-variant: normal;
        font-weight: normal;
      }

    </style>      
  </xsl:template>

</xsl:stylesheet>
