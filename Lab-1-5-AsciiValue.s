;
; CSU11021 Introduction to Computing I 2019/2020
; Convert a sequence of ASCII digits to the value they represent
;

	AREA	RESET, CODE, READONLY
	ENTRY

	LDR	R1, ='2'	; Load R1 with ASCII code for symbol '2'
	LDR	R2, ='0'	; Load R2 with ASCII code for symbol '0'
	LDR	R3, ='3'	; Load R3 with ASCII code for symbol '3'
	LDR	R4, ='4'	; Load R4 with ASCII code for symbol '4'
	
	SUB R1, R1, #0x30	;Convert R1 from ASCII code to integer
	SUB R2, R2, #0x30	;Convert R2 from ASCII code to integer
	SUB R3, R3, #0x30	;Convert R3 from ASCII code to integer
	SUB R4, R4, #0x30	;Convert R4 from ASCII code to integer
	
	LDR R5, =1000		;10^3
	LDR R6, =100		;10^2
	LDR R7, =10			;10^1
	
	MUL R5, R1, R5		;Multiply the 4th decimal digit by 10^3
	MUL R6, R2, R6		;Multiply the 3rd decimal digit by 10^2
	MUL R7, R3, R7		;Multiply the 2nd decimal digit by 10^1
	
	ADD R0, R5, R6		;	  Add each of 
	ADD R0, R0, R7		;  the decimal places
	ADD R0, R0, R4		;   into one number

STOP	B	STOP

	END
