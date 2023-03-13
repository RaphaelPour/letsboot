; nasm reference: https://www.nasm.us/doc/nasmdoc3.html
; interrupt reference: https://en.wikipedia.org/wiki/BIOS_interrupt_call#Interrupt_table
%define LF 10 ; line feed
%define CR 13 ; cariage return
%define NULL 0 ; null terminator
%define BG_COLOR 9 ; royal blue

[ORG 0x7c00]
   xor ax, ax ; clear ax by xoring it with itself
   mov ds, ax ; move ax to the datasegment register
   cld        ; clear direction flag, that decides in which direction
              ; e.g. loadsb should load the memory (++ as usual or -- for
              ; reading backwards)

   mov bl, BG_COLOR  ; store the background color in the proper register
                     ; for int10h with function 0xB
   call set_bg_color

   mov si, msg  ; store msg pointer into the proper register for the
                ; int10h with function 0xE
   call println

hang:
   jmp hang
 
set_bg_color:
   mov ah, 0x0B    ; select 'set background' function
   mov bh, 0x0     ; select 'set background' function
   int 0x10        ; call interrupt
   ret

print:
   lodsb           ; load next byte from 
   or al, al       ; set zero flag if null terminator has been reached
   jz done         ; finish print method if null terminator reached (zero flag reached)
   mov bl, 1
   mov ah, 0x0E    ; select 'Write character in TTY Mode' function of int 10h 
   int 0x10        ; call interrupt
   jmp print       ; process next char
done:
   ret

println:
   call print
   mov si, newline
   call print
   ret

msg     db 'Hello Raphael!', NULL
newline db CR, LF
 
   times 510-($-$$) db 0
   db 0x55
   db 0xAA
