unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,IniFiles, FileCtrl,PDirSelected,REGISTRY,reinit;

type
  TForm2 = class(TForm)
    Button1: TButton;
    Panel1: TPanel;
    Button2: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Panel2: TPanel;
    Label2: TLabel;
    Button3: TButton;
    Edit2: TEdit;
    DirDialog1: TDirDialog;
    Panel3: TPanel;
    Label3: TLabel;
    Button4: TButton;
    Edit3: TEdit;
    LanguageEnglish: TButton;
    Label4: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure SwitchLanguage(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

const
  //SUBLANG_RUSSIAN = $0419;
  ENGLISH  = (SUBLANG_ENGLISH_US shl 10) or LANG_ENGLISH;
 // RUSSIAN  = (SUBLANG_RUSSIAN shl 10) or LANG_RUSSIAN;

{$R *.dfm}

procedure TForm2.Button1Click(Sender: TObject);
begin
 with TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Config.ini') do

  begin
    WriteString('DIR', 'EEPROM', Edit2.Text);
    WriteString('DIR', 'EESAVE', Edit3.Text);
    WriteString('DIR', 'LOG', Edit1.Text);
    Free;
  end;
  form2.close;
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
  //
  DirDialog1.Execute;
  Edit1.Text := DirDialog1.DirPath;
end;

procedure TForm2.Button3Click(Sender: TObject);
begin
//
DirDialog1.Execute;
Edit2.Text := DirDialog1.DirPath;
end;

procedure TForm2.Button4Click(Sender: TObject);
begin
DirDialog1.Execute;
Edit3.Text := DirDialog1.DirPath;
end;

procedure SetLocalOverrides(const AFileName, ALocaleOverride: string);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    if Reg.OpenKey('Software\CoderGear\Locales', True) then
      Reg.WriteString(ALocaleOverride, AFileName);
  finally
    Reg.Free;
  end;
end;


procedure TForm2.SwitchLanguage(Sender: TObject);
var
  Name : String;
  Size : Integer;
begin
if LoadNewResourceModule(TComponent(Sender).Tag) <> 0 then
  begin
    ReinitializeForms;
  end;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin

LanguageEnglish.Tag := ENGLISH;

case SysLocale.DefaultLCID of
    ENGLISH: SwitchLanguage(LanguageEnglish);
 end;


  with TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Config.ini') do
  begin
    Edit3.Text := ReadString('DIR', 'EESAVE', '');
    Edit2.Text := ReadString('DIR', 'EEPROM', '');
    Edit1.Text := ReadString('DIR', 'LOG', '');
    Free;
  end;
end;


end.
