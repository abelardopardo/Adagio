<?xml version="1.0" encoding="ISO-8859-1"?>

<!-- $Id: TestExam.xsl 334 2006-01-25 09:44:13Z abel $ -->

<!--
     Taken from inline.xsl in docbook xsl stylesheets version 1.69.1
     and modified to suppress a span element produced surrounding the text 
     when processing a quote element.
    
     Source:

     <quote>X</quote>

     Obtained HTML without including this file:

     &#8221;<span class="quote">X</span>&#8221;

     Obtained HTML including this file:

     &#8221;X&#8221;

     The reason for the change is because, even though mozilla renders
     this combination perfectly, when printing to postscript, it
     renders it incorrectly inserting a space between the opening
     quote and the text inside the quote element.

     The price to pay is that since the span element is not included,
     any CSS stylesheet that relies on that to typeset quote elements
     has no longer any effect.
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common" 
  xmlns="http://www.w3.org/1999/xhtml" 
  exclude-result-prefixes="exsl" version="1.0">
  
  <xsl:template name="inline.charseq">
    <xsl:param name="content">
      <xsl:call-template name="anchor"/>
      <xsl:call-template name="simple.xlink">
        <xsl:with-param name="content">
          <xsl:apply-templates/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:param>

    <xsl:choose>
      <xsl:when test="name() = 'quote'">
        <xsl:call-template name="generate.html.title"/>
        <xsl:if test="@dir">
          <xsl:attribute name="dir">
            <xsl:value-of select="@dir"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:copy-of select="$content"/>
        <xsl:call-template name="apply-annotations"/>
      </xsl:when>
      <xsl:otherwise>
        <span class="{local-name(.)}">
          <xsl:call-template name="generate.html.title"/>
          <xsl:if test="@dir">
            <xsl:attribute name="dir">
              <xsl:value-of select="@dir"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:copy-of select="$content"/>
          <xsl:call-template name="apply-annotations"/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
