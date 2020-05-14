;
; CS1022 Introduction to Computing II 2019/2020
; eTest Group 4 Q1
;

N	EQU	9


	AREA	globals, DATA, READWRITE

array	SPACE	1024


	AREA	RESET, CODE, READONLY
	ENTRY

	; initialise the system stack pointer
	LDR	SP, =0x40010000


	LDR	R4, =array
	LDR	R5, =N	

	;
	; Your program goes here
	; (i.e. your translation of the pseudocode provided
	;
	
	LDR R6, =0			; i = 0
while1
	CMP R6, R5			; while(i < N) {
	BHS	endwhile1

	LDR R7, =0			;	j = 0
while2
	CMP R7, R6			;	while(j < i) {
	BHS	endwhile2
	
	MUL R8, R6, R5		;		R8 = row * rowSize
	ADD R8, R8, R7		;		R8 = (row * rowSize) + column
	STR	R7, [R4, R8, LSL #2];	array[i][j] = j
	
	ADD	R7, R7, #1		;		j++
	B	while2			;	}
endwhile2

	MOV R7, R6			;	j = i
while3
	CMP R7, R5			;	while(j < N) {
	BHS	endwhile3
	
	MUL R8, R6, R5		;		R8 = row * rowSize
	ADD R8, R8, R7		;		R8 = (row * rowSize) + column
	STR	R6, [R4, R8, LSL #2];	array[i][j] = i
	
	ADD	R7, R7, #1		;		j++
	B	while3
endwhile3				;	}

	ADD R6, R6, #1		; i++
	B	while1
endwhile1				; }


STOP	B	STOP


	END
