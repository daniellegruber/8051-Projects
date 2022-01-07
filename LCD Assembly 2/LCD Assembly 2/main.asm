$MOD51						; This includes 8051 definitions for the Metalink assembler
; Adapted from http://what-when-how.com/8051-microcontroller/lcd-interfacing/

RS			EQU 	P0.0	; Register select: selects command register when low, data register when high
RW			EQU		P0.1	; Read/write: low to write to the register, high to read from the register
EN			EQU 	P0.2	; Enable: sends data to data pins when a high to low pulse is given
D7			EQU		P2.7	; D7: busy flag of LCD, when high means LCD busy and no info should be issued
DATA_PORT	EQU 	P2		; Define input port


ORG 		0H
MAIN: 		MOV		DPTR,	#INIT_CMND	; Load DPTR with LCD initialization command
			ACALL	WRT_CMND			; Send command to LCD
			ACALL	DELAY				; Call DELAY subroutine
	
SEND_DATA1:	MOV		DPTR,	#LINE1		; Load DPTR with command to begin cursor at line 1
			ACALL	WRT_CMND			; Send command to LCD
			MOV		DPTR, 	#MY_DATA1	; Load DPTR with data for line 1
			ACALL	D1					; Call D1 subroutine
			;SJMP	SEND_DATA2
			
SEND_DATA2:	MOV		DPTR,	#LINE2		; Load DPTR with command to begin cursor at line 2
			ACALL	WRT_CMND			; Send command to LCD
			MOV		DPTR, 	#MY_DATA2	; Load DPTR with data for line 2
			ACALL	D1					; Call D1 subroutine
			SJMP	MAIN				; Jump back to beginning of program
			
; D1 subroutine:
D1:			MOV		10H, #5				; Load register 10H with 5
D2:			ACALL	WRT_DATA			; Send data to LCD and display
			ACALL	DELAY				; Call DELAY subroutine
			INC		DPTR				; Increment DPTR to get address of next byte of data (character)
			DJNZ	10H, D2				; Loop through D1 5 times because there are 5 char in 'HELLO' and 'WORLD'
			RET
	


; WRT_CMND subroutine: send command to LCD		
WRT_CMND:	CLR 	A				; Reset A at 0
			MOVC	A,	@A+DPTR		; Address of the desired byte in code space is formed by adding A + DPTR
			MOV 	DATA_PORT,	A	; Load DATA_PORT with contents of A
			CLR 	RS				; RS = 0 for command
			CLR 	RW				; RW = 0 for write
			SETB 	EN				; EN = 1 for high pulse
			ACALL	DELAY			; Call DELAY subroutine
			CLR 	EN				; EN = 0 for low pulse
			RET

; WRT_DATA subroutine: send data to LCD and display
WRT_DATA: 	CLR 	A				; Reset A at 0
			MOVC	A,	@A+DPTR		; Address of the desired byte in code space is formed by adding A + DPTR
			MOV 	DATA_PORT,	A	; Load DATA_PORT with contents of A
			SETB 	RS				; RS = 1 for data
			CLR 	RW				; RW = 0 for write
			SETB 	EN				; EN = 1 for high pulse
			ACALL	DELAY			; Call DELAY subroutine
			CLR 	EN				; EN = 0 for low pulse
			RET
		
; DELAY subroutine
DELAY: 		MOV 	R3, 	#255	; Load R3 with 255
L2: 		MOV 	R4,		#2		; Load R4 with 2
L1: 		DJNZ 	R4, 	L1		; Decrement R4, if not zero repeat L1
			DJNZ 	R3, 	L2		; Decrement R3, if not zero repeat L1
			RET
			
; Define commands to initialize LCD display
; 01H: Clear display
; 38H: 8-bit, 2 line, 5x7 dots
; 0EH: Display ON cursor, ON
; 06H: Auto increment mode, i.e., when we send char, cursor position moves right
INIT_CMND:	DB		01H,	38H,	0EH	,	06H, 	0
	
; Define data to display on lines 1 and 2 of LCD
MY_DATA1:	DB		'HELLO', 	0
MY_DATA2:	DB		'WORLD', 	0
	
; Define command to go to line 1 of display
; 80H:	Bring cursor to line 1
LINE1: 			DB 		80H,	0
	
; Define command to go to line 2 of display
; 0C0H:	Bring cursor to line 2
LINE2: 			DB 		0C0H,	0 


END