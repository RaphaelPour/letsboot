; boot2 - babystep 4

[ORG 0x7c00]
  xor ax, ax      ; clear ax by xoring it with itself
  mov ds, ax      ; initialize data segment register
  
                  ; initialize stack
  mov ss, ax      ; initialize stack segment register
  mov sp, 0x9c00  ; set stack pointer to bottom of stack far behind the bootloader
  
  cld             ; clear direction flag, that decides in which direction
                  ; e.g. loadsb should load the memory (++ as usual or -- for
                  ; reading backwards)

  mov ax, 0xb800  ; VGA video buffer starts at 0xb800
  mov es, ax      ; set extra-segment to the VGA Buffer

	cli							; <babystep 5 starts here> disable all interrupts
	mov bx, 0x09
	shl bx, 2
	xor ax, ax
	mov gs, ax
	mov [gs:bx], word on_key_press
	mov [gs:bx+2], ds
	sti

hang:
  jmp hang

; key callback
on_key_press:
	in al, 0x60
	mov bl, al
	mov byte [port60], al

	in al, 0x061
	mov ah, al
	or al, 0x80
	out 0x61, al
	xchg ah, al
	out 0x61, al

	mov al, 0x20
	out 0x20, al

	and bl, 0x80
	jnz on_key_press_done

	mov ax, [port60]
	mov word[reg16], ax
	call printreg16

on_key_press_done:
  iret

; the usual print lib
dochar: 
  call cprint
sprint: 
  lodsb
  cmp al, 0
  jne dochar
  add byte [ypos], 1
  mov byte [xpos], 0
  ret

cprint:
  mov ah, [bgcolor]
  or ah, [fgcolor]
  mov cx, ax
  movzx ax, byte [ypos]
  mov dx, 160
  mul dx
  movzx bx, byte [xpos]
  shl bx, 1

  mov di, 0
  add di, ax
  add di, bx

  mov ax, cx
  stosw
  add byte [xpos], 1
  ret

dumpstring:
  mov ax, 0xb800  ; VGA video buffer again
  mov gs, ax      ; store start of VGA Buffer to extra-extra-extra-buffer (E->F->G)
  mov bx, 0x0000  ; set base-pointer to first cell of the video buffer, where each cell has
                  ; two bytes like <CHAR><COLOR ATTRIBUTE>
dumploop:
  mov ax, [gs:bx]      ; load first character
  mov word [reg16], ax ; provide character to printreg16
  and ah, 0xF       ; check if null terminator has been reached
  jz dumpdone          ; if so, we're done
  call printreg16      ; otherwise print the cell
  inc bx               ; go to next cell
  jmp dumploop         ; repeat
dumpdone:
  ret

printreg16:
   mov di, outstr16
   mov ax, [reg16]
   mov si, hexstr
   mov cx, 4   ;four places
hexloop:
   rol ax, 4   ;leftmost will
   mov bx, ax   ; become
   and bx, 0x0f   ; rightmost
   mov bl, [si + bx];index into hexstr
   mov [di], bl
   inc di
   dec cx
   jnz hexloop
 
   mov si, outstr16
   call sprint
 
   ret
 
;------------------------------------

xpos   db 0
ypos   db 0
bgcolor db 0x90
fgcolor db 0x7
hexstr   db '0123456789ABCDEF'
outstr16   db '0000', 0  ;register value string
reg16   dw    0  ; pass values to printreg16
msg   db "Let's boot something :)", 0
port60 dw 0

times 510-($-$$) db 0
db 0x55
db 0xAA
