;
; CSU11021 Introduction to Computing I 2019/2020
; Bit Manipulation
;

	AREA	RESET, CODE, READONLY
	ENTRY

	LDR	R0, =137	; a = 137
	LDR	R1, =6   	; b = 6
	LDR R2, =0		; quotient = 0
	LDR R3, =0;		; remainder = 0
	LDR R4, =0x80000000 ; mask
	
while
	CMP R4, #0		;while(mask != 0) {
	BEQ	endwhile	;	
	MOV R3, R3, LSL #1;	remainder = remainder << 1

	AND	R5, R4, R0	;
	CMP R5, #0		;	if( (a & mask) != 0) {
	BEQ	endif1
	ORR	R3, R3, #1	;	remainder = remainder | 1
	
endif1					;	}
	CMP R3, R1		;	if(remainder >= b) {
	BLO	endif2		;	
	SUB	R3, R3, R1	;	remainder = remainder - b
	ORR	R2,	R2, R4	;	quotient = quotiet | mask
	
endif2				;	}
	MOV	R4, R4, LSR #1;	mask = mask >> 1
	B 	while
endwhile			;}

STOP	B	STOP

	END
