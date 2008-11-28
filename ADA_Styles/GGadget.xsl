<?xml version="1.0" encoding="UTF-8"?>

<!--
  Copyright (C) 2008 Carlos III University of Madrid
  This file is part of the ADA: Agile Distributed Authoring Toolkit

  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License
  as published by the Free Software Foundation; either version 2
  of the License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor
  Boston, MA  02110-1301, USA.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
  xmlns:suwl="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.UnwrapLinks"
  version="1.0" exclude-result-prefixes="exsl str xi suwl itunes">

  <!-- Templates to process docbook. The HTML are included to avoid the doctype -->
  <xsl:import 
     href="http://docbook.sourceforge.net/release/xsl/current/html/profile-docbook.xsl"/>

  <!-- Template with all the customization parameters -->
  <xsl:import href="GGadgetParams.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no" indent="yes" encoding="UTF-8" />

  <xsl:template match="/">
    <Module>
      <ModulePrefs scrolling="true">
        <xsl:attribute name="title"><xsl:value-of
        select="$ada.ggadget.title"/></xsl:attribute>
        <xsl:if test="$ada.ggadget.height">
          <xsl:attribute name="height"><xsl:value-of
          select="$ada.ggadget.height"/></xsl:attribute>
        </xsl:if>
        <xsl:if test="$ada.ggadget.thumb.url">
          <xsl:attribute name="thumbnail"><xsl:value-of
          select="$ada.ggadget.thumb.url"/></xsl:attribute>
        </xsl:if>
        <xsl:if test="$ada.ggadget.screenshot.url">
          <xsl:attribute name="screenshot"><xsl:value-of
          select="$ada.ggadget.screenshot.url"/></xsl:attribute>
        </xsl:if>
        <xsl:if test="$ada.ggadget.site.url">
          <xsl:attribute name="title_url"><xsl:value-of
          select="$ada.ggadget.site.url"/></xsl:attribute>
        </xsl:if>
        <xsl:if test="$ada.page.google.analytics.account">
          <Require feature="analytics"/>
        </xsl:if>
      </ModulePrefs>
      <Content type="html">
        <xsl:text
          disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
        <xsl:if test="$ada.page.google.analytics.account">
          <script>
            // Track this gadget using Google Analytics.
            _IG_Analytics("<xsl:value-of
            select="$ada.page.google.analytics.account"/>", 
            "<xsl:value-of
            select="$ada.ggadget.google.analytics.gadgetpath"/>");
          </script>
        </xsl:if>

        <xsl:apply-templates select="$profiled-nodes/gadget"/>

        <xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
      </Content>
    </Module>
  </xsl:template>

  <xsl:template match="gadget">
    <xsl:if test="rss/channel/item[position() = 1]/link">
      <fieldset style="background-color: #EEEEEE">
        <legend>
          <xsl:choose>
            <xsl:when test="$profile.lang = 'en'">Latest Events</xsl:when>
            <xsl:otherwise>Últimos eventos</xsl:otherwise>
          </xsl:choose>
        </legend>
        <a target="_blank">
          <xsl:attribute name="href"><xsl:value-of 
          select="rss/channel/item[position()=1]/link/text()"
          /></xsl:attribute>
          <xsl:value-of
            select="rss/channel/item[position() = 1]/title/text()"/>
        </a>
      </fieldset>
    </xsl:if>
    <fieldset>
      <xsl:apply-templates select="$profiled-nodes/gadget/chapter/informaltable"/>
    </fieldset>
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
        select="$ada.ggadget.site.url"/></xsl:if><xsl:value-of select="@url"/></xsl:attribute>
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

  <xsl:template match="@fileref">
    <xsl:value-of select="$ada.ggadget.site.url"/><xsl:value-of 
    select="ancestor::*/ulink[@condition = 'itemlinkbase']/@url"/>/<xsl:value-of 
    select="."/>
  </xsl:template>

</xsl:stylesheet>
