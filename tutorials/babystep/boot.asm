; nasm reference: https://www.nasm.us/doc/nasmdoc3.html
; interrupt reference: https://en.wikipedia.org/wiki/BIOS_interrupt_call#Interrupt_table
%define LF 10
%define CR 13
%define EOF 0
%macro Print 1 ; define macro with one argument
             mov si, word %1 ; push argument to si
next_char:lodsb    ; load next char of string in si
   or al, al       ; check if null terminator reached
   jz done         ; finish print method if null terminator reached
	 mov bl, 2 
   mov ah, 0x0E    ; select 'Write character in TTY Mode' function of int 10h 
   int 0x10        ; call interrupt
   jmp next_char   ; process next char
done:
%endmacro

[ORG 0x7c00]
   xor ax, ax
   mov ds, ax
   cld
 
   Print msg
hang:
   jmp hang
 
msg   db 'Hello Raphael', CR, LF, EOF
 
   times 510-($-$$) db 0
   db 0x55
   db 0xAA
