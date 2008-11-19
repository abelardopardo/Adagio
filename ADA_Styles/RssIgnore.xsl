<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0" exclude-result-prefixes="exsl xi">
  
  <!-- Ignore chapterinfo/sectioninfo for RSS -->
  <xsl:template match="sectioninfo[contains(@condition, 'rss.info')]/pubdate|
                       sectioninfo[contains(@condition, 'rss.info')]/abstract| 
                       sectioninfo[contains(@condition, 'rss.info')]/releaseinfo|
                      sectioninfo[contains(@condition, 'rss.info')]/author"
    mode="section.titlepage.recto.auto.mode"/>

  <xsl:template match="chapterinfo[contains(@condition, 'rss.info')]/pubdate|
                       chapterinfo[contains(@condition, 'rss.info')]/abstract|
                       chapterinfo[contains(@condition, 'dc.info')]/releaseinfo|
                       chapterinfo[contains(@condition, 'rss.info')]/author"
    mode="chapter.titlepage.recto.auto.mode"/>
  
  <xsl:template match="articleinfo[contains(@condition, 'rss.info')]/pubdate|
                       articleinfo[contains(@condition, 'rss.info')]/abstract|
                       articleinfo[contains(@condition, 'dc.info')]/releaseinfo|
                       articleinfo[contains(@condition, 'rss.info')]/author"
    mode="article.titlepage.recto.auto.mode"/>
  
</xsl:stylesheet>
