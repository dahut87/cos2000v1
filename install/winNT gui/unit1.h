//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ComCtrls.hpp>
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
        TButton *Button1;
        TProgressBar *install;
        TButton *Button2;
        TMemo *Memo1;
        TGroupBox *GroupBox1;
        TLabel *track;
        TLabel *Label4;
        TLabel *Label5;
        TLabel *sector;
        TLabel *head;
        TLabel *Label6;
        TLabel *Label8;
        TLabel *size;
        TGroupBox *GroupBox2;
        TLabel *Label1;
        TLabel *drive;
        TLabel *Label2;
        TLabel *allsize;
        TLabel *Label3;
        TLabel *allsector;
        TButton *Button3;
        void __fastcall FormShow(TObject *Sender);
        void __fastcall Button1Click(TObject *Sender);
        void __fastcall FormClose(TObject *Sender, TCloseAction &Action);
        void __fastcall Button3Click(TObject *Sender);
private:	// User declarations
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
