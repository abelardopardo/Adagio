<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
  xmlns:suwl="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.UnwrapLinks"
  version="1.0" exclude-result-prefixes="exsl str xi suwl itunes">

  <xsl:import 
     href="file:///usr/share/sgml/docbook/stylesheet/xsl/nwalsh/html/profile-docbook.xsl"/>
  <xsl:import 
     href="file:///usr/share/sgml/docbook/stylesheet/xsl/nwalsh/xhtml/manifest.xsl"/>
  <xsl:import href="es-modify.xsl"/>

  <xsl:output method="xml" indent="yes" encoding="UTF-8" />

  <xsl:param name="title.string" select="'Your title goes here'"/>
  <xsl:param name="thumb.url"/>
  <xsl:param name="gadget.height"/>
  <xsl:param name="screenshot.url"/>
  <xsl:param name="author.string"/>
  <xsl:param name="google.analytics.gadgetpath"/>
  <xsl:param name="google.analytics.account"/>

  <xsl:template match="/">
    <Module>
      <ModulePrefs scrolling="true">
        <xsl:attribute name="title"><xsl:value-of
        select="$title.string"/></xsl:attribute>
        <xsl:if test="$gadget.height">
          <xsl:attribute name="height"><xsl:value-of
          select="$gadget.height"/></xsl:attribute>
        </xsl:if>
        <xsl:if test="$thumb.url">
          <xsl:attribute name="thumbnail"><xsl:value-of
          select="$thumb.url"/></xsl:attribute>
        </xsl:if>
        <xsl:if test="$screenshot.url">
          <xsl:attribute name="screenshot"><xsl:value-of
          select="$screenshot.url"/></xsl:attribute>
        </xsl:if>
        <xsl:if test="$img.src.path">
          <xsl:attribute name="title_url"><xsl:value-of
          select="$img.src.path"/></xsl:attribute>
        </xsl:if>
        <xsl:if test="$google.analytics.account">
          <Require feature="analytics"/>
        </xsl:if>
      </ModulePrefs>
      <Content type="html">
        <xsl:text
          disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
        <xsl:if test="$google.analytics.account">
          <script>
            // Track this gadget using Google Analytics.
            _IG_Analytics("<xsl:value-of
            select="$google.analytics.account"/>", 
            "<xsl:value-of
            select="$google.analytics.gadgetpath"/>");
          </script>
        </xsl:if>
        <xsl:apply-templates />
        <xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
      </Content>
    </Module>
  </xsl:template>

  <xsl:template match="ulink" name="ulink">
    <xsl:variable name="link">
      <a>
        <xsl:if test="@id">
          <xsl:attribute name="id">
            <xsl:value-of select="@id"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:attribute name="href"><xsl:if
          test="not(starts-with(@url, 'http:'))  and 
                not(starts-with(@url, 'https:')) and 
                not(starts-with(@url, 'irc:'))"><xsl:value-of
        select="$img.src.path"/></xsl:if><xsl:value-of select="@url"/></xsl:attribute>
        <xsl:if test="$ulink.target != ''">
          <xsl:attribute name="target">
            <xsl:value-of select="$ulink.target"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="count(child::node())=0">
            <xsl:value-of select="@url"/> 
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
      </a>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="function-available('suwl:unwrapLinks')">
        <xsl:copy-of select="suwl:unwrapLinks($link)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$link"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
