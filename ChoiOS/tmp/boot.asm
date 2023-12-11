ORG 0 ; originate from this address.
BITS 16 ; specify bit 16

_start:
	JMP short start
	NOP
 times 33 DB 0


start:
	JMP 0x7c0:step2

step2:
	CLI ; clear interrupts
	MOV ax, 0x7c0
	MOV ds, ax
	MOV es, ax
	MOV ax, 0x00
	MOV ss, ax
	MOV sp, 0x7c00
	STI ; start interrupt
	
	MOV ah, 2 ; READ SECTOR COMMAND
	MOV al, 1 ; ONE SECTOR TO READ
	MOV ch, 0 ; Cylinder low eight bits
	MOV cl, 2 ; READ sector two
	MOV dh, 0 ; HEAD NUMBER
	MOV bx, buffer
	INT 0x13
	JC error

	MOV si, buffer
	CALL print
	JMP $

error:
	MOV si, error_message
	CALL print
	JMP $

print:
	MOV bx, 0
	
.loop:
	lodsb ; lodsb loads char as its called
	CMP al, 0
	JE .done
	CALL print_char
	JMP .loop

.done:
	RET

print_char: ; This line sets the AH register to 0Eh, which is a function code for the BIOS interrupt INT 0x10. This par		   
			; ticular function is used for displaying a character on the screen in teletype (TTY) mode.
	MOV ah, 0eh ; equivalent to eax register but higher 8 bit
	INT 0x10 ; interrupt : callign bios routine
	RET

error_message: DB 'Failed to load sector',0

times 510-($ - $$) db 0 ; we need to fill atleast 510 bytes
dw 0xAA55 ; intel machine is little endian the bytes get flipped

buffer:
