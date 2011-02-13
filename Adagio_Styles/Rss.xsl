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
  xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
  xmlns:date="http://exslt.org/dates-and-times"
  extension-element-prefixes="date"
  version="1.0" exclude-result-prefixes="exsl">
  
  <!-- Templates to process docbook. The HTML are included to avoid the doctype -->
  <xsl:import 
     href="http://docbook.sourceforge.net/release/xsl/current/html/profile-docbook.xsl"/>

  <!-- Template with all the customization parameters -->
  <xsl:import href="RssParams.xsl"/>

  <xsl:import href="AdaProfile.xsl"/>

  <!-- The presence of CDATA in descriptions is to preserve any embedded
       HTML. Ugly but seen in other RSS feeds
  -->
  <xsl:output method="xml" omit-xml-declaration="no" encoding="UTF-8" indent="yes"/>

  <xsl:template match="/">
    <rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
      <channel>
        <xsl:if test="$ada.rss.self.atom.link != ''">
          <atom:link rel="self" type="application/rss+xml">
            <xsl:attribute name="href"><xsl:value-of
                select="$ada.rss.self.atom.link" />
            </xsl:attribute>
          </atom:link>
        </xsl:if>
        <xsl:if test="$ada.rss.time.to.live != ''">
          <ttl><xsl:value-of select="$ada.rss.time.to.live"/></ttl>
        </xsl:if>

        <xsl:if test="$ada.rss.title != ''">
          <title><xsl:value-of select="$ada.rss.title"/></title>
        </xsl:if>
        <xsl:if test="($ada.rss.title != '') and ($ada.rss.image.url != '') 
                      and ($ada.rss.main.site.url != '')"> 
          <image>
            <title><xsl:value-of select="$ada.rss.title"/></title>
            <url><xsl:value-of select="$ada.rss.image.url"/></url>
            <link><xsl:value-of select="$ada.rss.main.site.url"/></link>
            <xsl:if test="$ada.rss.image.desc != ''">
              <description><xsl:text
              disable-output-escaping="yes">&lt;![CDATA[</xsl:text><xsl:value-of
              select="$ada.rss.image.desc"/><xsl:text 
              disable-output-escaping="yes">]]&gt;</xsl:text></description>
            </xsl:if>
            <width><xsl:value-of select="$ada.rss.image.width"/></width>
            <height><xsl:value-of select="$ada.rss.image.height"/></height>
          </image>
        </xsl:if>

        <xsl:if test="$ada.rss.description != ''">
          <description><xsl:text
          disable-output-escaping="yes">&lt;![CDATA[</xsl:text><xsl:value-of
          select="$ada.rss.description"/><xsl:text 
          disable-output-escaping="yes">]]&gt;</xsl:text></description>
        </xsl:if>
        <xsl:if test="$ada.rss.main.site.url != ''">
          <link><xsl:value-of select="$ada.rss.main.site.url"/></link>
        </xsl:if>
        <xsl:if test="$ada.rss.language != ''">
          <language><xsl:value-of select="$ada.rss.language"/></language>
        </xsl:if>
        <xsl:if test="$ada.rss.copyright != ''">
          <copyright><xsl:value-of select="$ada.rss.copyright"/></copyright>
        </xsl:if>
      
        <!-- Crucial elements that need to be produced every time with
             the correct format -->
        <lastBuildDate><xsl:value-of select="$ada.rss.date.rfc822"/></lastBuildDate>
        <pubDate><xsl:value-of select="$ada.rss.date.rfc822"/></pubDate>
        <docs>http://blogs.law.harvard.edu/tech/rss</docs>
        <xsl:if test="$ada.rss.author.email != ''">
          <webMaster><xsl:value-of select="$ada.rss.author.email"/></webMaster>
        </xsl:if>
        <!-- ITunes Stuff -->

        <!-- Author name in text -->
        <xsl:if test="$ada.rss.author.name != ''">
          <itunes:author><xsl:value-of select="$ada.rss.author.name"/></itunes:author>
        </xsl:if>
        <!-- One line for channel subtitle, similar to description above -->
        <xsl:if test="$ada.rss.subtitle != ''">
          <itunes:subtitle><xsl:value-of
          select="$ada.rss.subtitle"/></itunes:subtitle>
        </xsl:if>
        
        <!-- One paragraph explaining in more detaile what the channel offers -->
        <xsl:if test="$ada.rss.summary">
          <itunes:summary><xsl:value-of select="normalize-space($ada.rss.summary)"/></itunes:summary> 
        </xsl:if>
        
        <!-- Redundant information about the author -->
        <xsl:if test="($ada.rss.author.name != '') and ($ada.rss.author.email != '')">
          <itunes:owner>
            <itunes:name><xsl:value-of select="$ada.rss.author.name"/></itunes:name>
            <!-- Author Email -->
            <itunes:email><xsl:value-of select="$ada.rss.author.email"/></itunes:email>
          </itunes:owner>
        </xsl:if>
    
        <!-- If the content in the item is explicit -->
        <xsl:if test="$ada.rss.explicit != ''">
          <itunes:explicit><xsl:value-of
          select="$ada.rss.explicit"/></itunes:explicit>
        </xsl:if>

        <!-- An image that is displayed somewhere -->
        <xsl:if test="$ada.rss.image.url != ''">
          <itunes:image>
            <xsl:attribute name="href"><xsl:value-of
            select="$ada.rss.image.url"/></xsl:attribute>
          </itunes:image>
        </xsl:if>

        <!-- Category and subcategory information -->
        <xsl:if test="$ada.rss.category != ''">
          <itunes:category>
            <xsl:attribute name="text"><xsl:value-of select="$ada.rss.category"/></xsl:attribute>
            <xsl:if test="$ada.rss.subcategory != ''">
              <itunes:category>
                <xsl:attribute name="text"><xsl:value-of
                select="$ada.rss.subcategory"/></xsl:attribute>
              </itunes:category>
            </xsl:if>
          </itunes:category>
        </xsl:if>
        <!-- End of iTunes Stuff -->

        <xsl:variable name="episode.content"><xsl:apply-templates
        select="*/section|*/chapter" mode="profile"/></xsl:variable>

	<!-- take the RSS items and apply templates to them -->
	<xsl:variable name="rssitems"
	  select="exsl:node-set($episode.content)//sectioninfo[@condition='rss.info']
	  | exsl:node-set($episode.content)//chapterinfo[@condition='rss.info']" />
	<xsl:apply-templates
	  select="exsl:node-set($rssitems)[position()>last()-$ada.rss.numitems.max]">
	  <xsl:sort select="position()" order="descending" data-type="number"/>
	  <xsl:with-param name="numitems"><xsl:value-of
	      select="count(exsl:node-set($rssitems))" /></xsl:with-param>
	</xsl:apply-templates>
      </channel>
    </rss>
  </xsl:template>

  <!--############################################################-->
  <!--                                                            -->
  <!--                       ITEM ELEMENT                         -->
  <!--                                                            -->
  <!--############################################################-->
  <xsl:template match="sectioninfo[contains(@condition, 'rss.info')]|
                       chapterinfo[contains(@condition, 'rss.info')]|
                       articleinfo[contains(@condition, 'rss.info')]">
    <xsl:param name="numitems">0</xsl:param>
    <xsl:variable name="date.now">
      <xsl:choose>
        <xsl:when test="($ada.rss.force.date) and ($ada.rss.force.date != '')">
          <!--          <xsl:value-of select="$ada.rss.force.date" /> -->
          <xsl:value-of select="$ada.rss.date.rfc822" />
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="date:date()" /></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="date.now.tocompare">
      <xsl:value-of select="date:year($date.now)"/><xsl:if 
      test="date:month-in-year($date.now) &lt; 10">0</xsl:if><xsl:value-of
      select="date:month-in-year($date.now)"/><xsl:if 
      test="date:day-in-month($date.now) &lt; 10">0</xsl:if><xsl:value-of
      select="date:day-in-month($date.now)"/>
    </xsl:variable>
    <xsl:variable name="date.given.tocompare">
      <xsl:choose>
        <xsl:when test="../@status">
          <xsl:value-of select="substring(../@status, 13,
                                4)"/><xsl:call-template
          name="monthAbbrevToNumber">
          <xsl:with-param name="monthAbb" select="substring(../@status, 9, 3)"/>
        </xsl:call-template><xsl:value-of
        select="substring(../@status, 6, 2)"/>
        </xsl:when>
        <xsl:otherwise><xsl:value-of
        select="$date.now.tocompare"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:if test="$ada.rss.debug != ''">
      <debug><xsl:value-of select="normalize-space(title)"/></debug>
      <date.now.tocompare><xsl:value-of
      select="$date.now.tocompare"/></date.now.tocompare>
      <date.given.tocompare><xsl:value-of
      select="$date.given.tocompare"/></date.given.tocompare>
    </xsl:if>
    
    <!-- If date check is off or itemdate is later than right now,
         then dump the item -->
    <xsl:if test="($ada.rss.check.pubdate = '0') or 
                  ($date.given.tocompare &lt;= $date.now.tocompare)">

      <xsl:if test="$ada.rss.debug != ''">
        <debug3>Item IS PUBLISHED!!!</debug3>
      </xsl:if>

      <item>
        <title><xsl:value-of select="normalize-space(/*/title/text())"/></title>

        <link>
	  <xsl:choose>
	    <xsl:when test="$ada.rss.autolink='true'">
	      <!-- Link auto-numbering -->
	      <xsl:value-of
		select="$ada.rss.autolink.urlprefix" />#item<xsl:number
		value="$numitems - position() + 1" format="1"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <!-- Produce the link element from the modespec/olink -->
	      <xsl:if test="modespec/olink[@condition = 'link']">
		<!-- Stick prefix for URL taken from the ancestor -->
		<xsl:if test="ancestor::*/ulink[@condition = 'itemlinkbase']">
		  <xsl:value-of select="$ada.rss.item.url.prefix"/><xsl:value-of
		    select="ancestor::*/ulink[@condition =
		    'itemlinkbase']/@url"/>/</xsl:if><xsl:value-of
		  select="normalize-space(modespec/olink/text())"/>
	      </xsl:if>
	    </xsl:otherwise>
	  </xsl:choose>
	</link>

        <guid>
          <xsl:choose>
            <xsl:when test="$ada.rss.autoguid='true'">
              <!-- GUID auto-numbering -->
	      <xsl:value-of
		select="$ada.rss.autoguid.guidprefix" />#item<xsl:number
		value="$numitems - position() + 1" format="1"/>
            </xsl:when>
            <xsl:when test="modespec/olink[@condition = 'guid']">
              <!-- Stick prefix for URL taken from the ancestor -->
              <xsl:if test="ancestor::*/ulink[@condition =
                            'itemlinkbase']"><xsl:value-of 
              select="$ada.rss.item.url.prefix"/><xsl:value-of
              select="ancestor::*/ulink[@condition =
              'itemlinkbase']/@url"/>/</xsl:if><xsl:value-of
              select="normalize-space(modespec/olink[@condition = 'guid']/text())"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:if test="ancestor::*/ulink[@condition =
                            'itemlinkbase']"><xsl:value-of
          select="$ada.rss.item.url.prefix"/><xsl:value-of  
              select="ancestor::*/ulink[@condition =
              'itemlinkbase']/@url"/>/</xsl:if><xsl:value-of  
              select="normalize-space(modespec/olink/text())"/>
            </xsl:otherwise>
          </xsl:choose>
        </guid>
        
        <xsl:variable name="description.body">
          <xsl:choose>
            <xsl:when test="abstract/para">
              <xsl:apply-templates select="abstract/para" />
            </xsl:when>
            <xsl:when test="not(abstract/para)">
              <!-- Skip the elements before the title (ABEL: What is this?) -->
              <xsl:apply-templates select="../title/following-sibling::*" />
            </xsl:when>
          </xsl:choose>
        </xsl:variable>
      
        <description>
          <xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
            <xsl:copy-of select="$description.body"/>
          <xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
        </description>

        <xsl:if
          test="modespec/ulink[@condition = 'enclosure']">
          <xsl:variable name="link.element" 
            select="modespec/ulink[@condition = 'enclosure']"/>
          <enclosure>
            <xsl:attribute name="url"><xsl:value-of
            select="$ada.rss.item.url.prefix"/><xsl:value-of  
            select="../ulink[@condition = 'enclosurebase']/@url"/>/<xsl:value-of
            select="exsl:node-set($link.element)/@url"/></xsl:attribute>
            <xsl:attribute name="length"><xsl:value-of
            select="exsl:node-set($link.element)/@arch"/></xsl:attribute>
            <xsl:attribute name="type"><xsl:value-of
            select="exsl:node-set($link.element)/@type"/></xsl:attribute>
          </enclosure>
        </xsl:if>
        
        <xsl:if test="kewordset/keyword[@condition='category']">
          <category><xsl:copy-of
          select="normalize-space(kewordset/keyword[@condition='category']/text())"/></category>
        </xsl:if>
        
        <pubDate>
          <xsl:choose>
            <xsl:when test="../@status != ''">
              <xsl:value-of select="../@status"/>
            </xsl:when>
            <xsl:otherwise><xsl:value-of select="$ada.rss.date.rfc822"/></xsl:otherwise>
          </xsl:choose>
        </pubDate>
        
        <xsl:if test="$ada.rss.explicit != ''">
          <itunes:explicit><xsl:value-of
          select="$ada.rss.explicit"/></itunes:explicit>
        </xsl:if>
        
        <xsl:if test="(author/firstname) and (author/surname)">
          <itunes:author><xsl:copy-of
          select="normalize-space(author/firstname/text())"/>
          <xsl:text> </xsl:text>
          <xsl:copy-of select="normalize-space(author/surname/text())"/></itunes:author>
        </xsl:if>
        
        <xsl:if test="/*/title">
          <itunes:subtitle><xsl:copy-of select="normalize-space(/*/title/text())"/></itunes:subtitle>
        </xsl:if>
        
        <xsl:if test="abstract/para">
          <itunes:summary><xsl:copy-of
          select="normalize-space(abstract/para/text())"/></itunes:summary>
        </xsl:if>
        
        <xsl:if test="pagenums">
          <itunes:duration><xsl:copy-of
          select="normalize-space(pagenums/text())"/></itunes:duration>
        </xsl:if>
        
        <xsl:if test="keywordset/keyword[@condition != 'category']">
          <itunes:keywords>
            <xsl:for-each select="keywordset/keyword[@condition != 'category']">
              <xsl:copy-of select="normalize-space(text())"/>
            </xsl:for-each>
          </itunes:keywords>
        </xsl:if>
      </item>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@fileref">
    <xsl:value-of select="$ada.rss.item.url.prefix"/><xsl:value-of 
    select="ancestor::*/ulink[@condition = 'itemlinkbase']/@url"/>/<xsl:value-of 
    select="."/>
  </xsl:template>

  <xsl:template name="monthAbbrevToNumber">
    <xsl:param name="monthAbb"/>
    <xsl:choose>
      <xsl:when test="$monthAbb = 'Jan'">01</xsl:when>
      <xsl:when test="$monthAbb = 'Feb'">02</xsl:when>
      <xsl:when test="$monthAbb = 'Mar'">03</xsl:when>
      <xsl:when test="$monthAbb = 'Apr'">04</xsl:when>
      <xsl:when test="$monthAbb = 'May'">05</xsl:when>
      <xsl:when test="$monthAbb = 'Jun'">06</xsl:when>
      <xsl:when test="$monthAbb = 'Jul'">07</xsl:when>
      <xsl:when test="$monthAbb = 'Aug'">08</xsl:when>
      <xsl:when test="$monthAbb = 'Sep'">09</xsl:when>
      <xsl:when test="$monthAbb = 'Oct'">10</xsl:when>
      <xsl:when test="$monthAbb = 'Nov'">11</xsl:when>
      <xsl:when test="$monthAbb = 'Dec'">12</xsl:when>
      <xsl:otherwise>NaN</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
