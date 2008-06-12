<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0" exclude-result-prefixes="exsl xi">
  
  <!-- Ignore chapterinfo/sectioninfo for RSS -->
  <xsl:template match="sectioninfo[@condition = 'rss.info']/pubdate|
                       sectioninfo[@condition = 'rss.info']/abstract|
                       sectioninfo[@condition = 'rss.info']/author"
    mode="section.titlepage.recto.auto.mode"/>
  <xsl:template match="chapterinfo[@condition = 'rss.info']/pubdate|
                       chapterinfo[@condition = 'rss.info']/abstract|
                       chapterinfo[@condition = 'rss.info']/author"
    mode="chapter.titlepage.recto.auto.mode"/>
  
</xsl:stylesheet>
