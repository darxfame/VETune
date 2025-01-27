unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls,Masks, Grids, ExtCtrls,TeeProcs, TeEngine,Chart,math,IniFiles,unit2,
  Buttons;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    N1: TMenuItem;
    N5: TMenuItem;
    N8: TMenuItem;
    StringGrid2: TStringGrid;
    OpenDialog2: TOpenDialog;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N7: TMenuItem;
    N3DPlot1: TMenuItem;
    Help1: TMenuItem;
    N6: TMenuItem;
    N9: TMenuItem;
    Log1: TMenuItem;
    EEPROM1: TMenuItem;
    N11: TMenuItem;
    N12: TMenuItem;
    VEtxt1: TMenuItem;
    OpenDialog3: TOpenDialog;
    SaveDialog2: TSaveDialog;
    Panel1: TPanel;
    Label1: TLabel;
    Edit1: TEdit;
    Button1: TButton;
    Panel2: TPanel;
    Button2: TButton;
    Button3: TButton;
    Label2: TLabel;
    Panel3: TPanel;
    N10: TButton;
    N3DPlot2: TButton;
    CheckBox1: TCheckBox;
    BitBtn1: TBitBtn;
    Button4: TButton;
    procedure FormCreate(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure StringGrid2DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure N3DPlot1Click(Sender: TObject);
    procedure Help1Click(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure StringGrid2MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure StringGrid2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CheckBox1Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure N9Click(Sender: TObject);
    procedure editClick(Sender: TObject);
    procedure N12Click(Sender: TObject);
    procedure VEtxt1Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure StringGrid2SelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);


  private
    { Private declarations }


  public

    { Public declarations }
    a:integer; s:string;

  end;
     type
  TSave = record
    FontColor : TColor;
  end;
  TMyThread = class(TThread)
    private
    { Private declarations }
  protected
    procedure Execute; override;
  end;

var
  Form1: TForm1;
  List:TStringList;
  Lst:TStringList;
  ar: array of array of string;
  rash:array of array of real;
  rc:integer;
  gEditCol : Integer = -1;
  gEditRow : Integer = -1;
  MyThread: TMyThread;
  fname,frname:string;
    r: integer;  //hint
    c: integer;
    nvhod: array[0..16,0..16] of integer;
implementation

uses Unit3, Unit4;
Const
Ix=50;  Iy=50;  //�������� �������� �� ����� ���� ������
ndx=10;
ndy=50; //����� ��������� �� ���� (x, y), ����� �������
nc=7; mc=2; // ��������� ��� ������ ��������� ����
  BUF_SZ = 2048;
  NAMEN_SZ = 326;
  NAMEE_SZ = 342;
  VE_SZ=646;
  VEE_SZ=902;
Var
  eeprom:string;       //����� ��� ������ � *.bin
  buf: array [0..BUF_SZ-1] of byte; // ����� ������
  hexname:string;   //��� ��������
  loglen:integer;
  data: array of array of real;
  databuf: array[0..16,0..16] of string;    //����� ��� ������ ���������
  stsum:array [0..15,0..15] of real; //����� ��������� ����� ���������

    resourcestring
      rsdiperror = '������, ����� �� ������� ���������';
      rsedpont = '�������������� ��������';
      rsenpont = '������� ��������';
      rschpont = '�������� ��������?';
      rshelpmsg = '��������� ������������� ��� ����������� ������ VE �� �����.'+#13#10+#13#10+#13#10+
'1*)��� ���������� ���������� ��� ����������� ���������� �� ����� �������� ��� ������� ��� ���������� ����� �����'+#13#10+
'(��� ����� ������� �������� eeprom ����, ������� ��������, ������ ���������, ��������� eeprom � ������ � ����)'+#13#10+#13#10+
'2)����� ��������� ���������, ��������� ���� ��������� ������ ��������� � �������� ��� ����(�� ����� ������ ����� 30 �����)'+#13#10+#13#10+
'3)������������� ������ ����'+#13#10+#13#10+
'4*)��������� VETune � � ���� ��������� �������� ���������� �� ���������� �� ������� �� ���������� ��� ������� � ���������'+#13#10+#13#10+
'5*)�������� ������ ���������. ����� ��� ��� ���� ����� ����� ������ ����������'+#13#10+#13#10+
'6)�������� ����-������� � �������� ��� ���, �������� ���� VE � ��������� EEPROM'+#13#10+#13#10+
'7)��� ������ ��� ���� ����������� �������� ��������� VE'+#13#10+#13#10+
'8)������ � ��� ���� ������� ���������� ����������� �� ������ ��� �����. ��������� EEPROM'
+#13#10+#13#10+
'����� ���� ������� ������ EEPROM ������� � ���� Secu-3T � ����� ������� � ������ (2)'
+#13#10+#13#10+#13#10+
'��� �� �������� ����������� ������ ���������� ��� � ��������� � ��������������� �� ������� ��������� ��������� �����.'
+#13#10+#13#10+#13#10+'*����� 1,4 � 5 ����������� ������ � ������ �������������� ���������.'
+#13#10+#13#10+#13#10+'�������� �����, ��� �� ������� ���������� �� ���� ������ ����� ����������'
+#13#10+'�������� Shift � ������� ����� ������� ���� �� ������ ������. ���������� �����-������ �������������.'
+#13#10+'����� �������� ����� ��� �� ����� ���� � ����� ������ ������ ���� �� ������ ��� ��������������� �������';
    rschname = ' - ��������';
    rsreedit = '���� Log ���� ��� ������������� � ���� EEPROM'+#13#10+'���������� ���������� ��������?';
    rsgr = '��.\����.';

{$R *.dfm}


(******************************************************************************)
function AsToAc(arrChars: array of byte) : string;       //������� ASCII � ANSI
 Var
   i,kod: byte;
   arrTemp: array of byte;
 begin
  SetLength(arrTemp, Length(arrChars));
  for i:=0 to length(arrChars)-1 do
  begin
    kod:=arrChars[i];
    if (kod=240) then
      arrTemp[i]:=168;
    if (kod=241) then
      arrTemp[i]:=184;
    if (kod>=128) and (kod<=175) then
      arrTemp[i]:=kod+64
    else
      if (kod>=224) and (kod<=239) then
        arrTemp[i]:=kod+16
      else
        arrTemp[i]:=kod;
  end;
  SetString(Result, PAnsiChar(arrTemp), Length(arrTemp));
 end;

(******************************************************************************)

procedure TabClear(n,r,k:integer);                 //������� ������
var iStroki,iStolbca:integer;
begin
if k=1 then  begin

end;
if k=2 then  begin
//������� ����� �������
for iStolbca:=n to Form1.StringGrid2.ColCount do
for iStroki:=r to Form1.StringGrid2.RowCount do
  Form1.StringGrid2.Cells[iStolbca,iStroki]:='';
end;
end;

(******************************************************************************)

procedure TForm1.StringGrid2DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);                    //����������� STRGRD2
var Flag : Integer;
begin
//������ �������� �����, ������� �������� ��� ����� ��������� �� ������.
  Flag := Integer(StringGrid2.Rows[ARow].Objects[ACol]);
  //���� ���� �� �����
  if (Flag <> 1) and (Flag <> 2) and (Flag <> 4) and (Flag <> 5)then Exit;
with StringGrid2 do
  begin
  if (ACol>0) and(ARow>0) then begin
   try
if not (edit1.Text = Cells[ACol, ARow])then begin
Canvas.Brush.Color:=clYellow;
end;
if (Flag = 2) then begin Canvas.Brush.Color:=cllime; end;
if (Flag = 4) then begin Canvas.Brush.Color:=claqua; end;
if (Flag = 5) then begin Canvas.Brush.Color:=clred; end;
   except
   end;
   Canvas.FillRect(Rect); //����� ���� ����� ��������, ��� ����� ������������:
   Canvas.TextOut(Rect.Left+2, Rect.Top+2, Cells[ACol, ARow]);
  end;
  end;
end;

(******************************************************************************)

procedure TForm1.StringGrid2MouseDown(Sender: TObject; Button: TMouseButton;   //�������� ����� �� �����
  Shift: TShiftState; X, Y: Integer);
var
  Col, Row : Integer;
  Flag : Integer;
begin
//���������� ���������� ������, �� ������� ��������� ������ ����.
  StringGrid2.MouseToCell(X, Y, Col, Row);
  Flag := Integer(StringGrid2.Rows[Row].Objects[Col]);
  with StringGrid2 do
  begin
  //���� ��������� ������ ����� ������� ���� - ������������� ����.
  if (Flag <> 2) and (Flag <> 4) and (Flag <> 1)then Exit else
  if (Button = mbLeft)and (ssShift in Shift)then begin
    //��� ����� ��������� �� ������, ������� ������ � �������, ����������
    //�������� �����. �������� �����, ������ 1, ��������, ��� ���� ������ �������.
    Rows[Row].Objects[Col] := TObject(4);
  //���� ��������� ������ ������ ������� ���� - ���������� ����.
  end
  else
  if (Button = mbRight)and (ssShift in Shift)then begin
    Rows[Row].Objects[Col] := TObject(1);
  end;
  end;
end;

(******************************************************************************)

procedure TForm1.StringGrid2MouseMove(Sender: TObject; Shift: TShiftState; X,  //Hint
  Y: Integer);
var
  ARow: integer;
  ACol: integer;
begin
StringGrid2.MouseToCell(X, Y, ACol, ARow);
with StringGrid2 do
try
  if ((ACol<>C) or (ARow<>R)) then
    begin
      C:=ACol; R:=ARow;
     Application.CancelHint;
      StringGrid2.Hint:=inttostr(nvhod[c,r-1]);
      StringGrid2.Selection := TGridRect(rect(C, R, c, r));
    end;
except
end;
end;
(******************************************************************************)
procedure TForm1.StringGrid2SelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
  var poi:string;
begin
poi:=InputBox(rsedpont, rsenpont, StringGrid2.Cells[ACol,ARow]);
if (strtofloat(poi)<0) or (strtofloat(poi)>2) then
MessageDlg(rsdiperror,mtError, mbOKCancel, 0)
else
StringGrid2.Cells[ACol,ARow] := poi;
end;

(******************************************************************************)
procedure TForm1.VEtxt1Click(Sender: TObject);
var f1:textfile; i,k: Integer; fname:string;
begin
  saveDialog2.InitialDir := form2.Edit2.Text;

// ��������� ��������� ����� ���� .txt � .doc
  saveDialog2.Filter := 'VE Text|*.txt|';

  // ��������� ���������� �� ���������
  saveDialog2.DefaultExt := '*.txt';
   SaveDialog2.FileName:=FormatDateTime('dd.mm.yyyy_hh.nn.ss', Now)+'.txt';
  // ����� ��������� ������ ��� ��������� ��� �������
  saveDialog2.FilterIndex := 1;
//��������� ����� �� Memo1-������� ������� ���������
if Form1.SaveDialog2.Execute then begin
  //���� ���� ������,
  //�� S ��������� ������������ �����,

  fname:=SaveDialog2.FileName;

AssignFile(F1, fname);
Rewrite(F1);
with StringGrid2 do
   begin
     // Write number of Columns/Rows
    Writeln(f1, ColCount);
     Writeln(f1, RowCount);
     // loop through cells
    for i := 1 to ColCount - 1 do
       for k := 1 to RowCount - 1 do
         Writeln(F1, Cells[i, k]);
   end;
CloseFile(F1);
end;
end;

(******************************************************************************)


procedure TForm1.BitBtn1Click(Sender: TObject);
begin
form4.show;
end;

procedure TForm1.Button1Click(Sender: TObject);      //������� ���������� �����
var i,j,k:integer; iTmp:integer;
buttonSelected:integer;
begin
iTmp:=17;
stringGrid2.ColCount := iTmp;
stringGrid2.RowCount := iTmp;
   //��������� � ������� ������ �������� �� edit1
buttonSelected:= MessageDlg(rschpont,mtInformation, [mbYes,mbCancel], 0);
   if buttonSelected = mrYes    then begin
for i:= 1 to iTmp do begin
    k:=1;
      for j:=1 to iTmp do begin
      stringGrid2.Cells[k,i]:=edit1.Text;
        inc(k)
      end;
    end;
   end;
   with TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Config.ini') do
   WriteString('TUNEUP', 'StartPoint', edit1.text);
end;


(******************************************************************************)

procedure TForm1.EditClick(Sender: TObject); //��������� ��������� ������� � ������
 var i,j,k:integer;
      hexve:real;
begin
eeprom:='';
k:=VE_SZ; try
for i := Form1.stringgrid2.Colcount-1 downto 1 do
for j := 1 to Form1.stringgrid2.Rowcount-1 do begin
HexVE :=strtofloat(Form1.stringgrid2.Cells[i,j]);
buf[k]:=round(HexVE*128);
inc(k);
end;
except
on E : Exception do
      ShowMessage(E.ClassName+'Edit error with message : '+E.Message);
end;
end;


(******************************************************************************)

procedure TForm1.Button2Click(Sender: TObject);     //������� EEPROM
var
  i, j: Integer;
  boot:File;
  f:Integer;
 HexVE:string;
  k: Integer;
  res:real;
begin
Button3.Enabled:=true;
N3DPlot1.Enabled:=true;
N3DPlot2.Enabled:=true;
N4.Enabled:=true;
openDialog2.InitialDir := form2.Edit2.Text;
for i:= 1 to 17 do begin
      for j:=1 to 17 do begin
      form1.StringGrid2.Rows[i].Objects[j] := TObject(1);
      end;
    end;
     for i:= 1 to 16 do begin
      for j:=1 to 16 do begin
       nvhod[i-1,j-1]:=0;
      end;
    end;
//�������� ���� ������� ����.������� ��� ������ �����
//� �����, ����� �� �������� �������
// ��������� ��������� ����� ���� .txt � .doc
 OpenDialog2.Filter := 'EEPROM file|*.bin';

  // ��������� ���������� �� ���������
 OpenDialog2.DefaultExt := '*.bin';

  // ����� ��������� ������ ��� ��������� ��� �������
 OpenDialog2.FilterIndex := 1;
//��������� � Memo1 - ������� ������� ���������.
if Form1.OpenDialog2.Execute then begin //���� ������ ����
  S:=OpenDialog2.FileName;//�� S ��������� ������������ �����,
  TabClear(1,1,2);   //������� ����
   for i := 0 to BUF_SZ-1 do
buf[i]:=0;
try
 AssignFile(boot,s);
 Reset(boot,1);
Repeat
Application.ProcessMessages;
 BlockRead(boot,buf,buf_sz,f);
Until ( f <> buf_sz );
 CloseFile(boot);
except
on E : Exception do
      ShowMessage(E.ClassName+'Reset error with message : '+E.Message);

end;

k:=VE_SZ; try
for i := stringgrid2.Colcount-1 downto 1 do
for j := 1 to stringgrid2.Rowcount-1 do begin
res:=buf[k]/128;
HexVE :=FormatFloat('0.##',res);// Format('%0x',[buf[k]]);
stringgrid2.Cells[i,j]:=HexVE;
stringgrid2.Rows[i].Objects[j] := TObject(1);
inc(k);
end;
except
on E : Exception do
      ShowMessage(E.ClassName+'STRGRD error with message : '+E.Message);
end;
try
hexname:='';
for i := Namen_sz to namee_sz-1 do begin
hexname:=hexname+AsToAc(buf[i]);
end;
Form1.EEPROM1.caption:='EEPROM: '+ExtractFileName(s)+' - '+hexname;
  except
on E : Exception do
      ShowMessage(E.ClassName+'AstoAC error with message : '+E.Message);
end;
(**********������� ����������*********)
f:=0;
Form3.Button1Click(Sender);
Form3.databclick(Sender);
(**********����������*********)

    end;
end;
(******************************************************************************)

procedure TForm1.Button3Click(Sender: TObject);     //��������� EEPROM
var
   i: Integer;
  Fs : TFileStream;
  SBin : AnsiString;
  ln : integer;
  logname:string;
begin
Form1.editClick(Sender);
//���������� ������ �� ������ ���� ����.��������� ���...
//�������� ���� ������� ��� ������ ����� �
//������� ����� � ���� �����, � ������� �������
  saveDialog1.InitialDir := form2.Edit3.Text;
// ��������� ��������� ����� ���� .txt � .doc
  saveDialog1.Filter := 'EEPROM file|*.bin';

  // ��������� ���������� �� ���������
  saveDialog1.DefaultExt := '*.bin';

  // ����� ��������� ������ ��� ��������� ��� �������
  saveDialog1.FilterIndex := 1;
  SaveDialog1.FileName:=FormatDateTime('dd.mm.yyyy_hh.nn.ss', Now)+'.bin';
//��������� ����� �� Memo1-������� ������� ���������
if Form1.SaveDialog1.Execute then begin
  //���� ���� ������,
  //�� S ��������� ������������ �����,

  S:=SaveDialog1.FileName;

 i:=0;
 eeprom:='';
 while i<=BUF_SZ-1 do begin
 if length(Format('%0x',[buf[i]]))=1 then   eeprom:=eeprom+'0'+Format('%0x',[buf[i]])
 else  eeprom:=eeprom+Format('%0x',[buf[i]]);
  inc(i);
 end;
  //������ ���� ����� � ���������� ������������ ����� ���������.
  // ln:=Length(eeprom) div 2;
  //��������� �������� ������ �� HEX �����.
  SetLength(SBin,2048);
  HexToBin(PChar(eeprom), PChar(SBin), Length(SBin));
  //������ �������� ������ � �������� �����.
  Fs := TFileStream.Create(s, fmCreate);
  try
    Fs.Write(SBin[1], Length(SBin));
  finally
    FreeAndNil(Fs);
  end;

(**********����������*********)
with TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Config.ini') do
  begin
   WriteString('TUNEUP', 'LASTEE', ExtractFileName(s));
   logname:=log1.Caption;
   delete(logname,1,6);
   logname:=TrimLeft(logname);
   WriteString('TUNEUP', 'LASTLOG', logname);
  end;
end;
end;

(******************************************************************************)
procedure TForm1.Button4Click(Sender: TObject);
begin
with TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Config.ini') do
   WriteString('TUNEUP', 'StartPoint', edit1.text);
   StringGrid2.Refresh;
end;

(******************************************************************************)

procedure TForm1.CheckBox1Click(Sender: TObject);      //��������� ���������
var
  i,j:integer;
  zn:real;
  znac:string;
begin
if (CheckBox1.Checked = True) then
  begin
  for i:= 2 to form1.stringGrid2.Rowcount do begin
   for j := 2 to form1.stringGrid2.colcount do
      if (n10.Enabled=false) then begin
 zn:=strtofloat(form1.stringGrid2.Cells[j-1,i-1]);
 znac:=floattostrf(zn,fffixed,3,2);
  databuf[j-2,i-2]:=znac;
  form1.stringGrid2.Cells[j-1,i-1]:=floattostrf(stsum[j-1,i-2],fffixed,3,2);
end;
end;
  end
                              else
  begin
   for i:= 2 to form1.stringGrid2.Rowcount do begin
   for j := 2 to form1.stringGrid2.colcount do
      if (n10.Enabled=false) then begin
  form1.stringGrid2.Cells[j-1,i-1]:=databuf[j-2,i-2];
end;
end;
  end;

end;

(******************************************************************************)

procedure TForm1.FormCreate(Sender: TObject);
var i,j,k,d,razm:integer; filename:string;
begin
fileName := ExtractFilePath(ParamStr(0)) + 'Config.ini';
if not FileExists(fileName)
  then with TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Config.ini') do
  begin
   WriteString('DIR', 'EESAVE', ExtractFilePath(ParamStr(0)));
   WriteString('DIR', 'EEPROM', ExtractFilePath(ParamStr(0)));
   WriteString('DIR', 'LOG', ExtractFilePath(ParamStr(0)));
   WriteString('TUNEUP', 'StartPoint', inttostr(1));
  for d:=1 to 16 do
  begin
   case d of
    1:razm:=600;
    2:razm:=720;
    3:razm:=840;
    4:razm:=990;
    5:razm:=1170;
    6:razm:=1380;
    7:razm:=1650;
    8:razm:=1950;
    9:razm:=2310;
    10:razm:=2730;
    11:razm:=3210;
    12:razm:=3840;
    13:razm:=4530;
    14:razm:=5370;
    15:razm:=6360;
    16:razm:=7500;
    end;
    if Length(inttostr(razm)) =3 then WriteString('GridRPM', inttostr(d), '0'+inttostr(razm)) else
    WriteString('GridRPM', inttostr(d), inttostr(razm));
  end;
    Free;
end;

with TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Config.ini') do
  begin
    openDialog2.InitialDir := ReadString('DIR', 'EEPROM', '');
    openDialog1.InitialDir := ReadString('DIR', 'LOG', '');
    saveDialog1.InitialDir := ReadString('DIR', 'EESAVE', '');
    //VE.txt
    saveDialog2.InitialDir := ReadString('DIR', 'EEPROM', '');
    openDialog3.InitialDir := ReadString('DIR', 'EEPROM', '');
    edit1.Text:=ReadString('TUNEUP', 'StartPoint', '');
 //�������� ��������
  for d:=1 to 16 do
  begin
   stringGrid2.Cells[0,d]:=ReadString('GridRPM', inttostr(d), '');
  end;

    Free;
  end;
// ��������� ��������� ����� ���� .txt � .doc
OpenDialog1.Filter := 'Secu3 Logfile|*.csv|';

  // ��������� ���������� �� ���������
 OpenDialog1.DefaultExt := '*.csv';

  // ����� ��������� ������ ��� ��������� ��� �������
 OpenDialog1.FilterIndex := 1;
//���������� ������� �������� �����
//���������� �������� stringGrid2
//�������� �����
stringGrid2.Cells[0,0]:=rsgr;
j:=1;
for i:= 1 to 16 do begin
    k:=0;
      stringGrid2.Cells[i,k]:=inttostr(j);
      inc(j)
    end;
//��������� � ������� ������ ��������� ��������
for i:= 1 to 17 do begin
    k:=1;
      for j:=1 to 17 do begin
      stringGrid2.Cells[k,i]:=edit1.Text;
      form1.StringGrid2.Rows[i].Objects[j] := TObject(0);
      inc(k)
      end;
    end;
    StringGrid2.Hint := '0 0';
    StringGrid2.ShowHint := True;
end;
(******************************************************************************)

procedure TForm1.Help1Click(Sender: TObject);
begin
Showmessage(rshelpmsg);
end;
(******************************************************************************)
procedure TForm1.N3DPlot1Click(Sender: TObject);
begin
form3.Visible:=true;
Form3.Button1Click(Sender);
end;
(******************************************************************************)

procedure TForm1.N5Click(Sender: TObject);     //�������� ��� �����
var i,j:integer;
begin
openDialog1.InitialDir := form2.Edit1.Text;
TabClear(0,0,1);
if Form1.OpenDialog1.Execute then begin//���� ������ ����
  fname:=OpenDialog1.FileName;
     for i:= 1 to 16 do begin
      for j:=1 to 16 do begin
       nvhod[i-1,j-1]:=0;
      end;
    end;
 MyThread:=TMyThread.Create(False);
 MyThread.Priority:=tpNormal;
N7.Enabled:=true; end
end;
(******************************************************************************)

procedure TForm1.N6Click(Sender: TObject);
begin
with checkbox1 do
if Checked=false then
Checked:=true
else
Checked:=false;
end;
(******************************************************************************)

procedure TMyThread.Execute;
var k,s:TStringList;i:integer;
OldCursor: TCursor;
begin
 i:=0;
 OldCursor := Screen.Cursor;
 Screen.Cursor := crHourGlass;
        try
s:=TStringList.Create;
k:=TStringList.Create;
k.LoadFromFile(fname);
s.Delimiter:=','; // ��� ����������� ����� ����������
loglen:=k.Count;
SetLength(data,loglen,3);

for i:=0 to k.Count-1 do begin
 s.DelimitedText:=k[i];
 data[i,0]:=strtoint(s[1]);
 data[i,1]:=strtoint(s[8]);
 data[i,2]:=strtofloat(s[31]);
 end;
Form1.Log1.caption:='LOG: '+ExtractFileName(fname);
Form1.Caption:='VE LogTuner';
 Form1.n10.Enabled:=true;
 Screen.Cursor := OldCursor;
 s.free;k.Free;
 except
    on E : Exception do
      ShowMessage(E.ClassName+' error with message =) : '+E.Message);
       end;
end;

(******************************************************************************)
procedure TForm1.N8Click(Sender: TObject);           //���������� ������
begin
Close;
end;
procedure TForm1.N9Click(Sender: TObject);
begin
form2.show;
end;

(******************************************************************************)
procedure smlst(arh:Pointer;n:integer;k:integer);    //�������� �������� � STRGRD2
var i,cs,Flag:integer;
n1:array [0..15] of integer;
ranges: array of array of Integer;
 s1:array [0..15] of real;
 sr1:array [0..15] of real;
  arr: array of array of real;
  znac:string;
  zn:real;
  MyComponent,MyComponent1: TComponent;
  d:integer;
  const
  RANGE_LEFT = 0;
  RANGE_RIGTH = 1;

  procedure SetRangeValue(Number: Integer; EditLeft, EditRigth: TEdit);
  begin
    // ��������� ��������
    if number=15 then begin
    ranges[Number - 1][RANGE_LEFT] := StrToIntDef(EditLeft.Text, 0);
    ranges[Number - 1][RANGE_RIGTH] := StrToIntDef('9000', 0);
    end
    else begin
    ranges[Number - 1][RANGE_LEFT] := StrToIntDef(EditLeft.Text, 0);
    ranges[Number - 1][RANGE_RIGTH] := StrToIntDef(EditRigth.Text, 0)-1;
    end;
  end;

   procedure ProcessRangeValue(AValue: Integer;AD: Integer);
  var
    I: Integer;
  begin
    // ���� �� ��������� � ��������� ���������
    for I := 0 to Length(ranges) - 1 do
    begin
      if (AValue >= ranges[I][RANGE_LEFT]) and (AValue <= ranges[I][RANGE_RIGTH]) then
      begin
        s1[i]:=s1[i]+arr[1,AD]; inc(n1[i]);
        Break;
      end;
    end;
  end;

begin
Pointer(arr) := arh;
for i:=0 to 15 do  begin
  n1[i]:=0;
  s1[i]:=0;
  sr1[i]:=0;
end;
Try

 // ������� ��������
  SetLength(ranges, 16);
  for I := 0 to 15 do
  begin
    SetLength(ranges[I], 2);
  end;
  //���������
  for d:=2 to 16 do
  begin
   MyComponent := Form4.FindComponent('Edit'+IntToStr(d-1));
   MyComponent1 := Form4.FindComponent('Edit'+IntToStr(d));
   if MyComponent <> nil then if d=16 then begin
   SetRangeValue(d-1, TEdit(MyComponent), TEdit(MyComponent1));
   SetRangeValue(15, TEdit(MyComponent1), TEdit(MyComponent1));
   end else  SetRangeValue(d-1, TEdit(MyComponent), TEdit(MyComponent1));
  end;
  // ��������� ��������
  for I := 0 to N do begin
  begin
    cs := Floor(arr[0, I] / 1);
    ProcessRangeValue(cs,i);
  end;
  end
Except
      ShowMessage('����������� ������');
  end;

//���������� �������� ��������������� � ������� � �����
for i := 0 to 15 do
 begin
   if n1[i]>0 then begin
   sr1[i]:=(s1[i]/n1[i]);
   end;
 end;
/// �������� ���� ���� ��������� ��������
for i:= 2 to form1.stringGrid2.Rowcount do begin
Flag := Integer(form1.StringGrid2.Rows[i-1].Objects[k]);
if not (sr1[i-2]=0) and (Flag<>4) then begin
//array[�������,������]
  zn:=strtofloat(form1.stringGrid2.Cells[k,i-1])+sr1[i-2];
  znac:=floattostrf(zn,fffixed,3,2);
     if (zn<0) or (zn>2)then begin
        MessageDlg(rsdiperror,mtError, mbOKCancel, 0);
           //Cells[i, j] := st;      //��������� ������ ��������
          form1.StringGrid2.Cells[k,i-1] := '0.00';         //������ �� 0
          form1.StringGrid2.Rows[i-1].Objects[k] := TObject(5);
         end
    else
     if not (form1.stringGrid2.Cells[k,i-1]=znac) then
    begin
        nvhod[k,i-2]:=n1[i-2];
       if not (Flag=4) then stsum[k,i-2]:=sr1[i-2];
      form1.StringGrid2.Rows[i-1].Objects[k] := TObject(2);
      form1.stringGrid2.Cells[k,i-1]:=znac;
    end;
end;
end;

znac:='';
arr:=nil;
for i:=0 to 15 do  begin
  n1[i]:=0;
  s1[i]:=0;
  sr1[i]:=0;
end;
end;

(******************************************************************************)

procedure dk(s:integer);      //��������� �������� �������� � ����� � ������ � ��� ����������
var i,j,k:integer;
begin
SetLength(rash,2,length(data));
FormatSettings.DecimalSeparator:='.';
    k:=8;
    j:=0;

for i:= 0 to length(data)-1 do begin
      //array[�������,������]
        if data[i,1]=s then
        begin
          rash[0,j]:=data[i,0];
          rash[1,j]:=data[i,2]/100;
          inc(j);
        end
end;

smlst(rash,j-1,s);

if s=16 then  begin
SetLength(data,0,0);
Finalize(data);
end;
SetLength(rash,0,0);
Finalize(rash);
end;
(******************************************************************************)

procedure TForm1.N10Click(Sender: TObject);   //������ ��������� ��������
var i:integer; OldCursor: TCursor;
logname,lname,eename,ee:string;
buttonSelected:integer;
begin
with TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Config.ini') do
  begin
  //EEPROM
   eename:=ReadString('TUNEUP', 'LASTEE', '');
   ee:=EEPROM1.Caption;
   //Log
   logname:=ReadString('TUNEUP', 'LASTLOG', '');
   lname:=log1.Caption;
   delete(lname,1,6);
   lname:=TrimLeft(lname);
  end;
if (pos(eename,ee)<>0) and (logname=lname) then
buttonSelected:= MessageDlg(rsreedit,mtInformation, [mbYes,mbCancel], 0)
else buttonSelected := mrYes;
   if buttonSelected = mrYes    then begin
 OldCursor := Screen.Cursor;
 Screen.Cursor := crHourGlass;
if(length(data)>0 )then
   for i:= 1 to Form1.StringGrid2.ColCount-1 do
   try
    dk(i);
   except
    on E : Exception do
      ShowMessage(E.ClassName+' error with message : '+E.Message+' ���������� ����� '+inttostr(i));
   end;
  Screen.Cursor := OldCursor;
     form1.Caption:=form1.Caption+ rschname;
     Button3.Enabled:=true;
     checkbox1.Enabled:=true;
     N6.Enabled:=true;
     N3DPlot1.Enabled:=true;
     N3DPlot2.Enabled:=true;
     N10.Enabled:=false;
   end;


end;
(******************************************************************************)
procedure TForm1.N12Click(Sender: TObject);
var f1:textfile; i,j,iTmp: Integer; st,fname:string;
begin
  OpenDialog3.InitialDir := form2.Edit2.Text;
// ��������� ��������� ����� ���� .txt � .doc
  OpenDialog3.Filter := 'VE Text|*.txt|';

  // ��������� ���������� �� ���������
 OpenDialog3.DefaultExt := '*.txt';

  // ����� ��������� ������ ��� ��������� ��� �������
 OpenDialog3.FilterIndex := 1;
openDialog3.InitialDir := form2.Edit1.Text;

if Form1.OpenDialog3.Execute then begin//���� ������ ����
  fname:=OpenDialog3.FileName;
AssignFile(F1, fname);
Reset(F1);

with StringGrid2 do
   begin
     // Get number of columns
    Readln(f1, iTmp);
     ColCount := iTmp;
     // Get number of rows
    Readln(f1, iTmp);
     RowCount := iTmp;
     // loop through cells & fill in values
    for i := 1 to ColCount-1 do
       for j := 1 to RowCount-1 do
       begin
         Readln(f1, st);
         if (strtofloat(st)<0) or (strtofloat(st)>2)then begin
         MessageDlg(rsdiperror,mtError, mbOKCancel, 0);
         //Cells[i, j] := st;      //��������� ������ ��������
         Cells[i, j] := '0.00';         //������ �� 0
         Rows[j].Objects[i] := TObject(5);
         end else  begin
           Cells[i, j] := st;
         Rows[j].Objects[i] := TObject(1);
         end;
       end;
   end;
CloseFile(F1);
end;
end;
(******************************************************************************)


end.

