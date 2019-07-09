struc regs
{
.seip dd 0
.seax dd 0
.sebx dd 0
.secx dd 0
.sedx dd 0
.sesi dd 0
.sedi dd 0
.sebp  dd 0
.sesp  dd 0
.scs  dw 0
.sds  dw 0
.ses  dw 0
.sfs  dw 0
.sgs  dw 0
.sss  dw 0
;.seflags dd 0
;.sst0 dt 0
;;sst1 dt 0
;.sst2 dt 0
;.sst3 dt 0
;.sst4 dt 0
;.sst5 dt 0
;.sst6 dt 0
;.sst7 dt 0
}

struc tuple off,seg
{
.off dw 0   ;adresse
.seg dw 0   ;segment
}

struc vector off,seg
{
.data tuple off,seg
virtual at .data 
.content dd 0
end virtual 
}

struc ints ;bloc interruption
{ 
.number db 0    ;numero de l'interruption
.activated db 0     ;activé ou non
.locked db 0    ;verrouillée
.launchedlow dd 0
.launchedhigh dd 0
.calledlow dd 0
.calledhigh dd 0
.vector1 vector ?
.vector2 vector ?
.vector3 vector ?
.vector4 vector ?
.vector5 vector ?
.vector6 vector ?
.vector7 vector ?
.vector8 vector ?
.sizeof = $ - .number
}
 
struc mb check,isnotlast,isresident,reference,sizes,names
;Bloc de mémoire
{
.check 	        db "NH"         ;signature du bloc de mémoire.
.isnotlast 	db 0             ;flag indiquant le dernier bloc
.isresident	db 0             ;flag indiquant que le bloc est resident
.reference	dw 0             ;pointeur vers le bloc parent
.sizes		dw 0             ;taille du bloc en paragraphe de 16 octet
.names		db 24 dup (0)    ;nom du bloc
.sizeof = $ - .check
}

struc exe major        
;Executable COS
{
.checks 	         db "CE"         ;signature de l'exe
.major            db 1            ;N° version
.checksum         dd 0            ;Checksum de l'exe
.compressed       db 0            ;a 1 si compressé par RLE
.exports          dw 0            ;importation de fonctions
.imports          dw 0            ;exportation de fonctions
.sections         dw 0            ;sections des blocs mémoire
.starting         dw 15
}

struc descriptor limit_low,base_low,base_middle,dpltype,limit_high,base_high
{
.limit_low   dw 0
.base_low    dw 0
.base_middle db 0
.dpltype     db 0
.limit_high  db 0
.base_high   db 0
.sizeof = $ - .limit_low 
}

free        equ 0                 ;Reference quand libre

macro   exporting
{
	 exports:
}

macro   importing
{
	 imports:
}

macro   noimporting
{
	 imports:
	 ende
}

macro   noexporting
{
	 imports:
	 ende
}

macro   ende
{
	 dd 0
}

macro   endi
{
	 dd 0
}

macro   use    lib*,fonction*
{
	 db `lib,"::",`fonction,0
fonction:
	   dd 0
         dd 0
 }

macro   declare    fonction*
{
	 db `fonction,0
       dw fonction
}


; Macroinstructions for defining and calling procedures

macro stdcall proc,[arg]		; directly call STDCALL procedure
{ 
common
    if ~ arg eq
   reverse
    push arg
   common
    end if
    push cs
    call proc 
}
    
macro invoke proc,[arg]		; directly call STDCALL procedure
 { 
 common
    if ~ arg eq
   reverse
    push arg
   common
    end if
    call far [cs:proc] 
 }

macro proc [args]			; define procedure
 { common
    match name params, args>
    \{ define@proc name,<params \} }

prologue@proc equ prologuedef

macro prologuedef procname,flag,parmbytes,localbytes,reglist
 { if parmbytes | localbytes
    push bp
    mov bp,sp
    if localbytes
     sub sp,localbytes
    end if
   end if
   irps reg, reglist \{ push reg \} }

epilogue@proc equ epiloguedef

macro epiloguedef procname,flag,parmbytes,localbytes,reglist
 { irps reg, reglist \{ reverse pop reg \}
   if parmbytes | localbytes
    leave
   end if
   if flag and 10000b
    retn
   else
    retn parmbytes
   end if }

macro define@proc name,statement
 { local params,flag,regs,parmbytes,localbytes,current
   if used name
   name:
   match =stdcall args, statement \{ params equ args
				     flag = 11b \}
   match =stdcall, statement \{ params equ
				flag = 11b \}
   match =params, params \{ params equ statement
			    flag = 0 \}
   virtual at bp+4
   match =uses reglist=,args, params \{ regs equ reglist
					params equ args \}
   match =regs =uses reglist, regs params \{ regs equ reglist
					     params equ \}
   match =regs, regs \{ regs equ \}
   match =,args, params \{ defargs@proc args \}
   match =args@proc args, args@proc params \{ defargs@proc args \}
   parmbytes = $ - (bp+4)
   end virtual
   name # % = parmbytes/2
   all@vars equ
   current = 0
   match prologue:reglist, prologue@proc:<regs> \{ prologue name,flag,parmbytes,localbytes,reglist \}
   macro locals
   \{ virtual at bp-localbytes+current
      macro label . \\{ deflocal@proc .,:, \\}
      struc db [val] \\{ \common deflocal@proc .,db,val \\}
      struc du [val] \\{ \common deflocal@proc .,du,val \\}
      struc dw [val] \\{ \common deflocal@proc .,dw,val \\}
      struc dp [val] \\{ \common deflocal@proc .,dp,val \\}
      struc dd [val] \\{ \common deflocal@proc .,dd,val \\}
      struc dt [val] \\{ \common deflocal@proc .,dt,val \\}
      struc dq [val] \\{ \common deflocal@proc .,dq,val \\}
      struc rb cnt \\{ deflocal@proc .,rb cnt, \\}
      struc rw cnt \\{ deflocal@proc .,rw cnt, \\}
      struc rp cnt \\{ deflocal@proc .,rp cnt, \\}
      struc rd cnt \\{ deflocal@proc .,rd cnt, \\}
      struc rt cnt \\{ deflocal@proc .,rt cnt, \\}
      struc rq cnt \\{ deflocal@proc .,rq cnt, \\} \}
   macro endl
   \{ purge label
      restruc db,du,dw,dp,dd,dt,dq
      restruc rb,rw,rp,rd,rt,rq
      current = $-(bp-localbytes)
      end virtual \}
   macro ret operand
   \{ match any, operand \\{ retn operand \\}
      match , operand \\{ match epilogue:reglist, epilogue@proc:<regs>
			  \\\{ epilogue name,flag,parmbytes,localbytes,reglist \\\} \\} \}
   macro finish@proc \{ localbytes = (((current-1) shr 2)+1) shl 2
			end if \} }

macro defargs@proc [arg]
 { common
    if ~ arg eq
   forward
     local ..arg,current@arg
     match argname:type, arg
      \{ current@arg equ argname
	 label ..arg type
	 argname equ ..arg
	 if dqword eq type
	   dw ?,?,?,?,?,?,?,?
	 else if tbyte eq type
	   dw ?,?,?,?,?
	 else if qword eq type | pword eq type
	   dw ?,?,?,?
	 else if dword eq type
	   dw ?,?
	 else
	   dw ?
	 end if \}
     match =current@arg,current@arg
      \{ current@arg equ arg
	 arg equ ..arg
	 ..arg dw ? \}
   common
     args@proc equ current@arg
   forward
     restore current@arg
   common
    end if }

macro deflocal@proc name,def,[val]
 { common
    match vars, all@vars \{ all@vars equ all@vars, \}
    all@vars equ all@vars name
   forward
    local ..var,..tmp
    ..var def val
    match =?, val \{ ..tmp equ \}
    match any =dup (=?), val \{ ..tmp equ \}
    match tmp : value, ..tmp : val
     \{ tmp: end virtual
	initlocal@proc ..var,def value
	virtual at tmp\}
   common
    match first rest, ..var, \{ name equ first \} }

macro initlocal@proc name,def
 { virtual at name
    def
    size@initlocal = $ - name
   end virtual
   position@initlocal = 0
   while size@initlocal > position@initlocal
    virtual at name
     def
     if size@initlocal - position@initlocal < 2
      current@initlocal = 1
      load byte@initlocal byte from name+position@initlocal
     else if size@initlocal - position@initlocal < 4
      current@initlocal = 2
      load word@initlocal word from name+position@initlocal
     else
      current@initlocal = 4
      load dword@initlocal dword from name+position@initlocal
     end if
    end virtual
    if current@initlocal = 1
     mov byte [name+position@initlocal],byte@initlocal
    else if current@initlocal = 2
     mov word [name+position@initlocal],word@initlocal
    else
     mov dword [name+position@initlocal],dword@initlocal
    end if
    position@initlocal = position@initlocal + current@initlocal
   end while }

macro endp
 { purge ret,locals,endl
   finish@proc
   purge finish@proc
   restore regs@proc
   match all,args@proc \{ restore all \}
   restore args@proc
   match all,all@vars \{ restore all \} }

macro local [var]
 { common
    locals
   forward done@local equ
    match varname[count]:vartype, var
    \{ match =BYTE, vartype \\{ varname rb count
				restore done@local \\}
       match =WORD, vartype \\{ varname rw count
				restore done@local \\}
       match =DWORD, vartype \\{ varname rd count
				 restore done@local \\}
       match =PWORD, vartype \\{ varname rp count
				 restore done@local \\}
       match =QWORD, vartype \\{ varname rq count
				 restore done@local \\}
       match =TBYTE, vartype \\{ varname rt count
				 restore done@local \\}
       match =DQWORD, vartype \\{ label varname dqword
				  rq count+count
				  restore done@local \\}
       match , done@local \\{ virtual
			       varname vartype
			      end virtual
			      rb count*sizeof.\#vartype
			      restore done@local \\} \}
    match :varname:vartype, done@local:var
    \{ match =BYTE, vartype \\{ varname db ?
				restore done@local \\}
       match =WORD, vartype \\{ varname dw ?
				restore done@local \\}
       match =DWORD, vartype \\{ varname dd ?
				 restore done@local \\}
       match =PWORD, vartype \\{ varname dp ?
				 restore done@local \\}
       match =QWORD, vartype \\{ varname dq ?
				 restore done@local \\}
       match =TBYTE, vartype \\{ varname dt ?
				 restore done@local \\}
       match =DQWORD, vartype \\{ label varname dqword
				  dq ?,?
				  restore done@local \\}
       match , done@local \\{ varname vartype
			      restore done@local \\} \}
    match ,done@local
    \{ var
       restore done@local \}
   common
    endl }
