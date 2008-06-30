<?xml version="1.0" encoding="UTF-8"?>

<!-- $Id: solutionsection.xsl,v 1.1 2005/05/31 11:44:30 abel Exp $ --> 

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:exsl="http://exslt.org/common" 
  xmlns="http://www.w3.org/1999/xhtml" 
  exclude-result-prefixes="exsl" version="1.0">

  <!-- Brings in all the default values -->
  <xsl:import href="Params.xsl"/>

  <!--
       Variables needed to control the display of the video. Took the ones out
       of all possible ones that are more likely to be used.

       height
       width
       file
       image
       id
       searchbar

       backcolor
       frontcolor
       lightcolor
       screencolor
       
       showstop

       -->
  <xsl:template match="para[@condition = 'ada.flv.player']">
    <xsl:variable name="shockwave.width">
      <xsl:choose>
        <xsl:when test="phrase[@condition = 'width']">
          <xsl:value-of select="phrase[@condition = 'width']"/>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="ada.flv.player.width"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="shockwave.height">
      <xsl:choose>
        <xsl:when test="phrase[@condition = 'height']">
          <xsl:value-of select="phrase[@condition = 'height']"/>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="ada.flv.player.height"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="shockwave.movie">
      <xsl:value-of select="phrase[@condition = 'ada.flv.player.file']"/>
    </xsl:variable>

    <xsl:variable name="shockwave.pluginspace">
      <xsl:choose>
        <xsl:when test="phrase[@condition = 'pluginspage']">
          <xsl:value-of select="phrase[@condition = 'pluginspage']"/>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="$ada.flv.player.pluginspace"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:if test="$ada.flv.player.file">
      <div id="container">
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
      <script type="text/javascript" src="swfobject.js"></script>
      <script type="text/javascript">
        var s1 = new SWFObject("mediaplayer.swf","mediaplayer","300","185","8");
        s1.addParam("usefullscreen","true");
        s1.addVariable("width","300");
        s1.addVariable("height","185");
        s1.addVariable("file","video.flv");
        s1.write("container");
      </script>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
