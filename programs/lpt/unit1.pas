unit Unit1;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Grids, Outline, DirOutln, FileCtrl, Buttons,
  Gauges, ExtCtrls, Spin, Mask;

type
  TForm1 = class(TForm)
    DriveComboBox1: TDriveComboBox;
    FilterComboBox1: TFilterComboBox;
    FileListBox1: TFileListBox;
    DirectoryListBox1: TDirectoryListBox;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Memo1: TMemo;
    Memo2: TMemo;
    Memo3: TMemo;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    Gauge1: TGauge;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpinButton1: TSpinButton;
    MaskEdit1: TMaskEdit;
    SpeedButton8: TSpeedButton;
    SpinButton2: TSpinButton;
    okm: TCheckBox;
    Label1: TLabel;
    procedure FormActivate(Sender: TObject);
    procedure SpinButton1DownClick(Sender: TObject);
    procedure SpinButton1UpClick(Sender: TObject);
    procedure showadress(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure SpeedButton8Click(Sender: TObject);
    procedure MaskEdit1Change(Sender: TObject);
    procedure SpinButton2DownClick(Sender: TObject);
    procedure SpinButton2UpClick(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure Memo2Click(Sender: TObject);

  private
    { Private-déclarations }
  public                                            
    { Public-déclarations }
  end;

const UNESEC       =  1000;
      DIXSEC       =  4000;
      ACK          = $00;
      NAK          = $FF;
      MAXTRY      = 5;

type DBloc = array[ 1..15534 ] of byte;
type BHEADER = record
                 case boolean of
                   true  : (  Checksum:byte;
                              Lenb   : byte;
                              Lenh   : byte;
                              Token : byte;

                              );
                   false : ( Champ  : array[ 0..3 ] of byte );
               end;

var
 Form1: TForm1;
 Inlpt       : word;
 Outlpt      : word;
 times : longint;
 Block      : DBLOC;
 adress     :longint;
 errors: boolean;
 reste:integer;
 pop:boolean;

implementation

{$R *.DFM}

function Getlpt( Number : integer ) : boolean;
begin
  Outlpt := MemW[ $0040: 6 + Number * 2 ];
  if ( Outlpt <> 0 ) then
    begin
      Inlpt := Outlpt + 1;
      Getlpt := TRUE;
    end
  else
  Getlpt := FALSE;
end;

function getfirstlpt:byte;
var i:integer;
begin
i:=1;
 while (not(getlpt(i)) or (i>4)) do inc(i);
 if (getlpt(i)=false) then i:=0;
 getfirstlpt:= i;
end;

function getb:byte;
begin
  getb:=port[inlpt] and $F8
end;

procedure putb(what:byte);
begin
  port[outlpt]:=what;
end;

procedure starttimer;
begin
   times:=GetTickCount;
end;

function endtimer:longint;
begin
   endtimer:=getTickCount-times; 
end;

function Initlpt( Emetteur : boolean ) : boolean;
begin
   errors:=false;
   putb($10);
   putb($18);
   putb($10);
   starttimer;
   if ( Emetteur ) then
    begin
         while ( ( GetB <> $00 ) and ( Endtimer <= DIXSEC ) ) do;
    end
  else
    begin
      while ( ( GetB <> $00 ) and ( Endtimer <= DIXSEC ) ) do;
      PutB( $10 );
    end;
   Initlpt := ( Endtimer <= DIXSEC );
end;

function sendlpt( Wert : byte ) : boolean;
var Retour : byte;
label fin;
begin
if errors then goto fin;
  Starttimer;
  PutB( Wert and $0F );
  while ( ( ( GetB and 128 ) = 0 ) and ( Endtimer <= DIXSEC  )) do;
  if ( Endtimer > DIXSEC  ) then
  begin
  errors:=true;
  goto fin;
  end;
  Retour := ( GetB shr 3 ) and $0F;
  Starttimer;
  PutB( ( Wert shr 4 ) or $10 );
  while ( ( ( GetB and 128 ) <> 0 ) and ( Endtimer <= DIXSEC ) ) do
 if ( Endtimer > DIXSEC  ) then
  begin
  errors:=true;
  goto fin;
  end;
  Retour := Retour or ( ( GetB shl 1 ) and $F0 );
  fin:
  sendlpt :=  ( Wert = Retour );
end;

function receivelpt : byte;
var LoNib,
    HiNib : byte;
label fin;
begin
  if errors then goto fin;
  Starttimer;
  while ( ( ( GetB and 128 ) = 0 ) and ( Endtimer <= DIXSEC )) do;
  if ( Endtimer > DIXSEC  ) then
  begin
  errors:=true;
  goto fin;
  end;
  LoNib := ( GetB shr 3 ) and $0F;
  PutB( LoNib );
  Starttimer;
  while ( ( ( GetB and 128 ) <> 0 ) and ( Endtimer <= DIXSEC ) ) do;
  if ( Endtimer > DIXSEC  ) then
  begin
   errors:=true;
  goto fin;
  end;
  HiNib := ( GetB shl 1 ) and $F0;
  PutB( ( HiNib shr 4 ) or $10 );
  fin:
  receivelpt := ( LoNib or HiNib );
end;

function checksum8(Nombre:word;Dptr : pointer):byte ;
var donnees : ^DBloc ;
    i:word;
    ch:byte;
begin
ch:=0;
donnees:=dptr;
 for i:=1 to Nombre do ch:=ch + Donnees^[ i ];
 checksum8:=ch;
 end;

function SendlptBlock( Token  : byte;
                    Nombre : word;
                    Dptr   : pointer ):boolean;
var header     : BHEADER;
    ok         : boolean;
    i          : word;
    trys        : word;
    Donnees      : ^DBloc;
    label fin;
begin
 form1.gauge1.visible:=true;
  header.Token := Token;
  header.Lenb := (Nombre and $FF00) shr 8;
  header.Lenh := Nombre and $FF;
  header.Checksum:=checksum8(nombre,Dptr);
  trys := MAXTRY;
  repeat
    ok := TRUE;
    for i := 0 to 3 do
      ok := ok and sendlpt( Header.Champ[ i ] );
    if ( ok ) then
      ok := ok and sendlpt( ACK )
    else
      ok := ok and sendlpt( NAK );
    if ( not ok ) then
      dec( trys );
  until ( ( ok ) or ( trys =  0 ) or (errors));
  if ( (trys = 0) or (errors)) then
    begin
    goto fin;
    SendlptBlock:=false;
  end;
  if ( Nombre > 0 ) then
    begin
      Donnees := DPTR;
      trys := MAXTRY;
      repeat
    ok := TRUE;
        for i := Nombre downto 1 do
          begin
          ok := ok and sendlpt( Donnees^[ i ] );
          reste:=trunc(100-i/nombre*100);
          form1.gauge1.progress:=reste
          end;
        if ( ok ) then
      ok := ok and sendlpt( ACK )
        else
      ok := ok and sendlpt( NAK );
    if ( not ok ) then
      dec( trys );
      until ( ( ok ) or ( trys =  0 ) or (errors));
  if ( (trys = 0) or (errors)) then
    begin
    goto fin;
    SendlptBlock:=false;
   end;
    end;
     SendlptBlock:=true;
    fin:
    form1.gauge1.visible:=false;
end;

function ReceivelptBlock( var Token : byte;
                         var Len   : word;
                             Dptr  : pointer ):boolean;
var header       : BHEADER;
    ok           : boolean;
    i            : word;
    trys          : word;
    EscapeStatus : boolean;
    ByteBuffer   : byte;
    Donnees        : ^DBloc;
    label fin,good;
begin
 form1.gauge1.visible:=true;
   trys := MAXTRY;
  repeat
    for i:= 0 to 3 do
      Header.Champ[ i ] := receivelpt;
    ByteBuffer := receivelpt;
    if ( ByteBuffer <> ACK ) then
      dec( trys );
  until ( ( trys = 0 ) or ( ByteBuffer = ACK )  or (errors));
   if ( (trys = 0)  or (errors)) then
    begin
    goto fin;
    receivelptblock:=false;
  end;
  Token := Header.Token;
  Len := Header.Lenh+(Header.Lenb shl 8);
   if ( Len > 0 ) then
    begin
      Donnees := Dptr;
      trys := MAXTRY;
      repeat
        for i := len downto 1 do
        begin
         Donnees^[ i ] := receivelpt;
         reste:=trunc(100-i/len*100);
         form1.gauge1.progress:=reste
        end;
         ByteBuffer := receivelpt;
     if ( ByteBuffer <> ACK ) then
       dec( trys );
      until ( ( trys = 0 ) or ( ByteBuffer = ACK ) );
    if ( trys = 0 ) then
    begin
    goto fin;
    receivelptblock:=false;
    end;
    end;
    receivelptblock:=true;
    fin:
    form1.gauge1.visible:=false;
end;


function Sendfile(name:string):boolean;
var lus:word;
Fichier:file;
begin
assign( Fichier, Name );
reset( Fichier, 1 );
Blockread( Fichier, Block, 15000, Lus );
if lus>0 then
Sendfile:=SendlptBlock( 1, Lus, @Block )
else
Sendfile:=false;
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
adress:=0;
showadress(sender);
Memo2Click(Sender);
SpeedButton8Click(Sender);
pop:=true;
end;

procedure TForm1.SpinButton1DownClick(Sender: TObject);
begin
if (adress>0) and okm.checked then
begin
dec(adress);
SpeedButton6Click(Sender);
end;
end;

procedure TForm1.SpinButton1UpClick(Sender: TObject);
begin
if (adress<65536*16) and okm.checked then
begin
inc(adress);
SpeedButton6Click(Sender);
end;
end;

function hextoint(hex:string;n:word):longint;
var
resu,exp:longint;
i:word;
begin
 hex :=UpperCase(hex);
 resu:=0;
 exp:=1;
  for i:=n downto 1 do
  begin
  resu:=resu+(Pos(hex[i],'0123456789ABCDEF')-1)*(exp);
  exp:=exp*16
 end;
 hextoint:=resu;
 end ;

 function adresstoint(hex:string):longint;
begin
adresstoint:=hextoint(Copy(hex, 1, 4),4)shl 4 + hextoint(Copy(hex, length(hex)-3, 4),4)
end;

procedure TForm1.showadress(Sender: TObject);
var i,j,adh,adl:word;
adress2:longint;
old,old2:string;
begin
memo1.clear;
memo2.clear;
memo3.clear;
for i:=0 to 29 do
begin
adress2:=adress+i*16;
adl:=adress2 and $FFFF;
adh:=(adress2 and $F0000) shr 4;
memo1.lines.add(IntToHex(adh,4)+':'+IntToHex(adl,4)) ;
old:='';
old2:='';
for j:=1 to 16 do
begin
old:=old+inttohex(block[i*16+j],2);
if block[i*16+j]=0 then
old2:=old2+'.'
else
old2:=old2+char(block[i*16+j]) ;
if j mod 2=0 then old:=old+' ';
end;
memo2.lines.add(old) ;
memo3.lines.add(old2) ;
end
end;

procedure TForm1.SpeedButton8Click(Sender: TObject);
begin
if getfirstlpt=0 then showmessage('Pas de port parallèle détecté');
errors:=false;
end;

procedure TForm1.SpeedButton6Click(Sender: TObject);
var adl,adh,good:word;
tok:byte;
ok:boolean;
begin
if (inlpt=0) then SpeedButton8Click(sender);
if ((inlpt<>0) and (initlpt(true)))  then
begin
 adl:=adress and $FFFF;
 adh:=(adress and $F0000) shr 4;
Block[1]:=lo(adl);
Block[2]:= hi(adl);
Block[3]:= lo(adh);
Block[4]:= hi(adh);
Block[5]:= lo(512);
Block[6]:= hi(512) ;
ok:=false;
if SendlptBlock( 1,6,@Block) then ok:=receivelptBlock(tok,good ,@Block);  {demande de RAM}
if not(ok) or errors then Showmessage('Erreur de transmission !!!!!!!!!!');
showadress(sender);
end
else
Showmessage('Pas de PC distant');
putb($08);
errors:=false;
end;

procedure TForm1.MaskEdit1Change(Sender: TObject);
begin
if pop then
begin
adress:=adresstoint(maskedit1.text);
if okm.checked=true then SpeedButton6Click(sender);
showadress(sender);
end;
end;

procedure TForm1.SpinButton2DownClick(Sender: TObject);
begin
  if (adress+16*30<=65536*16) and okm.checked then
  begin
  adress:=adress+16*30;
SpeedButton6Click(Sender);
end;
end;

procedure TForm1.SpinButton2UpClick(Sender: TObject);
begin
 if (adress-16*30>=0) and okm.checked then
 begin
 adress:=adress-16*30;
SpeedButton6Click(Sender);
end;
end;
procedure TForm1.SpeedButton3Click(Sender: TObject);
var adl,adh,good:word;
adress2:longint;
tok:byte;
ok:boolean;
begin
if (inlpt=0) then SpeedButton8Click(sender);
if ((inlpt<>0) and (initlpt(true)))  then
begin
 adress2 :=adresstoint(maskedit1.text);
 adl:=adress2 and $FFFF;
 adh:=(adress2 and $F0000) shr 4;
Block[1]:=lo(adl);
Block[2]:= hi(adl);
Block[3]:= lo(adh);
Block[4]:= hi(adh);
ok:=SendlptBlock( 7,4,@Block);
if not(ok) or errors then Showmessage('Erreur de transmission !!!!!!!!!!');
end
else
Showmessage('Pas de PC distant');
putb($18);
errors:=false;
end;
procedure TForm1.Memo2Click(Sender: TObject);
var ligne,col,pos,adl,adh:word;
adress2:longint;
begin
 ligne:=memo2.selstart div 42;
 col:= (trunc((memo2.selstart mod 42+1) / 2.5));
 pos:=16*ligne+col;
 label1.caption:=inttostr(ligne)+':'+inttostr(col)+':'+inttostr(pos);
 adress2:=pos+adress;
 adl:=adress2 and $FFFF;
 adh:=(adress2 and $F0000) shr 4;
 pop:=false;
 maskedit1.text:=inttohex(adh,4)+':'+inttohex(adl,4);
 pop:=true;
end;

end.
