;
; CSU11021 Introduction to Computing I 2019/2020
; 64-bit Shift
;

	AREA	RESET, CODE, READONLY
	ENTRY

	LDR	R1, =0xD9448A9B		; most significaint 32 bits (63 ... 32)
	LDR	R0, =0xB8AA9D3B		; least significant 32 bits (31 ... 0)
	LDR	R2, =4				; shift count
	
	LDR R3, =0x7FFFFFFF		; msBitMask
	LDR R5, =0xFFFFFFFE		; lsBitMask
	LDR R4, =0				; isSigned
	LDR R6, =0				; shift
	LDR R9,	=0xFFFFFFFF		; signedMask
	
	BIC	R4, R2, R3			;isSigned = BIC(shiftCount, msBitMask)
							;//SHIFT RIGHT
	CMP R4, #0				;if(isSigned == 0) {
	BNE	else1
while1
	CMP R6, R2				;	while(shift < shiftCount) {
	BHS	endwhile1
	
	LDR R7, =0				;		isOne = 0
	MOV R0, R0, LSR #1		;		LS32 >> 1
	BIC	R7,	R1,	R5			;		isOne = BIC(MS32, lsBitMask)
	CMP	R7, #1				;		if(isOne == 1) {
	BNE	endif2
	LDR R8,	=0x80000000		;			R8 = 0x8000000
	ADD	R0, R0, R8			;			LS32 = LS32 + R8
endif2						;		}
	MOV R1, R1, LSR	#1		;		MS32 >> 1
	
	ADD R6, R6, #1			;		shift++
	B	while1				;	}
endwhile1
	B endif1				
							;}
							;//SHIFT LEFT
else1						;else{
	EOR	R2, R2, R9			;	XOR shiftCount, shiftCount, signedMask
	ADD R2, R2, #1			;	shiftCount = shiftCount + 1
while2
	CMP R6, R2				;	while(shift < shiftCount) {
	BHS endwhile2
	
	LDR R7, =0				;		isOne = 0
	MOV R1, R1, LSL	#1		;		MS32 << 1
	BIC	R7,	R0,	R3			;		isOne = BIC(LS32, msBitMask)
	LDR R8, =0x80000000
	CMP R7, R8				;		if(isOne == 0x80000000) {
	BNE endif3
	ADD R1, R1, #1			;			MS32 = MS32 + 1
endif3						;		}
	MOV R0, R0, LSL #1		;		LS32 << 1

	ADD R6, R6, #1			;		shift++
	B	while2				;	}
endwhile2
							;}
endif1
	

STOP	B	STOP

	END
