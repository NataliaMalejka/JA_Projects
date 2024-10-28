EXTERN CreateThread:PROC


.data
NUM_CHANNELS DWORD 3
_WIDTH  DWORD 0
_HEIGHT DWORD 0
_BUF_FROM QWORD 0
_BUF_TO   QWORD 0
_THREAD_COUNT DWORD 0
_STRIP_HEIGHT  DWORD 0

.code

filterAsm PROC
	; parameters
	; rcx - width
	; rdx - height
	; r8 - input image
	; r9 - output image
	; [rsp+30h] - thread count]

	push rbp
	mov rbp, rsp

	mov _WIDTH, ecx
	mov _HEIGHT, edx
	mov eax, dword ptr [rsp + 30h]
	mov _THREAD_COUNT, eax
	mov _BUF_FROM, r8
	mov _BUF_TO, r9

	mov eax, _HEIGHT
	cdq
	idiv _THREAD_COUNT
	mov _STRIP_HEIGHT, eax

	; pêtla numThreads razy
	mov ebx, _THREAD_COUNT

loopStart:
	dec ebx

	mov eax, _STRIP_HEIGHT
	imul ebx
	
	; parametry dla CreateThread:
	; LPSECURITY_ATTRIBUTES lpThreadAttributes,
	; SIZE_T dwStackSize,
	; LPTHREAD_START_ROUTINE lpStartAddress,
	; LPVOID lpParameter,
	; DWORD dwCreationFlags,
	; LPDWORD lpThreadId
	
	push 0 ; lpThreadId
	push 0 ; dwCreationFlags - 0=start immediately
	sub rsp, 20h
	mov r9, rax
	mov r8, threadFunc ; lpStartAddress
	mov rdx, 0 ; dwStackSize - 0=default
	mov rcx, 0 ; lpThreadAttributes - 0=default
	
	call CreateThread

	; add rsp, 10h

	cmp ebx, 0
	jne loopStart

loopEnd:

	mov rsp, rbp
	pop rbp
	ret
	
filterAsm ENDP



threadFunc PROC

	push rsi
	push rdi
	push r15

	mov r8, rcx				; r8 - starting row
	mov rsi, _BUF_FROM
	mov rdi, _BUF_TO

	mov ebx, _STRIP_HEIGHT	; rbx - number of rows to process

yLoopStart:
	dec ebx

	add ebx, r8d

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

			mov r15d, eax		; r15d = index
			mov al, [rsi+r15]
			shr al, 1
			mov [rdi+r15], al

			cmp r9d, 0
			jne cLoopStart

		cmp ecx, 0
		jne xLoopStart

	sub ebx, r8d
	
	cmp ebx, 0
	jne yLoopStart


	pop r15
	pop rdi
	pop rsi
	ret

threadFunc ENDP



processPixel PROC
	ret
processPixel ENDP




END