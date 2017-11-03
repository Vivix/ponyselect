;x86 real-mode version.
;============M=A=C=R=O==
%macro debug_print 1
	pusha
	mov ax,0900h
	mov dx,%%string
	int 21h
	popa
	jmp %%done
	%%string: db "L",__LINE__,": ",%1,0dh,0ah,"$"
	%%done:
%endmacro
;=

org 100h
;=======================
;First we open the file to process the contents into a manipulatable
;area of memory. Afterwards we generate a line count that we use in
;a random function to select a line. Upon selection of a line (offset into mem-
;-ory.) we process the line to give us the weight to use against our 1d6.
;
;After the reroll weight has been completed, we prompt the user with the episode
;name, and whether or not they want a reroll.
;======================

start:  mov ax,3d00h
	mov dx,filename
	int 21h
	jc file_error

	mov bx,ax
	mov cx,0ffffh                   ;set our maximum read to match
	mov ax,3f00h                    ;file buffer max
	mov dx,file_buffer
	int 21h                         ;actually read the file into memory
					;added 2016
	mov word [bytes_read],ax        ;store our bytes read

	;we should check file validity here

	mov ax,3e00h
	int 21h                         ;close the file, so we 
	jc  file_error_close            ;can discard file handle

.next:  mov word [rand_bx],bx           ;we might as well use this

;=========
; resultbx lines found
;       cx bytes read dec loop
process_file:
	mov cx, word [bytes_read]
	xor bx,bx
	mov si,file_buffer
	jmp .count_lines

.inc_count:
	inc bx                  ;increase lines found
	dec cx
	jz .select

.count_lines:
	lodsb                   ;mov al,[si], inc si
	cmp al,0dh
	je .inc_count
	loop .count_lines       ;decrease bytes left

;=========
;       select a random line
.select: mov byte [lines_found],bl      ;0-255 should be fine, upgrading this should be
					;easy if you really want to. Just make sure
					;the prng is expanded accordingly.
	;seed (b and d)
	mov ah,2ch                      ;get system time
	int 21h
	mov word [rand_dx],dx           ;bx is seeded

	;at some point the randomizer was broken. This is the source I found.
	;the working randomizer tests are gone.
line_select:

	mov bx, word [rand_bx]
	mov dx, word [rand_dx]
	;mixi trixi
	rol bx,07h      ;the ammount here doesn't seem to matter much
	add dl,bh

	add bx,dx       ;this needs to survive to the next iteration
	mov word [rand_bx],bx
	mov word [rand_dx],dx

	;random done, mod it down
%ifdef DEBUG
	debug_print "dl:RND - LINE GET - LINES FOUND"

	mov ah,dl       ;print our random number
	call debug_pr
%endif

	movzx ax,dl     ;set up and print our division
	mov dl,byte [lines_found]
	dec dl          ;(lines-1)
	div dl          ;%(lines-1)
	inc ah          ;remainder in ah
			;(rand%(lines-1))+1

%ifdef DEBUG
	call debug_pr
	push ax
	mov ah,byte [lines_found]
	call debug_pr
	pop ax
%endif

.get_line:
%ifdef DEBUG
	debug_print ".get_line entered."
%endif
	;as in the c version, I think we should just recount, rather than
	;store 255 maximum bytes of offsets in a table - with most processors
	;this should be fast enough. I would love to test it on older hardware!
	;Note to self: Make a C-64 and MZ-700 version! The c version SHOULD work
	;on Amiga.

	;AH = 1-LINES_FOUND
	mov cx, word [bytes_read]       ;point SI at the 0dh of our target
	mov si,file_buffer
;        or ah,ah
;        jz .line_zero                  ;we are checking for line 0
	jmp .lp                         ;but line 0 can not exist as of now

;.line_zero:
;        lodsb
;        cmp al,0dh
;        je .line_found
;        loop .line_zero

.dec_line:
	dec ah
	jz .line_found
.lp:
	lodsb           ;if we want line 1 this will start at offset 0
	cmp al,0dh      ;work itself up and count ONE 0dh, dec ah
	je .dec_line    ;get jz and leave SI at the correct location.
	loop .lp

;=============
;reaching here should indicate we did not find our line!
%ifdef DEBUG
	push dx
	mov dx,loop_drop
	call debug_str
%endif

;=======
;check against reroll
.line_found:
	;BELOW COMMENT IS FROM THE ORIGINAL FILES AND AN OLDER RANDOMIZER
	;here our si will be pointing at '\n' at the end of our selected line
	;I'd prefer it if it was pointing at the previous line. To achieve this
	;without cost, we can decrement our goal. This will introduce 0-94 vs 1-95
	;
	;This situation means that line 0 will never be found with our current loop
	;and that goal 94 will correctly find 95. Unlike our c file which goal 95
	;will selct line 1. I think I might as well stick with this.
	;A single dec and then fetch will fetch our re-roll
	;avoiding processing a line to roll against.
	;CURRENTLY::
	;
	;SI will be pointing at 0dh of our target in a list of 1-lines_found
	;and should correctly handle both last and first line as long
	;as the file ends with a newline. This is not a guarantee I realize,
	;but should be remedied easily.
%ifdef DEBUG
	debug_print "dice roll begin."
%endif

	;roll some dice
	mov dx, word [rand_dx]
	mov bx, word [rand_bx]

	rol bx,07h
	add dl,bh

%ifdef DEBUG
	debug_print "rol bx,07&add dl,bh"
%endif

	add bx,dx ;this needs to survive to the next iteration
	mov word [rand_bx],bx
	mov word [rand_dx],dx

%ifdef DEBUG
	debug_print "mov word[rand_dx],dx"
%endif

	movzx ax,dl     ;zero extend random number into ax
	mov dl,05h      ;mod/divide it by five
	div dl          ;123%5 = 0 1 2 3 4 5
	inc ah          ;1-6 rather than 0-5

	sub si,02h
	lodsb
	and al,0fh      ;31h->01h

%ifdef DEBUG
	debug_print "sub si 02 lodsb"
%endif

	cmp ah,al       ;ah dice, al weight
	jl line_select  ;reroll when dice<weight
	xchg ah,al

;=======
;print episode name!
	;aw man - rewind our index
print_episode:

.lp:
	dec si          ;TODO: Handle line 1 better. ATM we just hope it hits
	jz .lpsk        ;a 0dh
	mov al,[ds:si]          ;read backwards until we bump into previous
	cmp al,0dh              ;bump into our previous word

	jne .lp

.lpsk:  inc si
	mov ah,02h
.print:
	lodsb

	cmp al,','
	jz .finish_up
	cmp al,0dh
	jz .premature

	mov dl,al
	int 21h
	jmp .print

.finish_up:
.premature:
	mov dl,0ah
	int 21h
	mov dl,0dh
	int 21h
	;we don't do anything about this, but skip printing

;=======
;prompt user about reroll
	mov dx,prompt_user
	mov ah,09h
	int 21h

	mov ah,07h
	int 21h

	cmp al,'y'
	je line_select

;======
;We're done!
exit:   mov ax,4c00h
	int 21h

db "ponycongaponycongaponyconga"

%ifdef DEBUG
;========
;= prints ah
debug_pr:
	pusha
;       mov ah,2ch
;       int 21h
;       mov ah,02h
;       int 21h
;the code above makes no sense to me anymore 
;but I am keeping it just in case I remember

	push ax         ;protect our number in ah
	xor bx,bx       ;zero bx for index into hex
	mov bl,ah
	shr bl,04h      ;get only high nybble of number

	mov dl, byte [hex_string + bx]
	mov ax,0200h
	int 21h         ;print high nybble

	pop ax          ;restore number
	mov bl,ah
	and bl,0fh      ;get only low nybble.

	mov dl, byte [hex_string + bx]
	mov ax,0200h
	int 21h         ;print low nybble

	mov dl,"-"      ;print seperator
	int 21h

	popa
	ret

;====
; print string pointer in dx for debug, restores dx on exit
debug_str:
	push ax         ;protect ax
	push dx

	mov ax,0200h    ;print an indicator that this is a string
	mov dl,0fh
	int 21h

	pop dx          ;restore dx (dx should be ptr to string here)

	mov ax,0900h    ;print $ term string 
	int 21h

	pop ax          ;restore ax
	pop dx          ;restore original dx
	ret
.temp_reg       db 69h,69h
%endif

file_error:
	;error handling
	mov ah,4ch      ;keep al to conserve error returned by file int 
	int 21h

file_error_close:
	mov ah,4ch
	int 21h
	;above is temp

rand_dx:        dw 1244h
rand_bx:        dw 4421h
filename:       db "episodes.txt",0
lines_found:    db 05h
bytes_read:     dw 0h
prompt_user:    db "Reroll?",0ah,0dh,"$"

%ifdef DEBUG
hex_string:     db "0123456789ABCDEFHorses!",69h,69h
horses_rule     db "really!$"
getline_1       db "get_line reached after count$"
loop_drop       db "dropped behind loop, unreachable$"
dice_rolled     db "dice has been rolled against weight$"
dice_begin      db "dice is about to begin",0ah,0dh,"$"
%endif
db 0dh,0dh,0dh
segment .bss
file_buffer:    resb 1024

