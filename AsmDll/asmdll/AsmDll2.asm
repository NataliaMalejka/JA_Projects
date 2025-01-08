EXTERN CreateThread:PROC

.data

align 16

r2g byte 0, 2, 5, 1, 0, 2, 5, 1, 0, 2, 5, 1, 0, 2, 5, 1 
    byte 0, 2, 5, 1, 0, 2, 5, 1, 0, 2, 5, 1, 0, 2, 5, 1
    
onesw word 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
onesd dword 1,1,1,1,1,1,1,1
sib dword 80808080h, 80808080h, 80808080h, 80808080h
	dword 80808080h, 80808080h, 80808080h, 80808080h
shf1 byte 2,1,0,6,5,4,10,9,8,2,1,0,6,5,4,10
     byte 2,1,0,6,5,4,10,9,8,2,1,0,6,5,4,10

shf2 byte 0,1,2,3,4,5,6,7,8,9,10,11,5,6,7,8
     byte 0,1,2,3,4,5,6,7,8,9,10,11,5,6,7,8

m5 	byte -5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5
	byte -5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5

CHANNELS dword 4

imgWidth  dword 0
imgHeight dword 0

ptrFrom qword 0
ptrTo   qword 0

nRows    dword 0
firstRow dword 0

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

    mov rsi, ptrFrom
    mov rdi, ptrTo

    vmovapd ymm0, [rsi]
	vmovapd ymm1, [rsi + 4*rcx]
	vmovapd ymm2, [rsi + 8*rcx]
    vpaddb	ymm0, ymm0, byte ptr[sib]
    vmovapd ymm4, ymm0
    vmovapd ymm0, ymm1
    vmovapd ymm1, ymm4

    vpmaddubsw ymm3, ymm0, [r2g]
    vpmaddwd ymm3, ymm3, [onesw]
    vpsrld ymm3,ymm3, 3
    
    vpmaddubsw ymm4, ymm1, [r2g]
    vpmaddwd ymm4, ymm4, [onesw]
    vpsrld ymm4,ymm4, 3
    
    vpmaddubsw ymm5, ymm2, [r2g]
    vpmaddwd ymm5, ymm5, [onesw]
    vpsrld ymm5,ymm5, 3
    
    vpslld ymm3, ymm3, 8
    vpor ymm3, ymm3, ymm4
    vpslld ymm3, ymm3, 8
    vpor ymm3, ymm3, ymm5
    
	vpsubb ymm3, ymm3, byte ptr[sib]
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
	
	VPMOVMSKB rax, ymm8

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



threadFunction PROC

    ret

threadFunction ENDP


END
