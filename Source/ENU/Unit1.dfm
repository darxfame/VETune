object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'VE LogTuner'
  ClientHeight = 520
  ClientWidth = 879
  Color = clBtnFace
  Constraints.MaxHeight = 578
  Constraints.MaxWidth = 895
  Constraints.MinHeight = 530
  Constraints.MinWidth = 888
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object StringGrid2: TStringGrid
    Left = 7
    Top = 8
    Width = 873
    Height = 434
    ColCount = 17
    DefaultColWidth = 50
    RowCount = 17
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSizing, goColSizing]
    ScrollBars = ssNone
    TabOrder = 0
    OnDrawCell = StringGrid2DrawCell
    OnMouseDown = StringGrid2MouseDown
    OnMouseMove = StringGrid2MouseMove
    OnSelectCell = StringGrid2SelectCell
    RowHeights = (
      24
      24
      24
      24
      24
      24
      24
      24
      24
      24
      24
      24
      24
      24
      24
      24
      24)
  end
  object Panel1: TPanel
    Left = 64
    Top = 448
    Width = 177
    Height = 73
    BevelKind = bkTile
    TabOrder = 1
    object Label1: TLabel
      Left = 34
      Top = 5
      Width = 105
      Height = 13
      Caption = 'The initial value'
    end
    object Edit1: TEdit
      Left = 8
      Top = 21
      Width = 73
      Height = 21
      TabOrder = 0
      Text = '0.65'
    end
    object Button1: TButton
      Left = 8
      Top = 45
      Width = 161
      Height = 20
      Caption = 'Overwrite values'
      TabOrder = 1
      OnClick = Button1Click
    end
    object Button4: TButton
      Left = 96
      Top = 21
      Width = 73
      Height = 20
      Caption = 'Colorize'
      TabOrder = 2
      OnClick = Button4Click
    end
  end
  object Panel2: TPanel
    Left = 304
    Top = 448
    Width = 257
    Height = 73
    BevelKind = bkTile
    TabOrder = 2
    object Label2: TLabel
      Left = 6
      Top = 6
      Width = 243
      Height = 13
      Caption = 'Open and Save tables'
    end
    object Button2: TButton
      Left = 38
      Top = 25
      Width = 75
      Height = 37
      Caption = 'Open'
      TabOrder = 0
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 134
      Top = 25
      Width = 75
      Height = 37
      Caption = 'Save'
      Enabled = False
      TabOrder = 1
      OnClick = Button3Click
    end
  end
  object Panel3: TPanel
    Left = 622
    Top = 448
    Width = 251
    Height = 73
    BevelKind = bkTile
    TabOrder = 3
    object N10: TButton
      Left = 10
      Top = 25
      Width = 105
      Height = 37
      Caption = 'Calculate VE'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = N10Click
    end
    object N3DPlot2: TButton
      Left = 138
      Top = 25
      Width = 105
      Height = 37
      Caption = 'Chart VE'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = N3DPlot1Click
    end
    object CheckBox1: TCheckBox
      Left = 10
      Top = 5
      Width = 129
      Height = 17
      Caption = 'Last changes'
      Enabled = False
      TabOrder = 2
      OnClick = CheckBox1Click
    end
  end
  object BitBtn1: TBitBtn
    Left = 8
    Top = 483
    Width = 25
    Height = 39
    DoubleBuffered = True
    Glyph.Data = {
      CE040000424DCE04000000000000360000002800000012000000150000000100
      18000000000098040000000000000000000000000000000000008D847C68615C
      4D423D5249414C453E4F4942554A43554942534942544842544A43554A445548
      42534A43524C44504942524C4478706800005D5955656260786E6F737070676F
      6D676F6C6F6A6A6F67676E6C6B70696A6A6A696367666F6767726A6B67676769
      6A685B5A574D454100005C5A5AEAEAEAEAEAEAEAEAEA464646808080EAEAEAEA
      EAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEA464646808080EAEAEA595D58
      00006C6A69EAEAEAEAEAEAEAEAEA464646808080EAEAEAEAEAEAEAEAEAEAEAEA
      EAEAEAEAEAEAEAEAEAEAEAEA464646808080EAEAEA6969650000656362EAEAEA
      EAEAEAEAEAEA464646808080EAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEA
      EAEAEAEA464646808080EAEAEA6F646200006C69688080808080808080808080
      8080808080808080808080808080808080808080808080808080808080808080
      80808080806A686500006B696846464646464646464646464680808046464646
      4646464646464646464646464646464646464646464646808080464646686867
      00006A6867EAEAEAEAEAEAEAEAEA464646808080EAEAEAEAEAEAFF0000EAEAEA
      EAEAEAFF0000EAEAEAEAEAEA464646808080EAEAEA6C68680000706E6DEAEAEA
      EAEAEAEAEAEA464646808080EAEAEAFF0000FF0000EAEAEAEAEAEAFF0000FF00
      00EAEAEA464646808080EAEAEA6E6B6A00006B6968EAEAEAEAEAEAEAEAEA4646
      46808080FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF000046464680
      8080EAEAEA6E6B6A0000686665EAEAEAEAEAEAEAEAEA464646808080EAEAEAFF
      0000FF0000EAEAEAEAEAEAFF0000FF0000EAEAEA464646808080EAEAEA6E6B6A
      00006E6C6BEAEAEAEAEAEAEAEAEA464646808080EAEAEAEAEAEAFF0000EAEAEA
      EAEAEAFF0000EAEAEAEAEAEA464646808080EAEAEA726E6D0000716F6FEAEAEA
      EAEAEAEAEAEA464646808080EAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEA
      EAEAEAEA464646808080EAEAEA746F6E00006C6969EAEAEAEAEAEAEAEAEA4646
      46808080EAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEA46464680
      8080EAEAEA726E6D00006B696980808080808080808080808080808080808080
      8080808080808080808080808080808080808080808080808080808080727070
      00006C6A6A464646464646464646464646808080464646464646464646464646
      46464646464646464646464646464680808046464674727200006D6B6AEAEAEA
      EAEAEAEAEAEA464646808080EAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEA
      EAEAEAEA464646808080EAEAEA7572740000706E6EEAEAEAEAEAEAEAEAEA4646
      46808080EAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEA46464680
      8080EAEAEA7472730000706E6EEAEAEAEAEAEAEAEAEA464646808080EAEAEAEA
      EAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEAEA464646808080EAEAEA757575
      00006F6E6EEAEAEAEAEAEAEAEAEA464646808080EAEAEAEAEAEAEAEAEAEAEAEA
      EAEAEAEAEAEAEAEAEAEAEAEA464646808080EAEAEA868685000063615FA1A09F
      B2B3B1B2B4B1B5B7B6B6B6B7B7B5B8B7B4B7B7B3B5B7B4B5B7B4B5B6B3B4B6B3
      B4B4B3B5AEB1B2ACAFB1A7A9AB6F6C680000}
    ParentDoubleBuffered = False
    TabOrder = 4
    OnClick = BitBtn1Click
  end
  object MainMenu1: TMainMenu
    Left = 928
    Top = 8
    object N1: TMenuItem
      Caption = 'File'
      object N5: TMenuItem
        Caption = 'Open Log'
        OnClick = N5Click
      end
      object N12: TMenuItem
        Caption = 'Open VE.txt'
        OnClick = N12Click
      end
      object VEtxt1: TMenuItem
        Caption = 'Save VE.txt'
        OnClick = VEtxt1Click
      end
      object N8: TMenuItem
        Caption = 'Exit'
        OnClick = N8Click
      end
    end
    object N2: TMenuItem
      Caption = 'Menu VE'
      object N3: TMenuItem
        Caption = 'Open EEPROM'
        OnClick = Button2Click
      end
      object N4: TMenuItem
        Caption = 'Save EEPROM'
        Enabled = False
        OnClick = Button3Click
      end
      object N7: TMenuItem
        Caption = 'Calculate VE'
        Enabled = False
        OnClick = N10Click
      end
      object N6: TMenuItem
        Caption = 'Show changes'
        Enabled = False
        OnClick = N6Click
      end
    end
    object N3DPlot1: TMenuItem
      Caption = 'Chart VE'
      Enabled = False
      OnClick = N3DPlot1Click
    end
    object N9: TMenuItem
      Caption = 'Settings'
      OnClick = N9Click
    end
    object Help1: TMenuItem
      Caption = 'Help'
      OnClick = Help1Click
    end
    object N11: TMenuItem
      Caption = ' |'
      Enabled = False
    end
    object Log1: TMenuItem
      Caption = 'LOG:'
      Enabled = False
      Hint = 'Open Log File Name'
    end
    object EEPROM1: TMenuItem
      Caption = 'EEPROM:'
      Enabled = False
      Hint = 'The name of the open file and write EEPROM firmware'
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 1032
    Top = 8
  end
  object SaveDialog1: TSaveDialog
    Left = 984
    Top = 8
  end
  object OpenDialog2: TOpenDialog
    Left = 1032
    Top = 56
  end
  object OpenDialog3: TOpenDialog
    Left = 1032
    Top = 112
  end
  object SaveDialog2: TSaveDialog
    Left = 984
    Top = 56
  end
end
