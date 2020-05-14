;
; CS1022 Introduction to Computing II 2019/2020
; eTest Group 4 Q1
;

	AREA	globals, DATA, READWRITE

arrA	SPACE	1024
arrB	SPACE	1024


	AREA	RESET, CODE, READONLY
	ENTRY

	; initialise the system stack pointer
	LDR	SP, =0x40010000

	;
	; initialise arrays by copying from ROM to RAM
	;

	LDR	R0, =arrA	; destination in RAM
	LDR	R1, =initA	; source in ROM
	LDR	R4, =sizeA
	LDR	R2, [R4]	; size of arrA
	BL	copy_arr

	LDR	R0, =arrB	; destination in RAM
	LDR	R1, =initB	; source in ROM
	LDR	R4, =sizeB
	LDR	R2, [R4]	; size of arrB
	BL	copy_arr

	;
	; Your program to test your subroutine goes here
	;
	POAWDKALDAW
	; Setup parameters for merge
	LDR R0, =arrA
	LDR R4, =sizeA
	LDR R1, [R4]
	LDR R2, =arrB
	LDR R5, =sizeB
	LDR R3, [R5]
	BL	merge

STOP	B	STOP

;
; Initial data
;
sizeA	DCD	10				; test array size
initA	DCD	2, 2, 3, 4, 4, 5, 6, 7, 9, 9	; test array elements

sizeB	DCD	8				; test array size
initB	DCD	1, 4, 5, 5, 6, 8, 8, 9		; test array elements



;
; Your subroutine goes here
;

; merge subroutine
; Merges the elements from sorted arrB into sorta arrA and maintains arrA in sorted order
; Parameters:
;	R0 - start address of arrA
;	R1 - size of arrA
;	R2 - start address of arrB
;	R3 - size of arrB
merge
	PUSH {R4-R7, LR}
	
	LDR R4, =0				; i = 0
	LDR R5, =0				; j = 0

while1
	CMP	R4, R1				; while(i < sizeA && j < sizeB) {
	BHS	endwhile1
	CMP R5, R3				
	BHS endwhile1
	
	LDR R6, [R0, R4, LSL #2];	R6 = arrA[i]
	LDR R7, [R2, R5, LSL #2];	R7 = arrB[j]
	CMP R6, R7				;	if(arrA[i] >= arrB[i]) {
	BLO	endif1
	
	; Setup parameters for insert
	PUSH {R2}
	MOV	R2, R1				;		R2 = sizeA
	PUSH {R1}
	PUSH {R3}
	MOV R1, R4				;		R1 = i
	MOV R3, R7				;		R3 = arrB[j]
	BL	insert				;		insert(arrA, i, sizeA, arrB[j})
	POP	{R3}
	POP	{R1}
	POP	{R2}
		
	ADD	R5, R5, #1			;		j++
	ADD	R1, R1, #1			;		sizeA++
endif1						;	}
	
	
	ADD	R4, R4, #1			;	i++
	B	while1	
endwhile1					; }
	
	POP	{R4-R7, PC}


; insert subroutine
; Inserts an element into an array of word size values
; Parameters:
;   R0 - start address of array
;   R1 - index of element to insert
;   R2 - number of elements in the array
;   R3 - value of element to be inserted
; Return Value:
;   none
insert
	PUSH	{R4-R6}

	MOV	R4, R1
	MOV	R5, R3
whInsert
	CMP	R4, R2
	BHS	eWhInsert
	LDR	R6, [R0, R4, LSL #2]
	STR	R5, [R0, R4, LSL #2]
	MOV	R5, R6
	ADD	R4, R4, #1
	B	whInsert
eWhInsert
	STR	R5, [R0, R4, LSL #2]
	POP	{R4-R6}
	BX	LR



; copy_arr subroutine
; Copies an array of words in memory
; Parameters:
;   R0 - destination address
;   R1 - source address
;   R2 - number of words to copy
; Return Value:
;   none
copy_arr
	PUSH	{R4-R5}
	LDR	R4, =0
wh_copy_arr
	CMP	R4, R2
	BHS	ewh_copy_arr
	LDR	R5, [R1, R4, LSL #2]
	STR	R5, [R0, R4, LSL #2]
	ADD	R4, R4, #1
	B	wh_copy_arr
ewh_copy_arr
	POP	{R4-R5}
	BX	LR

	END
