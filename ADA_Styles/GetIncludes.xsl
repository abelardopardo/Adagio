<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:html="http://www.w3.org/1999/xhtml"
  version="1.0" exclude-result-prefixes="exsl xi str">

  <xsl:output method="text" encoding="UTF-8"/>

  <xsl:template match="/">
    <xsl:apply-templates select="//*/xi:include[@href]"/>
    <xsl:apply-templates select="document/material/include"/>
    <xsl:apply-templates select="//*/html:rss[@file]"/>
  </xsl:template>

  <xsl:template match="xi:include"><xsl:value-of
  select="@href"/><xsl:text>
</xsl:text></xsl:template>

  <!-- match dependencies in prosper driver files -->
  <xsl:template match="document/material/include"><xsl:value-of
      select="normalize-space(text())"/><xsl:text>
    </xsl:text></xsl:template>

  <!-- match dependencies in prosper driver files -->
  <xsl:template match="document/material/include"><xsl:value-of
      select="normalize-space(text())"/><xsl:text>
</xsl:text></xsl:template>

  <!-- match RSS dependencies in XHTML files -->
  <xsl:template match="html:rss"><xsl:value-of
      select="@file"/><xsl:text>
</xsl:text></xsl:template>

</xsl:stylesheet>
