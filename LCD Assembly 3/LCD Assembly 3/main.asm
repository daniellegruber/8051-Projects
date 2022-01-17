$MOD51						; This includes 8051 definitions for the Metalink assembler

RS			EQU 	P0.0	; Register select: selects command register when low, data register when high
RW			EQU		P0.1	; Read/write: low to write to the register, high to read from the register
EN			EQU 	P0.2	; Enable: sends data to data pins when a high to low pulse is given
DATA_PORT	EQU 	P2		; Define input port

NBYTES		EQU	R0	; Use R0 for defining # bytes in data and commands
BYTE_IDX	EQU	R1	; Use R1 for tracking byte idx when looping through bytes


ORG 	0H

; Initialize LCD
INIT:
			MOV		DPTR,	#INIT_CMND	; Load DPTR with LCD initialization command
			MOV		NBYTES, #3			; INIT_CMND has 3 commands = 3 bytes
			ACALL	SEND_CMND_BYTES		; Call SEND_CMND_BYTES subroutine

; Main program
MAIN: 		
SEND_DATA1:	
			MOV		DPTR,	#LINE1		; Load DPTR with command to begin cursor at line 1
			MOV		NBYTES, #2			; LINE1 has 2 commands = 2 bytes
			ACALL	SEND_CMND_BYTES		; Call SEND_CMND_BYTES subroutine
			MOV		DPTR, 	#DATA1		; Load DPTR with data for line 1
			MOV		NBYTES, #5			; DATA1 has 5 char = 5 bytes
			ACALL	SEND_DATA_BYTES		; Call SEND_DATA_BYTES subroutine
			
SEND_DATA2:		
			MOV		DPTR,	#LINE2		; Load DPTR with command to begin cursor at line 1
			MOV		NBYTES, #1			; LINE2 has 1 command = 1 byte
			ACALL	SEND_CMND_BYTES		; Call SEND_CMND_BYTES subroutine
			MOV		DPTR, 	#DATA2	; Load DPTR with data for line 1
			MOV		NBYTES, #5			; DATA2 has 5 char = 5 byte
			ACALL	SEND_DATA_BYTES		; Call SEND_DATA_BYTES subroutine
			
			SJMP	MAIN				; Jump back to MAIN (repeat main program)

; SEND_DATA_BYTES subroutine: write one byte of data to the LCD at a time 
SEND_DATA_BYTES:
			MOV		BYTE_IDX,	#0			; Initialize byte idx at 0
SEND_DATA_BYTE:
			MOV		A,	BYTE_IDX			; Load A with the value of BYTE_IDX
			ACALL	WRT_DATA				; Send data to LCD
			ACALL	DELAY					; Call DELAY subroutine
			INC		BYTE_IDX				; Increment byte idx
			DJNZ	NBYTES, SEND_DATA_BYTE	; Repeat for each byte of data (loop until NBYTES = 0)
			RET

; SEND_CMND_BYTES subroutine: write one byte of command(s) to the LCD at a time 
SEND_CMND_BYTES:
			MOV		BYTE_IDX,	#0			; Initialize byte idx at 0
SEND_CMND_BYTE:
			MOV		A,	BYTE_IDX			; Load A with the value of BYTE_IDX
			ACALL	WRT_CMND				; Send command to LCD
			ACALL	DELAY					; Call DELAY subroutine
			INC		BYTE_IDX				; Increment byte idx
			DJNZ	NBYTES, SEND_CMND_BYTE	; Repeat for each byte of command (loop until NBYTES = 0)
			RET
			

; WRT_CMND subroutine: send command to LCD		
WRT_CMND:	
			MOVC	A,	@A+DPTR		; Address of the desired byte in code space is formed by adding A + DPTR
			MOV 	DATA_PORT,	A	; Load DATA_PORT with contents of A
			CLR 	RS				; RS = 0 for command
			CLR 	RW				; RW = 0 for write
			SETB 	EN				; EN = 1 for high pulse
			ACALL	DELAY			; Call DELAY subroutine
			CLR 	EN				; EN = 0 for low pulse
			RET

; WRT_DATA subroutine: send data to LCD and display
WRT_DATA: 	
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
; 38H: 8-bit, 2 line, 5x7 dots
; 0EH: Display ON cursor, ON
; 06H: Auto increment mode, i.e., when we send char, cursor position moves right
INIT_CMND:	DB		38H,  	0EH,  	06H
	
; Define data to display on lines 1 and 2 of LCD
DATA1:	DB		'HELLO'
DATA2:	DB		'WORLD'
	
; Define commands to go to line 1 of display
; 01H: Clear display
; 80H: Bring cursor to line 1
LINE1: 	DB 		01H, 80H
	
; Define command to go to line 2 of display
; 0C0H:	Bring cursor to line 2
LINE2: 	DB 		0C0H


END