//---------------------------------------------------------------------------

#include <vcl.h>
#include <winioctl.h>
#include <io.h>
#include <fcntl.h>
#include <dir.h>
#pragma hdrstop

#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TForm1 *Form1;
HANDLE hDrive;
DISK_GEOMETRY dg_flop_geom;
AnsiString lecteur="b:";
AnsiString device="\\\\.\\"+lecteur;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------
char * GetLastErrorString(void)
{
	LPVOID lpMsgBuf;

	FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM,
		NULL, GetLastError(), MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
		(LPTSTR) &lpMsgBuf,	0, NULL);

	return (char *)lpMsgBuf;
}
//---------------------------------------------------------------------------
ShowMessages(AnsiString msg)
{
        Form1->Memo1->Lines->Add(msg);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::FormShow(TObject *Sender)
{
DWORD dwNotUsed;
DWORD error=0;

	hDrive = CreateFile(device.c_str(), GENERIC_WRITE,FILE_SHARE_READ|FILE_SHARE_WRITE,NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL,NULL);
        ShowMessages("Ouverture du peripherique "+lecteur);
        if (hDrive == INVALID_HANDLE_VALUE) {
	        ShowMessages("Erreur : "+AnsiString(GetLastErrorString()));
                error=1;
	}
        if(error!=1&&ShowMessages("Determination de la geometrie ")&&DeviceIoControl(hDrive, IOCTL_DISK_GET_DRIVE_GEOMETRY, NULL,0, &dg_flop_geom, sizeof(dg_flop_geom),&dwNotUsed, NULL) == FALSE) {
 		ShowMessages("Erreur : "+AnsiString(GetLastErrorString()));
                error=1;
	}
        if(error!=1&&(dg_flop_geom.MediaType==FixedMedia||dg_flop_geom.MediaType==RemovableMedia||dg_flop_geom.MediaType==Unknown))
        {
         	ShowMessages("Erreur : Ceci n'est pas une disquette !");
                error=1;
        }
        if (error!=1&&ShowMessages("Positionnement sur le secteur 0")&&SetFilePointer(hDrive, 0, NULL, FILE_BEGIN) == -1) {
		ShowMessages("Erreur : "+AnsiString(GetLastErrorString()));
                error=1;
	}
        if (error!=1)
        {
        drive->Caption=lecteur.UpperCase();
        track->Caption=IntToStr(dg_flop_geom.Cylinders.LowPart);
        sector->Caption=IntToStr(dg_flop_geom.SectorsPerTrack);
        size->Caption=IntToStr(dg_flop_geom.BytesPerSector);
        head->Caption=IntToStr(dg_flop_geom.TracksPerCylinder);
        allsize->Caption=IntToStr(dg_flop_geom.BytesPerSector*dg_flop_geom.Cylinders.LowPart*dg_flop_geom.SectorsPerTrack*dg_flop_geom.TracksPerCylinder);
        allsector->Caption=IntToStr(dg_flop_geom.Cylinders.LowPart*dg_flop_geom.SectorsPerTrack*dg_flop_geom.TracksPerCylinder);
        }
        else
        {
        CloseHandle(hDrive);
        }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button1Click(TObject *Sender)
{
 if (hDrive == NULL||dg_flop_geom.TracksPerCylinder>2||dg_flop_geom.TracksPerCylinder==0)

 {
  ShowMessages("Aucun support valide detecté !");
 }
 else
 {
 int fdboot;
 DWORD error=0;
 DWORD dwBsWritten;
 char * buffer;
 AnsiString bootfile="data/boot.bin";
        ShowMessages("Allocation de mémoire ");
        buffer = (char *)malloc(dg_flop_geom.BytesPerSector);
        ShowMessages("Ouverture et installation du fichier de boot "+bootfile);
  	if ((fdboot = _rtl_open(bootfile.c_str(),O_RDONLY | O_BINARY)) == -1 )
        {
		ShowMessages("Erreur : Fichier de boot introuvable");
                error=1;
	}
        if (error!=1&&_read(fdboot, buffer, dg_flop_geom.BytesPerSector)!= dg_flop_geom.BytesPerSector)
        {
		ShowMessages("Erreur : Fichier de boot de taille incorrecte !");
                error=1;
	}
        if (error!=1&&WriteFile(hDrive, buffer, dg_flop_geom.BytesPerSector, &dwBsWritten, NULL) == 0)
        {
               	ShowMessages("Ecriture impossible sur le secteur de boot !");
                error=1;
        }
        _rtl_close(fdboot);
        if (error!=1)
        {
        struct ffblk files;
        int done;
        int number=0;
        ShowMessages("Détermination des fichiers a copier");
        done = findfirst("data/*.*",&files,0);
        while (!done)
        {
        number++;
        done = findnext(&files);
        }
        install->Max=number;
        install->Min=0;
        install->Position=0;
        ShowMessages("Copie des fichiers de cos2000");
        done = findfirst("data/*.*",&files,0);
        while (!done)
        {
        ShowMessages(AnsiString(files.ff_name).LowerCase());
        if (!CopyFile((AnsiString("data/")+AnsiString(files.ff_name)).c_str(),(lecteur+"\\"+AnsiString(files.ff_name)).c_str(),false))
        {
           ShowMessages("Erreur : fichier impossible a copier"+AnsiString(GetLastErrorString()));
           error=1;
           break;
        }
        done = findnext(&files);
        install->Position++;
        }
        if (!error)
        {
        ShowMessages("Installation terminée !");
        Button2->Visible=false;
        Button1->Visible=false;
        Button3->Visible=true;
        }
        else
        ShowMessages("Installation echoué !");
        }
        free(buffer);
 }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::FormClose(TObject *Sender, TCloseAction &Action)
{
      CloseHandle(hDrive);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button3Click(TObject *Sender)
{
Close();
}
//---------------------------------------------------------------------------
