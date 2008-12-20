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

