; nasm reference: https://www.nasm.us/doc/nasmdoc3.html
%define LF 10
%define CR 13
%define EOF 0
%macro BiosPrint 1
                mov si, word %1
ch_loop:lodsb
   or al, al
   jz done
   mov ah, 0x0E
   int 0x10
   jmp ch_loop
done:
%endmacro
 
[ORG 0x7c00]
   xor ax, ax
   mov ds, ax
   cld
 
hang:
   BiosPrint msg
 
   jmp hang
 
msg   db 'Hello Raphael', CR, LF, EOF
 
   times 510-($-$$) db 0
   db 0x55
   db 0xAA
