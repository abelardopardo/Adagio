<?xml version="1.0" encoding="UTF-8"?>

<!--
  Copyright (C) 2008 Carlos III University of Madrid
  This file is part of the ADA: Agile Distributed Authoring Toolkit

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

  <!-- Obtain genearl ada variables -->
  <xsl:import href="GeneralParams.xsl"/>

  <xsl:param name="ada.rss.time.to.live">30</xsl:param>
  <xsl:param name="ada.rss.title">Rss title goes here</xsl:param>
  <xsl:param name="ada.rss.description">Descripción del canal</xsl:param>

  <!-- Parameter to put in links to the main site documentation -->
  <xsl:param name="ada.rss.main.site.url">http://bogus.net</xsl:param>

  <!-- Name of the file containing the feed (no prefix) -->
  <xsl:param name="ada.rss.filename"/>

  <!-- URL pointing to the XML file containing the feed -->
  <xsl:param name="ada.rss.channel.url"><xsl:value-of
  select="$ada.rss.filename"/></xsl:param>

  <!-- Prefix of the type http://......./a/b/c to use for material links -->
  <xsl:param name="ada.rss.item.url.prefix">Your prefix goes here</xsl:param>

  <xsl:param name="ada.rss.language">en</xsl:param>
  <xsl:param name="ada.rss.copyright">Copyright goes here</xsl:param>
  <xsl:param name="ada.rss.author.email">author@bogus.net (Author name)</xsl:param>    
  <xsl:param name="ada.rss.author.name">Author name goes here</xsl:param>
  <xsl:param name="ada.rss.subtitle">Rss subtitle goes here</xsl:param>
  <xsl:param name="ada.rss.summary">Rss summary goes here</xsl:param>
  <xsl:param name="ada.rss.explicit">No</xsl:param>
  <xsl:param name="ada.rss.image.url">http://image.net/bogusimage.png</xsl:param>
  <xsl:param name="ada.rss.image.desc"></xsl:param>
  <xsl:param name="ada.rss.image.width">88</xsl:param>
  <xsl:param name="ada.rss.image.height">88</xsl:param>
  <xsl:param name="ada.rss.category">Education</xsl:param>
  <xsl:param name="ada.rss.subcategory">Higher Education</xsl:param>
  <xsl:param name="ada.rss.max.items">10</xsl:param>
  <xsl:param name="ada.rss.check.pubdate">0</xsl:param>
  <xsl:param name="ada.rss.force.date"></xsl:param>
  <xsl:param name="ada.rss.date.rfc822"></xsl:param>
  <xsl:param name="ada.rss.self.atom.link"><xsl:value-of
  select="$ada.rss.channel.url"/></xsl:param>
  <xsl:param name="ada.rss.numitems.max">1000000</xsl:param>
  <xsl:param name="ada.rss.autolink">false</xsl:param>
  <xsl:param name="ada.rss.autoguid">false</xsl:param>

  <xsl:param name="ada.rss.debug"/>
</xsl:stylesheet>
