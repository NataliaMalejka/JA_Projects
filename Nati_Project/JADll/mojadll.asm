;-------------------------------------------------------------------------
;.586
;INCLUDE C:\masm32\include\windows.inc 

.DATA

_PI dq 3.141592653589793238
_180 dq 180.0
_100 dq 100.0
_60 dq 60.0

.CODE
;-------------------------------------------------------------------------
; To jest przyk³adowa funkcja.
;-------------------------------------------------------------------------
; parametry funkcji: RCX RDX R8 R9 stos,
; lub zmiennoprzec. XMM0 1 2 3

CheckSSEAsm proc
    mov eax, 1
    cpuid

    test edx, 02000000h
    jz no_sse

sse_supported:
    mov eax, 1   
    RET

no_sse:
    mov eax, 0   
    RET

CheckSSEAsm endp
;--------------------------------------------------------------------------
CheckSSE2Asm proc
    mov eax, 1
    cpuid

    test edx, 04000000h
    jz no_sse

sse_supported:
    mov eax, 1   
    RET

no_sse:
    mov eax, 0   
    RET

CheckSSE2Asm endp
;------------------------------------------------------------------------
RadToDegAsm proc

    mulsd xmm0, qword ptr [_180]
    divsd xmm0, qword ptr [_PI]
    cvtsd2si eax, xmm0
    cvtsi2sd xmm1, eax
    subsd xmm0, xmm1
    mulsd xmm0, qword ptr [_60]
    mulsd xmm1, qword ptr [_100]
    addsd xmm0, xmm1
    
ret

RadToDegAsm endp

END 
;------------------------------------------------------------------------

