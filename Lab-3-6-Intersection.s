;
; CSU11021 Introduction to Computing I 2019/2020
; Intersection
;

	AREA	RESET, CODE, READONLY
	ENTRY

	LDR	R0, =0x40000000	; address of sizeC
	LDR	R1, =0x40000004	; address of elemsC
	
	LDR	R6, =sizeA	; address of sizeA
	LDR	R2, [R6]	; load sizeA
	LDR	R3, =elemsA	; address of elemsA
	
	LDR	R6, =sizeB	; address of sizeB
	LDR	R4, [R6]	; load sizeB
	LDR	R5, =elemsB	; address of elemsB
	
	LDR R7, =0		;scanElement = 0
	LDR R8, =0		;currentElement = 0
	LDR R9, =0		;total = 0
	
while1
	CMP R2, #0x00	;while(sizeA > 0) {
	BLS	endwhile
	LDR	R7, [R3]	;	scanElement = Memory.byte[elemsA]
	LDR R5, =elemsB	;	Reset address of elemsB
	LDR R4,	[R6]	;	Reset sizeB

while2
	CMP R4,	#0x00	;	while(sizeB > 0) {
	BLS endwhile2
	LDR R8, [R5]	;		currentElement = Memory.byte[elemsB]
					
	CMP R7,	R8		;		if(currentElement == scanElement) {
	BNE	endif1
	LDR R9, [R0]	;			total = Memory.byte[sizeC]
	ADD R9, R9, #1	;			total++
	STR	R9,	[R0]	;			Memory.byte[sizeC] = total
	STR	R8,	[R1]	;			Memory.byte[elemsC]	= currentElement
	ADD	R1,	R1,	#4	;			elemsC + 4
endif1				;		}	
	ADD	R5, R5, #4	;		elemsB + 4
	SUB R4, R4, #1	;		sizeB--
	B	while2		;	}
endwhile2	
	ADD	R3, R3, #4	;	elemsA + 4
	SUB R2, R2, #1	;	sizeA--
	B	while1		;}
endwhile

STOP	B	STOP

;sizeA	DCD	4
;elemsA	DCD	7, 14, 6, 3

;sizeB	DCD	9
;elemsB	DCD	20, 11, 14, 5, 7, 2, 9, 12, 17

sizeA	DCD	7
elemsA	DCD	8, 9, 4, 1, 6, 7, 2
	
sizeB	DCD	5
elemsB	DCD	8, 9, 4, 1, 0

	END
