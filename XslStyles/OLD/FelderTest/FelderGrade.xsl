<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:exsl="http://exslt.org/common" 
  xmlns="http://www.w3.org/1999/xhtml" 
  exclude-result-prefixes="exsl" version="1.0">

  <xsl:param name="cellColor"      select="'#DDDDDD'"/>
  <xsl:param name="cellBgnd"       select="'tick.png'"/>

  <xsl:param name="felder.processor"/>
  <xsl:param name="felder.sublabel"/>

  <xsl:template match="answers">
    <xsl:variable name="col1"
      select="answer[@name='Q_01-1' or 
              @name='Q_05-1' or 
              @name='Q_09-1' or 
              @name='Q_13-1' or 
              @name='Q_17-1' or 
              @name='Q_21-1' or 
              @name='Q_25-1' or 
              @name='Q_29-1' or 
              @name='Q_33-1' or 
              @name='Q_37-1' or 
              @name='Q_41-1']"/>
    <xsl:variable name="col2"
      select="answer[@name='Q_02-2' or 
              @name='Q_06-2' or 
              @name='Q_10-2' or 
              @name='Q_14-2' or 
              @name='Q_18-2' or 
              @name='Q_22-2' or 
              @name='Q_26-2' or 
              @name='Q_30-2' or 
              @name='Q_34-2' or 
              @name='Q_38-2' or 
              @name='Q_42-2']"/>
    <xsl:variable name="col3"
      select="answer[@name='Q_03-3' or 
              @name='Q_07-3' or 
              @name='Q_11-3' or 
              @name='Q_15-3' or 
              @name='Q_19-3' or 
              @name='Q_23-3' or 
              @name='Q_27-3' or 
              @name='Q_31-3' or 
              @name='Q_35-3' or 
              @name='Q_39-3' or 
              @name='Q_43-3']"/>
    <xsl:variable name="col4"
      select="answer[@name='Q_04-4' or 
              @name='Q_08-4' or 
              @name='Q_12-4' or 
              @name='Q_16-4' or 
              @name='Q_20-4' or 
              @name='Q_24-4' or 
              @name='Q_28-4' or 
              @name='Q_32-4' or 
              @name='Q_36-4' or 
              @name='Q_40-4' or 
              @name='Q_44-4']"/>
    <xsl:variable name="col1-A"
      select="count(exsl:node-set($col1)[text()='a'])"/>
    <xsl:variable name="col1-B"
      select="count(exsl:node-set($col1)[text()='b'])"/>
    <xsl:variable name="col2-A"
      select="count(exsl:node-set($col2)[text()='a'])"/>
    <xsl:variable name="col2-B"
      select="count(exsl:node-set($col2)[text()='b'])"/>
    <xsl:variable name="col3-A"
      select="count(exsl:node-set($col3)[text()='a'])"/>
    <xsl:variable name="col3-B"
      select="count(exsl:node-set($col3)[text()='b'])"/>
    <xsl:variable name="col4-A"
      select="count(exsl:node-set($col4)[text()='a'])"/>
    <xsl:variable name="col4-B"
      select="count(exsl:node-set($col4)[text()='b'])"/>

    <!--
    <p>COL1-A = <xsl:value-of select="$col1-A"/></p>
    <p>COL1-B = <xsl:value-of select="$col1-B"/></p>
    <p>COL2-A = <xsl:value-of select="$col2-A"/></p>
    <p>COL2-B = <xsl:value-of select="$col2-B"/></p>
    <p>COL3-A = <xsl:value-of select="$col3-A"/></p>
    <p>COL3-B = <xsl:value-of select="$col3-B"/></p>
    <p>COL4-A = <xsl:value-of select="$col4-A"/></p>
    <p>COL4-B = <xsl:value-of select="$col4-B"/></p>
    -->

    <xsl:choose>
      <xsl:when test="$profile.lang='en'">
        To be translated
      </xsl:when>
      <xsl:otherwise>
        <p>
          Los resultados del test se presentan en cuatro
          escalas: activo/reflexivo, sensitivo/intuitivo,
          visual/verbal y secuencial/global. Cada una de ellas tiene
          una valoración entre cero y once que reflejan aspectos
          opuestos en la forma de
          aprender. Por ejemplo, la
          primera es la escala
          <quote>Activo/reflexivo</quote>. El resultado de tus
          respuestas se traduce en un punto en esta escala que
          te dice que tan intensivamente estás en una de esas
          categorías. Recuerda que no hay resultados correctos ni
          incorrectos, tan sólo diferentes formas de aprender.
        </p>
      </xsl:otherwise>
    </xsl:choose>

    <hr style="width: 100%" />

    <xsl:choose>
      <xsl:when test="$profile.lang='en'">
        <h4 align="center">Active/Reflexive</h4>
      </xsl:when>
      <xsl:otherwise>
        <h4 align="center">Activo/Reflexivo</h4>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="scaletable">
      <xsl:with-param name="leftTitle">Activo</xsl:with-param>
      <xsl:with-param name="rightTitle">Reflexivo</xsl:with-param>
      <xsl:with-param name="value"><xsl:value-of select="$col1-B - $col1-A"/></xsl:with-param>
    </xsl:call-template>

    <xsl:choose>
      <xsl:when test="$profile.lang='en'">
        To be translated.
      </xsl:when>
      <xsl:otherwise>
        <p>
          Los que aprenden en forma activa tienden a retener y
          entender mejor la información haciendo algo activamente con el objeto
          de conocimiento como discutirlo o aplicarlo, o explicarlo a
          otros. Los reflexivos prefieren pensar sobre el objeto
          tranquilamente.
        </p>

        <p>
          La frase del activo es: <quote>veamos cómo funciona</quote>;
          la del reflexivo es <quote>pensemos primero en ello</quote>. A
          los activos les agrada más el trabajo en grupo que a los
          reflexivos,
          que prefieren trabajar solos. Para los dos estilos es difícil aprender
          escuchando clases y tomando notas, sobre todo para los activos.
        </p>

        <p>
          No todo el mundo es activo o reflexivo. La preferencia por
          una categoría u otra puede ser intensa, moderada o discreta. Lo
          deseable es un equilibrio entre las dos. Si siempre se actúa antes de
          reflexionar, se pueden cometer omisiones o realizar falsas
          interpretaciones, mientras que, si se toma mucho tiempo en el proceso,
          se puede inhibir la toma de decisiones.
        </p>

        <h4>
          ¿Cómo pueden ayudarse a sí mismo los que aprenden en forma activa?
        </h4>

        <p>
          Si es una persona que aprende con estilo activo, y se
          encuentra en una clase que sólo permite escasa o nula discusión o
          actividades para la solución de problemas, debe tratar de compensar
          estas carencias cuando estudie. Debe hacerlo en un grupo en que los
          miembros toman su turno para explicar diferentes tópicos unos a
          otros. Debe trabajar con otros para imaginar qué le será preguntado y
          pensar cuál será su respuesta. Siempre retendrá información mejor si
          se encuentra alguna forma de hacer algo con ella.
        </p>

        <h4>
          ¿Cómo pueden los reflexivos ayudarse a sí mismos?
        </h4>

        <p>
          Si la persona tiene un estilo reflexivo en una clase que da
          poco tiempo o no lo da para pensar acerca de una nueva información,
          debe tratar de compensar esta carencia con estrategias específicas. En
          un curso de escasa duración debe aprender a priorizar los asuntos más
          importantes para que tenga el tiempo suficiente para estudiar. Puede
          ser de utilidad escribir resúmenes cortos de lecturas o notas de clase
          en sus propias palabras. Hacerlo puede tomar tiempo extra, pero
          permitirá que el material se retenga en forma más efectiva.
        </p>
      </xsl:otherwise>
    </xsl:choose>
    
    <hr style="width: 100%" />

    <xsl:choose>
      <xsl:when test="$profile.lang='en'">
        <h4 align="center">Sensitive/Intuitive</h4>
      </xsl:when>
      <xsl:otherwise>
        <h4 align="center">Sensitivo/Intuitivo</h4>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="scaletable">
      <xsl:with-param name="leftTitle">Sensitivo</xsl:with-param>
      <xsl:with-param name="rightTitle">Intuitivo</xsl:with-param>
      <xsl:with-param name="value"><xsl:value-of select="$col2-B - $col2-A"/></xsl:with-param>
    </xsl:call-template>

    <xsl:choose>
      <xsl:when test="$profile.lang='en'">
        To be translated.
      </xsl:when>
      <xsl:otherwise>
        <p>
          A los sensitivos les atrae más el aprendizaje de hechos; los
          intuitivos a menudo prefieren el descubrimiento de posibilidades y
          relaciones. Los sensitivos frecuentemente gustan de resolver problemas
          por métodos bien establecidos y no les agradan las complicaciones y
          sorpresas; a los intuitivos les estimulan las innovaciones y
          no las repeticiones. Los sensitivos son más susceptibles que
          los intuitivos para resentir que sean evaluados con materiales que no
          han sido explícitamente cubiertos en clase, pero tienden a ser
          pacientes con los detalles y son buenos para memorizar hechos y hacer
          trabajos manuales; los intuitivos pueden ser mejores para captar
          nuevos conceptos y a menudo se sienten más cómodos que los sensitivos
          con las abstracciones y las fórmulas matemáticas.
        </p>
        <p>
          Los sensitivos tienden a ser más prácticos y cuidadosos que
          los intuitivos y no les motivan los cursos que no tienen conexión
          aparente con el mundo real; estos últimos tienden a trabajar más
          rápidamente y ser más innovadores que los sensitivos y no se sienten
          atraídos por cursos que implican mucha memorización y cálculos de rutina.
        </p>
        <p>
          Todos los sujetos son a veces sensitivos y a veces
          intuitivos. La preferencia por una u otra opción puede ser intensa,
          moderada o discreta. Para ser efectivo en el proceso de aprender y
          resolver problemas, se requiere funcionar en las dos modalidades. Si
          se pone énfasis en la intuición, se pierden detalles importantes o se
          cometen errores por falta de cuidado en cálculos o en los trabajos
          manuales (laboratorio); si se da más importancia a lo sensitivo, se
          puede memorizar mucho, pero no se concentra lo suficiente en la
          comprensión y en los mecanismos creativos.
        </p>

        <h4>
          ¿Cómo se pueden ayudar a sí mismos los sensitivos?
        </h4>

        <p>
          Los sensitivos recuerdan y entienden mejor la información si
          pueden ver cómo se conecta con el mundo real. Si se encuentran en una
          clase en donde la mayor parte del material es abstracto y teórico,
          pueden tener dificultades. El alumno debe solicitar al profesor
          ejemplos específicos de conceptos y procedimientos y encontrar cómo
          los conceptos se aplican a la práctica. Si el profesor no proporciona
          suficientes ejemplos específicos, se deben tratar de encontrar en los
          textos del curso u otras referencias o a través de lluvia de ideas con
          amigos o compañeros de clase.
        </p>

        <p>
          ¿Cómo pueden los intuitivos ayudarse a sí mismos?
        </p>

        <p>
          Muchos de los cursos convencionales están enfocados a los
          inutitivos; sin embargo, si se encuentran en una clase que trata
          principalmente con memorización puede darse desmotivación. El profesor
          debe ayudar a las interpretaciones o proporcionar teorías que unan los
          hechos; el intuitivo debe tratar de hallar coneixones por sí
          mismo. También puede tender a cometer errores por descuido en las
          pruebas debido a que son impacientes con los detalles y no les gustan
          las repeticiones (como una revisión completa de problemas y
          soluciones). Deben tomarse el tiempo suficiente para leer la pregunta
          completa antes de comenzar a responder y estar seguros de
          revisar los resultados.
        </p>
      </xsl:otherwise>
    </xsl:choose>
    
    <hr style="width: 100%" />

    <h4 align="center">Visual/Verbal</h4>
    <xsl:call-template name="scaletable">
      <xsl:with-param name="leftTitle">Visual</xsl:with-param>
      <xsl:with-param name="rightTitle">Verbal</xsl:with-param>
      <xsl:with-param name="value"><xsl:value-of select="$col3-B - $col4-A"/></xsl:with-param>
    </xsl:call-template>

    <xsl:choose>
      <xsl:when test="$profile.lang='en'">
        To be translated.
      </xsl:when>
      <xsl:otherwise>
        <p>
          Los visuales recuerdan mejor lo que ven en las figuras,
          diagramas, líneas de tiempo, películas, videos y demostraciones. Los
          verbales prefieren las explicaciones verbales y escritas. Cualquiera
          aprende mejor cuando la información se presenta tanto visual como
          verbalmente. En la mayoría de las escuelas las clases se presentan con
          poca información visual, los estudiantes asisten principalmente a
          conferencias y leen material escrito en la pizarra así como en libros
          de texto y manuales. Desafortunadamente, la mayoría de la gente
          aprende en forma visual, lo que significa que muchos de los
          estudiantes no adquieren ni un poco de lo mucho que podrían si se
          utilizaran más presentaciones visuales. los alumnos hábiles son
          capaces de procesar información tanto visual como verbal.
        </p>
        
        <h4>
          ¿Cómo se pueden ayudar a sí mismos los visuales?
        </h4>

        <p>
          Los visuales deben tratar de encontrar diagramas, bosquejos,
          esquemas, fotografías o cualquier otra representación visual de
          material del curso que es predominantemente verbal. Deben buscarse
          apoyos como videos, multimedia, preparar mapas conceptuales listando
          puntos clave, encerrándolos en cajas o círculos y dibujando líneas con
          flechas entre conceptos para mostrar conexiones. Se pueden codificar
          con colores las notas marcando todo lo relacionado con un tópico con
          un solo color.
        </p>
        
        <h4>
          ¿cómo pueden ayudarse los verbales?
        </h4>

        <p>
          Estos pueden hacerlo escribiendo resúmenes o bosquejos de
          material de cursos en sus propias palabras. Trabajar en grupos puede
          ser particularmente efectivo, ya que se incrementa la comprensión del
          material escuchando explicaciones de sus compañeros de clases y
          aprenden más cuando ellos mismos hacen la explicación.
        </p>
      </xsl:otherwise>
    </xsl:choose>
    
    <hr style="width: 100%" />

    <xsl:choose>
      <xsl:when test="$profile.lang='en'">
        <h4 align="center">Sequential/Global</h4>
      </xsl:when>
      <xsl:otherwise>
        <h4 align="center">Secuencial/Global</h4>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="scaletable">
      <xsl:with-param name="leftTitle">Secuencial</xsl:with-param>
      <xsl:with-param name="rightTitle">Global</xsl:with-param>
      <xsl:with-param name="value"><xsl:value-of select="$col4-B - $col4-A"/></xsl:with-param>
    </xsl:call-template>

    <xsl:choose>
      <xsl:when test="$profile.lang='en'">
        To be translated.
      </xsl:when>
      <xsl:otherwise>
        <p>
          Los secuenciales tienden a incrementar la comprensión en
          pasos lineales, un paso seguido por otro en forma lógica. Los globales
          tienden a seguir caminos lógicos graduales para hallar soluciones,
          pueden ser capaces de resolver problemas complejos rápidamente o poner
          las cosas juntas en formas novedosas una vez que han captado el gran
          panorama, pero tienen dificultad para explicar cómo lo lograron. Mucha
          gente que lee esta descripció0n concluye erróneamente que son
          globales, ya que todos han experimentado confusión seguida de una
          comprensión súbita. Lo que hace o no a una persona global e slo que
          pasa después de ese evento. Los secuenciales pueden no entender
          completamente el material; sin embargo, pueden hacer algo con él (como
          solucionar problemas o pasar una prueba), ya que las piezas que se han
          aprendido están lógicamente conectadas. Los globales intensos que
          carecen de buenas habilidades de pensamiento secuencial, por otra
          parte, pueden tener dificultades serias hasta que tienen una idea
          clara del cuadro completo. Aun después de que lo tienen, pueden
          confundirse acerca de los detalles del objeto, mientras que los
          secuenciales pueden saber mucho acerca de aspectos específicos de una
          materia pero tienen dificultad para relacionarlos con los diferentes
          aspectos del mismo tópico o tópicos diferentes.
        </p>
        <h4>
          ¿Cómo pueden ayudarse a sí mismo los secuenciales?
        </h4>
        <p>
          Un secuencial con un profesor que vaya de un tópico a otro,
          que obvie pasos, tendrá dificultad para recordar y dar seguimiento a
          un aprendizaje. En estos casos el instructor debe completar los pasos
          que faltan o el propio alumno los puede llenar buscando las
          referencias apropiadas. Durante el estudio se debe tomar el tiempo
          para esquematizar el material de lecutra para sí mismo en un orden
          lógico. A la larga hacerlo ayudará a ahorrar tiempo. Se puede tratar
          también de reforzar las habilidades globales de pensamiento
          relacionando cada nuevo tópico que se estudia con cosas que ya
          seconocen. Cuanto más se pueda hacer, más será la
          profundidad de la comprensión.
        </p>

        <h4>
          ¿Cómo se puden ayudar los globales?
        </h4>
        <p>
          Para entender el cuadro general de una forma más rápida,
          antes de inicial el estudio de la primera sección de un capítulo de un
          texto, se debe ver el panorama general del capítulo completo. Hacerlo
          puede consumir tiempo inicialmente, pero le puede evitar tener que
          revisar partes particulares una y otra vez. Puede abordarse el estudio
          por grandes bloques y relacionar las materials o conocimientos con
          casos que ya sabe, se pidiéndole al profesor que le ayude a ver las
          conexiones o consultando referencias.
        </p>
      </xsl:otherwise>
    </xsl:choose>
    
    <hr style="width: 100%" />

    <xsl:choose>
      <xsl:when test="$profile.lang='en'">
        <h4 align="center">Feedback</h4>
      </xsl:when>
      <xsl:otherwise>
        <h4 align="center">Realimentación</h4>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:element name="form">
      <xsl:attribute name="name">form1</xsl:attribute>
      <xsl:attribute name="method">post</xsl:attribute>
      <xsl:attribute name="action">
        <xsl:choose>
          <xsl:when test="para[@condition='processor']">
            <xsl:value-of select="para[@condition='processor']/text()"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$felder.processor"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="enctype">multipart/form-data</xsl:attribute>
      <table style="border: 1px solid black; border-collapse: collapse;pageBreakInside: false" 
        align="center">
        <thead>
          <tr>
            <th align="center" colspan="7">
              El test me ha parecido
            </th>
          </tr>
        </thead>
        <tr align="center">
          <td style="align: center; width: 90px">totalmente inútil</td>
          <td style="align: center; width: 90px">inútil</td>
          <td style="align: center; width: 90px">poco útil</td>
          <td style="align: center; width: 90px">ni idea</td>
          <td style="align: center; width: 90px">algo útil</td>
          <td style="align: center; width: 90px">útil</td>
          <td style="align: center; width: 90px">muy útil</td>
        </tr>
        <tr>
          <td style="text-align: center">
            <input type="radio" value="-3" name="Feedback"/>
          </td>
          <td style="text-align: center">
            <input type="radio" value="-2" name="Feedback"/>
          </td>
          <td style="text-align: center">
            <input type="radio" value="-1" name="Feedback"/>
          </td>
          <td style="text-align: center">
            <input type="radio" value="0" name="Feedback"/>
          </td>
          <td style="text-align: center">
            <input type="radio" value="1" name="Feedback"/>
          </td>
          <td style="text-align: center">
            <input type="radio" value="2" name="Feedback"/>
          </td>
          <td style="text-align: center">
            <input type="radio" value="3" name="Feedback"/>
          </td>
        </tr>
      </table>
      <xsl:if test="$felder.sublabel != ''">
        <input type="hidden" name="submission.Id">
          <xsl:attribute name="value"><xsl:value-of 
          select="$felder.sublabel"/></xsl:attribute>
        </input>
      </xsl:if>
      <p style="text-align: center">
        <input value="Enviar" type="submit" />
      </p>
    </xsl:element>   
  </xsl:template>

  <xsl:template name="scaletable">
    <xsl:param name="rightTitle" select="''"/>
    <xsl:param name="leftTitle" select="''"/>
    <xsl:param name="value" select="0"/>

    <table style="border: 1px solid black; border-collapse: collapse;pageBreakInside: false" 
      align="center">
      <thead>
        <tr>
          <th align="center" colspan="11">
            <xsl:value-of select="$leftTitle"/>
          </th>
          <td align="center"></td>
          <th align="center" colspan="11">
            <xsl:value-of select="$rightTitle"/>
          </th>
        </tr>
      </thead>
      <tr align="center">
        <td style="width: 19px">11</td>
        <td style="width: 19px">10</td>
        <td style="width: 19px"> 9</td>
        <td style="width: 19px"> 8</td>
        <td style="width: 19px"> 7</td>
        <td style="width: 19px"> 6</td>
        <td style="width: 19px"> 5</td>
        <td style="width: 19px"> 4</td>
        <td style="width: 19px"> 3</td>
        <td style="width: 19px"> 2</td>
        <td style="width: 19px"> 1</td>
        <td style="width: 19px"> 0</td>
        <td style="width: 19px"> 1</td>
        <td style="width: 19px"> 2</td>
        <td style="width: 19px"> 3</td>
        <td style="width: 19px"> 4</td>
        <td style="width: 19px"> 5</td>
        <td style="width: 19px"> 6</td>
        <td style="width: 19px"> 7</td>
        <td style="width: 19px"> 8</td>
        <td style="width: 19px"> 9</td>
        <td style="width: 19px">10</td>
        <td style="width: 19px">11</td>
      </tr>
      <tr height="20px" align="center">
        <td>
          <xsl:if test="$value = -11">
            <xsl:attribute name="bgcolor"><xsl:value-of select="$cellColor"/></xsl:attribute>
            <xsl:attribute name="background"><xsl:value-of select="$cellBgnd"/></xsl:attribute>
          </xsl:if>
        </td>
        <td>
          <xsl:if test="$value = -10">
            <xsl:attribute name="bgcolor"><xsl:value-of select="$cellColor"/></xsl:attribute>
            <xsl:attribute name="background"><xsl:value-of select="$cellBgnd"/></xsl:attribute>
          </xsl:if>
        </td>
        <td>
          <xsl:if test="$value = -9">
            <xsl:attribute name="bgcolor"><xsl:value-of select="$cellColor"/></xsl:attribute>
            <xsl:attribute name="background"><xsl:value-of select="$cellBgnd"/></xsl:attribute>
          </xsl:if>
        </td>
        <td>
          <xsl:if test="$value = -8">
            <xsl:attribute name="bgcolor"><xsl:value-of select="$cellColor"/></xsl:attribute>
            <xsl:attribute name="background"><xsl:value-of select="$cellBgnd"/></xsl:attribute>
          </xsl:if>
        </td>
        <td>
          <xsl:if test="$value = -7">
            <xsl:attribute name="bgcolor"><xsl:value-of select="$cellColor"/></xsl:attribute>
            <xsl:attribute name="background"><xsl:value-of select="$cellBgnd"/></xsl:attribute>
          </xsl:if>
        </td>
        <td>
          <xsl:if test="$value = -6">
            <xsl:attribute name="bgcolor"><xsl:value-of select="$cellColor"/></xsl:attribute>
            <xsl:attribute name="background"><xsl:value-of select="$cellBgnd"/></xsl:attribute>
          </xsl:if>
        </td>
        <td>
          <xsl:if test="$value = -5">
            <xsl:attribute name="bgcolor"><xsl:value-of select="$cellColor"/></xsl:attribute>
            <xsl:attribute name="background"><xsl:value-of select="$cellBgnd"/></xsl:attribute>
          </xsl:if>
        </td>
        <td>
          <xsl:if test="$value = -4">
            <xsl:attribute name="bgcolor"><xsl:value-of select="$cellColor"/></xsl:attribute>
            <xsl:attribute name="background"><xsl:value-of select="$cellBgnd"/></xsl:attribute>
          </xsl:if>
        </td>
        <td>
          <xsl:if test="$value = -3">
            <xsl:attribute name="bgcolor"><xsl:value-of select="$cellColor"/></xsl:attribute>
            <xsl:attribute name="background"><xsl:value-of select="$cellBgnd"/></xsl:attribute>
          </xsl:if>
        </td>
        <td>
          <xsl:if test="$value = -2">
            <xsl:attribute name="bgcolor"><xsl:value-of select="$cellColor"/></xsl:attribute>
            <xsl:attribute name="background"><xsl:value-of select="$cellBgnd"/></xsl:attribute>
          </xsl:if>
        </td>
        <td>
          <xsl:if test="$value = -1">
            <xsl:attribute name="bgcolor"><xsl:value-of select="$cellColor"/></xsl:attribute>
            <xsl:attribute name="background"><xsl:value-of select="$cellBgnd"/></xsl:attribute>
          </xsl:if>
        </td>
        <td>
          <xsl:if test="$value = 0">
            <xsl:attribute name="bgcolor"><xsl:value-of select="$cellColor"/></xsl:attribute>
            <xsl:attribute name="background"><xsl:value-of select="$cellBgnd"/></xsl:attribute>
          </xsl:if>
        </td>
        <td>
          <xsl:if test="$value = 1">
            <xsl:attribute name="bgcolor"><xsl:value-of select="$cellColor"/></xsl:attribute>
            <xsl:attribute name="background"><xsl:value-of select="$cellBgnd"/></xsl:attribute>
          </xsl:if>
        </td>
        <td>
          <xsl:if test="$value = 2">
            <xsl:attribute name="bgcolor"><xsl:value-of select="$cellColor"/></xsl:attribute>
            <xsl:attribute name="background"><xsl:value-of select="$cellBgnd"/></xsl:attribute>
          </xsl:if>
        </td>
        <td>
          <xsl:if test="$value = 3">
            <xsl:attribute name="bgcolor"><xsl:value-of select="$cellColor"/></xsl:attribute>
            <xsl:attribute name="background"><xsl:value-of select="$cellBgnd"/></xsl:attribute>
          </xsl:if>
        </td>
        <td>
          <xsl:if test="$value = 4">
            <xsl:attribute name="bgcolor"><xsl:value-of select="$cellColor"/></xsl:attribute>
            <xsl:attribute name="background"><xsl:value-of select="$cellBgnd"/></xsl:attribute>
          </xsl:if>
        </td>
        <td>
          <xsl:if test="$value = 5">
            <xsl:attribute name="bgcolor"><xsl:value-of select="$cellColor"/></xsl:attribute>
            <xsl:attribute name="background"><xsl:value-of select="$cellBgnd"/></xsl:attribute>
          </xsl:if>
        </td>
        <td>
          <xsl:if test="$value = 6">
            <xsl:attribute name="bgcolor"><xsl:value-of select="$cellColor"/></xsl:attribute>
            <xsl:attribute name="background"><xsl:value-of select="$cellBgnd"/></xsl:attribute>
          </xsl:if>
        </td>
        <td>
          <xsl:if test="$value = 7">
            <xsl:attribute name="bgcolor"><xsl:value-of select="$cellColor"/></xsl:attribute>
            <xsl:attribute name="background"><xsl:value-of select="$cellBgnd"/></xsl:attribute>
          </xsl:if>
        </td>
        <td>
          <xsl:if test="$value = 8">
            <xsl:attribute name="bgcolor"><xsl:value-of select="$cellColor"/></xsl:attribute>
            <xsl:attribute name="background"><xsl:value-of select="$cellBgnd"/></xsl:attribute>
          </xsl:if>
        </td>
        <td>
          <xsl:if test="$value = 9">
            <xsl:attribute name="bgcolor"><xsl:value-of select="$cellColor"/></xsl:attribute>
            <xsl:attribute name="background"><xsl:value-of select="$cellBgnd"/></xsl:attribute>
          </xsl:if>
        </td>
        <td>
          <xsl:if test="$value = 10">
            <xsl:attribute name="bgcolor"><xsl:value-of select="$cellColor"/></xsl:attribute>
            <xsl:attribute name="background"><xsl:value-of select="$cellBgnd"/></xsl:attribute>
          </xsl:if>
        </td>
        <td>
          <xsl:if test="$value = 11">
            <xsl:attribute name="bgcolor"><xsl:value-of select="$cellColor"/></xsl:attribute>
            <xsl:attribute name="background"><xsl:value-of select="$cellBgnd"/></xsl:attribute>
          </xsl:if>
        </td>
      </tr>
    </table>
  </xsl:template>
</xsl:stylesheet>
