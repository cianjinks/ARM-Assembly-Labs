;
; CS1022 Introduction to Computing II 2018/2019
; Lab 3 - Floating-Point
;

	AREA	RESET, CODE, READONLY
	ENTRY

;
; Test Data
;
FP_A	EQU	0x41C40000
FP_B	EQU	0x41960000
FP_C	EQU 0xC1C40000


	; initialize system stack pointer (SP)
	LDR	SP, =0x40010000

	LDR	R0, =FP_A
	BL	fpfrac
	LDR R0, =FP_B
	BL	fpfrac
	LDR R0, =FP_C
	BL	fpfrac
	LDR	R0, =FP_A
	BL	fpexp
	LDR R0, =FP_B
	BL	fpexp
	LDR R0, =0x00C40000
	LSL R0, R0, #1			; Make it non normalised
	LDR R3, =0xFFFFFFFF
	EOR R0, R0, R3
	ADD R0, R0, #1
	LDR R1, =0x00000004
	BL	fpencode
	
stop	B	stop


;
; fpfrac
; decodes an IEEE 754 floating point value to the signed (2's complement)
; fraction
; parameters:
;	r0 - ieee 754 float
; return:
;	r0 - fraction (signed 2's complement word)
;
fpfrac

	PUSH {R4-R6, LR}
	
	LDR R4, =0x00000000
	LDR R5, =0x00000000
	LDR R6, =0x00000000
	
	LDR	R4, =0x7FFFFFFF			; Mask to obtain the sign
	BIC	R5, R0, R4				; Store sign in R5
	LSR	R5, R5, #31				; Shift sign to LSB
	LDR R4, =0xFF800000			; Mask to obtain unsigned fraction
	BIC	R6, R0, R4				; Store unsigned fraction in R6
	ADD R6, R6, #0x00800000 	; Add 1 to left of radix point 
	CMP R5, #1					; if(sign == 1) {
	BNE	endif1
	LDR R4, =0xFFFFFFFF			;	Mask to flip all bits
	EOR	R6, R6, R4				;	Flip all bits
	ADD	R6, R6, #1				;	Fraction++
endif1
	MOV R0, R6					;	Return the fraction in R0

	POP	{R4-R6, PC}



;
; fpexp
; decodes an IEEE 754 floating point value to the signed (2's complement)
; exponent
; parameters:
;	r0 - ieee 754 float
; return:
;	r0 - exponent (signed 2's complement word)
;
fpexp

	PUSH {R4-R5, LR}
	
	LDR R4, =0x00000000
	LDR R5, =0x00000000
	
	LDR	R4, =0x807FFFFF			; Mask to obtain exponent
	BIC	R5, R0, R4				; Store exponent in R5
	LSR	R5, R5, #23				; Shift exponent
	SUBS R5, R5, #127			; Unbias the exponent
	;LDR R4, =0xFFFFFFFF			; Mask to flip all the bits
	;EOR R5, R5, R4				; Flip all exponent bits
	;ADD R5, R5, #1				; exponenet++
	MOV R0, R5
	
	POP	{R4-R5, PC}


;
; fpencode
; encodes an IEEE 754 value using a specified fraction and exponent
; parameters:
;	r0 - fraction (signed 2's complement word)
;	r1 - exponent (signed 2's complement word)
; result:
;	r0 - ieee 754 float
;
fpencode

	PUSH{R4-R6, LR}
	
	LDR R4, =0x00000000
	LDR R5, =0x00000000
	LDR R6, =0x00000000
		
	CMP R0, #0x7FFFFFFF			; Check if fraction is negative
	BLS	endif2
	SUB R0, R0, #1				; 	fraction--
	LDR R4, =0xFFFFFFFF			;	Mask to flip all bits
	EOR	R0, R0, R4				;	Flip all bits
	LDR R5, =0x80000000			;	Load sign bit to 1
endif2

	; Check if fraction is normalised
while1
	LDR R4, =0x00FFFFFF			; Mask to check bits 25-32
	BIC R6, R0, R4				; Obtain bits 25-32
	CMP R6, #0					; while(bits 25-32 != 0) {
	BEQ	endwhile1
	CMP R5, #0x80000000			;	if(signed) {
	BNE	endif12
	LSL	R0, R0, #1				;		fraction << 1
	B	skipelse5
endif12							;	} else {
	LSR	R0, R0, #1				;		fraction >> 1
skipelse5						;	}
	ADD R1, R1, #1				;	exponent++
	B	while1					
endwhile1						; }

	LDR R4, =0x00800000			; Mask to remove bit to the left of radix point
	BIC	R0, R0, R4				; Clear bit to left of radix point in fraction
	ADDS R1, R1, #127			; Convert exponent to biased
	LSL	R1, R1, #23				; Align the exponent
	ADD R0, R0, R5				; Add together all the numbers
	ADD R0, R0, R1				; Add exponent in
	

	POP {R4-R6, PC}

	END
