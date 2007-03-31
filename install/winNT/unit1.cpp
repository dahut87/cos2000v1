//---------------------------------------------------------------------------
#include <windows.h>
#include <winbase.h>
#include <winioctl.h>
#include <io.h>
#include <stdio.h>
#include <fcntl.h>
#include <dir.h>
#pragma hdrstop

//---------------------------------------------------------------------------
char * GetLastErrorString(void)
{
	LPVOID lpMsgBuf;

	FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM,
		NULL, GetLastError(), MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
		(LPTSTR) &lpMsgBuf,	0, NULL);

	return (char *)lpMsgBuf;
}


#pragma argsused
int main(int argc, char* argv[])
{
DWORD dwNotUsed;
DWORD error=0;
HANDLE hDrive;
DISK_GEOMETRY dg_flop_geom;
char lecteur[4]="a:\0";
char device[7]="\\\\.\\a:\0";
int fdboot;
DWORD dwBsWritten;
char * buffer;
char bootfile[14]="data/boot.bin\0";
struct ffblk files;
int done;
int number=0;
char src[80];
char dest[80];
        printf("Installation de COS2000\nInserez une disquette et appuyer sur une touche...\n");
        getchar();
	hDrive = CreateFile(device, GENERIC_WRITE,FILE_SHARE_READ|FILE_SHARE_WRITE,NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL,NULL);
        printf("Ouverture du peripherique %s\n",lecteur);
        if (hDrive == INVALID_HANDLE_VALUE) {
	        printf("Erreur : %s\n",GetLastErrorString());
                error=1;
	}
        if(error!=1&&printf("Determination de la geometrie \n")&&DeviceIoControl(hDrive, IOCTL_DISK_GET_DRIVE_GEOMETRY, NULL,0, &dg_flop_geom, sizeof(dg_flop_geom),&dwNotUsed, NULL) == FALSE) {
 		printf("Erreur : %s\n",GetLastErrorString());
                error=1;
	}
        if(error!=1&&(dg_flop_geom.MediaType==FixedMedia||dg_flop_geom.MediaType==RemovableMedia||dg_flop_geom.MediaType==Unknown))
        {
         	printf("Erreur : Ceci n'est pas une disquette !\n");
                error=1;
        }
        if (error!=1&&printf("Positionnement sur le secteur 0\n")&&SetFilePointer(hDrive, 0, NULL, FILE_BEGIN) == -1) {
		printf("Erreur : %s\n",GetLastErrorString());
                error=1;
	}
        if (error!=1)
        {
        printf("Pistes :%u Secteurs:%u Tetes:%u Taille:%u\n",dg_flop_geom.Cylinders.LowPart,dg_flop_geom.SectorsPerTrack,dg_flop_geom.TracksPerCylinder,dg_flop_geom.BytesPerSector);
        }
        else
        {
        CloseHandle(hDrive);
        }
        if (hDrive == NULL||dg_flop_geom.TracksPerCylinder>2||dg_flop_geom.TracksPerCylinder==0)
        {
        printf("Aucun support valide detecte !");
        error=1;
        }
        if (error!=1)
        {
        printf("Allocation de memoire\n");
        buffer = (char *)malloc(dg_flop_geom.BytesPerSector);
        printf("Ouverture et installation du fichier de boot %s\n",bootfile);
        }
  	if (error!=1&&(fdboot = _rtl_open(bootfile,O_RDONLY | O_BINARY)) == -1 )
        {
		printf("Erreur : Fichier de boot introuvable\n");
                error=1;
	}
        if (error!=1&&_read(fdboot, buffer, dg_flop_geom.BytesPerSector)!= dg_flop_geom.BytesPerSector)
        {
		printf("Erreur : Fichier de boot de taille incorrecte !\n");
                error=1;
	}
        if (error!=1&&WriteFile(hDrive, buffer, dg_flop_geom.BytesPerSector, &dwBsWritten, NULL) == 0)
        {
               	printf("Ecriture impossible sur le secteur de boot !\n");
                error=1;
        }
        if (error!=1)
        {
        _rtl_close(fdboot);
        printf("Determination des fichiers a copier\n\n");
        done = findfirst("data\\*.*",&files,0);
        while (!done)
        {
        number++;
        done = findnext(&files);
        }
        printf("Copie des fichiers de cos2000\n");
        done = findfirst("data\\*.*",&files,0);
        while (!done)
        {
        printf("%s\n",files.ff_name);
        sprintf(src, "data\\%s",files.ff_name);
        sprintf(dest, "%s\\%s",lecteur,files.ff_name);
        if (!CopyFile(src,dest,false))
        {
           printf("Erreur : fichier impossible a copier %s\n",GetLastErrorString());
           error=1;
           break;
        }
        done = findnext(&files);
        }
        if (!error)
        {
        printf("Installation terminee !\nVeuillez redemarrer votre PC afin de charger le systeme");
        }
        else
        {
        printf("Installation echoué !");
        }
        free(buffer);
        }
        getchar();
        return 0;
}
//---------------------------------------------------------------------------
