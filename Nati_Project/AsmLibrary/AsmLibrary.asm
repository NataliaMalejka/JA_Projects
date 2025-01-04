PUBLIC filterAsm


.data
NUM_CHANNELS DWORD 3
_WIDTH  DWORD 0
_HEIGHT DWORD 0
_BUF_FROM QWORD 0
_BUF_TO   QWORD 0
_STRIP_HEIGHT DWORD 0
_START_ROW    DWORD 0

.code

filterAsm PROC
	; parameters
	; rcx - width
	; rdx - height
	; r8 - input image
	; r9 - output image
	; r10 - currentHeight
	; [rsp+30h] - strip height
	; [rsp+38h] - start row

	push rbp
	mov rbp, rsp

	mov _WIDTH, ecx
	mov _HEIGHT, edx
	mov _BUF_FROM, r8
	mov _BUF_TO, r9
	mov eax, dword ptr [rsp + 30h]
	mov _STRIP_HEIGHT, eax
	mov eax, dword ptr [rsp + 38h]
	mov _START_ROW, eax

	push rsi
	push rdi
	push r15

	mov rsi, _BUF_FROM
	mov rdi, _BUF_TO
	mov r10d, _START_ROW

	mov ebx, _STRIP_HEIGHT	; rbx - number of rows to process
	add ebx, r10d

yLoopStart:
	dec ebx

	cmp ebx, r10d         
    jl endYLoop   

	mov ecx, _WIDTH

	xLoopStart:
		push r10
		dec ecx   
		mov r9d, NUM_CHANNELS

				cLoopStart:
					dec r9d

					xor r14d, r14d            ; r14d = sum = 0
					xor r15d, r15d            ; r15d = count = 0

					mov rax, -1

					dyLoopStart:
						mov r11, -1

						dxLoopStart:
							; Obliczanie rx = x + dx
							mov r12d, ecx           ; r12d = x
							add r12d, r11d          ; r12d = x + dx (rx)

							; Sprawdzenie warunku rx < 0 || rx >= _WIDTH
							cmp r12d, 0             ; rx < 0?
							jl skipPixel            ; Skocz jeœli rx < 0
							cmp r12d, _WIDTH        ; rx >= _WIDTH?
							jge skipPixel           ; Skocz jeœli rx >= _WIDTH

							; Obliczanie ry = y + dy
							mov r13d, ebx           ; r13d = y
							add r13d, eax           ; r13d = y + dy (ry)

							; Sprawdzenie warunku ry < 0 || ry >= _HEIGHT
							cmp r13d, 0             ; ry < 0?
							jl skipPixel            ; Skocz jeœli ry < 0
							cmp r13d, _HEIGHT       ; ry >= _HEIGHT?
							jge skipPixel           ; Skocz jeœli ry >= _HEIGHT


							; Zwiêkszenie count
							inc r15d           ; count++

							; Obliczenie indeksu fromIndex = (ry * w + rx) * NUM_CHANNELS + channel							
							mov r10d, r13d     ; r10d = ry
							imul r10d, _WIDTH  ; r10d = ry * w
							add r10d, r12d     ; r10d = ry * w + rx
							imul r10d, NUM_CHANNELS ; r10d = (ry * w + rx) * NUM_CHANNELS
							add r10d, r9d      ; r10d = (ry * w + rx) * NUM_CHANNELS + channel

							; Dodanie wartoœci do sum
							movzx r8d, byte ptr [rsi + r10] ; r8d = from[fromIndex]
							add r14d, r8d     ; sum += from[fromIndex]

						skipPixel:
							inc r11
							cmp r11, 1
							jle dxLoopStart

						inc rax              ; Zwieksz dy
						cmp rax, 1
						jle dyLoopStart


					; Obliczanie indeksu dla kana³u koloru
					; (y * w + x) * NUM_CHANNELS + channel
					mov r10d, ebx
					imul r10d, _WIDTH
					add r10d, ecx
					imul r10d, NUM_CHANNELS
					add r10d, r9d  

					 ; Obliczenie sum / count i zapis do bufora wyjœciowego
					xor edx, edx            ; Wyzerowanie edx (dla idiv)
					cmp r15d, 0
					             ; Sprawdzenie czy count > 0
					je skipDivision         ; Skocz, jeœli count == 0 (unikaj dzielenia przez 0)
					push rax
					mov eax, r14d           ; eax = sum
					idiv r15d               ; eax = sum / count
					mov r14d, eax
					pop rax

				skipDivision:
					mov byte ptr [rdi + r10], r14b ; Zapisanie wyniku do bufora to			
					
				cmp r9d, 0
				jne cLoopStart

		pop r10
		cmp ecx, 0
		jne xLoopStart
	
	cmp ebx, 0
	jne yLoopStart

endYLoop:
	pop r15
	pop rdi
	pop rsi

	mov rsp, rbp
	pop rbp
	ret
	
filterAsm ENDP

END