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
    push rbp
    mov rbp, rsp

    ; Load parameters
    mov _WIDTH, ecx
    mov _HEIGHT, edx
    mov _BUF_FROM, r8
    mov _BUF_TO, r9
    mov eax, dword ptr [rsp + 30h]
    mov _STRIP_HEIGHT, eax
    mov eax, dword ptr [rsp + 38h]
    mov _START_ROW, eax

    mov rsi, _BUF_FROM
    mov rdi, _BUF_TO
    mov r13d, _START_ROW

    mov ebx, _STRIP_HEIGHT
    add ebx, r13d

    mov r15d, _WIDTH

yLoopStart:
    dec ebx
    cmp ebx, r13d
    jl endYLoop

    mov ecx, r15d
    dec ecx

        xLoopStart:
            dec ecx

            vpxor xmm1, xmm1, xmm1       ; sum = 0

            mov rax, -1                   ; dy = -1

            dyLoopStart:
                mov r11, -1                   ; dx = -1

                dxLoopStart:

                    mov r10d, ebx            ; y
                    add r10, rax             ; y + dy
                    imul r10d, _WIDTH        ; y * WIDTH
                    mov r12d, ecx            ; x
                    add r12d, r11d           ; x + dx
                    add r10d, r12d           ; (y * WIDTH) + x
                    imul r10d, NUM_CHANNELS  ; (y * WIDTH + x) * NUM_CHANNELS

                    movzx r14d, BYTE PTR [rsi + r10]      
                    pinsrb xmm0, r14d, 0                 

                    movzx r14d, BYTE PTR [rsi + r10 + 1]
                    pinsrb xmm0, r14d, 4         

                    movzx r14d, BYTE PTR [rsi + r10 + 2] 
                    pinsrb xmm0, r14d, 8 

                    vpaddd xmm1, xmm1, xmm0        ; Accumulate sum

                    inc r11
                    cmp r11, 1
                    jle dxLoopStart

                inc rax
                cmp rax, 1
                jle dyLoopStart

            ;to index
            mov r10d, ebx
            imul r10d, _WIDTH
            add r10d, ecx
            imul r10d, NUM_CHANNELS

            ; Przygotowanie dzielnika do operacji SIMD
            push r15
            mov r15, 9
            movd xmm4, r15d               ; Przenieœ r15d do xmm4 (skalar -> SIMD)
            vpbroadcastd xmm4, xmm4       ; Rozszerz r15d na wszystkie elementy ymm4
            pop r15

            ; Dzielenie SIMD: sum / count
            vdivps xmm1, xmm1, xmm4       ; Dzielenie SIMD
            vcvtps2dq xmm1, xmm1          ; Konwersja wyniku z FLOAT -> INT

            pextrb byte ptr [rdi + r10], xmm1, 0   
            pextrb byte ptr [rdi + r10 + 1], xmm1, 4   
            pextrb byte ptr [rdi + r10 + 2], xmm1, 8   

            cmp ecx, 1
            jne xLoopStart

        cmp ebx, 0
        jne yLoopStart

endYLoop:
    mov rsp, rbp
    pop rbp
    ret
filterAsm ENDP

END