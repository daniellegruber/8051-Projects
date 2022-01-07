$MOD51	; This includes 8051 definitions for the Metalink assembler
; Adapted from https://www.circuitstoday.com/interfacing-hex-keypad-to-8051

; Define keypad rows and columns
KEY_PORT	EQU		P1
COL1		EQU		P1.3
COL2		EQU		P1.2
COL3		EQU		P1.1
COL4		EQU		P1.0
ROW1		EQU		P1.7
ROW2		EQU		P1.6
ROW3		EQU		P1.5
ROW4		EQU		P1.4
	
; Define LCD pins
RS			EQU 	P0.0	; Register select: selects command register when low, data register when high
RW			EQU		P0.1	; Read/write: low to write to the register, high to read from the register
EN			EQU 	P0.2	; Enable: sends data to data pins when a high to low pulse is given
OUT_PORT	EQU 	P2		; Define output port
	
ORG 	00H
	
; Initialize LCD
MOV 	A,			#0FFH	; Loads A with all 1's
MOV 	OUT_PORT,	#0H		; Initializes P2 as output port

MOV		A,	01H		; Clear display
ACALL	WRT_CMND	
MOV		A,	38H		; 8-bit, 2 line, 5x7 dots
ACALL	WRT_CMND
MOV		A,	0EH		; Display ON cursor, ON
ACALL	WRT_CMND
MOV		A,	06H		; Auto increment mode, i.e., when we send char, cursor position moves right
ACALL	WRT_CMND
ACALL	DELAY				

; Keypad program
BACK:	MOV 	KEY_PORT,	#0FFH	; Load P1 with all 1s
		CLR		ROW1				; Make ROW1 low
		JB 		COL1,		NEXT1 	; Check whether COL1 is low and jump to NEXT1 if not low
		MOV		A,			#'1'	; Load A with '1' if column is low (that means key 1 is pressed)
		ACALL	WRT_DATA			; Call WRT_DATA subroutine

NEXT1:	JB		COL2,		NEXT2	; Check whether COL2 is low and so on...
		MOV		A,			#'2'
		ACALL	WRT_DATA
		
NEXT2:	JB		COL3,		NEXT3		
		MOV		A,			#'3'
		ACALL	WRT_DATA
		
NEXT3:	JB		COL4,		NEXT4		
		MOV		A,			#'A'
		ACALL	WRT_DATA
		
NEXT4:	SETB 	ROW1
		CLR 	ROW2
		JB 		COL1,		NEXT5
		MOV 	A,			#'4'
		ACALL	WRT_DATA

NEXT5:	JB		COL2,		NEXT6		
		MOV		A,			#'5'
		ACALL	WRT_DATA

NEXT6:	JB		COL3,		NEXT7		
		MOV		A,			#'6'
		ACALL	WRT_DATA
		
NEXT7:	JB		COL4,		NEXT8		
		MOV		A,			#'B'
		ACALL	WRT_DATA
		
NEXT8:	SETB 	ROW2
		CLR 	ROW3
		JB 		COL1,		NEXT9
		MOV 	A,			#'7'
		ACALL 	WRT_DATA
		
NEXT9:	JB 		COL2,		NEXT10
		MOV 	A,			#'8'
		ACALL 	WRT_DATA
		
NEXT10:	JB 		COL3,		NEXT11
		MOV 	A,			#'9'
		ACALL 	WRT_DATA
		
NEXT11:	JB 		COL4,		NEXT12
		MOV 	A,			#'C'
		ACALL 	WRT_DATA
		
NEXT12:	SETB 	ROW3
		CLR 	ROW4
		JB 		COL1,		NEXT13
		MOV 	A,			#'*'
		ACALL 	WRT_DATA
		
NEXT13:	JB 		COL2,		NEXT14
		MOV 	A,			#'0'
		ACALL 	WRT_DATA

NEXT14:	JB 		COL3,		NEXT15
		MOV 	A,			#'#'
		ACALL 	WRT_DATA

NEXT15:	JB 		COL4,		BACK
		MOV 	A,			#'D'
		ACALL 	WRT_DATA
		LJMP BACK


; WRT_CMND subroutine: send command to LCD		
WRT_CMND:	MOV 	OUT_PORT,	A	; Load OUT_PORT with contents of A
			CLR 	RS				; RS = 0 for command
			CLR 	RW				; RW = 0 for write
			SETB 	EN				; EN = 1 for high pulse
			ACALL	DELAY			; Call DELAY subroutine
			CLR 	EN				; EN = 0 for low pulse
			RET

; WRT_DATA subroutine: send data to LCD and display
WRT_DATA: 	MOV 	OUT_PORT,	A	; Load OUT_PORT with contents of A
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

END