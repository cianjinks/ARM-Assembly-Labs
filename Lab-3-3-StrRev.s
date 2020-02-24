;
; CSU11021 Introduction to Computing I 2019/2020
; String Reverse
;

	AREA	RESET, CODE, READONLY
	ENTRY

	LDR	R0, =tststr	; address of existing string
	LDR	R1, =0x40000000	; address for new string
	LDR R2, =0 ;count

count
	LDRB R3, [R0] ;char = Memory.byte[address]
	CMP R3, #0 ;   while(char != 0)
	BEQ endcount ; 
	ADD R2, #1   ; count++
	ADD R0, #1   ; address++
	B count
endcount
	
	SUB R0, #1 ;address-- -> -1 for the character before the 0

while
	LDRB R3, [R0] ;char = Memory.byte[address]
	STRB R3, [R1] ;Memory.byte[address] = char
	CMP R2, #0	;  while(count != 0)
	BEQ endwhile
	ADD R1, #1	;  new_address++
	SUB R0, #1	;  address--
	SUB R2, #1  ;  count--
	B while
endwhile	


	
	


STOP	B	STOP

tststr	DCB	"This is a test!",0

	END
