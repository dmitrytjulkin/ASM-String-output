.model tiny
.code
org 100h

VIDEOSEG 		equ 0b800h 
ADRESS_OF_FRAME		equ 007CAh
REL_ADRESS_OF_BORDER	equ 000A0h

ADRESS_OF_FIRST_CMD	equ 00082h
ADRESS_OF_SECOND_CMD	equ 00085h
ADRESS_OF_INPUT		equ 00088h

COUNT_TO_SKIP		equ 7d

TEXT_COLOR		equ 070h

HORIZONTAL_BORDER 	equ 0CDh
VERTICAL_BORDER		equ 0BAh
TOP_LEFT_CORNER		equ 0C9h
TOP_RIGHT_CORNER	equ 0BBh
BOTTOM_LEFT_CORNER	equ 0C8h
BOTTOM_RIGHT_CORNER	equ 0BCh

start:
	mov ax, VIDEOSEG
	mov es, ax

	mov ah, TEXT_COLOR

	call PrintFrame

	call PrintSentence

	mov ax, 4c00h
	int 21h
;___________________________________________________________________________;


;__PRINTFRAME__
;Printing frame with special color and with given size relative to sentence
;Entry: AH - color of symbols
;Exit: -
;Destr: AL, BX, CX, DI
;___________________________________________________________________________;
PrintFrame		proc
	call PrintUpperBorder

;	call PrintVerticalBorderAndBackground

	call PrintLowerBorder

	ret
	endp
;___________________________________________________________________________;


;__PRINTUPPERBORDER__
;Printing the top and bottom horizontal borders 
;Entry: AH = color of the text
;Exit: -
;Destr: AL, BX, CX, DI
;___________________________________________________________________________;
PrintUpperBorder	proc
	call FindInputStrlen

	mov bx, cx
	call RoundBxToEvenNum
	add bx, REL_ADRESS_OF_BORDER
	sub bx, ADRESS_OF_FRAME
	neg bx
	mov di, bx			;di = adress to print

	mov al, TOP_LEFT_CORNER
	mov es:[di-2], ax		;printing top left corner
	
	mov al, HORIZONTAL_BORDER

	xor bx, bx

building_upper_border:
	shl bx, 1
	mov es:[di+bx], ax
	shr bx, 1

	inc bx

	loop building_upper_border

	mov al, TOP_RIGHT_CORNER
	shl bx, 1
	mov es:[di+bx], ax		;printing top right corner

	ret
	endp
;___________________________________________________________________________;


;__PRINTLOWERBORDER__
;Printing lower border (include lower corners) in special color
;Entry: AH - color of border
;Exit: -
;Destr: AL, BX, CX, DI
;___________________________________________________________________________;
PrintLowerBorder 	proc
	call FindInputStrlen

	mov bx, cx
	call RoundBxToEvenNum
	neg bx
	add bx, ADRESS_OF_FRAME
	add bx, REL_ADRESS_OF_BORDER 
	mov di, bx			;di = adress to print

	mov al, BOTTOM_LEFT_CORNER
	mov es:[di-2], ax		;printing bottom left corner

	mov al, HORIZONTAL_BORDER

	xor bx, bx

building_lower_border:
	shl bx, 1
	mov es:[di+bx], ax
	shr bx, 1

	inc bx

	loop building_lower_border

	mov al, BOTTOM_RIGHT_CORNER
	shl bx, 1
	mov es:[di+bx], ax		;printing bottom right corner

	ret
	endp
;___________________________________________________________________________;

;__PRINTSENTENCE__
;Printing the input string
;Entry: AH = color of sentence
;Exit: -
;Destr: AL, BX, CX, DI
;___________________________________________________________________________;
PrintSentence 		proc
	call FindInputStrlen

	mov bx, cx
	call RoundBxToEvenNum
	neg bx
	add bx, ADRESS_OF_FRAME
	mov di, bx

	mov al, ds:[ADRESS_OF_INPUT]	;al = the 1st symbol of input

	xor bx, bx
	
building_sentence:
	shl bx, 1
	mov es:[di+bx], ax
	shr bx, 1

	inc bx
	mov al, ds:[bx+ADRESS_OF_INPUT]

	loop building_sentence

	ret
	endp
;___________________________________________________________________________;


;__BUILDTOPCORNERS__
;Printing top right and left corners.
;Entry: AH = color of text
;Exit: -
;Destr: AL, BX, CX, DI
;___________________________________________________________________________;
BuildTopCorners		proc
	call FindInputStrlen	
	
	mov bx, cx
	call RoundBxToEvenNum
;	mov di, CENTER_OF_FRAME
;	sub di, PLACE_OF_UPPER_BORDER	;di = same row as border, but in center
	sub di, bx

	mov al, TOP_LEFT_CORNER
	sub di, 2			;di = the start of top border
	mov es:[di], ax

	shl cx, 1

	mov al, TOP_RIGHT_CORNER
	add di, cx			;di = the end of top border
	mov es:[di+2], ax			

	ret
	endp
;___________________________________________________________________________;


;__BUILDBOTTOMCORNERS__
;Printing bottom left and right corners of frame.  
;Entry: AH = color of the text
;Exit: -
;Destr: AL, BX, CX, DI
;___________________________________________________________________________;
BuildBottomCorners	proc
	call FindInputStrlen

	mov bx, cx
	call RoundBxToEvenNum
;	mov di, CENTER_OF_FRAME
;	sub di, PLACE_OF_LOWER_BORDER	;di = same row as border, but in center
	sub di, bx

	mov al, BOTTOM_LEFT_CORNER
	sub di, 2
	mov es:[di], ax			;printing bottom left corner

	shl cx, 1
	
	mov al, BOTTOM_RIGHT_CORNER
	add di, cx
	mov es:[di+2], ax		;printing bottom right corner

	ret
	endp
;___________________________________________________________________________;


;__SETCYCLECOUNTER__
;Setting cx as counter of input symbols (the max value is 0EEh)
;Entry: -
;Exit: cx = count of input symbols
;Destr: -
;___________________________________________________________________________;
FindInputStrlen	proc
	mov cl, ds:[80h]
	mov ch, 00
	
	sub cx, COUNT_TO_SKIP

	ret
	endp
;__________________________________________________________________________;


;__ROUNDBXTOEVENNUM__
;Rounding value in bx to the nearest and the lowest even number
;Entry: BX = value
;Exit: BX = even value
;Destr: -
;__________________________________________________________________________;
RoundBxToEvenNum		proc
	shr bx, 1
	shl bx, 1

	ret
	endp
;__________________________________________________________________________;

end		Start