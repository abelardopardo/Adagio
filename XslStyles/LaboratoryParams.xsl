<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0" exclude-result-prefixes="exsl xi str">
  
  <xsl:param name="laboratory.include.toc"             select="'yes'"/>
  <xsl:param name="laboratory.include.solutions"       select="'no'"/>
  <xsl:param name="laboratory.include.guide"           select="'no'"/>
  <xsl:param name="laboratory.toc.section.depth"       select="'3'"/>
  <xsl:param name="laboratory.pguide.background.color" select="'#CCD0D6'"/>
  <xsl:param name="laboratory.submission.page"/>
</xsl:stylesheet>
