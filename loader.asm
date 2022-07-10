     name "loader"

	
   #make_boot#

org 7c00h


mov     ax, 07c0h
mov     ss, ax
mov     sp, 03feh 



xor     ax, ax
mov     ds, ax


mov     ah, 00h
mov     al, 03h
int     10h


lea     si, msg
call    imprimir



mov     ah, 02h 
mov     al, 10  
mov     ch, 0   
mov     cl, 2   
mov     dh, 0   

mov     bx, 0800h   
mov     es, bx
mov     bx, 0


int     13h

cmp     es:[0000],0E9h  
je     Checagem_integridade_ok


lea     si, err
call    imprimir


mov     ah, 0
int     16h

; Guardar magico em 0040h:0072h:
;   0000h - Boot a frio.
;   1234h - Reinicializacao.
mov     ax, 0040h
mov     ds, ax
mov     w.[0072h], 0000h 
jmp	0ffffh:0000h	     

;===================================

Checagem_integridade_ok:
;; Pular para o Kernel:
jmp     0800h:0000h

;===========================================



imprimir proc near
push    ax      
push    si     
proximo_char:      
        mov     al, [si]
        cmp     al, 0
        jz      impresso
        inc     si
        mov     ah, 0eh 
        int     10h
        jmp     proximo_char
impresso:
pop     si     
pop     ax      
ret
imprimir endp

                       
                       
                       
;====  =====================

msg  db "Carregando...",0Dh,0Ah, 0 
     
err  db "Dados invalidos no segundo setor do disco", 0Dh,0Ah
     db "                                                        ", 0Dh,0Ah
     db "O sistema precisa reiniciar. Pressione qualquer tecla...", 0
    
;======================================

