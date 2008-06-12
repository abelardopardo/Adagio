<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
  xmlns:date="http://exslt.org/dates-and-times"
  extension-element-prefixes="date"
  version="1.0" exclude-result-prefixes="exsl">
  
  <xsl:import 
     href="file:///usr/share/sgml/docbook/stylesheet/xsl/nwalsh/html/profile-docbook.xsl"/>
  <xsl:import 
     href="file:///usr/share/sgml/docbook/stylesheet/xsl/nwalsh/html/manifest.xsl"/>
  <xsl:import href="es-modify.xsl"/>

  <xsl:param name="rss.time.to.live"   select="'30'"/>
  <xsl:param name="rss.title"          select="'Rss title goes here'"/>
  <xsl:param name="rss.description"    select="'Rss description goes here'"/>
  <xsl:param name="rss.main.site.url"  select="'http://bogus.net'"/>
  <xsl:param name="rss.language"       select="'en'"/>
  <xsl:param name="rss.copyright"      select="'Copyright goes here'"/>
  <xsl:param name="rss.author.email"   select="'author@bogus.net'"/>    
  <xsl:param name="rss.author.name"    select="'Author name goes here'"/>
  <xsl:param name="rss.subtitle"       select="'Rss subtitle goes here'"/>
  <xsl:param name="rss.summary"        select="'Rss summary goes here'"/>
  <xsl:param name="rss.explicit"       select="'No'"/>
  <xsl:param name="rss.image.url"      select="'http://image.net/bogusimage.png'"/>
  <xsl:param name="rss.image.desc"     select="''"/>
  <xsl:param name="rss.image.width"    select="'88'"/>
  <xsl:param name="rss.image.height"   select="'88'"/>
  <xsl:param name="rss.category"       select="'Education'"/>
  <xsl:param name="rss.subcategory"    select="'Higher Education'"/>
  <xsl:param name="rss.max.items"      select="10"/>
  <xsl:param name="rss.check.pubdate"  select="0"/>
  <xsl:param name="rss.force.date"     select="''"/> 
  <xsl:param name="rss.date.rfc822"    select="''"/>
  <xsl:param name="rss.self.atom.link" select="''"/>
  
  <!-- The presence of CDATA in descriptions is to preserve any embedded
       HTML they might include. Ugly but seen in other RSS feeds
  -->
  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

  <!-- The date, when in pubDate, must follow the RFC 822 structure
       -->
  <!--
  <xsl:variable name="date">
    <xsl:value-of select="date:day-abbreviation()"/>,<xsl:text> </xsl:text>
    <xsl:value-of select="date:day-in-month()"/><xsl:text> </xsl:text>
    <xsl:value-of select="date:month-abbreviation()"/><xsl:text> </xsl:text>
    <xsl:value-of select="date:year()"/><xsl:text> </xsl:text>
    <xsl:if test="date:hour-in-day() &lt; 10">0</xsl:if><xsl:value-of
    select="date:hour-in-day()"/><xsl:text>:</xsl:text> 
    <xsl:if test="date:minute-in-hour() &lt; 10">0</xsl:if><xsl:value-of 
    select="date:minute-in-hour()"/><xsl:text>:</xsl:text>
    <xsl:if test="date:second-in-minute() &lt; 10">0</xsl:if><xsl:value-of 
    select="date:second-in-minute()"/><xsl:text> </xsl:text>
    <xsl:value-of 
      select="substring(date:time(), 9, 3)"/><xsl:value-of
    select="substring(date:time(), 13, 2)"/>
  </xsl:variable>
  -->

  <xsl:template match="/">
    <rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
      <channel>
        <xsl:if test="$rss.self.atom.link != ''">
          <atom:link rel="self" type="application/rss+xml">
            <xsl:attribute name="href"><xsl:value-of
                select="$rss.self.atom.link" />
            </xsl:attribute>
          </atom:link>
        </xsl:if>
        <xsl:if test="$rss.time.to.live != ''">
          <ttl><xsl:value-of select="$rss.time.to.live"/></ttl>
        </xsl:if>

        <xsl:if test="$rss.title != ''">
          <title><xsl:value-of select="$rss.title"/></title>
        </xsl:if>

        <xsl:if test="($rss.title != '') and ($rss.image.url != '')
                      and ($rss.main.site.url != '')"> 
          <image>
            <title><xsl:value-of select="$rss.title"/></title>
            <url><xsl:value-of select="$rss.image.url"/></url>
            <link><xsl:value-of select="$rss.main.site.url"/></link>
            <xsl:if test="$rss.image.desc != ''">
              <description><xsl:text
              disable-output-escaping="yes">&lt;![CDATA[</xsl:text><xsl:value-of 
              select="$rss.image.desc"/><xsl:text 
              disable-output-escaping="yes">]]&gt;</xsl:text></description>
            </xsl:if>
            <width><xsl:value-of select="$rss.image.width"/></width>
            <height><xsl:value-of select="$rss.image.height"/></height>
          </image>
        </xsl:if>

        <xsl:if test="$rss.description != ''">
          <description><xsl:text
          disable-output-escaping="yes">&lt;![CDATA[</xsl:text><xsl:value-of
          select="$rss.description"/><xsl:text 
          disable-output-escaping="yes">]]&gt;</xsl:text></description>
        </xsl:if>
        <xsl:if test="$rss.main.site.url != ''">
          <link><xsl:value-of select="$rss.main.site.url"/></link>
        </xsl:if>
        <xsl:if test="$rss.language != ''">
          <language><xsl:value-of select="$rss.language"/></language>
        </xsl:if>
        <xsl:if test="$rss.copyright != ''">
          <copyright><xsl:value-of select="$rss.copyright"/></copyright>
        </xsl:if>
      
        <!-- Crucial elements that need to be produced every time with
             the correct format -->
        <lastBuildDate><xsl:value-of select="$rss.date.rfc822"/></lastBuildDate>
        <pubDate><xsl:value-of select="$rss.date.rfc822"/></pubDate>
        <docs>http://blogs.law.harvard.edu/tech/rss</docs>
        <xsl:if test="$rss.author.email != ''">
          <webMaster><xsl:value-of
          select="$rss.author.email"/></webMaster>
        </xsl:if>
        <!-- ITunes Stuff -->

        <!-- Author name in text -->
        <xsl:if test="$rss.author.name != ''">
          <itunes:author><xsl:value-of
          select="$rss.author.name"/></itunes:author>
        </xsl:if>
        <!-- One line for channel subtitle, similar to description above -->
        <xsl:if test="$rss.subtitle != ''">
          <itunes:subtitle><xsl:value-of
          select="$rss.subtitle"/></itunes:subtitle>
        </xsl:if>
        
        <!-- One paragraph explaining in more detaile what the channel offers -->
        <xsl:if test="$rss.summary">
          <itunes:summary><xsl:value-of select="normalize-space($rss.summary)"/></itunes:summary> 
        </xsl:if>
        
        <!-- Redundant information about the author -->
        <xsl:if test="($rss.author.name != '') and ($rss.author.email != '')">
          <itunes:owner>
            <itunes:name><xsl:value-of select="$rss.author.name"/></itunes:name>
            <!-- Author Email -->
            <itunes:email><xsl:value-of select="$rss.author.email"/></itunes:email>
          </itunes:owner>
        </xsl:if>
    
        <!-- If the content in the item is explicit -->
        <xsl:if test="$rss.explicit != ''">
          <itunes:explicit><xsl:value-of
          select="$rss.explicit"/></itunes:explicit>
        </xsl:if>

        <!-- An image that is displayed somewhere -->
        <xsl:if test="$rss.image.url != ''">
          <itunes:image>
            <xsl:attribute name="href"><xsl:value-of
            select="$rss.image.url"/></xsl:attribute>
          </itunes:image>
        </xsl:if>

        <!-- Category and subcategory information -->
        <xsl:if test="$rss.category != ''">
          <itunes:category>
            <xsl:attribute name="text"><xsl:value-of select="$rss.category"/></xsl:attribute>
            <xsl:if test="$rss.subcategory != ''">
              <itunes:category>
                <xsl:attribute name="text"><xsl:value-of
                select="$rss.subcategory"/></xsl:attribute>
              </itunes:category>
            </xsl:if>
          </itunes:category>
        </xsl:if>
        <!-- End of iTunes Stuff -->

        <xsl:variable name="episode.content"><xsl:apply-templates
        select="*/section|*/chapter" mode="profile"/></xsl:variable>

        <!-- Loop over all section/chapter elements.  -->
        <xsl:for-each
          select="exsl:node-set($episode.content)/descendant::section|exsl:node-set($episode.content)/descendant::chapter">
          <xsl:sort select="position()" order="descending"
            data-type="number"/>
          <!-- 
          <debug><xsl:value-of select="$profile.lang"/></debug>
          <debug><xsl:value-of select="title/text()"/></debug>
          <debug><xsl:value-of select="count(sectioninfo)"/></debug>
          <debug><xsl:value-of select="count(chapterinfo)"/></debug>
           -->         
          <xsl:apply-templates
            select="sectioninfo|chapterinfo"/>
        </xsl:for-each>
      </channel>
    </rss>
  </xsl:template>

  <!--############################################################-->
  <!--                                                            -->
  <!--                       ITEM ELEMENT                         -->
  <!--                                                            -->
  <!--############################################################-->
  <xsl:template match="sectioninfo[@condition = 'rss.info']|
                       chapterinfo[@condition = 'rss.info']">
    <xsl:variable name="date.now">
      <xsl:choose>
        <xsl:when test="($rss.force.date) and ($rss.force.date != '')">
          <xsl:value-of select="$rss.force.date" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="date:date()" />
        </xsl:otherwise>
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
    
    <!--
    <debug><xsl:value-of select="normalize-space(title)"/></debug>
    <date.now.tocompare><xsl:value-of select="$date.now.tocompare"/></date.now.tocompare>
    <date.given.tocompare><xsl:value-of select="$date.given.tocompare"/></date.given.tocompare>
    -->
    
    <!-- If date check is off or itemdate is later than right now,
         then dump the item -->
    <xsl:if test="($rss.check.pubdate = '0') or 
                  ($date.given.tocompare &lt;= $date.now.tocompare)">
      <!--
      <debug3>Item IS PUBLISHED!!!</debug3>
      -->
      <item>
        <title>
          <xsl:value-of
            select="normalize-space(title)"/>
        </title>
        
        <!-- Produce the link element from the modespec/olink -->
        <xsl:if test="modespec/olink[@condition = 'link']">
          <!-- Stick prefix for URL taken from the ancestor -->
          <link><xsl:value-of 
          select="ancestor::*/ulink[@condition = 'itemlinkbase']/@url"/><xsl:value-of 
          select="normalize-space(modespec/olink/text())"/></link>
        </xsl:if>
        
        <guid>
          <xsl:choose>
            <xsl:when test="modespec/olink[@condition = 'guid']">
              <!-- Stick prefix for URL taken from the ancestor -->
              <xsl:value-of 
                select="ancestor::*/ulink[@condition = 'itemlinkbase']/@url"/><xsl:value-of 
              select="normalize-space(modespec/olink/text())"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of 
                select="ancestor::*/ulink[@condition = 'itemlinkbase']/@url"/><xsl:value-of 
              select="normalize-space(modespec/olink/text())"/>
            </xsl:otherwise>
          </xsl:choose>
        </guid>
        
        <xsl:if test="modespec/olink[@condition = 'guid']">
          <!-- Stick prefix for URL taken from the ancestor -->
          <guid><xsl:value-of 
          select="ancestor::*/ulink[@condition = 'itemlinkbase']/@url"/><xsl:value-of 
          select="normalize-space(modespec/olink/text())"/></guid>
        </xsl:if>

        <xsl:variable name="description.body">
          <xsl:choose>
            <xsl:when test="abstract/formalpara/para">
              <xsl:apply-templates select="abstract/formalpara/para" />
            </xsl:when>
            <xsl:when test="not(abstract/formalpara)">
              <!-- Skip the elements before the title  -->
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
            select="../ulink[@condition = 'enclosurebase']/@url"/><xsl:value-of
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
            <xsl:otherwise><xsl:value-of select="$rss.date.rfc822"/></xsl:otherwise>
          </xsl:choose>
        </pubDate>
        
        <xsl:if test="$rss.explicit != ''">
          <itunes:explicit><xsl:value-of
          select="$rss.explicit"/></itunes:explicit>
        </xsl:if>
        
        <xsl:if test="(author/firstname) and (author/surname)">
          <itunes:author><xsl:copy-of
          select="normalize-space(author/firstname/text())"/>
          <xsl:text> </xsl:text>
          <xsl:copy-of select="normalize-space(author/surname/text())"/></itunes:author>
        </xsl:if>
        
        <xsl:if test="abstract/formalpara/title">
          <itunes:subtitle><xsl:copy-of select="normalize-space(abstract/formalpara/title/text())"/></itunes:subtitle>
        </xsl:if>
        
        <xsl:if test="abstract/formalpara/para">
          <itunes:summary><xsl:copy-of
          select="normalize-space(abstract/formalpara/para/text())"/></itunes:summary>
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
    <xsl:value-of 
      select="ancestor::*/ulink[@condition = 'itemlinkbase']/@url"/><xsl:value-of 
    select="."/>
  </xsl:template>

  <!-- Normalize Text -->
  <!-- This template is removing space within a paragraph, it goes. -->
  <!-- <xsl:template match="text()">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template> -->

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
