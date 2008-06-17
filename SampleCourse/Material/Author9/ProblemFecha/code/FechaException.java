/**
 * La excepci�n FechaException se lanza cuando se intenta
 * generar un objeto Fecha con datos incorrectos
 */
public class FechaException extends Exception {

	/** 
	 * Constructor sin par�metros,
	 * genera una excepci�n sin mensaje explicativo espec�fico.
	 */
	public FechaException() {
		super();	// se llama al constructor de la clase padre Exception
	}

	/** 
	 * Constructor con par�metros,
	 * genera una excepci�n con un mensaje explicativo del error.
	 *
	 * @param mensaje Mensaje explicativo del error que ha generado la excepci�n
	 */
	public FechaException( String mensaje ) {
		super( mensaje );	// se llama al constructor de la clase padre Exception
	}
}