;
; CS1022 Introduction to Computing II 2018/2019
; Chess Clock
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

	; Enter irq mode and set initial SP
	MSR     CPSR_c, #Mode_IRQ:OR:I_Bit:OR:F_Bit
	MOV     SP, R0
	SUB     R0, R0, #Irq_Stack_Size

	; Enter user mode and set initial SP
	MSR     CPSR_c, #Mode_USR
	MOV	SP, R0

	;
	; your initialisation goes here
	;

	;The chess clock will start off on player 1's turn and each player gets 5 minutes (300,000,000 on 1Mhz clock)
	LDR R4, =currentTurn
	LDR R5, =0x01
	STR R5, [R4]
	
	LDR R4, =P1TimeRemaining
	LDR R5, =gameLength
	LDR R6, [R5]
	STR R6, [R4]
	
	LDR R4, =P2TimeRemaining
	LDR R5, =gameLength
	LDR R6, [R5]
	STR R6, [R4]
	
	;
	; Configure GPIO Pin 2.10
	;

	; Make Pin 2.10 GPIO (RMW)
	LDR	R4, =PINSEL4
	LDR	R5, [R4]			
	BIC	R5, #(0x03 << 20)	; clear bits 21:20
	ORR	R5, #(0x01 << 20)	; set bits 21:20 to 0:1
	STR	R5, [R4]			

	; Set edge-sensitive mode for EINT0 (RMW)
	LDR	R4, =EXTMODE
	LDR	R5, [R4]		
	ORR	R5, #1			
	STRB	R5, [R4]		

	; Set rising-edge mode for EINT0 (RMW)
	LDR	R4, =EXTPOLAR
	LDR	R5, [R4]		
	BIC	R5, #1			
	STRB	R5, [R4]		

	; Reset EINT0
	LDR	R4, =EXTINT
	MOV	R5, #1
	STRB	R5, [R4]
	
	;
	; Configure TIMER0
	;
	
	; Stop and reset TIMER0 
	; Bit 0 T0TCR - Stop TIMER
	; Bit 1 T0TCR - Reset TIMER
	LDR	R4, =T0TCR
	LDR	R5, =0x2
	STRB	R5, [R4]
	
	; Force reset the timer to 0 (the above instructions are not resetting the timer)
	LDR	R4, =T0TC
	LDR	R5, =0x0
	STR	R5, [R4]

	; Clear previous TIMER0 interrupts
	; Write 0xFF to TIMER0 Interrupt Register
	LDR	R4, =T0IR
	LDR	R5, =0xFF
	STRB	R5, [R4]

	; Set match register duration to game length when the game starts
	; 300,000,000 is 5 mins assuming a 1Mhz clock
	LDR	R4, =T0MR0
	LDR	R5, =gameLength
	LDR R6, [R5]
	STR	R6, [R4]

	; Enable raising of IRQ on match
	; Bit 0 T0MCR to 1 - Turn on interrupts
	; Bit 1 T0MCR to 1 - Reset counter to 0 after every match
	; Bit 2 T0MCR to 0 - Leave the counter enabled after match
	LDR	R4, =T0MCR
	LDR	R5, =0x03
	STRH	R5, [R4]
	
	;
	; Configure VIC for EINT0 interrupts
	;
	
	; Create a mask for bit 14 in R5
	LDR	R4, =VICVectEINT0		
	LDR	R5, =(1 << VICVectEINT0) 	

	; Clear bit 14 of VICIntSelect register to cause EINT0 to raise IRQ
	LDR	R6, =VICIntSelect	
	LDR	R7, [R6]		
	BIC	R7, R7, R5		
	STR	R7, [R6]		

	; Set Priority for EINT0 to 15 
	LDR	R6, =VICVectPri0	
	MOV	R7, #15
	STR	R7, [R6, R4, LSL #2]

	; Set Handler routine address for VIC channel EINT0 to address of button handler routine
	LDR	R6, =VICVectAddr0	
	LDR	R7, =Button_Handler	
	STR	R7, [R6, R4, LSL #2]	

	; Enable VIC EINT0 by writing a 1 to bit 14 of VICIntEnable
	LDR	R6, =VICIntEnable	
	STR	R5, [R6]		
	
	;
	; Configure VIC for TIMER0 interrupts
	;
	
	; Create mask for bit 4 in R5
	LDR R4, =VICVectT0
	LDR R5, =(1 << VICVectT0)
	
	; Clear bit 4 of VICIntSelect register to cause TIMER0 to raise IRQ
	LDR	R6, =VICIntSelect	
	LDR	R7, [R6]		
	BIC	R7, R7, R5		
	STR	R7, [R6]	
	
	; Set Priority for TIMER0 to 14
	LDR	R6, =VICVectPri0	
	MOV	R7, #14
	STR	R7, [R6, R4, LSL #2]
	
	; Set Handler routine address for VIC channel TIMER0 to address of game end handler routine
	LDR	R6, =VICVectAddr0	
	LDR	R7, =GameOver_Handler	
	STR	R7, [R6, R4, LSL #2]	
	
	; Enable VIC TIMER0 by writing a 1 to bit 4 of VICIntEnable
	LDR	R6, =VICIntEnable	
	STR	R5, [R6]	
	
	;
	; Start TIMER0
	;
	; Bit 0 T0TCR to 1 - Enable timer
	LDR	R4, =T0TCR
	LDR	R5, =0x01
	STRB	R5, [R4]
	
	
; Wait for interrupts
stop	B	stop


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


;
; write your interrupt handlers here
;
Button_Handler
	STMFD	sp!, {R4-R9, lr}
	
	; Reset EINT0 interrupt by writing 1 to EXTINT register
	LDR	R4, =EXTINT
	MOV	R5, #1
	STRB	R5, [R4]
	
	LDR R4, =currentTurn
	LDR R9, [R4]
	
	CMP R9, #1				; if(currentTurn == 1) {
	BNE endif1
	
	; mem@P1TimeRemainingAddress -= mem@T0TC
	LDR R4, =T0TC
	LDR R5, [R4]
	LDR R4, =P1TimeRemaining
	LDR R7, [R4]
	SUB R7, R7, R5
	STR R7, [R4]
	
	; Stop and reset TIMER0 
	; Bit 0 T0TCR - Stop TIMER
	; Bit 1 T0TCR - Reset TIMER
	LDR	R4, =T0TCR
	LDR	R5, =0x2
	STRB	R5, [R4]
	
	; Force reset the timer to 0 (the above instructions are not resetting the timer)
	LDR	R4, =T0TC
	LDR	R5, =0x0
	STR	R5, [R4]
	
	; Set match register duration to player 2's remaining time
	LDR	R4, =T0MR0
	LDR	R5, =P2TimeRemaining
	LDR R6, [R5]
	STR	R6, [R4]
	
	; Enable raising of IRQ on match
	; Bit 0 T0MCR to 1 - Turn on interrupts
	; Bit 1 T0MCR to 1 - Reset counter to 0 after every match
	; Bit 2 T0MCR to 0 - Leave the counter enabled after match
	LDR	R4, =T0MCR
	LDR	R5, =0x03
	STRH	R5, [R4]
	
	; Start TIMER0
	; Bit 0 T0TCR to 1 - Enable timer
	LDR	R4, =T0TCR
	LDR	R5, =0x01
	STRB	R5, [R4]
	
	; Set turn to player 2's
	LDR R4, =currentTurn
	LDR R5, =2
	STR R5, [R4]
	
	B	endif2
endif1						; }
	CMP R9, #2				; else if(currentTurn == 2) {
	BNE	endif2
	
	; mem@P2TimeRemainingAddress -= mem@T0TC
	LDR R4, =T0TC
	LDR R5, [R4]
	LDR R4, =P2TimeRemaining
	LDR R7, [R4]
	SUB R7, R7, R5
	STR R7, [R4]
	
	; Stop and reset TIMER0 
	; Bit 0 T0TCR - Stop TIMER
	; Bit 1 T0TCR - Reset TIMER
	LDR	R4, =T0TCR
	LDR	R5, =0x2
	STRB	R5, [R4]
	
	; Force reset the timer to 0 (the above instructions are not resetting the timer)
	LDR	R4, =T0TC
	LDR	R5, =0x0
	STR	R5, [R4]
	
	; Set match register duration to player 1's remaining time
	LDR	R4, =T0MR0
	LDR	R5, =P1TimeRemaining
	LDR R6, [R5]
	STR	R6, [R4]
	
	; Enable raising of IRQ on match
	; Bit 0 T0MCR to 1 - Turn on interrupts
	; Bit 1 T0MCR to 1 - Reset counter to 0 after every match
	; Bit 2 T0MCR to 0 - Leave the counter enabled after match
	LDR	R4, =T0MCR
	LDR	R5, =0x03
	STRH	R5, [R4]
	
	; Start TIMER0
	; Bit 0 T0TCR to 1 - Enable timer
	LDR	R4, =T0TCR
	LDR	R5, =0x01
	STRB	R5, [R4]
	
	; Set turn to player 1's
	LDR R4, =currentTurn
	LDR R5, =1
	STR R5, [R4]
	
endif2						; }

	; Clear interrupt source in VIC
	LDR	R4, =VICVectAddr	
	MOV	R5, #0			
	STR	R5, [R4]		
	
	LDMFD 	sp!, {R4-R9, pc}

GameOver_Handler
	STMFD	sp!, {lr}
	
	; Reset TIMER0 interrupt by writing 0xFF to T0IR
	LDR	R4, =T0IR
	MOV	R5, #0xFF
	STRB	R5, [R4]
	
gameOver	B	gameOver

	; Clear interrupt source in VIC
	LDR	R4, =VICVectAddr	
	MOV	R5, #0			
	STR	R5, [R4]
	
	LDMFD 	sp!, {pc}

gameLength		DCD		30000000

	AREA	TestData, DATA, READWRITE

currentTurn		SPACE	4
P1TimeRemaining SPACE 	4
P2TimeRemaining SPACE	4

	END
