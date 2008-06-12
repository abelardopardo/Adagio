<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0" exclude-result-prefixes="exsl str xi">
  
  <xsl:import href="HeadTail.xsl"/>

  <xsl:param name="asapdatatohtml.pagetitle" />
  <xsl:param name="asapdatatohtml.showanswertitle">0</xsl:param>
  <xsl:param name="asapdatatohtml.showglobalreview">0</xsl:param>

  <!-- Match on the template and recur on the reviews -->
  <xsl:template match="/submission">

    <xsl:if test="$asapdatatohtml.pagetitle">
      <h2 class="head-center">
        <xsl:copy-of select="$asapdatatohtml.pagetitle"/>
      </h2>
    </xsl:if>

    <xsl:apply-templates select="descendant::review"/>
  </xsl:template>

  <xsl:template match="review">
    <xsl:if test="remarks/text()">
      <xsl:choose>
        <xsl:when test="ancestor::answer">
          <!-- This is the case in which the review is part of an answer -->
          <xsl:if test="$asapdatatohtml.showanswertitle != 0">
            <p style="text-align: center">
              <xsl:choose>
                <xsl:when test="$profile.lang = 'en'">
                  Comments for  
                </xsl:when>
                <xsl:otherwise>
                  Comentarios para 
                </xsl:otherwise>
              </xsl:choose>
              <xsl:value-of
                select="ancestor::answer/@name"/>
            </p>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <!-- This is the case of a global review -->
          <xsl:if test="($asapdatatohtml.showanswertitle != 0) and
                        ($asapdatatohtml.showglobalreview = 1)">
            <p style="text-align: center">
              <xsl:choose>
                <xsl:when test="$profile.lang = 'en'">
                  Comments for the submission
                </xsl:when>
                <xsl:otherwise>
                  Comentarios de la entrega
                </xsl:otherwise>
              </xsl:choose>
              <xsl:value-of
                select="ancestor::answer/@name"/>
            </p>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
      <!-- Show table only if it is from ancestor or allowed by parameter -->
      <xsl:if test="ancestor::answer or ($asapdatatohtml.showglobalreview = 1)">
        <table cellspacing="0" cellpadding="10"
          style="border: 1px solid black; margin-right: auto; 
                 margin-left: auto;">
          <tr>
            <td>
              <pre width="80">
                <xsl:copy-of select="remarks/text()"/>
              </pre>
            </td>
          </tr>
        </table>
      </xsl:if>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
