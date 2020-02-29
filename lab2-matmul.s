;
; CS1022 Introduction to Computing II 2018/2019
; Lab 2 - Matrix Multiplication
;

N	EQU	4		

	AREA	globals, DATA, READWRITE

; result array
ARR_R	SPACE	N*N*4		; N*N words (4 bytes each)


	AREA	RESET, CODE, READONLY
	ENTRY

	; initialize system stack pointer (SP)
	LDR	SP, =0x40010000

	;
	; write your matrix multiplication program here
	;
	
	LDR R0, =0				; i = 0
	LDR R1, =0				; j = 0
	LDR R2, =N				; N = 4
	LDR R3, =0				; k = 0
	LDR R5, =0				; baseAddress
	
while1
	CMP R0, R2				; while(i < N) {
	BHS	endwhile1
	
while2
	CMP R1, R2				;	while(j < N) {
	BHS endwhile2
	
	LDR R4, =0				; 		r = 0

while3
	CMP R3, R2				;			while(k < N) {
	BHS endwhile3
				
	;r = r + ( A[i][k] * B[k][j] )
	MOV R8, R0				;				copyOfI = I
	MUL R8, R2, R8			;				row * rowSize
	ADD R8, R8, R3			;				index of [i][k]	= (row * rowSize) + col
	LDR R5, =ARR_A			; 				R5 = Matrix A
	LDR	R9, [R5, R8, LSL #2];				R9 = A[i][k]
	
	MOV R8, R3				;				copyOfk = k
	MUL R8, R2, R8			;				row * rowSize
	ADD R8, R8, R1			;				index of [k][j]	= (row * rowSize) + col
	LDR R5, =ARR_B			; 				baseAddress = Matrix B
	LDR	R10, [R5, R8, LSL #2];				R10 = B[k][j]
	
	MUL R9, R10, R9			;				R9 = A[i][k] * B[k][j]
	ADD R4, R4, R9			;				r = r + R9
				
	ADD R3, R3, #1			;				k++
	B 	while3
endwhile3					;			}

	MOV R8, R0				;		copyOfI = I
	MUL R8, R2, R8			;		row * rowSize
	ADD R8, R8, R1			;		index of [i][j]	= (row * rowSize) + col
	LDR R5, =ARR_R			;		baseAddress = Matrix R
	STR	R4, [R5, R8, LSL #2];		R[i][j] = r
	LDR R3,	=0				;		k = 0
	ADD R1, R1, #1			;		j ++
	B	while2
endwhile2					;	}

	LDR R1, =0				;	j = 0
	ADD R0, R0, #1			; 	i ++
	B 	while1
endwhile1					; }

STOP	B	STOP


;
; test data
;

ARR_A	DCD	 1,  2,  3,  4
	DCD	 5,  6,  7,  8
	DCD	 9, 10, 11, 12
	DCD	13, 14, 15, 16

ARR_B	DCD	 1,  2,  3,  4
	DCD	 5,  6,  7,  8
	DCD	 9, 10, 11, 12
	DCD	13, 14, 15, 16

	END
