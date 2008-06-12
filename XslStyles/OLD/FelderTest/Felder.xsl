<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:exsl="http://exslt.org/common" 
  xmlns="http://www.w3.org/1999/xhtml" 
  exclude-result-prefixes="exsl" version="1.0">

  <xsl:import href="../AsapAuthorBox.xsl"/>

  <xsl:param name="felder.processor"/>
  <xsl:param name="felder.sublabel"/>
  <xsl:param name="felder.anonymous" select="'yes'"/>
  <xsl:param name="question.number" select="'no'"/>

  <xsl:template match="qandaset">
    <xsl:element name="form">
      <xsl:attribute name="name">form1</xsl:attribute>
      <xsl:attribute name="method">post</xsl:attribute>
      <xsl:attribute name="action">
        <xsl:choose>
          <xsl:when test="para[@condition='processor']">
            <xsl:value-of select="para[@condition='processor']/text()"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$felder.processor"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="enctype">multipart/form-data</xsl:attribute>

      <xsl:if test="$felder.sublabel != ''">
        <input type="hidden" name="felder.sublabel">
          <xsl:attribute name="value"><xsl:value-of 
          select="$felder.sublabel"/></xsl:attribute>
        </input>
      </xsl:if>

      <xsl:if test="$felder.anonymous != 'yes'">
        <xsl:call-template name="asap.author.box"/>
        <br />
      </xsl:if>

      <table style="border: 1px solid black; border-collapse: collapse;pageBreakInside: false" 
        align="center" cellspacing="5"
        cellpadding="5">
        <xsl:apply-templates/>
      </table>

      <p><center><input value="Enviar" type="submit"></input></center></p>
    </xsl:element>
  </xsl:template>

  <xsl:template match="qandaentry">
    <tr>
      <td>
        <xsl:if test="$question.number = 'yes'">
          <b>
            <xsl:choose>
              <xsl:when test="$profile.lang = 'en'">Question</xsl:when>
              <xsl:otherwise>Pregunta</xsl:otherwise>
            </xsl:choose>
            <xsl:text> </xsl:text>
            <xsl:value-of
              select="count(preceding-sibling::qandaentry) + 1"/>
          </b>
        </xsl:if>
        <xsl:apply-templates select="question/node()"/>
      </td>
      <td>
        <p>
          <input type="radio" value="a">
            <xsl:attribute name="name"><xsl:value-of
            select="@id"/></xsl:attribute>
            <xsl:apply-templates select="answer[position() = 1]/para/text()"/>
          </input>
        </p>
        <p>
          <input type="radio" value="b">
            <xsl:attribute name="name"><xsl:value-of
            select="@id"/></xsl:attribute> 
            <xsl:apply-templates select="answer[position() = 2]/para/text()"/>
          </input>
        </p>
      </td>
    </tr>
  </xsl:template>
</xsl:stylesheet>
