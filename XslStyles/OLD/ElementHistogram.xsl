<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common" 
  xmlns="http://www.w3.org/1999/xhtml" 
  exclude-result-prefixes="exsl" version="1.0">

  <xsl:output method="text" encoding="UTF-8"/>

  <xsl:template match="*">
    <xsl:if test="name()">
      -- <xsl:value-of select="name()"/> --
    </xsl:if>
    <xsl:if test="./node()">
      <xsl:apply-templates select="node()"/>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
