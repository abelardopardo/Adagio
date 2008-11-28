<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0" exclude-result-prefixes="exsl xi str">
  
  <xsl:import href="HeadTail.xsl"/>
  <xsl:import href="HeaderLinks.xsl"/>

  <xsl:template match="chapter">
    <div class="narrowcontent">
      <xsl:if test="title/text() != ''">
        <h2 class="head-center"><xsl:apply-templates select="title/node()"/></h2>
      </xsl:if>
    </div>

    <xsl:call-template name="ada.insert.header.links"/>

    <xsl:apply-templates/>
  </xsl:template>
      
</xsl:stylesheet>
