<?xml version="1.0" encoding="UTF-8"?>

<!--
  Copyright (C) 2008 Carlos III University of Madrid
  This file is part of the Adagio: Agile Distributed Authoring Toolkit

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
  version="1.0" exclude-result-prefixes="exsl xi">

  <!-- Ignore chapterinfo/sectioninfo for RSS -->
  <xsl:template match="sectioninfo[contains(@condition, 'rss.info')]/pubdate|
                       sectioninfo[contains(@condition, 'rss.info')]/abstract|
                      sectioninfo[contains(@condition, 'rss.info')]/authorgroup|
                      sectioninfo[contains(@condition, 'rss.info')]/author"
    mode="section.titlepage.recto.auto.mode"/>

  <xsl:template match="chapterinfo[contains(@condition, 'rss.info')]/pubdate|
                       chapterinfo[contains(@condition, 'rss.info')]/abstract|
                       chapterinfo[contains(@condition, 'rss.info')]/authorgroup|
                       chapterinfo[contains(@condition, 'rss.info')]/author"
    mode="chapter.titlepage.recto.auto.mode"/>

  <xsl:template match="articleinfo[contains(@condition, 'rss.info')]/pubdate|
                       articleinfo[contains(@condition, 'rss.info')]/abstract|
                       articleinfo[contains(@condition, 'rss.info')]/authorgroup|
                       articleinfo[contains(@condition, 'rss.info')]/author"
    mode="article.titlepage.recto.auto.mode"/>

</xsl:stylesheet>
