<?xml version="1.0" encoding="ISO-8859-1"?>

<!-- $Id: ttaotofo2.xsl,v 1.3 2005/07/06 08:57:15 abel Exp $ -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml" 
  exclude-result-prefixes="http" version="1.0">

  <xsl:include href="file:///usr/share/sgml/docbook/stylesheet/xsl/nwalsh/xhtml/docbook.xsl"/>

  <xsl:output method="xml" indent="yes" encoding="ISO-8859-1"/>
  
  <xsl:template match="/">
    <test>
      <xsl:attribute name="exam"><xsl:value-of select="test/@exam"/></xsl:attribute>
      <xsl:attribute name="duration"><xsl:value-of
      select="test/@duration"/></xsl:attribute>
      <xsl:attribute name="date"><xsl:value-of
      select="test/@date"/></xsl:attribute>

      <xsl:for-each select="section/qandaset/qandadiv[@condition='TestMCQuestion']">
        <question>
          <qt>
            <xsl:apply-templates />
          </qt>
          <xsl:for-each select="descendant::answer">
            <answer>
              <xsl:choose>
                <xsl:when test="contains(@condition, 'Cierto') or
                                contains(@condition, 'Verdadero') or
                                contains(@condition, 'Correct') or
                                contains(@condition, 'True')">
                  <xsl:attribute name="correct">yes</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:attribute name="correct">no</xsl:attribute>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:apply-templates/>
            </answer>
          </xsl:for-each>
        </question>
      </xsl:for-each>
    </test>
  </xsl:template>
  
  <xsl:template match="question">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="answer"/>
</xsl:stylesheet>
