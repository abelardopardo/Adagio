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
  version="1.0" exclude-result-prefixes="exsl xi">

  <xsl:import href="GeneralParams.xsl"/>

  <!-- Customization variables for Head and Tail -->
  <xsl:param name="adagio.page.author"
    description="Author to include in the meta element in HTML head"/>

  <xsl:param name="adagio.page.google.analytics.account"
    description="Account to include in the Google Analytics HTML snippet."/>
  <xsl:param name="adagio.page.google.gadget.url"
    description="Link pointing to a Google Gadget to be included in the upper
                 left corner of the page"/>

  <xsl:param name="adagio.head.javascripts"
	     description="Javascripts to include in the document head"/>

  <xsl:param name="adagio.page.refresh.rate"
    description="Include a refresh rate in the page header"/>

  <xsl:param name="adagio.page.header.level1">
    <xsl:if test="$adagio.institution.name and $adagio.institution.name != ''">
      <h1 id="adagio_institution_name">
        <xsl:choose>
          <xsl:when test="$adagio.institution.url and $adagio.institution.url != ''">
            <a>
              <xsl:attribute name="href"><xsl:value-of
              select="$adagio.institution.url"/></xsl:attribute>
              <xsl:attribute name="title"><xsl:value-of
              select="$adagio.institution.name"/></xsl:attribute>
              <xsl:value-of select="$adagio.institution.name"/>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$adagio.institution.name"/>
          </xsl:otherwise>
        </xsl:choose>
      </h1>
    </xsl:if>
  </xsl:param>

  <xsl:param name="adagio.page.header.level2">
    <xsl:if test="$adagio.project.degree and $adagio.project.degree != ''">
      <h2 id="adagio_degree_name">
        <xsl:choose>
          <xsl:when test="$adagio.project.degree.url and $adagio.project.degree.url != ''">
            <a>
              <xsl:attribute name="href"><xsl:value-of
              select="$adagio.project.degree.url"/></xsl:attribute>
              <xsl:attribute name="title"><xsl:value-of
              select="$adagio.project.degree"/></xsl:attribute>
              <xsl:value-of select="$adagio.project.degree"/>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$adagio.project.degree"/>
          </xsl:otherwise>
        </xsl:choose>
      </h2>
    </xsl:if>
  </xsl:param>

  <xsl:param name="adagio.page.header.level3">
    <xsl:if test="$adagio.project.name and $adagio.project.name != ''">
      <h3 id="adagio_course_name">
        <xsl:choose>
          <xsl:when test="$adagio.project.home.url and $adagio.project.home.url != ''">
            <a>
              <xsl:attribute name="href"><xsl:value-of
              select="$adagio.project.home.url"/></xsl:attribute>
              <xsl:attribute name="title"><xsl:value-of
              select="$adagio.project.name"/></xsl:attribute>
              <xsl:value-of select="$adagio.project.name"/>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$adagio.project.name"/>
          </xsl:otherwise>
        </xsl:choose>
      </h3>
    </xsl:if>
  </xsl:param>

  <xsl:param name="adagio.page.header.level4">
    <xsl:if test="$adagio.project.edition and $adagio.project.edition != ''">
      <h4 id="adagio_course_edition">
        <xsl:choose>
          <xsl:when test="$adagio.project.edition.url and $adagio.project.edition.url != ''">
            <a>
              <xsl:attribute name="href"><xsl:value-of
              select="$adagio.project.edition.url"/></xsl:attribute>
              <xsl:attribute name="title"><xsl:value-of
              select="$adagio.project.edition.name"/></xsl:attribute>
              <xsl:value-of select="$adagio.project.edition"/>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$adagio.project.edition"/>
          </xsl:otherwise>
        </xsl:choose>
      </h4>
    </xsl:if>
  </xsl:param>

  <xsl:param name="adagio.page.navigation"
    description="HTML with navigation links" />

  <xsl:param name="adagio.page.footer"
    description="Footer HTML snippet" />

  <xsl:param name="adagio.page.navigation.home.accesskey"
    description="Access key to go to the home page">1</xsl:param>

  <xsl:param name="adagio.page.navigation.content.accesskey"
    description="Access key to assign to the skip to content link">2</xsl:param>

  <xsl:param name="adagio.page.navigation.navigation.accesskey"
    description="Access key to assign to the skip to navigation link">3</xsl:param>

</xsl:stylesheet>
