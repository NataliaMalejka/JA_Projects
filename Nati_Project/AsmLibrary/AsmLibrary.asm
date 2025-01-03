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
		dec ecx
		mov rax, -1   

		dyLoopStart:
			mov r11, -1

			dxLoopStart:
				mov r9d, NUM_CHANNELS

				cLoopStart:
					dec r9d

					; Obliczanie indeksu dla kana³u koloru
					; (y * w + x) * NUM_CHANNELS + channel
					mov r12d, ebx
					imul r12d, _WIDTH
					add r12d, ecx
					imul r12d, NUM_CHANNELS
					add r12d, r9d  
					mov r15d, r12d		 ; r15d = index

					cmp r9d, 2           ; Sprawdz kanal (R = 0, G = 1, B = 2)
					je setBlue
					cmp r9d, 1
					je setGreen
					cmp r9d, 0
					je setRed

					setBlue:
						push rax
						mov al, [rsi+r15]
						mov al, 50
						mov [rdi+r15], al
						pop rax
						jmp cLoopStart

					setGreen:
						push rax
						mov al, [rsi+r15]
						mov al, 250
						mov [rdi+r15], al
						pop rax
						jmp cLoopStart

					setRed:
						push rax
						mov al, [rsi+r15]
						mov al, 50
						mov [rdi+r15], al
						pop rax

					cmp r9d, 0
					jne cLoopStart

				inc r11
				cmp r11, 1
				jle dxLoopStart

			inc rax              ; Zwieksz dy
			cmp rax, 1
			jle dyLoopStart

		cmp ecx, 0
		jne xLoopStart

	;sub ebx, _START_ROW
	
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