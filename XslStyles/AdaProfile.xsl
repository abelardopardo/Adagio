<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:date="http://exslt.org/dates-and-times"
  version="1.0">

  <!-- This variable is supposed to have the format YYYY-MM-DDTHH:MM:SS -->
  <xsl:param name="ada.current.datetime" select="''"/> 
  <xsl:param name="ada.audience.date.separator" select="'--'"/>
  <xsl:param name="ada.audience.debug"/>

  <!-- 
       Translate the previous variable from its original format to
       YYYYMMDDHHMMSS to simplify comparison. If it is empty, obtain the current
       date/time 
       -->
  <xsl:variable name="ada.audience.date.now">
    <xsl:call-template name="date.translate.to.simple.string">
      <xsl:with-param name="string.to.process">
        <xsl:choose>
          <xsl:when test="($ada.current.datetime) and 
                          ($ada.current.datetime != '')">
            <xsl:value-of select="$ada.current.datetime" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="date:date-time()" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:variable>

  <!-- Profile elements based on input parameters -->
  <xsl:template match="*" mode="profile">
    
    <xsl:variable name="arch.content">
      <xsl:if test="@arch">
        <xsl:call-template name="cross.compare">
          <xsl:with-param name="a" select="$profile.arch"/>
          <xsl:with-param name="b" select="@arch"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="arch.ok" select="not(@arch) or not($profile.arch) or
                                         $arch.content != '' or @arch = ''"/>
    
    <!-- 
         This is the modification. Check for dates rather than simple string
         inclusion
         -->
    <xsl:variable name="audience.content">
      <xsl:if test="@audience">
        <xsl:call-template name="audience.date.compare">
          <xsl:with-param name="audience.value" select="@audience"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="audience.ok" 
      select="not(@audience) or not($profile.audience) or
              $audience.content != '' or @audience = ''"/>
    <!-- End of content check -->
    
    <xsl:variable name="condition.content">
      <xsl:if test="@condition">
        <xsl:call-template name="cross.compare">
          <xsl:with-param name="a" select="$profile.condition"/>
          <xsl:with-param name="b" select="@condition"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="condition.ok" 
      select="not(@condition) or not($profile.condition) or
              $condition.content != '' or @condition = ''"/>
    
    <xsl:variable name="conformance.content">
      <xsl:if test="@conformance">
        <xsl:call-template name="cross.compare">
          <xsl:with-param name="a" select="$profile.conformance"/>
          <xsl:with-param name="b" select="@conformance"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="conformance.ok" 
      select="not(@conformance) or not($profile.conformance) or
              $conformance.content != '' or @conformance = ''"/>
    
    <xsl:variable name="lang.content">
      <xsl:if test="@lang | @xml:lang">
        <xsl:call-template name="cross.compare">
          <xsl:with-param name="a" select="$profile.lang"/>
          <xsl:with-param name="b" select="(@lang | @xml:lang)[1]"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="lang.ok" 
      select="not(@lang | @xml:lang) or not($profile.lang) or
              $lang.content != '' or @lang = '' or @xml:lang = ''"/>
    
    <xsl:variable name="os.content">
      <xsl:if test="@os">
        <xsl:call-template name="cross.compare">
          <xsl:with-param name="a" select="$profile.os"/>
          <xsl:with-param name="b" select="@os"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="os.ok" select="not(@os) or not($profile.os) or
                                       $os.content != '' or @os = ''"/>
    
    <xsl:variable name="revision.content">
      <xsl:if test="@revision">
        <xsl:call-template name="cross.compare">
          <xsl:with-param name="a" select="$profile.revision"/>
          <xsl:with-param name="b" select="@revision"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="revision.ok" 
      select="not(@revision) or not($profile.revision) or
              $revision.content != '' or @revision = ''"/>
    
    <xsl:variable name="revisionflag.content">
      <xsl:if test="@revisionflag">
        <xsl:call-template name="cross.compare">
          <xsl:with-param name="a" select="$profile.revisionflag"/>
          <xsl:with-param name="b" select="@revisionflag"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="revisionflag.ok" 
      select="not(@revisionflag) or not($profile.revisionflag) or
              $revisionflag.content != '' or @revisionflag = ''"/>
    
    <xsl:variable name="role.content">
      <xsl:if test="@role">
        <xsl:call-template name="cross.compare">
          <xsl:with-param name="a" select="$profile.role"/>
          <xsl:with-param name="b" select="@role"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="role.ok" select="not(@role) or not($profile.role) or
                                         $role.content != '' or @role = ''"/>
    
    <xsl:variable name="security.content">
      <xsl:if test="@security">
        <xsl:call-template name="cross.compare">
          <xsl:with-param name="a" select="$profile.security"/>
          <xsl:with-param name="b" select="@security"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="security.ok" 
      select="not(@security) or not($profile.security) or
              $security.content != '' or @security = ''"/>
    
    <xsl:variable name="status.content">
      <xsl:if test="@status">
        <xsl:call-template name="cross.compare">
          <xsl:with-param name="a" select="$profile.status"/>
          <xsl:with-param name="b" select="@status"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="status.ok" select="not(@status) or not($profile.status) or
                                           $status.content != '' or @status = ''"/>
    
    <xsl:variable name="userlevel.content">
      <xsl:if test="@userlevel">
        <xsl:call-template name="cross.compare">
          <xsl:with-param name="a" select="$profile.userlevel"/>
          <xsl:with-param name="b" select="@userlevel"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="userlevel.ok" 
      select="not(@userlevel) or not($profile.userlevel) or
              $userlevel.content != '' or @userlevel = ''"/>
    
    <xsl:variable name="vendor.content">
      <xsl:if test="@vendor">
        <xsl:call-template name="cross.compare">
          <xsl:with-param name="a" select="$profile.vendor"/>
          <xsl:with-param name="b" select="@vendor"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="vendor.ok" select="not(@vendor) or not($profile.vendor) or
                                           $vendor.content != '' or @vendor = ''"/>
    
    <xsl:variable name="wordsize.content">
      <xsl:if test="@wordsize">
        <xsl:call-template name="cross.compare">
          <xsl:with-param name="a" select="$profile.wordsize"/>
          <xsl:with-param name="b" select="@wordsize"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="wordsize.ok" 
      select="not(@wordsize) or not($profile.wordsize) or
              $wordsize.content != '' or @wordsize = ''"/>
    
    <xsl:variable name="attribute.content">
      <xsl:if test="@*[local-name()=$profile.attribute]">
        <xsl:call-template name="cross.compare">
          <xsl:with-param name="a" select="$profile.value"/>
          <xsl:with-param name="b" select="@*[local-name()=$profile.attribute]"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="attribute.ok" 
      select="not(@*[local-name()=$profile.attribute]) or 
              not($profile.value) or $attribute.content != '' or 
              @*[local-name()=$profile.attribute] = '' or 
              not($profile.attribute)"/>
    
    <xsl:if test="$arch.ok and 
                  $audience.ok and 
                  $condition.ok and 
                  $conformance.ok and 
                  $lang.ok and 
                  $os.ok and 
                  $revision.ok and 
                  $revisionflag.ok and 
                  $role.ok and 
                  $security.ok and 
                  $status.ok and 
                  $userlevel.ok and 
                  $vendor.ok and 
                  $wordsize.ok and 
                  $attribute.ok">
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <!-- 
             Entity references must be replaced with filereferences for
             temporary tree 
             -->
        <xsl:if test="@entityref and $profile.baseuri.fixup">
          <xsl:attribute name="fileref">
            <xsl:value-of select="unparsed-entity-uri(@entityref)"/>
          </xsl:attribute>
        </xsl:if>
        
        <!-- xml:base is eventually added to the root element -->
        <xsl:if test="not(../..) and $profile.baseuri.fixup">
          <xsl:call-template name="add-xml-base"/>
        </xsl:if>
        
        <xsl:apply-templates select="node()" mode="profile"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
  
  <!-- 
       Template the receives as parameter the value of the audience
       attribute. Such value is supposed to contain two date/times in the
       following format YYYY/mm/dd HH:MM[sep]YYYY/mm/dd HH:MM (where [sep] is
       the value of the variable ada.audience.date.separator) and checks that the
       value of the global variable ada.current.datetime is a date/time
       contained in between the two given dates.

       If ada.current.datetime is empty, then the current date/time is
       taken.
  -->
  <xsl:template name="audience.date.compare">
    <xsl:param name="audience.value"/>
    <xsl:choose>
      <!-- 
           Execute the transformation only if the audience.value has the format
           YYYY-MM-DDTHH:MM:SS 
           -->
      <xsl:when test="contains($audience.value, $ada.audience.date.separator)">
        <!-- Translate the start date to YYYMMDDHHMMSS -->
        <xsl:variable name="audience.start.date">
          <xsl:call-template name="date.translate.to.simple.string">
            <xsl:with-param name="string.to.process">
              <xsl:value-of select="substring-before($audience.value, 
                                                     $ada.audience.date.separator)"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:variable>
        <!-- Translate the end date to YYYMMDDHHMMSS -->
        <xsl:variable name="audience.end.date">
          <xsl:call-template name="date.translate.to.simple.string">
            <xsl:with-param name="string.to.process">
              <xsl:value-of select="substring-after($audience.value, 
                                                    $ada.audience.date.separator)"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:variable>

        <!-- And this is the key point. If the condition is true, some text ends
             up as the result of the template and the content is considered. If
             not, the result is empty and the content will be ignored 

             ((audience.start.date = '' or 
               audience.start.date BEFORE ada.audience.date.now ))
             and
             ((audience.enddate = '' or 
               ada.audience.date.now BEFORE audience.end.date))
             -->
        <xsl:if test="$ada.audience.debug = 'true'">
          <xsl:message>
            audience.value: <xsl:value-of select="$audience.value"/>
            audience.start.date:  <xsl:value-of select="$audience.start.date"/>
            ada.audience.date.now:<xsl:value-of select="$ada.audience.date.now"/>
            audience.end.date:    <xsl:value-of select="$audience.end.date"/>
            Cnd1 : <xsl:value-of select="$audience.start.date = ''"/>
            Cnd2 : <xsl:value-of select="$audience.start.date &lt;= $ada.audience.date.now"/>
            Cnd3 : <xsl:value-of select="$audience.end.date = ''"/>
            Cnd4 : <xsl:value-of select="$ada.audience.date.now &lt;= $audience.end.date"/>
          </xsl:message>
        </xsl:if>

        <xsl:if test="(($audience.start.date = '') 
                        or ($audience.start.date &lt;= $ada.audience.date.now)) 
                      and
                      (($audience.end.date = '') 
                        or ($ada.audience.date.now &lt;= $audience.end.date))">
          <xsl:value-of select="$ada.audience.date.now"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>
          Incorrect audience value<xsl:value-of select="$audience.value"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- 
       Translate a date template. If it is empty, return nothing, thus the empty
       string. This is to translate a date to a string that can be easily
       compared. It is not clear if two dates can be compared directly, that is
       the reason for this function.
       -->
  <xsl:template name="date.translate.to.simple.string">
    <xsl:param name="string.to.process"/>
    <xsl:if test="($string.to.process != '') and 
                  (string-length($string.to.process) &gt;= 19)">
      <xsl:value-of 
        select="substring($string.to.process,  1, 4)"/><xsl:value-of
        select="substring($string.to.process,  6, 2)"/><xsl:value-of
        select="substring($string.to.process,  9, 2)"/><xsl:value-of
        select="substring($string.to.process, 12, 2)"/><xsl:value-of
        select="substring($string.to.process, 15, 2)"/><xsl:value-of
        select="substring($string.to.process, 18, 2)"/>
    </xsl:if>
  </xsl:template>

  <!-- Returns non-empty string if list in $b contains one ore more values from list $a -->
  <xsl:template name="cross.compare">
    <xsl:param name="a"/>
    <xsl:param name="b"/>
    <xsl:param name="sep" select="$profile.separator"/>
    <xsl:variable name="head" select="substring-before(concat($a, $sep), $sep)"/>
    <xsl:variable name="tail" select="substring-after($a, $sep)"/>
    <xsl:if test="contains(concat($sep, $b, $sep), concat($sep, $head, $sep))">1</xsl:if>
    <xsl:if test="$tail">
      <xsl:call-template name="cross.compare">
        <xsl:with-param name="a" select="$tail"/>
        <xsl:with-param name="b" select="$b"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>

