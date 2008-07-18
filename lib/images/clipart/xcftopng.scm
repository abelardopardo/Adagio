(define (batch-xcf2png pattern )
  (let* ((filelist (cadr (file-glob pattern 1))))
    (while (pair? filelist)
      (let* ((filename (car filelist))
	     (image (car (gimp-file-load RUN-NONINTERACTIVE 
                                         filename filename)))
	     (drawable (car (gimp-image-get-active-layer image)))
	    )
        (set! drawable (car (gimp-image-flatten image)))
	(gimp-file-save RUN-NONINTERACTIVE image drawable 
          (strcat (car (strbreakup filename ".")) ".png")
          (strcat (car (strbreakup filename ".")) ".png"))
	(gimp-image-delete image)
      )
      (set! filelist (cdr filelist))
    )
  )
)
(batch-xcf2png "*.xcf")
(gimp-quit 0)'

