$MOD51						; This includes 8051 definitions for the Metalink assembler

RS			EQU 	P0.0	; Register select: selects command register when low, data register when high
RW			EQU		P0.1	; Read/write: low to write to the register, high to read from the register
EN			EQU 	P0.2	; Enable: sends data to data pins when a high to low pulse is given
D7			EQU		P2.7	; D7: busy flag of LCD, when high means LCD busy and no info should be issued
DATA_PORT	EQU 	P2		; Define input port


ORG 	0000H
MAIN: 	
		; Write commands to LCD
		MOV		A,	#38H	; 8-bit, 2 line, 5x7 dots
		ACALL	CMND_WRT
		MOV		A,	#0EH	; Display ON cursor, ON
		ACALL 	CMND_WRT
		MOV 	A,	#06H	; Auto increment mode, i.e., when we send char, cursor position moves right
		ACALL 	CMND_WRT
		MOV 	A,	#01H	; Clear display
		ACALL 	CMND_WRT
		MOV 	A,	#80H	; Bring cursor to line 1, position 0
		ACALL 	CMND_WRT
		
		; Display 'HELLO' on line 1
		MOV 	A,	#'H'
		ACALL 	DATA_WRT
		MOV 	A,	#'E'
		ACALL 	DATA_WRT
		MOV 	A,	#'L'
		ACALL 	DATA_WRT
		MOV 	A,	#'L'
		ACALL 	DATA_WRT
		MOV 	A,	#'O'
		ACALL	DATA_WRT

		MOV 	A,	#0C0H	; Bring cursor to line 2, position 0
		ACALL	CMND_WRT

		; Display 'WORLD' on line 2
		MOV 	A,	#'W'
		ACALL 	DATA_WRT
		MOV 	A,	#'O'
		ACALL 	DATA_WRT
		MOV 	A,	#'R'
		ACALL 	DATA_WRT
		MOV 	A,	#'L'
		ACALL 	DATA_WRT
		MOV 	A,	#'D'
		ACALL	DATA_WRT

		SJMP MAIN

; CMND_WRT subroutine: send command to LCD		
CMND_WRT: 	;ACALL	READY
			MOV 	DATA_PORT,	A
			CLR 	RS				; RS = 0 for command
			CLR 	RW				; RW = 0 for write
			SETB 	EN				; EN = 1 for high pulse
			ACALL	DELAY			; Call DELAY subroutine
			CLR 	EN				; EN = 0 for low pulse
			RET

; DATA_WRT subroutine: send data to LCD and display
DATA_WRT: 	MOV 	DATA_PORT,	A
			SETB 	RS				; RS = 1 for data
			CLR 	RW				; RW = 0 for write
			SETB 	EN				; EN = 1 for high pulse
			ACALL	DELAY			; Call DELAY subroutine
			CLR 	EN				; EN = 0 for low pulse
			RET
		
DELAY: 		MOV 	R3, 	#255
L2: 		MOV 	R4,		#4
L1: 		DJNZ 	R4, 	L1
			DJNZ 	R3, 	L2
			RET
		
;READY:
;	SETB	D7						; Initiate LCD as busy
;	CLR 	RS 						; RS = 0 for command
;	SETB 	RW 						; RW = 1 for read
	
;BACK:
;	CLR 	EN 						; EN = 0, start LCD command
;	ACALL	DELAY					; Call DELAY subroutine
;	SETB 	EN 						; EN = 1, clock out command to LCD
;	MOV 	DATA_PORT,	#0FFh		; Set pins to 0FF (1111 1111)
;	MOV 	A,		DATA_PORT 		; Read the return value
;	JB 		D7,		BACK			; If bit 7 high, LCD still busy
;	RET

END