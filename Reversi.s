.equ SWI_Exit, 0x11
.equ SWI_SETLED, 0x201
.equ SWI_CheckBlue, 0x203
.equ SWI_Display_String, 0x204
.equ SWI_Display_int, 0x205
.equ SWI_Display_char, 0x207
.equ SWI_Display_clear_line, 0x208
.text

b main

print:
;preserving(pushing on stack) r4,r5
str r4,[sp,#-4]!
str r5,[sp,#-4]!

mov r0,#0
mov r1,#0
ldr r2,=s1
swi SWI_Display_String

mov r3,#1
ldr r4,=board

while:
	mov r0,#0
	mov r1,r3
	mov r2,r3
	swi SWI_Display_int

	cmp r3,#4
	beq four
	cmp r3,#5
	beq five

	mov r1,r3
	mov r0,#1
	ldr r2,=s12
	swi SWI_Display_String
	b endit

	four:
	mov r1,r3
	mov r0,#1
	ldr r2,=s13
	swi SWI_Display_String
	b endit

	five:
	mov r1,r3
	mov r0,#1
	ldr r2,=s14
	swi SWI_Display_String

	endit:
	/*
	mov r5,#2

	while1:
		ldrb r0,[r4]
		cmp r0,#1
		beq white
		blt black
		bgt blank

		blank:
			mov r0,r5
			mov r1,r3
			mov r2,#' 
			swi SWI_Display_char
			mov r2,#'_
			swi SWI_Display_char
			b finish
		white:
			mov r0,r5
			mov r1,r3
			mov r2,#' 
			swi SWI_Display_char
			mov r2,#'W
			swi SWI_Display_char
			b finish
		black:
			mov r0,r5
			mov r1,r3
			mov r2,#' 
			swi SWI_Display_char
			mov r2,#'B
			swi SWI_Display_char
		finish:

		add r4,r4,#1
		add r5,r5,#2
		cmp r5,#18
	blt while1 */

	add r3,r3,#1
	cmp r3,#9
blt while


;poping r4,r5 from stack
ldr r5,[sp],#4
ldr r4,[sp],#4

mov pc,lr

is_possible:
; arg : r0 = chance 
;return : r0 = bool
; r1=i, r2=j
; pushing r4 on stack
str r4,[sp,#-4]!
ldr r3,=board
mov r1,#0

while2:
	mov r2,#0
	while3:
		ldrb r4,[r3]
		cmp r4,#2
		bne down

		; calling function valid
		; pushing r1,r2,r3 on stack
		; r0 contains chance
		str r0,[sp,#-4]!
		str r1,[sp,#-4]!
		str r2,[sp,#-4]!
		str r3,[sp,#-4]!
		; r0=chance, r1 = i, r2=j
		str lr,[sp,#-4]! 	@ push lr to stack
		bl valid
		ldr lr,[sp],#4 		@ pop lr from stack
		; r0=result of valid
		cmp r0,#1
		bne down1
		b return_one
		down1:
		;poping r0,r1,r2,r3
		ldr r3,[sp],#4
		ldr r2,[sp],#4
		ldr r1,[sp],#4
		ldr r0,[sp],#4
		down:
		add r3,r3,#1
		add r2,r2,#1
		cmp r2,#8
		blt while3
	add r1,r1,#1
	cmp r1,#8
	blt while2
;reached here implies not possible so r0=0
mov r0,#0
; poping r4 from stack
ldr r4,[sp],#4
mov pc,lr
return_one:
	ldr r3,[sp],#4
	ldr r2,[sp],#4
	ldr r1,[sp],#4
	ldr r0,[sp],#4
	ldr r4,[sp],#4
	mov r0,#1
mov pc,lr

valid:
; parameters r0=chance, r1 = row, r2=col
; result r0 = bool
; r3 = i, r4 = up, r5 = down, r6 = flips, r7 = flips_local, r8 = ver, r9 = hor, r10=board
; pushing r4,r5,r6,r7,r8,r9,r10,r11 from stack

str r4,[sp,#-4]!
str r5,[sp,#-4]!
str r6,[sp,#-4]!

ldr r3,=board
add r4,r3,r2
ldrb r5,[r4,r1,LSL#3]
cmp r5,#2

ldr r6,[sp],#4
ldr r5,[sp],#4
ldr r4,[sp],#4
beq continue_this
mov r0,#0
mov pc,lr

continue_this:
str r4,[sp,#-4]!
str r5,[sp,#-4]!
str r6,[sp,#-4]!
str r7,[sp,#-4]!
str r8,[sp,#-4]!
str r9,[sp,#-4]!
str r10,[sp,#-4]!
str r11,[sp,#-4]!

ldr r8,=ver
ldr r9,=hor
ldr r10,=board
mov r3,#0
mov r6,#0
for:
	ldr r4,[r8,r3,LSL#2]
	add r4,r4,r1
	ldr r5,[r9,r3,LSL#2]
	add r5,r5,r2
	mov r7,#0
	; validity of up and down
	cmp r4,#0
	blt bottom_for
	cmp r4,#7
	bgt bottom_for
	cmp r5,#0
	blt bottom_for
	cmp r5,#7
	bgt bottom_for

	while4:
		;cmp board[up*8+down] == 1-chance
		mov r11,r10
		add r11,r11,r5
		ldrb r11,[r11,r4,LSL#3]
		sub r0,r0,#1
		cmn r11,r0
		add r0,r0,#1
		bne continue_for

		add r7,r7,#1
		; r4 += [r8,r3,LSL#2]
		; r5 += [r9,r3,LSL#2]
		; pushing r1,r2 to stack
		str r1,[sp,#-4]!
		
		ldr r1,[r8,r3,LSL#2]
		add r4,r4,r1
		ldr r1,[r9,r3,LSL#2]
		add r5,r5,r1
		; poping r1,r2 to stack
		ldr r1,[sp],#4

		cmp r4,#0
		blt continue_for
		cmp r4,#7
		bgt continue_for
		cmp r5,#0
		blt continue_for
		cmp r5,#7
		bgt continue_for

	b while4

	continue_for:
	cmp r4,#0
	blt bottom_for
	cmp r4,#7
	bgt bottom_for
	cmp r5,#0
	blt bottom_for
	cmp r5,#7
	bgt bottom_for

	;cmp board[up*8+down] == chance
	mov r11,r10
	add r11,r11,r5
	ldrb r11,[r11,r4,LSL#3]
	cmp r11,r0
	bne bottom_for

	add r6,r6,r7

	bottom_for:
	add r3,r3,#1
	cmp r3,#8
	blt for

mov r0,#0
cmp r6,#0
ble	if_end
mov r0,#1
if_end:

; poping r4,r5,r6,r7,r8,r9,r10,r11 from stack
ldr r11,[sp],#4
ldr r10,[sp],#4
ldr r9,[sp],#4
ldr r8,[sp],#4
ldr r7,[sp],#4
ldr r6,[sp],#4
ldr r5,[sp],#4
ldr r4,[sp],#4

mov pc,lr

go:
;parameters r0 = chance, r1 = row, r2 = col
; pushing r4,r5,r6,r7,r8,r9,r10,r11 from stack
str r4,[sp,#-4]!
str r5,[sp,#-4]!
str r6,[sp,#-4]!
str r7,[sp,#-4]!
str r8,[sp,#-4]!
str r9,[sp,#-4]!
str r10,[sp,#-4]!
str r11,[sp,#-4]!
; r3 = i, r4 = up, r5 = down, r7 = flips_local, r8 = ver, r9 = hor, r10=board, r6=up1, r11=down1
mov r3,#0
ldr r8,=ver
ldr r9,=hor
ldr r10,=board

;board[row*8+col] = chance; score[chance]++;
; writing this is remaining = done
ldr r3,=board
add r3,r3,r2
strb r0,[r3,r1,LSL#3]
ldr r3,=score
ldr r4,[r3,r0,LSL#2]
add r4,r4,#1
str r4,[r3,r0,LSL#2]
mov r3,#0

@ changing the corresponding B/W on the screen
cmp r0,#0
beq black_hai
add r1,r1,#1
str r0,[sp,#-4]!
str r2,[sp,#-4]!

mov r0,r2,LSL#1
add r0,r0,#2

mov r2,#'W
swi SWI_Display_char

ldr r2,[sp],#4
ldr r0,[sp],#4
sub r1,r1,#1
b for1

black_hai:
add r1,r1,#1
str r0,[sp,#-4]!
str r2,[sp,#-4]!

mov r0,r2,LSL#1
add r0,r0,#2

mov r2,#'B
swi SWI_Display_char

ldr r2,[sp],#4
ldr r0,[sp],#4
sub r1,r1,#1

for1:
	ldr r4,[r8,r3,LSL#2]
	add r4,r4,r1
	ldr r5,[r9,r3,LSL#2]
	add r5,r5,r2
	mov r7,#0
	; validity of up and down
	cmp r4,#0
	blt bottom_for1
	cmp r4,#7
	bgt bottom_for1
	cmp r5,#0
	blt bottom_for1
	cmp r5,#7
	bgt bottom_for1

	while5:
		;cmp board[up*8+down] == 1-chance
		mov r11,r10
		add r11,r11,r5
		ldrb r11,[r11,r4,LSL#3]
		sub r0,r0,#1
		cmn r11,r0
		add r0,r0,#1
		bne continue_for1

		add r7,r7,#1
		; r4 += [r8,r3,LSL#2]
		; r5 += [r9,r3,LSL#2]
		; pushing r1 to stack
		str r1,[sp,#-4]!
		
		ldr r1,[r8,r3,LSL#2]
		add r4,r4,r1
		ldr r1,[r9,r3,LSL#2]
		add r5,r5,r1
		; poping r1 to stack
		ldr r1,[sp],#4

		cmp r4,#0
		blt continue_for1
		cmp r4,#7
		bgt continue_for1
		cmp r5,#0
		blt continue_for1
		cmp r5,#7
		bgt continue_for1

	b while5
	continue_for1:

	cmp r4,#0
	blt bottom_for1
	cmp r4,#7
	bgt bottom_for1
	cmp r5,#0
	blt bottom_for1
	cmp r5,#7
	bgt bottom_for1

	cmp r7,#0
	ble bottom_for1

	;cmp board[up*8+down] == chance
	mov r11,r10
	add r11,r11,r5
	ldrb r11,[r11,r4,LSL#3]
	cmp r11,r0
	bne bottom_for1

	;up1 = ver[i]+row; down1 = hor[i] + col;
	ldr r6,[r8,r3,LSL#2]
	add r6,r6,r1
	ldr r11,[r9,r3,LSL#2]
	add r11,r11,r2

	while6:
		; !(up1==up && down1 == down)
		cmp r4,r6
		beq next1
		b next2
		next1:
		cmp r5,r11
		beq bottom_for1
		next2:

		; pushing r1,r2 to stack
		str r1,[sp,#-4]!
		str r2,[sp,#-4]!

		ldr r2,=score
		;score[chance]++
		ldr r1,[r2,r0,LSL#2]
		add r1,r1,#1
		str r1,[r2,r0,LSL#2]
		;score[1-chance]--
		cmp r0,#1
		beq itsone
		cmp r0,#0
		beq itszero

		itszero:
		ldr r1,[r2,#4]
		sub r1,r1,#1
		str r1,[r2,#4]
		b endif

		itsone:
		ldr r1,[r2]
		sub r1,r1,#1
		str r1,[r2]

		endif:

		;board[up1*8+down1] = chance;
		mov r1,r10
		add r1,r1,r11
		strb r0,[r1,r6,LSL#3]


		@ changing the corresponding B/W on the screen

		cmp r0,#0
		beq black_hai1
		str r0,[sp,#-4]!
		str r1,[sp,#-4]!
		str r2,[sp,#-4]!
		add r1,r6,#1
		mov r0,r11,LSL#1
		add r0,r0,#2

		mov r2,#'W
		swi SWI_Display_char

		ldr r2,[sp],#4
		ldr r1,[sp],#4
		ldr r0,[sp],#4
		sub r1,r1,#1
		b yaha

		black_hai1:
		str r0,[sp,#-4]!
		str r1,[sp,#-4]!
		str r2,[sp,#-4]!
		add r1,r6,#1
		mov r0,r11,LSL#1
		add r0,r0,#2

		mov r2,#'B
		swi SWI_Display_char

		ldr r2,[sp],#4
		ldr r1,[sp],#4
		ldr r0,[sp],#4
		sub r1,r1,#1

		yaha:
		; r6=up1, r11=down1
		; r3 = i, r4 = up, r5 = down, r7 = flips_local, r8 = ver, r9 = hor, r10=board, r6=up1, r11=down1
		;up1 += ver[i]; down1 += hor[i];
		ldr r1,[r8,r3,LSL#2]
		add r6,r6,r1
		ldr r1,[r9,r3,LSL#2]
		add r11,r11,r1

		; poping r1,r2 to stack
		ldr r2,[sp],#4
		ldr r1,[sp],#4

		b while6

	bottom_for1:
	add r3,r3,#1
	cmp r3,#8
	blt for1


; poping r4,r5,r6,r7,r8,r9,r10,r11 from stack
ldr r11,[sp],#4
ldr r10,[sp],#4
ldr r9,[sp],#4
ldr r8,[sp],#4
ldr r7,[sp],#4
ldr r6,[sp],#4
ldr r5,[sp],#4
ldr r4,[sp],#4

mov pc,lr

getBlueInput:
button:
swi SWI_CheckBlue
cmp r0,#0
beq button
mov r1,#0
tst r0,#255
addeq r1,r1,#8
moveq r0,r0,LSR#8
tst r0,#15
addeq r1,r1,#4
moveq r0,r0,LSR#4
tst r0,#3
addeq r1,r1,#2
moveq r0,r0,LSR#2
tst r0,#1
addeq r1,r1,#1
moveq r0,r0,LSR#1
mov r0,r1
add r0,r0,#1
mov pc,lr


main:
	ldr r0,=hor
	ldr r1,[r0,#4]
	;r4 = chance, r5 = score, r6 = row, r7 = col
	ldr r5,=score
	mov r4,#0

	bl print

	; show the scores
	mov r0,#20
	mov r1,#3
	ldr r2,=s6
	swi SWI_Display_String
	mov r0,#20
	mov r1,#4
	ldr r2,=s8
	swi SWI_Display_String

	mov r0,#28
	mov r1,#4
	ldr r2,=s11
	swi SWI_Display_String

	mov r0,#28
	mov r1,#5
	ldr r2,=s11
	swi SWI_Display_String			

	ldr r0,=score
	ldr r2,[r0]
	ldr r3,[r0,#4]

	mov r0,#28
	mov r1,#4
	swi SWI_Display_int

	mov r0,#20
	mov r1,#5
	ldr r2,=s7
	swi SWI_Display_String

	mov r0,#28
	mov r1,#5
	mov r2,r3
	swi SWI_Display_int

	while7:
		ldr r6,[r5]
		ldr r7,[r5,#4]
		add r6,r6,r7
		cmp r6,#64
		beq gameEndsHere

		mov r0,r4
		bl is_possible
		cmp r0,#0
		bne chance
		mov r1,#-1
		mul r0,r1,r4
		add r0,r0,#1
		bl is_possible
		cmp r0,#0
		bne swap_chance
		b gameEndsHere
		swap_chance: 
			mov r1,#-1
			mul r0,r1,r4
			add r0,r0,#1
			mov r4,r0
		chance: 
			mov r0,#20
			mov r1,#2
			ldr r2,=s2
			swi SWI_Display_String

			cmp r4,#0
			beq black_chance
			; show that chance is for white
			mov r0,#32
			mov r1,#2
			ldr r2,=s3
			swi SWI_Display_String

			b input
			black_chance:
			; show that chance is for black
			mov r0,#32
			mov r1,#2
			ldr r2,=s4
			swi SWI_Display_String

			input:
			bl getBlueInput
			mov r6,r0
			
			mov r0,#10
			swi SWI_Display_clear_line
			
			bl getBlueInput
			mov r7,r0
			sub r6,r6,#1
			sub r7,r7,#1
			
			mov r0,r4
			mov r1,r6
			mov r2,r7
			bl valid
			cmp r0,#0
			beq invalid_input

			mov r0,r4
			mov r1,r6
			mov r2,r7
			bl go
			@bl print
			
			mov r1,#-1
			mul r0,r1,r4
			add r0,r0,#1
			mov r4,r0

			; show the scores
			@mov r0,#20
			@mov r1,#3
			@ldr r2,=s6
			@swi SWI_Display_String
			@mov r0,#20
			@mov r1,#4
			@ldr r2,=s8
			@swi SWI_Display_String

			mov r0,#28
			mov r1,#4
			ldr r2,=s11
			swi SWI_Display_String

			mov r0,#28
			mov r1,#5
			ldr r2,=s11
			swi SWI_Display_String			

			ldr r0,=score
			ldr r2,[r0]
			ldr r3,[r0,#4]

			mov r0,#28
			mov r1,#4
			swi SWI_Display_int

			@mov r0,#20
			@mov r1,#5
			@ldr r2,=s7
			@swi SWI_Display_String

			mov r0,#28
			mov r1,#5
			mov r2,r3
			swi SWI_Display_int
			
			b while7

			invalid_input:
			; print that input is invalid
			mov r0,#10
			mov r1,#10
			ldr r2,=s5
			swi SWI_Display_String

			b while7

	gameEndsHere:
		mov r0,#0
		mov r1,#10
		ldr r2,=s9
		swi SWI_Display_String
		
		ldr r3,[r5]
		ldr r4,[r5,#4]

		cmp r3,r4
		bgt black_winner
		beq draw

		mov r0,#5
		mov r1,#11
		ldr r2,=s7 @white
		swi SWI_Display_String
		b Ending

		black_winner:
		mov r0,#5
		mov r1,#11
		ldr r2,=s8 @black
		swi SWI_Display_String
		b Ending

		draw:
		mov r0,#1
		mov r1,#11
		ldr r2,=s10 @draw
		swi SWI_Display_String

		Ending:
swi SWI_Exit


.data
ver: .word -1, 1, 0, 0, 1,-1, 1,-1
hor: .word  0, 0, 1,-1, 1, 1,-1,-1
s1: .asciz "  1 2 3 4 5 6 7 8\n"
s2: .asciz "chance of :"
s3:	.asciz "white"
s4: .asciz "black"
s5: .asciz "invalid input, try again"
s6: .asciz "scores:"
s7: .asciz "white:"
s8: .asciz "black:"
s9: .asciz "The game ends here and the winner is:"
s10: .asciz "No one, it's a draw"
s11: .asciz "  "
s12: .asciz " _ _ _ _ _ _ _ _"
s13: .asciz " _ _ _ W B _ _ _"
s14: .asciz " _ _ _ B W _ _ _"

board: .byte 	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,0,2,2,2,2,2,2,0,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
score: .word    2,2
.end