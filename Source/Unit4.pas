unit Unit4;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,IniFiles,
  Dialogs, StdCtrls;

type
  TForm4 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    Edit10: TEdit;
    Edit11: TEdit;
    Edit12: TEdit;
    Edit13: TEdit;
    Edit14: TEdit;
    Edit15: TEdit;
    Edit16: TEdit;
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form4: TForm4;

implementation

uses Unit1;

resourcestring
 rschen = '��� ���������� ��������� � ���� ���������� ������������� ���������. ������� ��������� ������?';
 rserr = '������, �� ��������� ������ �����';
 rsdef = '������� ����������� ��������?';

{$R *.dfm}

function check():boolean;
var MyComponent,MyComponent1,MyComponent2: TComponent; d,k:integer;
begin
k:=0;
    for d:=2 to 15 do
  begin
   MyComponent := Form4.FindComponent('Edit'+IntToStr(d-1));
   MyComponent1 := Form4.FindComponent('Edit'+IntToStr(d));
   MyComponent2 := Form4.FindComponent('Edit'+IntToStr(d+1));
   if (strtoint(TEdit(MyComponent).Text) <strtoint(TEdit(MyComponent1).Text)) and
   (strtoint(TEdit(MyComponent1).Text)<strtoint(TEdit(MyComponent2).Text))
   then k:=k+1;
  end;
 if k=14 then Result:=true else Result:=false;
end;

procedure TForm4.Button1Click(Sender: TObject);
var MyComponent: TComponent; d,buttonSelected:integer;
begin
if(check()=true) then
  with TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Config.ini') do
  begin
  for d:=1 to 16 do
  begin
   MyComponent := Form4.FindComponent('Edit'+IntToStr(d));
   if MyComponent <> nil then if Length(TEdit(MyComponent).Text) =3 then
   begin
   TEdit(MyComponent).Text:='0'+TEdit(MyComponent).Text;
   WriteString('GridRPM', inttostr(d), TEdit(MyComponent).Text)
   end
   else
    WriteString('GridRPM', inttostr(d), TEdit(MyComponent).Text);
  end;
    Free;
   buttonSelected:= MessageDlg(rschen,mtInformation, mbOKCancel, 0);
    if buttonSelected = mrOK    then begin
    Application.Terminate;
    end;
    form4.Close;
  end
  else MessageDlg(rserr,mtError, mbOKCancel, 0);

end;

procedure TForm4.Button2Click(Sender: TObject);
begin
form4.Close;
end;

procedure TForm4.Button3Click(Sender: TObject);
var buttonSelected:integer;
begin
buttonSelected:= MessageDlg(rsdef,mtInformation, [mbYes,mbCancel], 0);
   if buttonSelected = mrYes    then begin
    Edit1.Text:='0600';
    Edit2.Text:='0720';
    Edit3.Text:='0840';
    Edit4.Text:='0990';
    Edit5.Text:='1170';
    Edit6.Text:='1380';
    Edit7.Text:='1650';
    Edit8.Text:='1950';
    Edit9.Text:='2310';
    Edit10.Text:='2730';
    Edit11.Text:='3210';
    Edit12.Text:='3840';
    Edit13.Text:='4530';
    Edit14.Text:='5370';
    Edit15.Text:='6360';
    Edit16.Text:='7500';
    end;
end;

procedure TForm4.FormCreate(Sender: TObject);
var MyComponent: TComponent; d:integer;
begin
with TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Config.ini') do
  begin
  for d:=1 to 16 do
  begin
   MyComponent := Form4.FindComponent('Edit'+IntToStr(d));
   if MyComponent <> nil then
    TEdit(MyComponent).Text:=ReadString('GridRPM', inttostr(d), '');
  end;
      Free;
    form4.Close;
  end;
end;

end.
