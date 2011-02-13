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

  <!-- Brings in all the default values -->
  <xsl:import href="FLVObjParams.xsl"/>

  <!--
       Variables needed to control the display of the video. Only some of all
       the possible ones were selected.

       backcolor
       file
       frontcolor
       height
       id
       image
       lightcolor
       screencolor
       showstop
       width

       -->
  <xsl:template match="para[@condition = 'ada.flv.player']">
    <xsl:if test="(phrase[@condition = 'file'] != '') and @id and
                  (phrase[@condition = 'height'] != '') and 
                  (phrase[@condition = 'width'])">
      <xsl:variable name="shockwave.width">
        <xsl:value-of select="phrase[@condition = 'width']/text()"/>
      </xsl:variable>

      <xsl:variable name="shockwave.height">
        <xsl:value-of select="phrase[@condition = 'height']"/>
      </xsl:variable>

      <xsl:variable name="shockwave.pluginspace">
        <xsl:choose>
          <xsl:when test="phrase[@condition = 'pluginspage']">
            <xsl:value-of select="phrase[@condition = 'pluginspage']"/>
          </xsl:when>
          <xsl:otherwise><xsl:value-of 
          select="normalize-space($ada.flv.player.pluginspace)"/></xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <div class="ada_flv_video">
        <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
        <a>
          <xsl:attribute name="href"><xsl:value-of
          select="$shockwave.pluginspace"/></xsl:attribute>
          <xsl:choose>
            <xsl:when test="$profile.lang = 'es'">
              Descarga el reproductor de flash para ver este vídeo
            </xsl:when>
            <xsl:otherwise>
              Get the Flash Player to see this video
            </xsl:otherwise>
          </xsl:choose>
        </a>
      </div>
      <script type="text/javascript">
        <xsl:attribute name="src"><xsl:value-of select="normalize-space($ada.flv.player.js.file)"/></xsl:attribute></script>
      <script type="text/javascript">
        var s1 = new SWFObject("<xsl:value-of select="normalize-space($ada.flv.player.swf.file)"/>",
                               "mediaplayer",
                               "<xsl:value-of select="$shockwave.width"/>",
                               "<xsl:value-of select="$shockwave.height"/>",
                               "<xsl:value-of select="$ada.flv.player.minimum.version"/>");
        <!-- Added by default, seems reasonable -->
        s1.addParam("usefullscreen","true");

        s1.addVariable("width","<xsl:value-of select="$shockwave.width"/>");
        s1.addVariable("height","<xsl:value-of select="$shockwave.height"/>");
        s1.addVariable("file","<xsl:value-of select="$basedir"/>/<xsl:value-of 
                        select="phrase[@condition = 'file']/text()"/>");

        <xsl:if test="phrase[@condition = 'image']">
          s1.addVariable("image", 
                         "<xsl:value-of select="phrase[@condition = 'image']"/>");
        </xsl:if>

        <xsl:if test="phrase[@condition = 'backcolor']">
          s1.addVariable("backcolor", 
                         "<xsl:value-of select="phrase[@condition = 'backcolor']"/>");
        </xsl:if>

        <xsl:if test="phrase[@condition = 'frontcolor']">
          s1.addVariable("frontcolor", 
                         "<xsl:value-of select="phrase[@condition = 'frontcolor']"/>");
        </xsl:if>

        <xsl:if test="phrase[@condition = 'lightcolor']">
          s1.addVariable("lightcolor", 
                         "<xsl:value-of select="phrase[@condition = 'lightcolor']"/>");
        </xsl:if>

        <xsl:if test="phrase[@condition = 'screencolor']">
          s1.addVariable("screencolor", 
                         "<xsl:value-of select="phrase[@condition = 'screencolor']"/>");
        </xsl:if>

        <xsl:if test="phrase[@condition = 'showstop']">
          s1.addVariable("showstop", 
                         "<xsl:value-of select="phrase[@condition = 'showstop']"/>");
        </xsl:if>
        
        s1.write("<xsl:value-of select="@id"/>");
      </script>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
