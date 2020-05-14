;
; CS1022 Introduction to Computing II 2018/2019
; Lab 4 - timer-game-int
;

T0IR		EQU	0xE0004000
T0TCR		EQU	0xE0004004
T0TC		EQU	0xE0004008
T0MR0		EQU	0xE0004018
T0MCR		EQU	0xE0004014

PINSEL4		EQU	0xE002C010

FIO2DIR1	EQU	0x3FFFC041
FIO2PIN1	EQU	0x3FFFC055

EXTINT		EQU	0xE01FC140
EXTMODE		EQU	0xE01FC148
EXTPOLAR	EQU	0xE01FC14C

VICIntSelect	EQU	0xFFFFF00C
VICIntEnable	EQU	0xFFFFF010
VICVectAddr0	EQU	0xFFFFF100
VICVectPri0	EQU	0xFFFFF200
VICVectAddr	EQU	0xFFFFFF00

VICVectT0	EQU	4
VICVectEINT0	EQU	14

Irq_Stack_Size	EQU	0x80

Mode_USR        EQU     0x10
Mode_IRQ        EQU     0x12
I_Bit           EQU     0x80            ; when I bit is set, IRQ is disabled
F_Bit           EQU     0x40            ; when F bit is set, FIQ is disabled



	AREA	RESET, CODE, READONLY
	ENTRY

	; Exception Vectors

	B	Reset_Handler	; 0x00000000
	B	Undef_Handler	; 0x00000004
	B	SWI_Handler	; 0x00000008
	B	PAbt_Handler	; 0x0000000C
	B	DAbt_Handler	; 0x00000010
	NOP			; 0x00000014
	B	IRQ_Handler	; 0x00000018
	B	FIQ_Handler	; 0x0000001C

;
; Reset Exception Handler
;
Reset_Handler

	;
	; Initialize Stack Pointers (SP) for each mode we are using
	;

	; Stack Top
	LDR	R0, =0x40010000

	; Enter undef mode and set initial SP
	MSR     CPSR_c, #Mode_IRQ:OR:I_Bit:OR:F_Bit
	MOV     SP, R0
	SUB     R0, R0, #Irq_Stack_Size

	; Enter user mode and set initial SP
	MSR     CPSR_c, #Mode_USR
	MOV	SP, R0

	; Reset buttonCount to 0
	LDR R4, =buttonCount
	LDR R5, =0
	STR R5, [R4]
	
	; Configure beginning bounds
	LDR R4, =lowerBound
	LDR R5, =5000000
	STR R5, [R4]
	LDR R4, =upperBound
	LDR R5, =8000000
	STR R5, [R4]
	
	;
	; Configure P2.10 for EINT0
	;

	; Enable P2.10 for GPIO
	LDR	R4, =PINSEL4
	LDR	R5, [R4]		; read current value
	BIC	R5, #(0x03 << 20)	; clear bits 21:20
	ORR	R5, #(0x01 << 20)	; set bits 21:20 to 01
	STR	R5, [R4]		; write new value

	; Set edge-sensitive mode for EINT0
	LDR	R4, =EXTMODE
	LDR	R5, [R4]		; read
	ORR	R5, #1			; modify
	STRB	R5, [R4]		; write

	; Set rising-edge mode for EINT0
	LDR	R4, =EXTPOLAR
	LDR	R5, [R4]		; read
	BIC	R5, #1			; modify
	STRB	R5, [R4]		; write

	; Reset EINT0
	LDR	R4, =EXTINT
	MOV	R5, #1
	STRB	R5, [R4]
	
	;
	; Configure VIC for EINT0 interrupts
	;

	; Useful VIC vector numbers and masks for following code
	LDR	R4, =VICVectEINT0		; vector 4
	LDR	R5, =(1 << VICVectEINT0) 	; bit mask for vector 14

	; VICIntSelect - Clear bit 4 of VICIntSelect register to cause
	; channel 14 (EINT0) to raise IRQs (not FIQs)
	LDR	R6, =VICIntSelect	; addr = VICVectSelect;
	LDR	R7, [R6]		; tmp = Memory.Word(addr);
	BIC	R7, R7, R5		; Clear bit for Vector 14
	STR	R7, [R6]		; Memory.Word(addr) = tmp;

	; Set Priority for VIC channel 14 (EINT0) to lowest (15) by setting
	; VICVectPri4 to 15. Note: VICVectPri4 is the element at index 14 of an
	; array of 4-byte values that starts at VICVectPri0.
	; i.e. VICVectPri4=VICVectPri0+(4*4)
	LDR	R6, =VICVectPri0	; addr = VICVectPri0;
	MOV	R7, #15			; pri = 15;
	STR	R7, [R6, R4, LSL #2]	; Memory.Word(addr + vector * 4) = pri;

	; Set Handler routine address for VIC channel 4 (TIMER0) to address of
	; our handler routine (TimerHandler). Note: VICVectAddr4 is the element
	; at index 4 of an array of 4-byte values that starts at VICVectAddr0.
	; i.e. VICVectAddr4=VICVectAddr0+(4*4)
	LDR	R6, =VICVectAddr0	; addr = VICVectAddr0;
	LDR	R7, =Button_Handler	; handler = address of TimerHandler;
	STR	R7, [R6, R4, LSL #2]	; Memory.Word(addr + vector * 4) = handler

	; Enable VIC channel 14 (EINT0) by writing a 1 to bit 4 of VICIntEnable
	LDR	R6, =VICIntEnable	; addr = VICIntEnable;
	STR	R5, [R6]		; enable interrupts for vector 14

STOP	B	STOP


;
; TOP LEVEL EXCEPTION HANDLERS
;

;
; Software Interrupt Exception Handler
;
Undef_Handler
	B	Undef_Handler

;
; Software Interrupt Exception Handler
;
SWI_Handler
	B	SWI_Handler

;
; Prefetch Abort Exception Handler
;
PAbt_Handler
	B	PAbt_Handler

;
; Data Abort Exception Handler
;
DAbt_Handler
	B	DAbt_Handler

;
; Interrupt ReQuest (IRQ) Exception Handler (top level - all devices)
;
IRQ_Handler
	SUB	lr, lr, #4	; for IRQs, LR is always 4 more than the
				; real return address
	STMFD	sp!, {r0-r3,lr}	; save r0-r3 and lr

	LDR	r0, =VICVectAddr; address of VIC Vector Address memory-
				; mapped register

	MOV	lr, pc		; can’t use BL here because we are branching
	LDR	pc, [r0]	; to a different subroutine dependant on device
				; raising the IRQ - this is a manual BL !!

	LDMFD	sp!, {r0-r3, pc}^ ; restore r0-r3, lr and CPSR

;
; Fast Interrupt reQuest Exception Handler
;
FIQ_Handler
	B	FIQ_Handler
	
Button_Handler
	
	STMFD	sp!, {R4-R5, LR}
	
	; Reset EINT0 interrupt by writing 1 to EXTINT register
	LDR	R4, =EXTINT
	MOV	R5, #1
	STRB	R5, [R4]
	
	; Increment buttonCount
	LDR R4, =buttonCount
	LDR R5, [R4]
	ADD R5, R5, #1
	STR	R5, [R4]
	
	CMP R5, #1					; if(buttonCount == 1) { ; STOP RESET AND START THE TIMER
	BNE	endif3
	
	; Stop and reset TIMER0 using Timer Control Register
	; Set bit 0 of TCR to 0 to stop TIMER
	; Set bit 1 of TCR to 1 to reset TIMER
	LDR	R5, =T0TCR
	LDR	R6, =0x2
	STRB	R6, [R5]
	
	; Similarly to the polling program this dosent seem to actually reset the timer so:
	; Force reset the timer to 0
	LDR	R4, =T0TC
	LDR	R5, =0x0
	STR	R5, [R4]
	
	; Start TIMER0 using the Timer Control Register
	; Set bit 0 of TCR (0xE0004004) to enable the timer
	LDR	R4, =T0TCR
	LDR	R5, =0x01
	STRB	R5, [R4]
	
endif3							; }
	
	LDR R4, =buttonCount
	LDR R5, [R4]				; load buttonCount
	
	CMP R5, #2					; if(buttonCount == 2) {
	BNE	endif1
	LDR R5, =0					;	buttonCount = 0;
	STR R5, [R4]
	
	LDR R4, =T0TC
	LDR R5, [R4]				; 	load current time
	
	LDR R4, =lowerBound
	LDR R6, [R4]				; 	load lowerBound
	
	LDR R4, =upperBound
	LDR R7, [R4]				; 	load upperBound
		
	CMP R5, R6					; 	if(currentTime < lowerBound || currentTime > upperBound) {
	BLO insideif
	CMP R5, R7				
	BLS	endif2
insideif

	; LOSES GAME
	; Enable P2.10 for GPIO
	LDR	R4, =PINSEL4			; 		load address of PINSEL4
	LDR	R5, [R4]				; 		read current PINSEL4 value
	BIC	R5, #(0x3 << 20)		; 		modify bits 20 and 21 to 00
	STR	R5, [R4]				; 		write new PINSEL4 value

	; Set P2.10 for output
	LDR	R4, =FIO2DIR1			; 		load address of FIO2DIR1
	LDRB	R5, [R4]			; 		read current FIO2DIR1 value
	ORR	R5, #(0x1 << 2)			; 		modify bit 2 to 1 for output, leaving other bits unmodified
	STRB	R5, [R4]			; 		write new FIO2DIR1
	
	LDR	R4, =0x04				;   	setup bit mask for P2.10 bit in FIO2PIN1
	LDR	R5, =FIO2PIN1		;
	LDRB	R6, [R5]			;   	read FIO2PIN1
	
	ORR	R6, R6, R4				;     	set bit 2 (turn LED on)
	STRB	R6, [R5]			; 		write new FIO2PIN1 value
	
	; Set P2.10 for input (This avoids it crashing when you get game over but click the button again)
	;LDR	R4, =FIO2DIR1			; 		load address of FIO2DIR1
	;LDRB	R5, [R4]			; 		read current FIO2DIR1 value
	;BIC	R5, #(0x1 << 2)			; 		modify bit 2 to 0 for input
	;STRB	R5, [R4]			; 		write new FIO2DIR1
	; I thought maybe this turns off the LED so its commented out
	
	; Stop and reset TIMER0 using Timer Control Register
	; Set bit 0 of TCR to 0 to stop TIMER
	; Set bit 1 of TCR to 1 to reset TIMER
	LDR	R5, =T0TCR
	LDR	R6, =0x2
	STRB	R6, [R5]
	
	; Similarly to the polling program this dosent seem to actually reset the timer so:
	; Force reset the timer to 0
	LDR	R4, =T0TC
	LDR	R5, =0x0
	STR	R5, [R4]
	
	B	GAMEOVER
	


endif2							; 	}

	LDR R8, =3000000
	ADD R6, R6, R8
	LDR R4, =lowerBound
	STR R6, [R4]				; 	Add 3 seconds to lower bound
	
	ADD R7, R7, R8
	LDR R4, =upperBound
	STR R7, [R4]				; 	Add 3 seconds to upper bound
	
	
	
	; Stop and reset TIMER0 using Timer Control Register
	; Set bit 0 of TCR to 0 to stop TIMER
	; Set bit 1 of TCR to 1 to reset TIMER
	LDR	R5, =T0TCR
	LDR	R6, =0x2
	STRB	R6, [R5]
	
	; Similarly to the polling program this dosent seem to actually reset the timer so:
	; Force reset the timer to 0
	LDR	R4, =T0TC
	LDR	R5, =0x0
	STR	R5, [R4]
	
endif1							; }
	

	; Clear source of interrupt
	LDR	R4, =VICVectAddr		; addr = VICVectAddr
	MOV	R5, #0					; tmp = 0;
	STR	R5, [R4]				; Memory.Word(addr) = tmp;
	
	LDMFD	sp!, {R4-R5, PC}
	
GAMEOVER B GAMEOVER				; Infinite loop with LED on if you lost the game
	
	AREA	TestData, DATA, READWRITE

buttonCount	SPACE	4
lowerBound  SPACE   4
upperBound	SPACE	4


	END
