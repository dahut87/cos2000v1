.model  tiny
.486
smart
.code

org     0h

include ..\include\fat.h
include ..\include\mem.h
include ..\include\divers.h

start:
header  exe     <,1,0,,,offset imports,,>

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
        mov     ah,16
        mov     di,offset dir
        int     48h
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
        push    word ptr cs: [bp-8]
        call    [print]
        push    cs
        pop     es
        call    copy0
        call    getlength0
        add     di,cx
        jmp     waitchar
norr:
        cmp     al,0dh          ;entrée
        je      entere
        cmp     al,08h          ;backspace
        je      backspace
        cmp     al,27           ;echap
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
        push    offset error_syntax
        call    [print]
        push    word ptr cs: [bp-8]
        call    [print]
        jmp     replay
errorprec:
        push    offset derror
        call    [print]
        jmp     replay

code_exit:
        pop     ax
        retf

code_version:
        push    offset version_text
        call    [print]
        ret

version_text db 'Cos 2000 version 1.4Fr par \c04MrNop',0

code_cls:
        mov     ah,2
        int     47h
        ret

code_reboot:
        push    0ffffh
        push    00000h
        retf

code_command:
        push    offset def
        call    [print]
        mov     bx,offset commands
showalls:
        add     bx,8
        cmp     word ptr [bx],0
        je      endoff
        push    word ptr [bx+4]
        push    word ptr [bx+6]
        push    word ptr [bx]
        push    offset commandes
        call    [print]
        jmp     showalls
        endoff:
        ret

def       db 'Liste des commandes internes\l\l',0
commandes db '%0 \h10:\h12%0 \h70%0\l',0

code_mode:
        mov     cx,0
        call    gettypeditem0
        mov     ah,0
        mov     al,dl
        and     al,1111b
        int     47h
        mov     ah,2
        int     47h
        ret

code_dir:
        mov     ah,12
        int     48h
        push    edx
        mov     ah,11
        mov     di,offset nomdisque
        int     48h
        push    di
        push    offset present
        call    [print]
        xor     bp,bp
        mov     di,offset bufferentry
        mov     ah,7
        int     48h
        jc      nofiles
go:
        push    word ptr [di+entries.fileattr]
        push    dword ptr [di+entries.filesize]
        push    word ptr [di+entries.filetime]
        push    word ptr [di+entries.filedate]
        push    word ptr [di+entries.filetimecrea]
        push    word ptr [di+entries.filedatecrea]
        push    di
        push    offset line
        call    [print]
        inc     bp
        mov     ah,8
        int     48h
        jnc     go
nofiles:
        push    ebp
        push    offset filess
        call    [print]
        ret
        
nomdisque db    13 dup (0)
bufferentry db  512 dup (0)
present db      '\c02Le volume insere est nomme %0, Numero de serie : %hD\l\l',0

line    db      '\c07%n   %d   %t   %d   %t   %z   %a\l',0
filess  db      '\l\l\c02%u Fichier(s) au total\l',0

code_cd:
        mov     cx,0
        call    gettypeditem0
        push    di
        push    offset changing
        call    [print]
        mov     si,di
        mov     ah,13
        int     48h
        jnc     okchange
        push    offset errorchanging
        call    [print]
okchange:
        ret
        
changing db     'Changement de repertoire vers %0\l',0
errorchanging db '\c04Impossible d''atteindre ce dossier',0
        
code_kill:
        mov     cx,0
        call    gettypeditem0
        push    di
        push    offset killing
        call    [print]
        mov     si,di
        mov     ah,5
        int     49h
        jc      nochanged
        mov     ah,1
        int     49h
        jnc     okchanged
nochanged:
        push    offset errorkilling
        call    [print]
okchanged:
        ret
        
killing db     'Fermeture du processus %0\l',0
errorkilling db '\c04Impossible de fermer ce processus',0

code_refresh:
        mov     ah,3
        int     48h
        jnc     okrefresh
        push    offset errorrefreshing
        call    [print]
        ret
okrefresh:
        mov     ah,12
        int     48h
        push    edx
        mov     ah,11
        mov     di,offset nomdisque
        int     48h
        push    di
        push    offset present
        call    [print]
        ret
        
errorrefreshing db '\c04Impossible de lire le support',0
extcom  db      '.CE',0

code_mem:
        push    offset msg
        call    [print]
        xor     ebx,ebx
        xor     cx,cx
listmcb:
        mov     ah,4
        int     49h
        jc      fino
        inc     cx
;placement mémoire
        mov     dx,gs
        inc     dx
        inc     dx
        push    edx
;parent
        cmp     gs: [mb.reference],0
        jne     next
        push    cs
        push    offset none
        add     bx,gs:[mb.sizes]
        jmp     suitemn
next:
        mov     dx,gs: [mb.reference]
        dec     dx
        dec     dx
        push    dx
        push    offset mb.names
suitemn:
;Resident
        cmp     gs: [mb.isresident],true
        jne     notresident
        push    offset resident
        jmp     suitelistmcb
notresident:
        push    offset nonresident
suitelistmcb:
;taille memoire
        xor     edx,edx
        mov     dx,gs: [mb.sizes]
        shl     edx,4
        push    6
        push    edx
;nom
        push    gs
        push    offset mb.names
        push    offset line2
        call    [print]
        jmp     listmcb
fino:
        shl     ebx,4
        push    ebx
        push    offset fin
        call    [print]
        ret
resident db     "oui",0
nonresident db  "non",0
line2   db      "%0P\h15%w\h24%0\h30%0P\h46%hW\l",0
fin     db      "\l\l\c02%u octets de memoire disponible\l",0
msg     db      "Plan de la memoire\l\lNom            Taille   Res   Parent          Mem\l",0
none    db      ".",0


;converti le jeux scancode/ascii en fr ax->ax
convertfr:
        push    dx si
        mov     si,offset fr
searchtouch:
        mov     dx,cs: [si]
        cmp     dx,0
        je      endofconv
        add     si,4
        cmp     dx,ax
        jne     searchtouch
        mov     ax,cs: [si-2]
endofconv:
        pop     dx si
        ret

fr:     db      '1', 02, '&', 02
        db      '!', 02, '1', 02
        db      '2', 03, '‚', 03
        db      '@', 03, '2', 03
        db      '3', 04, '"', 04
        db      '#', 04, '3', 04
        db      '4', 05, 39, 05
        db      '$', 05, '4', 05
        db      '5', 06, '(', 06
        db      '%', 06, '5', 06
        db      '6', 07, '-', 07
        db      '^', 07, '6', 07
        db      '7', 08, 'Š', 08
        db      '&', 08, '7', 08
        db      '8', 09, '_', 09
        db      '*', 09, '8', 09
        db      '9', 10, '‡', 10
        db      '(', 10, '9', 10
        db      '0', 11, '…', 11
        db      ')', 11, '0', 11
        db      '-', 12, ')', 12
        db      '_', 12, 'ø', 12
        db      'Q', 16, 'A', 16
        db      'q', 16, 'a', 16
        db      'W', 17, 'Z', 17
        db      'w', 17, 'z', 17
        db      '{', 26, '‰', 26
        db      '[', 26, 'ˆ', 26
        db      ']', 27, '$', 27
        db      '}', 27, 'œ', 27
        db      'A', 30, 'Q', 30
        db      'a', 30, 'q', 30
        db      ':', 39, 'M', 39
        db      ';', 39, 'm', 39
        db      39, 40, '—', 40
        db      '"', 40, '%', 40
        db      00, 40, '%', 40
        db      '\', 43, '*', 43
        db      '|', 43, 'æ', 43
        db      'Z', 44, 'W', 44
        db      'z', 44, 'w', 44
        db      'm', 50, ',', 50
        db      'M', 50, '?', 50
        db      ',', 51, ';', 51
        db      '<', 51, '.', 51
        db      '.', 52, ':', 52
        db      '>', 52, '/', 52
        db      '?', 53, 'õ', 53
        db      '/', 53, '!', 53
        db      '\', 86, '<', 86
        db      '|', 86, '>', 86
        db      00, 79h, '~', 03
        db      00, 7ah, '#', 04
        db      00, 7bh, '{', 05
        db      00, 7ch, '[', 06
        db      00, 7dh, '|', 07
        db      00, 7eh, '`', 08
        db      00, 7fh, '\', 09
        db      00, 80h, '^', 10
        db      00, 81h, '@', 11
        db      00, 82h, ']', 12
        db      00, 83h, '}', 13
        db      00, 00, 00, 00

commands dw     str_exit ,code_exit ,syn_exit ,help_exit
        dw      str_version,code_version,syn_version,help_version
        dw      str_cls ,code_cls ,syn_cls ,help_cls
        dw      str_reboot ,code_reboot ,syn_reboot ,help_reboot
        dw      str_command,code_command,syn_command,help_command
        dw      str_mode ,code_mode ,syn_mode ,help_mode
        dw      str_dir ,code_dir ,syn_dir ,help_dir
        dw      str_refresh ,code_refresh ,syn_refresh ,help_refresh
        dw      str_cd ,code_cd ,syn_cd ,help_cd
        dw      str_mem ,code_mem ,syn_mem ,help_mem
        dw      str_kill ,code_kill ,syn_kill ,help_kill
        dw      0

str_exit db     'QUIT',0
str_version db  'VERS',0
str_cls db      'CLEAR',0
str_reboot db   'REBOOT',0
str_command db  'CMDS',0
str_mode db     'MODE',0
str_dir db      'DIR',0
str_refresh db  'DISK',0
str_cd  db      'CD',0
str_mem db      'MEM',0
str_kill db      'KILL',0

syn_exit db     0
syn_version db  0
syn_cls db      0
syn_reboot db   0
syn_command db  0
syn_mode db     'FFH',0
syn_dir db      0
syn_refresh db  0
syn_cd  db      '@',0
syn_mem db      0
syn_kill  db    '@',0

help_exit db    'Permet de quitter l''interpreteur',0
help_version db 'Affiche la version de COS',0
help_cls db     'Efface l''ecran',0
help_reboot db  'Redemarre l''ordinateur',0
help_command db 'Affiche le detail des commandes',0
help_mode db    'Modifie le mode video en cours',0
help_dir db     'Affiche le contenu du repertoire courant',0
help_refresh db 'Lit le support disquette insere',0
help_cd db      'Change le repertoire courant',0
help_mem db     'Affiche le plan de la memoire',0
help_kill db    'Termine le processus cible',0

derror  db      '\c04Erreur de Syntaxe !',0
error_syntax db '\c04La commande ou l''executable n''existe pas ! F1 pour ',0
prompt  db      '\c07>',0
msginit db      '\m02\e\c07\l\lInterpreteur de commande COS V1.9\lSous license \c05GPL\c07 - Ecrit par \c04MrNop\l\c07Utilisez la commande CMDS pour connaitres les commandes disponibles\l',0

include str0.asm

dir     db      32 dup (0)
buffer  db      128 dup (0)
buffer2 db      128 dup (0)

imports:
        db      "VIDEO.LIB::print",0
print   dd      0
        db      "VIDEO.LIB::showhex",0
showhex dd      0
        db      "VIDEO.LIB::showchar",0
showchar dd     0
        dw      0

end     start
