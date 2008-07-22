<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0" exclude-result-prefixes="exsl xi">

  <!-- Obtain variables ada.publish.host ada.publish.dir -->
  <xsl:import href="GeneralParams.xsl"/>

  <xsl:param name="ada.rss.time.to.live">30</xsl:param>
  <xsl:param name="ada.rss.title">Rss title goes here</xsl:param>
  <xsl:param name="ada.rss.description">Rss description goes here</xsl:param>

  <!-- Parameter to put in links to the main site documentation -->
  <xsl:param name="ada.rss.main.site.url">http://bogus.net</xsl:param>

  <!-- URL pointing to the XML file containing the feed -->
  <xsl:param name="ada.rss.channel.url"/>

  <!-- Prefix of the type http://......./a/b/c to use for material links -->
  <xsl:param name="ada.rss.item.url.prefix"></xsl:param>

  <xsl:param name="ada.rss.language">en</xsl:param>
  <xsl:param name="ada.rss.copyright">Copyright goes here</xsl:param>
  <xsl:param name="ada.rss.author.email">author@bogus.net (Author name)</xsl:param>    
  <xsl:param name="ada.rss.author.name">Author name goes here</xsl:param>
  <xsl:param name="ada.rss.subtitle">Rss subtitle goes here</xsl:param>
  <xsl:param name="ada.rss.summary">Rss summary goes here</xsl:param>
  <xsl:param name="ada.rss.explicit">No</xsl:param>
  <xsl:param name="ada.rss.image.url">http://image.net/bogusimage.png</xsl:param>
  <xsl:param name="ada.rss.image.desc"></xsl:param>
  <xsl:param name="ada.rss.image.width">88</xsl:param>
  <xsl:param name="ada.rss.image.height">88</xsl:param>
  <xsl:param name="ada.rss.category">Education</xsl:param>
  <xsl:param name="ada.rss.subcategory">Higher Education</xsl:param>
  <xsl:param name="ada.rss.max.items">10</xsl:param>
  <xsl:param name="ada.rss.check.pubdate">0</xsl:param>
  <xsl:param name="ada.rss.force.date"></xsl:param>
  <xsl:param name="ada.rss.date.rfc822"></xsl:param>
  <xsl:param name="ada.rss.self.atom.link"><xsl:value-of
  select="$ada.rss.channel.url"/></xsl:param>
  <xsl:param name="ada.rss.debug"></xsl:param>
</xsl:stylesheet>
