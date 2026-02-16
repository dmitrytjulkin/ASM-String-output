.model tiny
.code
org 100h

VIDEOSEG 		equ 0b800h
START_OF_SENTENCE 	equ 000A0h 

start:
	mov ax, VIDEOSEG
	mov es, ax

	call UpperBorder

	call Sentence

	mov ax, 4c00h
	int 21h
;___________________________________________________________________________;

;__UPPERBORDER__
;Searches
;Entry:
;Exit:
;Destr:

;___________________________________________________________________________;
UpperBorder proc
	mov al, 03h		;al = upper border
	mov ah, 70h		;ah = white colour on black

	mov cx, 20		;cycle conter = 20
	xor bx, bx

BuildingUpperBorder:
	shl bx, 1
	mov es:[bx], ax
	shr bx, 1
	
	inc bx

	loop BuildingUpperBorder

	ret
	endp
;___________________________________________________________________________;

;___________________________________________________________________________;
Sentence proc
	mov al, ds:[82h]
	mov ah, 70h

	mov cx, 20
	xor bx, bx

BuildingSentence:
	shl bx, 1
	mov es:[START_OF_SENTENCE+bx], ax
	shr bx, 1

	inc bx
	mov al, ds:[82h+bx]

	loop BuildingSentence

	ret
	endp
;___________________________________________________________________________;

;___________________________________________________________________________;

end		Start