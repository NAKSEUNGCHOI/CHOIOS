ORG 0x7c00 ; originate from this address.
BITS 16 ; specify bit 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

_start:
	JMP short start
	NOP
 times 33 DB 0

start:
	JMP 0:step2

step2:
	CLI ; clear interrupts
	MOV ax, 0x00
	MOV ds, ax
	MOV es, ax
	MOV ss, ax
	MOV sp, 0x7c00
	STI ; start interrupt

; this can be found on the website.
.load_protected:
    CLI
    lgdt[gdt_descriptor]
    MOV eax, cr0
    OR eax, 0x1
    MOV cr0, eax
    jmp CODE_SEG:load32

; GDT
gdt_start:

gdt_null:
    DD 0x0
    DD 0x0
; offset 0x08
gdt_code:     ; CS SHOULD POINT TO THIS
    DW 0xffff ; Segment limit first 0-15 bit
    DW 0        ; BASE FIRST 0 - 15 BITS
    DB 0        ; BASE 16 - 23 BITS
    DB 0x9a     ; ACCESS BYTE
    DB 11001111b ; HIGHT 4 BIT FLAGS AND THE LOWER 4 BIT FLAGS
    DB 0        ; BASE 24 - 31 BITS

; offset 0x10
gdt_data:       ; DS, SS, ES, FS, GS
    DW 0xffff ; Segment limit first 0-15 bit
    DW 0        ; BASE FIRST 0 - 15 BITS
    DB 0        ; BASE 16 - 23 BITS
    DB 0x92     ; ACCESS BYTE
    DB 11001111b ; HIGHT 4 BIT FLAGS AND THE LOWER 4 BIT FLAGS
    DB 0        ; BASE 24 - 31 BITS

gdt_end:

gdt_descriptor:
    DW gdt_end - gdt_start - 1
    DD gdt_start

[BITS 32]
load32:
    MOV eax, 1      ; represents the starting sector that we wanna load from. 0 is our boot loader
    MOV ecx, 100    ; number of sectors we want to load
    MOV edi, 0x0100000 ; 1MB address we want to load them into
    CALL ata_lba_read
    jmp CODE_SEG:0x0100000

ata_lba_read:
    MOV ebx, eax, ; backup the LBA
    
    ; SEND THE HIGHEST 8 BITS OF THE LBA TO HARD DISK CONTROLLER
    SHR eax, 24
    OR eax, 0xE0    ;   SELECT THE MASTER DRIVE
    MOV dx, 0x1F6
    OUT dx, al  ; with this out instruction, we're talking with the bus in the motherboard.
    ; FINISH SENDING THE HIGHEST 8 BITS OF THE LBA

    ; SEND THE TOTAL SECTORS TO READ
    MOV eax, ecx
    MOV dx, 0x1F2
    OUT dx, al
    ; FINISHED SENDING THE TOTAL SECTORS TO READ

    ; SEND MORE BITS OF THE LBA
    MOV eax, ebx    ; RESTORE THE BACKUP LBA
    MOV dx, 0x1F3
    OUT dx, al
    ; FINISHED SENDING MORE BITS OF THE LBA
    
    ; SEND MORE BITS OF THE LBA
    MOV dx, 0x1F4
    MOV eax, ebx ; RESTORE THE BACKUP LBA
    SHR eax, 8
    OUT dx, al
    ; FINISHED SENDING MORE BITS OF THE LBA

    ; SENDING UPPER 16 BITS OF THE LBA
    MOV dx, 0x1F5
    MOV eax, ebx
    SHR eax, 16
    OUT dx, al
    ; FINISHED SENDING UPPER 16 BITS OF THE LBA

    MOV dx, 0x1F7
    MOV al, 0x20
    OUT dx, al

    ; READ ALL SECTORS INTO MEMORY
.next_sector:
    PUSH ecx

; CHECKING IF WE NEED TO READ
.try_again:
    MOV dx, 0x1F7
    IN al, dx
    TEST al, 8
    jz .try_again

; WE NEED TO READ 256 WORDS AT A TIME
    MOV ecx, 256
    MOV dx, 0x1F0
    REP insw ; input word from I/O port specified in DX into memory location specified in ES:(E)DI
             ; READ 256 words which is 512 bytes = one sector
    POP ecx
    loop .next_sector
    ; END OF READING SECTORS INTO MEMORY
    ret



times 510-($ - $$) db 0 ; we need to fill atleast 510 bytes
dw 0xAA55 ; intel machine is little endian the bytes get flipped

