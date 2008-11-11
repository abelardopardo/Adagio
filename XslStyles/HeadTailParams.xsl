<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0" exclude-result-prefixes="exsl xi">
  
  <!-- Customization variables for Head and Tail -->
  <xsl:param name="ada.page.author" 
    description="Author to include in the meta element in HTML head"/>
  <xsl:param name="ada.page.cssstyle.url" 
    description="URL pointing to a CSS file to include in the HTML head"/>
  <xsl:param name="ada.page.google.analytics.account" 
    description="Account to include in the Google Analytics HTML snippet."/>
  <xsl:param name="ada.page.google.gadget.url" 
    description="Link pointing to a Google Gadget to be included in the upper
                 left corner of the page"/>
  <xsl:param name="ada.page.head.bigtitle" 
    description="Value 1/0 to enable a big title on top of the page">0</xsl:param>
  <xsl:param name="ada.page.head.center.bottom" 
    description="Text to insert at the bottom row of the Header table"/>
  <xsl:param name="ada.page.head.center.top.logo" 
    description="URL to the image to show in the top center of the table
                 header"/>
  <xsl:param name="ada.page.head.center.top.logo.alt" 
    description="Alt attribute for the previous image"/>
  <xsl:param name="ada.page.head.center.top.logo.url" 
    description="URL to make the image a link"/>
  <xsl:param name="ada.page.head.left.logo"
    description="URL to the image to show in the left side of the table header"/>
  <xsl:param name="ada.page.head.left.logo.alt" 
    description="Alt attribute for the previous image"/>
  <xsl:param name="ada.page.head.left.logo.url"
    description="URL to make the image a link"/>
  <xsl:param name="ada.page.head.right.logo"
    description="URL to the image to show in the right side of the table header"/>
  <xsl:param name="ada.page.head.right.logo.alt" 
    description="Alt attribute for the previous image"/>
  <xsl:param name="ada.page.head.right.logo.url" 
    description="URL to make the image a link"/>
  <xsl:param name="ada.page.refresh.rate" 
    description="Include a refresh rate in the page header"/>
  <xsl:param name="ada.page.license.institution" select="'&#169; Carlos III University of Madrid, Spain'"/>
  <xsl:param name="ada.page.license" 
    description="Yes/no to include license information at the bottom of the
                 page">no</xsl:param>
  <xsl:param name="ada.page.license.name"
    description="Name of the license"/>
  <xsl:param name="ada.page.license.logo"
    description="URL to an image to accompany the license information"/>
  <xsl:param name="ada.page.license.alt" 
    description="Alt attribute for the previous image"/>
  <xsl:param name="ada.page.license.url" 
    description="URL to point when clicking in the license image"/>
  <xsl:param name="ada.page.show.lastmodified" 
    description="yes/no controlling if the last modified info is shown at
                 bottom">no</xsl:param>
</xsl:stylesheet>
