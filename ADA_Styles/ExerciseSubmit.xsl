<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0" exclude-result-prefixes="exsl xi str">
  
  <xsl:import href="ExerciseSubmitParams.xsl"/>

  <xsl:import href="HeadTail.xsl"/>
  <xsl:import href="CountDown.xsl"/>
  <xsl:import href="HeaderLinks.xsl"/>

  <!-- Ignore the submit elements -->
  <xsl:import href="SubmitIgnore.xsl"/>

  <!-- Lab is supposed to be a chapter -->
  <xsl:template match="chapter">
    <div class="narrowcontent">
      <!-- Title if present -->
      <xsl:if test="title/text() != ''">
        <h2 class="head-center"><xsl:apply-templates select="title/node()"/></h2>
      </xsl:if>

      <!-- Insert a header with the deadline if present in the document -->
      <xsl:if test="(note[@condition = 'AdminInfo']/para[@condition =
                    'handindate']/text() != '') and
                    ($solutions.include.guide != 'yes')">
        <h2 class="head-center">
          <xsl:choose>
            <xsl:when test="$profile.lang='en'">
              Submission Deadline:
            </xsl:when>
            <xsl:otherwise>
              Fecha de entrega: 
            </xsl:otherwise>
          </xsl:choose>
          <xsl:apply-templates
            select="note[@condition='AdminInfo']/para[@condition =
                    'handindate']/node()"/>
        </h2>
        <hr class="head-center"/>
      </xsl:if>

      <div class="noprint head-center">
        <xsl:if
          test="(note[@condition = 'AdminInfo']/para[@condition =
                'handinlink']) and 
                ($solutions.include.guide != 'yes')">
          <p>
            <!--
            <xsl:choose>
              <xsl:when test="$exercisesubmit.submission.page != ''">
                <xsl:copy-of select="$exercisesubmit.submission.page.url"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:choose>
                  <xsl:when test="$profile.lang='en'">
                    <b>Submission Page: </b> 
                  </xsl:when>
                  <xsl:otherwise>
                    <b>Página de entrega: </b> 
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:element name="a">
              <xsl:attribute name="href">
                <xsl:value-of select="note[@condition =
                                      'AdminInfo']/para[@condition =
                                      'handinlink']/text()"/> 
              </xsl:attribute>
              <xsl:value-of select="note[@condition =
                                    'AdminInfo']/para[@condition =
                                    'handinlink']/text()"/> 
            </xsl:element>.
            -->
            <xsl:apply-templates 
              select="note[@condition = 'AdminInfo']/para[@condition =
                      'handinlink']/node()"/>
          </p>
        </xsl:if>

        <!-- Insert countdown here -->
        <xsl:if
          test="note[@condition='AdminInfo']/para[@condition =
                'deadline.format']/text()">
          <xsl:variable name="deadlineparts">
            <tokens xmlns="">
              <xsl:copy-of
                select="str:tokenize(normalize-space(note[@condition =
                        'AdminInfo']/para[@condition =
                        'deadline.format']/text()), ' /')" />
            </tokens>
          </xsl:variable>
          <p>
            <xsl:call-template name="ada.page.countdown.insert">
              <xsl:with-param name="countdown.year">
                <xsl:value-of
                  select="exsl:node-set($deadlineparts)/tokens/token[position()
                          = 4]/text()"/>
              </xsl:with-param>
              <xsl:with-param name="countdown.month">
                <xsl:value-of
                  select="exsl:node-set($deadlineparts)/tokens/token[position()
                          = 3]/text()"/>
              </xsl:with-param>
              <xsl:with-param name="countdown.day">
                <xsl:value-of
                  select="exsl:node-set($deadlineparts)/tokens/token[position()
                          = 2]/text()"/>
              </xsl:with-param>
              <xsl:with-param name="countdown.hour">
                <xsl:value-of
                  select="exsl:node-set($deadlineparts)/tokens/token[position()
                          = 5]/text()"/>
              </xsl:with-param>
              <xsl:with-param name="countdown.minute">
                <xsl:value-of
                  select="exsl:node-set($deadlineparts)/tokens/token[position()
                          = 6]/text()"/>
              </xsl:with-param>
            </xsl:call-template>
          </p>
        </xsl:if>
        <xsl:if
          test="((note[@condition='AdminInfo']/para[@condition='handinlink']/text()
                != '') and ($solutions.include.guide != 'yes')) or
                (note[@condition='AdminInfo']/para[@condition =
                'deadline.format']/text())">
          <hr class="head-center"/>
        </xsl:if>
      </div>
      
      <xsl:if test="$exercisesubmit.include.toc = 'yes'">
        <table style="border:0" cellspacing="0" cellpadding="2" align="center">
          <tr>
            <td><xsl:call-template name="section.toc" mode="toc"/></td>
          </tr>
        </table>
        <hr align="center"/>
      </xsl:if>
      
      <xsl:call-template name="ada.insert.header.links"/>
      
      <table width="97%" style="border:0" cellspacing="0" cellpadding="2" 
        align="center">
        <tr>
          <td>
            <xsl:apply-templates/>
          </td>
        </tr>
      </table>
    </div>
  </xsl:template>
  
  <xsl:template match="note[@condition = 'AdminInfo']"/>

  <!-- skip entirely processing of the submit sections -->
  <xsl:template match="section[@condition='submit']|note[@condition='submit']"/>
  <xsl:template match="note[@condition='text.before.author.box']"/>

  <!-- Prevent these sections from appearing in TOC -->
  <xsl:template match="section[@condition='submit']"         mode="toc" />

</xsl:stylesheet>
