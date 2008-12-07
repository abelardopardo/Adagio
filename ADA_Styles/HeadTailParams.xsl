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
  
  <xsl:import href="GeneralParams.xsl"/>

  <!-- Customization variables for Head and Tail -->
  <xsl:param name="ada.page.author" 
    description="Author to include in the meta element in HTML head"/>

  <xsl:param name="ada.page.cssstyle.url" 
    description="Comma separated list of CSS files to include in the HTML
    head. Use file:media to specify media attribute"/>

  <xsl:param name="ada.page.google.analytics.account" 
    description="Account to include in the Google Analytics HTML snippet."/>
  <xsl:param name="ada.page.google.gadget.url" 
    description="Link pointing to a Google Gadget to be included in the upper
                 left corner of the page"/>

  <!--
       <xsl:param name="ada.page.head.bigtitle" 
    description="yes/no to enable a big title on top of the page">no</xsl:param>
  <xsl:param name="ada.page.head.center.bottom" 
    description="Text to insert at the bottom row of the Header table"/>
  <xsl:param name="ada.page.head.center.top.logo" 
    description="URL to the image to show in the top center of the table
                 header"/>
  <xsl:param name="ada.page.head.center.top.logo.alt" 
    description="Alt attribute for the previous image"/>
  <xsl:param name="ada.page.head.center.top.logo.url" 
    description="URL to make the image a link"/>
  <xsl:param name="ada.page.head.left.logo"
    description="URL to the image to show in the left side of the table header"/>
  <xsl:param name="ada.page.head.left.logo.alt" 
    description="Alt attribute for the previous image"/>
  <xsl:param name="ada.page.head.left.logo.url"
    description="URL to make the image a link"/>
  <xsl:param name="ada.page.head.right.logo"
    description="URL to the image to show in the right side of the table header"/>
  <xsl:param name="ada.page.head.right.logo.alt" 
    description="Alt attribute for the previous image"/>
  <xsl:param name="ada.page.head.right.logo.url" 
    description="URL to make the image a link"/> 
  -->

  <xsl:param name="ada.page.refresh.rate" 
    description="Include a refresh rate in the page header"/>

  <!-- 
  <xsl:param name="ada.page.license.institution" select="'&#169; Carlos III University of Madrid, Spain'"/>
  <xsl:param name="ada.page.license" 
    description="Yes/no to include license information at the bottom of the
                 page">no</xsl:param>
  <xsl:param name="ada.page.license.name"
    description="Name of the license"/>
  <xsl:param name="ada.page.license.logo"
    description="URL to an image to accompany the license information"/>
  <xsl:param name="ada.page.license.alt" 
    description="Alt attribute for the previous image"/>
  <xsl:param name="ada.page.license.url" 
    description="URL to point when clicking in the license image"/>
  <xsl:param name="ada.page.show.lastmodified" 
    description="yes/no controlling if the last modified info is shown at
                 bottom">no</xsl:param>
  -->
  
  <xsl:param name="ada.page.header.level1">
    <xsl:if test="$ada.institution.name and $ada.institution.name != ''">
      <h1 id="ada_institution_name">
        <xsl:choose>
          <xsl:when test="$ada.institution.url and $ada.institution.url != ''">
            <a>
              <xsl:attribute name="href"><xsl:value-of
              select="$ada.institution.url"/></xsl:attribute>
              <xsl:attribute name="title"><xsl:value-of
              select="$ada.institution.name"/></xsl:attribute>
              <xsl:value-of select="$ada.institution.name"/>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$ada.institution.name"/>
          </xsl:otherwise>
        </xsl:choose>
      </h1>
    </xsl:if>
  </xsl:param>

  <xsl:param name="ada.page.header.level2">
    <xsl:if test="$ada.course.degree and $ada.course.degree != ''">
      <h2 id="ada_degree_name">
        <xsl:choose>
          <xsl:when test="$ada.course.degree.url and $ada.course.degree.url != ''">
            <a>
              <xsl:attribute name="href"><xsl:value-of
              select="$ada.course.degree.url"/></xsl:attribute>
              <xsl:attribute name="title"><xsl:value-of
              select="$ada.course.degree"/></xsl:attribute>
              <xsl:value-of select="$ada.course.degree"/>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$ada.course.degree"/>
          </xsl:otherwise>
        </xsl:choose>
      </h2>
    </xsl:if>
  </xsl:param>

  <xsl:param name="ada.page.header.level3">
    <xsl:if test="$ada.course.name and $ada.course.name != ''">
      <h3 id="ada_course_name">
        <xsl:choose>
          <xsl:when test="$ada.course.home.url and $ada.course.home.url != ''">
            <a>
              <xsl:attribute name="href"><xsl:value-of
              select="$ada.course.home.url"/></xsl:attribute>
              <xsl:attribute name="title"><xsl:value-of
              select="$ada.course.name"/></xsl:attribute>
              <xsl:value-of select="$ada.course.name"/>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$ada.course.name"/>
          </xsl:otherwise>
        </xsl:choose>
      </h3>
    </xsl:if>
  </xsl:param>

  <xsl:param name="ada.page.header.level4">
    <xsl:if test="$ada.course.edition and $ada.course.edition != ''">
      <h4 id="ada_course_edition">
        <xsl:choose>
          <xsl:when test="$ada.course.edition.url and $ada.course.edition.url != ''">
            <a>
              <xsl:attribute name="href"><xsl:value-of
              select="$ada.course.edition.url"/></xsl:attribute>
              <xsl:attribute name="title"><xsl:value-of
              select="$ada.course.edition.name"/></xsl:attribute>
              <xsl:value-of select="$ada.course.edition"/>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$ada.course.edition"/>
          </xsl:otherwise>
        </xsl:choose>
      </h4>
    </xsl:if>
  </xsl:param>

  <xsl:param name="ada.page.navigation"
    description="HTML with navigation links" />

  <xsl:param name="ada.page.footer"
    description="Footer HTML snippet" />

  <xsl:param name="ada.page.navigation.navigation.accesskey"
    description="Access key to assign to the skip to navigation link">3</xsl:param>

  <xsl:param name="ada.page.navigation.content.accesskey"
    description="Access key to assign to the skip to content link">2</xsl:param>

</xsl:stylesheet>
