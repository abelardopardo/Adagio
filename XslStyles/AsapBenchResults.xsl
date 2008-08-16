<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  version="1.0" exclude-result-prefixes="exsl str">

  <xsl:import href="HeadTail.xsl"/>
  <xsl:import href="CountDown.xsl"/>
  <xsl:import href="ChatRoomLink.xsl"/>

  <xsl:import href="AsapBenchResultsParams.xsl"/>

  <xsl:variable name="testUnits" select="/chapter/testUnits"/>
  <xsl:variable name="profile.lang"      select="/chapter/@lang"/>
  <xsl:variable name="columns"   
    select="/chapter/columns[@lang = $profile.lang]"/>
  <xsl:variable name="datadir"   
    select="/chapter/datadir[@lang = $profile.lang]/text()"/>


  <xsl:template match="chapter[@condition = 'result']">
    <h2 align="center">
      <xsl:choose>
        <xsl:when test="title">
          <xsl:apply-templates select="title/node()"/>
        </xsl:when>
        <xsl:when test="title/text() = '' and $profile.lang = 'en'">
          Benchmark Results
        </xsl:when>
        <xsl:otherwise>
          Resultados del juego de pruebas
        </xsl:otherwise>
      </xsl:choose>
    </h2>
    
    <!-- Insert countdown here -->
    <xsl:if test="para[@condition='deadline.format']/text() != ''">
      <xsl:variable name="deadlineparts">
        <tokens xmlns="">
          <xsl:copy-of
            select="str:tokenize(normalize-space(para[@condition='deadline.format']/text()), ' /')"/>
        </tokens>
      </xsl:variable>

      <p style="text-align: center">
        <xsl:call-template name="ada.page.countdown.insert">
          <xsl:with-param name="countdown.year">
            <xsl:value-of
              select="exsl:node-set($deadlineparts)/tokens/token[position() =
                      4]/text()"/> 
          </xsl:with-param>
          <xsl:with-param name="countdown.month">
            <xsl:value-of
              select="exsl:node-set($deadlineparts)/tokens/token[position() =
                      3]/text()"/> 
          </xsl:with-param>
          <xsl:with-param name="countdown.day">
            <xsl:value-of
              select="exsl:node-set($deadlineparts)/tokens/token[position() =
                      2]/text()"/> 
          </xsl:with-param>
          <xsl:with-param name="countdown.hour">
            <xsl:value-of
              select="exsl:node-set($deadlineparts)/tokens/token[position() =
                      5]/text()"/> 
          </xsl:with-param>
          <xsl:with-param name="countdown.minute">
            <xsl:value-of
              select="exsl:node-set($deadlineparts)/tokens/token[position() =
                      6]/text()"/> 
          </xsl:with-param>
        </xsl:call-template>
      </p>
    </xsl:if>
    
    <p align="center">
      <xsl:choose>
        <xsl:when test="$profile.lang = 'en'">
          Last update:
        </xsl:when>
        <xsl:otherwise>
          Última actualización: 
        </xsl:otherwise>
      </xsl:choose>
      <xsl:element name="script">
        <xsl:attribute name="language">JavaScript</xsl:attribute>
        <xsl:attribute name="type">text/javascript</xsl:attribute>
        <xsl:comment>
          document.write(document.lastModified) 
          //</xsl:comment>
      </xsl:element>
    </p>

    <xsl:call-template name="ada.insert.chatroom.link"/>

    <xsl:if test="section[@condition = 'legend']">
      <xsl:apply-templates select="section[@condition = 'legend']"/>
    </xsl:if>

    <xsl:if test="referencedir/text() != ''">
      <xsl:call-template name="ada.asap.results.dotable"/>
    </xsl:if>
    
    <h3 align="center">
      <xsl:choose>
        <xsl:when test="$profile.lang = 'en'">
          Received Submissions
        </xsl:when>
        <xsl:otherwise>
          Entregas recibidas
        </xsl:otherwise>
      </xsl:choose>
    </h3>
    <xsl:choose>
      <xsl:when test="$ada.asapbenchresults.empty.data.table = 'yes'">
        <xsl:call-template name="ada.asap.results.dotable" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="ada.asap.results.dotable">
          <xsl:with-param name="srcData" select="directoryfile[@lang = $profile.lang]"/>
          <xsl:with-param name="withOrdinal" select="'yes'"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="ada.asap.results.dotable">
    <xsl:param name="withOrdinal">no</xsl:param>
    <xsl:param name="srcData"/>

    <table style="page-break-inside: avoid; border: 1px solid black" 
      cellpadding="5" align="center" width="95%">

      <!-- Generate the table head row -->
      <thead>
        <xsl:call-template name="ada.asap.results.dotable.head">
          <xsl:with-param name="withOrdinal" select="$withOrdinal"/>
          <xsl:with-param name="srcData" select="$srcData"/>
        </xsl:call-template>
      </thead>

      <!-- Create a table depending on processing a set of
           submissions, or a single entry, which means, the reference
           implementation. Variable srcData is the one to check. -->
      <tbody>
        <xsl:choose>
          <xsl:when test="$srcData">
            <xsl:for-each select="$srcData/table/entry">
              <!-- Sort by rank field -->
              <xsl:sort data-type="number"
                select="document(concat($datadir, '/sub.', @id, 
                        '/bench.xml'))/testReport/rank/text()"/>
              <!-- If rank field is identical, go for sub.ID -->
              <xsl:sort data-type="text" select="@id"/>
              <!-- Removed this sort criteria because in the absence of rank
                   it shuffles completely the submissions. -->
              <!-- <xsl:sort select="users/user/id"/> -->
              
              <xsl:variable name="userInfo" select="./users"/>
              <xsl:variable name="dirName" select="@id" />
              <xsl:variable name="date" select="@lastText" />
              <xsl:variable name="ordinal" select="position()"/>
              <xsl:variable name="subDir" 
                select="concat($datadir, '/sub.', $dirName)" />
              <!-- CALL ada.asap.results.doentry TEMPLATE HERE  -->
              <xsl:call-template name="ada.asap.results.doentry">
                <xsl:with-param name="withOrdinal" select="$withOrdinal"/>
                <xsl:with-param name="ordinal" select="$ordinal"/>
                <xsl:with-param name="userInfo" select="$userInfo"/>
                <xsl:with-param name="date" select="$date"/>
                <xsl:with-param name="subDir" select="$subDir"/>
              </xsl:call-template>
              
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <!-- CALL ada.asap.results.doentry TEMPLATE HERE -->
            <xsl:call-template name="ada.asap.results.doentry">
              <xsl:with-param name="withOrdinal" select="$withOrdinal"/>
              <xsl:with-param name="ordinal" select="1"/>
              <xsl:with-param name="subDir" 
                select="referencedir/text()"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </tbody>
    </table>
  </xsl:template>

  <!-- Template to generate a row in the table. Override to redefine. -->
  <xsl:template name="ada.asap.results.doentry">
    <xsl:param name="rowPosition"/>
    <xsl:param name="withOrdinal"/>
    <xsl:param name="ordinal"/>
    <xsl:param name="userInfo"/>
    <xsl:param name="date"/>
    <xsl:param name="subDir"/>

    <xsl:for-each select="$testUnits/name">
      <xsl:variable name="testName" select="."/>
      <xsl:variable name="resultInfo"
        select="document(concat($subDir, '/', text(), '/', 'bench.xml'))/results"/>
      <tr class="submissionresult">
        <xsl:if test="position() = 1">
          <xsl:if test="$withOrdinal = 'yes'">
            <td style="border: 1px solid black" align="center">
              <xsl:attribute name="rowspan">
                <xsl:value-of select="count($testUnits/name)"/>
              </xsl:attribute>
              <xsl:value-of select="$ordinal"/>
            </td>
          </xsl:if>
          <td style="border: 1px solid black">
            <xsl:attribute name="rowspan">
              <xsl:value-of select="count($testUnits/name)"/>
            </xsl:attribute>
            <xsl:choose>
              <xsl:when test="$userInfo">
                <xsl:call-template name="ada.asap.results.user.info.cell">
                  <xsl:with-param name="subDir" select="$subDir"/>
                  <xsl:with-param name="userInfo" select="$userInfo"/>
                  <xsl:with-param name="date" select="$date"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:choose>
                  <xsl:when test="$profile.lang = 'en'">Reference</xsl:when>
                  <xsl:otherwise>Referencia</xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </xsl:if>
        <xsl:if test="count($testUnits/name) > 1">
          <td style="border: 1px solid black" align="center">
            <xsl:copy-of select="$testName"/>
          </td>
        </xsl:if>

        <!--
        <xsl:for-each select="$resultInfo/*">
          <xsl:if test="name() != 'rank'">
            <td style="border: 1px solid black" align="center">
              <xsl:if test="position() = 1">
                <xsl:attribute name="colspan">
                  <xsl:value-of select="1 + count($columns/*) 
                                        - count($resultInfo/*)"/>
                </xsl:attribute>
              </xsl:if>
              <xsl:copy-of select="./*"/>
            </td>
          </xsl:if>
        </xsl:for-each>
        -->

        <xsl:for-each select="$columns/column">
          <xsl:variable name="cname" select="@ref"/>
          <xsl:element name="td">
            <xsl:attribute name="style">border: 1px solid black</xsl:attribute>
            <xsl:choose>
              <xsl:when test="@align">
                <xsl:attribute name="align"><xsl:value-of select="@align"/></xsl:attribute>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="align">center</xsl:attribute>
              </xsl:otherwise>
            </xsl:choose>
            <!-- <xsl:value-of select="$cname"/> -->
            <xsl:copy-of select="$resultInfo/*[name() = $cname]/node()"/>
          </xsl:element>
        </xsl:for-each>

      </tr>
    </xsl:for-each>
  </xsl:template>

  <!-- Template to generate table head. Override to redefine -->
  <xsl:template name="ada.asap.results.dotable.head">
    <xsl:param name="withOrdinal">no</xsl:param>
    <xsl:param name="srcData"/>
    <tr class="blue1head">
      <xsl:if test="$withOrdinal = 'yes'">
        <th>N</th>
      </xsl:if>
      <th style="border: 1px solid black">
        <xsl:choose>
          <xsl:when test="$profile.lang = 'en'">Author(s) and date of last submission</xsl:when>
          <xsl:otherwise>Autor(es) y fecha de última entrega</xsl:otherwise>
        </xsl:choose>
      </th>
      <xsl:if test="count($testUnits/name) > 1">
        <th style="border: 1px solid black">
          <xsl:choose>
            <xsl:when test="$profile.lang = 'en'">Exercise</xsl:when>
            <xsl:otherwise>Ejercicio</xsl:otherwise>
          </xsl:choose>
        </th>
      </xsl:if>
      <xsl:for-each select="$columns/column">
        <th style="border: 1px solid black">
          <xsl:choose>
            <xsl:when test="./node() != ''">
              <xsl:copy-of select="node()"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@ref"/>
            </xsl:otherwise>
          </xsl:choose>
        </th>
      </xsl:for-each>
    </tr>
  </xsl:template>

  <!-- Template to put the User Info in a cell. Override to redefine -->
  <xsl:template name="ada.asap.results.user.info.cell">
    <xsl:param name="subDir"/>
    <xsl:param name="userInfo"/>
    <xsl:param name="date"/>
    <table style="border:0" align="left">
      <xsl:for-each select="$userInfo/user">
        <tr>
          <td>
            <xsl:if test="firstname and lastname">
              <xsl:copy-of select="firstname/node()"/>
              <xsl:text> </xsl:text>
              <xsl:copy-of select="lastname/node()"/>
            </xsl:if>
          </td>
        </tr>
      </xsl:for-each>
      <tr>
        <td>(<xsl:value-of select="$date"/>)</td>
      </tr>
    </table>
  </xsl:template>
</xsl:stylesheet>
