;-------------------------------------------------------------------------
;.586
;INCLUDE C:\masm32\include\windows.inc 

.DATA


.CODE


CheckSSE2Asm proc
   

    mov al, cl       
    mov bl, dl      
    mov cl, r8b     

    shr al, 1       
    shr bl, 1        
    shr cl, 1        

    movzx eax, cl   
    shl eax, 8       
    mov al, bl       
    shl eax, 8      
    mov al, al       

    ret

CheckSSE2Asm endp


END 
;------------------------------------------------------------------------

