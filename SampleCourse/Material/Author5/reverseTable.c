/**CFile***********************************************************************

 FileName    [reverseTable.c]

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

typedef struct pageInfo PageInfo;

/*---------------------------------------------------------------------------*/
/* Structure declarations                                                    */
/*---------------------------------------------------------------------------*/

struct pageInfo {
    int pid;
    int page;
    /* int frame; */
    unsigned int stamp;
};

/*---------------------------------------------------------------------------*/
/* Variable declarations                                                     */
/*---------------------------------------------------------------------------*/

static PageInfo pageSet[NUM_FRAMES];
static int freePages = NUM_FRAMES;
static unsigned int numOperations = 0;

/*---------------------------------------------------------------------------*/
/* Macro declarations                                                        */
/*---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------*/
/* Static function prototypes                                                */
/*---------------------------------------------------------------------------*/
static int getOldest();

/*---------------------------------------------------------------------------*/
/* Definition of exported functions                                          */
/*---------------------------------------------------------------------------*/

/**Function********************************************************************

 Synopsis           [required]

 Description        [optional]

 ******************************************************************************/
int searchFrame(int pid, int page) {
    int i;
    int freeIdx = -1;

    for (i = 0; i < NUM_FRAMES; i++) {
        if (pageSet[i].pid == pid && pageSet[i].page == page) {
            pageSet[i].stamp = numOperations++;
            return i;
        }
    }

    if (freePages == 0) {
        /* Search for the oldest slot to replace */
        freeIdx = resetFrame(pid, page, getOldest());
    } else {
        freeIdx = getFrame(pid, page);
        freePages--;
    }

    /* Insert the content in the slot */
    pageSet[freeIdx].pid = pid;
    pageSet[freeIdx].page = page;
    pageSet[freeIdx].stamp = numOperations++;

    return freeIdx;
}

/**Function********************************************************************

 Synopsis           [required]

 Description        [optional]

 ******************************************************************************/
void removePages(int pid) {
    int i;
    for (i = 0; i < NUM_FRAMES; i++) {
        if (pageSet[i].pid != pid) {
            continue;
        }

        pageSet[i].pid = 0;
        releaseFrame(i);
        freePages++;
    }
}

/*---------------------------------------------------------------------------*/
/* Definition of internal functions                                          */
/*---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------*/
/* Definition of static functions                                            */
/*---------------------------------------------------------------------------*/

static int getOldest() {
    unsigned int value;
    int index;
    int i;

    index = -1;
    value = numOperations;
    for (i = 0; i < NUM_FRAMES; i++) {
        if (pageSet[i].stamp < value) {
            index = i;
            value = pageSet[i].stamp;
        }
    }

    return index;
}

