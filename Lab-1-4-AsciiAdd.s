;
; CSU11021 Introduction to Computing I 2019/2020
; Adding the values represented by ASCII digit symbols
;

	AREA	RESET, CODE, READONLY
	ENTRY

	LDR	R1, ='2'	; Load R1 with ASCII code for symbol '2'
	LDR	R2, ='4'	; Load R2 with ASCII code for symbol '4'

	SUB R1, R1, #0x30	;Convert ASCII code to integer
	SUB R2, R2, #0x30	;Convert ASCII code to integer
	ADD R0, R1, R2		;Add the integers together
	ADD R0, R0, #0x30	;Convert integer to ASCII code

STOP	B	STOP

	END
