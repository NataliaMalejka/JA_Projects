PUBLIC filterAsm


.data
NUM_CHANNELS DWORD 3
_WIDTH  DWORD 0
_HEIGHT DWORD 0
_BUF_FROM QWORD 0
_BUF_TO   QWORD 0
_STRIP_HEIGHT DWORD 0
_START_ROW    DWORD 0

    ; parameters
	; rcx - width
	; rdx - height
	; r8 - input image
	; r9 - output image
	; [rsp+30h] - strip height
	; [rsp+38h] - start row

;RCX - OldPixels pointer
;R8 - Starting index
;R9 - End index
;R10 - Stride
;R11 - Negative width
;R12 - NewPixels pointer

.code

filterAsm PROC
   
    push rbp
	mov rbp, rsp

	push rsi
	push rdi
	push r15

	mov r8d, dword ptr [rsp + 30h]
	add r8d, dword ptr [rsp + 38h]
	mov r9d, dword ptr [rsp + 38h]

	mov eax, 3120
    movd xmm11, eax
    pshufd xmm11, xmm11, 0

    mov eax, 255
    movd xmm5, eax
    pshufd xmm5, xmm5, 0

    mov r14, r9
    sub r14, 4

PixelLoop:
	
	dec r8
	cmp r8, r9
	jl EndLoop


    ; Clear R, G, B accumulators
    pxor xmm1, xmm1
    pxor xmm2, xmm2
    pxor xmm3, xmm3



	jmp PixelLoop

EndLoop:

	pop r15
	pop rdi
	pop rsi

	mov rsp, rbp
	pop rbp
	ret

filterAsm ENDP

END