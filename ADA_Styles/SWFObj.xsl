<?xml version="1.0" encoding="UTF-8"?>

<!-- $Id: solutionsection.xsl,v 1.1 2005/05/31 11:44:30 abel Exp $ --> 

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
