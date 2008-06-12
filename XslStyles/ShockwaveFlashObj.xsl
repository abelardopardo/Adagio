<?xml version="1.0" encoding="UTF-8"?>

<!-- $Id: solutionsection.xsl,v 1.1 2005/05/31 11:44:30 abel Exp $ --> 

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:exsl="http://exslt.org/common" 
  xmlns="http://www.w3.org/1999/xhtml" 
  exclude-result-prefixes="exsl" version="1.0">

  <xsl:variable name="flv.player">mediaplayer.swf</xsl:variable>

  <xsl:template match="para[@condition = 'shockwave.flash']">
    <xsl:variable name="shockwave.width">
      <xsl:choose>
        <xsl:when test="phrase[@condition = 'width']">
          <xsl:value-of select="phrase[@condition = 'width']"/>
        </xsl:when>
        <xsl:otherwise>740</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="shockwave.height">
      <xsl:choose>
        <xsl:when test="phrase[@condition = 'height']">
          <xsl:value-of select="phrase[@condition = 'height']"/>
        </xsl:when>
        <xsl:otherwise>740</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="shockwave.codebase">
      <xsl:choose>
        <xsl:when test="phrase[@condition = 'codebase']">
          <xsl:value-of select="phrase[@condition = 'codebase']"/>
        </xsl:when>
        <xsl:otherwise>http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=5,0,0,0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="shockwave.movie">
      <xsl:value-of select="phrase[@condition = 'shockwave.movie']"/>
    </xsl:variable>

    <xsl:variable name="shockwave.play">
      <xsl:choose>
        <xsl:when test="phrase[@condition = 'play']">
          <xsl:value-of select="phrase[@condition = 'play']"/>
        </xsl:when>
        <xsl:otherwise>true</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="shockwave.loop">
      <xsl:choose>
        <xsl:when test="phrase[@condition = 'loop']">
          <xsl:value-of select="phrase[@condition = 'loop']"/>
        </xsl:when>
        <xsl:otherwise>false</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="shockwave.quality">
      <xsl:choose>
        <xsl:when test="phrase[@condition = 'quality']">
          <xsl:value-of select="phrase[@condition = 'quality']"/>
        </xsl:when>
        <xsl:otherwise>low</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="shockwave.type">
      <xsl:choose>
        <xsl:when test="phrase[@condition = 'type']">
          <xsl:value-of select="phrase[@condition = 'type']"/>
        </xsl:when>
        <xsl:otherwise>application/x-shockwave-flash</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="shockwave.pluginspage">
      <xsl:choose>
        <xsl:when test="phrase[@condition = 'pluginspage']">
          <xsl:value-of select="phrase[@condition = 'pluginspage']"/>
        </xsl:when>
        <xsl:otherwise>http://www.macromedia.com/go/getflashplayer</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:if test="$shockwave.movie">
      <center>
        <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000">
          <xsl:attribute name="width"><xsl:value-of 
          select="$shockwave.width"/></xsl:attribute>
          <xsl:attribute name="height"><xsl:value-of 
          select="$shockwave.height"/></xsl:attribute>
          <xsl:attribute name="codebase"><xsl:value-of 
          select="$shockwave.codebase"/></xsl:attribute>
          <xsl:attribute name="codebase"><xsl:value-of 
          select="$shockwave.codebase"/></xsl:attribute>
          <param name="movie">
            <xsl:attribute name="value"><xsl:value-of
            select="$shockwave.movie"/></xsl:attribute>
          </param>
          <param name="play">
            <xsl:attribute name="value"><xsl:value-of
            select="$shockwave.play"/></xsl:attribute>
          </param>
          <param name="loop">
            <xsl:attribute name="value"><xsl:value-of
            select="$shockwave.loop"/></xsl:attribute>
          </param>
          <param name="quality">
            <xsl:attribute name="value"><xsl:value-of
            select="$shockwave.quality"/></xsl:attribute>
          </param>
          <embed>
            <xsl:attribute name="src"><xsl:value-of 
            select="$shockwave.movie"/></xsl:attribute>
            <xsl:attribute name="width"><xsl:value-of 
            select="$shockwave.width"/></xsl:attribute>
            <xsl:attribute name="height"><xsl:value-of 
            select="$shockwave.height"/></xsl:attribute>
            <xsl:attribute name="play"><xsl:value-of 
            select="$shockwave.play"/></xsl:attribute>
            <xsl:attribute name="loop"><xsl:value-of 
            select="$shockwave.loop"/></xsl:attribute>
            <xsl:attribute name="quality"><xsl:value-of 
            select="$shockwave.quality"/></xsl:attribute>
            <xsl:attribute name="type"><xsl:value-of 
            select="$shockwave.type"/></xsl:attribute>
            <xsl:attribute name="pluginspage"><xsl:value-of 
            select="$shockwave.pluginspage"/></xsl:attribute>
          </embed>
        </object>
      </center>
    </xsl:if>
  </xsl:template>

  <!-- 
                FLV Embedding
  -->
  <xsl:template match="para[@condition = 'embedded.flash']">
    <xsl:variable name="flash.width">
      <xsl:choose>
        <xsl:when test="phrase[@condition = 'width']">
          <xsl:value-of select="phrase[@condition = 'width']"/>
        </xsl:when>
        <xsl:otherwise>400</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="flash.height">
      <xsl:choose>
        <xsl:when test="phrase[@condition = 'height']">
          <xsl:value-of select="phrase[@condition = 'height']"/>
        </xsl:when>
        <xsl:otherwise>400</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="flash.type">
      <xsl:choose>
        <xsl:when test="phrase[@condition = 'type']">
          <xsl:value-of select="phrase[@condition = 'type']"/>
        </xsl:when>
        <xsl:otherwise>application/x-shockwave-flash</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="flash.movie">
      <xsl:value-of select="phrase[@condition = 'flash.movie']"/>
    </xsl:variable>

    <xsl:variable name="flash.pluginspage">
      <xsl:choose>
        <xsl:when test="phrase[@condition = 'pluginspage']">
          <xsl:value-of select="phrase[@condition = 'pluginspage']"/>
        </xsl:when>
        <xsl:otherwise>http://www.macromedia.com/go/getflashplayer</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:if test="$flash.movie">
      <embed>
        <xsl:attribute name="src"><xsl:value-of 
        select="$flv.player"/></xsl:attribute>
        <xsl:attribute name="width"><xsl:value-of 
        select="$flash.width"/></xsl:attribute>
        <xsl:attribute name="height"><xsl:value-of 
        select="$flash.height"/></xsl:attribute>
        <xsl:attribute name="type"><xsl:value-of 
        select="$flash.type"/></xsl:attribute>
        <xsl:attribute name="pluginspage"><xsl:value-of 
        select="$flash.pluginspage"/></xsl:attribute>
        <xsl:attribute name="flashvars">file=<xsl:value-of
        select="$flash.movie"/></xsl:attribute>
      </embed>
    </xsl:if>
  </xsl:template>

  <!-- 
                Windows Media Embedding
  -->
  <xsl:template match="para[@condition = 'embedded.wmv']">
    <!-- Width -->
    <xsl:variable name="wmv.width">
      <xsl:choose>
        <xsl:when test="phrase[@condition = 'width']">
          <xsl:value-of select="phrase[@condition = 'width']"/>
        </xsl:when>
        <xsl:otherwise>400</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- Height -->
    <xsl:variable name="wmv.height">
      <xsl:choose>
        <xsl:when test="phrase[@condition = 'height']">
          <xsl:value-of select="phrase[@condition = 'height']"/>
        </xsl:when>
        <xsl:otherwise>400</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- ID -->
    <xsl:variable name="wmv.id">
      <xsl:choose>
        <xsl:when test="phrase[@condition = 'id']">
          <xsl:value-of select="phrase[@condition = 'id']"/>
        </xsl:when>
        <xsl:otherwise>nsplay</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- classid -->
    <xsl:variable name="wmv.classid">
      <xsl:choose>
        <xsl:when test="phrase[@condition = 'classid']">
          <xsl:value-of select="phrase[@condition = 'classid']"/>
        </xsl:when>
        <xsl:otherwise>clsid:22d6f312-b0f6-11d0-94ab-0080c74c7e95</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- Type for the object element  -->
    <xsl:variable name="wmv.object.type">
      <xsl:choose>
        <xsl:when test="phrase[@condition = 'object.type']">
          <xsl:value-of select="phrase[@condition = 'object.type']"/>
        </xsl:when>
        <xsl:otherwise>application/x-oleobject</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- type for the embed element -->
    <xsl:variable name="wmv.embed.type">
      <xsl:choose>
        <xsl:when test="phrase[@condition = 'embed.type']">
          <xsl:value-of select="phrase[@condition = 'embed.type']"/>
        </xsl:when>
        <xsl:otherwise>application/x-mplayer2</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- Codebase -->
    <xsl:variable name="wmv.codebase">
      <xsl:choose>
        <xsl:when test="phrase[@condition = 'codebase']">
          <xsl:value-of select="phrase[@condition = 'codebase']"/>
        </xsl:when>
        <xsl:otherwise>http://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#version=5,1,52,701</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- Standby message -->
    <xsl:variable name="wmv.standby">
      <xsl:choose>
        <xsl:when test="phrase[@condition = 'standby']">
          <xsl:value-of select="phrase[@condition = 'standby']"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="$profile.lang = 'es'">cargando los
              componentes del reproductor de windows media de
              microsoft...
            </xsl:when>
            <xsl:otherwise>Loading components for Microsoft Windows
            Media Player...
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise> 
      </xsl:choose>
    </xsl:variable>
    <!-- Filename -->
    <xsl:variable name="wmv.filename">
      <xsl:choose>
        <xsl:when test="phrase[@condition = 'filename']">
          <xsl:value-of select="phrase[@condition = 'filename']"/>
        </xsl:when>
        <xsl:otherwise>NOFILENAMEGIVEN</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- Showcontrols -->
    <xsl:variable name="wmv.showcontrols">
      <xsl:choose>
        <xsl:when test="phrase[@condition = 'showcontrols']">
          <xsl:value-of select="phrase[@condition = 'showcontrols']"/>
        </xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- showdisplay -->
    <xsl:variable name="wmv.showdisplay">
      <xsl:choose>
        <xsl:when test="phrase[@condition = 'showdisplay']">
          <xsl:value-of select="phrase[@condition = 'showdisplay']"/>
        </xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- Showstatusbar -->
    <xsl:variable name="wmv.showstatusbar">
      <xsl:choose>
        <xsl:when test="phrase[@condition = 'showstatusbar']">
          <xsl:value-of select="phrase[@condition = 'showstatusbar']"/>
        </xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- Autosize -->
    <xsl:variable name="wmv.autosize">
      <xsl:choose>
        <xsl:when test="phrase[@condition = 'autosize']">
          <xsl:value-of select="phrase[@condition = 'autosize']"/>
        </xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- Pluginspage -->
    <xsl:variable name="wmv.pluginspage">
      <xsl:choose>
        <xsl:when test="phrase[@condition = 'pluginspage']">
          <xsl:value-of select="phrase[@condition = 'pluginspage']"/>
        </xsl:when>
        <xsl:otherwise>http://www.microsoft.com/windows/downloads/contents/products/mediaplayer/</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <object>
      <xsl:attribute name="id"><xsl:value-of select="$wmv.id"/></xsl:attribute>
      <xsl:attribute name="standby"><xsl:value-of select="$wmv.standby"/></xsl:attribute>
      <xsl:attribute name="type"><xsl:value-of select="$wmv.object.type"/></xsl:attribute>
      <xsl:attribute name="width"><xsl:value-of select="$wmv.width"/></xsl:attribute>
      <xsl:attribute name="height"><xsl:value-of select="$wmv.height"/></xsl:attribute>
      <xsl:attribute name="classid"><xsl:value-of select="$wmv.classid"/></xsl:attribute> 
      <xsl:attribute name="codebase"><xsl:value-of select="$wmv.codebase"/></xsl:attribute>
      <param name="filename">
        <xsl:attribute name="value"><xsl:value-of select="$wmv.filename"/></xsl:attribute>
      </param>
      <param name="showcontrols">
        <xsl:attribute name="value"><xsl:value-of select="$wmv.showcontrols"/></xsl:attribute>
      </param>
      <param name="showdisplay">
        <xsl:attribute name="value"><xsl:value-of select="$wmv.showdisplay"/></xsl:attribute>
      </param>
      <param name="showstatusbar">
        <xsl:attribute name="value"><xsl:value-of select="$wmv.showstatusbar"/></xsl:attribute>
      </param>
      <param name="autosize">
        <xsl:attribute name="value"><xsl:value-of select="$wmv.autosize"/></xsl:attribute>
      </param>

      <embed type="application/x-mplayer2">
        <xsl:attribute name="type"><xsl:value-of 
        select="$wmv.embed.type" /></xsl:attribute>
        <xsl:attribute name="pluginspage"><xsl:value-of 
        select="$wmv.pluginspage" /></xsl:attribute>
        <xsl:attribute name="filename"><xsl:value-of 
        select="$wmv.filename" /></xsl:attribute>
        <xsl:attribute name="showcontrols"><xsl:value-of 
        select="$wmv.showcontrols" /></xsl:attribute>
        <xsl:attribute name="showdisplay"><xsl:value-of 
        select="$wmv.showdisplay" /></xsl:attribute>
        <xsl:attribute name="showstatusbar"><xsl:value-of 
        select="$wmv.showstatusbar" /></xsl:attribute>
        <xsl:attribute name="autosize"><xsl:value-of 
        select="$wmv.autosize" /></xsl:attribute>
        <xsl:attribute name="width"><xsl:value-of 
        select="$wmv.width" /></xsl:attribute>
        <xsl:attribute name="height"><xsl:value-of 
        select="$wmv.height" /></xsl:attribute>
      </embed>
    </object>
  </xsl:template>
  <!-- Embed Windows Media Player stuff
<object id="nsplay" width="384" height="328" classid="clsid:22d6f312-b0f6-11d0-94ab-0080c74c7e95" codebase="http://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#version=5,1,52,701" standby="cargando los componentes del reproductor de windows media de microsoft..." type="application/x-oleobject">
    <param name="filename" value="mms://streaming.ehu.es/vod/cbiz/ueu/biz4/070629_eji.wmv" />
    <param name="showcontrols" value="1" />
    <param name="showdisplay" value="0" />
    <param name="showstatusbar" value="0" />
    <param name="autosize" value="1" />

    <embed type="application/x-mplayer2"
        pluginspage="http://www.microsoft.com/windows/downloads/contents/products/mediaplayer/"
        filename="mms://streaming.ehu.es/vod/cbiz/ueu/biz4/070629_eji.wmv"
        showcontrols="1"
        showdisplay="0"
        showstatusbar="0"
        autosize="1"
        width="384"
        height="328" />
</object>
-->
</xsl:stylesheet>
