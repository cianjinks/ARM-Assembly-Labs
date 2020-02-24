;
; CSU11021 Introduction to Computing I 2019/2020
; Pseudo-random number generator
;

	AREA	RESET, CODE, READONLY
	ENTRY
	;32 BIT XORSHIFT - Bit Cleared to 4bit
	
	LDR	R0, =0x40000000	; start address for pseudo-random sequence
	LDR	R1, =64		; number of pseudo-random values to generate

	LDR R2, =0xCACA62D8	; seed
	LDR	R3,	=0xFFFFFF00	;seedMask
	LDR R4,	=0			;seedCopy
	LDR	R5,	=0			;result
	
while
	CMP R1, #0			;while(noValues > 0) {
	BLS	endwhile
	
	MOV R4, R2, LSL	#13	;	seedCopy = seed << 13
	EOR	R2, R2, R4		;	XOR(seed, seed, seedCopy)
	MOV R4, R2, LSR	#17	;	seedCopy = seed >> 17
	EOR	R2, R2, R4		;	XOR(seed, seed, seedCopy)
	MOV R4, R2, LSL	#5	;	seedCopy = seed << 5
	EOR	R2, R2, R4		;	XOR(seed, seed, seedCopy)
	BIC	R5, R2, R3		;	result = BIC(seed, seedMask)
	
	STRB R5, [R0]		;	Memory.byte['startAddr'] = result
	ADD	R0, R0, #1		;	startAddr = startAddr + 1
	SUB	R1, R1, #1		;	noValues--
	
	B while
endwhile				;}
	

STOP	B	STOP

	END
