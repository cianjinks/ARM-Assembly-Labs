;
; CSU11021 Introduction to Computing I 2019/2020
; String Copy
;

	AREA	RESET, CODE, READONLY
	ENTRY

	LDR	R0, =tststr	; address of existing string
	LDR	R1, =0x40000000	; address for new string

	;
	; Write your program here to create the duplicate string
	;

STOP	B	STOP

tststr	DCB	"This is a test!",0

	END
