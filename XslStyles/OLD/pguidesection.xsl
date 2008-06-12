<?xml version="1.0" encoding="UTF-8"?>

<!-- $Id: pguidesection.xsl,v 1.1 2005/05/31 11:47:37 abel Exp $ --> 

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:exsl="http://exslt.org/common" 
  xmlns="http://www.w3.org/1999/xhtml" 
  exclude-result-prefixes="exsl" version="1.0">
  
  <!-- Include professor guide text --> 
  <xsl:param name="include.guide" select="'no'"/>
  <!-- Background color for the professor guide box  --> 
  <xsl:param name="pguidebgn" select="'#CCD0D6'"/>

  <!-- Conditionally process the notes labeled with condition
       professorguide -->
  <xsl:template match="note[@condition='professorguide']">
    <xsl:if test="$include.guide = 'yes'">
      <xsl:choose>
        <xsl:when test="title">
          <table cellpadding="10"
            style="border-collapse: collapse;border: 1px solid black;">
            <xsl:attribute name="bgcolor">
              <xsl:value-of select="$pguidebgn"/>
            </xsl:attribute>
            <tr>
              <td style="border-right: 0.5pt solid ; border-bottom: 0.5pt solid ; ">
                <!-- Taken from docbook/html/admin.xsl -->
                <p><b><xsl:value-of select="title/text()"/></b></p>
                <xsl:apply-templates select="node()"/>
              </td>
            </tr>
          </table>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="node()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>
