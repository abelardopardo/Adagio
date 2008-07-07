<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0" exclude-result-prefixes="exsl xi">

  <!-- This stylesheet is to include some default extensions when using docbook -->
  <xsl:import 
     href="http://docbook.sourceforge.net/release/xsl/current/xhtml/profile-docbook.xsl"/>
  <xsl:import 
     href="http://docbook.sourceforge.net/release/xsl/current/xhtml/manifest.xsl"/>

  <xsl:import href="es-modify.xsl"/>

  <!-- 
       Allows the inclusion in the audience attribute a date/time range in which
       the element is visible 
       -->
  <xsl:import href="AudienceDateProfile.xsl"/>

  <!-- Allows the inclusion of Flash videos and MP3 -->
  <xsl:import href="FLVObj.xsl"/>

</xsl:stylesheet>
