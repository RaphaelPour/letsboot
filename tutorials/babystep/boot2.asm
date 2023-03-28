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

  mov si, msg     ; store string for sprint's lodsb in the proper register
  call sprint 

  call dumpstring

hang:
  jmp hang

dochar: 
  call cprint
sprint: 
  lodsb
  cmp al, 0
  jne dochar
  ;add byte [ypos], 1
  add byte [xpos], 2
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
times 510-($-$$) db 0
db 0x55
db 0xAA
