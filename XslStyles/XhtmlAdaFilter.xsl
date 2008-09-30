<?xml version="1.0" encoding="UTF-8"?>

<!--
   Docbook-like processing of XHTML files

   Replaces the <rss> element with the latest items from a RSS channel.
   Filters input HTML documents using the AdaProfile  filter.

   Imports the AdaProfile filter used for Docbook files. 
  -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns="http://www.w3.org/1999/xhtml"
  version="1.0">

  <!-- AdaProfile filter and Docbook import -->
  <xsl:import href="AdaProfile.xsl"/>
  <xsl:import 
     href="http://docbook.sourceforge.net/release/xsl/current/xhtml/profile-docbook.xsl"/>

  <xsl:param name="ada.profile.suppress.profiling.attributes">yes</xsl:param>

  <!-- Numer of RSS items to show. May be overridden externally -->
  <xsl:param name="ada.rss.display.num">5</xsl:param>
  <!-- Path of the HTML page that shows the full RSS items -->
  <xsl:param name="ada.rss.html.path"></xsl:param>

  <xsl:output method="xml" indent="yes" encoding="UTF-8"
              doctype-public="-//W3C//DTD XHTML 1.1//EN"
              doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
              omit-xml-declaration="no" />

  <!-- Bootstrap the filter -->
  <xsl:template match="/">
    <xsl:variable name="content"><xsl:apply-templates
	select="/" mode="profile"/></xsl:variable>
    <xsl:copy>
      <xsl:copy-of select="exsl:node-set($content)/@*" />
      <xsl:apply-templates select="exsl:node-set($content)/*" />
    </xsl:copy>
  </xsl:template>

  <!-- any HTML element: copy to the output recursively -->
  <xsl:template match="html:*">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- apply templates to the RSS items of the external file -->
  <xsl:template match="html:rss">
    <!-- pass the RSS source file through the profile filter -->
    <xsl:variable name="rsscontent">
      <xsl:apply-templates mode="profile" select="document(@file)" />
    </xsl:variable>

    <!-- take the RSS items -->
    <xsl:variable name="rssitems"
      select="exsl:node-set($rsscontent)//sectioninfo[@condition='rss.info']
      | exsl:node-set($rsscontent)//chapterinfo[@condition='rss.info']" />

    <!-- choose between short and normal mode -->
   <xsl:choose>
      <xsl:when test="@mode and @mode='short'">
	<!-- apply templates to the last $ada.rss.display.num items -->
	<xsl:apply-templates
	  select="exsl:node-set($rssitems)[position()>last()-$ada.rss.display.num]"
	  mode="rss-short">
	  <xsl:sort select="position()" order="descending" data-type="number"/>
	  <xsl:with-param name="numitems"><xsl:value-of
	      select="count(exsl:node-set($rssitems))" /></xsl:with-param>
	</xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
	<!-- apply templates to all the items -->
	<xsl:apply-templates select="exsl:node-set($rssitems)" mode="rss-normal">
	  <xsl:sort select="position()" order="descending" data-type="number"/>
	  <xsl:with-param name="numitems"><xsl:value-of
	      select="count(exsl:node-set($rssitems))" /></xsl:with-param>
	</xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- apply templates to a RSS item (short: first paragraph only) -->
  <xsl:template match="sectioninfo | chapterinfo" mode="rss-short">
    <xsl:param name="numitems">0</xsl:param>
    <xsl:element name="tr">
      <td>
	<xsl:if test="../@status">
	  <xsl:value-of select="../@status" />
	</xsl:if>
      </td>
      <td>
	<xsl:choose>
	  <xsl:when test="$ada.rss.html.path != ''">
	    <xsl:element name="a">
	      <xsl:attribute name="href"><xsl:value-of
		  select="$ada.rss.html.path" />#item<xsl:number
		  value="$numitems - position() + 1" format="1"/></xsl:attribute>
	      <b><xsl:value-of select="title/text()" /></b>
	    </xsl:element>
	  </xsl:when>
	  <xsl:otherwise>
	    <b><xsl:value-of select="title/text()" /></b>
	  </xsl:otherwise>
	</xsl:choose>
	<xsl:apply-templates select="abstract/formalpara/para[position()=1]" />
      </td>
    </xsl:element>    
  </xsl:template>

  <!-- apply templates to a RSS item (full item) -->
  <xsl:template match="sectioninfo | chapterinfo" mode="rss-normal">
    <xsl:param name="numitems">0</xsl:param>
    <xsl:element name="h3">
      <xsl:element name="a">
	<xsl:attribute name="id">item<xsl:number value="$numitems - position() + 1" format="1"/></xsl:attribute>
      </xsl:element>
      <xsl:value-of select="title/text()" />
    </xsl:element>
    <xsl:element name="p">
      <i>
	<xsl:if test="../@status">
	  <xsl:value-of select="../@status" />
	</xsl:if>
      </i>
    </xsl:element>
    <xsl:for-each select="abstract/formalpara/para">
      <xsl:element name="p">
	<xsl:apply-templates select="." />
      </xsl:element>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
