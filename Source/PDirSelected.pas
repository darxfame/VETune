unit PDirSelected;

//Сборка Yakovchenko Sergey 2009
//DelphiWorld 2002-2004. Акулов Николай и сообщество Delphikingdom
interface
  uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls,ComCtrls, ShlObj, ActiveX;
type
  TDirDialog = class(TComponent)
  protected
    FNewFolder: Boolean;
    FDirPath: String;
    FTitleName: String;
  public
    function Execute: Boolean;
  published
    property TitleName: String read FTitleName write FTitleName;
    property NewFolder: Boolean read FNewFolder write FNewFolder;
    property DirPath: String read FDirPath write FDirPath;

end;
procedure Register;
implementation

procedure Register;
begin
  RegisterComponents('DelphiExpert',[TDirDialog]);
end;

function AdvSelectDirectory(const Caption: string; const Root: WideString;
   var Directory: string; EditBox: Boolean = False; ShowFiles: Boolean = False;
   AllowCreateDirs: Boolean = True): Boolean;
   // callback function that is called when the dialog has been initialized
  //or a new directory has been selected

  // Callback-Funktion, die aufgerufen wird, wenn der Dialog initialisiert oder
  //ein neues Verzeichnis selektiert wurde
  function SelectDirCB(Wnd: HWND; uMsg: UINT; lParam, lpData: lParam): Integer;
     stdcall;
   var
     PathName: array[0..MAX_PATH] of Char;
   begin
     case uMsg of
       BFFM_INITIALIZED: SendMessage(Wnd, BFFM_SETSELECTION, Ord(True), Integer(lpData));
       // include the following comment into your code if you want to react on the
      //event that is called when a new directory has been selected 
      // binde den folgenden Kommentar in deinen Code ein, wenn du auf das Ereignis
      //reagieren willst, das aufgerufen wird, wenn ein neues Verzeichnis selektiert wurde 
      {BFFM_SELCHANGED:
      begin 
        SHGetPathFromIDList(PItemIDList(lParam), @PathName);
        // the directory "PathName" has been selected
        // das Verzeichnis "PathName" wurde selektiert 
      end;}
     end;
     Result := 0;
   end;
 var
   WindowList: Pointer;
   BrowseInfo: TBrowseInfo;
   Buffer: PChar;
   RootItemIDList, ItemIDList: PItemIDList;
   ShellMalloc: IMalloc;
   IDesktopFolder: IShellFolder;
   Eaten, Flags: LongWord;
   Drive: Char;

 const
   // necessary for some of the additional expansions
  // notwendig fur einige der zusatzlichen Erweiterungen 
  BIF_USENEWUI = $0040;
   BIF_NOCREATEDIRS = $0200;
 begin
   Result := False;
   if not DirectoryExists(Directory) then
     Directory := '';
   FillChar(BrowseInfo, SizeOf(BrowseInfo), 0);
   if (ShGetMalloc(ShellMalloc) = S_OK) and (ShellMalloc <> nil) then
   begin
     Buffer := ShellMalloc.Alloc(MAX_PATH);
     try
       RootItemIDList := nil;
       if Root <> '' then
       begin
         SHGetDesktopFolder(IDesktopFolder);
         for Drive:= 'A' to 'Z' do begin
         case GetDriveType(PCHAR(Drive + ':/')) of
         DRIVE_FIXED:
 begin


         IDesktopFolder.ParseDisplayName(0, nil,
           POleStr(Drive + ':\'), Eaten, RootItemIDList, Flags);
       end;
       end;
       end;
       end;
       OleInitialize(nil);
       with BrowseInfo do
       begin
         hwndOwner := 0;
         pidlRoot := RootItemIDList;
         pszDisplayName := Buffer;
         lpszTitle := PChar(Caption);
         // defines how the dialog will appear:
        // legt fest, wie der Dialog erscheint: 
        ulFlags := BIF_RETURNONLYFSDIRS or BIF_USENEWUI or
           BIF_EDITBOX * Ord(EditBox) or BIF_BROWSEINCLUDEFILES * Ord(ShowFiles) or
           BIF_NOCREATEDIRS * Ord(not AllowCreateDirs);
         lpfn    := @SelectDirCB;
         if Directory <> '' then
           lParam := Integer(PChar(Directory));
       end;
       WindowList := DisableTaskWindows(0);
       try
         ItemIDList := ShBrowseForFolder(BrowseInfo);
       finally
         EnableTaskWindows(WindowList);
       end;
       Result := ItemIDList <> nil;
       if Result then
       begin
         ShGetPathFromIDList(ItemIDList, Buffer);
         ShellMalloc.Free(ItemIDList);
         Directory := Buffer;
       end;
     finally
       ShellMalloc.Free(Buffer);
     end;
   end;
 end;

function CallDirDialogNoNewFolder(TitName: String; var DirName: String): Boolean;
var
  TitleName : string;
  lpItemID : PItemIDList;
  BrowseInfo : TBrowseInfo;
  DisplayName : array[0..MAX_PATH] of char;
  TempPath : array[0..MAX_PATH] of char;
begin
Result:= False;
  FillChar(BrowseInfo, sizeof(TBrowseInfo), #0);
  BrowseInfo.hwndOwner := 0;
  BrowseInfo.pszDisplayName := @DisplayName;
  TitleName := TitName;
  BrowseInfo.lpszTitle := PChar(TitleName);
  BrowseInfo.ulFlags := BIF_RETURNONLYFSDIRS;
  lpItemID := SHBrowseForFolder(BrowseInfo);
  if lpItemId <> nil then
  begin
    SHGetPathFromIDList(lpItemID, TempPath);
    DirName:= TempPath;
    GlobalFreePtr(lpItemID);
    Result:= True;
  end;
end;
function TDirDialog.Execute: Boolean;
begin
  Result:= False;
  if not FNewFolder then begin
  if CallDirDialogNoNewFolder(FTitleName,FDirPath) then Result:= True;
  end
  else
  AdvSelectDirectory(FTitleName, '', FDirPath, False, False, True);
end;
end.
 