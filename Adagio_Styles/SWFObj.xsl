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
  xmlns:exsl="http://exslt.org/common"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="exsl" version="1.0">

  <!--
       Variables needed to control the display of the video. Only some of all
       the possible ones were selected.

       file -> gets put into src
       height
       width
       id (optional)
    -->

  <xsl:param name="adagio.swf.player.default.width">480</xsl:param>
  <xsl:param name="adagio.swf.player.default.height">385</xsl:param>

  <xsl:template match="para[@condition = 'adagio_swf_player']|
                       remark[@condition = 'adagio_swf_player']">
    <xsl:if test="phrase[@condition = 'file'] != ''">
      <xsl:variable name="shockwave.width">
        <xsl:choose>
          <xsl:when test="phrase[@condition = 'width'] != ''">
            <xsl:value-of select="phrase[@condition = 'width']/text()"/>
          </xsl:when>
          <xsl:otherwise><xsl:value-of
          select="$adagio.swf.player.default.width"/></xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="shockwave.height">
        <xsl:choose>
          <xsl:when test="phrase[@condition = 'height'] != ''">
            <xsl:value-of select="phrase[@condition = 'height']/text()"/>
          </xsl:when>
          <xsl:otherwise><xsl:value-of
          select="$adagio.swf.player.default.height"/></xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <div class="adagio_swf_video">
        <!-- Pass the @id attribute to the div enclosing the swf -->
        <xsl:if test="@id">
          <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
        </xsl:if>
        <object>
          <xsl:attribute name="height"><xsl:value-of
          select="$shockwave.height"/></xsl:attribute>
          <xsl:attribute name="width"><xsl:value-of
          select="$shockwave.width"/></xsl:attribute>
          <param name="movie">
            <xsl:attribute name="value"><xsl:value-of
            select="phrase[@condition = 'file']/text()"/></xsl:attribute>
          </param>
	  <xsl:if test="phrase[@condition = 'allowFullScreen']">
	    <param><xsl:attribute name="name">allowFullScreen</xsl:attribute>
	    <xsl:attribute name="value"><xsl:value-of select="phrase[@condition
	    = 'allowFullScreen']/text()"/></xsl:attribute></param>
	  </xsl:if>
	  <xsl:if test="phrase[@condition = 'allowscriptaccess']">
	    <param><xsl:attribute name="name">allowscriptaccess</xsl:attribute>
	    <xsl:attribute name="value"><xsl:value-of select="phrase[@condition
	    = 'allowscriptaccess']/text()"/></xsl:attribute></param>
	  </xsl:if>
          <embed type="application/x-shockwave-flash">
            <xsl:attribute name="src"><xsl:value-of
            select="phrase[@condition = 'file']/text()"/></xsl:attribute>
            <xsl:attribute name="height"><xsl:value-of
            select="$shockwave.height"/></xsl:attribute>
            <xsl:attribute name="width"><xsl:value-of
            select="$shockwave.width"/></xsl:attribute>
	    <xsl:if test="phrase[@condition = 'allowFullScreen']">
	      <xsl:attribute name="allowfullscreen"><xsl:value-of
	      select="phrase[@condition = 'allowFullScreen']/text()"/></xsl:attribute>
	  </xsl:if>
	  <xsl:if test="phrase[@condition = 'allowscriptaccess']">
	    <xsl:attribute name="allowscriptaccess"><xsl:value-of select="phrase[@condition
	    = 'allowscriptaccess']/text()"/></xsl:attribute>
	  </xsl:if>
          </embed>
        </object>

        <!-- Apply the templates to whatever element remains in the paragraph -->
        <xsl:apply-templates
          select="*[not(@condition='file') and
                  not(@condition='height') and
                  not(@condition='width') and
                  not(@condition='allowFullScreen') and
                  not(@condition='allowscriptaccess')]"/>
      </div>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
