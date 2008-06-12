/**CFile***********************************************************************

 FileName    [main.c]

 Synopsis    [Generates a set of pairs (pid, page) to the reverse table page.]

 Description [The program parses the received arguments that specify the
 number of processes creating requests as well as the number of pages in their
 working set and the number of total request to be simulated. It simply
 iterates as many times as its last parameter selecting a process and
 generating a page request from its working set.]

 Author      [Abelardo Pardo abel@it.uc3m.es, 
 Ralf Seepold ralf.seepold@uc3m.es]
 ]

 ******************************************************************************/

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

#include "ao.h"
#include "frames.h"

// Maximum execution time in seconds
#ifndef TIMEOUT
// Maximum CPU time allowed to execute
#define TIMEOUT 60
#endif

/* Additional methods in frames.c that are needed by the main */
int checkFrame(int index, int pid, int page);
int getFrameSize();
int getFrameOperations();

/*---------------------------------------------------------------------------*/
/* Type declarations                                                         */
/*---------------------------------------------------------------------------*/

/* Type description to simplify the handling of the alarm */
typedef void (*sighandler_t)();

/* The three methods that must be implemented in reverseTable.c */
int searchFrame(int pid, int page);
void removePages(int pid);

/*---------------------------------------------------------------------------*/
/* Static function prototypes                                                */
/*---------------------------------------------------------------------------*/
/* Used only when program bombs out */
static void errorMsg(char *);

/*---------------------------------------------------------------------------*/
/* Definition of exported functions                                          */
/*---------------------------------------------------------------------------*/

/**Function********************************************************************

 Synopsis           [Simulation procedure.]

 Description [Implements a loop generating as many page requests as specified
 by the third parameter, produced by as many processes as specified by the
 first parameter and from a fictitious working set with as many pages as
 specified by the second parameter.]

 ******************************************************************************/
int main(int argc, char **argv) {
    char *checkPtr; /* To check integer parsing with strtol */
    int numProcess; /* Number of processes received as first parameter */
    int pagePerProcess; /* Pages in the working set, second parameter. */
    int numRequests; /* Number of requests to simulate, third parameter */
    int valueProcess; /* Index to iterate over the processes */
    int valuePage; /* Index to iterate over the page numbers */
    int valueRequest; /* Index to iterate over the requests */
    long cpuLap; /* To store the CPU time */
    long seed; /* To initialize the random number generator */
    int *offset; /* Array with shift factors for working sets */
    int half; /* For looping over the two halves of the bench */

    /* If the number of parameters is incorrect, stop */
    if (argc < 3) {
        errorMsg("Executable needs 3 integer arguments.");
    }

    /* Parse first integer */
    numProcess = strtol(argv[1], &checkPtr, 10);
    if (*checkPtr != '\0' || numProcess < 1) {
        errorMsg("First parameter must be a positive non-zero integer.");
    }

    /* Parse second integer */
    pagePerProcess = strtol(argv[2], &checkPtr, 10);
    if (*checkPtr != '\0' || pagePerProcess < 1) {
        errorMsg("Second parameter must be a positive non-zero integer.");
    }

    /* Parse third integer */
    numRequests = strtol(argv[3], &checkPtr, 10);
    if (*checkPtr != '\0' || numRequests < 1) {
        errorMsg("Third parameter must be a positive non-zero integer.");
    }

#ifdef DEBUG
    printf("Parameters correctly parsed:\n");
    printf("  numProcess     = %d\n", numProcess);
    printf("  pagePerProcess = %d\n", pagePerProcess);
    printf("  numRequests    = %d\n", numRequests);
#endif

    /* Dump the execution line to be able to replicate results */
    for (valueRequest = 0; valueRequest < argc; valueRequest++) {
        printf("%s ", argv[valueRequest]);
    }
    printf("\n");

    // Set the execution time out (seconds)
#ifndef DEBUG
    __aoMiscSetTimeOutAlarm(TIMEOUT);
#endif

    // Set the default file size limit
    __aoSetDefaultMaxFileSize();

    // Initialize the random number generator
    seed = -1;
    __aoMiscRan3(&seed);
    seed = 0; // Value must be != -1 to generate numbers

    /* Initialize the array with page offsets */
    offset = (int *)calloc(numProcess, sizeof(int));

    /* Start point for CPU usage measure */
    cpuLap = __aoMiscCpuTime();

    /* Main simulation loop, with as many iteratios as requests */
    for (half = 0; half < 2; half++) {
        for (valueRequest = 0; valueRequest < numRequests/2; valueRequest++) {
            int frameNumber;

            /* Get the process number producing the request */
            valueProcess = 1 + numProcess * __aoMiscRan3(&seed);

            /* 
             * Get the page number within the proper page range displaced by the
             * offset . This is to simulate a process that keeps requesting pages
             * over a window tha is sliding towards higher values. */
            valuePage = (offset[valueProcess]++) + pagePerProcess
                    * __aoMiscRan3(&seed);

            // need to guarantee that no page number is larger than pagePerProcess
            valuePage = valuePage % pagePerProcess;

            /* Get the frame number from the reverse table page */
            frameNumber = searchFrame(valueProcess, valuePage);

#ifdef DEBUG
            printf("Request[%d] = %d, %d -> %d\n", valueRequest, valueProcess,
                    valuePage, frameNumber);
#endif

            /* Check that the received frame is consistent with the information
             * stored internally */
            if (!checkFrame(frameNumber, valueProcess, valuePage)) {
                if ((getenv("LANG") == NULL) || (strncmp(getenv("LANG"), "en_",
                        3) == 0)) {
                    printf("%s Returned incorrect frame number %d\n",
                            __aoGetErrorPrefix(), frameNumber);
                } else {
                    printf("%s Devuelto número de marco incorrecto %d\n",
                            __aoGetErrorPrefix(), frameNumber);
                }
                exit(-1);
            }
        }
        /* Nuke half the processes to test this functionality */
        for (valueProcess = 1; valueProcess <= numProcess/2; valueProcess++) {
            removePages(valueProcess);
        }
    } /* End of the loop over two executions */

    /* Remove all frames from the frameSet */
    for (valueProcess = 1; valueProcess <= numProcess; valueProcess++) {
        removePages(valueProcess);
    }

    /* End point for CPU usage measure */
    cpuLap = __aoMiscCpuTime() - cpuLap;

    /* Get rid of the offset array */
    free(offset);

    /* Frame size should be zero by now */
    if (getFrameSize() != 0) {
        if ((getenv("LANG") == NULL)
                || (strncmp(getenv("LANG"), "en_", 3) == 0)) {
            printf("%s There are %d frames not released.\n",
                    __aoGetErrorPrefix(), getFrameSize());
        } else {
            printf("%s Quedan %d marcos por liberar.\n", __aoGetErrorPrefix(),
                    getFrameSize());
        }
        exit(-1);
    }

    /* Dump results */
    printf("Frames          = %d\n", NUM_FRAMES);
    printf("Num. Processes  = %d\n", numProcess);
    printf("Page per Proc.  = %d\n", pagePerProcess);
    printf("Requests        = %d\n", numRequests);
    printf("Page Faults     = %d (%.2f %%) \n", getFrameOperations(), 100.0
            * getFrameOperations() / numRequests);
    printf("CPU time = %ld (milliseconds)\n", cpuLap);

    return 0;
}

/*---------------------------------------------------------------------------*/
/* Definition of internal functions                                          */
/*---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------*/
/* Definition of static functions                                            */
/*---------------------------------------------------------------------------*/

/**Function********************************************************************

 Synopsis           [required]

 Description        [optional]

 ******************************************************************************/
static void errorMsg(char *msg) {
    printf("%s %s\n", __aoGetErrorPrefix(), msg);
    exit(-1);
}

