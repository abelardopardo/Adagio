<?xml version="1.0" encoding="ASCII"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
    xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="doc"
    version="1.0">

  <xsl:import 
     href="http://docbook.sourceforge.net/release/xsl/current/xhtml/profile-docbook.xsl"/>
  <xsl:import 
     href="http://docbook.sourceforge.net/release/xsl/current/xhtml/manifest.xsl"/>
  <xsl:import href="../XslStyles/es-modify.xsl"/>

  <xsl:template match="qandaentry">
    <tr>
      <td>
        <table class="qandaentry">
          <xsl:apply-templates/>
        </table>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>
