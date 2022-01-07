$MOD51	; This includes 8051 definitions for the Metalink assembler

LED_R	BIT		P1.0	; Set red LED as bit 0 of port 1
LED_B	BIT		P1.7	; Set blue LED as bit 7 of port 1
LED_G	BIT		P3.5	; Set green LED as bit 5 of port 3

ORG		0H				; Program counter starts at address 0H

CLR		LED_R			; Make sure all LEDs are initially turned off
CLR		LED_B
CLR 	LED_G

MAIN:					; Define MAIN process
	SETB	LED_R		; Set LED high (turn on)
	ACALL	DELAY		; Call DELAY subroutine
	CLR		LED_R		; Set LED low (turn off)

	SETB	LED_B
	ACALL	DELAY
	CLR		LED_B

	SETB 	LED_G
	ACALL	DELAY
	CLR		LED_G

	SJMP	MAIN		; Repeat MAIN process

DELAY:						; Define DELAY subroutine
	MOV		R4,		#6		; Load R4 with #6

DL1:						; Define DL1 process
	MOV		R3,		#255	; Load R3 with #255
	DJNZ	R3,		$		; Decrement R3 until 0
	
	DJNZ	R4, 	DL1		; Decrement R4 until 0, if not 0 repeat DL1

RET							; Return to location of call in program

END							; End program