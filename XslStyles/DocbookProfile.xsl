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
  <xsl:import href="AdaProfile.xsl"/>

  <!-- Allows the inclusion of Flash videos and MP3 -->
  <xsl:import href="FLVObj.xsl"/>

  <!-- Allows the inclusion of Flash videos and MP3 -->
  <xsl:import href="SWFObj.xsl"/>

  <!-- 
       The variable l10n.gentext.language takes its value from the presence of
       the attribute lang or xml:lang in any of the ancestors of a node. This
       does not work when processing a multi-language document in which that
       attribute is not at the root of the document but in elements deeper in
       the hierarchy. One consequence, for example is that it renders "Table of
       Contents" despite processing a document with profile.lang = es. The
       assignment forces l10n.gentext.language to have the same value.
       -->
  <xsl:param name="l10n.gentext.language"><xsl:value-of select="$profile.lang"/></xsl:param>  

</xsl:stylesheet>
