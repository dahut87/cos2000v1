.model tiny
.486
smart
.code

org 0100h

ent equ 32h

start:
jmp CopyCOS

Message db 0Dh,0Ah,'COS 2000 V3.02Fr programme d''installation',0Dh,0AH,'Inserez une disquette formatee et appuyez sur entre...',0Dh,0AH,'Attention le contenu de celle ci peut etre altere !!!',0Dh,0AH,'$'
Message2 db 0Dh,0AH,'Creation du secteur de demarrage...',0Dh,0Ah,'$'
Message3 db  0Dh,0AH,'Copie des fichiers systeme...',0Dh,0Ah,'$'
Errormsg db 0Dh,0AH,'Erreur d''installation, contactez moi a COS2000@MULTIMANIA.COM !',0Dh,0AH,'$'
Ok db 0Dh,0AH,'COS2000 a été correctement installé, veuillez redemarrer votre PC',0Dh,0AH,'$'
files db '*.*',0
boot db 'boot.bin',0
dat db 'data',0
retu db 0Dh,0AH,'$'
dta db 43 dup (0)
nom db 25 dup (0)

copycos:
        mov        ah,9
        mov        dx,offset message
        int        21h
        xor        ax,ax
        int        16h
        mov        ah,4ah
        mov        bx,1000h
        int        21h
        jc         error
        mov        ah,48h
        mov        bx,65536/16
        int        21h
        jc         error
        mov        fs,ax
        mov        ah,3Bh
        mov        dx,offset dat
        int        21h
        jc         error
        mov        ah,1Ah
        mov        dx,offset dta
        int        21h
        jc         error
        mov        ah,4eh
        xor        cx,cx
        mov        dx,offset files
        int        21h
        jc         error
        mov        ah,09
        mov        dx,offset message3
        int        21h
allfile:
        mov        byte ptr [offset dta+43],'$'
        mov        ah,9
        mov        dx,offset dta+30
        int        21h
        push       dx
        mov        ah,09
        mov        dx,offset retu
        int        21h
        pop        dx
        mov        ax,3D00h
        int        21h
        jc         error
        mov        bx,ax
        mov        ax,4202h
        xor        cx,cx
        xor        dx,dx
        int        21h
        jc         error
        cmp        dx,0
        jne        error
        cmp        ax,0
        je         error
        mov        bp,ax
        mov        ax,4200h
        xor        cx,cx
        xor        dx,dx
        int        21h
        jc         error
        push       fs
        pop        ds
        mov        ah,3fh
        mov        cx,0FFFFh
        xor        dx,dx
        int        21h
        push       cs
        pop        ds
        jc         error
        mov        ah,3eh
        int        21h
        jc         error
        mov        ah,3ch
        push       cs
        pop        es
        mov        si,offset dta+30-3
        mov        di,offset nom
        mov        cx,25
        rep        movsb
        mov        di,offset nom
        mov        word ptr [di],":a"
        mov        byte ptr [di+2],"\"
        xor        cx,cx
        mov        dx,di
        int        21h
        jc         error
        mov        bx,ax
        push       fs
        pop        ds
        xor        dx,dx
        mov        ah,40h
        mov        cx,bp
	int        21h
	push       cs
	pop        ds
        jc         error
        mov        ah,3eh
        int        21h
        jc         error
        mov        ah,4fh
        int        21h
 jnc        allfile
        mov        ah,09
        mov        dx,offset message2
        int        21h
        mov        ax,3D00h
        mov        dx,offset boot
        int        21h
        jc         error
        push       fs
        pop        ds
        mov        ah,3fh
        mov        cx,000FFh
        xor        dx,dx
        int        21h
        push       cs
        pop        ds
        jc         error
        mov        ah,3eh
        int        21h
        jc         error
        push       fs
        pop        es
        mov        ax,0301h
        mov        dx,0
        mov        cx,0001h
        xor        bx,bx
        int        13h
        mov        ah,09
        mov        dx,offset Ok
        int        21h
        xor        ax,ax
        int        16h
        ret

        
error:
        mov        ah,09
        mov        dx,offset errormsg
        int        21h
        xor        ax,ax
        int        16h
        ret
        
end start
