object Form1: TForm1
  Left = 418
  Top = 273
  Width = 599
  Height = 371
  Caption = 'Installation de COS2000'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 288
    Top = 304
    Width = 75
    Height = 25
    Caption = 'installer...'
    TabOrder = 0
    OnClick = Button1Click
  end
  object install: TProgressBar
    Left = 16
    Top = 264
    Width = 553
    Height = 25
    Min = 0
    Max = 100
    TabOrder = 1
  end
  object Button2: TButton
    Left = 208
    Top = 304
    Width = 75
    Height = 25
    Caption = 'support'
    TabOrder = 2
    OnClick = FormShow
  end
  object Memo1: TMemo
    Left = 192
    Top = 24
    Width = 377
    Height = 225
    ReadOnly = True
    TabOrder = 3
  end
  object GroupBox1: TGroupBox
    Left = 16
    Top = 120
    Width = 161
    Height = 129
    Caption = 'G'#233'om'#233'trie'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    object track: TLabel
      Left = 96
      Top = 60
      Width = 31
      Height = 13
      Caption = 'Aucun'
    end
    object Label4: TLabel
      Left = 24
      Top = 60
      Width = 34
      Height = 13
      Caption = 'Pistes :'
    end
    object Label5: TLabel
      Left = 24
      Top = 28
      Width = 48
      Height = 13
      Caption = 'Secteurs :'
    end
    object sector: TLabel
      Left = 96
      Top = 28
      Width = 31
      Height = 13
      Caption = 'Aucun'
    end
    object head: TLabel
      Left = 96
      Top = 44
      Width = 31
      Height = 13
      Caption = 'Aucun'
    end
    object Label6: TLabel
      Left = 24
      Top = 44
      Width = 33
      Height = 13
      Caption = 'Tetes :'
    end
    object Label8: TLabel
      Left = 24
      Top = 84
      Width = 69
      Height = 13
      Caption = 'Taille secteur :'
    end
    object size: TLabel
      Left = 96
      Top = 84
      Width = 31
      Height = 13
      Caption = 'Aucun'
    end
  end
  object GroupBox2: TGroupBox
    Left = 16
    Top = 16
    Width = 161
    Height = 97
    Caption = 'Support'
    TabOrder = 5
    object Label1: TLabel
      Left = 24
      Top = 24
      Width = 42
      Height = 13
      Caption = 'Lecteur :'
    end
    object drive: TLabel
      Left = 88
      Top = 24
      Width = 31
      Height = 13
      Caption = 'Aucun'
    end
    object Label2: TLabel
      Left = 24
      Top = 40
      Width = 31
      Height = 13
      Caption = 'Taille :'
    end
    object allsize: TLabel
      Left = 88
      Top = 40
      Width = 31
      Height = 13
      Caption = 'Aucun'
    end
    object Label3: TLabel
      Left = 24
      Top = 56
      Width = 58
      Height = 13
      Caption = 'N'#176'secteurs :'
    end
    object allsector: TLabel
      Left = 88
      Top = 56
      Width = 31
      Height = 13
      Caption = 'Aucun'
    end
  end
  object Button3: TButton
    Left = 248
    Top = 304
    Width = 75
    Height = 25
    Caption = 'Quitter'
    TabOrder = 6
    Visible = False
    OnClick = Button3Click
  end
end
