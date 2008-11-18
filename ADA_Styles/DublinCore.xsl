<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:date="http://exslt.org/dates-and-times"
  version="1.0" exclude-result-prefixes="exsl xi">

  <xsl:param name="ada.dc.include.descriptors" 
    description="yes/no contolling if the Dublin Core descriptors are included
                 in the page header">no</xsl:param>

  <xsl:param name="ada.page.dc.title" 
    description="Dublin Core title descriptor (if no title element in root)" />

  <xsl:param name="ada.page.dc.description" 
    description="Dublin Core description (if no *info/releaseinfo element in root)" />

  <xsl:param name="ada.page.dc.subject" description="Dublin Core subject
                                                     descriptor" />

  <xsl:param name="ada.page.dc.format" description="Dublin Core format
                                                    descriptor (text/html default)" />

  <xsl:param name="ada.page.dc.language" description="Dublin Core language
                                                      descriptor" />

  <xsl:param name="ada.page.dc.publisher" description="Dublin Core publisher
                                                      descriptor" />

  <xsl:param name="ada.page.dc.creator"/> 

  <!-- User HEAD content -->
  <xsl:template name="user.head.content">
    <xsl:call-template name="ada.dc.insert.meta.elements"/>
  </xsl:template>

  <xsl:template name="ada.dc.insert.meta.elements">

    <xsl:if test="$ada.dc.include.descriptors = 'yes'">
      
      <!-- DC.title -->
      <xsl:choose>
        <xsl:when test="/*/title">
          <meta name="DC.title"><xsl:attribute name="content"><xsl:value-of
          select="/*/title/text()"/></xsl:attribute></meta>
        </xsl:when>
        <xsl:when test="$ada.page.dc.title != ''">
          <meta name="DC.title"><xsl:attribute name="content"><xsl:value-of
          select="$ada.page.dc.title"/></xsl:attribute></meta>
        </xsl:when>
      </xsl:choose>

      <!-- DC.description -->
      <xsl:choose>
        <xsl:when test="/*/*[contains(@condition, 'dc.info')]/releaseinfo">
          <meta name="DC.description"><xsl:attribute name="content"><xsl:value-of
          select="/*/*[contains(@condition, 'dc.info')]/releaseinfo/text()"/></xsl:attribute></meta>
        </xsl:when>
        <xsl:when test="$ada.page.dc.description != ''">
          <meta name="DC.description"><xsl:attribute name="content"><xsl:value-of
          select="$ada.page.dc.description"/></xsl:attribute></meta>
        </xsl:when>
      </xsl:choose>

      <!-- DC.date -->
      <meta name="DC.date"><xsl:attribute name="content"><xsl:value-of
      select="date:year()"/>-<xsl:value-of
      select="date:month-in-year()"/>-<xsl:value-of
      select="date:day-in-month()"/></xsl:attribute></meta>

      <!-- DC.format -->
      <xsl:choose>
        <xsl:when test="$ada.page.dc.format != ''">
          <meta name="DC.format"><xsl:attribute name="content"><xsl:value-of
          select="$ada.page.dc.format"/></xsl:attribute></meta>
        </xsl:when>
        <xsl:otherwise>
          <meta name="DC.format" content="text/html"/>
        </xsl:otherwise>
      </xsl:choose>
      
      <!-- DC.lang -->
      <xsl:variable name="dc.lang">
        <xsl:choose>
          <xsl:when test="/*/@lang"><xsl:value-of select="/*/@lang"/></xsl:when>
          <xsl:when test="$profile.lang"><xsl:value-of select="$profile.lang"/></xsl:when>
          <xsl:when test="$l10n.gentext.default.language"><xsl:value-of
          select="$l10n.gentext.default.language"/></xsl:when>
          <xsl:when test="$ada.page.dc.language != ''"><xsl:value-of
          select="$ada.page.dc.language"/></xsl:when>
        </xsl:choose>
      </xsl:variable>
      <meta name="DC.language"><xsl:attribute name="content"><xsl:value-of
      select="$dc.lang"/></xsl:attribute></meta>
      
      <!-- DC.publisher -->
      <xsl:choose>
        <xsl:when test="/*/*[contains(@condition, 'dc.info')]/publisher/publishername">
          <meta name="DC.publisher"><xsl:attribute name="content"><xsl:value-of
          select="/*/*[contains(@condition, 'dc.info')]/publisher/publishername/text()"/></xsl:attribute></meta>
        </xsl:when>
        <xsl:when test="$ada.page.dc.publisher != ''">
          <meta name="DC.publisher"><xsl:attribute name="content"><xsl:value-of
          select="$ada.page.dc.publisher"/></xsl:attribute></meta>
        </xsl:when>
      </xsl:choose>

      <!-- DC.creator -->
      <xsl:if test="/*/*[contains(@condition, 'dc.info')]/author or ($ada.page.dc.creator != '')">
        <xsl:variable name="dc.creator">
          <xsl:choose>
            <xsl:when test="/*/*[contains(@condition, 'dc.info')]/author"><xsl:value-of
            select="/*/*[contains(@condition, 'dc.info')]/author/firstname"/><xsl:text> </xsl:text><xsl:value-of
            select="/*/*[contains(@condition, 'dc.info')]/author/surname"/></xsl:when>
            <xsl:when test="$ada.page.dc.creator != ''"><xsl:value-of
            select="$ada.page.dc.creator"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <meta name="DC.creator"><xsl:attribute name="content"><xsl:value-of
        select="$dc.creator"/></xsl:attribute></meta>
      </xsl:if>

    </xsl:if>
  </xsl:template>

  <!-- 
       Templates needed to bypass redering of *info elements with the dc.info
       labels 
       -->
  <xsl:template match="chapterinfo[@condition = 'dc.info']/pubdate|
                       chapterinfo[@condition = 'dc.info']/abstract|
                       chapterinfo[@condition = 'dc.info']/releaseinfo|
                       chapterinfo[@condition = 'dc.info']/author"
    mode="chapter.titlepage.recto.auto.mode"/>

  <xsl:template match="sectioninfo[@condition = 'dc.info']/pubdate|
                       sectioninfo[@condition = 'dc.info']/abstract|
                       sectioninfo[@condition = 'dc.info']/releaseinfo|
                       sectioninfo[@condition = 'dc.info']/author"
    mode="section.titlepage.recto.auto.mode"/>

  <xsl:template match="articleinfo[@condition = 'dc.info']/pubdate|
                       articleinfo[@condition = 'dc.info']/abstract|
                       articleinfo[@condition = 'dc.info']/releaseinfo|
                       articleinfo[@condition = 'dc.info']/author"
    mode="article.titlepage.recto.auto.mode"/>

</xsl:stylesheet>
