<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0" exclude-result-prefixes="exsl xi">
  
  <!-- Customization variables for Head and Tail -->
  <xsl:param name="ada.page.author" />
  <xsl:param name="ada.page.cssstyle.url" />
  <xsl:param name="ada.page.flash.player.javascript" />
  <xsl:param name="ada.page.google.analytics.account" />
  <xsl:param name="ada.page.google.gadget.url" />
  <xsl:param name="ada.page.head.bigtitle" />
  <xsl:param name="ada.page.head.center.bottom" />
  <xsl:param name="ada.page.head.center.top.logo" />
  <xsl:param name="ada.page.head.center.top.logo.alt" />
  <xsl:param name="ada.page.head.center.top.logo.url" />
  <xsl:param name="ada.page.head.left.logo" />
  <xsl:param name="ada.page.head.left.logo.alt" />
  <xsl:param name="ada.page.head.left.logo.url" />
  <xsl:param name="ada.page.head.right.logo" />
  <xsl:param name="ada.page.head.right.logo.alt" />
  <xsl:param name="ada.page.head.right.logo.url" />
  <xsl:param name="ada.page.license" />
  <xsl:param name="ada.page.license.alt" />
  <xsl:param name="ada.page.license.institution" select="'&#169; Carlos III University of Madrid, Spain'"/>
  <xsl:param name="ada.page.license.logo" />
  <xsl:param name="ada.page.license.url" />
  <xsl:param name="ada.page.refresh.rate" />
  <xsl:param name="ada.page.show.lastmodified" select="'no'"/>
</xsl:stylesheet>
