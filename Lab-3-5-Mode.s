;
; CSU11021 Introduction to Computing I 2019/2020
; Mode
;

	AREA	RESET, CODE, READONLY
	ENTRY

	LDR	R4, =tstN	; load address of tstN
	LDR	R1, [R4]	; load value of tstN

	LDR	R2, =tstvals	; load address of numbers
	
	LDR R3, =0		;scanNumber = 0
	LDR R7, =0      ;currentNumber = 0
	LDR R9, =0		;maxCount = 0
	LDR R0, =0		;MODE = 0
	LDR R5, [R4]	;copy of value N
	
while
	CMP	R1, #0x00	;while(n > 0) {
	BLS endwhile
	LDRB R3, [R2]	;	scanNumber = Memory.byte[numbers_address]
	LDR R6, =tstvals;   R6 = copy of numbers address
	LDR R8, =0x00	;	count = 0
	
while2
	CMP R5, #0x00   ;	while(n > 0) {
	BLS endwhile2	;		
	LDRB R7, [R6]	;		currentNumber = Memory.byte[copy_numbers_address]
	CMP R3, R7		;		if(scanNumber = currentNumber) {
	BNE	endif1		;			
	ADD R8, R8, #1	;			count++
endif1				;		}
	ADD R6, R6, #4	;		copy_numbers_address++
	SUB R5, R5, #1	;		n--;
	B	while2
endwhile2			;   }

	CMP R8, R9 		;	if(count > maxCount) {
	BLS	endif2		;
	MOV R9, R8		;		maxCount = count
	MOV R0, R3		;		MODE = scanNumber
					;	}
endif2	
	LDR R5, [R4]	;	n_copy = 8
	ADD R2, R2, #4	;	numbers_address++
	SUB R1, R1, #1	;	n--
	B while			;}
endwhile


STOP	B	STOP

;tstN	DCD	8			; N (number of numbers)
;tstvals	DCD	5, 3, 7, 5, 3, 5, 1, 9	; numbers
tstN    DCD 13
tstvals DCD 8, 8, 8, 7, 5, 2, 1, 9, 4, 3, 1, 8, 1
	END
