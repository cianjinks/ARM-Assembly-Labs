;
; CSU11021 Introduction to Computing I 2019/2020
; Anagrams
;

	AREA	RESET, CODE, READONLY
	ENTRY

	LDR	R0, =tststr1	; first string
	LDR	R1, =tststr2	; second string
	LDR R2, =tststr1	; first string copy

	LDR R3, =0			;currentLetter = 0
	LDR R4, =0			;loopLetter = 0
	LDR R5, =0			;word1Count = 0
	LDR R6, =0			;word2Count = 0
	
	LDRB R3, [R0] 		;currentLetter = Memory.byte['tststr1']

while1
	CMP R3, #0			;while(currentLetter != 0) {
	BEQ	endwhile1
	
	LDRB R4, [R2]		;	loopLetter = Memory.byte['tststr1Copy']

while2
	CMP R4, #0			;	while(loopLetter != 0) {
	BEQ endwhile2
	
	CMP R3, R4			;		if(currentLetter == loopLetter) {
	BNE	endif1
	ADD R5, R5, #1		;			word1Count++
endif1					;		}
	ADD	R2, R2, #1		;		tststr1Copy++
	LDRB R4, [R2]		;		loopLetter = Memory.byte['tststr1Copy']
	
	B 	while2
endwhile2				;	}
	
	LDRB R4, [R1]		;	loopLetter = Memory.byte['tststr2']
while3
	CMP R4, #0			;	while(loopLetter != 0) {
	BEQ endwhile3
			
	CMP R3, R4			;		if(currentLetter == loopLetter) {
	BNE	endif2
	ADD R6, R6, #1		;			word2Count++
endif2					;		}
	ADD	R1, R1, #1		;		tststr2++
	LDRB R4, [R1]		;		loopLetter = Memory.byte['tststr2']
	
	B while3
endwhile3				;	}

	CMP R5, R6			;	if(word1Count != word2Count) {
	BNE notAnagram		;		not an anagram
						;	}
	ADD R0, R0, #1		;	tststr1++
	LDRB R3, [R0] 		;	currentLetter = Memory.byte['tststr1']
	LDR	R1, =tststr2	; 	reset second string address
	LDR R2, =tststr1	; 	reset first string address copy
	LDR R5, =0			;	word1Count = 0
	LDR R6, =0			;	word2Count = 0
	
	B	while1
endwhile1				;}
	LDR R0, =1			;isAnagram = 1

notAnagram
	CMP R0, #1			;if(isAnagram != 1) {
	BEQ	STOP			
	LDR R0, =0			;	isAnagram = 0
						;}
	
	

STOP	B	STOP

tststr1	DCB	"tapas",0
tststr2	DCB	"pasta",0

;tststr1 DCB	"realist",0
;tststr2 DCB	"retails",0

;tststr1 DCB	"bowl",0
;tststr2 DCB	"blow",0

	END
