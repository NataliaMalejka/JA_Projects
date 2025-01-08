.data

align 16

r2g 	byte 	0,2,5,1, 0,2,5,1, 0,2,5,1, 0,2,5,1 
		byte 	0,2,5,1, 0,2,5,1, 0,2,5,1, 0,2,5,1 
onesw 	word 	1,1,1,1, 1,1,1,1,  1,1,1,1, 1,1,1,1

sib 	dword 	80808080h, 80808080h, 80808080h, 80808080h
		dword 	80808080h, 80808080h, 80808080h, 80808080h

shf1 	byte 	0,1,2,4,  5,6,8,9,  10,0,1,2, 4,5,6,8
		byte 	0,1,2,4,  5,6,8,9,  10,0,1,2, 4,5,6,8
     
shf2 	byte 	0,1,2,3, 4,5,6,7, 8,9,10,11, 5,6,7,8
		byte 	0,1,2,3, 4,5,6,7, 8,9,10,11, 5,6,7,8

m5 		byte 	-5,-5,-5,-5, -5,-5,-5,-5,  -5,-5,-5,-5, -5,-5,-5,-5
		byte 	-5,-5,-5,-5, -5,-5,-5,-5,  -5,-5,-5,-5, -5,-5,-5,-5
;-5 to w praktyce zakodowany próg dla mediany w macierzy 3×3 (wartoœæ odpowiadaj¹ca 5. pozycji w sortowaniu).

imgHeight dword 0

lookup dd 0, 0, 0, 0, 0
; jest u¿ywana do szybkiego odnajdywania adres piksela jeden z 9
.code

Asm_medianFilter PROC
; prolog funkcji
    push rbp							;zapisz na stosie zeby potem odzyskac
    mov rbp, rsp
    
	push rsi
    push rdi
	push r12
	
; zapis parametrów do zmiennych globalnych
	mov imgHeight, edx

	xor r12, r12
    mov r12d, dword ptr [rbp + 30h]

	
; set lookup table
	lea r11, [lookup]						;;adres bazowy lu do r11
	xor rax, rax

    mov ax, cx							;cx znajduje siê teraz w dolnych 16 bitach rejestru rax
    shl rax, 17							;w lewo
    add ax, cx							;dodaje wartoœæ z rejestru cx do dolnej czêœci rax
    shl rax, 16							;lewo
    mov [r11], rax						;do pierszego ele lu
    add rax, qword ptr[onesw]
    mov [r11+6], rax					; 2 lu
    add rax, qword ptr[onesw]
    mov [r11+12], rax					;3 lu

; set starting point
    mov rsi, r8
    mov rdi, r9
	
	vmovupd ymm0, [rsi]					;wczytanie bloku pamieci

	lea rax, [r2g]
	vmovupd ymm15, [rax + 0*32] ;r2g - wagi kolorów do konwersji RGB na odcienie szaroœci
	vmovupd ymm14, [rax + 1*32] ;onesw - jedynki wagi do sumowania RGB
	vmovupd ymm13, [rax + 2*32] ;sib - (-128) do zamiany unsigned byte na signed byte dla vpcmpgtb
	vmovupd ymm11, [rax + 3*32] ;shf1 - maska dla vpshufb ustawia 9 pixeli w odpowiedniej kolejnosci
	vmovupd ymm12, [rax + 4*32] ;shf2 - dodatkowa maska dla vpshufb
	vmovupd ymm10, [rax + 5*32] ;m5	- (-5) potrzebne do wyznaczenia mediany

;------------------------------------

block:	
	vmovupd ymm1, [rsi + 4*rcx]
	vpmaddubsw 	ymm0, ymm0, ymm15 		;rgb2gray ;wykonuje mno¿enie wartoœci nastêpnie sumuje wyniki
	vpmaddwd 	ymm0, ymm0, ymm14	 	;suma
	vpsrlw 		ymm0, ymm0, 3			;div 8 (suma wag)
	
	vmovupd ymm2, [rsi + 8*rcx]			;wczytujemy kolejny rejestr
	
	vpmaddubsw 	ymm1, ymm1, ymm15
    vpmaddwd 	ymm1, ymm1, ymm14
	vpsrlw 		ymm1, ymm1, 3
	vpsllw 		ymm1, ymm1, 8			;przesuniecie zeby to zmiescic
    vpor 		ymm0, ymm0, ymm1		;laczenie zawartosci z dwoch przetworzonych blokow

    
median:		
	
	vpmaddubsw 	ymm2, ymm2, ymm15		;Przeprowadza konwersjê pikseli RGB w ymm2 na odcienie szarosci

    vpmaddwd 	ymm2, ymm2, ymm14		; Sumuje wartoœci poœrednie odcieni szaroœci, aby uzyskaæ ich wa¿on¹ sumê.

	vpsrlw 		ymm2, ymm2, 3			;div 8

	vpslld 		ymm2, ymm2, 16			; 16 bitów w lewo.

	vpor 		ymm0, ymm0, ymm2		;laczenie danych

	
	vpaddb	ymm3, ymm0, ymm13		;-128 bo centrowanie wartosci;przesuwa dane w ymm0 o wartoœæ równ¹ ymm13
    vpshufb ymm0, ymm3, ymm11		;przestawienie pozycji wedlug masek w shufle

; ------------ pix 1-9
  
	vpalignr ymm1, ymm0, ymm0, 1		;o 1 bajt w prawo ;//////////////
    vpshufb ymm0, ymm0, ymm12			; sortowania okna dla mediany;///////////
    
	vpcmpgtb ymm6, ymm0, ymm1			;(czy ymm0 > ymm1)
	vpcmpgtb ymm7, ymm1, ymm0			;(czy ymm1 > ymm0)
	vmovdqa	ymm8,  ymm6	;sumuje wyniki porównañ z poprz  ednich kroków, aby uzyskaæ liczbê elementów, w których ymm0 > ymm1.
	vmovdqa	ymm9, ymm7	;sumuj¹c liczbê przypadków, w których ymm1 > ymm0.
	vpalignr ymm6, ymm6, ymm6, 15		;w prawo o 15 po lewej 0
	vpalignr ymm7, ymm7, ymm7, 15
	vpaddb	ymm8, ymm8, ymm7			;sumowanie liczby przypadków, w których ymm1 > ymm0 w odpowiednich przesuniêtych pozycjach.
	vpaddb	ymm9, ymm9, ymm6
	
	vpalignr ymm1, ymm1, ymm1, 1		;w prawo o 1 bajt, tak jak w pierwszym kroku
    vpcmpgtb ymm6, ymm0, ymm1
	vpcmpgtb ymm7, ymm1, ymm0
	vpaddb	ymm8, ymm8, ymm6
	vpaddb	ymm9, ymm9, ymm7
	vpalignr ymm6, ymm6, ymm6, 14 ;//////////////////////////////
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
	
	
	vpcmpgtb ymm8, ymm8, ymm10		;czy wartosci > od progu mediany
	vpcmpgtb ymm9, ymm9, ymm10		;czy wartosci > od progu mediany
	
	vpand ymm8, ymm8, ymm9			;sumowanie and
	
	VPMOVMSKB r10, ymm8				;Z ka¿dego bajtu w ymm8 bierze najbardziej znacz¹cy bit (MSB) i tworzy z nich maskê w r10

	
	bsf rax, r10					;szuka pierwszego ustawionego bitu w rejestrze r10 i zapisuje jego pozycjê w rejestrze rax.
    mov ax, word ptr[r11+2*rax]		;Mapuje znalezion¹ pozycjê w masce na konkretn¹ wartoœæ w tablicy

    mov eax, dword ptr[rsi+4*rax]	;Wykorzystuje poprzednio zmapowan¹ pozycjê, aby odczytaæ odpowiedni¹ wartoœæ z tablicy

    mov dword ptr[rdi], eax			;Przypisuje wynik operacji do bufora wyjœciowego
	
	shr r10, 16						;przesowa o 16 prawo

;Kolejne instrukcje dzia³aj¹ na drugiej czêœci maski
	bsf rax, r10
    mov ax, word ptr[r11+2*rax]
    mov eax, dword ptr[rsi+4*rax + 16]
    mov dword ptr[rdi + 16], eax

; ---------------------------
; ------------ pix 4-12
	
	
	vmovdqa	ymm0, ymm3	
	vpalignr ymm0, ymm0, ymm0, 4
	vpshufb ymm0, ymm0, ymm11
	
	vpalignr ymm1, ymm0, ymm0, 1
    vpshufb ymm0, ymm0, ymm12
    
	vpcmpgtb ymm6, ymm0, ymm1
	vpcmpgtb ymm7, ymm1, ymm0
	vmovdqa	ymm8, ymm6
	vmovdqa	ymm9, ymm7
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
	
	
	vpcmpgtb ymm8, ymm8, ymm10
	vpcmpgtb ymm9, ymm9, ymm10
	
	vpand ymm8, ymm8, ymm9
	
	VPMOVMSKB r10, ymm8
	
	bsf rax, r10
    mov ax, word ptr[r11+2*rax]
    mov eax, dword ptr[rsi+4*rax +4]
    mov dword ptr[rdi +4], eax
	
	shr r10, 16
	bsf rax, r10
    mov ax, word ptr[r11+2*rax]
    mov eax, dword ptr[rsi+4*rax + 20]
    mov dword ptr[rdi + 20], eax

; ---------------------------
; ---------------------------
; ------------ pix 7-15
	
	
	vpermq	ymm4, ymm3, 99h
	vpshufd	xmm5, xmm4, 39h
	vpblendd ymm4, ymm4, ymm5, 0fh
	
	vpshufb ymm0, ymm4, ymm11
	
	vpalignr ymm1, ymm0, ymm0, 1
    vpshufb ymm0, ymm0, ymm12
    
	vpcmpgtb ymm6, ymm0, ymm1
	vpcmpgtb ymm7, ymm1, ymm0
	vmovdqa	ymm8, ymm6           ;kopiujemy pierwsza wartosc z ymm6 do ymm8
	vmovdqa	ymm9, ymm7
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
	
	
	vpcmpgtb ymm8, ymm8, ymm10
	vpcmpgtb ymm9, ymm9, ymm10
	
	vpand ymm8, ymm8, ymm9
	
	VPMOVMSKB r10, ymm8
	
	bsf rax, r10
    mov ax, word ptr[r11+2*rax]
    mov eax, dword ptr[rsi+4*rax +12]
    mov dword ptr[rdi +12], eax
	
	shr r10, 16
	bsf rax, r10
    mov ax, word ptr[r11+2*rax]
    mov eax, dword ptr[rsi+4*rax + 8]
    mov dword ptr[rdi + 8], eax

; -- 6 pix done, time to next row	
	
	dec rdx
	jz 	next_block ; 8px column block done
	
	lea rsi, [rsi + 4*rcx]
	vmovupd ymm2, [rsi + 8*rcx]
	lea rdi, [rdi + 4*rcx]

	vpsubb ymm0, ymm3, ymm13
	vpsrld ymm0, ymm0, 8

	jmp median
	

next_block:
	dec r12
	jz 	finito
	vmovupd ymm0, [r8 + 24]					;Wczytuje dane z pamiêci
	add r8, 24								;o 24 bajty w przód (na kolejny blok w pamiêci obrazu).
	add r9, 24
    mov rsi, r8								;rsi teraz wskazuje na nowy blok danych obrazu.
    mov rdi, r9								;rdi teraz wskazuje na nowy docelowy blok.  
	mov edx, imgHeight
	
	jmp block

finito:
	
	pop r12
    pop rdi
    pop rsi


; epilog funkcji
    mov rsp, rbp
    pop rbp
    ret
Asm_medianFilter ENDP


END
