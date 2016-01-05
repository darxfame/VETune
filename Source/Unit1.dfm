object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'VE LogTuner'
  ClientHeight = 512
  ClientWidth = 888
  Color = clBtnFace
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
  object Label1: TLabel
    Left = 45
    Top = 453
    Width = 105
    Height = 13
    Caption = #1053#1072#1095#1072#1083#1100#1085#1086#1077' '#1079#1085#1072#1095#1077#1085#1080#1077
  end
  object Label2: TLabel
    Left = 302
    Top = 453
    Width = 243
    Height = 13
    Caption = #1054#1090#1082#1088#1099#1090#1100' '#1080' '#1089#1086#1093#1088#1072#1085#1080#1090#1100' '#1087#1088#1086#1084#1077#1078#1091#1090#1086#1095#1085#1099#1077' '#1090#1072#1073#1083#1080#1094#1099
  end
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
  object Edit1: TEdit
    Left = 24
    Top = 477
    Width = 65
    Height = 21
    TabOrder = 1
    Text = '0.65'
  end
  object Button1: TButton
    Left = 104
    Top = 472
    Width = 75
    Height = 33
    Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 337
    Top = 470
    Width = 75
    Height = 37
    Caption = #1054#1090#1082#1088#1099#1090#1100
    TabOrder = 3
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 431
    Top = 470
    Width = 75
    Height = 37
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
    Enabled = False
    TabOrder = 4
    OnClick = Button3Click
  end
  object N10: TButton
    Left = 656
    Top = 470
    Width = 105
    Height = 37
    Caption = #1056#1072#1089#1089#1095#1080#1090#1072#1090#1100' VE'
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 5
    OnClick = N10Click
  end
  object N3DPlot2: TButton
    Left = 767
    Top = 470
    Width = 105
    Height = 37
    Caption = #1043#1088#1072#1092#1080#1082' VE'
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 6
    OnClick = N3DPlot1Click
  end
  object CheckBox1: TCheckBox
    Left = 656
    Top = 447
    Width = 129
    Height = 17
    Caption = #1055#1086#1089#1083#1077#1076#1085#1080#1077' '#1080#1079#1084#1077#1085#1077#1085#1080#1103
    Enabled = False
    TabOrder = 7
    OnClick = CheckBox1Click
  end
  object MainMenu1: TMainMenu
    Left = 928
    Top = 8
    object N1: TMenuItem
      Caption = #1060#1072#1081#1083
      object N5: TMenuItem
        Caption = #1054#1090#1082#1088#1099#1090#1100
        OnClick = N5Click
      end
      object N8: TMenuItem
        Caption = #1042#1099#1093#1086#1076
        OnClick = N8Click
      end
    end
    object N2: TMenuItem
      Caption = #1052#1077#1085#1102' VE'
      object N3: TMenuItem
        Caption = #1054#1090#1082#1088#1099#1090#1100' EEPROM'
        OnClick = Button2Click
      end
      object N4: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' EEPROM'
        Enabled = False
        OnClick = Button3Click
      end
      object N7: TMenuItem
        Caption = #1056#1072#1089#1089#1095#1080#1090#1072#1090#1100' VE'
        Enabled = False
        OnClick = N10Click
      end
      object N6: TMenuItem
        Caption = #1055#1086#1082#1072#1079#1072#1090#1100' '#1080#1079#1084#1077#1085#1077#1085#1080#1103
        OnClick = N6Click
      end
    end
    object N3DPlot1: TMenuItem
      Caption = #1043#1088#1072#1092#1080#1082' VE'
      Enabled = False
      OnClick = N3DPlot1Click
    end
    object N9: TMenuItem
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
      OnClick = N9Click
    end
    object Help1: TMenuItem
      Caption = 'Help'
      OnClick = Help1Click
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
end
