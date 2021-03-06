<?xml version="1.0" encoding="UTF-8"?>

<!--
  Copyright (C) 2008 Carlos III University of Madrid
  This file is part of Adagio: Agile Distributed Authoring Integrated Toolkit

  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License
  as published by the Free Software Foundation; either version 2
  of the License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor
  Boston, MA  02110-1301, USA.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:date="http://exslt.org/dates-and-times"
  version="1.0" exclude-result-prefixes="exsl xi">

  <xsl:param name="adagio.dc.include.descriptors"
    description="yes/no contolling if the Dublin Core descriptors are included
                 in the page header">no</xsl:param>

  <xsl:param name="adagio.dc.title"
    description="Dublin Core title descriptor (if no title element in root)" />

  <xsl:param name="adagio.dc.description"
    description="Dublin Core description (if no *info/abstract element in root)" />

  <xsl:param name="adagio.dc.subject" description="Dublin Core subject
                                                     descriptor" />

  <xsl:param name="adagio.dc.format" description="Dublin Core format
                                                    descriptor (text/html default)" />

  <xsl:param name="adagio.dc.language" description="Dublin Core language
                                                      descriptor" />

  <xsl:param name="adagio.dc.publisher" description="Dublin Core publisher
                                                      descriptor" />

  <xsl:param name="adagio.dc.creator"/>

  <!-- User HEAD content -->
  <xsl:template name="user.head.content">
    <xsl:call-template name="adagio.dc.insert.meta.elements"/>
  </xsl:template>

  <xsl:template name="adagio.dc.insert.meta.elements">

    <xsl:if test="$adagio.dc.include.descriptors = 'yes'">

      <!-- DC.title -->
      <xsl:variable name="dc.title">
        <xsl:choose>
          <xsl:when test="/*/title">
            <xsl:apply-templates select="/*/title/node()"/>
          </xsl:when>
          <xsl:when test="$adagio.dc.title and ($adagio.dc.title != '')"><xsl:value-of
          select="$adgioa.dc.title"/></xsl:when>
        </xsl:choose>
      </xsl:variable>
      <meta name="DC.title"><xsl:attribute name="content"><xsl:value-of
          select="normalize-space(string($dc.title))"/></xsl:attribute></meta>

      <!-- DC.description -->
      <xsl:variable name="dc.description">
        <xsl:choose>
          <xsl:when test="/*/*[contains(@condition, 'dc.info')]/abstract/*[name() != 'title']">
            <xsl:apply-templates select="/*/*[contains(@condition, 'dc.info')]/abstract/*[name() != 'title']"/>
          </xsl:when>
          <xsl:when test="$adagio.dc.description != ''">
            <meta name="DC.description"><xsl:attribute name="content"><xsl:value-of
            select="$adagio.dc.description"/></xsl:attribute></meta>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>
      <meta name="DC.description"><xsl:attribute name="content"><xsl:value-of
      select="normalize-space(string($dc.description))"/></xsl:attribute></meta>

      <!-- DC.date -->
      <meta name="DC.date"><xsl:attribute name="content"><xsl:value-of
      select="date:year()"/>-<xsl:value-of
      select="date:month-in-year()"/>-<xsl:value-of
      select="date:day-in-month()"/></xsl:attribute></meta>

      <!-- DC.format -->
      <xsl:choose>
        <xsl:when test="$adagio.dc.format != ''">
          <meta name="DC.format"><xsl:attribute name="content"><xsl:value-of
          select="$adagio.dc.format"/></xsl:attribute></meta>
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
          <xsl:when test="$adagio.dc.language != ''"><xsl:value-of
          select="$adagio.dc.language"/></xsl:when>
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
        <xsl:when test="$adagio.dc.publisher != ''">
          <meta name="DC.publisher"><xsl:attribute name="content"><xsl:value-of
          select="$adagio.dc.publisher"/></xsl:attribute></meta>
        </xsl:when>
      </xsl:choose>

      <!-- DC.creator -->
      <xsl:variable name="dc.creator">
        <xsl:choose>
          <xsl:when test="/*/*[contains(@condition, 'dc.info')]/author">
            <xsl:apply-templates select="/*/*[contains(@condition,
                                         'dc.info')]/author"/>
          </xsl:when>
          <xsl:when test="$adagio.dc.creator">
            <xsl:value-of select="$adagio.dc.creator"/>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>
      <xsl:if test="$dc.creator and ($dc.creator != '')">
        <meta name="DC.creator"><xsl:attribute name="content"><xsl:value-of
        select="normalize-space(string($dc.creator))"/></xsl:attribute></meta>
      </xsl:if>

    </xsl:if>
  </xsl:template>

  <!--
       Templates needed to bypass redering of *info elements with the dc.info
       labels
       -->
  <xsl:template match="chapterinfo[contains(@condition, 'dc.info')]/pubdate|
                       chapterinfo[contains(@condition, 'dc.info')]/abstract|
                       chapterinfo[contains(@condition, 'dc.info')]/author"
    mode="chapter.titlepage.recto.auto.mode"/>

  <xsl:template match="sectioninfo[contains(@condition, 'dc.info')]/pubdate|
                       sectioninfo[contains(@condition, 'dc.info')]/abstract|
                       sectioninfo[contains(@condition, 'dc.info')]/author"
    mode="section.titlepage.recto.auto.mode"/>

  <xsl:template match="articleinfo[contains(@condition, 'dc.info')]/pubdate|
                       articleinfo[contains(@condition, 'dc.info')]/abstract|
                       articleinfo[contains(@condition, 'dc.info')]/author"
    mode="article.titlepage.recto.auto.mode"/>

</xsl:stylesheet>
