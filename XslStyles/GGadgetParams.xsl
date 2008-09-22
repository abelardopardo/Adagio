<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0" exclude-result-prefixes="exsl xi">

  <!-- Obtain other generic ada variables  -->
  <xsl:import href="GeneralParams.xsl"/>
  <xsl:import href="HeadTailParams.xsl"/>

  <xsl:param name="ada.ggadget.title"><xsl:value-of
  select="$ada.course.name"/></xsl:param>

  <xsl:param name="ada.ggadget.thumb.url"/>
  <xsl:param name="ada.ggadget.height"/>
  <xsl:param name="ada.ggadget.screenshot.url"/>
  <xsl:param name="ada.ggadget.author"/> <!-- Not used! Check why -->
  <xsl:param name="ada.ggadget.google.analytics.gadgetpath"/>
</xsl:stylesheet>
