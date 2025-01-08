EXTERN CreateThread:PROC

.data
CHANNELS dword 4

imgWidth  dword 0
imgHeight dword 0

ptrFrom qword 0
ptrTo	qword 0

nRows    dword 0
firstRow dword 0

.code

Asm_medianFilter PROC
; prolog funkcji
	push rbp ;zapisuje aktualn¹ wartoœæ rejestru rbp na stosie
	mov rbp, rsp ;kopiuje bie¿¹cy wskaŸnik stosu (rsp) do rejestru rbp

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

	mov rsi, ptrFrom ;wskaznik na poczatek danych wejsc
	mov rdi, ptrTo ;wskaznik na poczatek wyj

	mov r10d, nRows ;r10 na liczbe wierszy do przetworzenia
yLoop:
	dec r10d ;zmniejszamy aby przejsc do nastepnego wiersza

	add r10d, firstRow		; offset o nRows*ID w¹tku
	;Dodaje firstRow do r10d, co pozwala na przesuniêcie indeksu, aby 
	;ka¿dy w¹tek móg³ zacz¹æ przetwarzanie od swojego wyznaczonego wiersza.

	mov r11d, imgWidth
	xLoop:
		dec r11d

		mov r12d, CHANNELS ;Ustawia r12d na liczbê kana³ów (CHANNELS) i rozpoczyna pêtlê channels
		channelsLoop:
			dec r12d

			; wyznaczenie indeksu tablicy
			; (y * w + x) * NUM_CHANNELS + channel
			mov eax, r10d ;Przenosi wartoœæ r10d (czyli wspó³rzêdn¹ y dla bie¿¹cego wiersza) do rejestru eax 
			imul imgWidth ; mnozy szerokosc razy eax czyli y
			add eax, r11d ;Dodaje do eax wartoœæ r11d (wspó³rzêdn¹ x), uzyskuj¹c przesuniêcie piksela w bie¿¹cym wierszu
			imul CHANNELS ; aby uzyskaæ ca³kowite przesuniêcie w buforze dla danego piksela i kana³u.
			add eax, r12d ; aby uzyskaæ przesuniêcie do konkretnego subpiksela (czyli wartoœci kana³u) w obrêbie tego piksela.
			mov r8d, eax	; r8d = index w buforze

			; przetworzenie subpiksela
			mov al, [rsi+r8]
			and al, 011000000b
			mov [rdi+r8], al ;Ta operacja zapisuje przetworzony subpiksel (kana³ koloru) do odpowiedniego miejsca w buforze wyjœciowym.

			cmp r12d, 0
			jne channelsLoop		; koniec pêtli channels

		cmp r11d, 0
		jne xLoop				; koniec pêtli x

	sub r10d, firstRow		; cofniêcie offsetu

	cmp r10d, 0
	jne yLoop					; koniec pêtli y

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
