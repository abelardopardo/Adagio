<?xml version="1.0" encoding="UTF-8"?>

<!-- $Id: pguidesection.xsl,v 1.1 2005/05/31 11:47:37 abel Exp $ --> 

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:exsl="http://exslt.org/common" 
  xmlns="http://www.w3.org/1999/xhtml" 
  exclude-result-prefixes="exsl" version="1.0">
  
  <!-- Include professor guide text --> 
  <xsl:param name="professorguide.include.guide" select="'no'"/>
  <!-- Background color for the professor guide box  --> 
  <xsl:param name="pguidebgn" select="'#CCD0D6'"/>

  <!-- Prevent this section from appearing in TOC -->
  <xsl:template match="section[@condition='professorguide']" mode="toc" />

  <!-- Conditionally process the notes labeled with condition
       professorguide -->
  <xsl:template match="section[@condition = 'professorguide'] |
                       note[@condition = 'professorguide']">
    <xsl:if test="$professorguide.include.guide = 'yes'">
      <p>
        <table class="ada_pguide_table" cellpadding="10">
          <tr>
            <td>
              <xsl:choose>
                <xsl:when test="$profile.lang='en'">
                  <p><b>Professor Guide:</b></p>
                </xsl:when>
                <xsl:otherwise>
                  <p><b>Guía del profesor</b></p>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:apply-templates select="node()"/>
            </td>
          </tr>
        </table>
      </p>
    </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>
