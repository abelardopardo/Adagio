/**CHeaderFile*****************************************************************

  FileName    [frames.h]

  Synopsis    [Defines the exported functions to handle frames.]

  Author      [Abelardo Pardo abel@it.uc3m.es]

******************************************************************************/

#ifndef _FRAMES_H
#define _FRAMES_H

/*---------------------------------------------------------------------------*/
/* Constant declarations                                                     */
/*---------------------------------------------------------------------------*/

/* Number of frames to be used by the manager. This constant may be changed at
 * compile time by specifying the option -DNUM_FRAMES=new_value
 */
#ifndef NUM_FRAMES
#define NUM_FRAMES 2048
#endif

/*---------------------------------------------------------------------------*/
/* Function prototypes                                                       */
/*---------------------------------------------------------------------------*/
int getFrame(int pid, int page);
void releaseFrame(int index);
int resetFrame(int pid, int page, int index);

#endif /* _FRAMES_H */
