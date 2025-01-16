PUBLIC filterAsm


.data

    ; parameters
	; rcx - width
	; rdx - height
	; r8 - input image
	; r9 - output image
	; [rsp + 48h] - strip height
	; [rsp + 50h] - start row
    ; [rsp + 58h] - start index

    ;r11 - y
    ;r12 - start row
    ;r10 - start index

.code

filterAsm PROC
   
   PixelNeigbor macro vert, horiz

    mov rbx, horiz
    mov rax, vert
    imul rax, rcx          ; rax = vert * width
    add rax, rbx        ; rax = (vert * width) + horiz

    ; Adjust the current pixel address
    lea rdi, [r8 + r10 * 4] 
    add rdi, rax

    ; Load the neighbor pixel
    movdqu xmm4, xmmword ptr [rdi]
    
    movdqa xmm7, xmm4
    pand xmm7, xmm5 ; B
    paddd xmm3, xmm7  

    psrld xmm4, 8
    movdqa xmm7, xmm4
    pand xmm7, xmm5 ; G
    paddd xmm2, xmm7

    psrld xmm4, 8
    movdqa xmm7, xmm4
    pand xmm7, xmm5 ; R
    paddd xmm1, xmm7

    pxor xmm4, xmm4       ; Clear the register

endm

    push rbp
	mov rbp, rsp

	push rsi
	push rdi
	push r15

	mov r11d, dword ptr [rsp + 48h]
	add r11d, dword ptr [rsp + 50h]
	mov r12d, dword ptr [rsp + 50h]
    mov r10d, dword ptr [rsp + 58h]

	mov eax, 3120
    movd xmm11, eax
    pshufd xmm11, xmm11, 0

    mov eax, 255
    movd xmm5, eax
    pshufd xmm5, xmm5, 0

    xor r13, r13 

PixelLoop:
	
	dec r11
	cmp r11, r12
	jl EndLoop


    ; Clear R, G, B accumulators
    pxor xmm1, xmm1
    pxor xmm2, xmm2
    pxor xmm3, xmm3

    PixelNeigbor -4, -4
    PixelNeigbor 0, -4
    PixelNeigbor 4, -4
    PixelNeigbor -4, 0
    PixelNeigbor 0, 0
    PixelNeigbor 4, 0
    PixelNeigbor -4, 4
    PixelNeigbor 0, 4
    PixelNeigbor 4, 4

    pslld xmm5, 24

    ; Normalization
    pmulld xmm1, xmm11
    pmulld xmm2, xmm11
    pmulld xmm3, xmm11

    psrad xmm1, 16
    psrad xmm2, 16
    psrad xmm3, 16

    ; Glue the channels together
    pslld xmm1, 16
    pslld xmm2, 8 
    por xmm1, xmm2
    por xmm1, xmm3
    por xmm1, xmm5

    psrld xmm5, 24

    ;Save
    movdqu xmmword ptr [r9 + r10 * 4], xmm1

    add r10d, 1 
    cmp r10, rcx

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