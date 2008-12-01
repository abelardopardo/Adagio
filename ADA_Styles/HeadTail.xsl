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
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0" exclude-result-prefixes="exsl xi str">
  
  <!-- Brings in all the default values -->
  <xsl:import href="Params.xsl"/>

  <xsl:import href="RssParams.xsl"/>

  <xsl:import href="DocbookProfile.xsl"/>

  <xsl:import href="DublinCore.xsl"/>

  <!-- Template to ignore the chapter/section info with rss.info condition -->
  <xsl:import href="RssIgnore.xsl"/>

  <!-- Invoke the templates to process professor guide and solution -->
  <xsl:import href="PguideSection.xsl"/>
  <xsl:import href="SolutionSection.xsl"/>

  <xsl:output method="xml" indent="yes" encoding="UTF-8"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"/>

  <!-- Docbook XSL parameters needed generate strict XHTML -->
  <xsl:param name="css.decoration">0</xsl:param>
  <xsl:param name="html.longdesc">0</xsl:param>
  <xsl:param name="ulink.target" />
  <xsl:param name="use.viewport">0</xsl:param>
  <xsl:param name="generate.id.attributes">1</xsl:param>

  <!-- Propagate the role attribute as class element when allowed -->
  <xsl:param name="emphasis.propagates.style">1</xsl:param>
  <xsl:param name="entry.propagates.style">1</xsl:param>
  <xsl:param name="para.propagates.style">1</xsl:param>
  <xsl:param name="phrase.propagates.style">1</xsl:param>

  <!-- This one for sure is needed in all documents -->
  <xsl:param name="xref.with.number.and.title" select="'0'"/>

  <xsl:template name="body.attributes">
    <xsl:variable name="default_status">
      <xsl:apply-templates
        select="/" mode="object.title.markup.textonly"/>
    </xsl:variable>

    <!-- Insert the onload attribute with the window.defaultStatus value -->
    <xsl:if test="$default_status and $default_status != ''">
      <xsl:attribute name="onload">window.defaultStatus='<xsl:value-of
      select="$default_status"/>';</xsl:attribute>
    </xsl:if>

    <!-- Copy the id attribute from the root element -->
    <xsl:if test="/*[@id] and /*[@id] != ''">
      <xsl:attribute name="id"><xsl:value-of select="/*/@id"/></xsl:attribute>
    </xsl:if>
  </xsl:template>

  <!-- User HEAD content -->
  <xsl:template name="user.head.content">

    <!-- Insert Dublin Core Metadata -->
    <xsl:call-template name="ada.dc.insert.meta.elements"/>

    <!-- FAVICON -->
    <xsl:if test="$ada.course.icon">
      <link rel="shortcut icon">
        <xsl:attribute name="href"><xsl:value-of
        select="$ada.course.home"/><xsl:value-of
        select="$ada.course.icon"/></xsl:attribute>
        <xsl:attribute name="type"><xsl:value-of 
        select="$ada.course.icon.type"/></xsl:attribute>
      </link>
    </xsl:if>

    <!-- Author Meta Element -->
    <xsl:variable name="author_string">
      <xsl:choose>
        <xsl:when test="/*/*/author">
          <xsl:call-template name="person.name"/>
        </xsl:when>
        <xsl:when test="/*/*/authorgroup">
          <xsl:call-template name="person.name.list">
            <xsl:with-param name="person.list"
              select="/*/*/authorgroup/author"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$ada.page.author">
          <xsl:value-of select="$ada.page.author"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="$author_string and $author_string != ''">
      <xsl:element name="meta">
        <xsl:attribute name="name">Author</xsl:attribute>
        <xsl:attribute name="content">
          <xsl:value-of select="string($author_string)"/>
        </xsl:attribute>
      </xsl:element>
    </xsl:if>

    <!-- Stick the javascript for the flash player -->
    <xsl:if test="$ada.flv.player.js.file and ($ada.flv.player.js.file != '')
                  and /*/para[@condition = 'ada.flv.player']">
      <script type="text/javascript" language="JavaScript">
        <xsl:attribute name="src"><xsl:value-of
        select="$ada.flv.player.js.file"/></xsl:attribute>
      </script>
    </xsl:if>

    <!-- If refresh rate has been given, include it -->
    <xsl:if test="$ada.page.refresh.rate and ($ada.page.refresh.rate != '')">
      <meta http-equiv="refresh">
        <xsl:attribute name="content"><xsl:value-of 
        select="$ada.page.refresh.rate"/></xsl:attribute>
      </meta>
    </xsl:if>

    <!-- CSS styles -->
    <xsl:if test="$ada.page.cssstyle.url">
      <meta http-equiv="Content-Style-Type" content="text/css"/>
      <xsl:for-each select="str:tokenize($ada.page.cssstyle.url, ',')">
        <link rel="stylesheet" type="text/css">
          <xsl:attribute name="href"><xsl:value-of
          select="$ada.course.home"/><xsl:value-of
          select="."/></xsl:attribute>
        </link>
      </xsl:for-each>
    </xsl:if>
    <!-- FIXME: Instead of the link element, include code similar to:
         <style type="text/css" media="MMMM">@import "blah.css";</style>
         -->

    <!-- Insert the reference to the RSS channel if given -->
    <xsl:if test="$ada.rss.channel.url and ($ada.rss.channel.url != '')">
      <link rel="alternate" type="application/rss+xml" title="rss">
        <xsl:attribute name="href"><xsl:value-of
        select="$ada.rss.channel.url"/></xsl:attribute>
      </link>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="user.header.content">
    <xsl:param name="node" select="."/>
    
    <xsl:comment> ######## Beginning of title ######## </xsl:comment>
    <xsl:if test="$ada.page.head.left.logo or $ada.page.head.center.top.logo 
                  or $ada.page.head.right.logo or $ada.page.head.center.bottom">
      <div id="ada_logo_headers">
        <div id="ada_logo_headers_left">
          <a>
            <xsl:if test="$ada.page.head.left.logo.url">
              <xsl:attribute name="href"><xsl:value-of 
              select="$ada.page.head.left.logo.url"/></xsl:attribute>
            </xsl:if>
            <img id="ada_logo_headers_left_image">
              <xsl:if test="$ada.page.head.left.logo.alt">
                <xsl:attribute name="alt"><xsl:value-of 
                select="$ada.page.head.left.logo.alt"/></xsl:attribute>
              </xsl:if>
              <xsl:attribute name="src"><xsl:value-of
              select="$ada.course.home"/><xsl:value-of 
              select="$ada.page.head.left.logo"/></xsl:attribute>
            </img>
          </a>
        </div>

        <div id="ada_logo_headers_center_box">
          <div id="ada_logo_headers_center_box_top">
            <a>
              <xsl:if test="$ada.page.head.center.top.logo.url">
                <xsl:attribute name="href"><xsl:value-of 
                select="$ada.page.head.center.top.logo.url"/></xsl:attribute>
              </xsl:if>
              <img id="ada_logo_headers_top_center_image">
                <xsl:if test="$ada.page.head.center.top.logo.alt">
                  <xsl:attribute name="alt"><xsl:value-of 
                  select="$ada.page.head.center.top.logo.alt"/></xsl:attribute>
                </xsl:if>
                <xsl:attribute name="src"><xsl:value-of
                select="$ada.course.home"/><xsl:value-of
                select="$ada.page.head.center.top.logo"/></xsl:attribute>
              </img>
            </a>
          </div>

          <div id="ada_logo_headers_center_box_bottom">
            <xsl:if test="$ada.page.head.center.bottom and
                          $ada.page.head.center.bottom != ''">
              <div id="ada_logo_headers_center_box_bottom_text">
                <xsl:copy-of
                  select="exsl:node-set($ada.page.head.center.bottom)"/>
              </div>
            </xsl:if>
          </div>
        </div>

        <div id="ada_logo_headers_right">
          <a>
            <xsl:if test="$ada.page.head.right.logo.url">
              <xsl:attribute name="href"><xsl:value-of 
              select="$ada.page.head.right.logo.url"/></xsl:attribute>
            </xsl:if>
            <img id="ada_logo_headers_right_image">
              <xsl:if test="$ada.page.head.right.logo.alt">
                <xsl:attribute name="alt"><xsl:value-of 
                select="$ada.page.head.right.logo.alt"/></xsl:attribute>
              </xsl:if>
              <xsl:attribute name="src"><xsl:value-of
              select="$ada.course.home"/><xsl:value-of 
              select="$ada.page.head.right.logo"/></xsl:attribute>
            </img>
          </a>
        </div>

      </div>
    </xsl:if>
    
    <!-- Big title -->
    <xsl:if test="$ada.page.head.bigtitle = 'yes'">
      <div id="ada_page_head_bigtitle">
        <div id="ada_ggadgetlink">
          Google Gadget
          <xsl:call-template name="ggadgetlink"/>
        </div>
        
        <xsl:if test="$ada.course.name or ada.course.edition 
                      or ada.course.image">
          
          <div id="ada_course_name_edition_image">
            <xsl:if test="$ada.course.image">
              <div id="ada_course_image">
                <xsl:element name="img">
                  <xsl:if test="$ada.course.name">
                    <xsl:attribute name="alt"><xsl:value-of 
                    select="$ada.course.name"/></xsl:attribute>
                  </xsl:if>
                  <xsl:attribute name="style">border: 0;</xsl:attribute>
                  <xsl:attribute name="src"><xsl:value-of
                  select="$ada.course.home"/><xsl:value-of
                  select="$ada.course.image"/></xsl:attribute>
                </xsl:element>
              </div>
            </xsl:if>
            <div id="ada_course_name_edition">
              <!-- Big title course name -->
              <xsl:if test="$ada.course.name">
                <h1><xsl:value-of select="$ada.course.name"/></h1>
              </xsl:if>
              <xsl:if test="$ada.course.edition">
                <h4><xsl:value-of select="$ada.course.edition"/></h4>
              </xsl:if>
            </div>
          </div>          
        </xsl:if>
      </div>
    </xsl:if>
    <xsl:comment> ######## End of title ######## </xsl:comment>
  </xsl:template>
  
  <!-- Template processing the root. Need to overwrite to include div elements -->
  <xsl:template match="*" mode="process.root">
    <xsl:variable name="doc" select="self::*"/>
    
    <xsl:call-template name="user.preroot"/>
    <xsl:call-template name="root.messages"/>
    
    <html>
      <xsl:call-template name="language.attribute"/>
      <head>
        <xsl:call-template name="system.head.content">
          <xsl:with-param name="node" select="$doc"/>
        </xsl:call-template>
        <xsl:call-template name="head.content">
          <xsl:with-param name="node" select="$doc"/>
        </xsl:call-template>
        <xsl:call-template name="user.head.content">
          <xsl:with-param name="node" select="$doc"/>
        </xsl:call-template>
      </head>
      <body>
        <xsl:call-template name="body.attributes"/>
        <div id="body_container">
          <div id="user_header_content">
            <xsl:call-template name="user.header.content">
              <xsl:with-param name="node" select="$doc"/>
            </xsl:call-template>
          </div>
          <div id="main_content">
            <xsl:apply-templates select="."/>
          </div>
          <div id="user_footer_content">
            <xsl:call-template name="user.footer.content">
              <xsl:with-param name="node" select="$doc"/>
            </xsl:call-template>
          </div>
        </div>
      </body>
    </html>
    <xsl:value-of select="$html.append"/>
  </xsl:template>

  <!-- Footer-->
  <xsl:template name="user.footer.content">
    <div id="tailbox">
      <xsl:comment> ######## Beginning of Tail ######## </xsl:comment>
      <table cellspacing="2" cellpadding="2"
        style="border: 0; margin-left: auto; margin-right: auto">
        <tr>
          <td align="center">
            <small>
              <xsl:copy-of select="$ada.page.license.institution"/>
            </small>
          </td>
          <xsl:if test="$ada.page.license = 'yes'">
            <td align="center" valign="middle" rowspan="2">
              <a>
                <xsl:if test="$ada.page.license.url">
                  <xsl:attribute name="href"><xsl:value-of 
                  select="$ada.page.license.url"/></xsl:attribute>
                </xsl:if>
                <xsl:element name="img">
                  <xsl:attribute name="alt"><xsl:value-of 
                  select="$ada.page.license.alt"/></xsl:attribute>
                  <xsl:attribute name="style">border:0;</xsl:attribute>
                  <xsl:attribute name="src"><xsl:value-of
                  select="$ada.course.home"/><xsl:value-of 
                  select="$ada.page.license.logo"/></xsl:attribute>
                </xsl:element>
              </a>
            </td>
          </xsl:if>
        </tr>
        <xsl:if test="($ada.page.license = 'yes') and
                      $ada.page.license.name">
          <tr>
            <td align="center">
              <small>
                <xsl:choose>
                  <xsl:when test="$profile.lang='es'">
                    Material con licencia
                  </xsl:when>
                  <xsl:otherwise>
                    Work licensed under 
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:text> </xsl:text>
                <a rel="license">
                  <xsl:if test="$ada.page.license.url">
                    <xsl:attribute name="href"><xsl:value-of 
                    select="$ada.page.license.url"/></xsl:attribute>
                  </xsl:if>
                  <xsl:copy-of select="$ada.page.license.name"/>
                </a>
              </small>
            </td>
          </tr>
        </xsl:if>
      </table>
      
      <!-- Show the last modified attribute -->
      <xsl:if test="$ada.page.show.lastmodified = 'yes'">
        <p style="text-align: center; font-size: small; font-style: italic;">
          <xsl:choose>
            <xsl:when test="$profile.lang='es'">Última modificación:</xsl:when>
            <xsl:otherwise>Last Revision:</xsl:otherwise>
          </xsl:choose>
          <xsl:element name="script">
            <xsl:attribute name="type">text/javascript</xsl:attribute>
            <xsl:text>
              testdate = new Date(document.lastModified);
              testdate = testdate.toLocaleString();
              document.write(testdate)
            </xsl:text>
          </xsl:element>
        </p>
      </xsl:if>
      <xsl:comment> ######## End of Tail ######## </xsl:comment>
    </div>

    <!-- Insert Google Analytics snippet -->
    <xsl:if test="$ada.page.google.analytics.account">
      <script type="text/javascript">
        var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
        document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
      </script>
      <script type="text/javascript">
        var pageTracker = _gat._getTracker("<xsl:value-of select="$ada.page.google.analytics.account"/>");
        pageTracker._trackPageview();
      </script>
    </xsl:if>
  </xsl:template>

  <xsl:template name="ggadgetlink">
    <xsl:if test="$ada.page.google.gadget.url">
      <a>
        <xsl:attribute
          name="href">http://fusion.google.com/add?moduleurl=<xsl:value-of 
        select="$ada.page.google.gadget.url"/></xsl:attribute>
        <img style="border: 0"
          src="http://buttons.googlesyndication.com/fusion/add.gif">
          <xsl:attribute name="alt"><xsl:choose>
            <xsl:when 
              test="$profile.lang = 'es'">Añade un gadget a tu página personal en Google</xsl:when>
            <xsl:otherwise>Add a gadget to your personal page in Google</xsl:otherwise>
          </xsl:choose></xsl:attribute>
        </img>
      </a>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
