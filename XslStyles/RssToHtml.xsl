<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:date="http://exslt.org/dates-and-times"
  xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
  extension-element-prefixes="date"
  version="1.0" exclude-result-prefixes="exsl itunes">

  <!--
       Style file to render an XML file containing an RSS channel to HTML in
       order to view all the element values. The main purpose of this rendering
       is to debug possible errors in the information contained in the channel,
       and should not be published to the open public
       -->
  <xsl:output method="html" indent="yes" encoding="UTF-8"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"/>

  <xsl:template match="/">
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <meta http-equiv="Content-Type" content="text/html;
                                                 charset=UTF-8"/>
        <xsl:copy-of select="rss/channel/title"/>
        <meta name="generator" content="Home Brewed XSLT"></meta>
        <meta name="Author" content="Carlos III University of Madrid"></meta>
        <meta http-equiv="Content-Style-Type" content="text/css"/>
        <style type="text/css">
          <xsl:value-of select="document('style.xml')/text/text()"/>
        </style>
      </head>
      <body>
        <xsl:apply-templates/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="channel">
    <h2 style="text-align: center">Channel Info</h2>
    <div class="informaltable">
      <table style="border:1px solid black" cellspacing="5" cellpadding="5">
        <tr>
          <td colspan="2">Title</td>
          <td><xsl:value-of select="title"/></td>
          <td rowspan="22">
            <h3 style="text-align: center">Episode Index</h3>
            <ol>
              <xsl:for-each select="item">
                <xsl:sort select="position()" order="descending"
                  data-type="number"/>
                <li>
                  <a>
                    <xsl:attribute name="href">#<xsl:value-of select="position()"/></xsl:attribute>
                    <xsl:value-of select="title"/>
                  </a>
                </li>
              </xsl:for-each>
            </ol>
          </td>
        </tr>
        <tr>
          <td colspan="2">TTL</td>
          <td><xsl:value-of select="ttl"/></td>
        </tr>
        <tr>
          <td rowspan="5">Image</td>
          <td>Title</td>
          <td><xsl:value-of select="image/title"/></td>
        </tr>
        <tr>
          <td>URL</td>
          <td>
            <xsl:value-of select="image/url"/>
            <xsl:text> </xsl:text>
            <img style="vertical-align: middle">
              <xsl:attribute name="src">
                <xsl:value-of select="image/url"/>
              </xsl:attribute>
            </img>
          </td>
        </tr>
        <tr>
          <td>Link</td>
          <td>
            <a>
              <xsl:attribute name="href">
                <xsl:value-of select="image/link"/>
              </xsl:attribute>
              <xsl:value-of select="image/link"/>
            </a>
          </td>
        </tr>
        <tr>
          <td>Description</td>
          <td><xsl:copy-of select="image/description/node()"/></td>
        </tr>
        <tr>
          <td>Width/Height</td>
          <td><xsl:value-of select="image/width"/>/<xsl:value-of
          select="image/height"/></td>
        </tr>
        <tr>
          <td colspan="2">Description</td>
          <td><xsl:copy-of select="description/node()"/></td>
        </tr>
        <tr>
          <td colspan="2">Link</td>
          <td>
            <a>
              <xsl:attribute name="href">
                <xsl:value-of select="link"/>
              </xsl:attribute>
              <xsl:value-of select="link"/>
            </a>
          </td>
        </tr>
        <tr>
          <td colspan="2">Language</td>
          <td>
            <xsl:value-of select="language"/>
          </td>
        </tr>
        <tr>
          <td colspan="2">Copyright</td>
          <td>
            <xsl:value-of select="copyright"/>
          </td>
        </tr>
        <tr>
          <td colspan="2">Last Built</td>
          <td>
            <xsl:value-of select="lastBuildDate"/>
          </td>
        </tr>
        <tr>
          <td colspan="2">Pub Date</td>
          <td>
            <xsl:value-of select="pubDate"/>
          </td>
        </tr>
        <tr>
          <td colspan="2">Docs</td>
          <td>
            <a>
              <xsl:attribute name="href">
                <xsl:value-of select="docs"/>
              </xsl:attribute>
              <xsl:value-of select="docs"/>
            </a>
          </td>
        </tr>
        <tr>
          <td colspan="2">Web Master</td>
          <td>
            <xsl:value-of select="webMaster"/>
          </td>
        </tr>
        <tr>
          <td rowspan="6">iTunes</td>
          <td>Author</td>
          <td><xsl:value-of select="itunes:author"/></td>
        </tr>
        <tr>
          <td>Subtitle</td>
          <td><xsl:value-of select="itunes:subtitle"/></td>
        </tr>
        <tr>
          <td>Summary</td>
          <td><xsl:value-of select="itunes:summary"/></td>
        </tr>
        <tr>
          <td>Owner</td>
          <td>
            <xsl:value-of select="itunes:owner/itunes:name"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="itunes:owner/itunes:email"/>
          </td>
        </tr>
        <tr>
          <td>Explicit</td>
          <td><xsl:value-of select="itunes:explicit"/></td>
        </tr>
        <tr>
          <td>Category</td>
          <td>
            <xsl:value-of select="itunes:category/@text"/>,
            <xsl:value-of select="itunes:category/itunes:category/@text"/>
          </td>
        </tr>
        <tr>
          <td colspan="2">Num. Episodes</td>
          <td><xsl:value-of select="count(item)"/></td>
        </tr>
      </table>
      
      <br/>
      
      <xsl:apply-templates select="item">
        <xsl:sort select="position()" order="descending"
          data-type="number"/>
      </xsl:apply-templates>
    </div>
  </xsl:template>

  <xsl:template match="item">
    <a><xsl:attribute name="id"><xsl:value-of select="position()"/></xsl:attribute></a>
    <table style="border:1px solid black" cellspacing="5" cellpadding="5">
      <tr>
        <th style="background-color: #000000; color:#FFFFFF" colspan="3">
          Episode <xsl:value-of
          select="count(following-sibling::item) + 1"/>
        </th>
      </tr>
      <tr>
        <td colspan="2">Title</td>
        <td><xsl:value-of select="title"/></td>
      </tr>
      <tr>
        <td colspan="2">Link</td>
        <td>
          <a>
            <xsl:attribute name="href">
              <xsl:value-of select="link"/>
            </xsl:attribute>
            <xsl:value-of select="link"/>
          </a>
        </td>
      </tr>
      <tr>
        <td colspan="2">GUID</td>
        <td>
          <a>
            <xsl:attribute name="href">
              <xsl:value-of select="guid"/>
            </xsl:attribute>
            <xsl:value-of select="guid"/>
          </a>
        </td>
      </tr>
      <tr>
        <td colspan="2">Description</td>
        <td>
          <xsl:copy-of select="description/text()"/>
        </td>
      </tr>
      <tr>
        <td rowspan="3">Enclosure</td>
        <td>URL</td>
        <td>
          <a>
            <xsl:attribute name="href">
              <xsl:value-of select="enclosure/@url"/>
            </xsl:attribute>
            <xsl:value-of select="enclosure/@url"/>
          </a>
        </td>
      </tr>
      <tr>
        <td>Length</td>
        <td>
          <xsl:value-of select="enclosure/@length"/>
        </td>
      </tr>
      <tr>
        <td>Type</td>
        <td>
          <xsl:value-of select="enclosure/@type"/>
        </td>
      </tr>
      <tr>
        <td colspan="2">Pub Date</td>
        <td>
          <xsl:value-of select="pubDate"/>
        </td>
      </tr>
      <tr>
        <td rowspan="4">iTunes</td>
        <td>Author</td>
        <td><xsl:value-of select="itunes:author"/></td>
      </tr>
      <tr>
        <td>Subtitle</td>
        <td><xsl:value-of select="itunes:subtitle"/></td>
      </tr>
      <tr>
        <td>Summary</td>
        <td><xsl:value-of select="itunes:summary"/></td>
      </tr>
      <tr>
        <td>Explicit</td>
        <td><xsl:value-of select="itunes:explicit"/></td>
      </tr>
    </table>
    <br />
  </xsl:template>
</xsl:stylesheet>
