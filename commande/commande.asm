.model tiny
.486
smart
.code

org 0h

include ..\include\fat.h
include ..\include\mem.h
include ..\include\divers.h

start:
header exe <,1,0,,,offset imports,,>

realstart:
        push    offset msginit
        call    [print]
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
        push    offset prompt
        call    [print]
        mov     di,offset buffer
waitchar:
        mov     ax,0
        int     16h
        call    convertfr
        cmp     ah,59
        jne     norr
        cmp     bp,0
        je      waitchar
        push    word ptr cs:[bp-8]
        call    [print]
        push    cs
        pop     es   
        call    copy0
        call    getlength0
        add     di,cx
        jmp     waitchar
norr:
        cmp     al,0Dh  ;entrée
        je      entere
        cmp     al,08h ;backspace
        je      backspace
        cmp     al,27 ;echap
        je      escape
        cmp     al,' '
        jb      waitchar
        cmp     di,offset buffer+256
        je      waitchar
        mov     [di],al
        inc     di
        push    ax
        call    [showchar]
        jmp     waitchar
escape:
        cmp     di,offset buffer
        je      waitchar
        mov     ah,24
        int     47h
        mov     dx,offset buffer
        mov     cx,di
        sub     cx,dx
        js      waitchar
        je      waitchar
        sub     bh,cl
        mov     ah,25
        int     47h
        mov     di,offset buffer
        mov     byte ptr [di],0
backspace:
        cmp     di,offset buffer
        je      waitchar
        mov     ah,24
        int     47h
        dec     bh
        mov     ah,25
        int     47h
        push    ' '
        call    [showchar]
        mov     ah,25
        int     47h
        dec     di
        mov     byte ptr [di],0
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
        mov     ah,18
        int     48h
        jc      reallyerror
        xor     bp,bp
        jmp     replay
reallyerror:
        push    offset Error_Syntax
        call    [print]
        push    word ptr cs:[bp-8]
        call    [print]
        jmp     replay
errorprec:
        push    offset derror
        call    [print]
        jmp     replay
        
Code_Exit:
        pop     ax
        retf
        
Code_Version:
        push    offset Version_Text
        call    [print]
        ret
        
Version_Text db 'Cos 2000 version 1.2Fr par Nico',0
        
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
        push    si
        call    [print]
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

present db 'Le volume insere est nomme %0, Numero de serie : %hD\l\l',0
nomdisque db 13 dup (0)
Code_Dir:
mov ah,12
int 48h
push edx
mov ah,11
mov di,offset nomdisque
int 48h
push di
push offset present
call [print]
xor bp,bp
mov di,offset bufferentry
mov ah,7
int 48h
jc nofiles
go:
push word ptr [di+Entries.FileAttr]
push dword ptr [di+Entries.FileSize]
push word ptr [di+Entries.FileTime]
push word ptr [di+Entries.FileDate]
push word ptr [di+Entries.FileTimeCrea]
push word ptr [di+Entries.FileDateCrea]
push di
push offset line
call [print]
inc bp
mov ah,8
int 48h
jnc go
nofiles:
push ebp
push offset filess
call [print]
ret
bufferentry db 32 dup (0)
line db '\c07%n   %d   %t   %d   %t   %z   %a\l',0
filess db '\l\l%u Fichier(s) au total\l',0

changing db 'Changement de repertoire vers ',0
code_cd:
	mov     cx,0
        call    gettypeditem0
	push    offset changing
        call    [print]	
	mov	si,di
	mov	ah,13
	int	48h
	jnc	okchange
	push    offset errorchanging
        call    [print]	
okchange:
	ret
errorchanging db '\c04Impossible d''atteindre ce dossier',0

code_refresh:
	mov 	ah,3
	int 	48h
	jnc	okrefresh
	push offset errorrefreshing
      call [print]
ret
okrefresh:
mov ah,12
int 48h
push edx
mov ah,11
mov di,offset nomdisque
int 48h
push di
push offset present
call [print]
ret
errorrefreshing db '\c04Impossible de lire le support',0

extcom db '.CE',0

Code_Mem:
push offset msg
call [print]
xor cx,cx
listmcb:
mov ah,4
int 49h
jc fino
inc cx
;placement mémoire
mov dx,gs
inc dx
inc dx
push edx
;parent
cmp gs:[MB.Reference],0
je next
mov dx,gs:[MB.Reference]
dec dx
dec dx
push dx
push offset MB.Names
jmp suitemn
next:
push cs
push offset none
suitemn:
;Resident
cmp gs:[MB.IsResident],true
jne notresident
push offset resident
jmp suitelistmcb
notresident:
push offset nonresident
suitelistmcb:
;taille memoire
xor edx,edx
mov dx,gs:[MB.Sizes]
shl edx,4
push 6
push edx
;nom
push gs
push offset MB.Names
push offset line2
call [print]
jmp listmcb
fino:
ret
resident       db "oui",0
nonresident    db "non",0
line2           db "%0P\h15%w\h24%0\h30%0P\h46%hW\l",0
msg            db "Plan de la memoire\l\lNom            Taille   Res   Parent          Mem\l",0
none           db ".",0


;converti le jeux scancode/ascii en fr ax->ax
convertfr:
            push        dx si
            mov         si,offset fr
searchtouch:
            mov         dx,cs:[si]
            cmp         dx,0
            je          endofconv
            add         si,4
            cmp         dx,ax
            jne         searchtouch
            mov         ax,cs:[si-2]
endofconv:
            pop          dx si
            ret

fr:                     db   '1', 02, '&', 02
                        db   '!', 02, '1', 02
                        db   '2', 03, '‚', 03
                        db   '@', 03, '2', 03
                        db   '3', 04, '"', 04
                        db   '#', 04, '3', 04
                        db   '4', 05,  39, 05
                        db   '$', 05, '4', 05
                        db   '5', 06, '(', 06
                        db   '%', 06, '5', 06
                        db   '6', 07, '-', 07
                        db   '^', 07, '6', 07
                        db   '7', 08, 'Š', 08
                        db   '&', 08, '7', 08
                        db   '8', 09, '_', 09
                        db   '*', 09, '8', 09
                        db   '9', 10, '‡', 10
                        db   '(', 10, '9', 10
                        db   '0', 11, '…', 11
                        db   ')', 11, '0', 11
                        db   '-', 12, ')', 12
                        db   '_', 12, 'ø', 12
                        db   'Q', 16, 'A', 16
                        db   'q', 16, 'a', 16
                        db   'W', 17, 'Z', 17
                        db   'w', 17, 'z', 17
                        db   '{', 26, '‰', 26
                        db   '[', 26, 'ˆ', 26
                        db   ']', 27, '$', 27
                        db   '}', 27, 'œ', 27
                        db   'A', 30, 'Q', 30
                        db   'a', 30, 'q', 30
                        db   ':', 39, 'M', 39
                        db   ';', 39, 'm', 39
                        db    39, 40, '—', 40
                        db   '"', 40, '%', 40
                        db    00, 40, '%', 40
                        db   '\', 43, '*', 43
                        db   '|', 43, 'æ', 43
                        db   'Z', 44, 'W', 44
                        db   'z', 44, 'w', 44
                        db   'm', 50, ',', 50
                        db   'M', 50, '?', 50
                        db   ',', 51, ';', 51
                        db   '<', 51, '.', 51
                        db   '.', 52, ':', 52
                        db   '>', 52, '/', 52
                        db   '?', 53, 'õ', 53
                        db   '/', 53, '!', 53
                        db   '\', 86, '<', 86
                        db   '|', 86, '>', 86
                        db   00, 79h, '~', 03
                        db   00, 7Ah, '#', 04
                        db   00, 7Bh, '{', 05
                        db   00, 7Ch, '[', 06
                        db   00, 7Dh, '|', 07
                        db   00, 7Eh, '`', 08
                        db   00, 7Fh, '\', 09
                        db   00, 80h, '^', 10
                        db   00, 81h, '@', 11
                        db   00, 82h, ']', 12
                        db   00, 83h, '}', 13
                        db   00,  00,  00, 00















        
commands      dw Str_Exit   ,Code_Exit   ,Syn_Exit   ,Help_Exit
              dw Str_Version,Code_Version,Syn_Version,Help_Version
              dw Str_Cls    ,Code_Cls    ,Syn_Cls    ,Help_Cls
              dw Str_Reboot ,Code_Reboot ,Syn_Reboot ,Help_Reboot
              dw Str_Command,Code_Command,Syn_Command,Help_Command   
              dw Str_Mode   ,Code_Mode   ,Syn_Mode   ,Help_Mode
              dw Str_Dir   ,Code_Dir   ,Syn_Dir   ,Help_Dir
              dw Str_refresh   ,Code_refresh   ,Syn_refresh   ,Help_refresh
	      dw Str_cd   ,Code_cd   ,Syn_cd   ,Help_cd
	      dw Str_Mem   ,Code_Mem   ,Syn_Mem   ,Help_Mem
              dw 0
      
Str_Exit      db 'QUIT',0
Str_Version   db 'VERS',0
Str_Cls       db 'CLEAR',0
Str_Reboot    db 'REBOOT',0
Str_Command   db 'CMDS',0
Str_Mode      db 'MODE',0
Str_Dir		db 'DIR',0
Str_refresh 	db 'DISK',0
Str_cd 		db 'CD',0
Str_Mem 	db 'MEM',0
Syn_Exit      db 0
Syn_Version   db 0
Syn_Cls       db 0
Syn_Reboot    db 0
Syn_Command   db 0
Syn_Mode      db 'FFH',0
Syn_Dir   db 0
Syn_refresh   db 0
Syn_cd   db '@',0
Syn_Mem db 0
Help_Exit     db 0
Help_Version  db 0
Help_Cls      db 0
Help_Reboot   db 0
Help_Command  db 0
Help_Mode     db 0
Help_Dir     db 0  
Help_refresh     db 0   
Help_cd     db 0
Help_Mem db 0
derror        db '\c04Erreur de Syntaxe !',0
Error_Syntax  db '\c04La commande ou l''executable n''existe pas ! F1 pour ',0
prompt        db '\c07>',0
msginit           db '\m02\e\c07\l\lInterpreteur de commande COS V1.9',0

        include str0.asm

dir           db 32 dup (0)
buffer        db 256 dup (0)
buffer2       db 256 dup (0)

imports:
         db "VIDEO.LIB::print",0
print    dd 0
         db "VIDEO.LIB::showhex",0
showhex  dd 0
         db "VIDEO.LIB::showchar",0
showchar dd 0
         dw 0

end start
