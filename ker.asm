     name "sispx"

#make_bin#


#load_segment=0800#
#load_offset=0000#


#al=0b#
#ah=00#
#bh=00#
#bl=00#
#ch=00#
#cl=02#
#dh=00#
#dl=00#
#ds=0800#
#es=0800#
#si=7c02#
#di=0000#
#bp=0000#
#cs=0800#
#ip=0000#
#ss=07c0#
#sp=03fe#




putc    macro   char
        push    ax
        mov     al, char
        mov     ah, 0eh
        int     10h     
        pop     ax
endm



gotoxy  macro   col, row
        push    ax
        push    bx
        push    dx
        mov     ah, 02h
        mov     dh, row
        mov     dl, col
        mov     bh, 0
        int     10h
        pop     dx
        pop     bx
        pop     ax
endm


imprimir macro x, y, atributo, sdat
LOCAL   s_dcl, skip_dcl, s_dcl_end
    pusha
    mov dx, cs
    mov es, dx
    mov ah, 13h
    mov al, 1
    mov bh, 0
    mov bl, atributo
    mov cx, offset s_dcl_end - offset s_dcl
    mov dl, x
    mov dh, y
    mov bp, offset s_dcl
    int 10h
    popa
    jmp skip_dcl
    s_dcl DB sdat
    s_dcl_end DB 0
    skip_dcl:    
endm





org 0000h

jmp inicio 




;====  =====================

;; Mensagem de Boas Vindas


msg  db "Iniciando o SISPX...", 0Dh, 0Ah
     db "", 0Dh,0Ah
     db "", 0Dh, 0Ah
     db "Bem Vindo ao SISPX 16-Bit", 0Dh, 0Ah
     db "", 0Dh, 0Ah
     db "",0Dh,0Ah
     db "Copyright (C) 2013 Felipe Miguel Nery Lunkes",0Dh,0Ah  
     db "", 0Dh, 0Ah
     db "", 0Dh, 0Ah 
     db "Verificando seu computador... [Pronto]", 0Dh, 0Ah
     db 0Dh,0Ah,"",0Dh,0Ah,0   
     
falha_msg  db "Iniciando o SISPX...", 0Dh, 0Ah
     db "", 0Dh,0Ah
     db "", 0Dh, 0Ah
     db "Bem Vindo ao SISPX 16-Bit", 0Dh, 0Ah
     db "", 0Dh, 0Ah
     db "",0Dh,0Ah
     db "Copyright (C) 2013 Felipe Miguel Nery Lunkes",0Dh,0Ah  
     db "", 0Dh, 0Ah
     db "", 0Dh, 0Ah 
     db "Verificando seu computador... [Falha Geral]", 0Dh, 0Ah
     db 0Dh,0Ah,"",0Dh,0Ah,0
     
tamanho_comando        equ 64    ; Tamanho do buffer
comando_buffer  db tamanho_comando dup("b")
string_limpa       db tamanho_comando dup(" "), 0
prompt          db ">", 0

;; Comandos

cajuda    db "ajuda", 0
cajuda_tail: 
cproc db "proc",0
cproc_tail:
ccls     db "cls", 0
ccls_tail:
csair    db "sair", 0
csair_tail:
cfechar    db "fechar", 0
cfechar_tail:
creiniciar  db "reiniciar", 0
creiniciar_tail:   
cpaint db "paint",0
cpaint_tail:
cinfo db "info",0       
cinfo_tail: 
cinfopx db "info /px",0
cinfopx_tail:
cinfosispx db "info /sispx",0
cinfosispx_tail:

ajuda_msg db "Obrigado por usar o SISSPX-SO", 0Dh,0Ah 
         db "", 0Dh,0Ah
         
         db "Lista de comandos disponiveis:", 0Dh,0Ah
         db "",0Dh,0Ah
         db "ajuda     - Exibe esta mensagem", 0Dh,0Ah
         db "cls       - Limpa a tela.", 0Dh,0Ah
         db "reiniciar - Finaliza o SISSPX-SO e o PX-DOS e reiniciar o PC.", 0Dh,0Ah
         db "fechar    - Finaliza o SISPX e retorna ao PX-DOS.", 0Dh,0Ah 
         db "info      - Exibe informacoes do sistema.",0Dh,0Ah
         db "", 0Dh,0Ah, 0

desconhecido  db "Comando desconhecido: " , 0    

;======================================

inicio:


push    cs
pop     ds

; Definir video para 80x25:
mov     ah, 00h
mov     al, 03h
int     10h


mov     ax, 1003h
mov     bx, 0      
int     10h


jmp integridade_ok
 
integridade_ok: 

nop

              



call    limpartela
                     
                       

lea     si, msg
call    escrever


loop_infinito:
call    obter_comando

call    processar_comando


jmp loop_infinito


;===========================================
obter_comando proc near


mov     ax, 40h
mov     es, ax
mov     al, es:[84h]

gotoxy  0, al


lea     si, string_limpa
call    escrever

gotoxy  0, al

lea     si, prompt 
call    escrever



mov     dx, tamanho_comando   
lea     di, comando_buffer
call    obter_string


ret
obter_comando endp   


;===========================================

processar_comando proc    near


push    ds
pop     es

cld     


lea     si, comando_buffer
mov     cx, cajuda_tail - offset cajuda   
lea     di, cajuda
repe    cmpsb
je      ajuda_comando
 
lea     si, comando_buffer
mov     cx, cpaint_tail - offset cpaint  
lea     di, cpaint
repe    cmpsb
je     paint_comando   

      
lea     si, comando_buffer
mov     cx, cinfo_tail - offset cinfo  
lea     di, cinfo
repe    cmpsb
je      info_comando   

lea     si, comando_buffer
mov     cx, cinfosispx_tail - offset cinfosispx  
lea     di, cinfosispx
repe    cmpsb
je      infosispx_comando  



;===========================================

lea     si, comando_buffer
mov     cx, ccls_tail - offset ccls  
lea     di, ccls
repe    cmpsb
je     cls_comando    


lea     si, comando_buffer
mov     cx, csair_tail - offset csair 
lea     di, csair
repe    cmpsb
je      reiniciar_comando


lea     si, comando_buffer
mov     cx, cfechar_tail - offset cfechar 
lea     di, cfechar
repe    cmpsb
je      sair_comando


lea     si, comando_buffer
mov     cx, creiniciar_tail - offset creiniciar  
lea     di, creiniciar
repe    cmpsb
je      reiniciar_comando


cmp     comando_buffer, 0
jz      processado



mov     al, 1
call   rolar_para_area

mov     ax, 40h
mov     es, ax
mov     al, es:[84h]
dec     al
gotoxy  0, al

lea     si, desconhecido
call    escrever

lea     si, comando_buffer
call    escrever

mov     al, 1
call   rolar_para_area

jmp     processado


;;*********************************************************

sair_comando:
  

call    limpartela
imprimir 5,2,0011_1111b," Voce esta prestes a finaliza o SISPX. "
imprimir 5,3,0011_1111b," Pressione <ENTER> para desligar... "
mov ax, 0  
int 16h  
 
nop
nop
cli
clc
std
stc
sti 
hlt


;;*********************************************************


ajuda_comando:


mov     al, 9
call   rolar_para_area


mov     ax, 40h
mov     es, ax
mov     al, es:[84h]
sub     al, 9
gotoxy  0, al

lea     si, ajuda_msg
call    escrever

mov     al, 1
call   rolar_para_area

jmp     processado



;;*********************************************************


infosispx_comando:

lea     si, infosispx_msg
call    escrever 



mov     al, 1
call   rolar_para_area

jmp     processado  

infosispx_msg db "",0Dh,0Ah
           db "",0Dh,0Ah 
           db "Sistema Operacional SISPX",0Dh,0Ah
           db "*************************",0Dh,0Ah
           db "",0Dh,0Ah
           db "Versao 0.1.1 8086",0Dh,0Ah
           db "Processador: Intel 8086",0Dh,0Ah
           db "Memoria RAM aproximada: 638 Kb",0Dh,0Ah
           db "Discos suportados: <Disquete 1440 Kb> | <Disquete 720 Kb>",0Dh,0Ah
           db "",0Dh,0Ah
           db "Copyright (C) 2013 Felipe Miguel Nery Lunkes",0Dh,0Ah
           db "Todos os direitos reservados.",0Dh,0Ah
           db "",0Dh,0Ah
           db "",0Dh,0Ah,0
           
           
           
;;*********************************************************


cls_comando:
call    limpartela
jmp     processado

                    
                      
;;*********************************************************


paint_comando: 

include "mouse.asm"

jmp inicio_mouse


;;*********************************************************  


info_comando: 


lea si, info_msg
call escrever

mov     al, 1
call   rolar_para_area

jmp     processado

info_msg db "",0Dh,0Ah
         db "", 0Dh, 0Ah
         db "Sistema Operacional SISPX versao 0.1.1", 0Dh,0Ah
         db "",0Dh,0Ah
         db "Versao 0.1.1 8086",0Dh,0Ah
         db "Memoria RAM aproximada: 638 Kb",0Dh,0Ah
         db "",0Dh,0Ah
         db "",0Dh,0Ah
         db "Para mais informacoes, use info /sispx para mais sobre o SISPX.",0Dh,0Ah
         db "", 0Dh,0Ah,0



;;*********************************************************



reiniciar_comando:
call    limpartela
imprimir 5,2,0011_1111b," Por favor retire todos os disquetes e midias "
imprimir 5,3,0011_1111b," e pressione qualquer tecla para reiniciar... "
mov ax, 0  
int 16h


mov     ax, 0040h
mov     ds, ax
mov     w.[0072h], 0000h 
jmp	0ffffh:0000h	 

; ++++++++++++++++++++++++++

processado:
ret
processar_comando endp

;===========================================


rolar_para_area  proc    near

mov dx, 40h
mov es, dx  
mov ah, 06h 
mov bh, 07  
mov ch, 0 
mov cl, 0  
mov di, 84h 
mov dh, es:[di] 
dec dh  
mov di, 4ah 
mov dl, es:[di]
dec dl  
int 10h

ret
rolar_para_area  endp

;===========================================





obter_string      proc    near
push    ax
push    cx
push    di
push    dx

mov     cx, 0                  

cmp     dx, 1                   
jbe     buffer_vazio            

dec     dx                      




esperar_tecla:

mov     ah, 0                   
int     16h

cmp     al, 0Dh                
jz      fechar


cmp     al, 8                  
jne     adicionar_ao_buffer
jcxz    esperar_tecla            
dec     cx
dec     di
putc    8                     
putc    ' '                     
putc    8                       
jmp     esperar_tecla

adicionar_ao_buffer:

        cmp     cx, dx          
        jae     esperar_tecla   

        mov     [di], al
        inc     di
        inc     cx
        
       
        mov     ah, 0eh
        int     10h

jmp     esperar_tecla
;============================

fechar:


mov     [di], 0

buffer_vazio:

pop     dx
pop     di
pop     cx
pop     ax
ret
obter_string      endp





escrever proc near
push    ax    
push    si      

proximo_char:      
        mov     al, [si]
        cmp     al, 0
        jz      imprimired
        inc     si
        mov     ah, 0eh 
        int     10h
        jmp     proximo_char
imprimired:

pop     si    
pop     ax      

ret
escrever endp




limpartela proc near
        push    ax      
        push    ds      
        push    bx      
        push    cx      
        push    di      

        mov     ax, 40h
        mov     ds, ax  
        mov     ah, 06h
        mov     al, 0   
        mov     bh, 1001_1111b  
        mov     ch, 0   
        mov     cl, 0   
        mov     di, 84h 
        mov     dh, [di] 
        mov     di, 4ah 
        mov     dl, [di]
        dec     dl      
        int     10h

        
        mov     bh, 0  
        mov     dl, 0   
        mov     dh, 0   
        mov     ah, 02
        int     10h

        pop     di      
        pop     cx      ;
        pop     bx      ;
        pop     ds      ;
        pop     ax      ;

        ret
limpartela endp


cls proc near
    
    mov ax,cs
	mov ds,ax
	mov es,ax
    
    push ax
    push bx
    push cx
    push dx
    
    
    mov dx, 0
	mov bh, 0
	mov ah, 2
	int 10h  
	
	mov ah, 6			
	mov al, 0			
	mov bh, 7			
	mov cx, 0			
	mov dh, 24			
	mov dl, 79
	int 10h
              
    pop dx
	pop cx
	pop bx
	pop ax

	ret    
	
cls endp	          