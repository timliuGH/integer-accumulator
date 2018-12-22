TITLE Integer Accumulator     (Program03_Liu_Timothy.asm)

; Author: Timothy Liu
; Last Modified: October 27, 2018
; Description: This program will introduce the program and the programmer, greet the user,
; 	prompt the user for values until a non-negative number is entered, then display the 
; 	following: the number of negative numbers entered, the sum of the numbers, the average
; 	rounded to the nearest integer and rounded to the nearest 0.001. The program will ask the
; 	user to play again, change players, or quit. Finally the program will say farewell to the user.

; Implementation notes: Uses global variables

INCLUDE Irvine32.inc

LOWER_LIMIT = -100		; Lowest valid input
UPPER_LIMIT = -1		; Highest valid input

.data

intro				BYTE	"Welcome to the Integer Accumulator by "
					BYTE	"Timothy Liu", 0dh, 0ah, 0					; Program's title and programmer's name
extraCredit_1		BYTE	"EC #1: Number the lines during user "
					BYTE	"input", 0dh, 0ah, 0						; Description of Extra Credit #1
extraCredit_2		BYTE	"EC #2: Display the average as a "
					BYTE	"floating-point number rounded to the "
					BYTE	"nearest 0.001", 0dh, 0ah, 0				; Description of Extra Credit #2
extraCredit_3		BYTE	"EC #3: Prompt player to play again, "
					BYTE	"change players, or quit", 0dh, 0ah, 0		; Description of Extra Credit #3
promptName			BYTE	"Welcome new player. What is your "
					BYTE	"name? ", 0									; Prompt user for name
userName			BYTE	33 DUP(0)									; String to be entered by user
greetUser			BYTE	"Hello, ", 0								; Greeting to user
instructions		BYTE	"Please enter numbers in [-100, -1]."		
					BYTE	0dh, 0ah, "Enter a non-negative number "
					BYTE	"when you are finished to see "	
					BYTE	"results.", 0dh, 0ah, 0						; Instructs users on valid input
promptNum			BYTE	"Enter number: ", 0							; Prompt for input
lineString			BYTE	"Line ", 0									; Precedes line number (for Extra Credit #1)
decimal				BYTE	". ", 0										; Insert colon (for Extra Credit #1)
sum					SDWORD	0											; Accumulator to hold sum
numInputs			SDWORD	0											; Accumulator to hold number of inputs
noRoundAvg			SDWORD	?											; Holds the average before rounding
avg					SDWORD	?											; Holds the average after rounding
remainder			SDWORD	?
dispNumInputs_1		BYTE	"You entered ", 0							; First-half of displaying number of inputs
dispNumInputs_2		BYTE	" valid numbers.", 0dh, 0ah, 0				; Second-half of displaying number of inputs
dispSum				BYTE	"The sum of your valid numbers is ", 0		; Displaying sum of inputs
dispAvg				BYTE	"The average rounded to the nearest "
					BYTE	"integer is ", 0							; Displaying average rounded to the nearest int
dispFloatAvg		BYTE	"The average rounded to the nearest "
					BYTE	"0.001 is ", 0								; Displaying the average rounded to 0.001 (Extra Credit #2)
noRemainder			BYTE	".000", 0									; Used if no remainder in average (Extra Credit #2)
decimalPoint		BYTE	".", 0										; Display decimal point
zeroInputs			BYTE	"You entered zero valid numbers.", 0		; Text for no inputs
repeatGame			BYTE	"Press 1 to replay, 2 for new player, "
					BYTE	"or 0 to quit: ", 0							; Repeat game text (Extra Credit #3)
farewellText		BYTE	"Thank you for playing Integer "
					BYTE	"Accumulator! It's been a pleasure to "
					BYTE	"meet you, ", 0								; Farewell text

.code
main PROC

; --- Introduction of Program ---
; Display the program title and programmer's name
	mov		edx, OFFSET intro
	call	WriteString

; Display Extra Credit descriptions
	mov		edx, OFFSET extraCredit_1
	call	WriteString
	mov		edx, OFFSET extraCredit_2
	call	WriteString
	mov		edx, OFFSET extraCredit_3
	call	WriteString

; --- Introduction of Player ---
newUser:
; Prompt for user's name
	call	Crlf
	mov		edx, OFFSET promptName
	call	WriteString

; Get and store user's name
    mov     edx, OFFSET userName
    mov     ecx, SIZEOF userName
    call    ReadString

; Greet the user
	call	Crlf
	mov		edx, OFFSET greetUser
	call	WriteString
	mov		edx, OFFSET userName
	call	WriteString
	call	Crlf

; --- Program Instructions ---
startGame:
; Make sure all variables are reset (important if game is replayed by user)
	mov		sum, 0
	mov		numInputs, 0
	mov		noRoundAvg, 0
	mov		avg, 0
	mov		remainder, 0

; Display instructions including valid input range
	call	Crlf
	mov		edx, OFFSET instructions
	call	WriteString

; --- User Input ---
promptLoop:
; Print line number (Extra Credit #1)
	mov		edx, OFFSET lineString		
	call	WriteString					; Print line text
	mov		eax, numInputs				; Get line number by adding 1 to current number of inputs
	inc		eax
	call	WriteDec					; Print line number
	mov		edx, OFFSET decimal
	call	WriteString					; Print decimal

; Prompt for numbers
	mov		edx, OFFSET promptNum
	call	WriteString
	call	ReadInt

; Check if input is at least -100
	cmp		eax, LOWER_LIMIT
	jl		invalidInput

; Check if input is at most -1
	cmp		eax, UPPER_LIMIT
	jg		invalidInput

validInput:
; Add input to sum
	add		sum, eax

; Increment number of inputs counter
	inc		numInputs

; Ask for another number
	jmp		promptLoop

; --- Display Results ---	
invalidInput:
; Check if 0 valid numbers were inputted
	cmp		numInputs, 0
	je		noInputs

; Display number of valid numbers inputted
	call	Crlf
	mov		edx, OFFSET dispNumInputs_1
	call	WriteString
	mov		eax, numInputs
	call	WriteDec
	mov		edx, OFFSET dispNumInputs_2
	call	WriteString

; Display the sum
	mov		edx, OFFSET dispSum
	call	WriteString
	mov		eax, sum
	call	WriteInt
	call	Crlf

; Calculate the quotient and remainder of the valid numbers inputted
	cdq
	idiv	numInputs
	mov		noRoundAvg, eax		; Store the quotient as the average
	mov		avg, eax
	mov		remainder, edx		; Store the remainder

; Check if remainder multiplied by -2 is greater than divisor for rounding purposes
; Need to multiply by negative 2 because remainder will be negative from idiv instruction
	imul	edx, -2
	cmp		edx, numInputs
	jg		roundAvg
	jmp		skipRounding

; Round to nearest negative integer by becoming more negative
roundAvg:
	dec		avg		

skipRounding:
; Display the average rounded to the nearest integer
	mov		edx, OFFSET dispAvg
	call	WriteString
	mov		eax, avg
	call	WriteInt
	call	Crlf

; Display the average rounded to the nearest 0.001 (Extra Credit #2)
	mov		edx, OFFSET dispFloatAvg
	call	WriteString
	mov		eax, noRoundAvg
	call	WriteInt

; Check if calculation for average had any remainder
	cmp		remainder, 0
	jne		showDecimals
	mov		edx, OFFSET noRemainder
	call	WriteString
	call	Crlf
	jmp		startEnding

; Print a decimal point
showDecimals:
	mov		edx, OFFSET decimalPoint
	call	WriteString

; Convert negative remainder value to positive
	mov		eax, -1
	mul		remainder
	mov		remainder, eax

; Find 2 values after the decimal point
	mov		ecx, 2
decimalLoop:
	mov		eax, remainder
	mov		ebx, 10
	mul		ebx
	div		numInputs
	call	WriteDec
	mov		remainder, edx
	loop	decimalLoop

; Find the third value after the decimal point
	mov		eax, remainder
	mov		ebx, 10
	mul		ebx
	div		numInputs
	mov		ecx, eax			; Store the quotient
	mov		remainder, edx		; Store the remainder

; Find the fourth value after the decimal point
	mov		eax, remainder
	mov		ebx, 10
	mul		ebx
	div		numInputs

; Use fourth value after decimal to determine rounding of third value after decimal
	cmp		eax, 5
	jle		noRounding
	inc		ecx
noRounding:
	mov		eax, ecx
	call	WriteDec
	call	Crlf
	jmp		startEnding

; --- End of Program ---
noInputs:
	call	Crlf
	mov		edx, OFFSET zeroInputs
	call	WriteString
	call	Crlf

startEnding:
; Ask user to play again, change players, or quit (Extra Credit #3)
	call	Crlf
	mov		edx, OFFSET repeatGame
	call	WriteString
	call	ReadDec
	cmp		eax, 1					; Check if same player wants to play again
	je		startGame

; Display farewell text with user's name
	call	Crlf
	mov		edx, OFFSET farewellText
	call	WriteString
	mov		edx, OFFSET userName
	call	WriteString
	call	Crlf

; Continuation of asking user to change players (Extra Credit #3)
	cmp		eax, 2					; Check if different player wants to play
	je		newUser

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
