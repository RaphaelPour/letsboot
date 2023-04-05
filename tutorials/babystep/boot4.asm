; babystep 6+7

[ORG 0x7c00]
  xor ax, ax      ; clear ax by xoring it with itself
  mov ds, ax      ; initialize data segment register
  
                  ; initialize stack
  mov ss, ax      ; initialize stack segment register
  mov sp, 0x9c00  ; set stack pointer to bottom of stack far behind the bootloader
  
  cli	            ; disable all interrupts
	push ds         ; save the real mode data segment to the stack

	lgdt [gdtinfo]  ; load the Global Descriptor Table

	mov eax, cr0    ; enter the protected mode
	or al, 1        ; by setting the protected-mode-flag
	mov cr0, eax

	mov bx, 0x08    ; select entry #1 and skip entry #0
	mov ds, bx      ; 
	
	and al, 0xFE    ; go back to real mode
	mov cr0, eax    ; by toggeling the protection mode bit again

	pop ds          ; restore real mode data segment
	sti             ; enable interrupts again

	mov bx, 0x0f01
	mov eax, 0x0b8000
	mov word [ds:eax], bx

	jmp $

	gdtinfo:               ; define the Global Descriptor Table
		dw gdt_end - gdt - 1 ; address to the last byte in the table
		dd gdt               ; table starts here

	gdt  dd 0,0  ; first entry is not in use
	flatdesc   db 0xff, 0xff, 0, 0, 0, 10010010b, 11001111b, 0
	gdt_end:
	

times 510-($-$$) db 0
db 0x55
db 0xAA
