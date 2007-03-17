//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <Menus.hpp>
#include <Dialogs.hpp>
#include <ComCtrls.hpp>
#include <ImgList.hpp>
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
        TMainMenu *MainMenu1;
        TMenuItem *Fichier1;
        TMenuItem *Ouvrir1;
        TOpenDialog *OpenDialog;
        TTreeView *TreeView;
        TImageList *ImageList;
        TMenuItem *N1;
        TMenuItem *Quitter1;
        TRichEdit *RichEdit1;
        void __fastcall Ouvrir1Click(TObject *Sender);
        void __fastcall Quitter1Click(TObject *Sender);
private:	// User declarations
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
 