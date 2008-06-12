/**CFile***********************************************************************

  FileName    [main.c]

  Synopsis    [Main Testing Program for the IntSquare problem]

  Author      [Abelardo Pardo abel@it.uc3m.es]

  Copyright   [This file was created at the University Carlos III of Madrid.
  The University Carlos III of Madrid makes no warranty about the suitability
  of this software for any purpose. It is presented on an AS IS basis.]

  Revision    [$Id: main.c,v 1.4 2005/05/11 07:47:56 abel Exp $]

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
asm(".include \"../square.s\" ");
#else
asm(".include \"square.s\" ");
#endif

asm("__mainsize__: NOP");
extern int __mainsize__;

asm(".data\n__aoMiscEndDataMark:");
extern void *__aoMiscEndDataMark;

#ifndef NUMTESTS        // Number random executions to perform
#define NUMTESTS 100
#endif

extern int num;
extern int res;

static int myRes[2] = {0, 0};

int main(int argc, char **argv);
void squareCheck(int a, int *res);

int __start__(int argc, char **argv) {
    unsigned int dataSize, codeSize;
    int idx;
    int *resB = (&res) + 1;
    long seed;

    dataSize = (unsigned)&__aoMiscEndDataMark - 
               (unsigned)&__aoMiscBeginDataMark;
    codeSize = (unsigned)&__mainsize__ - (unsigned)&main;
    printf("LOG CODESIZE: %d\n", codeSize);
    printf("LOG DATASIZE: %d\n", dataSize);

    // If the codeSize is one, it means that only the RET instruction is
    // present, therefore, the submitted exercise contains no code. Terminate.
    if (codeSize == 1) {
	printf("No se ha recibido ninguna entrega.\n");
	exit(0);
    }

    // Create a duplicate of the static data section
    __aoAsCopyDataSegment((void *)&__aoMiscBeginDataMark, 
			  (void *)&__aoMiscEndDataMark);

    // Set the execution time out (seconds)
#ifndef DEBUG
    __aoMiscSetTimeOutAlarm(TIMEOUT);
#endif

    // Execute one time but initializing the result variables to non zero
    res = -1;
    *resB = -1;
    
    squareCheck(num, myRes);

    // Check the program preserves the register values
    __aoAsFlagActivationBlockAnomaly(&main, NULL, 0, NULL, 0, 0, "main", NULL, 0x00);
    if (__aoAsFlagModifiedRegisters() != 0) {
	exit(0);
    }
    
    // Check if the result is not stored in little endian
    if ((myRes[0] != myRes[1]) && (res == myRes[1]) && (*resB == myRes[0])) {
	printf("%s El resultado no está almacenado en little endian.\n", 
               __aoGetErrorPrefix());
	exit(0);
    }

    // Check the result is correct
    if ((res != myRes[0]) || (*resB != myRes[1])) {
	printf("%s Cuadrado de %d incorrecto.\n", __aoGetErrorPrefix(), num);
	exit(0);
    }

    seed = -1;
    __aoMiscRan3(&seed);
    seed = 0;

    // Execute NUMTESTS times with random positive numbers
    for (idx = 0; idx < NUMTESTS; idx++) {
	// Restore the original data values in the program
	__aoAsRestoreDataSegment();

	num = __aoMiscRan3(&seed) * (1<<26);

	squareCheck(num, myRes);

	// Call the student code with the original data.
	__aoAsFlagActivationBlockAnomaly(&main, NULL, 0, NULL, 0, 0, "main", NULL, 0x00);
	if (__aoAsFlagModifiedRegisters() != 0) {
	    exit(0);
	}
	
	// Check if the result is not stored in little endian
	if ((myRes[0] != myRes[1]) && (res == myRes[1]) && (*resB == myRes[0])) {
	    printf("%s El resultado no está almacenado en little endian.\n",
                   __aoGetErrorPrefix()); exit(0);
	}

	if ((res != myRes[0]) || (*resB != myRes[1])) {
	    printf("%s Cuadrado de %d incorrecto. ", __aoGetErrorPrefix(), 
	 	   num);
	    printf(" Obtenido=%08x:%08x, Correcto=%08x:%08x\n", *resB, res,
		   myRes[1], myRes[0]);
	    exit(0);
	}

    }

    // Check register usage
    __aoAsWarnNumPush((unsigned char *)&main, "main", 3);

    // Check use of pusha
    __aoAsWarnPusha((unsigned char *)&main, "main");
    
    printf("LOG STACKSIZE %d\n", __aoAsGetStackSize(&main));

    // Free the stored data segment
    __aoAsCopyDataSegment(NULL, NULL);

    // Normal execution
    exit(0);
}

