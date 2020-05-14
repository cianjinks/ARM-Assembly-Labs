;
; CS1022 Introduction to Computing II 2019/2020
; Polling Example
;

; Pin Control Block registers
PINSEL4		EQU	0xE002C010

; GPIO registers
; Button
FIO2DIR1	EQU	0x3FFFC041
FIO2PIN1	EQU	0x3FFFC055
	
; Timer
T0TCR		EQU	0xE0004004
T0MR0		EQU	0xE0004018
T0MCR		EQU	0xE0004014
T0TC		EQU	0xE0004008

	AREA	RESET, CODE, READONLY
	ENTRY

	; Enable P2.10 for GPIO
	LDR	R4, =PINSEL4		; load address of PINSEL4
	LDR	R5, [R4]			; read current PINSEL4 value
	BIC	R5, #(0x3 << 20)	; modify bits 20 and 21 to 00
	STR	R5, [R4]			; write new PINSEL4 value

	; Set P2.10 for input
	LDR	R4, =FIO2DIR1		; load address of FIO2DIR1

	NOP						; on "real" hardware, we cannot place
							; an instruction at address 0x00000014
	LDRB	R5, [R4]		; read current FIO2DIR1 value
	BIC	R5, #(0x1 << 2)		; modify bit 2 to 0 for input, leaving other bits unmodified
	STRB	R5, [R4]		; write new FIO2DIR1
	
	; Force reset the timer to 0
	LDR	R5, =T0TC
	LDR	R6, =0x0
	STR	R6, [R5]
	
	; Start TIMER0 using the Timer Control Register
	; Set bit 0 of TCR (0xE0004004) to enable the timer
	LDR	R4, =T0TCR
	LDR	R5, =0x01
	STRB	R5, [R4]

	MOV	R7, #0				; presses = 0
	MOV R8, #0				; firstPress = 0
	MOV R9, #0				; secondPress = 0
	LDR R11, =5000000		; elapsedTimeStart
	LDR R12, =8000000		; elapsedTimeEnd

whRepeat					; while (forever) {
	LDR	R4, =FIO2PIN1		; load address of FIO2PIN1
	LDRB	R6, [R4]		;   lastState = FIO2PIN1 & 0x4
	AND	R6, R6, #0x4		;

	; keep testing pin state until it changes

whPoll						;   do {
	LDRB	R5, [R4]		;     currentState = FIO2PIN1 & 0x4
	AND	R5, R5, #0x4		;
	CMP	R5, R6				;
	BEQ	whPoll				;   } while (currentState == lastState);

	; BUTTON IS PRESSED
	
	ADD R7, R7, #1			;	presses++
	
	CMP R7, #1				;	if (presses == 1) {
	BNE	endif1
	LDR R5, =T0TC			;		load the timer address
	LDR	R8, [R5]			;		firstPress = time
endif1						; 	}

	CMP R7, #3				;	if (presses == 3) {
	BNE endif2
	LDR R5, =T0TC			;		load the timer address
	LDR	R9, [R5]			;		secondPress = time
	
	SUB R9, R9, R8			;		elapsedTime = secondPress - firstPress (difference between presses)
	
							; 		CHECK IF USER LOST
	MOV R10, R11
	CMP R9, R10				;       if (elapsedTime < elapsedTimeStart || elapsedTime > elapsedTimeEnd) {
	BLO insideif
	MOV R10, R12
	CMP R9, R10
	BLS	endif4
insideif
	
	; Configure P2.10 for output
	LDR	R4, =FIO2DIR1		; 			load address of FIO2DIR1
	LDRB	R10, [R4]		; 			read current FIO2DIR1 value
	ORR	R10, #(0x1 << 2)	; 			modify bit 2 to 1 for output, leaving other bits unmodified
	STRB	R10, [R4]		; 			write new FIO2DIR1
	
	BL	ledon				;			TURN ON LED
	
	LDR	R4, =FIO2DIR1		; 			load address of FIO2DIR1
	LDRB	R10, [R4]		; 			read current FIO2DIR1 value
	BIC	R10, #(0x1 << 2)	; 			modify bit 2 to 0 for input, leaving other bits unmodified
	STRB	R10, [R4]		; 			write new FIO2DIR1
	
							;			GAME LOST
	B	stop
	
endif4						;		}

; Force reset timer to 0
	LDR	R5, =T0TC
	LDR	R6, =0x0
	STR	R6, [R5]
	
	MOV	R7, #0				; 		presses = 0
	MOV R8, #0				; 		firstPress = 0
	MOV R9, #0				; 		secondPress = 0
	BL	addTime				;		Add 3 seconds to timer window
	
	; Force reset the timer to 0
	LDR	R5, =T0TC
	LDR	R6, =0x0
	STR	R6, [R5]
	
endif2						;  
	
	B	whRepeat			; }

stop 
	B	stop

; ledon
; Subroutine to turn on the LED ( Make sure P2.10 is set to output )
; Paramters: None
ledon
	PUSH {R3-R5, LR}
	
	; Turn on LED
	LDR	R3, =0x04			;   		setup bit mask for P2.10 bit in FIO2PIN1
	LDR	R4, =FIO2PIN1		;
	LDRB	R5, [R4]		;   		read FIO2PIN1
	ORR	R5, R3, R5		;       		set bit 2 (turn LED on)
	STRB R5, [R4]			;			store new value
	
	
	POP {R3-R5, PC}
	
; addTime
; Add 3s to time window
; Parameters: None
addTime
	PUSH {R10, LR}
	
	LDR R10, =3000000
	ADD R11, R11, R10
	ADD R12, R12, R10
	
	POP {R10, PC}
	
	END
