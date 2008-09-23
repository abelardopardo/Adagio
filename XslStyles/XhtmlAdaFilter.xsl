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

  <!-- Path of the docbook source of the RSS channel. Must be overridden -->
  <xsl:param name="ada.rss.source.file"></xsl:param>

  <!-- Numer of RSS items to show. May be overridden externally -->
  <xsl:param name="ada.rss.display.num">5</xsl:param>

  <xsl:output method="xml" indent="yes" encoding="UTF-8"
              doctype-public="-//W3C//DTD XHTML 1.1//EN"
              doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd" />


  <xsl:param name="rssfile"><xsl:value-of select="$ada.course.home"/><xsl:value-of
      select="$ada.rss.source.file"/>
  </xsl:param>

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
      <xsl:apply-templates mode="profile" select="document(exsl:node-set($rssfile))" />
    </xsl:variable>
    <!-- take the RSS items -->
    <xsl:variable name="rssitems"
      select="exsl:node-set($rsscontent)//sectioninfo[@condition='rss.info']
      | exsl:node-set($rsscontent)//chapterinfo[@condition='rss.info']" />
    <!-- apply templates to the last $ada.rss.display.num items -->
    <xsl:apply-templates
      select="exsl:node-set($rssitems)[position()>last()-$ada.rss.display.num]"
      mode="rss">
      <xsl:sort select="position()" order="descending"
	data-type="number"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- apply templates to a RSS item -->
  <xsl:template match="sectioninfo | chapterinfo" mode="rss">
    <xsl:element name="tr">
      <td>
	<xsl:if test="../@status">
	  <xsl:value-of select="../@status" />
	</xsl:if>
      </td>
      <td>
	<b><xsl:value-of select="title/text()" /></b>
	<xsl:apply-templates select="abstract/formalpara/para" />
      </td>
    </xsl:element>    
  </xsl:template>

</xsl:stylesheet>
