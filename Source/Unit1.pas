unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls,Masks, Grids, ExtCtrls,TeeProcs, TeEngine,Chart,math,WindowThread;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    N1: TMenuItem;
    N5: TMenuItem;
    N8: TMenuItem;
    StringGrid2: TStringGrid;
    Edit1: TEdit;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    OpenDialog2: TOpenDialog;
    N10: TButton;
    Label2: TLabel;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N7: TMenuItem;
    N3DPlot1: TMenuItem;
    N3DPlot2: TButton;
    Help1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure StringGrid2DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);

    procedure StringGrid2MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure N3DPlot1Click(Sender: TObject);
    procedure Help1Click(Sender: TObject);
    procedure Edit(Sender: TObject);
    procedure N8Click(Sender: TObject);


  private
    { Private declarations }


  public
    { Public declarations }
    a:integer; s:string;
  end;
     type
  TSave = record
    FontColor : TColor;
    FontStyle : TFontStyles;
    BrColor : TColor;
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

implementation

uses Unit3;
Const
Ix=50;  Iy=50;  //величины отступов от краев поля вывода
//nt=100; //число интервалов на оси x
ndx=10;
ndy=50; //число разбиений по осям (x, y), сетка графика
nc=7; mc=2; // константы для вывода оцифровки осей
  BUF_SZ = 2048;
  NAMEN_SZ = 326;
  NAMEE_SZ = 342;
  VE_SZ=646;
  VEE_SZ=902;
Var
  eeprom:string;       //Буфер для записи в *.bin
  buf: array [0..BUF_SZ-1] of byte; // буфер чтения
  hexname:string;   //Имя прошивки
  loglen:integer;
  data: array of array of real;

{$R *.dfm}

(******************************************************************************)
function AsToAc(arrChars: array of byte) : string;       //Перевод ASCII в ANSI
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

procedure TabClear(n,r,k:integer);                 //Очистка таблиц
var iStroki,iStolbca:integer;
begin
if k=1 then  begin

end;
if k=2 then  begin
//очистка ячеек таблицы
for iStolbca:=n to Form1.StringGrid2.ColCount do
for iStroki:=r to Form1.StringGrid2.RowCount do
  Form1.StringGrid2.Cells[iStolbca,iStroki]:='';
end;
end;

(******************************************************************************)

procedure TForm1.StringGrid2DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);                    //Перерисовка STRGRD2
var Flag : Integer;
begin
//Читаем значение флага, которое записано под видом указателя на объект.
  Flag := Integer(StringGrid2.Rows[ARow].Objects[ACol]);
  //Если флаг не равен
  if (Flag <> 1) then Exit;
with StringGrid2 do
  begin
  if (ACol>0) and(ARow>0) then begin
   try
    if not (edit1.Text = Cells[ACol, ARow])then
Canvas.Brush.Color:=clYellow;
   except
   end;
   Canvas.FillRect(Rect); //Текст тоже будет закрашен, его нужно перерисовать:
   Canvas.TextOut(Rect.Left+2, Rect.Top+2, Cells[ACol, ARow]);
  end;
  end;
end;

(******************************************************************************)

procedure TForm1.StringGrid2MouseUP(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Col, Row : Integer;
begin
//Определяем координаты ячейки, на которой произошёл щелчок мыши.
  StringGrid2.MouseToCell(X, Y, Col, Row);
  with StringGrid2 do
  begin
  //Если произошёл щелчок левой кнопкой мыши - устанавливаем флаг.
  if Button = mbLeft then begin
    //Под видом указателя на объект, который связан с ячейкой, записываем
    //значение флага. Значение флага, равное 1, означает, что цвет ячейки изменён.
    Rows[Row].Objects[Col] := TObject(1); //Или: := Pointer(1);
  //Если произошёл щелчок правой кнопкой мыши - сбрасываем флаг.
  end else if Button = mbRight then begin
    Rows[Row].Objects[Col] := TObject(0); //Или: := Pointer(0);
  end;
  end;
end;
(******************************************************************************)


procedure TForm1.Button1Click(Sender: TObject);      //Базовое заполнение ячеек
var i,j,k:integer; iTmp:integer;
begin
iTmp:=17;
Button3.Enabled:=true;
stringGrid2.ColCount := iTmp;
stringGrid2.RowCount := iTmp;
if not buf[0]=0 then  StringGrid2.Refresh else begin
   //Загружаем в листинг список значений из edit1
for i:= 1 to iTmp do begin
    k:=1;
      for j:=1 to iTmp do begin
      stringGrid2.Cells[k,i]:=edit1.Text;
        inc(k)
      end;
    end;
end;
end;


(******************************************************************************)

procedure TForm1.Edit(Sender: TObject); //Занесение изменений таблицы в массив
 var i,j,k:integer;
      res,hexve:real;
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
      ShowMessage(E.ClassName+'Edit ошибка с сообщением : '+E.Message);
end;
eeprom:='';
end;


(******************************************************************************)

procedure TForm1.Button2Click(Sender: TObject);     //Открыть EEPROM
var
  i, j,iTmp: Integer;
  f1:textfile;
  st:string;
  boot:File;
  TT: TThreadWindow;
  srcPtr : PChar;
  buf16:byte;
  f:Integer;
 HexVE:string;
  k: Integer;
  res:real;
begin
Button3.Enabled:=true;
N3DPlot1.Enabled:=true;
N3DPlot2.Enabled:=true;
N4.Enabled:=true;
//Открытие окна диалога ФАЙЛ.ОТКРЫТЬ для выбора папки
//и файла, текст из которого следует
// Разрешаем сохранять файлы типа .txt и .doc
  OpenDialog2.Filter := 'EEPROM file|*.bin';

  // Установка расширения по умолчанию
 OpenDialog2.DefaultExt := '*.bin';

  // Выбор текстовых файлов как стартовый тип фильтра
 OpenDialog2.FilterIndex := 1;
 openDialog2.InitialDir := GetCurrentDir+'\VE';
//поместить в Memo1 - рабочую область редактора.
if Form1.OpenDialog2.Execute then begin //если выбран файл
  S:=OpenDialog2.FileName;//то S присвоить спецификацию файла,
  TabClear(1,1,2);   //очистка окна
  TT := TThreadWindow.Show;
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
      ShowMessage(E.ClassName+'Reset ошибка с сообщением : '+E.Message);

end;

k:=VE_SZ; try
for i := stringgrid2.Colcount-1 downto 1 do
for j := 1 to stringgrid2.Rowcount-1 do begin
res:=buf[k]/128;
HexVE :=FormatFloat('0.##',res);// Format('%0x',[buf[k]]);
stringgrid2.Cells[i,j]:=HexVE;
inc(k);
end;
except
on E : Exception do
      ShowMessage(E.ClassName+'STRGRD ошибка с сообщением : '+E.Message);
end;
try
for i := Namen_sz to namee_sz-1 do begin
hexname:=hexname+AsToAc(buf[i]);
end;
 Form1.Caption:=Form1.Caption+' '+hexname;
  except
on E : Exception do
      ShowMessage(E.ClassName+'AstoAC ошибка с сообщением : '+E.Message);
end;
tt.Destroy;
(**********Очистка переменных*********)
f:=0;
Form3.Button1Click(Sender);
(**********Завершение*********)

    end;

end;
(******************************************************************************)

procedure TForm1.Button3Click(Sender: TObject);     //Сохранить EEPROM
var
   i, k: Integer;
  f1:textfile;
   FileName : String;
  Fs : TFileStream;
  SBin : AnsiString;
  ln : integer;

begin
//Обработчик щелчка на пункте меню ФАЙЛ.СОХРАНИТЬ КАК...
//Открытие окна диалога для выбора папки и
//задания имени и типа файла, в котором следует
// Разрешаем сохранять файлы типа .txt и .doc
  saveDialog1.Filter := 'EEPROM file|*.bin';

  // Установка расширения по умолчанию
  saveDialog1.DefaultExt := '*.bin';

  // Выбор текстовых файлов как стартовый тип фильтра
  saveDialog1.FilterIndex := 1;
//сохранить текст из Memo1-рабочей области редактора
if Form1.SaveDialog1.Execute then begin
  //Если файл выбран,
  //то S присвоить спецификацию файла,

  S:=SaveDialog1.FileName;

 i:=0;
 eeprom:='';
 while i<=BUF_SZ-1 do begin
 if length(Format('%0x',[buf[i]]))=1 then   eeprom:=eeprom+'0'+Format('%0x',[buf[i]])
 else  eeprom:=eeprom+Format('%0x',[buf[i]]);
  inc(i);
 end;
  //Полный путь файла в директории исполняемого файла программы.
 // FileName := ExtractFilePath(ParamStr(0)) + 'test1.bin';
   ln:=Length(eeprom) div 2;
  //Формируем двоичные данные по HEX кодам.
  SetLength(SBin,2048);
  HexToBin(PChar(eeprom), PChar(SBin), Length(SBin));
  //Запись двоичных данных в файловый поток.
  Fs := TFileStream.Create(s, fmCreate);
  try
    Fs.Write(SBin[1], Length(SBin));
  finally
    FreeAndNil(Fs);
  end;

(**********Завершение*********)
end;
end;


(******************************************************************************)

procedure TForm1.FormCreate(Sender: TObject);
var i,j,k:integer;
begin
// Разрешаем сохранять файлы типа .txt и .doc
OpenDialog1.Filter := 'Secu3 Logfile|*.csv|';

  // Установка расширения по умолчанию
 OpenDialog1.DefaultExt := '*.csv';

  // Выбор текстовых файлов как стартовый тип фильтра
 OpenDialog1.FilterIndex := 1;
//Обработчик события СОЗДАНИЯ ФОРМЫ
//Записываем разметку stringGrid2
//разметка строк
stringGrid2.Cells[0,0]:='Об.\Расх.';
j:=1;
for i:= 1 to 16 do begin
    k:=0;
      stringGrid2.Cells[i,k]:=inttostr(j);
      inc(j)
    end;
//разметка столбцов
j:=1;
 for i:= 1 to 16 do begin
    k:=0;
    case i of
    1:j:=600;
    2:j:=720;
    3:j:=840;
    4:j:=990;
    5:j:=1170;
    6:j:=1380;
    7:j:=1650;
    8:j:=1950;
    9:j:=2310;
    10:j:=2730;
    11:j:=3210;
    12:j:=3840;
    13:j:=4530;
    14:j:=5370;
    15:j:=6360;
    16:j:=7500;
    end;
      stringGrid2.Cells[k,i]:=inttostr(j);
    end;

//Загружаем в листинг список начальных значений
for i:= 1 to 17 do begin
    k:=1;
      for j:=1 to 17 do begin
      stringGrid2.Cells[k,i]:=edit1.Text;
      form1.StringGrid2.Rows[i].Objects[j] := TObject(1);
      inc(k)
      end;
    end;
end;
(******************************************************************************)

procedure TForm1.Help1Click(Sender: TObject);
begin
Showmessage('Программа предназначена для составления таблиц VE по логам.'+#13#10+#13#10+#13#10+
'1*)Вам необходимо установить все коэфициенты наполнения на некое значение при котором Ваш автомобиль будет ехать'+#13#10+
'(Это можно сделать прочитав eeprom сюда, выбрать значение, нажать заполнить, сохранить eeprom и залить в блок)'+#13#10+#13#10+
'2)Затем запустить двигатель, дождаться пока включится Лямбда коррекция и записать лог файл(Не стоит ездить более 30 минут)'+#13#10+#13#10+
'3)Останавливаем запись лога'+#13#10+#13#10+
'4*)Запускаем VETune и в окне начальное значение записываем то наполнение на которое вы установили все графики в менеджере'+#13#10+#13#10+
'5*)Нажимаем кнопку загрузить. Видим что все поля стали равны нашему наполнению'+#13#10+#13#10+
'6)Нажимаем Файл-Открыть и выбираем наш лог, нажимаем Меню VE и открываем EEPROM'+#13#10+#13#10+
'7)Как только лог файл подгрузился нажимаем Построить VE'+#13#10+#13#10+
'8)Теперь у нас есть таблица наполнений построенная на основе лог файла. Сохраняем EEPROM'
+#13#10+#13#10+
'После чего следует залить EEPROM обратно в блок Secu-3T и затем перейти к пункту (2)'
+#13#10+#13#10+#13#10+
'Так же возможно просмотреть график наполнения как в менеджере и непосредственно на графике поправить некоторые точки.'
+#13#10+#13#10+#13#10+'*Пункт 1,4 и 5 выполняется только в случае первоначальной настройки.');
end;
(******************************************************************************)
procedure TForm1.N3DPlot1Click(Sender: TObject);
begin
form3.Visible:=true;
Form3.Button1Click(Sender);
end;
(******************************************************************************)

procedure TForm1.N5Click(Sender: TObject);         //Открытие лог файла
begin
TabClear(0,0,1);
if Form1.OpenDialog1.Execute then begin//если выбран файл
  fname:=OpenDialog1.FileName;
 MyThread:=TMyThread.Create(False);
 MyThread.Priority:=tpNormal;
N7.Enabled:=true; end
end;

procedure TMyThread.Execute;
var k,s:TStringList;i:integer; F: TThreadWindow;
begin
 i:=0;
        try
s:=TStringList.Create;
k:=TStringList.Create;
k.LoadFromFile(fname);
s.Delimiter:=','; // Это разделитель между элементами
loglen:=k.Count;
SetLength(data,loglen,3);
F := TThreadWindow.Show;
for i:=0 to k.Count-1 do begin
 s.DelimitedText:=k[i];
 data[i,0]:=strtoint(s[1]);
 data[i,1]:=strtoint(s[8]);
 data[i,2]:=strtofloat(s[31]);
 end;
 F.Destroy;

Form1.Caption:='VE LogTuner'+' Открыт ' + fname+hexname;
Form1.n10.Enabled:=true;
 s.free;k.Free;
 except
    on E : Exception do
      ShowMessage(E.ClassName+' ошибка с сообщением =) : '+E.Message);

       end;

end;

(******************************************************************************)
procedure TForm1.N8Click(Sender: TObject);           //Завершение работы
begin
Close;
end;
(******************************************************************************)
procedure smlst(arh:Pointer;n:integer;k:integer);    //Пересчет значений в STRGRD2
var i,cs:integer; n1:array [0..15] of integer;
 s1:array [0..15] of real;
  sr1:array [0..15] of real;
  arr: array of array of real;
  znac:string;
  zn:real;
begin
Pointer(arr) := arh;
for i:=0 to 15 do  begin
  n1[i]:=0;
  s1[i]:=0;
  sr1[i]:=0;
end;  Try
for i:=0 to n do begin
cs:=Floor(arr[0,i]/1);
case cs of
600..719:begin s1[0]:=s1[0]+arr[1,i]; inc(n1[0]);end;
720..839:begin s1[1]:=s1[1]+arr[1,i]; inc(n1[1]);end;
840..989:begin s1[2]:=s1[2]+arr[1,i]; inc(n1[2]);end;
990..1169:begin s1[3]:=s1[3]+arr[1,i]; inc(n1[3]);end;
1170..1379:begin s1[4]:=s1[4]+arr[1,i]; inc(n1[4]);end;
1380..1649:begin s1[5]:=s1[5]+arr[1,i]; inc(n1[5]);end;
1650..1949:begin s1[6]:=s1[6]+arr[1,i]; inc(n1[6]);end;
1950..2309:begin s1[7]:=s1[7]+arr[1,i]; inc(n1[7]);end;
2310..2729:begin s1[8]:=s1[8]+arr[1,i]; inc(n1[8]);end;
2730..3209:begin s1[9]:=s1[9]+arr[1,i]; inc(n1[9]);end;
3210..3839:begin s1[10]:=s1[10]+arr[1,i]; inc(n1[10]);end;
3840..4529:begin s1[11]:=s1[11]+arr[1,i]; inc(n1[11]);end;
4530..5369:begin s1[12]:=s1[12]+arr[1,i]; inc(n1[12]);end;
5370..6359:begin s1[13]:=s1[13]+arr[1,i]; inc(n1[13]);end;
6360..7499:begin s1[14]:=s1[14]+arr[1,i]; inc(n1[14]);end;
7500..9000:begin s1[15]:=s1[15]+arr[1,i]; inc(n1[15]);end;
end;
end;
Except
      ShowMessage('Неизвестная ошибка');
  end;

//Нахождение среднего арифметического и перевод в сотые
for i := 0 to 15 do
 begin
   if n1[i]>0 then  sr1[i]:=(s1[i]/n1[i]);
 end;
/// Выбираем поле куда вставлять значения
for i:= 2 to form1.stringGrid2.Rowcount do begin
if not (sr1[i-2]=0) then begin
//array[столбец,строка]
 zn:=strtofloat(form1.stringGrid2.Cells[k,i-1])+sr1[i-2];
 znac:=floattostrf(zn,fffixed,3,2);
    if not (form1.stringGrid2.Cells[k,i-1]=znac) then
    begin
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

procedure dk(s:integer);      //Занесение значений оборотов и лямды в массив и его сортировка
var i,j,k,n:integer; f:string; b,b1:real; switch:boolean;
begin
SetLength(rash,2,length(data));
FormatSettings.DecimalSeparator:='.';
    k:=8;
    j:=0;

for i:= 0 to length(data)-1 do begin
      //array[столбец,строка]
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

procedure TForm1.N10Click(Sender: TObject);   //Запуск пересчета значений
var i:integer;  F: TThreadWindow;
begin
if(length(data)>0 )then
 F := TThreadWindow.Show;
   for i:= 1 to Form1.StringGrid2.ColCount-1 do
   try
    dk(i);
   except
    on E : Exception do
      ShowMessage(E.ClassName+' ошибка с сообщением : '+E.Message+' переменная равна '+inttostr(i));
   end;
   F.Destroy;
     form1.Caption:=form1.Caption+ ' - Изменено';
     Button3.Enabled:=true;
     N3DPlot1.Enabled:=true;
     N3DPlot2.Enabled:=true;
     N10.Enabled:=false;
end;
(******************************************************************************)


end.

