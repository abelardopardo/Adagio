<?xml version="1.0" encoding="UTF-8"?>

<!--
  Copyright (C) 2008 Carlos III University of Madrid
  This file is part of Adagio: Agile Distributed Authoring Integrated Toolkit

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
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="exsl" version="1.0">

  <xsl:param
    name="adagio.fm.code">freemind.main.FreeMindApplet.class</xsl:param>
  <xsl:param name="adagio.fm.archive">freemind.jar</xsl:param>
  <xsl:param name="adagio.fm.width">100%</xsl:param>
  <xsl:param name="adagio.fm.height">100%</xsl:param>
  <xsl:param
    name="adagio.fm.type">application/x-java-applet;version=1.4</xsl:param>
  <xsl:param name="adagio.fm.scriptable">false</xsl:param>
  <xsl:param
    name="adagio.fm.modes">freemind.modes.browsemode.BrowseMode</xsl:param>
  <xsl:param name="adagio.fm.browsemode_initial_map">./YOURFILE.mm</xsl:param>
  <xsl:param name="adagio.fm.initial_mode">Browse</xsl:param>
  <xsl:param
    name="adagio.fm.selection_method">selection_method_direct</xsl:param>

  <xsl:template match="para[@condition = 'adagio.fm.browser']">
    <!-- Take the value given in phrase, or the default value for all 10
    parameters -->
    <xsl:variable name="fm.code">
      <xsl:choose>
	<xsl:when test="phrase[@condition = 'fm.code']">
	  <xsl:value-of select="phrase[@condition = 'fm.code']"/>
	</xsl:when>
	<xsl:otherwise><xsl:value-of select="$adagio.fm.code"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="fm.archive">
      <xsl:choose>
	<xsl:when test="phrase[@condition = 'fm.archive']">
	  <xsl:value-of select="phrase[@condition = 'fm.archive']"/>
	</xsl:when>
	<xsl:otherwise><xsl:value-of
	select="$adagio.fm.archive"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="fm.width">
      <xsl:choose>
	<xsl:when test="phrase[@condition = 'fm.width']">
	  <xsl:value-of select="phrase[@condition = 'fm.width']"/>
	</xsl:when>
	<xsl:otherwise><xsl:value-of select="$adagio.fm.width"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="fm.height">
      <xsl:choose>
	<xsl:when test="phrase[@condition = 'fm.height']">
	  <xsl:value-of select="phrase[@condition = 'fm.height']"/>
	</xsl:when>
	<xsl:otherwise><xsl:value-of select="$adagio.fm.height"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="fm.type">
      <xsl:choose>
	<xsl:when test="phrase[@condition = 'fm.type']">
	  <xsl:value-of select="phrase[@condition = 'fm.type']"/>
	</xsl:when>
	<xsl:otherwise><xsl:value-of select="$adagio.fm.type"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="fm.scriptable">
      <xsl:choose>
	<xsl:when test="phrase[@condition = 'fm.scriptable']">
	  <xsl:value-of select="phrase[@condition = 'fm.scriptable']"/>
	</xsl:when>
	<xsl:otherwise><xsl:value-of
	select="$adagio.fm.scriptable"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="fm.modes">
      <xsl:choose>
	<xsl:when test="phrase[@condition = 'fm.modes']">
	  <xsl:value-of select="phrase[@condition = 'fm.modes']"/>
	</xsl:when>
	<xsl:otherwise><xsl:value-of select="$adagio.fm.modes"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="fm.browsemode_initial_map">
      <xsl:choose>
	<xsl:when test="phrase[@condition = 'fm.browsemode_initial_map']">
	  <xsl:value-of select="phrase[@condition =
				'fm.browsemode_initial_map']"/>
	</xsl:when>
	<xsl:otherwise><xsl:value-of
	select="$adagio.fm.browsemode_initial_map"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="fm.initial_mode">
      <xsl:choose>
	<xsl:when test="phrase[@condition = 'fm.initial_mode']">
	  <xsl:value-of select="phrase[@condition = 'fm.initial_mode']"/>
	</xsl:when>
	<xsl:otherwise><xsl:value-of
	select="$adagio.fm.initial_mode"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="fm.selection_method">
      <xsl:choose>
	<xsl:when test="phrase[@condition = 'fm.selection_method']">
	  <xsl:value-of select="phrase[@condition = 'fm.selection_method']"/>
	</xsl:when>
	<xsl:otherwise><xsl:value-of
	select="$adagio.fm.selection_method"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <applet>
      <xsl:attribute name="code"><xsl:value-of
      select="$fm.code"/></xsl:attribute>
      <xsl:attribute name="archive"><xsl:value-of
      select="fm.archive"/></xsl:attribute>
      <xsl:attribute name="eidth"><xsl:value-of
      select="fm.width"/></xsl:attribute>
      <xsl:attribute name="height"><xsl:value-of
      select="fm.height"/></xsl:attribute>
      <param>
	<xsl:attribute name="name">type</xsl:attribute>
	<xsl:attribute name="value"><xsl:value-of
	select="$fm.type"/></xsl:attribute>
      </param>
      <param>
	<xsl:attribute name="name">scriptable</xsl:attribute>
	<xsl:attribute name="value"><xsl:value-of
	select="$fm.scriptable"/></xsl:attribute>
      </param>
      <param>
	<xsl:attribute name="name">modes</xsl:attribute>
	<xsl:attribute name="value"><xsl:value-of
	select="$fm.modes"/></xsl:attribute>
      </param>
      <param>
	<xsl:attribute name="name">browsemode_initial_map</xsl:attribute>
	<xsl:attribute name="value"><xsl:value-of
	select="$fm.browsemode_initial_map"/></xsl:attribute>
      </param>
      <param>
	<xsl:attribute name="name">initial_mode</xsl:attribute>
	<xsl:attribute name="value"><xsl:value-of
				      select="$fm.initial_mode"/></xsl:attribute>
      </param>
      <param>
	<xsl:attribute name="name">selection_mode</xsl:attribute>
	<xsl:attribute
	  name="value"><xsl:value-of
	  select="$fm.selection_mode"/></xsl:attribute>
      </param>
    </applet>
  </xsl:template>
</xsl:stylesheet>
