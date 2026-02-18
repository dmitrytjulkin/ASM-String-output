.model tiny
.code
org 100h

VIDEOSEG 		equ 0b800h 
CENTER_OF_FRAME		equ 07CAh
PLACE_OF_UPPER_BORDER	equ 00A0h
PLACE_OF_LOWER_BORDER	equ 0FF60h
TEXT_COLOR		equ 0070h

start:
	mov ax, VIDEOSEG
	mov es, ax

	call BuildFrame

	mov ax, 4c00h
	int 21h
;___________________________________________________________________________;


;__BUILDFRAME__

;___________________________________________________________________________;
BuildFrame		proc
	mov ah, TEXT_COLOR			;init color of text

	call BuildTopLeftCorner

	mov dx, PLACE_OF_UPPER_BORDER
	call BuildBorder

;	call BuildTopRightCorner

	call Sentence

	mov dx, PLACE_OF_LOWER_BORDER
	call BuildBorder

	ret
	endp
;___________________________________________________________________________;


;__UPPERBORDER__

;___________________________________________________________________________;
BuildBorder	 proc
	call SetCycleCounter

	mov bx, cx
	shr bx, 1
	shl bx, 1
	sub dx, CENTER_OF_FRAME
	add bx, dx			;choose if it top border or bottom
	neg bx
	mov di, bx			;di = place to print

	mov al, 0cdh			;al = double horizontal border

	xor bx, bx

building_border:
	shl bx, 1
	mov es:[di+bx], ax
	shr bx, 1

	inc bx

	loop building_border

	ret
	endp
;___________________________________________________________________________;


;__SENTENCE__

;___________________________________________________________________________;
Sentence 		proc
	call SetCycleCounter

	mov bx, cx
	shr bx, 1
	shl bx, 1
	sub bx, CENTER_OF_FRAME
	neg bx
	mov di, bx

	mov al, 0bah 
	mov es:[di-2], ax		;printing left border

	mov al, ds:[82h]		;al = the 1st symbol of input

	xor bx, bx
	
building_sentence:
	shl bx, 1
	mov es:[di+bx], ax
	shr bx, 1

	inc bx
	mov al, ds:[82h+bx]

	loop building_sentence

	shl bx, 1
	mov al, 0bah
	mov es:[di+bx], ax		;printing right border

	ret
	endp
;___________________________________________________________________________;


;___________________________________________________________________________;
BuildTopLeftCorner	proc
	call SetCycleCounter	
	
	mov bx, cx
	shr bx, 1
	shl bx, 1
	mov dx, PLACE_OF_UPPER_BORDER
	sub dx, CENTER_OF_FRAME
	add bx, dx
	neg bx
	mov di, bx

	mov al, 0c9h			;al = top left corner

	mov es:[di-2], ax

	ret
	endp
;___________________________________________________________________________;

;__SETCYCLECOUNTER__

;___________________________________________________________________________;
SetCycleCounter		proc
	mov cl, ds:[80h]
	mov ch, 00
	dec cl

	ret
	endp
;__________________________________________________________________________;

;__________________________________________________________________________;
RoundBxToEvenNum		proc
	shr bx, 1
	shl bx, 1

	ret
	endp
;__________________________________________________________________________;

end		Start