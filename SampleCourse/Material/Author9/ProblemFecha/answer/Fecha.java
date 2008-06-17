import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

public class Fecha {

    /**
     * Meses del año, ordenados, para convertirlos de formato cadena a numero y viceversa
     *
     * El numero de mes coincidira con la posicion de su nombre en el array mas 1
     * (porque las posiciones del array se numeran a partir de 0 pero los meses a partir de 1)
     */
    private static final String[] meses =
        { "enero", "febrero", "marzo", "abril", "mayo", "junio", "julio",
          "agosto", "septiembre", "octubre", "noviembre", "diciembre" };

    // ATRIBUTOS
    private int dia;
    private int mes;
    private int agno;


    // CONSTRUCTORES

    public Fecha(int dia, int mes, int agno) throws FechaException {
        comprobarFecha(dia, mes, agno);
        this.dia = dia;
        this.mes = mes;
        this.agno = agno;
    }

    public Fecha(String sDia, String sNombreMes, String sAgno)
        throws FechaException {

        // Convertir las cadenas del dia y el año en numeros
        try {
            dia = Integer.parseInt(sDia);
            agno = Integer.parseInt(sAgno);
        } catch ( NumberFormatException nfe ) {
            // Error al convertir una cadena en numero
            throw new FechaException( "Fecha incorrecta" );
        }

        // Se comprueba si el mes viene como número o como texto
        try {
            mes = Integer.parseInt(sNombreMes);
        } catch ( NumberFormatException nfe ) {
            mes = getMes(sNombreMes);
        }

        // Comprobar además que los valores tienen sentido
        comprobarFecha(dia, mes, agno);
    }


    // MÉTODOS DE ACCESO

    public int getDia() {
        return dia;
    }

    public int getMes() {
        return mes;
    }

    public int getAgno() {
        return agno;
    }


    // MÉTODOS

    public String toString() {
        return (dia + " de " + meses[mes-1] + " de " + agno);
    }

    public int compareTo( Fecha fecha ) {

        if (agno < fecha.getAgno()) {
            return -1;
        } else if (agno > fecha.getAgno()) {
            return 1;
        } else {                // los años son iguales => comparar los meses
            if (mes < fecha.getMes()) {
                return -1;
            } else if (mes > fecha.getMes()) {
                return 1;
            } else {            // los meses también son iguales => comparar los dias
                if (dia < fecha.getDia()) {
                    return -1;
                } else if (dia > fecha.getDia()) {
                    return 1;
                } else {                // los dias también son iguales => misma fecha
                    return 0;
                }
            }
        }
    }

    /**
     * Lee una fecha por entrada estándar.
     * Es estático porque no necesita estar ligado a ninguna instancia
     * de la clase Fecha.
     */
    public static Fecha leerFecha() throws FechaException, IOException {
        // Variables para almacenar la entrada del usuario
        String sDia, sMes, sAgno;

        BufferedReader entrada =
            new BufferedReader(new InputStreamReader(System.in));

        // Leer la primera fecha
        System.out.print("Introduzca dia: ");
        System.out.flush();
        sDia = entrada.readLine();
        System.out.print("Introduzca mes: ");
        System.out.flush();
        sMes = entrada.readLine();
        System.out.print("Introduzca año: ");
        System.out.flush();
        sAgno = entrada.readLine();

        return new Fecha( sDia, sMes, sAgno );
    }

    /**
     * Devuelve la fecha más reciente de un array de fechas.
     * Es estático porque no necesita estar ligado a ninguna instancia
     * de la clase Fecha.
     */
    public static Fecha fechaMasReciente(Fecha[] fechas) {
        Fecha fecha = null;
        if (fechas.length > 0) {
            fecha = fechas[0];
            for (int i = 1; i < fechas.length; i++) {
                if (fecha.compareTo(fechas[i]) < 0) {
                    fecha = fechas[i];
                }
            }
        }
        return fecha;
    }

    // MÉTODOS AUXILIARES

    /**
     * Devuelve el numero de dias de un mes dado
     */
    private int getDiasMes(int mes) throws FechaException {
        int diasMes = 0;

        switch(mes) {
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12:                // meses de 31 dias
            diasMes = 31;
            break;
        case 4:
        case 6:
        case 9:
        case 11:                // meses de 30 dias
            diasMes = 30;
            break;
        case 2:         // febrero
            if (esBisiesto(agno))
                diasMes = 29;
            else
                diasMes = 28;
            break;
        default:                        // mes incorrecto
            throw new FechaException("Mes incorrecto");
        }

        return diasMes;
    }


    /**
     * Devuelve el numero de dias de un mes dado
     */
    private int getDiasMes(String mes) throws FechaException {
        return getDiasMes(getMes(mes));
    }



    /**
     * Método auxiliar para calcular el numero de mes, dado su nombre
     */
    private int getMes(String sNombreMes) throws FechaException {

        // Hallar el numero de mes
        int mes = 0;
        for (int i = 0; i < meses.length && mes == 0; i++) {
            if (meses[i].equalsIgnoreCase(sNombreMes)) {
                // El mes coincide con el elemento actual del array
                mes = i + 1;
            }
        }

        if (mes == 0) {
            // si el mes introducido no coincide con ninguno de los almacenados
            // en el array es que hay un error
            throw new FechaException( "Mes incorrecto" );
        }

        return mes;
    }


    /**
     * Método auxiliar para comprobar que una fecha es correcta
     */
    private void comprobarFecha(int dia, int mes, int agno) throws FechaException {

        // Comprobar que el dia es correcto
        // (El método getDiasMes ya comprueba que el mes sea correcto)
        if ( (dia <= 0) || (dia > getDiasMes(mes)) ) {
            throw new FechaException( "Dia incorrecto" );
        }
    }


    /**
     * Comprueba si un año es bisiesto
     * Son bisiestos los años múltiplos de 4 que no sean múltiplos de 100
     * y los múltiplos de 400
     */
    private boolean esBisiesto( int agno ) {
        return (( ((agno % 4) == 0) && ((agno % 100) != 0) )
                || ((agno % 400) == 0) );
    }
}
