unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, TeEngine, ExtCtrls, TeeProcs, Chart, StdCtrls,unit1, Series,
  SDL_plot3d,SDL_sdlbase,SDL_math2, SDL_filesys, SDL_matrix, SDL_NumLab;

type
  TForm3 = class(TForm)
    Chart1: TChart;
    rash1: TScrollBar;
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    Button2: TButton;
    Series1: TLineSeries;
    CheckBox1: TCheckBox;
    Help: TButton;
    CheckBox2: TCheckBox;
    NLabMag: TNumLab;
    ScrBarMagnif: TScrollBar;
    Plot3D1: TPlot3D;
    procedure rash1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Chart1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Chart1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Chart1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure HelpClick(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure Plot3D1BeforeRenderPolygon(Sender: TObject; Canvas: TCanvas;
      var Handled: Boolean; CellX, CellY: Integer; quad: TQuad;
      var color: TColor);
      procedure ScrBarMagnifChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;
  mouse:string;
  mint:integer;
  mins, maxs : array[1..3] of double;
 const
  HoleXLow = 16;
  HoleXHigh = 16;
  HoleYLow = 17;
  HoleYHigh = 17;

implementation

{$R *.dfm}
(******************************************************************************)

procedure TForm3.Button1Click(Sender: TObject);
var i,j,e,l,rcout:integer; x,y,z:real;
begin
Plot3D1.Gridmat.Fill(0);
rcout:=form1.stringGrid2.rowcount;
//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&//

Plot3D1.GridMat.Resize(rcout,rcout);
Plot3D1.SetRange (1, 16, 600, 7500, 0, 1.4);
Plot3D1.CaptionX:='Расходы';
Plot3D1.CaptionY:='Обороты';
Plot3D1.CaptionZ:='Коэфициент';
e:=1;
while e<form1.StringGrid2.ColCount do
  for j := 1 to form1.StringGrid2.RowCount-1 do
  begin
  FormatSettings.DecimalSeparator := '.';
  z:=strtofloat(form1.StringGrid2.Cells[e,j]);
  x:=strtofloat(form1.StringGrid2.Cells[0,j]);
   Plot3D1.GridMat.Elem[e,j] := z;
  if j=form1.StringGrid2.RowCount-1 then inc(e);
    end;

Plot3D1.ColorLow := clFuchsia;
Plot3D1.ColorHigh := clBlue;
Plot3D1.ColorScaleHigh := 1;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&//

for i:=1 to form1.StringGrid2.ColCount-1 do
     begin
       if checkbox1.Checked=false then
       begin
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        with Chart1 do
  begin
Label1.Caption:='Расход:';
Label2.Caption:=inttostr(rash1.Position);
label2.left:=107;
rash1.Min:=1;
rash1.Max:=16;
//если необходимо можешь задать  min X , max Y,   min Y , max Y
      BottomAxis.Automatic:= True;
      BottomAxis.Maximum := 7500;
      BottomAxis.Minimum := 600;
      LeftAxis.Automatic := False;
      LeftAxis.Maximum := 1.5;
      LeftAxis.Minimum := -0.5;

   UndoZoom;//востанавливаем исходный масштаб
   Title.Text.Clear;
   Title.Text.Add('Расход '+inttostr(form3.rash1.Position));//GRAPHIC
   LeftAxis.AxisValuesFormat := '0.##';//
   BottomAxis.Title.Caption  := 'Обороты';//подписываем X
   LeftAxis.Title.Caption    := 'Проценты';//подписываем Y
   Repaint;
  end;
 with form3.Chart1 do
  begin
  Series1.Clear;
  legend.Visible:=True;
///создаём серию
// Series1:=TFastLineSeries.Create(Chart1); //тип FastLine
 //Series1.ParentChart := Chart1;             //назначение родительского графика
 (Series1 as TLineSeries).LinePen.Width:=2;//толщина
 Series1.XValues.Order:= LoNone;               //чтобы соединялись точки так как их вводят!!!
 Series1.Marks.Visible:= True;
// Series1.Marks.Style:=smsPointIndex;
 Series1.Marks.Style:=smsValue;
 x:=0;
 y:=0;
for j := 1 to form1.StringGrid2.RowCount-1 do
  begin
  FormatSettings.DecimalSeparator := '.';
  y:=strtofloat(form1.StringGrid2.Cells[rash1.Position,j]);
  x:=strtofloat(form1.StringGrid2.Cells[0,j]);
   Series1.AddXY(x,y, form1.StringGrid2.Cells[0,j]+'('+inttostr(j-1)+')',clRed);
    end;
Series1.Title := ''; //
 Series1.Active := True;
  end;
       end
      else
     begin
//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        with Chart1 do
  begin
 if rcout=15 then  rash1.max:=14;
if rcout=17 then  rash1.max:=16;
Label1.Caption:='Обороты:';
label2.left:=104;
case rash1.Position of
  1:Label2.Caption:='600';
  2:Label2.Caption:='720';
  3:Label2.Caption:='840';
  4:Label2.Caption:='990';
  5:Label2.Caption:='1170';
  6:Label2.Caption:='1380';
  7:Label2.Caption:='1650';
  8:Label2.Caption:='1950';
  9:Label2.Caption:='2310';
  10:Label2.Caption:='2730';
  11:Label2.Caption:='3210';
  12:Label2.Caption:='3840';
  13:Label2.Caption:='4530';
  14:Label2.Caption:='5370';
  15:Label2.Caption:='6360';
  16:Label2.Caption:='7500';
end;
rash1.Min:=1;
rash1.Max:=rcout-1;
//если необходимо можешь задать  min X , max Y,   min Y , max Y
      BottomAxis.Automatic:= True;
      BottomAxis.Minimum := 1;
      BottomAxis.Maximum := 16;
      LeftAxis.Automatic := False;
      LeftAxis.Maximum := 1.5;
      LeftAxis.Minimum := -0.5;

   UndoZoom;//востанавливаем исходный масштаб
   Title.Text.Clear;
   Title.Text.Add('Обороты '+Label2.Caption);//GRAPHIC
   LeftAxis.AxisValuesFormat := '0.##';//
   BottomAxis.Title.Caption  := 'Расход';//подписываем X
   LeftAxis.Title.Caption    := 'Проценты';//подписываем Y
   Repaint;
  end;
 with form3.Chart1 do
  begin
  Series1.Clear;
  legend.Visible:=false;
///создаём серию
// Series1:=TFastLineSeries.Create(Chart1); //тип FastLine
 //Series1.ParentChart := Chart1;             //назначение родительского графика
 (Series1 as TLineSeries).LinePen.Width:=2;//толщина
 Series1.XValues.Order:= LoNone;               //чтобы соединялись точки так как их вводят!!!
 Series1.Marks.Visible:= True;
 Series1.Marks.Style:=smsValue;
 x:=0;
 y:=0;
for j := 1 to form1.StringGrid2.ColCount-1 do
  begin
  FormatSettings.DecimalSeparator := '.';
  y:=strtofloat(form1.StringGrid2.Cells[j,rash1.Position]);
  x:=strtofloat(form1.StringGrid2.Cells[j,0]);
   Series1.AddXY(x,y, '',clRed);
    end;
Series1.Title := ''; //
 Series1.Active := True;
  end;
     end;
     end;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
end;
 (******************************************************************************)

procedure TForm3.Button2Click(Sender: TObject);
begin
form3.Visible:=false;
end;

(******************************************************************************)

procedure TForm3.Chart1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 mint:=series1.GetCursorValueIndex();
if (Button = mbLeft) then mouse:='mbLeft';
if (Button = mbRight) then mouse:='mbRight';
end;
(******************************************************************************)

procedure TForm3.Chart1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
  var xX, yY: Double;
begin
      with form3.Chart1 do
  begin
if (ssCtrl in Shift) and (mouse='mbLeft') and (mint <> -1)then
  begin
  Series1.GetCursorValues(xX, yY);
   Series1.YValue[mint]:=strtofloat(FormatFloat( '0.##',(yY)));
  if (checkbox1.Checked=false)
    then form1.StringGrid2.Cells[rash1.Position,mint+1]:=FormatFloat( '0.##',(yY))
    else form1.StringGrid2.Cells[mint+1,rash1.Position]:=FormatFloat( '0.##',(yY))
  end;
  end;
end;
 (******************************************************************************)

procedure TForm3.Chart1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
mouse:='';
Form1.edit(sender);
end;
(******************************************************************************)

procedure TForm3.CheckBox2Click(Sender: TObject);
begin
if checkbox2.Checked=true then
       begin
       Button1Click(Sender);
        Plot3D1.Visible:=true;
        Chart1.Visible:=false;
        label1.Visible:=false;
        label2.Visible:=false;
        rash1.Visible:=false;
       end
       else begin
        Plot3D1.Visible:=false;
        Chart1.Visible:=true;
        label1.Visible:=true;
        label2.Visible:=true;
        rash1.Visible:=true;
       end;
end;
(******************************************************************************)

procedure TForm3.FormCreate(Sender: TObject);
var
  i, j : integer;
begin
Label1.Caption:='Расход';
rash1.Min:=1;
rash1.Max:=16;
Button1Click(Sender);
end;
(******************************************************************************)

procedure TForm3.HelpClick(Sender: TObject);
begin
Showmessage('Для редактирования точек зажмите Ctrl,левую кнопку мыши и тащите точку');
end;

(******************************************************************************)
procedure TForm3.ScrBarMagnifChange(Sender: TObject);
begin
Plot3D1.Magnification := ScrBarMagnif.position/100;
NLabMag.Value := ScrBarMagnif.position/100;
end;
(******************************************************************************)
procedure TForm3.Plot3D1BeforeRenderPolygon(Sender: TObject;
  canvas: Tcanvas; var Handled: Boolean; CellX, CellY: Integer;
  quad: TQuad; var color: TColor);

begin
if (CellX >= HoleXLow) and (CellX <= HoleXHigh) and (CellY >= HoleYLow) and (CellY <= HoleYHigh) then
  Handled := true;
end;
(******************************************************************************)

procedure TForm3.rash1Change(Sender: TObject);
begin
label2.Caption:=inttostr(rash1.Position);
Button1Click(Sender);
end;
(******************************************************************************)

end.
