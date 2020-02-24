;
; CSU11021 Introduction to Computing I 2019/2020
; Proper Case
;

	AREA	RESET, CODE, READONLY
	ENTRY

	LDR	R0, =tststr	; address of existing string
	LDR	R1, =0x40000000	; address for new string
	LDR R2, =0 ; currentChar = 0
	LDR R3, =0 ; lastChar = 0

while
	MOV R3, R2		; lastChar = currentChar
	LDRB R2, [R0]	; while(var currentChar = Memory.byte[address] != 0) {
	CMP R2, #0		;
	BEQ endwhile	; 
	
	CMP R3, #' '	; 	if(lastChar == " " || lastChar == 0x00) {
	BEQ ifor		;	
	CMP R3, #0x00	;
	BNE ifend		;
ifor				
	CMP R2, #'a'	;		if(currentChar >= 'a' && currentChar <= 'z') {
	BLO ifend		;
	CMP R2, #'z'	;
	BHI	ifend		;
	SUB R2, R2, #0x20 ; 			currentChar = currentChar - 0x20
					;		}
ifend				;	}

	CMP R3, #'A'	; 	if(lastChar >= 'A' && lastChar <= 'z') {
	BLO ifend2		;	
	CMP R3, #'z'	;
	BHI ifend2		;			
	CMP R2, #'A'	;		if(currentChar >= 'A' && currentChar <= 'Z') {
	BLO ifend2		;
	CMP R2, #'Z'	;
	BHI	ifend2		;
	ADD R2, R2, #0x20 ; 			currentChar = currentChar + 0x20
					;		}
ifend2				;	}

	STRB R2, [R1]	;		Memory.byte[new_address] = currentChar 
	ADD R0, R0, #1	;		address++	
	ADD R1, R1, #1	;		new_address++
	B while			; }
	
endwhile	

STOP	B	STOP

tststr	DCB	"tHe foX",0
;tststr	DCB	"the big battle of the battle",0
	END
