//---------------------------------------------------------------------------

#include <vcl.h>
#include <math.h>
#include <stdio.h>
#pragma hdrstop

#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------
tree(AnsiString file,int offset,TTreeNode* rootnode)
{
FILE* in;
#pragma option -a1
struct CE {
char checks[2];
unsigned char major;
unsigned int checksum;
unsigned char compressed;
unsigned short exports;
unsigned short imports;
unsigned short sections;
unsigned short starting;
} myce;
#pragma option -a

long pointeur=0;

if ((in = fopen(file.c_str(), "rb"))!= NULL)
{
fseek(in, pointeur+offset, SEEK_SET);
fread(&myce, sizeof(myce), 1, in);
TTreeNode* currentnode;
TTreeNode* subcurrentnode;
TTreeNode* subsubcurrentnode;
if (offset==0)
{
fseek(in, 0L, SEEK_END);
Form1->TreeView->Items->AddChild(rootnode,"Adresse réelle: 0x0000")->ImageIndex=31;
Form1->TreeView->Items->AddChild(rootnode,"Adresse : 0x0000")->ImageIndex=31;
}
currentnode=Form1->TreeView->Items->AddChild(rootnode,"Entête");
currentnode->ImageIndex=10;
Form1->TreeView->Items->AddChild(currentnode,"Adresse réelle: 0x"+IntToHex((int)pointeur+offset,4))->ImageIndex=31;
Form1->TreeView->Items->AddChild(currentnode,"Adresse : 0x"+IntToHex((int)pointeur,4))->ImageIndex=31;
if (AnsiString(myce.checks,2)!="CE")
{
rootnode->ImageIndex=4;
Form1->TreeView->Items->AddChild(currentnode,"Type : ceci n'est pas un fichier CE")->ImageIndex=1;
}
else
{
rootnode->ImageIndex=2;
subcurrentnode=Form1->TreeView->Items->AddChild(currentnode,"Type : "+AnsiString(myce.checks,2));
Form1->TreeView->Items->AddChild(subcurrentnode,"Adresse réelle: 0x"+IntToHex((int)0+offset,4))->ImageIndex=31;
Form1->TreeView->Items->AddChild(subcurrentnode,"Adresse : 0x"+IntToHex((int)0,4))->ImageIndex=31;
Form1->TreeView->Items->AddChild(subcurrentnode,"Taille: 0x0002")->ImageIndex=31;
subcurrentnode=Form1->TreeView->Items->AddChild(currentnode,"Version : "+IntToStr(myce.major));
Form1->TreeView->Items->AddChild(subcurrentnode,"Adresse réelle: 0x"+IntToHex((int)2+offset,4))->ImageIndex=31;
Form1->TreeView->Items->AddChild(subcurrentnode,"Adresse : 0x"+IntToHex((int)2,4))->ImageIndex=31;
Form1->TreeView->Items->AddChild(subcurrentnode,"Taille: 0x0001")->ImageIndex=31;
subcurrentnode=Form1->TreeView->Items->AddChild(currentnode,"Checksum : 0x"+IntToHex((int)myce.checksum,8));
Form1->TreeView->Items->AddChild(subcurrentnode,"Adresse réelle: 0x"+IntToHex((int)3+offset,4))->ImageIndex=31;
Form1->TreeView->Items->AddChild(subcurrentnode,"Adresse : 0x"+IntToHex((int)3,4))->ImageIndex=31;
Form1->TreeView->Items->AddChild(subcurrentnode,"Taille: 0x0004")->ImageIndex=31;
if (myce.compressed>=1)
subcurrentnode=Form1->TreeView->Items->AddChild(currentnode,"Fichier compressé avec RIP");
else
subcurrentnode=Form1->TreeView->Items->AddChild(currentnode,"Fichier sans compression");
Form1->TreeView->Items->AddChild(subcurrentnode,"Adresse réelle: 0x"+IntToHex((int)7+offset,4))->ImageIndex=31;
Form1->TreeView->Items->AddChild(subcurrentnode,"Adresse : 0x"+IntToHex((int)7,4))->ImageIndex=31;
Form1->TreeView->Items->AddChild(subcurrentnode,"Taille: 0x0001")->ImageIndex=31;
subcurrentnode=Form1->TreeView->Items->AddChild(currentnode,"Pointeur exportation : 0x"+IntToHex(myce.exports,4));
Form1->TreeView->Items->AddChild(subcurrentnode,"Adresse réelle: 0x"+IntToHex((int)8+offset,4))->ImageIndex=31;
Form1->TreeView->Items->AddChild(subcurrentnode,"Adresse : 0x"+IntToHex((int)8,4))->ImageIndex=31;
Form1->TreeView->Items->AddChild(subcurrentnode,"Taille: 0x0002")->ImageIndex=31;
subcurrentnode=Form1->TreeView->Items->AddChild(currentnode,"Pointeur Importation : 0x"+IntToHex(myce.imports,4));
Form1->TreeView->Items->AddChild(subcurrentnode,"Adresse réelle: 0x"+IntToHex((int)10+offset,4))->ImageIndex=31;
Form1->TreeView->Items->AddChild(subcurrentnode,"Adresse : 0x"+IntToHex((int)10,4))->ImageIndex=31;
Form1->TreeView->Items->AddChild(subcurrentnode,"Taille: 0x0002")->ImageIndex=31;
subcurrentnode=Form1->TreeView->Items->AddChild(currentnode,"Pointeur sections : 0x"+IntToHex(myce.sections,4));
Form1->TreeView->Items->AddChild(subcurrentnode,"Adresse réelle: 0x"+IntToHex((int)12+offset,4))->ImageIndex=31;
Form1->TreeView->Items->AddChild(subcurrentnode,"Adresse : 0x"+IntToHex((int)12,4))->ImageIndex=31;
Form1->TreeView->Items->AddChild(subcurrentnode,"Taille: 0x0002")->ImageIndex=31;
subcurrentnode=Form1->TreeView->Items->AddChild(currentnode,"Point d'entrée : 0x"+IntToHex(myce.starting,4));
Form1->TreeView->Items->AddChild(subcurrentnode,"Adresse réelle: 0x"+IntToHex((int)14+offset,4))->ImageIndex=31;
Form1->TreeView->Items->AddChild(subcurrentnode,"Adresse : 0x"+IntToHex((int)14,4))->ImageIndex=31;
Form1->TreeView->Items->AddChild(subcurrentnode,"Taille: 0x0002")->ImageIndex=31;
Form1->TreeView->Items->AddChild(currentnode,"Taille : 0x0010")->ImageIndex=31;

char imported[30];
AnsiString imports[30]={""};
AnsiString exports[30]={""};
AnsiString sections[30]={""};
unsigned short iaddrs[30]={0};
unsigned short eaddrs[30]={0};
unsigned short saddrs[30]={0};
unsigned short ssize[30]={0};
AnsiString libraries[30]={""};
AnsiString alib;
int i=0;
pointeur=myce.imports;
int nblib=0;
int nbimp=0;

if (myce.imports!=0)
{
currentnode=Form1->TreeView->Items->AddChild(rootnode,"Importations");
currentnode->ImageIndex=14;
Form1->TreeView->Items->AddChild(currentnode,"Adresse réelle: 0x"+IntToHex((int)pointeur+offset,4))->ImageIndex=31;
Form1->TreeView->Items->AddChild(currentnode,"Adresse : 0x"+IntToHex((int)pointeur,4))->ImageIndex=31;
do
{
fseek(in, pointeur+offset, SEEK_SET);
fread(&imported, sizeof(imported), 1, in);
imports[i]=AnsiString((char*)&imported);
iaddrs[i]=pointeur;
pointeur+=imports[i].Length()+5;
alib=imports[i].SubString(0,imports[i].Pos(":")-1);
int j;
for(j=0;(j<nblib)&&(alib!=libraries[j])&&(libraries[j]!="");j++);
if ((libraries[j]=="")&&(alib!="")) {
libraries[j]=alib;
nblib++;
}
i++;
} while(imports[i-1]!="");
nbimp=i-1;
for(int i=0;i<nblib;i++)
{
subcurrentnode=Form1->TreeView->Items->AddChild(currentnode,libraries[i]);
subcurrentnode->ImageIndex=13;
for(int j=0;j<nbimp;j++)
{
if (imports[j].SubString(0,imports[j].Pos(":")-1)==libraries[i])
{
subsubcurrentnode=Form1->TreeView->Items->AddChild(subcurrentnode,imports[j].SubString(imports[j].Pos(":")+2,255));
subsubcurrentnode->ImageIndex=3;
Form1->TreeView->Items->AddChild(subsubcurrentnode,"Adresse réelle: 0x"+IntToHex((int)iaddrs[j]+offset,4))->ImageIndex=31;
Form1->TreeView->Items->AddChild(subsubcurrentnode,"Adresse : 0x"+IntToHex((int)iaddrs[j],4))->ImageIndex=31;
}
}
}
currentnode->Text="importations ("+IntToStr(nbimp)+"/"+IntToStr(nblib)+")";
Form1->TreeView->Items->AddChild(currentnode,"Taille : 0x"+IntToHex((int)pointeur-myce.imports,4))->ImageIndex=31;
}
else
{
nbimp=0;
}

i=0;
pointeur=myce.exports;
int nbexp=0;

if (myce.exports!=0)
{
currentnode=Form1->TreeView->Items->AddChild(rootnode,"Exportations");
currentnode->ImageIndex=14;
Form1->TreeView->Items->AddChild(currentnode,"Adresse réelle: 0x"+IntToHex((int)pointeur+offset,4))->ImageIndex=31;
Form1->TreeView->Items->AddChild(currentnode,"Adresse : 0x"+IntToHex((int)pointeur,4))->ImageIndex=31;
do
{
fseek(in, pointeur+offset, SEEK_SET);
fread(&imported, sizeof(imported), 1, in);
exports[i]=AnsiString((char*)&imported);
pointeur+=exports[i].Length()+1;
fseek(in, pointeur+offset, SEEK_SET);
fread(&eaddrs[i],sizeof(eaddrs[i]),1,in);
pointeur+=2;
i++;
} while(exports[i-1]!="");

nbexp=i-1;

for(int i=0;i<nbexp;i++)
{
subcurrentnode=Form1->TreeView->Items->AddChild(currentnode,exports[i]);
subcurrentnode->ImageIndex=3;
Form1->TreeView->Items->AddChild(subcurrentnode,"Adresse réelle: 0x"+IntToHex(eaddrs[i]+offset,4))->ImageIndex=31;
Form1->TreeView->Items->AddChild(subcurrentnode,"Adresse : 0x"+IntToHex(eaddrs[i],4))->ImageIndex=31;
}
currentnode->Text="exportations ("+IntToStr(nbexp)+")";
Form1->TreeView->Items->AddChild(currentnode,"Taille : 0x"+IntToHex((int)pointeur-myce.exports,4))->ImageIndex=31;
}
else
{
nbexp=0;
}

pointeur=myce.sections;
i=0;
int nbsec=0;

if (myce.sections!=0)
{
currentnode=Form1->TreeView->Items->AddChild(rootnode,"Sections");
currentnode->ImageIndex=12;
Form1->TreeView->Items->AddChild(currentnode,"Adresse réelle: 0x"+IntToHex((int)pointeur+offset,4))->ImageIndex=31;
Form1->TreeView->Items->AddChild(currentnode,"Adresse : 0x"+IntToHex((int)pointeur,4))->ImageIndex=31;
do
{
fseek(in, pointeur+offset, SEEK_SET);
fread(&saddrs[i],sizeof(saddrs[i]),1,in);
pointeur+=2;
fseek(in, pointeur+offset, SEEK_SET);
fread(&ssize[i],sizeof(ssize[i]),1,in);
pointeur+=2;
fseek(in, pointeur+offset, SEEK_SET);
fread(&imported, sizeof(imported), 1, in);
sections[i]=AnsiString((char*)&imported);
pointeur+=sections[i].Length()+1;
i++;
} while(ssize[i-1]!=0);
nbsec=i-1;
for(int i=0;i<nbsec;i++)
{
subcurrentnode=Form1->TreeView->Items->AddChild(currentnode,sections[i]);
Form1->TreeView->Items->AddChild(subcurrentnode,"Adresse réelle: 0x"+IntToHex(saddrs[i]+offset,4))->ImageIndex=31;
Form1->TreeView->Items->AddChild(subcurrentnode,"Adresse : 0x"+IntToHex(saddrs[i],4))->ImageIndex=31;
if (saddrs[i]!=0) tree(file,saddrs[i],subcurrentnode);
subcurrentnode->ImageIndex=2;
Form1->TreeView->Items->AddChild(subcurrentnode,"Taille : 0x"+IntToHex(ssize[i],4))->ImageIndex=31;
}
Form1->TreeView->Items->AddChild(currentnode,"Taille : 0x"+IntToHex((int)pointeur-myce.sections,4))->ImageIndex=31;
currentnode->Text="Sections ("+IntToStr(nbsec)+")";
}
else
{
nbsec=0;
}

if (offset==0)
{
fseek(in, 0L, SEEK_END);
int size = ftell(in);
Form1->TreeView->Items->AddChild(rootnode,"Taille : 0x"+IntToHex(size,4))->ImageIndex=31;
}
}
fclose(in);
}
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Ouvrir1Click(TObject *Sender)
{
if (OpenDialog->Execute())
tree(OpenDialog->FileName,0,Form1->TreeView->Items->Add(Form1->TreeView->Items->GetFirstNode(),ExtractFileName(OpenDialog->FileName)));
TTreeNode* node=Form1->TreeView->Items->GetFirstNode();
while(node!=NULL)
{
node->SelectedIndex=node->ImageIndex;
node=node->GetNext();
}
}

//---------------------------------------------------------------------------

void __fastcall TForm1::Quitter1Click(TObject *Sender)
{
Close();        
}
//---------------------------------------------------------------------------


