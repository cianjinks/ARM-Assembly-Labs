;
; CS1022 Introduction to Computing II 2018/2019
; Magic Square
;

	AREA	RESET, CODE, READONLY
	ENTRY

	; initialize system stack pointer (SP)
	LDR	SP, =0x40010000

	LDR	R1, =arr1
	LDR	R4, =size1
	LDR	R2, [R4]

	BL	isMagic

stop	B	stop

;isMagic
;This subroutine takes in a reference to a two dimensional array in memory and its size then
;returns wether it is a magic square or not
;Return:
;	R0 - 0 or 1 wether it is a magic square of not
;Parameters:
;	R1 - Reference to the square 2D array
; 	R2 - Size of the square 2D array
isMagic
	PUSH {R4-R9, LR}
	
	LDR R4, =0				; magicNumber = 0
	LDR R5, =0				; column = 0
	
while1
	CMP R5, R2				; while(column < Size) {
	BGE	endwhile1
	LDR R7, [R1, R5, LSL #2]; 	R7 = 2DArray[column]
	ADD R4, R4, R7			;	magicNumber += R7
	ADD R5, R5, #1			;	column++
	
	B	while1
endwhile1					; }

	LDR R5, =0				; column = 0
	LDR R6, =0				; row = 0
	
while2
	CMP R6, R2				; while(row < Size) {
	BGE	endwhile2
	LDR R8, =0				; 	magicNumber2 = 0
while3			
	CMP R5, R2				;	while(column < Size) {
	BGE	endwhile3
	MUL R9, R6, R2			;		R9 = row * Size
	ADD	R9, R9, R5			;		R9 += column
	LDR R7, [R1, R9, LSL #2]; 		R7 = 2DArray[(row * Size) + column]
	ADD R8, R8, R7			;		magicNumber2 += R7
	ADD R5, R5, #1			;		column++;
	B	while3
endwhile3					;	}
	CMP R4, R8				;	if(magicNumber != magicNumber2) {
	BEQ	endif1
	LDR R0, =0				;		return false (place 0 in R0 then branch to end)
	B	endmagic			
endif1						;   }
	LDR R5, =0				; 	column = 0
	ADD	R6, R6, #1			;	row++
	B	while2
endwhile2					; }

	LDR R5, =0				; column = 0
	LDR R6, =0				; row = 0
	
while4
	CMP R5, R2				; while(column < Size) {
	BGE	endwhile4
	LDR R8, =0				; 	magicNumber2 = 0
while5
	CMP	R6, R2				;	while(row < Size) {
	BGE	endwhile5
	MUL R9, R6, R2			;		R9 = row * Size
	ADD	R9, R9, R5			;		R9 += column
	LDR R7, [R1, R9, LSL #2]; 		R7 = 2DArray[(row * Size) + column]
	ADD R8, R8, R7			;		magicNumber2 += R7
	ADD R6, R6, #1			;		row++;
	B	while5
endwhile5					;	}
	CMP R4, R8				;	if(magicNumber != magicNumber2) {
	BEQ	endif2
	LDR R0, =0				;		return false (place 0 in R0 then branch to end)
	B	endmagic			
endif2						;   }
	LDR R6, =0				; 	row = 0
	ADD	R5, R5, #1			;	column++
	B	while4
endwhile4					; }

	LDR R5, =0				; column = 0
	LDR R6, =0				; row = 0
	LDR R8, =0				; magicNumber2 = 0
	
while6
	CMP R6, R2				; while(row < Size) {
	BGE	endwhile6			
	
	MUL R9, R6, R2			;	R9 = row * Size
	ADD	R9, R9, R5			;	R9 += column
	LDR R7, [R1, R9, LSL #2]; 	R7 = 2DArray[(row * Size) + column]
	ADD R8, R8, R7			;	magicNumber2 += R7
	
	ADD	R5, R5, #1			;	column++
	ADD R6, R6, #1			;	row++
	B	while6
endwhile6					; }
	CMP R4, R8				; if(magicNumber != magicNumber2) {
	BEQ	endif3
	LDR R0, =0				;	return false (place 0 in R0 then branch to end)
	B	endmagic			
endif3						; }	

	SUB	R5, R2, #1			; column = Size - 1
	LDR R6, =0				; row = 0
	LDR R8, =0				; magicNumber2 = 0
	
while7
	CMP R5, #0				; while(column >= 0)	
	BLT	endwhile7				
	
	MUL R9, R6, R2			;	R9 = row * Size
	ADD	R9, R9, R5			;	R9 += column
	LDR R7, [R1, R9, LSL #2]; 	R7 = 2DArray[(row * Size) + column]
	ADD R8, R8, R7			;	magicNumber2 += R7
	
	SUB R5, R5, #1			;	column--
	ADD R6, R6, #1			;	row++
	B	while7
endwhile7					; }
	CMP R4, R8				; if(magicNumber != magicNumber2) {
	BEQ	endif4
	LDR R0, =0				;	return false (place 0 in R0 then branch to end)
	B	endmagic			
endif4						; }	

	LDR R0, =1				; If every single check passes then it is a magic square (return 1 for true)
	
endmagic
	POP {R4-R9, PC}
	
	
	
size1	DCD	3			; a 3x3 array
arr1	DCD	2, 7, 6		; the array
		DCD	9, 5, 1
		DCD	4, 3, 8


	END
