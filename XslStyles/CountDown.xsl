<?xml version="1.0" encoding="UTF-8"?>

<!-- $Id: HeadTail.xsl 334 2006-01-25 09:44:13Z abel $ -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  version="1.0" exclude-result-prefixes="exsl">
  
  <xsl:param name="countDownJS"/>

  <xsl:template name="countdown.insert">
    <xsl:param name="countdown.year"/>
    <xsl:param name="countdown.month"/>
    <xsl:param name="countdown.day"/>
    <xsl:param name="countdown.hour"/>
    <xsl:param name="countdown.minute"/>
    <xsl:if test="$countDownJS">
      <xsl:variable name="countDownDate">
        <xsl:value-of
          select="concat('20',$countdown.year,',',$countdown.month -1, 
                  ',', $countdown.day, ',', $countdown.hour, ',',
                  $countdown.minute, ',00')"/>
      </xsl:variable>
      <xsl:variable name="script.src">
        <xsl:value-of 
          select="concat('dateFuture = new Date(',
                  $countDownDate, ');')"/>
      </xsl:variable>
      <script type="text/javascript">
        <xsl:attribute name="src"><xsl:value-of
        select="$countDownJS"/></xsl:attribute>
      </script>
      <script type="text/javascript">
        <xsl:comment>
          <xsl:text>
          </xsl:text>
          <xsl:value-of select="$script.src"/>
          <xsl:text>
            //</xsl:text>
        </xsl:comment>
      </script>
      <span id="countbox">
        <xsl:if test="$profile.lang">
          <xsl:attribute name="lang">
            <xsl:value-of select="$profile.lang"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="$profile.lang='en'">
            <xsl:attribute name="class">Deadline in</xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="class">Faltan</xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
      </span>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
