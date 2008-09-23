<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0" exclude-result-prefixes="exsl str xi">

  <!-- Bring in all the parameters -->
  <xsl:import href="AsapAuthorBoxParams.xsl"/>
  
  <!-- ******************************************************************* -->
  <!--                                                                     -->
  <!-- Template to produce author box                                      -->
  <!--                                                                     -->
  <!-- ******************************************************************* -->
  <xsl:template name="ada.asap.author.box">
    <table>
      <tr>
        <td>
          <table style="border: 1px solid black; 
                        background-color: rgb(204, 204, 233)" 
            cellpadding="4">
            <!-- for ( i = I ; i OPERATOR TESTVALUE; i += INCREMENT ) -->
            <!-- for ( i = 1 ; i &lt;= 4; i += 1 ) -->
            <xsl:call-template name="author.loop">
              <xsl:with-param name="i"         select="'1'"/>
              <xsl:with-param name="increment" select="'1'"/>
              <xsl:with-param name="operator"  select="'&lt;='"/>
              <xsl:with-param name="testValue" select="$ada.asap.num.authors"/>
            </xsl:call-template>
            <tr>
              <td colspan="2" style="background-color: rgb(255, 255, 255); 
                                     border: 1px solid black"/></tr>
            <xsl:if test="$ada.asap.include.password = 'one'">
              <tr style="border: 1px solid black;">
                <td style="text-align: right">
                  <xsl:choose>
                    <xsl:when test="$ada.asap.num.authors &gt; 1">
                      <xsl:choose>
                        <xsl:when test="$profile.lang='en'">
                          Any author password
                        </xsl:when>
                        <xsl:otherwise>Clave de un autor</xsl:otherwise>
                      </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:choose>
                        <xsl:when test="$profile.lang='en'">Password</xsl:when>
                        <xsl:otherwise>Clave</xsl:otherwise>
                      </xsl:choose>
                    </xsl:otherwise>
                  </xsl:choose>
                </td>
                <td>
                  <input type="password" name="asap:password_0"
                    size="20"/>
                  <xsl:text> </xsl:text>
                  <img alt="Info" style="border: 0; vertical-align: middle">
                    <xsl:attribute name="src"><xsl:value-of
                    select="$ada.course.home"/>/images/info.png</xsl:attribute>
                    <xsl:attribute name="title">
                      <xsl:choose>
                        <xsl:when
                          test="$profile.lang='en'">Password of any of the authors</xsl:when>
                        <xsl:otherwise>Clave de cualquiera de los autores</xsl:otherwise>
                      </xsl:choose>
                    </xsl:attribute>
                  </img>
                </td>
              </tr>
            </xsl:if>
            <xsl:if test="$ada.asap.include.groupname = 'yes'">
              <tr style="border: 1px solid black;">
                <td style="text-align: right">
                  <xsl:choose>
                    <xsl:when test="$profile.lang='en'">Group Nick</xsl:when>
                    <xsl:otherwise>Nick de grupo</xsl:otherwise>
                  </xsl:choose>
                </td>
                <td>
                  <input type="text" name="__nick__" size="20"/>
                  <xsl:text> </xsl:text>
                  <img alt="Info" style="border: 0; vertical-align: middle">
                    <xsl:attribute name="src"><xsl:value-of
                    select="$ada.course.home"/>/images/info.png</xsl:attribute>
                    <xsl:attribute name="title">
                      <xsl:choose>
                        <xsl:when
                          test="$profile.lang='en'">Group name for the result table</xsl:when>
                        <xsl:otherwise>Nombre del grupo para la tabla de resultados</xsl:otherwise>
                      </xsl:choose>
                    </xsl:attribute>
                  </img>
                </td>
              </tr>
            </xsl:if>
            <xsl:if test="$ada.asap.confirmation.email = 'yes'">
              <tr style="border: 1px solid black;">
                <td style="text-align: right">
                  <xsl:choose>
                    <xsl:when test="$profile.lang='en'">Confirmation Email</xsl:when>
                    <xsl:otherwise>Email de confirmación</xsl:otherwise>
                  </xsl:choose><sup>*</sup>
                </td>
                <td>
                  <input type="text" name="asap:Email" size="40"/>
                </td>
              </tr>
            </xsl:if>

            <tr style="border: 1px solid black;">
              <td colspan="2" style="background-color: rgb(255, 255, 255);"/>
            </tr>
            <xsl:variable name="submit.count" 
              select="count(//*/section[@condition='submit']) + 
                      count(//*/note[@condition='submit'])"/>
            <xsl:for-each select="//*/section[@condition='submit']|//*/note[@condition='submit']">
              <tr>
                <xsl:choose>
                  <xsl:when test="$submit.count &gt; 1">
                    <td align="center">
                      <b><xsl:apply-templates select="../title/node()"/></b>
                    </td>
                    <td>
                      <xsl:apply-templates/>
                    </td>
                  </xsl:when>
                  <xsl:otherwise>
                    <td colspan="2">
                      <xsl:apply-templates/>
                    </td>
                  </xsl:otherwise>
                </xsl:choose>
              </tr>
            </xsl:for-each>
          </table>
        </td>
      </tr>      
    </table>
  </xsl:template>

  <!-- for ( i = I ; i OPERATOR TESTVALUE; i += INCREMENT ) -->
  <xsl:template name="author.loop">
    <!-- By default, this template does not perform any iteration -->
    <!-- for ( i = 1; i <= 0; i++) -->
    <xsl:param name="i"         select="1"/>
    <xsl:param name="increment" select="1"/>
    <xsl:param name="operator"  select="'&lt;='"/>
    <xsl:param name="testValue" select="0"/>

    <xsl:variable name="testPassed">
      <xsl:choose>
        <xsl:when test="starts-with($operator, '!=')">
          <xsl:if test="$i != $testValue">
            <xsl:text>true</xsl:text>
          </xsl:if>
        </xsl:when>
        <xsl:when test="starts-with($operator, '&lt;=')">
          <xsl:if test="$i &lt;= $testValue">
            <xsl:text>true</xsl:text>
          </xsl:if>
        </xsl:when>
        <xsl:when test="starts-with($operator, '&gt;=')">
          <xsl:if test="$i &gt;= $testValue">
            <xsl:text>true</xsl:text>
          </xsl:if>
        </xsl:when>
        <xsl:when test="starts-with($operator, '=')">
          <xsl:if test="$i = $testValue">
            <xsl:text>true</xsl:text>
          </xsl:if>
        </xsl:when>
        <xsl:when test="starts-with($operator, '&lt;')">
          <xsl:if test="$i &lt; $testValue">
            <xsl:text>true</xsl:text>
          </xsl:if>
        </xsl:when>
        <xsl:when test="starts-with($operator, '&gt;')">
          <xsl:if test="$i &gt; $testValue">
            <xsl:text>true</xsl:text>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message terminate="yes">
            <xsl:text>Sorry, the loop emulator only </xsl:text>
            <xsl:text>handles six operators </xsl:text>
            <xsl:value-of select="$newline"/>
            <xsl:text>(&lt; | &gt; | = | &lt;= | &gt;= | !=). </xsl:text>
            <xsl:text>The value </xsl:text>
            <xsl:value-of select="$operator"/>
            <xsl:text> is not allowed.</xsl:text>
            <xsl:value-of select="$newline"/>
          </xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="$testPassed='true'">
      <!-- Put your logic here, whatever it might be. For the purpose      -->
      <!-- of our example, we'll just write some text to the output stream. -->
      <xsl:if test="$ada.asap.num.authors &gt; 1">
        <tr>
          <td colspan="2" 
            style="background-color: rgb(255, 255, 255); 
                   text-align: center; border: 1px solid black">
            <xsl:choose>
              <xsl:when test="$profile.lang='en'">
                Author <xsl:value-of select="$i" />
              </xsl:when>
              <xsl:otherwise>Autor <xsl:value-of select="$i"/></xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
      </xsl:if>

      <!-- We cannot push the choose to the inside because there is
           always the possibility of having the value "none" which means,
           there should be no box with full name info 
           -->
      <xsl:choose>
        <xsl:when test="$ada.asap.include.id = 'nia'">
          <tr style="border: 1px solid black">
            <td style="text-align: right">
              <xsl:choose>
                <xsl:when test="$profile.lang='en'">
                  Student ID (9 digits)
                </xsl:when>
                <xsl:otherwise>NIA (9 dígitos)</xsl:otherwise>
              </xsl:choose>
            </td>
            <td>
              <xsl:element name="input">
                <xsl:attribute name="type">text</xsl:attribute>
                <xsl:attribute name="size">50</xsl:attribute>
                <xsl:attribute name="maxlength">50</xsl:attribute>
                <xsl:attribute name="name">asap:id_<xsl:value-of select="$i - 1"/></xsl:attribute>
              </xsl:element>
            </td>
          </tr>
        </xsl:when>
        <xsl:when test="$ada.asap.include.id = 'email'">
          <tr>
            <td style="text-align: right">
              <xsl:choose>
                <xsl:when 
                  test="$profile.lang='en'">Student Email</xsl:when>
                <xsl:otherwise>Correo de alumno</xsl:otherwise>
              </xsl:choose>
            </td>
            <td>
              <xsl:element name="input">
                <xsl:attribute name="type">text</xsl:attribute>
                <xsl:attribute name="size">25</xsl:attribute>
                <xsl:attribute name="maxlength">25</xsl:attribute>
                <xsl:attribute name="name">asap:id_<xsl:value-of select="$i - 1"/></xsl:attribute>
              </xsl:element>
            </td>
          </tr>
        </xsl:when>
        <xsl:when test="$ada.asap.include.id = 'custom'">
          <tr>
            <td style="text-align: right">
              <xsl:value-of select="$ada.asap.id.text"/>
            </td>
            <td>
              <xsl:element name="input">
                <xsl:attribute name="type">text</xsl:attribute>
                <xsl:attribute name="size">25</xsl:attribute>
                <xsl:attribute name="maxlength">25</xsl:attribute>
                <xsl:attribute name="name">asap:id_<xsl:value-of select="$i - 1"/></xsl:attribute>
              </xsl:element>
            </td>
          </tr>
        </xsl:when>
      </xsl:choose>

      <xsl:if test="$ada.asap.include.password = 'all'">
        <tr>
          <td style="text-align: right">
            <xsl:choose>
              <xsl:when test="$profile.lang='en'">Password</xsl:when>
              <xsl:otherwise>Clave</xsl:otherwise>
            </xsl:choose>
          </td>
          <td>
            <xsl:element name="input">
              <xsl:attribute name="type">password</xsl:attribute>
              <xsl:attribute name="size">25</xsl:attribute>
              <xsl:attribute name="maxlength">25</xsl:attribute>
              <xsl:attribute name="name">asap:password_<xsl:value-of select="$i - 1"/></xsl:attribute>
            </xsl:element>
          </td>
        </tr>
      </xsl:if>
      <xsl:if test="$ada.asap.include.fullname = 'yes'">
        <tr>
          <xsl:choose>
            <xsl:when test="$profile.lang='en'">
              <td style="text-align: right">First Name</td>
            </xsl:when>
            <xsl:otherwise>
              <td style="text-align: right">Nombre</td>
            </xsl:otherwise>
          </xsl:choose>
          <td>
            <xsl:element name="input">
              <xsl:attribute name="type">text</xsl:attribute>
              <xsl:attribute name="size">20</xsl:attribute>
              <xsl:attribute name="name">asap:firstName_<xsl:value-of select="$i - 1"/></xsl:attribute>
            </xsl:element>
          </td>
        </tr>
        <tr>
          <xsl:choose>
            <xsl:when test="$profile.lang='en'">
              <td style="text-align: right">Last Name</td>
            </xsl:when>
            <xsl:otherwise>
              <td style="text-align: right">Apellidos</td>
            </xsl:otherwise>
          </xsl:choose>
          <td>
            <xsl:element name="input">
              <xsl:attribute name="type">text</xsl:attribute>
              <xsl:attribute name="size">40</xsl:attribute>
              <xsl:attribute
                name="name">asap:lastName_<xsl:value-of select="$i - 1"/></xsl:attribute>
            </xsl:element>
          </td>
        </tr>
      </xsl:if>

      <!-- Your logic should end here; don't change the rest of this        -->
      <!-- template!                                                        -->

      <!-- Now for the important part: we increment the index variable and  -->
      <!-- loop. Notice that we're passing the incremented value, not      -->
      <!-- changing the variable itself.                                   -->

      <xsl:call-template name="author.loop">
        <xsl:with-param name="i"         select="$i + $increment"/>
        <xsl:with-param name="increment" select="$increment"/>
        <xsl:with-param name="operator"  select="$operator"/>
        <xsl:with-param name="testValue" select="$testValue"/>
      </xsl:call-template>
    </xsl:if> 
  </xsl:template>
</xsl:stylesheet>
