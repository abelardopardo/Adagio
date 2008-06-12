<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:exsl="http://exslt.org/common" 
  xmlns="http://www.w3.org/1999/xhtml" 
  exclude-result-prefixes="exsl" version="1.0">

  <!-- Lang attribute -->
  <xsl:param name="lang"/>

  <!-- Show the qandadiv ID -->
  <xsl:param name="include.id" select="'no'"/>

  <!-- Insert history remarks -->
  <xsl:param name="include.history" select="'no'"/>

  <!-- Insert pagebreaks as specified in the sectioninfo -->
  <xsl:param name="insert.pagebreaks" select="'yes'"/>

  <!-- Render one question per page -->
  <xsl:param name="render.onequestionperpage" select="'no'"/>

  <!-- Size of the square to mark -->
  <xsl:param name="render.squaresize" select="'10pt'"/>

  <!-- Number QandA with correlative integers within a section -->
  <xsl:template match="question" mode="label.markup">
    <xsl:number level="any" count="qandaentry" from="section" format="1"/>
  </xsl:template>

  <!-- Those qandadiv with condition TestQuestion or TestMCQuestion
       are processed in a different way -->
  <xsl:template match="qandadiv[@condition='TestQuestion']|qandadiv[@condition='TestMCQuestion']">
    <xsl:variable name="beginnumber">
      <xsl:number level="any" count="qandaentry" from="section"/>
    </xsl:variable>
    <xsl:variable name="qnumber" select="count(descendant::qandaentry)"/>
    <!-- 
         FIX: Needs to check for the presence of some sort of
         blockinfo that instructs this table to have a
         class="pageBreakBefore" attribute 
    -->
    <table style="border: 1px solid black; border-collapse: collapse;pageBreakInside: false" 
      width="100%" align="center" cellspacing="5" cellpadding="5">
      <xsl:if 
        test="($render.onequestionperpage = 'yes') or
              ((/section/sectioninfo/productnumber/remark[@condition=($beginnumber + 1)]) and
              ($insert.pagebreaks = 'yes'))">
        <xsl:attribute name="class">pageBreakBefore</xsl:attribute>
      </xsl:if>
      <tr>
        <td>
          <p style="margin-top: 0pt">
            <b>
              <xsl:choose>
                <xsl:when test="$qnumber > 1">
                  <xsl:choose>
                    <xsl:when test="$profile.lang='en'">Questions </xsl:when>
                    <xsl:otherwise>Preguntas </xsl:otherwise>
                  </xsl:choose>
                  <xsl:value-of select="$beginnumber + 1"/>
                  <xsl:choose>
                    <xsl:when test="$profile.lang='en'"> to </xsl:when>
                    <xsl:otherwise> a </xsl:otherwise>
                  </xsl:choose>
                  <xsl:value-of select="$beginnumber + $qnumber"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:choose>
                    <xsl:when test="$profile.lang='en'">Question </xsl:when>
                    <xsl:otherwise>Pregunta </xsl:otherwise>
                  </xsl:choose>
                  <xsl:value-of select="$beginnumber + 1"/>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="$include.id = 'yes'">
                (id = <xsl:value-of select="@id"/>
                <xsl:if test="blockinfo/author">
                  <xsl:text>, </xsl:text>
                  <xsl:value-of select="blockinfo/author/personname/firstname/text()"/>
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="blockinfo/author/personname/surname/text()"/>
                </xsl:if>
                <xsl:for-each select="blockinfo/printhistory/para">
                  <xsl:text>, </xsl:text><xsl:value-of select="@arch"/>/<xsl:value-of select="@revision"/>/<xsl:value-of select="@vendor"/>
                </xsl:for-each>)
              </xsl:if>
            </b>
          </p>

          <!-- Recur through other DocBook elements -->
          <xsl:apply-templates/>

          <!-- Needed to separate the True/False boxes from peceeding
               text -->
          <br/>
              
          <xsl:choose>
            <xsl:when test="count(qandaentry) = 1">
              <xsl:for-each select="qandaentry">
                <xsl:call-template name="singlequestion"/>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="multiplequestion"/>
            </xsl:otherwise>
          </xsl:choose>
        </td>
      </tr>
    </table>
    <br />
  </xsl:template>

  <xsl:template match="qandaentry">
    <!--
    match="qandaentry[@condition='TestQuestion']|qandadiv[@condition='TestQuestion']//qandaentry">
    -->
    <xsl:if test="not(boolean(ancestor::qandadiv))">
      <table style="border: 1px solid black; border-collapse: collapse;pageBreakInside: false" 
        width="100%" align="center" cellspacing="3" cellpadding="3">
        <tr>
          <td>
            <b>
              <xsl:choose>
                <xsl:when test="$profile.lang='en'">Question</xsl:when>
                <xsl:otherwise>Pregunta</xsl:otherwise>
              </xsl:choose>
              <xsl:value-of select="count(ancestor::section/preceding::qandaentry) + 1"/>
              <xsl:if test="$include.id = 'yes'">
                (id=<xsl:value-of select="@id"/>
                <xsl:for-each select="blockinfo/printhistory/para">
                  , <xsl:value-of select="@arch"/>/<xsl:value-of select="@revision"/>/<xsl:value-of select="@vendor"/>
                </xsl:for-each>)
              </xsl:if>
            </b>
            <p />
            <xsl:call-template name="singlequestion"/>
          </td>
        </tr>
      </table>
      
      <!-- <br /> -->
    </xsl:if>
  </xsl:template>
  
  <!-- Formats a qandaentry. To be used, either when not in a
       qandadiv, or if in a qandadiv but the only one -->
  <xsl:template name="singlequestion">
    <xsl:choose>
      <xsl:when test="count(answer) = 1">
        <xsl:call-template name="singleTFquestion"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="singleMCquestion"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- One single TF question -->
  <xsl:template name="singleTFquestion">
    <table style="border: 0; border-collapse: collapse;pageBreakInside: false" 
      width="95%" align="center" cellspacing="0" cellpadding="3">
      <tr>
        <th width="5%">
          <xsl:choose>
            <xsl:when test="$profile.lang='en'">True</xsl:when>
            <xsl:otherwise>Verdadero</xsl:otherwise>
          </xsl:choose>
        </th>
        <th width="10pt"/>
        <th width="5%">
          <xsl:choose>
            <xsl:when test="$profile.lang='en'">False</xsl:when>
            <xsl:otherwise>Falso</xsl:otherwise>
          </xsl:choose>
        </th>
        <th width="10pt"/>
        <th/>
        <xsl:if test="$include.history='yes'">
          <th/>
        </xsl:if>
      </tr>
      <tr>
        <xsl:variable name="trueBgnd">
          <xsl:choose>
            <xsl:when test="($include.solutions = 'yes') and
                            (contains(answer/@condition, 'Cierto') or
                            contains(answer/@condition, 'Verdadero') or
                            contains(answer/@condition, 'Correct') or
                            contains(answer/@condition, 'True'))">background: black</xsl:when>
            <xsl:otherwise>background: white</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="falseBgnd">
          <xsl:choose>
            <xsl:when test="($include.solutions = 'yes') and
                            (contains(answer/@condition, 'Falso') or
                            contains(answer/@condition, 'False'))">background: black</xsl:when>
            <xsl:otherwise>background: white</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <td align="center" height="20pt">
          <table 
            style="border: 1px solid black; border-collapse: collapse;pageBreakInside: false" 
            align="center">
            <tr>
              <xsl:element name="td">
                <xsl:attribute name="align">center</xsl:attribute>
                <xsl:attribute name="height"><xsl:value-of
                select="$render.squaresize"/></xsl:attribute>
                <xsl:attribute name="width"><xsl:value-of
                select="$render.squaresize"/></xsl:attribute>
                <xsl:attribute name="style">
                  <xsl:value-of select="$trueBgnd"/>
                </xsl:attribute>
              </xsl:element>
            </tr>
          </table>
        </td>
        <td />
        <td align="center" height="20pt">
          <table style="border: 1px solid black; border-collapse:
                        collapse;pageBreakInside:false" 
            align="center">
            <tr>
              <xsl:element name="td">
                <xsl:attribute name="align">center</xsl:attribute>
                <xsl:attribute name="height"><xsl:value-of
                select="$render.squaresize"/></xsl:attribute>
                <xsl:attribute name="width"><xsl:value-of
                select="$render.squaresize"/></xsl:attribute>
                <xsl:attribute name="style">
                  <xsl:value-of select="$falseBgnd"/>
                </xsl:attribute>
              </xsl:element>
            </tr>
          </table>
        </td>
        <td width="10pt"/>
        <td class="qtext">
          <xsl:apply-templates select="question/node()"/>
        </td>
        <xsl:call-template name="dump-history"/>
      </tr>
    </table>
  </xsl:template>
  
  <!-- One single multiple choice question -->
  <xsl:template name="singleMCquestion">
    <xsl:variable name="answerNumber" select="count(answer)"/>
    <xsl:variable name="colspan">
      <xsl:choose>
        <xsl:when test="$include.history = 'yes'">4</xsl:when>
        <xsl:otherwise>3</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <table 
      style="border: 0; border-collapse: collapse;pageBreakInside: false" 
      width="95%" align="center" cellspacing="0" cellpadding="3">
      <tr>
        <td class="qtext">
          <xsl:attribute name="colspan"><xsl:value-of select="$colspan"/></xsl:attribute>
          <xsl:apply-templates select="question/node()"/>
        </td>
      </tr>
      <xsl:for-each select="answer">
        <tr>
          <xsl:variable name="trueBgnd">
            <xsl:choose>
              <xsl:when test="($include.solutions = 'yes') and
                              (contains(@condition, 'Cierto') or
                              contains(@condition, 'Verdadero') or
                              contains(@condition, 'Correct') or
                              contains(@condition, 'True'))">background: black</xsl:when>
              <xsl:otherwise>background: white</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="falseBgnd">
            <xsl:choose>
              <xsl:when test="($include.solutions = 'yes') and
                              (contains(@condition, 'Falso') or
                              contains(@condition, 'False'))">background: black</xsl:when>
              <xsl:otherwise>background: white</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <td align="center" height="20pt">
            <table 
              style="border: 1px solid black; border-collapse: collapse;pageBreakInside: false" 
              width="10pt" align="center">
              <tr>
                <xsl:element name="td">
                  <xsl:attribute name="align">center</xsl:attribute>
                  <xsl:attribute name="height">10pt</xsl:attribute>
                  <xsl:attribute name="width">10pt</xsl:attribute>
                  <xsl:attribute name="style">
                    <xsl:value-of select="$trueBgnd"/>
                  </xsl:attribute>
                </xsl:element>
              </tr>
            </table>
          </td>
          <td width="10pt"/>
          <td width="90%">
            <xsl:apply-templates />
          </td>
          <xsl:if test="position() = 1">
            <xsl:call-template name="dump-history">
              <xsl:with-param name="rowspan">
                <xsl:value-of select="$answerNumber"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:if>
        </tr>
      </xsl:for-each>
    </table>
  </xsl:template>
  
  <!-- multple question elements in the same quandaentry -->
  <xsl:template name="multiplequestion">
    <!-- There are three possible cases: All questions TF, all
         questions MC and mixed. Is it worth considering these three
         cases? So far, only the TF template is invoked. -->
    <xsl:call-template name="multipleTFquestion"/>
  </xsl:template>

  <!-- multple TF question elements in the same quandaentry -->
  <xsl:template name="multipleTFquestion">
    <table 
      style="border: 1px solid black; border-collapse: collapse;pageBreakInside: false" 
      width="95%" align="center" cellspacing="0" cellpadding="3">
      <tr>
        <th width="60pt">
          <xsl:choose>
            <xsl:when test="$profile.lang='en'">True</xsl:when>
            <xsl:otherwise>Verdadero</xsl:otherwise>
          </xsl:choose>
        </th>
        <th width="60pt">
          <xsl:choose>
            <xsl:when test="$profile.lang='en'">False</xsl:when>
            <xsl:otherwise>Falso</xsl:otherwise>
          </xsl:choose>
        </th>
        <th />
        <xsl:if test="$include.history='yes'">
          <th>
            <xsl:choose>
              <xsl:when test="$profile.lang='en'">Statistics</xsl:when>
              <xsl:otherwise>Estadísticas</xsl:otherwise>
            </xsl:choose>
          </th>
        </xsl:if>
      </tr>
      
      <xsl:for-each select="qandaentry">
        <tr>
          <xsl:variable name="trueBgnd">
            <xsl:choose>
              <xsl:when test="($include.solutions = 'yes') and
                              (contains(answer/@condition, 'Cierto') or
                              contains(answer/@condition, 'Verdadero') or
                              contains(answer/@condition, 'Correct') or
                              contains(answer/@condition, 'True'))">background: black</xsl:when>
              <xsl:otherwise>background: white</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="falseBgnd">
            <xsl:choose>
              <xsl:when test="($include.solutions = 'yes') and
                              (contains(answer/@condition, 'Falso') or
                              contains(answer/@condition, 'False'))">background: black</xsl:when>
              <xsl:otherwise>background: white</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <td align="center" height="20pt">
            <table 
              style="border: 1px solid black; border-collapse: collapse;pageBreakInside: false" 
              width="10pt" align="center">
              <tr>
                <xsl:element name="td">
                  <xsl:attribute name="align">center</xsl:attribute>
                  <xsl:attribute name="height">10pt</xsl:attribute>
                  <xsl:attribute name="width">10pt</xsl:attribute>
                  <xsl:attribute name="style">
                    <xsl:value-of select="$trueBgnd"/>
                  </xsl:attribute>
                </xsl:element>
              </tr>
            </table>
          </td>
          <td align="center" height="20pt">
            <table 
              style="border: 1px solid black; border-collapse: collapse;pageBreakInside: false" 
              width="10pt" align="center">
              <tr>
                <xsl:element name="td">
                  <xsl:attribute name="align">center</xsl:attribute>
                  <xsl:attribute name="height">10pt</xsl:attribute>
                  <xsl:attribute name="width">10pt</xsl:attribute>
                  <xsl:attribute name="style">
                    <xsl:value-of select="$falseBgnd"/>
                  </xsl:attribute>
                </xsl:element>
              </tr>
            </table>
          </td>
          <td class="qtext"><xsl:apply-templates select="question/node()"/></td>
          <xsl:call-template name="dump-history"/>
        </tr>
      </xsl:for-each>
    </table>
  </xsl:template>
  
  <!-- Dump element containing history --> 
  <xsl:template name="dump-history">
    <xsl:param name="rowspan" select="1"/>
    <xsl:if test="$include.history='yes'">
      <td>
        <xsl:attribute name="rowspan"><xsl:value-of select="$rowspan"/></xsl:attribute>
        <table style="border: 1px solid black; border-collapse: collapse;" 
          align="center" cellpadding="3">
          <tr>
            <xsl:choose>
              <xsl:when test="$profile.lang='en'">
                <th style="border: 1px solid black; border-collapse: collapse;">Edition</th>
                <th style="border: 1px solid black; border-collapse: collapse;">Correct</th>
                <th style="border: 1px solid black; border-collapse: collapse;">Inc.</th>
                <th style="border: 1px solid black; border-collapse: collapse;">Blank</th>
                <th style="border: 1px solid black; border-collapse: collapse;">Total</th>
                <th style="border: 1px solid black; border-collapse: collapse;">Remarks</th>
              </xsl:when>
              <xsl:otherwise>
                <th style="border: 1px solid black; border-collapse: collapse;">Edición</th>
                <th style="border: 1px solid black; border-collapse: collapse;">Correctas</th>
                <th style="border: 1px solid black; border-collapse: collapse;">Inc.</th>
                <th style="border: 1px solid black; border-collapse: collapse;">Blanco</th>
                <th style="border: 1px solid black; border-collapse: collapse;">Total</th>
                <th style="border: 1px solid black; border-collapse: collapse;">Comentarios</th>
              </xsl:otherwise>
            </xsl:choose>
          </tr>
          <xsl:choose>
            <xsl:when test="blockinfo/printhistory/para">
              <xsl:for-each select="blockinfo/printhistory/para">
                <tr>
                  <td style="border: 1px solid black; border-collapse:
                             collapse;" 
                    align="center">
                    <xsl:value-of
                      select="@arch"/>/<xsl:value-of
                    select="@revision"/>/<xsl:value-of
                    select="@vendor"/>
                  </td>
                  <td style="border: 1px solid black; border-collapse:
                             collapse;" 
                    align="center">
                    <xsl:value-of
                      select="phrase[@condition='correct']/text()"/>
                  </td>
                  <td style="border: 1px solid black; border-collapse:
                             collapse;" 
                    align="center">
                    <xsl:value-of select="phrase[@condition='incorrect']/text()"/>
                  </td>
                  <td style="border: 1px solid black; border-collapse:
                             collapse;" 
                    align="center">
                    <xsl:value-of select="phrase[@condition='blank']/text()"/>
                  </td>
                  <td style="border: 1px solid black; border-collapse:
                             collapse;" 
                    align="center">
                    <xsl:value-of select="phrase[@condition='total']/text()"/>
                  </td>
                  <td style="border: 1px solid black; border-collapse:
                             collapse;" 
                    align="center">
                    <xsl:value-of select="phrase[@condition='remarks']/text()"/>
                  </td>
                </tr>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <tr>
                <td style="border: 1px solid black; border-collapse:
                             collapse;" 
                    colspan="6" align="center">No information available</td>
              </tr>
            </xsl:otherwise>
          </xsl:choose>
        </table>
      </td>
    </xsl:if>
  </xsl:template>

  <!-- Just discovered that blockinfo element is passed to the HTML -->
  <xsl:template match="blockinfo"/>
</xsl:stylesheet>
