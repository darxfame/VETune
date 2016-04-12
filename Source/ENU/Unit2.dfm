object Form2: TForm2
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Settings'
  ClientHeight = 334
  ClientWidth = 376
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label4: TLabel
    Left = 255
    Top = 14
    Width = 113
    Height = 13
    Caption = 'Switch language button'
  end
  object Button1: TButton
    Left = 62
    Top = 302
    Width = 129
    Height = 25
    Caption = 'Save settings'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Panel1: TPanel
    Left = 16
    Top = 8
    Width = 233
    Height = 89
    TabOrder = 1
    object Label1: TLabel
      Left = 72
      Top = 8
      Width = 95
      Height = 13
      Caption = 'Path to Log Files'
    end
    object Button2: TButton
      Left = 72
      Top = 54
      Width = 75
      Height = 25
      Caption = 'Point'
      TabOrder = 0
      OnClick = Button2Click
    end
    object Edit1: TEdit
      Left = 8
      Top = 27
      Width = 217
      Height = 21
      TabOrder = 1
    end
  end
  object Panel2: TPanel
    Left = 16
    Top = 103
    Width = 233
    Height = 89
    TabOrder = 2
    object Label2: TLabel
      Left = 56
      Top = 8
      Width = 119
      Height = 13
      Caption = 'The path to the EEPROM of the files'
    end
    object Button3: TButton
      Left = 72
      Top = 54
      Width = 75
      Height = 25
      Caption = 'Point'
      TabOrder = 0
      OnClick = Button3Click
    end
    object Edit2: TEdit
      Left = 8
      Top = 27
      Width = 217
      Height = 21
      TabOrder = 1
    end
  end
  object Panel3: TPanel
    Left = 16
    Top = 199
    Width = 233
    Height = 89
    TabOrder = 3
    object Label3: TLabel
      Left = 56
      Top = 8
      Width = 131
      Height = 13
      Caption = 'Path save EEPROM'
    end
    object Button4: TButton
      Left = 72
      Top = 54
      Width = 75
      Height = 25
      Caption = 'Point'
      TabOrder = 0
      OnClick = Button4Click
    end
    object Edit3: TEdit
      Left = 8
      Top = 27
      Width = 217
      Height = 21
      TabOrder = 1
    end
  end
  object LanguageEnglish: TButton
    Left = 272
    Top = 33
    Width = 75
    Height = 25
    Caption = 'English'
    TabOrder = 4
    OnClick = SwitchLanguage
  end
  object DirDialog1: TDirDialog
    NewFolder = True
    Left = 232
    Top = 384
  end
end
