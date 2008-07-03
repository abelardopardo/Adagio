<?xml version="1.0" encoding="UTF-8"?>

<!-- $Id: solutionsection.xsl,v 1.1 2005/05/31 11:44:30 abel Exp $ --> 

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:exsl="http://exslt.org/common" 
  xmlns="http://www.w3.org/1999/xhtml" 
  exclude-result-prefixes="exsl" version="1.0">
  
  <!-- Include the solutions for the exercises --> 
  <xsl:param name="laboratory.include.solutions" select="'no'"/>

  <!-- Prevent this section from appearing in TOC -->
  <xsl:template match="section[@condition='solution']"       mode="toc" />

  <!-- Conditionally process the sections/paragraphs labeled with condition
       solution -->
  <xsl:template match="section[@condition='solution']|phrase[@condition='solution']|note[@condition='solution']">
    <xsl:if test="$laboratory.include.solutions = 'yes'">
      <table class="ada_solution_table">
        <tr>
          <td style="border-right: 0.5pt solid ; border-bottom: 0.5pt solid ;">
            <xsl:choose>
              <xsl:when test="$profile.lang='en'">
                <p><b>Solution:</b></p>
              </xsl:when>
              <xsl:otherwise>
                <p><b>Solución:</b></p>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="node()"/>
          </td>
        </tr>
      </table>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
