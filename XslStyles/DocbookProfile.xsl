<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0" exclude-result-prefixes="exsl xi">

  <!-- This trivial stylesheet is to make sure the dependencies work correctly
  in the ant files. They check if the style applied is up to date. If using
  directly the URL, this dependency check fails and the xsltproc is executed
  always (thus wasting a lot of time). By using this trivial stylesheet, the
  dependency check only fails if there has been changes. -->

  <xsl:import 
     href="http://docbook.sourceforge.net/release/xsl/current/xhtml/profile-docbook.xsl"/>

</xsl:stylesheet>
