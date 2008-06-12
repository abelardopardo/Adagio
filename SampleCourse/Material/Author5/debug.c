extern int frameSet[NUM_FRAMES][2];
static void checkTable();

static void checkTable() {
    int i;
    for (i = 0; i < NUM_FRAMES; i++) {
	int slot;
	if (pageSet[i].pid == 0) {
	    continue;
	}

	slot = pageSet[i].frame;
	if (frameSet[slot][0] != pageSet[i].pid ||
	    frameSet[slot][1] != pageSet[i].page) {
	    printf("Incosistency!!!\n");
	    exit(-1);
	}
    }
}
