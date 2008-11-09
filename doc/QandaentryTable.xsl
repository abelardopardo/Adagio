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

  <xsl:output method="xml" indent="yes" encoding="UTF-8"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"/>

  <xsl:template match="qandaentry">
    <tr>
      <td>
        <table class="qandaentry">
          <xsl:apply-templates/>
          <tr>
            <td colspan="2">
              <a class="xref">
                <xsl:attribute name="href">#<xsl:value-of select="ancestor::section/@id"/></xsl:attribute>
                <xsl:attribute name="title"><xsl:value-of select="ancestor::section/title/text()"/></xsl:attribute>
                Top of the Section
              </a>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>
