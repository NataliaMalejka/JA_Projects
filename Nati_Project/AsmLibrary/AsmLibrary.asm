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

	mov ebx, _STRIP_HEIGHT	; rbx - number of rows to process
	add ebx, _START_ROW
yLoopStart:
	dec ebx

	cmp ebx, _START_ROW         
    jl endYLoop   

	mov ecx, _WIDTH

	xLoopStart:
		dec ecx

		mov r9d, NUM_CHANNELS
		cLoopStart:
			dec r9d

			; (y * w + x) * NUM_CHANNELS + channel
			mov rax, rbx		; rax = y
			imul _WIDTH
			add rax, rcx
			imul NUM_CHANNELS
			add rax, r9

			mov r15, rax		; r15 = index


			cmp r9d, 2						; Sprawdz kanal (R = 0, G = 1, B = 2)
			je setBlue
			cmp r9d, 1
			je setGreen
			cmp r9d, 0
			je setRed

			;mov al, [rsi+r15]
			;shr al, 1
			;mov [rdi+r15], al

			setBlue:
				mov al, [rsi+r15]
				mov al, 50
				mov [rdi+r15], al
				jmp cLoopStart

			setGreen:
				mov al, [rsi+r15]
				mov al, 250
				mov [rdi+r15], al
				jmp cLoopStart

			setRed:
				mov al, [rsi+r15]
				mov al, 50
				mov [rdi+r15], al

			cmp r9d, 0
			jne cLoopStart

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




processPixel PROC
	ret
processPixel ENDP




END