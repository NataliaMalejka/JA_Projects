;EXTERN CreateThread:PROC
;EXTERN Asm_medianFilter:PROC

.data

align 16

r2g 	byte 	0,2,5,1, 0,2,5,1, 0,2,5,1, 0,2,5,1 
		byte 	0,2,5,1, 0,2,5,1, 0,2,5,1, 0,2,5,1 
onesw 	word 	1,1,1,1, 1,1,1,1,  1,1,1,1, 1,1,1,1
onesd 	dword 	1,1,1,1, 1,1,1,1
sib 	dword 	80808080h, 80808080h, 80808080h, 80808080h
		dword 	80808080h, 80808080h, 80808080h, 80808080h
; shf1 byte 2,1,0,6,5,4,10,9,8,2,1,0,6,5,4,10
     ; byte 2,1,0,6,5,4,10,9,8,2,1,0,6,5,4,10
;8	6	5	4	2	1	0	10	9	8	6	5	4	2	1	0
shf1 	byte 	0,1,2,4,  5,6,8,9,  10,0,1,2, 4,5,6,8
		byte 	0,1,2,4,  5,6,8,9,  10,0,1,2, 4,5,6,8
     
shf2 	byte 	0,1,2,3, 4,5,6,7, 8,9,10,11, 5,6,7,8
		byte 	0,1,2,3, 4,5,6,7, 8,9,10,11, 5,6,7,8

m5 		byte 	-5,-5,-5,-5, -5,-5,-5,-5,  -5,-5,-5,-5, -5,-5,-5,-5
		byte 	-5,-5,-5,-5, -5,-5,-5,-5,  -5,-5,-5,-5, -5,-5,-5,-5

imgWidth  dword 0
imgHeight dword 0

ptrFrom qword 0
ptrTo   qword 0

nRows    dword 0
firstRow dword 0

lu dd 0, 0, 0, 0, 0

.code

Asm_medianFilter PROC
; prolog funkcji
    push rbp
    mov rbp, rsp

; zapis parametrów do zmiennych globalnych
    mov imgWidth, ecx
    mov imgHeight, edx
    mov ptrFrom, r8
    mov ptrTo, r9
    mov eax, dword ptr [rsp + 30h]
    mov nRows, eax
    mov eax, dword ptr [rsp + 38h]
    mov firstRow, eax


; r10 - iterator y
; r11 - iterator x
; r12 - iterator channel

    push rsi
    push rdi
    push r10
    push r11
    push r12


	lea r11, lu
	xor rax, rax

    mov ax, cx
    shl rax, 17
    add ax, cx
    shl rax, 16
    mov [r11], rax
    add rax, qword ptr[onesw]
    mov [r11+6], rax
    add rax, qword ptr[onesw]
    mov [r11+12], rax


    mov rsi, ptrFrom
    mov rdi, ptrTo

	vmovupd ymm0, [rsi]
	
	vpxor 	ymm15, ymm15, ymm15
	vpaddb 	ymm15, ymm15, [r2g]
	vpxor 	ymm14, ymm14, ymm14
	vpaddw 	ymm14, ymm14, [onesw]
	
	vmovupd ymm2, [rsi + 8*rcx]
	
	vpxor 	ymm13, ymm13, ymm13
	vpaddd 	ymm13, ymm13, [sib]
	
	; vpxor 	ymm1, ymm1, ymm1
	; vpaddb 	ymm1, ymm1, []
  
    vpmaddubsw 	ymm0, ymm0, ymm15 ;rgb2gray
	vpmaddwd 	ymm0, ymm0, ymm14	 ;suma
	
	
	vmovupd 	ymm1, [rsi + 4*rcx]
		
	vpmaddubsw 	ymm2, ymm2, ymm15
    vpmaddwd 	ymm2, ymm2, ymm14
	vpslld 		ymm2, ymm2, 16	
	vpor 		ymm0, ymm0, ymm2
	vpsrlw 		ymm0, ymm0, 3			 ;div 8 (suma wag)
	
	vpmaddubsw 	ymm1, ymm1, ymm15
    vpmaddwd 	ymm1, ymm1, ymm14
	vpsrlw 		ymm1, ymm1, 3
	vpsllw 		ymm1, ymm1, 8
    vpor 		ymm0, ymm0, ymm1
    
	
	;vpsubb ymm3, ymm3, byte ptr[sib]
	vpaddb	ymm3, ymm0, ymm13	;-128
    vpshufb ymm0, ymm3, [shf1]
    
	vpalignr ymm1, ymm0, ymm0, 1
    vpshufb ymm0, ymm0, [shf2]
    vpcmpgtb ymm6, ymm0, ymm1
	vpcmpgtb ymm7, ymm1, ymm0
	vpaddb	ymm8, ymm8, ymm6
	vpaddb	ymm9, ymm9, ymm7
	vpalignr ymm6, ymm6, ymm6, 15
	vpalignr ymm7, ymm7, ymm7, 15
	vpaddb	ymm8, ymm8, ymm7
	vpaddb	ymm9, ymm9, ymm6
	
	vpalignr ymm1, ymm1, ymm1, 1
    vpcmpgtb ymm6, ymm0, ymm1
	vpcmpgtb ymm7, ymm1, ymm0
	vpaddb	ymm8, ymm8, ymm6
	vpaddb	ymm9, ymm9, ymm7
	vpalignr ymm6, ymm6, ymm6, 14
	vpalignr ymm7, ymm7, ymm7, 14
	vpaddb	ymm8, ymm8, ymm7
	vpaddb	ymm9, ymm9, ymm6
	
	vpalignr ymm1, ymm1, ymm1, 1
    vpcmpgtb ymm6, ymm0, ymm1
	vpcmpgtb ymm7, ymm1, ymm0
	vpaddb	ymm8, ymm8, ymm6
	vpaddb	ymm9, ymm9, ymm7
	vpalignr ymm6, ymm6, ymm6, 13
	vpalignr ymm7, ymm7, ymm7, 13
	vpaddb	ymm8, ymm8, ymm7
	vpaddb	ymm9, ymm9, ymm6

	vpalignr ymm1, ymm1, ymm1, 1
    vpcmpgtb ymm6, ymm0, ymm1
	vpcmpgtb ymm7, ymm1, ymm0
	vpaddb	ymm8, ymm8, ymm6
	vpaddb	ymm9, ymm9, ymm7
	vpalignr ymm6, ymm6, ymm6, 12
	vpalignr ymm7, ymm7, ymm7, 12
	vpaddb	ymm8, ymm8, ymm7
	vpaddb	ymm9, ymm9, ymm6
	
	
	vpcmpgtb ymm8, ymm8, [m5]
	vpcmpgtb ymm9, ymm9, [m5]
	
	vpand ymm8, ymm8, ymm9
	
	VPMOVMSKB r10, ymm8
	
	bsf rax, r10
    mov ax, word ptr[r11+2*rax]
    mov eax, dword ptr[rsi+4*rax]
    mov dword ptr[rdi], eax
	
	add rsi, 4*4
	add rdi, 4*4
	
	shr r10, 16
	bsf rax, r10
    mov ax, word ptr[r11+2*rax]
    mov eax, dword ptr[rsi+4*rax]
    mov dword ptr[rdi], eax

    ; mov r10d, nRows
; yLoop:
    ; dec r10d

    ; add r10d, firstRow        ; offset o nRows*ID w¹tku


    ; mov r11d, imgWidth
    ; xLoop:
        ; dec r11d

        ; mov r12d, CHANNELS
        ; channelsLoop:
            ; dec r12d

            ; wyznaczenie indeksu tablicy
            ; (y * w + x) * NUM_CHANNELS + channel
            ; mov eax, r10d
            ; imul imgWidth
            ; add eax, r11d
            ; imul CHANNELS
            ; add eax, r12d
            ; mov r8d, eax  ; r8d = index w buforze

            ; przetworzenie subpiksela
            ; mov al, [rsi+r8]
            ; and al, 011000000b
            ; mov [rdi+r8], al

            ; cmp r12d, 0
            ; jne channelsLoop      ; koniec pêtli channels

        ; cmp r11d, 0
        ; jne xLoop             ; koniec pêtli x

    ; sub r10d, firstRow        ; cofniêcie offsetu

    ; cmp r10d, 0
    ; jne yLoop                 ; koniec pêtli y

    pop r12
    pop r11
    pop r10
    pop rdi
    pop rsi


; epilog funkcji
    mov rsp, rbp
    pop rbp
    ret
Asm_medianFilter ENDP




END
