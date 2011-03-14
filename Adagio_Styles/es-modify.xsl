<?xml version="1.0" encoding="ISO-8859-1"?>

<!--
  Copyright (C) 2008 Carlos III University of Madrid
  This file is part of the Adagio: Agile Distributed Authoring Toolkit

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
  version="1.0" exclude-result-prefixes="exsl">
  <!-- Taken from common/es.xml -->
  <xsl:param name="local.l10n.xml" select="document('')"/>

  <!--
  <l:i18n xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0";>
    <l:l10n language="en" english-language-name="English">
      <l:template name="startquote" text="&#8216;"/>
      <l:template name="endquote" text="&#8217;"/>
      <l:template name="nestedstartquote" text="&#8220;"/>
      <l:template name="nestedendquote" text="&#8221;"/>
    </l:l10n>
  </l:i18n>
  -->

  <l:i18n xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0">
    <l:l10n xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0"
      language="es" english-language-name="Spanish">
      <l:context name="xref-number">
        <l:template name="answer"        text="R:&#160;%n"/>
        <l:template name="appendix"      text="ap&#233;ndice&#160;%n"/>
        <l:template name="bridgehead"    text="secci&#243;n&#160;%n"/>
        <l:template name="chapter"       text="cap&#237;tulo&#160;%n"/>
        <l:template name="equation"      text="ecuaci&#243;n&#160;%n"/>
        <l:template name="example"       text="ejemplo&#160;%n"/>
        <l:template name="figure"        text="figura&#160;%n"/>
        <l:template name="part"          text="parte&#160;%n"/>
        <l:template name="procedure"     text="procedimiento&#160;%n"/>
        <l:template name="productionset" text="producci&#243;n&#160;%n"/>
        <l:template name="qandadiv"      text="P y R&#160;%n"/>
        <l:template name="qandaentry"    text="P:&#160;%n"/>
        <l:template name="question"      text="P:&#160;%n"/>
        <l:template name="sect1"         text="secci&#243;n&#160;%n"/>
        <l:template name="sect2"         text="secci&#243;n&#160;%n"/>
        <l:template name="sect3"         text="secci&#243;n&#160;%n"/>
        <l:template name="sect4"         text="secci&#243;n&#160;%n"/>
        <l:template name="sect5"         text="secci&#243;n&#160;%n"/>
        <l:template name="section"       text="secci&#243;n&#160;%n"/>
        <l:template name="table"         text="tabla&#160;%n"/>
      </l:context>
      <l:context name="xref-number-and-title">
        <l:template name="appendix"      text="ap&#233;ndice&#160;%n, %t"/>
        <l:template name="bridgehead"    text="secci&#243;n&#160;%n, &#8220;%t&#8221;"/>
        <l:template name="chapter"       text="cap&#237;tulo&#160;%n, %t"/>
        <l:template name="equation"      text="ecuaci&#243;n&#160;%n, &#8220;%t&#8221;"/>
        <l:template name="example"       text="ejemplo&#160;%n, &#8220;%t&#8221;"/>
        <l:template name="figure"        text="figura&#160;%n, &#8220;%t&#8221;"/>
        <l:template name="part"          text="parte&#160;%n, &#8220;%t&#8221;"/>
        <l:template name="procedure"     text="procedimiento&#160;%n, &#8220;%t&#8221;"/>
        <l:template name="productionset" text="producci&#243;n&#160;%n, &#8220;%t&#8221;"/>
        <l:template name="qandadiv"      text="P y R&#160;%n, &#8220;%t&#8221;"/>
        <l:template name="refsect1"      text="secci&#243;n llamada &#8220;%t&#8221;"/>
        <l:template name="refsect2"      text="secci&#243;n llamada &#8220;%t&#8221;"/>
        <l:template name="refsect3"      text="secci&#243;n llamada &#8220;%t&#8221;"/>
        <l:template name="refsection"    text="secci&#243;n llamada &#8220;%t&#8221;"/>
        <l:template name="sect1"         text="secci&#243;n&#160;%n, &#8220;%t&#8221;"/>
        <l:template name="sect2"         text="secci&#243;n&#160;%n, &#8220;%t&#8221;"/>
        <l:template name="sect3"         text="secci&#243;n&#160;%n, &#8220;%t&#8221;"/>
        <l:template name="sect4"         text="secci&#243;n&#160;%n, &#8220;%t&#8221;"/>
        <l:template name="sect5"         text="secci&#243;n&#160;%n, &#8220;%t&#8221;"/>
        <l:template name="section"       text="secci&#243;n&#160;%n, &#8220;%t&#8221;"/>
        <l:template name="simplesect"    text="secci&#243;n llamada &#8220;%t&#8221;"/>
        <l:template name="table"         text="tabla&#160;%n, &#8220;%t&#8221;"/>
      </l:context>
    </l:l10n>
  </l:i18n>

</xsl:stylesheet>

