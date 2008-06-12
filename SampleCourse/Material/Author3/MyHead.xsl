<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0" exclude-result-prefixes="exsl xi">
  
  <!-- Brings in all the default values -->
  <xsl:import href="../../../XslStyles/HeadTail.xsl"/>

  <xsl:param name="ada.page.head.bigtitle" select="0"/>
  <xsl:param name="ada.page.cssstyle.file" select="'../../style.css'"/>
</xsl:stylesheet>
