bits 16
org 0x7c00

boot:	
	mov ax, 0x3
	int 0x10

	cli
    xor ax,ax
    mov ds,ax
	lgdt [gdtr]

	mov eax, cr0
	or eax,0x1
	mov cr0, eax

	jmp CODE_SEG:boot2   ;cелектор:смещение

align 8
gdt_start:
	dq 0x0
gdt_code:
	dw 0xFFFF
	dw 0x0
	db 0x0
	db 10011010b
	db 11001111b
	db 0x0
gdt_data:
	dw 0xFFFF
	dw 0x0
	db 0x0
	db 10010010b
	db 11001111b
	db 0x0
gdt_end:
gdtr:
	dw gdt_end - gdt_start
	dd gdt_start

CODE_SEG equ 0x08  
DATA_SEG equ 0x10

bits 32
boot2:
    
	mov ax, DATA_SEG
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax

isA20_on:
    pushad
    mov edi,0x112345
    mov esi,0x012345
    mov [edi],esi
    mov [edi],edi
    cmpsd
    popad
    jne A20_on
    jmp A20_off

A20_off:    
    in al,92h
    or al,2
    out 92h,al
    jmp A20_on


A20_on:
	mov esi,hello
	mov ebx,0xb8000   ;color video descr
    or ah,0x0F ;color
 .loop:
	lodsb
	or al,al
	jz halt	
	mov word [ebx], ax
	add ebx,2
	jmp .loop
halt:	
    jmp $  

hello db "A20 on. Hello protected mode!",0


times 510 - ($-$$) db 0
dw 0xaa55
