<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common" 
  xmlns="http://www.w3.org/1999/xhtml" 
  exclude-result-prefixes="exsl" version="1.0">
  
  <xsl:import href="DocbookProfile.xsl"/> 

  <xsl:include href="TestQuestions.xsl"/>
  <xsl:include href="SolutionSection.xsl"/>
  <xsl:include href="PguideSection.xsl"/>
  <xsl:include href="SubmitIgnore.xsl"/>

  <!-- This one for sure is needed in all documents -->
  <xsl:param name="xref.with.number.and.title" select="'0'"/>

  <xsl:include href="ExamParams.xsl"/>

<!--   <xsl:include href="removespanquote.xsl"/> -->

  <xsl:output method="xml" indent="yes" encoding="UTF-8"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"/>

  <xsl:template match="section">
    <!-- Fetch the customization elements that are present in the document -->
    <xsl:variable name="part">
      <xsl:apply-templates select="para[@condition='part']"/>
    </xsl:variable>
    <xsl:variable name="duration" select="para[@condition='duration']/node()"/>
    <xsl:variable name="scoring"  select="para[@condition='scoring']/node()"/>
    <xsl:variable name="date"     select="para[@condition='date']/node()"/>
    <xsl:variable name="note"     select="para[@condition='note']/node()"/>
    <xsl:variable name="name"     select="para[@condition='name']"/>
    <xsl:variable name="score"    select="para[@condition='score']"/>
    
    <!-- Table to show Logo, Degree, Dept and institution on the left and Course
    and date on the right -->
    <table width="100%" style="border:0">
      <tr>
        <!-- Include the logo if given in var ada.exam.topleft.image -->
        <xsl:if test="$ada.exam.topleft.image">
          <td width="10%" align="left" rowspan="3">
            <img align="center">
              <xsl:if test="$ada.exam.topleft.image.alt">
                <xsl:attribute name="alt"><xsl:value-of                
                select="$ada.exam.topleft.image.alt"/></xsl:attribute>
              </xsl:if>
              <xsl:attribute name="src"><xsl:value-of
              select="$ada.course.home"/><xsl:value-of
              select="$ada.exam.topleft.image"/></xsl:attribute>
            </img>
          </td>
        </xsl:if>
          
        <!-- First row is completed with additinal text vars -->
        <td width="50%" align="left">
          <xsl:if test="$ada.exam.topleft.toptext or $ada.exam.topleft.toptext.en">
            <b>
              <xsl:choose>
                <xsl:when test="$profile.lang='en'">
                  <xsl:copy-of select="$ada.exam.topleft.toptext.en"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:copy-of select="$ada.exam.topleft.toptext"/>
                </xsl:otherwise>
              </xsl:choose>
            </b>
          </xsl:if>
        </td>

        <td width="40%" align="right">
          <xsl:if test="$ada.exam.topright.toptext or $ada.exam.topright.toptext.en">
            <b>
              <xsl:choose>
                <xsl:when test="$profile.lang='en'">
                  <xsl:copy-of select="$ada.exam.topright.toptext.en"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:copy-of select="$ada.exam.topright.toptext"/>
                </xsl:otherwise>
              </xsl:choose>
            </b>
          </xsl:if>
        </td>
      </tr>

      <tr>
        <!-- Second row include department and date -->
        <td>
          <xsl:if test="$ada.exam.topleft.centertext or 
                        $ada.exam.topleft.centertext.en">
            <b>
              <xsl:choose>
                <xsl:when test="$profile.lang='en'">
                  <xsl:copy-of select="$ada.exam.topleft.centertext.en"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:copy-of select="$ada.exam.topleft.centertext"/>
                </xsl:otherwise>
              </xsl:choose>
            </b>
          </xsl:if>
        </td>

        <td align="right">
          <xsl:if test="$ada.exam.topright.centertext or 
                        $ada.exam.topright.centertext.en">
            <b>
              <xsl:choose>
                <xsl:when test="$profile.lang='en'">
                  <xsl:copy-of select="$ada.exam.topright.centertext.en"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:copy-of select="$ada.exam.topright.centertext"/>
                </xsl:otherwise>
              </xsl:choose>
            </b>
          </xsl:if>
        </td>
      </tr>

      <tr>
        <!-- And final row include University on the left -->
        <td>
          <xsl:if test="$ada.exam.topleft.bottomtext or 
                        $ada.exam.topleft.bottomtext.en">
            <b>
              <xsl:choose>
                <xsl:when test="$profile.lang='en'">
                  <xsl:copy-of select="$ada.exam.topleft.bottomtext.en"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:copy-of select="$ada.exam.topleft.bottomtext"/>
                </xsl:otherwise>
              </xsl:choose>
            </b>
          </xsl:if>
        </td>
        <td align="right">
          <xsl:if test="$ada.exam.topright.bottomtext or 
                        $ada.exam.topright.bottomtext.en">
            <b>
              <xsl:choose>
                <xsl:when test="$profile.lang='en'">
                  <xsl:copy-of select="$ada.exam.topright.bottomtext.en"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:copy-of select="$ada.exam.topright.bottomtext"/>
                </xsl:otherwise>
              </xsl:choose>
            </b>
          </xsl:if>
        </td>
      </tr>
    </table>
    
    <xsl:comment>Part heading</xsl:comment>
    
    <!-- If the exam has a "part" label, stick it right at the top of the page -->
    <xsl:if test="$part">
      <div style="text-align: center;">
        <u><xsl:copy-of select="$part"/></u>
        <xsl:if test="($ada.exam.include.id = 'yes') and (/section/@status)">
          (<xsl:value-of select="/section/@status"/>)
        </xsl:if>
      </div>
    </xsl:if>
    
    <!-- Include paragraph with duration, scoring, date and/or note -->
    <xsl:if test="$duration or $scoring or $date or $note">
      <p>
        <table style="margin-left: 0%;">
          <!-- Duration -->
          <xsl:if test="$duration">
            <xsl:comment>Duration/Score/Date</xsl:comment>
            <tr>
              <td>
                <b>
                  <xsl:choose>
                    <xsl:when test="$profile.lang='en'">
                      Duration:
                    </xsl:when>
                    <xsl:otherwise>
                      Duración:
                    </xsl:otherwise>
                  </xsl:choose>
                </b>
              </td>
              <td><xsl:apply-templates select="$duration"/></td>
            </tr>
          </xsl:if>

          <!-- Scoring -->
          <xsl:if test="$scoring">
            <tr>
              <td>
                <b>
                  <xsl:choose>
                    <xsl:when test="$profile.lang='en'">
                      Score:
                    </xsl:when>
                    <xsl:otherwise>
                      Puntuación:
                    </xsl:otherwise>
                  </xsl:choose>
                </b>
              </td>
              <td><xsl:apply-templates select="$scoring"/></td>
            </tr>
          </xsl:if>

          <!-- Date -->
          <xsl:if test="$date">
            <tr>
              <td>
                <b>
                  <xsl:choose>
                    <xsl:when test="$profile.lang='en'">
                      Date:
                    </xsl:when>
                    <xsl:otherwise>
                      Fecha:
                    </xsl:otherwise>
                  </xsl:choose>
                </b>
              </td>
              <td><xsl:apply-templates select="$date"/></td>
            </tr>
          </xsl:if>

          <!-- Note -->
          <xsl:if test="$note">
            <tr>
              <td valign="top">
                <b>
                  <xsl:choose>
                    <xsl:when test="$profile.lang='en'">
                      Remarks:
                    </xsl:when>
                    <xsl:otherwise>
                      Nota:
                    </xsl:otherwise>
                  </xsl:choose>
                </b>
              </td>
              <td><xsl:apply-templates select="$note"/></td>
            </tr>
          </xsl:if>
        </table>
      </p>
      <hr width="100%" align="center"/>
    </xsl:if>
    
    <!-- Include a box to write the student first/last/id -->
    <xsl:if test="$name">
      <table width="100%" 
        style="border: 1px solid black; border-collapse: collapse;" 
        cellpadding="10">
        <!-- Last name -->
        <tr>
          <td style="border: 1px solid black; border-collapse: collapse;"
              width="11%" align="left">
            <xsl:choose>
              <xsl:when test="$profile.lang='en'">
                Last Name:
              </xsl:when>
              <xsl:otherwise>
                Apellidos:
              </xsl:otherwise>
            </xsl:choose>
          </td>
          <td style="border: 1px solid black; border-collapse: collapse;"
              width="90%" ></td>
        </tr>

        <!-- First name -->
        <tr>
          <td style="border: 1px solid black; border-collapse: collapse;"
              align="left">
            <xsl:choose>
              <xsl:when test="$profile.lang='en'">
                First Name:
              </xsl:when>
              <xsl:otherwise>
                Nombre:
              </xsl:otherwise>
            </xsl:choose>
          </td>
          <td style="border: 1px solid black; border-collapse: collapse;"></td>
        </tr>

        <!-- Student ID -->
        <tr>
          <td style="border: 1px solid black; border-collapse: collapse;"
              align="left">
            <xsl:choose>
              <xsl:when test="$profile.lang='en'">
                Student ID:
              </xsl:when>
              <xsl:otherwise>
                NIA:
              </xsl:otherwise>
            </xsl:choose>
          </td>
          <td style="border: 1px solid black; border-collapse: collapse;"></td>
        </tr>
      </table>
      <hr width="100%" align="center"/>
    </xsl:if>
    
    <!-- 
         Insert a box to fill with the scoring: Correct/Incorrect/Blank. Only
         suitable for tests.

         Possible improvement: provide several types of score boxes. Another one
         in which a bunch of boxes are created (given by a parameter) and a
         total box for the final score. All this controlled by a parameter.
    -->
    <xsl:if test="$score">
      <table style="border: 1px solid black; border-collapse: collapse;" 
             cellpadding="10">
        <tr>
          <th style="border: 1px solid black; border-collapse: collapse;">
            <xsl:choose>
              <xsl:when test="$profile.lang='en'">
                Correct
              </xsl:when>
              <xsl:otherwise>
                Correctas
              </xsl:otherwise>
            </xsl:choose>
          </th>
          <th style="border: 1px solid black; border-collapse: collapse;">
            <xsl:choose>
              <xsl:when test="$profile.lang='en'">
                Incorrect
              </xsl:when>
              <xsl:otherwise>
                Incorrectas
              </xsl:otherwise>
            </xsl:choose>
          </th>
          <th style="border: 1px solid black; border-collapse: collapse;">
            <xsl:choose>
              <xsl:when test="$profile.lang='en'">
                No answer
              </xsl:when>
              <xsl:otherwise>
                Sin respuesta
              </xsl:otherwise>
            </xsl:choose>
          </th>
          <th style="border: 1px solid black; border-collapse: collapse;">
            <xsl:choose>
              <xsl:when test="$profile.lang='en'">
                Final Score
              </xsl:when>
              <xsl:otherwise>
                Nota
              </xsl:otherwise>
            </xsl:choose>
          </th>
        </tr>
        <tr>
          <td style="border: 1px solid black; border-collapse: collapse;"
              width="25%" height="50pt"/>
          <td style="border: 1px solid black; border-collapse: collapse;"
              width="25%" height="50pt"/>
          <td style="border: 1px solid black; border-collapse: collapse;"
              width="25%" height="50pt"/>
          <td style="border: 1px solid black; border-collapse: collapse;"
              width="25%" height="50pt"/>
        </tr>
      </table>
      <hr width="100%" align="center"/>
    </xsl:if>
    
    <!-- If cover is to be rendered in a single page, insert the page break -->
    <xsl:if test="$ada.exam.render.separate.cover = 'yes'">
      <br class="pageBreakBefore"/>
    </xsl:if>

    <!-- Test questions within qandaset element -->
    <xsl:apply-templates select='qandaset/node()'/>
    
    <!-- Problems within a section element -->
    <xsl:for-each select="section/section">
      <xsl:if test="$ada.exam.exercise.name.en or $ada.exam.exercise.name">
        <b>
          <xsl:choose>
            <xsl:when test="$profile.lang='en'">
              <xsl:copy-of select="$ada.exam.exercise.name.en"/>
              <xsl:text> </xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="$ada.exam.exercise.name"/>
              <xsl:text> </xsl:text>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:if test="count(preceding-sibling::section) +
                        count(following-sibling::section) &gt;= 1">
            <xsl:value-of select="count(preceding-sibling::section) + 1"/>.
          </xsl:if>
          <xsl:choose>
            <xsl:when test="@condition">
              <xsl:text> </xsl:text>
              <xsl:value-of select="@condition"/>
            </xsl:when>
            <xsl:when test="sectioninfo/subtitle">
              <xsl:text> </xsl:text>
              <xsl:apply-templates select="sectioninfo/subtitle/node()"/>
            </xsl:when>
          </xsl:choose>
        </b>
      </xsl:if>

      <xsl:apply-templates/>

      <xsl:if test="not(position() = last())">
        <hr width="100%"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- 
       Style to be included in the header. It is included instead of inserting a
       link to a css file to make the HTML self-contained and be visualized as close
       as possible to its final appearance without requiring a net connection.
  -->
  <xsl:template name="user.head.content">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>

    <xsl:if test="$ada.exam.author">
      <xsl:element name="meta">
        <xsl:attribute name="name">Author</xsl:attribute>
        <xsl:attribute name="content">
          <xsl:value-of select="$ada.exam.author"/>
        </xsl:attribute>
      </xsl:element>
    </xsl:if>

    <style type="text/css">
      body { 
        font-family: '<xsl:value-of select="$ada.exam.fontfamily"/>';
        font-size: <xsl:value-of select="$ada.exam.fontsize"/>;
        color: black; 
        background: white;
      }

      table       { page-break-inside: avoid; 
                    border-collapse: collapse; 
                    margin-right: auto; 
                    margin-left: auto; 
                  }

      hr                { height: 1px solid black; }

      table.data        { border: 2px solid black; }

      th.data           { border: 2px solid black; }

      td.data           { border: 2px solid black; }

      tr                { page-break-inside: avoid; }

      div.informalfigure { text-align: center; }

      td.qtext p { margin-top: 2pt; margin-bottom: 2pt; }

      .underline { text-decoration: underline; }

      /* Add a class attribute with these values to force PDF page
      breaks */
      .pageBreakBefore {
        margin-bottom: 0; page-break-before: always;
      }
      .pageBreakAfter {
          margin-bottom: 0; page-break-after: always;
      } 
    </style>      
  </xsl:template>
</xsl:stylesheet>

