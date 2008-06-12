<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0" exclude-result-prefixes="exsl">

  <xsl:param name="chatroom.link"/>

  <!-- Variable that takes either a para with
       condition="chatroom.link" or the value of the parameter (in
       this order) -->
  <xsl:variable name="chatroom.link.var">
    <xsl:choose>
      <xsl:when test="//*/note[@condition='AdminInfo']/para[@condition='chatroom.link']">
        <xsl:value-of select="//*/note[@condition='AdminInfo']/para[@condition='chatroom.link']/text()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$chatroom.link"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:template name="InsertChatRoomLink">
    <xsl:if test="$chatroom.link.var != ''">
      <div class="noprint head-center">
        <a>
          <xsl:attribute name="href">
            <xsl:value-of select="$chatroom.link.var"/>
          </xsl:attribute>
          <xsl:attribute name="target">_blank</xsl:attribute>
          <xsl:choose>
            <xsl:when test="$profile.lang='en'">
              Link to the course chat room
            </xsl:when>
            <xsl:otherwise>Enlace a la sala de chat del curso</xsl:otherwise>
          </xsl:choose>
        </a>
        <hr class="head-center"/>
      </div>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
