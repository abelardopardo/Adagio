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
  xmlns:str="http://exslt.org/strings"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0" exclude-result-prefixes="exsl str xi">

  <xsl:param name="ada.page.cssstyle.url"
    description="Comma separated list of CSS files to include in the HTML
    head. Use file:media:title to specify media and title attribute"/>

  <xsl:param name="ada.page.cssstyle.alternate.url"
    description="Comma separated list of alternate CSS files to include in the HTML
    head. Use file:media:title to specify media and title attribute"/>

  <!-- Template to generate the CSS stylesheet links -->
  <xsl:template name="ada_link_rel_css">
    <xsl:param name="node" select="."/>
    <xsl:param name="rel"  select="'stylesheet'"/>
    <xsl:if test="$node">
      <xsl:for-each select="str:tokenize($node, ',')">
        <xsl:variable name="tuple_url_attributes">
          <tokens xmlns="">
            <xsl:copy-of select="str:tokenize(., ':')"/>
          </tokens>
        </xsl:variable>

        <xsl:variable name="css_url_value">
          <xsl:value-of
            select="normalize-space(exsl:node-set($tuple_url_attributes)/tokens/token[position() = 1])"/>
        </xsl:variable>

        <xsl:variable name="media_attribute_value">
          <xsl:choose>
            <xsl:when
              test="exsl:node-set($tuple_url_attributes)/tokens/token[position() = 2]">
              <xsl:value-of
                select="exsl:node-set($tuple_url_attributes)/tokens/token[position() = 2]"/>
            </xsl:when>
            <xsl:otherwise>all</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="title_attribute_value">
          <xsl:choose>
            <xsl:when
              test="exsl:node-set($tuple_url_attributes)/tokens/token[position() = 3]">
              <xsl:value-of
                select="exsl:node-set($tuple_url_attributes)/tokens/token[position() = 3]"/>
            </xsl:when>
            <xsl:otherwise />
          </xsl:choose>
        </xsl:variable>

        <link type="text/css">
          <xsl:attribute name="rel"><xsl:value-of
          select="$rel"/></xsl:attribute>
          <xsl:attribute name="href"><xsl:if
          test="not(starts-with($css_url_value, './'))"><xsl:value-of
          select="$ada.project.home"/></xsl:if><xsl:value-of
          select="$css_url_value"/></xsl:attribute>
          <xsl:attribute name="media"><xsl:value-of
          select="$media_attribute_value"/></xsl:attribute>
          <xsl:if test="$title_attribute_value and $title_attribute_value != ''">
            <xsl:attribute name="title"><xsl:value-of
            select="$title_attribute_value"/></xsl:attribute>
          </xsl:if>
        </link>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
