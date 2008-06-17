import java.io.IOException;

public class PruebaFecha
{
    public static void main(String[] args)
    {
        Fecha fecha1;
        Fecha fecha2;

        try {
            // Leer la primera fecha
            System.out.println("Introduzca una fecha");
            fecha1 = Fecha.leerFecha();
            System.out.println("Introduzca otra fecha");
            fecha2 = Fecha.leerFecha();

            // Comparar las fechas
            switch (fecha1.compareTo( fecha2 )) {
            case -1:        // fecha1 es anterior a fecha2
                System.out.println(fecha1.toString() + " es anterior a " + fecha2.toString());
                break;

            case 1:     // fecha1 es posterior a fecha2
                System.out.println(fecha1.toString() + " es posterior a " + fecha2.toString());
                break;

            case 0:
                System.out.println(fecha1.toString() + " y " + fecha2.toString() + " son iguales");
                break;

            default:
                // error, este caso no deberia darse nunca
                throw new FechaException( "Ha habido un error en el programa" );

            }
        } catch (FechaException fe) {
            System.err.println(fe.toString());

        } catch (IOException ioe) {
            System.err.println( ioe.toString() );
        }
    }
}
