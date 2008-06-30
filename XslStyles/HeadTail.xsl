<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0" exclude-result-prefixes="exsl xi">
  
  <xsl:import href="DocbookProfile.xsl"/>

  <!-- Brings in all the default values -->
  <xsl:import href="Params.xsl"/>

  <!-- Template to ignore the chapter/section info with rss.info condition -->
  <xsl:import href="RssIgnore.xsl"/>

  <xsl:output method="xml" indent="yes" encoding="UTF-8"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"/>

  <!-- Docbook XSL parameters needed generate strict XHTML -->
  <xsl:param name="css.decoration">0</xsl:param>
  <xsl:param name="html.longdesc">0</xsl:param>
  <xsl:param name="ulink.target" />
  <xsl:param name="use.viewport">0</xsl:param>

  <!-- This one for sure is needed in all documents -->
  <xsl:param name="xref.with.number.and.title" select="'0'"/>

  <!-- Stick the onload attribute in case the flash.player.javascript is given -->
  <xsl:template name="body.attributes">
    <!-- No longer needed. A new version of mediaplayer uses js to take care of
  these issues -->
    <!--
    <xsl:if test="$ada.page.flash.player.javascript">
      <xsl:attribute name="onload">setupSeekBar();</xsl:attribute>
    </xsl:if>
    -->
  </xsl:template>

  <!-- User HEAD content -->
  <xsl:template name="user.head.content">
    <xsl:if test="$ada.course.icon">
      <link rel="shortcut icon">
        <xsl:attribute name="href"><xsl:value-of
        select="$ada.course.icon"/></xsl:attribute>
        <xsl:attribute name="type"><xsl:value-of 
        select="$ada.course.icon.type"/></xsl:attribute>
      </link>
    </xsl:if>

    <xsl:if test="$ada.page.author">
      <xsl:element name="meta">
        <xsl:attribute name="name">Author</xsl:attribute>
        <xsl:attribute name="content">
          <xsl:value-of select="$ada.page.author"/>
        </xsl:attribute>
      </xsl:element>
    </xsl:if>

    <!-- Stick the javascript for the flash player -->
    <xsl:if test="$ada.page.flash.player.javascript">
      <script type="text/javascript" language="JavaScrpt">
        <xsl:attribute name="src"><xsl:value-of
        select="$ada.page.flash.player.javascript"/></xsl:attribute>
      </script>
    </xsl:if>

    <!-- If refresh rate has been given, include it -->
    <xsl:if test="$ada.page.refresh.rate">
      <meta http-equiv="refresh">
        <xsl:attribute name="content"><xsl:value-of 
        select="$ada.page.refresh.rate"/></xsl:attribute>
      </meta>
    </xsl:if>
    <meta http-equiv="Content-Style-Type" content="text/css"/>
    <xsl:if test="$ada.page.cssstyle.url">
      <link rel="stylesheet" type="text/css">
        <xsl:attribute name="href"><xsl:value-of
        select="$ada.page.cssstyle.url"/></xsl:attribute>
      </link>
    </xsl:if>

    <!-- Insert the reference to the RSS channel if given -->
    <xsl:if test="$ada.rss.channel.url">
      <link rel="alternate" type="application/rss+xml" title="rss">
        <xsl:attribute name="href"><xsl:value-of
        select="$ada.rss.channel.url"/></xsl:attribute>
      </link>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="user.header.content">
    <xsl:param name="node" select="."/>
    
    <!-- Insert Google Analytics snippet -->
    <xsl:if test="$ada.page.google.analytics.account">
      <script src="http://www.google-analytics.com/urchin.js" 
        type="text/javascript">
      </script>
      <script type="text/javascript">
        _uacct = "<xsl:value-of select="$ada.page.google.analytics.account"/>";
        urchinTracker();
      </script>
    </xsl:if>

    <xsl:comment> ######## Beginning of title ######## </xsl:comment>
    <div id="titlebox">
      <xsl:if test="$ada.page.head.left.logo or $ada.page.head.center.top.logo 
                    or $ada.page.head.right.logo or $ada.page.head.center.bottom">
        <table cellspacing="0" cellpadding="0"
          style="border:0; width:100%">
          <tr>
            <td>
              <table style="border:0" cellspacing="1" cellpadding="0">
                <xsl:if test="$ada.page.head.left.logo or $ada.page.head.center.top.logo 
                              or $ada.page.head.right.logo">
                  <tr style="background-color: #FFFFFF">
                    <xsl:if test="$ada.page.head.left.logo">
                      <td rowspan="2" style="border:1px solid black;">
                        <a>
                          <xsl:if test="$ada.page.head.left.logo.url">
                            <xsl:attribute name="href"><xsl:value-of 
                            select="$ada.page.head.left.logo.url"/></xsl:attribute>
                          </xsl:if>
                          <img
                            style="vertical-align: bottom; border: 0;">
                            <xsl:if test="$ada.page.head.left.logo.alt">
                              <xsl:attribute name="src"><xsl:value-of 
                              select="$ada.page.head.left.logo.alt"/></xsl:attribute>
                            </xsl:if>
                            <xsl:attribute name="src"><xsl:value-of 
                            select="$ada.page.head.left.logo"/></xsl:attribute>
                          </img>
                        </a>
                      </td>
                    </xsl:if>
                    <xsl:if test="$ada.page.head.center.top.logo">
                      <td style="border:1px solid black; ">
                        <div style="text-align: center;">
                          <a>
                            <xsl:if test="$ada.page.head.center.top.logo.url">
                              <xsl:attribute name="href"><xsl:value-of 
                              select="$ada.page.head.center.top.logo.url"/></xsl:attribute>
                            </xsl:if>
                            <img
                              style="vertical-align: bottom; border: 0;">
                              <xsl:if test="$ada.page.head.center.top.logo.alt">
                                <xsl:attribute name="alt"><xsl:value-of 
                                select="$ada.page.head.center.top.logo.alt"/></xsl:attribute>
                              </xsl:if>
                              <xsl:attribute name="src"><xsl:value-of
                              select="$ada.page.head.center.top.logo"/></xsl:attribute>
                            </img>
                          </a>
                        </div>
                      </td>
                    </xsl:if>
                    <xsl:if test="$ada.page.head.right.logo">
                      <td rowspan="2" style="border:1px solid black;">
                        <a>
                          <xsl:if test="$ada.page.head.right.logo.url">
                            <xsl:attribute name="href"><xsl:value-of 
                            select="$ada.page.head.right.logo.url"/></xsl:attribute>
                          </xsl:if>
                          <img
                            style="vertical-align: bottom; border: 0;">
                            <xsl:if test="$ada.page.head.right.logo.alt">
                              <xsl:attribute name="src"><xsl:value-of 
                              select="$ada.page.head.right.logo.alt"/></xsl:attribute>
                            </xsl:if>
                            <xsl:attribute name="src"><xsl:value-of 
                            select="$ada.page.head.right.logo"/></xsl:attribute>
                          </img>
                        </a>
                      </td>
                    </xsl:if>
                  </tr>
                </xsl:if>
                <xsl:if test="$ada.page.head.center.bottom">
                  <tr>
                    <td style="border:1px solid black; background-color: #CCD0D6;" 
                      valign="middle">
                      <div class="noprint" style="text-align: center">
                        <xsl:copy-of
                          select="exsl:node-set($ada.page.head.center.bottom)"/>
                      </div>
                    </td>
                  </tr>
                </xsl:if>
              </table>
            </td>
          </tr>
        </table>
      </xsl:if>
      <xsl:if test="$ada.page.head.bigtitle = '1'">
        <table cellspacing="0" cellpadding="0"
          style="border:0; margin-right: auto; margin-left: auto; width: 100%;">
          <tr>
            <td class="noprint" style="text-align: left; vertical-align: top;">
              <xsl:call-template name="ggadgetlink"/>
            </td>
            <xsl:if test="$ada.course.name or ada.course.edition or 
                          ada.course.image">
              <td align="center">
                <xsl:if test="$ada.course.name">
                  <h1><xsl:value-of select="$ada.course.name"/></h1>
                </xsl:if>
                <xsl:if test="$ada.course.edition">
                  <h4><xsl:value-of select="$ada.course.edition"/></h4>
                </xsl:if>
              </td>
              <xsl:if test="$ada.course.image">
                <td align="center">
                  <xsl:element name="img">
                    <xsl:if test="$ada.course.name">
                      <xsl:attribute name="alt"><xsl:value-of 
                      select="$ada.course.name"/></xsl:attribute>
                    </xsl:if>
                    <xsl:attribute name="style">border: 0;</xsl:attribute>
                    <xsl:attribute name="src"><xsl:value-of
                    select="$ada.course.image"/></xsl:attribute>
                  </xsl:element>
                </td>
              </xsl:if>
            </xsl:if>
          </tr>
        </table>
        <hr style="text-align:center;"/>
      </xsl:if>
      <xsl:comment> ######## End of title ######## </xsl:comment>
    </div>
  </xsl:template>
  
  <!-- Footer-->
  <xsl:template name="user.footer.content">
    <div id="tailbox">
      <xsl:comment> ######## Beginning of Tail ######## </xsl:comment>
      <hr style="text-align: center"/>
      <!-- Creative Commons License -->
      <table cellspacing="2" cellpadding="2"
        style="border: 0; margin-left: auto; margin-right: auto">
        <tr>
          <td align="center">
            <xsl:choose>
              <xsl:when test="$profile.lang='en'">
                <small>
                  <xsl:value-of select="$ada.page.license.institution.en"/>
                </small>
              </xsl:when>
              <xsl:otherwise>
                <small>
                  <xsl:value-of select="$ada.page.license.institution.es"/>
                </small>
              </xsl:otherwise>
            </xsl:choose>
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
                  select="$ada.page.license.logo"/></xsl:attribute>
                </xsl:element>
              </a>
            </td>
          </xsl:if>
        </tr>
        <xsl:if test="$ada.page.license = 'yes'">
          <tr>
            <td align="center">
              <small>
                <xsl:choose>
                  <xsl:when test="$profile.lang='en'">
                    Work licensed under 
                  </xsl:when>
                  <xsl:otherwise>
                    Material con licencia
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:text> </xsl:text>
                <a rel="license">
                  <xsl:if test="$ada.page.license.url">
                    <xsl:attribute name="href"><xsl:value-of 
                    select="$ada.page.license"/></xsl:attribute>
                  </xsl:if>
                  Creative Commons
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
            <xsl:when test="$profile.lang='en'">Last Revision:</xsl:when>
            <xsl:otherwise>Última modificación:</xsl:otherwise>
          </xsl:choose>
          <xsl:element name="script">
            <xsl:attribute name="type">text/javascript</xsl:attribute>
            <xsl:text>
              document.write(document.lastModified)
            </xsl:text>
          </xsl:element>
        </p>
      </xsl:if>
      <xsl:comment> ######## End of Tail ######## </xsl:comment>
    </div>
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
              test="$profile.lang = 'en'">Add a gadget to your personal page in Google</xsl:when>
            <xsl:otherwise>Añade un gadget a tu página personal en Google</xsl:otherwise>
          </xsl:choose></xsl:attribute>
        </img>
      </a>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
