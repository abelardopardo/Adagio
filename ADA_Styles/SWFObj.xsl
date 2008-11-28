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
  xmlns:exsl="http://exslt.org/common" 
  xmlns="http://www.w3.org/1999/xhtml" 
  exclude-result-prefixes="exsl" version="1.0">

  <!--
       Variables needed to control the display of the video. Only some of all
       the possible ones were selected.

       file
       height
       width
       id (optional)
    -->

  <xsl:template match="para[@condition = 'ada.swf.player']">
    <xsl:if test="(phrase[@condition = 'file'] != '') and
                  (phrase[@condition = 'height'] != '') and 
                  (phrase[@condition = 'width'])">
      <xsl:variable name="shockwave.width">
        <xsl:value-of select="phrase[@condition = 'width']/text()"/>
      </xsl:variable>

      <xsl:variable name="shockwave.height">
        <xsl:value-of select="phrase[@condition = 'height']"/>
      </xsl:variable>

      <div class="ada_swf_video">
        <!-- Pass the @id attribute to the div enclosing the swf -->
        <xsl:if test="@id">
          <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
        </xsl:if>
        <embed type="application/x-shockwave-flash">
          <xsl:attribute name="src"><xsl:value-of 
          select="phrase[@condition = 'file']/text()"/></xsl:attribute>
          <xsl:attribute name="height"><xsl:value-of 
          select="phrase[@condition = 'height']/text()"/></xsl:attribute>
          <xsl:attribute name="width"><xsl:value-of 
          select="phrase[@condition = 'width']/text()"/></xsl:attribute>
        </embed>
        
        <!-- Apply the templates to whatever element remains in the paragraph -->
        <xsl:apply-templates 
          select="*[not(@condition='file') and 
                    not(@condition='height') and 
                    not(@condition='width')]"/>
      </div>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
