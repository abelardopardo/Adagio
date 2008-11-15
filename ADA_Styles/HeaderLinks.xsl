<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0" exclude-result-prefixes="exsl">

  <xsl:import href="AdaProfile.xsl"/>

  <xsl:param name="ada.page.header.links"/>

  <!-- Variable that takes either a para with
       condition="ada.page.header.links" or the value of the parameter (in
       this order) -->
  <xsl:template name="ada.insert.header.links">
    <xsl:variable name="ada.page.header.links.var">
      <xsl:choose>
        <xsl:when test="//*/note[@condition='AdminInfo']/para[@condition='ada.page.header.links']">
          <xsl:copy-of select="//*/note[@condition='AdminInfo']/para[@condition='ada.page.header.links']/node()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="exsl:node-set($ada.page.header.links)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:if test="$ada.page.header.links.var != ''">
      <div class="noprint head-center">
        <xsl:call-template name="ada.profile.subtree">
          <xsl:with-param name="subtree" 
            select="exsl:node-set($ada.page.header.links.var)/node()"/>
        </xsl:call-template>
        <hr class="head-center"/>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template 
    match="note[@condition='AdminInfo']"/>
</xsl:stylesheet>
