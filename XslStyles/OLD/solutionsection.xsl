<?xml version="1.0" encoding="UTF-8"?>

<!-- $Id: solutionsection.xsl,v 1.1 2005/05/31 11:44:30 abel Exp $ --> 

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:exsl="http://exslt.org/common" 
  xmlns="http://www.w3.org/1999/xhtml" 
  exclude-result-prefixes="exsl" version="1.0">
  
  <!-- Include the solutions for the exercises --> 
  <xsl:param name="include.solutions" select="'no'"/>

  <!-- Conditionally process the sections/paragraphs labeled with condition
       solution -->
  <xsl:template match="section[@condition='solution']|phrase[@condition='solution']|note[@condition='solution']">
    <xsl:if test="$include.solutions = 'yes'">
      <table cellpadding="10"
        style="border-collapse: collapse;border: 1px solid black;">
        <tr>
          <td style="border-right: 0.5pt solid ; border-bottom: 0.5pt solid ; ">
            <p><b>Solución:</b></p>
            <xsl:apply-templates select="node()"/>
          </td>
        </tr>
      </table>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
