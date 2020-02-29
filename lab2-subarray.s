;
; CS1022 Introduction to Computing II 2018/2019
; Lab 2 - Subarray
;

N	EQU	8
M	EQU	4		

	AREA	RESET, CODE, READONLY
	ENTRY

	; initialize system stack pointer (SP)
	LDR	SP, =0x40010000

	;
	; Write your program here to determine whether SMALL_A
	;   is a subarray of LARGE_A
	;
	; Store 1 in R0 if SMALL_A is a subarray and zero otherwise
	;
	
	LDR R4, =N				; largeSize
	LDR R7, =M				; subSize
	SUB R12, R4, R7			; (largeSize - subSize) 
	LDR R3, =LARGE_A		; baseAddress

	LDR R5, =0				; largeRow
	LDR R6, =0				; largeColumn
	LDR R10, =0				; row = 0
	LDR R11, =0				; column = 0

; Scan all matrices of size M in larger matrix of size N

while3
	LDR R4, =N				; largeSize
	LDR R7, =M				; subSize
	SUB R12, R4, R7			; (largeSize - subSize) 
	CMP R10, R12			; while(row <= (largeSize - subSize)) {
	BHI	endwhile3

while4
	LDR R4, =N				; largeSize
	LDR R7, =M				; subSize
	SUB R12, R4, R7			; (largeSize - subSize) 
	CMP R11, R12			;	while(column <= (largeSize - subSize)) {
	BHI endwhile4			;

	MOV R5, R10				;		row2 = row
	MOV R6, R11				;		colum2 = column
	ADD R8, R7, R5			; 		(subSize + largeRow
	ADD R9, R7, R6			;   	(subSize + largeColumn)

while1
	CMP R5, R8				; 		while(row2 < (subSize + largeRow)) {
	BHS	endwhile1			
	
while2
	CMP R6, R9				;			while(colum2 < (subSize + largeColumn)) {
	BHS	endwhile2
	
	MOV	R2,	R6				;				col = column2
	MOV R1,	R5				;				ro = row2
	LDR R3, =LARGE_A
	LDR R4, =N				; 				largeSize
	BL	mIndex				;				^call mIndex using paramters above
	
;	Parameters for compare:
	MOV R1, R5				;				i
	MOV R2, R6				;				j
	MOV R3, R0				;				numberToCompare
	LDR R4, =M				;				matrixSize
	BL	compare				;				compare with submatrix
	
	CMP R0, #1				;				if(R0 == 1) {
	BNE	endif2
	ADD R12, R12, #1		;					counter++
endif2						;				}
	
	ADD R6, R6, #1			;				column++
	B	while2
endwhile2					;			}

	MOV R6, R11				;			largeColumn reset
	ADD R5, R5, #1			;			row2++
	B	while1
endwhile1					;		 }

	PUSH {R11}
	MUL R11, R7, R7
	CMP R12, R11				;		 if(counter == 9) {
	BNE	endif3
	POP	{R11}
	LDR R0, =1				;			IT IS A SUBARRAY
	B 	STOP
endif3						;		 }
	
	ADD R11, R11, #1		;		 column2++
	B	while4
endwhile4					;	}

	LDR R11, =0				; 	column = 0 (column reset)
	ADD R10, R10, #1		;	row++
	B	while3
endwhile3					; }
					
	LDR R0, =0

STOP	B	STOP

;-----MATRIX INDEX SUBROUTINE-----
;This subroutine takes two parameters i and j and returns the element at A[i][j] in a word sized matrix
;Parameters:
;	R1: i
;	R2: j
;	R3: A (base_address)
;	R4: matrixSize
;	Returns R0: element at A[i][j]
mIndex 
	PUSH {R5, LR}

	MUL R5, R1, R4						; row * rowSize
	ADD R5, R5, R2						; (row * rowSize) + column
	LDR	R0, [R3, R5, LSL #2]			; R0 = A[i][j]
	
	POP {R5, PC}	

;-----COMPARISON SUBROUTINE-----
;This subroutine checks if a number is equal to an element of a matrix
;Parameters:
;	R1: i
;	R2: j
;	R3: numberToCompare
;	R4: matrixSize
;	Returns R0: 1 if they are equal

compare
	PUSH {R3, LR}			; stack.push(numberToCompare)
	
	SUB R1, R1, R10			; Make i between 0 and 3
	SUB R2, R2, R11			; Make j between 0 and 3
	
	CMP	R1, #0				; if(row2 && column2 == 0) {
	BNE	endifcounter
	CMP R2, #0
	BNE	endifcounter
	LDR R12, =0				; 	counter = 0
endifcounter				; }
	

	LDR R3, =SMALL_A		; baseAddress
	BL	mIndex				; element = SMALL_A[i][j]
	
	POP {R3}				; stack.pop(numberToCompare)
	
	CMP R0, R3				; if(element == numerToCompare) {
	BNE	endif1
	LDR R0, =1				;	return 1
	B	skipelse
endif1						; } else {
	LDR R0, =0				; 	return 0
skipelse					; }

	POP {PC}

; test data
;

LARGE_A	DCD	 48, 37, 15, 44,  3, 17, 26, 67
	DCD	  2,  9, 12, 18, 14, 33, 16, 89
	DCD	 13, 20,  1, 22,  7, 48, 21, 7
	DCD	 27, 19, 44, 49, 44, 18, 10, 8
	DCD	 29, 17, 22,  4, 46, 43, 41, 8
	DCD	 37, 35, 38, 34, 16, 25,  0, 9
	DCD	 17,  0, 48, 15, 27, 35, 11, 0
	DCD  10,  9,  5, 19, 90, 10,  8, 4

;SMALL_A	DCD	 48, 37, 15, 44
;	DCD	  2, 9, 12, 18
;	DCD	 13, 20, 1, 22
;	DCD	 27, 19, 44, 49

SMALL_A	DCD	 9, 12, 18, 14
	DCD	  20, 1, 22, 7
	DCD	 19, 44, 49, 44
	DCD	 17, 22,  4, 46
		

;SMALL_A	DCD	 37, 15, 44
;	DCD	  9, 12, 18
;	DCD	 20, 1, 22

	END
