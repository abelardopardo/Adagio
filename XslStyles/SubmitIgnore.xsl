<?xml version="1.0" encoding="UTF-8"?>

<!-- $Id: submitsection.xsl,v 1.2 2005/05/31 11:39:35 abel Exp $ --> 

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:exsl="http://exslt.org/common" 
  xmlns="http://www.w3.org/1999/xhtml" 
  exclude-result-prefixes="exsl" version="1.0">
  
  <!-- Ignore the sections/paragraphs labeled with condition submit -->
  <xsl:template match="section[@condition = 'submit']" mode="toc" />

  <xsl:template match="section[@condition = 'submit']|
                       note[@condition='submit']|
                       phrase[@condition='submit']"/>

</xsl:stylesheet>
