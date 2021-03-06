		;TEX PATCH #2, 28 JUN 78
		;THIS PATCH CORRECTS AN ERROR WHICH OCCURS WHEN 
		;THE $F FORM FEED OPTION IS USED.  
		;IN PARTICULAR, THIS PATCH CAUSES A FORM FEED 
		;ON THE FIRST PAGE, WHICH WAS NOT PREVIOUSLY DONE.

PATCH		EQU	1D59H
L445		EQU	0980H
SAV$LINELENGTH	EQU	1F11H
FORM$FEED	EQU	1F0CH
PUTDEST		EQU	0672H
FF		EQU	0CH

		ORG	L445
		JMP	PATCH

RETPAT:

		ORG	PATCH
		STA	SAV$LINELENGTH
		LDA	FORM$FEED
		RAL
		MVI	C,FF
		CC	PUTDEST
		JMP	RETPAT
		END

