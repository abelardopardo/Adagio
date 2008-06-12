<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common" 
  xmlns="http://www.w3.org/1999/xhtml" 
  exclude-result-prefixes="exsl" version="1.0">
  
  <xsl:import
    href="file:///usr/share/sgml/docbook/stylesheet/xsl/nwalsh/xhtml/profile-docbook.xsl"/> 
  <xsl:import
    href="file:///usr/share/sgml/docbook/stylesheet/xsl/nwalsh/html/manifest.xsl"/>

  <!-- Figure/Section names go in lowercase -->
  <xsl:include href="es-modify.xsl"/>

  <xsl:include href="TestQuestions.xsl"/>
  <xsl:include href="solutionsection.xsl"/>
  <xsl:include href="pguidesection.xsl"/>
  <xsl:include href="submitsection.xsl"/>
  <xsl:include href="removespanquote.xsl"/>

  <xsl:output method="html" indent="yes" encoding="UTF-8"/>
  
  <!-- Control the font size -->
  <xsl:param name="testexam.fontsize" select="'10pt'"/>

  <!-- Show the qandadiv ID -->
  <xsl:param name="include.id" select="'no'"/>

  <!-- Show the qandadiv ID -->
  <xsl:param name="render.separate.cover" select="'yes'"/>

  <!-- Prefix to include in all images -->
  <xsl:param name="rootPrefix" select="'./'"/>

  <xsl:template match="section">
    <xsl:variable name="part">
      <xsl:apply-templates select="para[@condition='part']"/>
    </xsl:variable>
    <xsl:variable name="duration" select="para[@condition='duration']/node()"/>
    <xsl:variable name="scoring" select="para[@condition='scoring']/node()"/>
    <xsl:variable name="date" select="para[@condition='date']/node()"/>
    <xsl:variable name="note" select="para[@condition='note']/node()"/>
    <xsl:variable name="name" select="para[@condition='name']"/>
    <xsl:variable name="score" select="para[@condition='score']"/>
    
    <table width="100%" style="border:0">
      <tr>
        <td width="10%" align="left" rowspan="3">
          <img align="center" alt="UC3M">
            <xsl:attribute name="src"><xsl:value-of
            select="$rootPrefix"/>images/basic/uc3mlogo70.png</xsl:attribute>
          </img>
        </td>
        <td width="50%" align="left">
          <b><xsl:apply-templates select="/*/para[@condition='degree']/node()"/></b>
        </td>
        <td width="40%" align="right">
          <b><xsl:apply-templates select="/*/para[@condition='coursename']/node()"/></b>
        </td>
      </tr>
      <tr>
        <td>
          <b><xsl:apply-templates select="/*/para[@condition='department']/node()"/></b>
        </td>
        <td align="right">
          <b><xsl:apply-templates select="/*/para[@condition='monthyear']/node()"/></b>
        </td>
      </tr>
      <tr>
        <td>
          <b><xsl:apply-templates select="/*/para[@condition='university']/node()"/></b>
        </td>
      </tr>
    </table>
    
    <xsl:comment>Part heading</xsl:comment>
    
    <xsl:if test="$part">
      <div style="text-align: center;">
        <u><xsl:copy-of select="$part"/></u>
        <xsl:if test="($include.id = 'yes') and (/section/@status)">
          (<xsl:value-of select="/section/@status"/>)
        </xsl:if>
      </div>
    </xsl:if>
    
    <xsl:if test="$duration or $scoring or $date or $note">
      <p>
        <table style="margin-left: 0%;">
          <xsl:if test="$duration">
            <xsl:comment>Duration/Score/Date</xsl:comment>
            <tr>
              <td>
                <b>
                  <xsl:choose>
                    <xsl:when test="$profile.lang='en'">
                      Duration:
                    </xsl:when>
                    <xsl:otherwise>
                      Duración:
                    </xsl:otherwise>
                  </xsl:choose>
                </b>
              </td>
              <td><xsl:apply-templates select="$duration"/></td>
            </tr>
          </xsl:if>
          <xsl:if test="$scoring">
            <tr>
              <td>
                <b>
                  <xsl:choose>
                    <xsl:when test="$profile.lang='en'">
                      Score:
                    </xsl:when>
                    <xsl:otherwise>
                      Puntuación:
                    </xsl:otherwise>
                  </xsl:choose>
                </b>
              </td>
              <td><xsl:apply-templates select="$scoring"/></td>
            </tr>
          </xsl:if>
          <xsl:if test="$date">
            <tr>
              <td>
                <b>
                  <xsl:choose>
                    <xsl:when test="$profile.lang='en'">
                      Date:
                    </xsl:when>
                    <xsl:otherwise>
                      Fecha:
                    </xsl:otherwise>
                  </xsl:choose>
                </b>
              </td>
              <td><xsl:apply-templates select="$date"/></td>
            </tr>
          </xsl:if>
          <xsl:if test="$note">
            <tr>
              <td valign="top">
                <b>
                  <xsl:choose>
                    <xsl:when test="$profile.lang='en'">
                      Remarks:
                    </xsl:when>
                    <xsl:otherwise>
                      Nota:
                    </xsl:otherwise>
                  </xsl:choose>
                </b>
              </td>
              <td><xsl:apply-templates select="$note"/></td>
            </tr>
          </xsl:if>
        </table>
      </p>
      <hr width="100%" align="center"/>
    </xsl:if>
    
    <xsl:if test="$name">
      <table width="100%" 
        style="border: 1px solid black; border-collapse: collapse;" 
        cellpadding="10">
        <tr>
          <td style="border: 1px solid black; border-collapse: collapse;"
              width="11%" align="left">
            <xsl:choose>
              <xsl:when test="$profile.lang='en'">
                Last Name:
              </xsl:when>
              <xsl:otherwise>
                Apellidos:
              </xsl:otherwise>
            </xsl:choose>
          </td>
          <td style="border: 1px solid black; border-collapse: collapse;"
              width="90%" ></td>
        </tr>
        <tr>
          <td style="border: 1px solid black; border-collapse: collapse;"
              align="left">
            <xsl:choose>
              <xsl:when test="$profile.lang='en'">
                First Name:
              </xsl:when>
              <xsl:otherwise>
                Nombre:
              </xsl:otherwise>
            </xsl:choose>
          </td>
          <td style="border: 1px solid black; border-collapse: collapse;"></td>
        </tr>
        <tr>
          <td style="border: 1px solid black; border-collapse: collapse;"
              align="left">
            <xsl:choose>
              <xsl:when test="$profile.lang='en'">
                Student ID:
              </xsl:when>
              <xsl:otherwise>
                NIA:
              </xsl:otherwise>
            </xsl:choose>
          </td>
          <td style="border: 1px solid black; border-collapse: collapse;"></td>
        </tr>
      </table>
      <hr width="100%" align="center"/>
    </xsl:if>
    
    <xsl:if test="$score">
      <table style="border: 1px solid black; border-collapse: collapse;" 
             cellpadding="10">
        <tr>
          <th style="border: 1px solid black; border-collapse: collapse;">
            <xsl:choose>
              <xsl:when test="$profile.lang='en'">
                Correct
              </xsl:when>
              <xsl:otherwise>
                Correctas
              </xsl:otherwise>
            </xsl:choose>
          </th>
          <th style="border: 1px solid black; border-collapse: collapse;">
            <xsl:choose>
              <xsl:when test="$profile.lang='en'">
                Incorrect
              </xsl:when>
              <xsl:otherwise>
                Incorrectas
              </xsl:otherwise>
            </xsl:choose>
          </th>
          <th style="border: 1px solid black; border-collapse: collapse;">
            <xsl:choose>
              <xsl:when test="$profile.lang='en'">
                No answer
              </xsl:when>
              <xsl:otherwise>
                Sin respuesta
              </xsl:otherwise>
            </xsl:choose>
          </th>
          <th style="border: 1px solid black; border-collapse: collapse;">
            <xsl:choose>
              <xsl:when test="$profile.lang='en'">
                Final Score
              </xsl:when>
              <xsl:otherwise>
                Nota
              </xsl:otherwise>
            </xsl:choose>
          </th>
        </tr>
        <tr>
          <td style="border: 1px solid black; border-collapse: collapse;"
              width="25%" height="50pt"/>
          <td style="border: 1px solid black; border-collapse: collapse;"
              width="25%" height="50pt"/>
          <td style="border: 1px solid black; border-collapse: collapse;"
              width="25%" height="50pt"/>
          <td style="border: 1px solid black; border-collapse: collapse;"
              width="25%" height="50pt"/>
        </tr>
      </table>
      <hr width="100%" align="center"/>

      <xsl:if test="$render.separate.cover = 'yes'">
        <br class="pageBreakBefore"/>
      </xsl:if>
    </xsl:if>
    
    <!-- Test questions within qandaset element -->
    <xsl:apply-templates select='qandaset/node()'/>
    
    <!-- Problems within a section element -->
    <xsl:for-each select="section/section">
      <b>
        <xsl:choose>
          <xsl:when test="$profile.lang='en'">Problem </xsl:when>
          <xsl:otherwise>Problema </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="count(preceding-sibling::section) +
                      count(following-sibling::section) &gt;= 1">
          <xsl:value-of select="count(preceding-sibling::section) + 1"/>.
        </xsl:if>
        <xsl:choose>
          <xsl:when test="@condition">
            <xsl:text> </xsl:text>
            <xsl:value-of select="@condition"/>
          </xsl:when>
          <xsl:when test="sectioninfo/subtitle">
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="sectioninfo/subtitle/node()"/>
          </xsl:when>
        </xsl:choose>
        <!--
        <xsl:if test="@condition"> 
          <xsl:text> </xsl:text>
          <xsl:value-of select="@condition"/>
        </xsl:if>
        -->
      </b>
      <xsl:apply-templates/>
      <xsl:if test="not(position() = last())">
        <hr width="100%"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="user.head.content">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <xsl:element name="meta">
      <xsl:attribute name="name">Author</xsl:attribute>
      <xsl:attribute name="content">
        Carlos III University of Madrid, Spain
      </xsl:attribute>
    </xsl:element>
    <title><xsl:value-of select="title"/></title>
    <style type="text/css">
      body { 
        font-family: 'Verdana';
      /* font-family: sans-serif; */
        font-size: <xsl:value-of select="$testexam.fontsize"/>;
        color: black; 
        background: white;
      }
      table       { page-break-inside: avoid; 
                    border-collapse: collapse; 
                    margin-right: auto; 
                    margin-left: auto; 
                  }
      hr                { height: 2px; background: black; }
      table.data        { border: 2px solid black; }
      th.data           { border: 2px solid black; }
      td.data           { border: 2px solid black; }
      tr                { page-break-inside: avoid; }
      code.code { 
        font-family: Courier New, Courier, monospace;
        /* font-size: 10pt; */
        font-style: normal;
        font-variant: normal;
        font-weight: normal;
      }

      div.informalfigure { text-align: center; }

      td.qtext p { margin-top: 2pt; margin-bottom: 2pt; }

      .underline { text-decoration: underline; }
      /* Add a class attribute with these values to force PDF page
      breaks */
      .pageBreakBefore {
        margin-bottom: 0; page-break-before: always;
      }
      .pageBreakAfter {
          margin-bottom: 0; page-break-after: always;
      } 
    </style>      
  </xsl:template>
</xsl:stylesheet>

