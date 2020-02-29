;
; CS1022 Introduction to Computing II 2018/2019
; Lab 2 - Upper Triangular
;

N	EQU	4	
;N	EQU 5

	AREA	RESET, CODE, READONLY
	ENTRY

	; initialize system stack pointer (SP)
	LDR	SP, =0x40010000

	;
	; write your program here to determine whether ARR_A
	;   (below) is a matrix in Upper Triangular form.
	;
	; Store 1 in R0 if the matrix is in Upper Triangular form
	;   and zero otherwise.
	;
	
	LDR R1, =N				; matrixSize = 4
	LDR R2, =ARR_A			; A[][]
	LDR R3, =1				; i = 1
	LDR R4, =0				; j = 0
	
while1
	CMP R3, R1				; while(i < matrixSize) {
	BHS	endwhile1
	
while2
	CMP R4, R3				;	while(j < i) {
	BHS endwhile2
	
	; (row * rowsize) + column	
	MOV R5, R3				;		copyOfI = I
	MUL R5, R1, R5			;		row * rowsize
	ADD R5, R5, R4			;		(row * rowsize) + column
	
	LDR R6, [R2, R5, LSL #2];		R6 = A[i][j]
	CMP R6, #0				;		if(A[i][j] != 0) {
	BEQ	endif1
	LDR R0, =0				;			R0 = 0
	B 	STOP				;			Branch to STOP
endif1						;		}
	
	ADD R4, R4, #1			;		j++
	B	while2
endwhile2					;	}
	
	LDR R4, =0				;   j = 0
	ADD R3, R3, #1			; 	i++
	B	while1	
endwhile1					; }

	LDR R0, =1				; R0 = 1

STOP	B	STOP


;
; test data
;

ARR_A	DCD	 1,  2,  3,  4
	DCD	 0,  6,  7,  8
	DCD	 0,  0, 11, 12
	DCD	 0,  0,  0, 16

;ARR_A	DCD	 5,  7,  9,  2, 4
;	DCD	 0,  5,  2,  8, 8
;	DCD	 0,  0, 6, 45, 10
;	DCD	 0,  0,  0, 1, 20
;	DCD  0,  0,  0, 0, 5

	END
