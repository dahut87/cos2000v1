.model tiny
.486
smart
.code

org 0100h

include ..\include\fat.h

start:
	push    cs
        push    cs
        push    cs
        push    cs
        pop     ds
        pop     es
        pop     fs
        pop     gs
	  mov ah,21
     mov cl,7
     int 47h
	mov	ah,3
	int	48h
	mov	ax,0002
	int	47h
        mov     ah,2
        int     47h
        mov     ah,6
        int     47h
        mov     ah,6
        int     47h
        mov     ah,42
        int     47h
        mov     ah,13
        mov     si,offset msg
        int     47h
        xor     bp,bp
        mov     dl,' '
        call    setdelimiter0
replay:
        mov     ah,6
        int     47h
noret:
        mov     ah,6
        int     47h
	mov	ah,16
	mov	di,offset dir
	int	48h
	mov	si,di    
        mov     ah,13
	int	47h
        mov     si,offset prompt
        int     47h
        mov     di,offset buffer
waitchar:
        mov     ax,0
        int     16h
        cmp     ah,59
        jne     norr
        cmp     bp,0
        je      waitchar
        mov     ah,13
        mov     si,cs:[bp-8]
        int     47h
        push    cs
        pop     es   
        call    copy0
        call    getlength0
        add     di,cx
        jmp     waitchar
norr:
        cmp     al,0Dh
        je      entere
        cmp     di,offset buffer+256
        je      waitchar
        mov     [di],al
        inc     di
        mov     dl,al  
        mov     ah,7
        int     47h
        jmp     waitchar
entere:
        mov     byte ptr [di],0
        mov     si,offset buffer
        cmp     si,di
        je      noret
        mov     ah,6
        int     47h
        push    cs
        pop     es
        mov     di,offset buffer2
        xor     cx,cx
        call    getitem0
        mov     si,di
        call    uppercase0
        mov     bx,offset commands
        xor     bp,bp
tre:
        mov     di,[bx]
        add     bx,8
        cmp     di,0
        je      error
        push    cs
        pop     es   
        call    evalue0
        cmp     dx,bp
        jb      noadd
        mov     bp,dx
        mov     ax,bx
        noadd:
        call    cmpstr0
        jne     tre
        mov     si,offset buffer
        mov     di,offset buffer2
        call    copy0
        mov     si,di
        call    uppercase0
        xor     cx,cx
        inc     cx
        call    getpointeritem0
        cmp     byte ptr [di-1],0
        jne     nopod
        mov     byte ptr [di],0
nopod:
        mov     si,di
        mov     di,[bx-4]
        call    checksyntax0
        jc      errorprec
        mov     bx,[bx-6]
        call    bx
        jmp     replay
error:
        mov     bp,ax
        push    cs
        pop     es   
        mov     dl,'.'
        call    searchchar0
        je      noaddext
        mov     di,offset buffer
        mov     si,offset extcom
        call    concat0
noaddext:
        mov     si,offset buffer
        push    cs
        mov     ax,offset arrive
        push    ax
        mov     di,offset vga
        mov     ah,40
        int     47h
        mov     ax,9000h
        mov     es,ax
        push    ax
        mov     di,0100h
        push    di
        mov     ah,4
        int     48h
        jc      reallyerror
        push    es
        push    es
        push    es
        pop     ds
        pop     fs
        pop     gs
        push    7202h
        popf 
        db      0CBh
        arrive:
        push    cs
        push    cs
        push    cs
        push    cs
        pop     ds
        pop     es
        pop     fs
        pop     gs
        mov     si,offset vga
        mov     ah,41
        int     47h
        xor     bp,bp
        jmp     replay
reallyerror:
        pop     ax
        pop     ax
        pop     ax
        pop     ax
        mov     ah,13
        mov     si,offset Error_Syntax
        int     47h
        mov     ah,13
        mov     si,cs:[bp-8]
        int     47h
        jmp     replay
errorprec:
        mov     ah,13
        mov     si,offset derror
        int     47h
        jmp     replay
        
Code_Exit:
        pop     ax
        db      0CBh
        
Code_Version:
        mov     ah,13
        mov     si,offset Version_Text
        int     47h
        ret
        
Version_Text db 'Cos 2000 version 3.0.2Fr par Nico',0
        
Code_Cls:
        mov     ah,2
        int     47h
        ret
        
Code_Reboot:
        push    0FFFFh
        push    00000h
        db 0CBH
        
Code_Command:
        mov     bx,offset commands
showalls:
        mov     si,[bx]
        add     bx,8
        cmp     si,0
        je      endoff
        mov     ah,13
        int     47h
        mov     ah,6
        int     47h
        jmp     showalls
        endoff:
        ret

Code_Mode:
        mov     cx,0
        call    gettypeditem0
        mov     ah,0
        mov     al,dl
        and     al,1111b
        int     47h
        mov     ah,2
        int     47h
        ret

present db 'Le volume insere est nomme ',0
present2 db ', Numero de serie : ',0
nomdisque db 13 dup (0)
Code_Dir:
mov si,offset present
mov ah,13
int 47h
mov ah,11
mov di,offset nomdisque
int 48h
mov si,di
mov ah,13
int 47h
mov si,offset present2
mov ah,13
int 47h
mov ah,12
int 48h
mov ah,10
mov cx,32
int 47h
mov ah,6
int 47h
mov ah,6
int 47h
xor ebp,ebp
mov di,offset bufferentry
mov si,di
mov ah,7
int 48h
jc nofiles
go:
mov ah,46
int 47h
mov ah,05
int 47h
int 47h
int 47h
mov ah,44
mov dx,[si+Entries.FileDateCrea]
int 47h
mov ah,05
int 47h
int 47h
int 47h
mov ah,45
mov dx,[si+Entries.FileTimeCrea]
int 47h
mov ah,05
int 47h
int 47h
int 47h
mov ah,44
mov dx,[si+Entries.FileDate]
int 47h
mov ah,05
int 47h
int 47h
int 47h
mov ah,45
mov dx,[si+Entries.FileTime]
int 47h
mov ah,05
int 47h
int 47h
int 47h
mov ah,48
mov edx,[si+Entries.FileSize]
int 47h
mov ah,05
int 47h
int 47h
int 47h
mov ah,47
mov dl,[si+Entries.FileAttr]
int 47h
mov ah,6
int 47h
inc bp
mov ah,8
int 48h
jnc go
nofiles:
mov edx,ebp
mov ah,6
int 47h
mov ah,8
int 47h
mov si,offset filess
mov ah,13
int 47h
ret
bufferentry db 32 dup (0)
filess db ' Fichier(s) au total',0

changing db 'Changement de repertoire vers ',0
code_cd:
	mov     cx,0
        call    gettypeditem0
	push	si
	mov	si,offset changing
	mov	ah,13
	int	47h
	pop	si
	int	47h
	mov 	ah,6
	int 	47h
	mov	si,di
	mov	ah,13
	int	48h
	jnc	okchange
	mov	si,offset errorchanging
	mov	ah,13
	int	47h
okchange:
	ret
errorchanging db 'Impossible d''atteindre ce dossier',0

code_refresh:
	mov 	ah,3
	int 	48h
	jnc	okrefresh
	mov	si,offset errorrefreshing
	mov	ah,13
	int	47h
ret
okrefresh:
mov si,offset present
mov ah,13
int 47h
mov ah,11
mov di,offset nomdisque
int 48h
mov si,di
mov ah,13
int 47h
mov si,offset present2
mov ah,13
int 47h
mov ah,12
int 48h
mov ah,10
mov cx,32
int 47h
mov ah,6
int 47h
	ret
errorrefreshing db 'Impossible de lire le support',0

extcom db '.EXE',0
        
commands      dw Str_Exit   ,Code_Exit   ,Syn_Exit   ,Help_Exit
              dw Str_Version,Code_Version,Syn_Version,Help_Version
              dw Str_Cls    ,Code_Cls    ,Syn_Cls    ,Help_Cls
              dw Str_Reboot ,Code_Reboot ,Syn_Reboot ,Help_Reboot
              dw Str_Command,Code_Command,Syn_Command,Help_Command   
              dw Str_Mode   ,Code_Mode   ,Syn_Mode   ,Help_Mode
              dw Str_Dir   ,Code_Dir   ,Syn_Dir   ,Help_Dir
              dw Str_refresh   ,Code_refresh   ,Syn_refresh   ,Help_refresh
	      dw Str_cd   ,Code_cd   ,Syn_cd   ,Help_cd
              dw 0
      
Str_Exit      db 'QUIT',0
Str_Version   db 'VERS',0
Str_Cls       db 'EFFAC',0
Str_Reboot    db 'REDEM',0
Str_Command   db 'CMDS',0
Str_Mode      db 'MODE',0
Str_Dir		db 'VOIR',0
Str_refresh 	db 'LIRE',0
Str_cd 		db 'CH',0
Syn_Exit      db 0
Syn_Version   db 0
Syn_Cls       db 0
Syn_Reboot    db 0
Syn_Command   db 0
Syn_Mode      db 'FFH',0
Syn_Dir   db 0
Syn_refresh   db 0
Syn_cd   db '@',0
Help_Exit     db 0
Help_Version  db 0
Help_Cls      db 0
Help_Reboot   db 0
Help_Command  db 0
Help_Mode     db 0
Help_Dir     db 0  
Help_refresh     db 0   
Help_cd     db 0                              
derror        db 'Erreur de Syntaxe !',0
Error_Syntax  db 'La commande ou l''executable n''existe pas ! F1 pour ',0
prompt        db '>',0
msg           db 'Interpreteur de commande COS V1.1',0

        include str0.asm

dir           equ $
buffer        equ $+128
buffer2       equ $+128+512
vga           equ $+128+512+512


end start