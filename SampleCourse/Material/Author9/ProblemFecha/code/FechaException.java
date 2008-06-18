/**
 * La excepción FechaException se lanza cuando se intenta
 * generar un objeto Fecha con datos incorrectos
 */
public class FechaException extends Exception {

	/** 
	 * Constructor sin parámetros,
	 * genera una excepción sin mensaje explicativo específico.
	 */
	public FechaException() {
		super();	// se llama al constructor de la clase padre Exception
	}

	/** 
	 * Constructor con parámetros,
	 * genera una excepción con un mensaje explicativo del error.
	 *
	 * @param mensaje Mensaje explicativo del error que ha generado la excepción
	 */
	public FechaException( String mensaje ) {
		super( mensaje );	// se llama al constructor de la clase padre Exception
	}
}