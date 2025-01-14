PUBLIC filterAsm


.data
NUM_CHANNELS DWORD 3
_WIDTH  DWORD 0
_HEIGHT DWORD 0
_BUF_FROM QWORD 0
_BUF_TO   QWORD 0
_STRIP_HEIGHT DWORD 0
_START_ROW    DWORD 0


;RCX - OldPixels pointer
;R8 - Starting index
;R9 - End index
;R10 - Stride
;R11 - Negative width
;R12 - NewPixels pointer

.code

filterAsm PROC
    mov ebx, dword ptr[rbp + 48]     ; Move width to EBX
    mov r10, rbx                     ; Move stride to R10
    xor r11, r11                     ; Clear R11 register
    sub r11, r10                     ; Assign negative value of width to R11
    mov r12, rdx                     ; Move NewPixelPointer to R12
    mov rdi, r8                      ; Initialize counter from starting index to RDI
    add rcx, r8                      ; Move OldPixels pointer to starting position
    add R12, r8                      ; Move NewPixels pointer to starting position

programLoop:
    cmp rdi, r9                      ; Compare current index with end index
    je endLoop                       ; Exit loop if end is reached

    ; Load 9 pixels (3 channels per pixel) into XMM registers
    movdqu xmm0, [rcx + r11 - 3]     ; Load top-left, top-center, top-right
    movdqu xmm1, [rcx - 3]           ; Load mid-left, mid-center, mid-right
    movdqu xmm2, [rcx + r10 - 3]     ; Load bottom-left, bottom-center, bottom-right

    ; Add RGB values for all 9 pixels
    paddusb xmm0, xmm1               ; Add middle row to top row
    paddusb xmm0, xmm2               ; Add bottom row to xmm0

    ; Horizontal sum of RGB channels
    movdqa xmm1, xmm0                ; Copy xmm0 to xmm1
    pshufd xmm1, xmm1, 245    ; Shuffle to align RGB values
    paddusb xmm0, xmm1               ; Add shuffled values
    pshufd xmm1, xmm1, 27    ; Further shuffle to complete sum
    paddusb xmm0, xmm1               ; Final sum of RGB channels

    ; Divide by 9 (equivalent to averaging)
    movdqa xmm1, xmm0                ; Copy sum to xmm1
    psrlw xmm1, 3                    ; Divide each value by 8 (right shift)
    paddusb xmm1, xmm0               ; Add remainder for rounding
    psrlw xmm1, 1                    ; Final division (divide by 9)

    ; Clamp to range 0-255
    pxor xmm2, xmm2                  ; Zero xmm2
    packuswb xmm1, xmm2              ; Pack to unsigned bytes

    ; Store the result
    movdqu [R12], xmm1               ; Store averaged pixel in NewPixels

    ; Increment pointers
    inc rdi                          ; Increment current index (loop)
    add rcx, 3                       ; Move OldPixels pointer to the next pixel
    add R12, 3                       ; Move NewPixels pointer to the next pixel
    jmp programLoop

endLoop:
    ret

filterAsm ENDP

END