<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0" exclude-result-prefixes="exsl xi">
  
  <!-- Customization variables and their default values -->
  <xsl:param name="ada.publish.dir" />
  <xsl:param name="ada.publish.host" />

  <xsl:param name="ada.institution.name">Universidad Carlos III de Madrid</xsl:param>
  <xsl:param name="ada.institution.name.en">Carlos III University of Madrid</xsl:param>

  <xsl:param name="ada.course.icon" />
  <xsl:param name="ada.course.icon.type" select="'image/x-icon'" />
  <xsl:param name="ada.course.degree" />
  <xsl:param name="ada.course.edition" />
  <xsl:param name="ada.course.home.url" />
  <xsl:param name="ada.course.image" />
  <xsl:param name="ada.course.name" select="'Your ada.course.name var goes here'" />
  <xsl:param name="ada.course.short.edition" />
  <xsl:param name="ada.course.short.name" />
  <xsl:param name="ada.course.year" />

  <xsl:param name="ada.course.home" select="'./'"/>
</xsl:stylesheet>
