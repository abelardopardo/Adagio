/**CFile***********************************************************************

  FileName    [main.c]

  Synopsis    [Main Testing Program for the BinarySearch problem]

  Author      [Abelardo Pardo abel@it.uc3m.es]

  Copyright   [This file was created at the University Carlos III of Madrid.
  The University Carlos III of Madrid makes no warranty about the suitability
  of this software for any purpose. It is presented on an AS IS basis.]

  Revision    [$Id: main.c,v 1.5 2005/05/18 10:01:24 abel Exp $]

******************************************************************************/
#include "ao.h"

// Maximum execution time in seconds
#ifndef TIMEOUT
// Maximum CPU time allowed to execute
#define TIMEOUT 5
#endif

asm(".data\n__aoMiscBeginDataMark:");
extern void *__aoMiscBeginDataMark;

#ifndef DEVELOP
asm(".include \"../buscar.s\" ");
asm(".include \"../buscarmain.s\" ");
#else
asm(".include \"buscar.s\" ");
asm(".include \"buscarmain.s\" ");
#endif

asm("__mainsize__: NOP");
extern int __mainsize__;

asm(".data\n__aoMiscEndDataMark:");
extern void *__aoMiscEndDataMark;

// Force the given routine to be accesible from outside this file
asm(".globl buscar");

extern int array;
extern int longitud;
extern char formato;

int main(int argc, char **argv);
void buscar(int size, int *table, int search, int result);
static int mySearch(int size, int *table, int value);

int __start__(int argc, char **argv) {
    unsigned int dataSize, codeSize;
    int myResult, subroutineResult;
    int diagnostics;
    int *arrayPtr;
    struct paramData {
	int length;
	int *tablePtr;
	int search;
    } pData;
    int i;

    dataSize = (unsigned)&__aoMiscEndDataMark - (unsigned)&__aoMiscBeginDataMark;
    codeSize = (unsigned)&__mainsize__ - (unsigned)&main;
    printf("LOG CODESIZE: %d\n", codeSize);
    printf("LOG DATASIZE: %d\n", dataSize);

    // If the codeSize is one, it means that only the RET instruction is
    // present, therefore, the submitted exercise contains no code. Terminate.
    if (codeSize == 1) {
	printf("No se ha recibido ninguna entrega.\n");
	exit(0);
    }

    // Check that the data section contains consistent data
    dataSize = ((unsigned)&longitud - (unsigned)&array) / 4;
    if (dataSize != longitud) {
	printf("%s valor inicial de longitud (%d) incorrecto.\n",
	       __aoGetErrorPrefix(), longitud);
	exit(0);
    }

    // Create a duplicate of the static data section
    __aoAsCopyDataSegment((void *)&__aoMiscBeginDataMark, 
			  (void *)&__aoMiscEndDataMark);

    // Set the execution time out (seconds)
#ifndef DEBUG
    __aoMiscSetTimeOutAlarm(TIMEOUT);
#endif

    // Make sure the subroutine has the activation block
    if (__aoAsFlagNoActivationBlock((unsigned char *)&buscar, "buscar")) {
	exit(0);
    }
    
    // Check the main execution
    diagnostics = 
	__aoAsFlagActivationBlockAnomaly((void *)main, // Function to call
					 NULL,         // Ptr to param
					 0,            // Size of param
					 NULL,         // Ptr to result
					 0,            // Size of result
					 0x00,         // No register to eax
					 "main",       // Function name
					 NULL,         // Capture result
					 0x00);        // Expected diag

    // Notify if any register has been modified
    if (__aoAsFlagModifiedRegisters() != 0) {
	exit(0);
    }
    
    // Check diagnostics returned by the main execution.
    if (diagnostics > 1) {
	exit(0);
    }

    // Execute the subroutine one time per element in the array
    arrayPtr = &array;
    pData.length = longitud;
    pData.tablePtr = arrayPtr;
    for (i = 0; i < longitud; i++) {
	myResult = mySearch(longitud, arrayPtr, arrayPtr[i]);

	pData.search = arrayPtr[i];

	// Restore the data segment in the program to its initial values
	__aoAsRestoreDataSegment();

	// Check the routine execution
	diagnostics = 
	    __aoAsFlagActivationBlockAnomaly((void *)buscar,   // Function to call
					     (void *)&pData,   // Ptr to param
					     sizeof(pData),    // Size of params
					     &subroutineResult,// Ptr to result
					     sizeof(subroutineResult), // Size of result
					     0x00,             // No register to eax
					     "buscar",         // Function name
					     NULL,             // Capture result
					     0x00);            // Expected diag

	// Notify if any register has been modified
	if (__aoAsFlagModifiedRegisters() != 0) {
	    exit(0);
	}
	
	// Check diagnostics returned by subroutine execution.
	if (diagnostics > 1) {
	    exit(0);
	}

	if (subroutineResult != myResult) {
	    printf("%s Resultado incorrecto (%d) para tabla [%d",
		   __aoGetErrorPrefix(), subroutineResult, arrayPtr[0]);
	    for (i = 1; i < longitud; i++) {
		printf(", %d", arrayPtr[i]);
	    }
	    printf("] y búsqueda de %d\n", 
		   arrayPtr[i]);
	    exit(0);
	}
    } // Loop over all the elements of the array

    // Execute one time per element in the array but this time with
    // non-existent elements
    for (i = 1; i < longitud; i++) {
	// If the two elements in the array are consecutive, there is no point
	// in testing
	if (arrayPtr[i - 1] == arrayPtr[i] - 1) {
	    continue;
	}

	pData.search = arrayPtr[i] - 1;

	// Restore the data segment in the program to its initial values
	__aoAsRestoreDataSegment();

	// Check the routine execution
	diagnostics = 
	    __aoAsFlagActivationBlockAnomaly((void *)buscar,    // Function to call
					     (void *)&pData,   // Ptr to param
					     sizeof(pData),    // Size of params
					     &subroutineResult,// Ptr to result
					     sizeof(subroutineResult), // Size of result
					     0x00,             // No register to eax
					     "buscar",          // Function name
					     NULL,             // Capture result
					     0x6);             // Expected diag

	// Notify if any register has been modified
	if (__aoAsFlagModifiedRegisters() != 0) {
	    exit(0);
	}
	
	// Check diagnostics returned by subroutine execution.
	if (diagnostics > 1) {
	    exit(0);
	}

	if (subroutineResult != -1) {
	    printf("%s Resultado incorrecto (%d) para tabla [%d",
		   __aoGetErrorPrefix(), subroutineResult, arrayPtr[0]);
	    for (i = 1; i < longitud; i++) {
		printf(", %d", arrayPtr[i]);
	    }
	    printf("] y búsqueda de %d\n", 
		   arrayPtr[i]);
	    exit(0);
	}
    }

    // Check register usage
    __aoAsWarnNumPush((unsigned char *)&main, "main", 3);
    __aoAsWarnNumPush((unsigned char *)&buscar, "buscar", 5);

    // Check use of pusha
    __aoAsWarnPusha((unsigned char *)&main, "main");
    __aoAsWarnPusha((unsigned char *)&buscar, "buscar");
    
    // Free the stored data segment
    __aoAsCopyDataSegment(NULL, NULL);

    // Normal execution
    exit(0);
}

static int mySearch(int size, int *table, int value) {
    int i, j, middle;

    i = 0;
    j = size;

    // Loop while the two indeces do not cross
    while (i <= j) {
	middle = (i + j) / 2;
	if (value == table[middle]) {
	    return middle;
	}

	if (value > table[middle]) {
	    i = middle + 1;
	} else {
	    j = middle - 1; 
	}
    }

    if ((i == j) && value == table[i]) {
	return i;
    }

    return -1;
}
