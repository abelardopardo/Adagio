<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0" exclude-result-prefixes="exsl xi str">
  
  <xsl:param name="exercisesubmit.include.toc" 
    description="Yes/no variable to include a TOC a the top of the page">yes</xsl:param>
  <xsl:param name="exercisesubmit.submission.page.url"
    description="URL to the submission page (if not given, taken from the XML)"/>

  <!-- Docbook parameter to restrict the levels in the TOC -->
  <xsl:param name="toc.section.depth" select="'3'"/>
</xsl:stylesheet>
