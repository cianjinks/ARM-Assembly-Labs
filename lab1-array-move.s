;
; CS1022 Introduction to Computing II 2018/2019
; Lab 1 - Array Move
;

N	EQU	16		; number of elements

	AREA	globals, DATA, READWRITE

; N word-size values

ARRAY	SPACE	N*4		; N words


	AREA	RESET, CODE, READONLY
	ENTRY

	; for convenience, let's initialise test array [0, 1, 2, ... , N-1]

	LDR	R0, =ARRAY
	LDR	R1, =0
L1	CMP	R1, #N
	BHS	L2
	STR	R1, [R0, R1, LSL #2]
	ADD	R1, R1, #1
	B	L1
L2

	; initialise registers for your program

	LDR	R0, =ARRAY					; arrayAddr
	LDR	R1, =6						; startIndex
	LDR	R2, =3						; endIndex
	LDR	R3, =N
	LDR R4, =0						; currentNumber
	LDR R5, =0						; replaceNumber
	
	; your program goes here
	
	CMP R1, R2 						; if(startIndex > endIndex) {
	BLS endif1
	
	LDR R4, [R0, R1, LSL #2]		; 	currentNumber	= Memory.byte[arrayAddr + 4 * startIndex]
	
while1								; 	while( startIndex != endIndex ) {
	CMP R1, R2						
	BEQ endwhile1
	 
	SUB R1, R1, #1					;		startIndex--;
	LDR R5, [R0, R1, LSL #2]        ;   	replaceNumber = Memory.byte[arrayAddr + 4 * startIndex]
	MOV	R6, R1                      ; 		copyStartIndex = startIndex
	ADD R6, R6, #1					;		copyStartIndex++;
	STR R5, [R0, R6, LSL #2]        ;   	Memory.byte[arrayAddr + 4 * copyStartIndex] = replaceNumber
	
	
	B while1
endwhile1							; 	}

	STR R4, [R0, R2, LSL #2]        ; 	Memory.byte[arrayAddr + 4 * endIndex] = currentNumber
									; }
endif1
	CMP R1, R2 						; if(startIndex < endIndex) {
	BHS endif2
	
	LDR R4, [R0, R1, LSL #2]		; 	currentNumber	= Memory.byte[arrayAddr + 4 * startIndex]
	
while2								; 	while( startIndex != endIndex ) {
	CMP R1, R2						
	BEQ endwhile2
	 
	ADD R1, R1, #1					;		startIndex--;
	LDR R5, [R0, R1, LSL #2]        ;   	replaceNumber = Memory.byte[arrayAddr + 4 * startIndex]
	MOV	R6, R1                      ; 		copyStartIndex = startIndex
	SUB R6, R6, #1					;		copyStartIndex++;
	STR R5, [R0, R6, LSL #2]        ;   	Memory.byte[arrayAddr + 4 * copyStartIndex] = replaceNumber
	
	B while2
endwhile2							; 	}

	STR R4, [R0, R2, LSL #2]        ; 	Memory.byte[arrayAddr + 4 * endIndex] = currentNumber
									; }
endif2		
	
STOP	B	STOP

	END
