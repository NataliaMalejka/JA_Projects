PUBLIC filterAsm


.data
NUM_CHANNELS DWORD 3
ONE DWORD 1
_WIDTH  DWORD 0
_HEIGHT DWORD 0
_BUF_FROM QWORD 0
_BUF_TO   QWORD 0
_STRIP_HEIGHT DWORD 0
_START_ROW    DWORD 0

.code

filterAsm PROC
    ; Setup stack frame
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
    mov r10d, _START_ROW

    mov ebx, _STRIP_HEIGHT
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

            ; SIMD summation for NUM_CHANNELS
            vxorpd xmm1, xmm1, xmm1       ; Zero sum (sum = 0)
            xor r15d, r15d                ; count = 0

            mov rax, -1                   ; dy = -1

            dyLoopStart:
                mov r11, -1                   ; dx = -1

                dxLoopStart:
                    ; Calculate rx = x + dx
                    mov r12d, ecx
                    add r12d, r11d

                    ; Check bounds rx
                    cmp r12d, 0
                    jl skipPixel
                    cmp r12d, _WIDTH
                    jge skipPixel

                    ; Calculate ry = y + dy
                    mov r13d, ebx
                    add r13d, eax

                    ; Check bounds ry
                    cmp r13d, 0
                    jl skipPixel
                    cmp r13d, _HEIGHT
                    jge skipPixel

                    inc r15;

                    ; Load NUM_CHANNELS pixels into YMM register
                    mov r10d, r13d
                    imul r10d, _WIDTH
                    add r10d, r12d
                    imul r10d, NUM_CHANNELS


                    movzx r14d, BYTE PTR [rsi + r10]      
                    pinsrb xmm0, r14d, 0                 

                    movzx r14d, BYTE PTR [rsi + r10 + 1]
                    pinsrb xmm0, r14d, 4         

                    movzx r14d, BYTE PTR [rsi + r10 + 2] 
                    pinsrb xmm0, r14d, 8 

                   vpaddd xmm1, xmm1, xmm0        ; Accumulate sum

                skipPixel:
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
            movd xmm4, r15d               ; Przenieœ r15d do xmm4 (skalar -> SIMD)
            vpbroadcastd xmm4, xmm4       ; Rozszerz r15d na wszystkie elementy ymm4

           ; Dzielenie SIMD: sum / count
            vcvtdq2ps xmm1, xmm1          ; Konwersja sum (INT -> FLOAT)
            vcvtdq2ps xmm4, xmm4          ; Konwersja count (INT -> FLOAT)
            vdivps xmm1, xmm1, xmm4       ; Dzielenie SIMD
            vcvtps2dq xmm1, xmm1          ; Konwersja wyniku z FLOAT -> INT


            pextrb byte ptr [rdi + r10], xmm1, 0   
            pextrb byte ptr [rdi + r10 + 1], xmm1, 4   
            pextrb byte ptr [rdi + r10 + 2], xmm1, 8   


            pop r10
            cmp ecx, 0
            jne xLoopStart

        cmp ebx, 0
        jne yLoopStart

endYLoop:
    mov rsp, rbp
    pop rbp
    ret
filterAsm ENDP

END