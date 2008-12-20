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

