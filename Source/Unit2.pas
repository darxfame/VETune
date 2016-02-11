{ VETune and VEOnline  - An open source, free editor engine tables unit
   Copyright (C) 2015 Artem E. Kochegizov. Russia, Moscow
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.
   contacts:
              http://secu-3.org
              email: akochegizov@gmail.com
}

unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,IniFiles, FileCtrl,PDirSelected;

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
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

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

procedure TForm2.FormCreate(Sender: TObject);
begin
  with TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Config.ini') do
  begin
    Edit3.Text := ReadString('DIR', 'EESAVE', '');
    Edit2.Text := ReadString('DIR', 'EEPROM', '');
    Edit1.Text := ReadString('DIR', 'LOG', '');
    Free;
  end;
end;


end.
