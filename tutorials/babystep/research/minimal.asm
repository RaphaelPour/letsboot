[ORG 0x7c00]
hang:
	jmp hang

times 510-($-$$) db 0
db 0x55
db 0xAA
