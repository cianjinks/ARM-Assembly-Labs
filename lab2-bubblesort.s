;
; CS1022 Introduction to Computing II 2019/2020
; Lab 1B - Bubble Sort
;

N	EQU	10

	AREA	globals, DATA, READWRITE

; N word-size values

SORTED	SPACE	N*4		; N words (4 bytes each)


	AREA	RESET, CODE, READONLY
	ENTRY


	;
	; copy the test data into RAM
	;

	LDR	R4, =SORTED
	LDR	R5, =UNSORT
	LDR	R6, =0
whInit	CMP	R6, #N
	BHS	eWhInit
	LDR	R7, [R5, R6, LSL #2]
	STR	R7, [R4, R6, LSL #2]
	ADD	R6, R6, #1
	B	whInit
eWhInit

	LDR	R4, =SORTED
	LDR	R5, =UNSORT

	;
	; your sort program goes here
	;

while2					; do {
	LDR R1, =0			; 	swapped = false
	LDR R2, =N			; 	N = 10
	LDR R3, =0x1		; 	i = 1
while1
	CMP R3, R2			; 	while(i < N) {
	BHS	endwhile1
	
	MOV R8, R3			;		R8 = i
	SUB R8, R8, #0x1	;		R8--
	LDR	R6, [R4, R8, LSL #2];	array[i - 1]
	LDR R7, [R4, R3, LSL #2];	array[i]
	CMP R6, R7
	BLS	endif1			;		if(array[i-1] > array[i] {
	MOV R9, R6			;			tmpswap = array[i - 1]
	STR R7, [R4, R8, LSL #2];		array[i-1] = array[i]
	STR	R9,	[R4, R3, LSL #2];		array[i] = tmpswap
	LDR R1, =0x1		;			swapped = true
endif1					;		}
	ADD	R3, R3, #1		;		i++
	B	while1
endwhile1				; 	}
	CMP R1, #0x1		; } while(swapped);
	BEQ	while2

	

stop	B stop

UNSORT	DCD	9,3,0,1,6,2,4,7,8,5
;UNSORT DCD 1,8,2,4,7,9,3,1,2,4

	END
