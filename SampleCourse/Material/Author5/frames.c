/**CFile***********************************************************************

 FileName    [frames.c]

 Synopsis    [required]

 Description [optional]

 Author      [Abelardo Pardo abel@it.uc3m.es]

 ******************************************************************************/

#include <stdio.h>
#include <stdlib.h>

#include "ao.h"
#include "frames.h"

/*---------------------------------------------------------------------------*/
/* Constant declarations                                                     */
/*---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------*/
/* Type declarations                                                         */
/*---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------*/
/* Structure declarations                                                    */
/*---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------*/
/* Variable declarations                                                     */
/*---------------------------------------------------------------------------*/

static int frameSet[NUM_FRAMES][2];
static int occupied = 0;
static int numOperations = 0;

/*---------------------------------------------------------------------------*/
/* Macro declarations                                                        */
/*---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------*/
/* Static function prototypes                                                */
/*---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------*/
/* Definition of exported functions                                          */
/*---------------------------------------------------------------------------*/

/**Function********************************************************************

 Synopsis           [required]

 Description        [optional]

 ******************************************************************************/
int getFrame(int pid, int page) {
	int i;
	for (i = 0; i < NUM_FRAMES; i++) {
		if (frameSet[i][0] == 0) {
			frameSet[i][0] = pid;
			frameSet[i][1] = page;
			occupied++;
			numOperations++;
			return i;
		}
	}

	if ((getenv("LANG") == NULL) || (strncmp(getenv("LANG"), "en_", 3) == 0)) {
		printf("%s Too many frame requests.\n", __aoGetErrorPrefix());
	} else {
		printf("%s Se han pedido demasiados marcos.\n", __aoGetErrorPrefix());
	}
	exit(-1);
	return 0;
}

/**Function********************************************************************

 Synopsis           [required]

 Description        [optional]

 ******************************************************************************/
void releaseFrame(int index) {
	if (index >= NUM_FRAMES) {
		if ((getenv("LANG") == NULL)
				|| (strncmp(getenv("LANG"), "en_", 3) == 0)) {
			printf("%s Illegal releaseFrame operation with frame %d\n",
					__aoGetErrorPrefix(), index);
		} else {
			printf("%s Operaci�n releaseFrame incorrecta con marco %d\n",
					__aoGetErrorPrefix(), index);
		}
		exit(-1);
	}
	if (occupied == 0) {
		if ((getenv("LANG") == NULL)
				|| (strncmp(getenv("LANG"), "en_", 3) == 0)) {
			printf(
					"%s releaseFrame operation invoked, but no frame is occupied.\n",
					__aoGetErrorPrefix());
		} else {
			printf(
					"%s Llamada a releaseFrame, pero no hay ning�n marco ocupado.\n",
					__aoGetErrorPrefix());
		}
		exit(-1);
	}
	frameSet[index][0] = 0;
	occupied--;
}

/**Function********************************************************************

 Synopsis           [required]

 Description        [optional]

 ******************************************************************************/
int resetFrame(int pid, int page, int index) {
	int i;
	for (i = 0; i < NUM_FRAMES; i++) {
		if (i == index) {
			continue;
		}

		if (frameSet[i][0] == pid && frameSet[i][1] == page) {
			if ((getenv("LANG") == NULL) || (strncmp(getenv("LANG"), "en_", 3)
					== 0)) {
				printf("%s ResetFrame: Pair (%d, %d) already stored in ",
						__aoGetErrorPrefix(), pid, page);
				printf("frame %d.\n", i);
			} else {
				printf("%s ResetFrame: Par (%d, %d) ya almacenado en ",
						__aoGetErrorPrefix(), pid, page);
				printf("frame %d.\n", i);
			}
			exit(-1);
		}
	}

	if (frameSet[index][0] == 0) {
		if ((getenv("LANG") == NULL)
				|| (strncmp(getenv("LANG"), "en_", 3) == 0)) {
			printf("%s ResetFrame: Frame %d is not allocated.\n",
					__aoGetErrorPrefix(), index);
		} else {
			printf("%s ResetFrame: Marco %d no est� reservado.\n",
					__aoGetErrorPrefix(), index);
		}
		exit(-1);
	}

	frameSet[index][0] = pid;
	frameSet[index][1] = page;
	numOperations++;
	return index;
}

/**Function********************************************************************

 Synopsis           [required]

 Description        [optional]

 ******************************************************************************/
int checkFrame(int index, int pid, int page) {
	if (index >= NUM_FRAMES) {
		if ((getenv("LANG") == NULL)
				|| (strncmp(getenv("LANG"), "en_", 3) == 0)) {
			printf("%s Illegal frame number %d\n", __aoGetErrorPrefix(), index);
		} else {
			printf("%s N�mero de marco incorrecto:  %d\n",
					__aoGetErrorPrefix(), index);
		}
		exit(-1);
	}

	return (frameSet[index][0] == pid) && (frameSet[index][1] == page);
}

/**Function********************************************************************

 Synopsis           [required]

 Description        [optional]

 ******************************************************************************/
int getFrameSize() {
	return occupied;
}

/**Function********************************************************************

 Synopsis           [required]

 Description        [optional]

 ******************************************************************************/
int getFrameOperations() {
	return numOperations;
}

/*---------------------------------------------------------------------------*/
/* Definition of internal functions                                          */
/*---------------------------------------------------------------------------*/

void showFrame(void) {
	int i;

	for (i = 0; i < NUM_FRAMES; i++) {
		printf("frameSet[%d][0]=%d \t frameSet[%d][1]0=%d\n", i,
				frameSet[i][0], i, frameSet[i][1]);
	}
}

