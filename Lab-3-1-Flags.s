;
; CSU11021 Introduction to Computing I 2019/2020
; Condition Code Flags
;

	AREA	RESET, CODE, READONLY
	ENTRY

	LDR     R0, =0xC0001000
	LDR 	R1, =0x51004000
	ADDS 	R2, R0, R1 		; result? flags?
	LDR 	R3, =0x92004000
	SUBS 	R4, R3, R3 		; result? flags?
	LDR 	R5, =0x74000100
	LDR 	R6, =0x40004000
	ADDS 	R7, R5, R6 		; result? flags?
	LDR	R1, =0x6E0074F2
	LDR	R2, =0x211D6000
	ADDS	R0, R1, R2		; result? flags?
	LDR	R1, =0xBE2FDD2E
	LDR	R2, =0x41D022D2
	ADDS	R0, R1, R2		; result? flags?

STOP	B	STOP

	END
