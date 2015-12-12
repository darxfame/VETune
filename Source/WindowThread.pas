unit WindowThread;
(*
 * Module:     Класс TThreadWindow является потомком TThread
 *             и содержит окно с иконкой, текстом и индикатором
 *             хода работы.
 *             Можно использовать при длительных операциях,
 *             чтобы пользователь не скучал.
 * Version:    03.00 (16.04.2009)
 * Author:     Cepгей Poщин
 * Comments:   Специально для королевства Delphi
 *             Сайт автора: http://www.roschinspb.narod.ru
 *             Пишите письма: http://www.delphikingdom.com/asp/users.asp?ID=1271
 *
 * Copyright:  © 2005 - 2009 г.
 *
 * Version:    03.00 (16.04.2009)
 * Realized:   Переделал первоначальную версию задействовав Message методы (стандарный для Delphi механизм
 *             обработки сообщений).
 *             См. http://www.delphikingdom.com/asp/viewitem.asp?catalogid=1390
 *             Спасибо Сергею Галездинову
 *)
interface
uses Windows,
  Messages,
  Classes,
  SysUtils,
  Math
  {$IFDEF VER130},
  OldVersions{$ELSE} {, GraphUtil}{$ENDIF}
  ;

const
  NameIconWait = 'MESICON9'; //Название ресурса, который содержит иконку этого окна
  NameClass: string = 'Class Window of TThreadWindow (new)'; //Название класса окна
  InterValTimeOut = 20000; //Эта константа определяет, сколько времени надо ждать, пока
  //будет обработано сообщение посланое потоку (0 - соответствует бесконечности)

resourcestring
  DefaultMessage = 'Дождитесь окончания текущей операции!';
  TextCancel = 'Отмена';
  ErrorWait = 'Время ожидания истекло';
  ErrorThread = 'Во время работы потока возникла ошибка %1:s' + #13#10 + '%0:s';
  ErrorParam = 'Неверное значение параметра %s (%s)';

const
  BorderWidth = 8;
  UM_GetPropertyData = WM_USER + 2;
  UM_SetPropertyValue = WM_USER + 3;

  IntBool: array[boolean] of LongInt = (0, 1);
  IDVisible = 1;
  IdColor = 2;
  IdFontColor = 3;
  IdIcon = 4;
  IdIconIndex = 5;
  IdIconSize = 6;
  IdBoundsRect = 7;
  IdText = 8;
  IdAlphaBlendValue = 9;
  IdFont = 10;

type
  TPropertyData = packed record
    RecordSize: integer;
    DataSize: integer;
    Data: Pointer;
  end;
  PRopertyData = ^TPropertyData;

  TUMPropertyData = packed record
    Msg: Cardinal;
    IndexProp: Word;
    Part: Word;
    Value: PRopertyData;
    Result: Longint;
  end;

  TUMPropertyValue = packed record
    Msg: Cardinal;
    IndexProp: Word;
    Part: Word;
    Value: LongInt;
    Result: Longint;
  end;

  TElementPos = packed record
    TextRect: TRect;
    IconRect: TRect;
    ProgressRect: TRect;
  end;

  TWndMethod = procedure(var Message: TMessage) of object;

  // Что требуется обновить в окне
  TCallDispath = (cdNone, cdOutThread, cdInThread, cdInWindow);
  TUpdateArea = (uaAll, // Требуется перерасчет координат элементов окна и перерисовка всего окна
    uaWindow, // Требуется перерисовка всего окна
    uaIcon, // Требуется перерисовка только пиктограммы
    uaProgress); // Требуется перерисовка только индикатора хода выполнения
  TUpdateAreas = set of TUpdateArea;

  TDefaultFont = (dCaptionFont, dSmCaptionFont, dMenuFont, dStatusFont, dMessageFont, dTimeFont);

  EThreadWindow = class(Exception)
  public
  end;

  TThreadWindow = class(TThread)
  private
    fBusy: THandle;
    fHandleCreated: THandle;
    fTextError: string;
    fErrorClass: ExceptClass;
    fVisible: boolean;
    fShowTick: DWORD;
    fHandleCreatedTick: DWORD;
    fTimer: UINT;
    fInterval: DWORD;
    fWND: HWND;
    fColor: Cardinal;
    fBrush: HBrush;
    fBoundsRect: TRect;
    fWindowRect: TRect;
    fClientRect: TRect;
    fHObj: Pointer;
    fCallDispath: TCallDispath;
    fLastMessage: TMessage;
    fFont: hFont;
    fFontColor: Cardinal;
    fIcon: HIcon;
    fIconSize: LongInt;
    fIconIndex: LongInt;
    fText: string;
    fPercent: SmallInt;
    fOldPercent: SmallInt;
    fElementPos: TElementPos;
    fAlphaShow: boolean;
    fAlphaBlendValue: byte;
    fIntervalAlphaShow: integer;
    fEnabled: boolean;
    fOldEnabled: boolean;
    fUpdateAreas: TUpdateAreas;
    fHotPoint: TPoint;
    fCountInStack: integer;
    fLayoutUpdated: boolean;
    procedure Stop;
    procedure AllocateHWnd(Method: TWndMethod);
    procedure DeallocateHWnd;
    procedure SetVisible(const Value: boolean);
    // Метод ProcessMessage выполняется при получении потоком любого сообщения
    procedure ProcessMessage(MSG: TMSG);
    // Метод WNDProc выполняется при получении окном любого сообщения
    procedure WNDProc(var Message: TMessage);
    // Метод TimerProc выполняется таймером через короткие промежутки времени
    procedure TimerProc(var M: TMessage);
    // Создание и разрушение окна
    procedure ShowWND;
    procedure CloseWND;
    procedure SetColor(const Value: Cardinal);
    procedure UpdateBrush(const Color: Cardinal; var Brush: HBrush);
    procedure SetBoundsRect(const Value: TRect);
    // Для получения данных посылается сообщение содержащие адрес и размер данных
    // Обработчик сообщение помещает данные по указанному адресу
    // Если адрес и указатель нулевые, то выделяется память нужного размера,
    // которую потом необходимо освободить
    procedure UMGetPropertyData(var Message: TUMPropertyData); message UM_GetPropertyData;
    // Отправка данных потоку окна. После отправки сообщения потоку, необходимо обязательно
    // дождаться его обработки, для этого можно использовать процедуру perform
    procedure UMSetPropertyValue(var Message: TUMPropertyValue); message UM_SetPropertyValue;
    procedure WMSHOWWINDOW(var Message: TWMSHOWWINDOW); message WM_SHOWWINDOW;
    procedure WMWINDOWPOSCHANGED(var Message: TWMWINDOWPOSCHANGED); message WM_WINDOWPOSCHANGED;
    procedure WMERASEBKGND(var Message: TWMERASEBKGND); message WM_ERASEBKGND;
    procedure WMTIMER(var Message: TWMTIMER); message WM_TIMER;
    procedure WMLBUTTONDOWN(var Message: TWMLBUTTONDOWN); message WM_LBUTTONDOWN;
    procedure WMLBUTTONUP(var Message: TWMLBUTTONUP); message WM_LBUTTONUP;
    procedure SetFont(const Value: hFont);
    procedure SetFontColor(const Value: Cardinal);
    procedure SetIcon(const Value: HIcon);
    procedure FreeIcon(var DestIcon: HIcon);
    procedure UpdateIcon(SourceIcon: HIcon; var DestIcon: HIcon);
    procedure SetIconSize(const Value: LongInt);
    procedure SetText(const Value: string);
    procedure SetIconIndex(const Value: LongInt);
    procedure SetAlphaBlendValue(const Value: byte);
    procedure UpdateBlend(const WND: HWND; Value: Byte);
    function GetText: string;
    function GetVisible: boolean;
    function GetBoundsRect: TRect;
  protected
    procedure Execute; override;
    function MakeWParam(IndexProp, Part: Word): Longint; //inline;
    // Получение данных из потока, в котором работает окно
    procedure GetPropertyData(IndexProp, Part: Word; var Buffer; Size: LongInt); overload;
    procedure GetPropertyData(IndexProp, Part: Word; var S: string); overload;
    procedure GetPropertyData(IndexProp, Part: Word; var I: LongInt); overload;
    procedure GetPropertyData(IndexProp, Part: Word; var B: boolean); overload;
    // Если при выполнении потока произошла какая-то ошибка, то по окончании
    // генерируем соответствующую ошибку
    procedure DoTerminate; override;
    // Метод DoBeforeResume выполняется в основном потоке перед запуском потока окна
    procedure DoBeforeResume; virtual;
    // Метод DoAfterStop выполняется в основном потоке после остановки потока окна
    procedure DoAfterStop; virtual;
    // Метод WNDCreated выполняется после создания окна
    procedure WNDCreated(WND: HWND); virtual;
    // Метод WNDDestroy выполняется перед разрушением окна
    procedure WNDDestroy(var WND: HWND); virtual;
    // Метод DoBeforeDispath выполняется перед обработкой сообщения
    procedure DoBeforeDispath(var Message: TMessage); virtual;
    // Метод DrawWND выполняет отрисовку всего окна
    procedure DrawWND(DC: HDC; ARect: TRect); virtual;
    // Метод DrawProgress выполняет отрисовку индикатора хода выполнения
    procedure DrawProgress(DC: HDC; ARect: TRect; Percent: integer); virtual;
    // Метод DoAfterSetBounds устанавливает физические границы окна
    // и границы клиентской области окна относительно физических границ окна
    procedure DoAfterSetBounds(NewBoundsRect: TRect; var NewWindowRect, NewClientRect: TRect); virtual;
    // Метод UpdateLayout возвращает координаты всех элементов окна
    procedure UpdateLayout(ClientRect: TRect; var ElementPos: TElementPos); virtual;
    // Метод DrawText выполняет отрисовку текста сообщения
    procedure DrawText(DC: HDC; ARect: TRect; Text: PChar; Len: integer); virtual;
    // Метод DrawIcon выполняет отрисовку пиктограммы
    procedure DrawIcon(DC: HDC; ARect: TRect; Icon: HIcon; Brush: HBrush); virtual;
    // Этот метод выполняет отрисовку рамки
    procedure DrawBorder(DC: HDC; ARect: TRect; Ctl3D: boolean; Width: Integer;
      IsDown: boolean = false); virtual;
    // Ждем, пока не произойдет событие fBusy.
    // После того, как дождались событие автоматически сбрасывается
    // Если SetAfterWaiting = true, то после завершения ожидания оно устанавливается
    // Если не дождались (время ожидания), то возникает ошибка.
    // Если объект разрушен, или не создан, то возвращается false, иначе true
    function WaitBusy(SetAfterWaiting: boolean = false): boolean;
    // Посылка сообщения нити и ожидание его выполнения
    // (можно посылать только пользовательские сообщения > WM_USER)
    function Perform(Msg: Cardinal; WParam, LParam: Longint): Longint;
    // Метод Change указывает, на то, что некоторая часть окна изменилась и неплохо бы
    // окошко перерисовать
    procedure Change(var UpdateAreas: TUpdateAreas); virtual;
    // Посылка сообщения о том, что необходимо перерисовать какуюто часть окна
    procedure Invalidate(Area: TUpdateArea = uaWindow);
    // Функция возвращает значение True, если вызов осуществился внутри
    // потока, в котором работает окно.
    function InThread: boolean;
  public
    // Создание и отображение окна с параметрами по умолчанию
    // и текстом сообщения AMessage, если текст не задан,
    // то с текстом DefaultMessage
    constructor Show(AMessage: string = ''); overload;
    // Разрушает созданный экземпляр
    destructor Destroy; override;
    // Эта процедура выполняется после создания экземпляра класса
    procedure AfterConstruction; override;
    // Возвращает информацию о шрифте с дескриптором Font, если он равен 0, то
    // возвращает информацию об одном из стандартных шрифтов
    class function GetFontIndirect(Font: HFont; DefaultFont: TDefaultFont): tagLOGFONT;

    // Основные свойства окна
    // В большинстве случаев для получения значения поля не требуется ни каких дополнительных
    // действий и потокозащищенность. Но для примера методы
    // GetVisible и GetText сделаны потокозащищенными
    property Visible: boolean read GetVisible write SetVisible;
    // Цвет окна
    property Color: Cardinal read fColor write SetColor;
    // Видимые координаты окна, относительно рабочего стола. В случае окон сложной формы, могут не совпадать
    // c физическими координатами окна. См. WindowRect
    property BoundsRect: TRect read GetBoundsRect write SetBoundsRect;
    property Font: hFont read fFont write SetFont;
    property FontColor: Cardinal read fFontColor write SetFontColor;
    property Icon: HIcon read fIcon write SetIcon;
    property IconIndex: LongInt read fIconIndex write SetIconIndex;
    property IconSize: LongInt read fIconSize write SetIconSize;
    // Это свойство устанавливает степень прозрачности окна.
    // Если 0, то свойство Visible становится False
    property AlphaBlendValue: byte read fAlphaBlendValue write SetAlphaBlendValue;
    // Текст сообщения
    property Text: string read GetText write SetText;
    property Message: string read GetText write SetText;

    // Простейшие свойства.
    // Изменение этих свойств не требует моментальной реакции окна. В методе Change
    // периодически сравниваются старые и новые значения, и в случае изменения
    // возвращается признак того, что изменилась некоторая часть окна
    // Дескриптор окна
    property WND: HWND read fWND;
    // Хэндл кисти для заливки фона
    property Brush: HBrush read fBrush;
    // Время задержки появления окна (мс)
    property Interval: DWORD read fInterval write fInterval;
    // Процент выполнения умноженный на 10 (0..1000). Если меньше 0, то не отображается
    property Percent: SmallInt read fPercent write fPercent;
    // Физические координаты окна, относительно рабочего стола
    property WindowRect: TRect read fWindowRect;
    // Координаты клиентской области окна относительно левого верхнего угла
    // физических координат окна
    property ClientRect: TRect read fClientRect;
    // свойство CallDispath указывает на то, в каком месте вызывается
    // обработчик события
    property CallDispath: TCallDispath read fCallDispath;
    // Если установлено это свойство, то при отображении будет происходить
    // плавное изменение прозрачности. После того, как окно отобразилось
    // Это свойство сбрасывается
    property AlphaShow: boolean read fAlphaShow write fAlphaShow;
    // Время в течении которого будет происходить изменение прозрачности
    property IntervalAlphaShow: integer read fIntervalAlphaShow write fIntervalAlphaShow;
    // Доступность окна (можно ли таскать мышью и т.п.)
    property Enabled: boolean read fEnabled write fEnabled;
  end;

function Test(AllMembers, Member: Cardinal): boolean;

implementation

function Test(AllMembers, Member: Cardinal): boolean;
begin
  result := ((Member) and (AllMembers)) = Member;
end;

function InternalSetFont(var Font: HFont; Value: HFont; DefaultFont: TDefaultFont): Bool;
var NewLogFont, OldLogFont: tagLOGFONT;
begin
  NewLogFont := TThreadWindow.GetFontIndirect(Value, DefaultFont);
  Result := Font = 0;
  if not Result then begin
    OldLogFont := TThreadWindow.GetFontIndirect(Font, DefaultFont);
    Result := not CompareMem(@OldLogFont, @NewLogFont, SizeOf(NewLogFont));
  end;
  if Result then begin
    if (Font <> 0) and (not DeleteObject(Font)) then
      RaiseLastOsError
    else
      Font := 0;
    Font := CreateFontIndirect(NewLogFont);
  end;
end;

{ TThreadWindow }

function TThreadWindow.WaitBusy(SetAfterWaiting: boolean): boolean;
var R: DWORD;
  H: array[0..1] of THandle;
begin
  result := false;
  if fBusy <> 0 then begin
    H[0] := fBusy;
    H[1] := fHandleCreated;
    R := WaitForMultipleObjects(Length(H), PWOHandleArray(@H), True, InterValTimeOut);
    case R of
      WAIT_OBJECT_0: begin
          result := true;
          if SetAfterWaiting then begin
            if not SetEvent(fBusy) then RaiseLastOsError;
          end;
        end;
      WAIT_TIMEOUT: raise EThreadWindow.Create(ErrorWait);
      WAIT_ABANDONED: exit;
    else
      RaiseLastOSError;
    end;
  end;
end;

procedure TThreadWindow.Stop;
begin
  Terminate;
  if ThreadID <> 0 then begin
    PostThreadMessage(ThreadID, WM_QUIT, 0, 0);
    if GetCurrentThreadId <> ThreadID then WaitFor;
  end;
end;

destructor TThreadWindow.Destroy;
begin
  Stop;
  WaitFor;
  DeallocateHWnd;
  if fBusy <> 0 then begin
    CloseHandle(fBusy);
    fBusy := 0;
  end;
  if fHandleCreated <> 0 then begin
    CloseHandle(fHandleCreated);
    fHandleCreated := 0;
  end;
  FreeIcon(fIcon);
  try
    DoAfterStop;
  finally
    inherited;
  end;
end;

procedure TThreadWindow.Execute;
// Получаем текущее сообщение и обрабатываем его
  function ProcessCurrentMessage: boolean;
  var MSG: TMSG;
  begin
    if not Windows.GetMessage(MSG, 0, 0, 0) then Terminate;
    if not Terminated then begin
      // Если пришло сообщение от таймера
      if (MSG.message = WM_TIMER) and (UINT(MSG.wParam) = fTimer) then begin
        // Немного ждём окончания передачи данных от основного потока
        if WaitForSingleObject(fBusy, 1) = WAIT_OBJECT_0 then begin
          // Если дождались, то выполняем обработчик события таймера
          try
            ProcessMessage(MSG);
          finally
            SetEvent(fBusy);
          end
        end
          //        Если недождались, то пропускаем этот тост
          //        else
          //          PostMessage(MSG.hwnd, MSG.message, MSG.wParam, MSG.lParam);
      end
      else
        ProcessMessage(MSG);
    end;
    result := MSG.message = WM_NULL;
  end;
  //Ждем, пока окно невидимо
  procedure WaitNoVisible;
  begin
    while (not fVisible) and (not Terminated) do
      ProcessCurrentMessage;
    PostThreadMessage(ThreadID, WM_NULL, 0, 0);
    while not ProcessCurrentMessage do
      if Terminated then break;
  end;
  //Выжидаем, некоторое время, до того, как окно должно стать фактически видимым
  procedure WaitInterval;
  var P: Pointer;
    T: Int64;
  begin
    P := nil;
    fTimer := 0;
    try
      fShowTick := GetTickCount;
      if (fVisible) and (not Terminated) then begin
        if fInterval > 0 then begin
          P := MakeObjectInstance(TimerProc);
          fTimer := SetTimer(0, 1, 10, P);
        end;
      end;
      if fInterval > 0 then begin
        while (fVisible) and (not Terminated) do begin
          T := GetTickCount;
          T := Abs(T - fShowTick);
          if T > fInterval then Break;
          ProcessCurrentMessage;
        end;
      end;
      // Запрещаем добавление сообщений в очередь
      ResetEvent(fHandleCreated);
      // Обрабатываем все оставшиеся сообщения в очереди
      PostThreadMessage(ThreadID, WM_NULL, 0, 0);
      while (not Terminated) and (not ProcessCurrentMessage) do
        ;
    finally
      if fTimer <> 0 then
        if not KillTimer(0, fTimer) then RaiseLastOSError;
      if P <> nil then FreeObjectInstance(P);
      fTimer := 0;
    end;
  end;
  // В цикле обрабатываем сообщения посланые окну
  // Также создаём таймер, который шлёт сообщения WM_TIMER
  procedure MainCikl;
  begin
    fTimer := SetTimer(fWND, 2, 10, nil);
    try
      while (fVisible) and (not Terminated) do begin
        ProcessCurrentMessage;
      end;
    finally
      if fTimer <> 0 then
        if not KillTimer(fWND, fTimer) then RaiseLastOSError;
    end;
  end;
  // Собственно тело метода Execute
begin
  try
    SetEvent(fBusy);
    try
      repeat
        WaitNoVisible;
        WaitInterval;
        if (fVisible) and (not Terminated) then begin
          ShowWND;
          // Разрешаем добавление сообщений в очередь
          SetEvent(fHandleCreated);
          try
            MainCikl;
          finally
            CloseWND;
          end;
        end
        else
          SetEvent(fHandleCreated);
      until Terminated;
    finally
      ResetEvent(fHandleCreated);
      try
        Windows.UnregisterClass(PChar(NameClass), hInstance);
      finally
        SetEvent(fHandleCreated);
      end;
    end;
  except
    on E: Exception do begin
      fTextError := E.Message;
      fErrorClass := ExceptClass(E.ClassType);
      SetEvent(fBusy);
    end;
  end;
end;

//Эта функция возвращает параметры шрифта
//Если Font=0, то возвращаются соответствующие параметы по умолчанию

class function TThreadWindow.GetFontIndirect(Font: HFont; DefaultFont: TDefaultFont): tagLOGFONT;
var NonClientMetrics: TNonClientMetrics;
  Siz: integer;
  procedure DoIndirect;
  begin
    Siz := SizeOf(NonClientMetrics);
    FillChar(NonClientMetrics, Siz, 0);
    NonClientMetrics.cbSize := Siz;
    if DefaultFont <> dTimeFont then begin
      if SystemParametersInfo(SPI_GETNONCLIENTMETRICS, 0, @NonClientMetrics, 0) then
        with NonClientMetrics do
          case DefaultFont of
            dCaptionFont: result := lfCaptionFont;
            dSmCaptionFont: result := lfSmCaptionFont;
            dMenuFont: result := lfMenuFont;
            dStatusFont: result := lfStatusFont;
            dMessageFont: result := lfMessageFont;
          end
      else
        RaiseLastOSError;
    end
    else begin
      result.lfHeight := -8;
      result.lfWidth := 0;
      result.lfEscapement := 0;
      result.lfOrientation := 0;
      result.lfWeight := FW_NORMAL;
      result.lfItalic := 0;
      result.lfUnderline := 0;
      result.lfStrikeOut := 0;
      result.lfCharSet := DEFAULT_CHARSET;
      result.lfOutPrecision := OUT_DEFAULT_PRECIS;
      result.lfClipPrecision := CLIP_DEFAULT_PRECIS;
      result.lfQuality := PROOF_QUALITY;
      result.lfPitchAndFamily := FF_MODERN;
      result.lfFaceName := 'Small Fonts';
    end;
  end;
begin
  FillChar(Result, SizeOf(Result), 0);
  if Font = 0 then
    DoIndirect
  else begin
    Siz := SizeOf(result);
    if GetObject(Font, Siz, @result) = 0 then begin
      DoIndirect
    end;
  end;
end;

procedure TThreadWindow.ProcessMessage(MSG: TMSG);
var Message: TMessage;
  OldCallDispath: TCallDispath;
begin
  Message.Msg := Msg.message;
  Message.WParam := MSG.wParam;
  Message.LParam := MSG.lParam;
  Message.Result := 0;
  try
    OldCallDispath := fCallDispath;
    // Если нить еще не создана, то сразу вызываем обработчики событий
    if ThreadId = 0 then begin
      fCallDispath := cdOutThread;
      try
        DoBeforeDispath(Message);
        if Message.Result = 0 then
          Dispatch(Message);
      finally
        fCallDispath := OldCallDispath;
        fLastMessage := Message;
      end;
    end
    else begin
      // Если сообщение передавалось окну, то пересылаем сообщение окну
      // иначе вызываем обработчики событий
      if fCallDispath <> cdInWindow then fCallDispath := cdInThread;
      try
        inc(fCountInStack);
        DoBeforeDispath(Message);
        if (fCallDispath <> cdInWindow) and // Вызов производится не в окне
        (Message.Result = 0) and // Сообщение не обработано
        (MSG.hwnd = fWND) and // Сообщение предназаначалось окну
        (fWND <> 0) then {// Окно создано} begin
          MSG.message := Message.Msg;
          MSG.wParam := Message.WParam;
          MSG.lParam := Message.LParam;
          TranslateMessage(MSG);
          DispatchMessage(MSG);
        end
        else begin
          try
            if Message.Result = 0 then
              Dispatch(Message);
          finally
            if (Message.Msg > WM_USER) and (fCountInStack = 1) then begin
              fLastMessage := Message;
              SetEvent(fBusy);
            end;
          end;
        end;
      finally
        Dec(fCountInStack);
        if fCallDispath <> cdInWindow then fCallDispath := OldCallDispath;
      end;
    end;
  except
    on E: EAbort do
      Exit
  else
    raise;
  end;
end;

procedure TThreadWindow.WNDProc(var Message: TMessage);
var OldCallDispath: TCallDispath;
begin
  OldCallDispath := fCallDispath;
  try
    fCallDispath := cdInWindow;
    DoBeforeDispath(Message);
    if Message.Result = 0 then
      Dispatch(Message);
    if Message.Result = 0 then
      Message.Result := DefWindowProc(fWND, Message.Msg, Message.WParam, Message.LParam);
    fLastMessage := Message;
  finally
    fCallDispath := OldCallDispath;
  end;
end;

function TThreadWindow.InThread: boolean;
var Id: Cardinal;
begin
  result := (ThreadID = 0) or (fBusy = 0);
  if not result then begin
    Id := GetCurrentThreadId;
    result := Id = ThreadID;
  end;
end;

function TThreadWindow.Perform(Msg: Cardinal; WParam, LParam: LongInt): Longint;
var M: TMSG;
begin
  Result := -1;
  if InThread then begin
    FillChar(M, SizeOf(M), 0);
    M.message := Msg;
    M.wParam := WParam;
    M.lParam := LParam;
    ProcessMessage(M);
    Result := fLastMessage.Result;
  end
  else begin
    if MSG <= WM_USER then
      raise EThreadWindow.CreateFmt(ErrorParam, ['MSG', inttostr(MSG)]);
    if (ThreadID <> 0) and (WaitBusy) then begin
      PostThreadMessage(ThreadId, Msg, WParam, LParam);
      if WaitBusy then begin
        Result := fLastMessage.Result;
        SetEvent(fBusy);
      end;
    end;
  end;
end;

//По таймеру посылаем потоку пустое сообщение
//для того, чтобы поток вышел из режима ожидания

procedure TThreadWindow.TimerProc(var M: TMessage);
begin
  if ThreadID <> 0 then PostThreadMessage(ThreadID, WM_NULL, 0, 0);
end;

procedure TThreadWindow.DoTerminate;
var EClass: string;
begin
  inherited;
  if fTextError <> '' then begin
    if fErrorClass = nil then
      EClass := 'nil'
    else
      EClass := fErrorClass.ClassName;
    if not fErrorClass.InheritsFrom(EAbort) then
      raise EThreadWindow.CreateFMT(ErrorThread, [fTextError, EClass]);
  end;
end;

procedure TThreadWindow.ShowWND;
begin
  try
    AllocateHWnd(WNDProc);
    WNDCreated(fWND);
    Invalidate(uaAll);
    ShowWindow(fWND, SW_SHOWNA);
  except
    on E: Exception do begin
      raise Exception(E.ClassType).Create('ShowWND:' + #13#10 + E.Message);
    end;
  end;
end;

procedure TThreadWindow.Change(var UpdateAreas: TUpdateAreas);
var Style: LongInt;
begin
  if fPercent <> fOldPercent then begin
    if (fOldPercent = -1) or (fPercent = -1) then
      UpdateAreas := UpdateAreas + [uaAll]
    else
      UpdateAreas := UpdateAreas + [uaProgress];
    fOldPercent := fPercent;
  end;
  if fEnabled <> fOldEnabled then begin
    UpdateAreas := UpdateAreas + [uaAll];
    fOldEnabled := fEnabled;
    if fWnd <> 0 then begin
      Style := GetWindowLong(fWND, GWL_STYLE);
      if fEnabled then
        Style := Style and (not WS_DISABLED)
      else begin
        Style := Style or WS_DISABLED;
        fHotPoint.X := -1;
        fHotPoint.Y := -1;
      end;
      SetWindowLong(fWND, GWL_STYLE, Style);
    end;
  end;
end;

procedure TThreadWindow.CloseWND;
begin
  try
    try
      WNDDestroy(fWND);
    finally
      DeallocateHWnd;
    end;
  finally
    fVisible := false;
    fShowTick := 0;
  end;
end;

// Создание дескриптора окна

procedure TThreadWindow.AllocateHWnd(Method: TWndMethod);
var TempClassInfo: TWndClass;
  WndClass: TWndClass;
  ClassRegistered: LongBool;
  HInst: THandle;
  HA: THandle;
  A: array[0..255] of char;
  Style: Cardinal;
  procedure UpdateBoundsRect;
  var W, H, CX, CY: integer;
    DC: HDC;
    R: TRect;
    OldFont: HFont;
  begin
    CX := Windows.GetSystemMetrics(SM_CXFULLSCREEN);
    CY := (2 * Windows.GetSystemMetrics(SM_CYFULLSCREEN)) div (3);
    DC := GetWindowDC(0);
    OldFont := SelectObject(DC, fFont);
    try
      R := Rect(0, 0, CX div 2, CY * 2);
      windows.DrawText(DC, PChar(fText), length(fText), R, DT_CALCRECT);
      W := R.Right + 2 * BorderWidth;
      H := Max(R.Bottom, IconSize) + 2 * BorderWidth;
      if IconSize > 0 then inc(W, IconSize + BorderWidth);
      if Percent >= 0 then inc(H, 2 * BorderWidth);
      R := Rect((CX - W) div (2),
        (CY - H) div (2),
        (CX + W) div (2),
        (CY + H) div (2));
      fBoundsRect := R;
    finally
      SelectObject(DC, OldFont);
      ReleaseDC(0, DC);
    end;
  end;
begin
  //Задание исходных данных
  if fWND <> 0 then DeallocateHWnd;
  fLayoutUpdated := False;
  HInst := hInstance;
  if Hinst = 0 then Exception.Create('Hinst ' + SysErrorMessage(GetLastError));
  FillChar(TempClassInfo, SizeOf(TempClassInfo), 0);
  FillChar(WndClass, SizeOf(WndClass), 0);
  FillChar(A, SizeOf(A), 0);
  move(NameClass[1], A, Length(NameClass) * SizeOf(NameClass[1]));
  //Регистрация класса, если еще не зарегистрирован
  ClassRegistered := GetClassInfo(HInst, PChar(NameClass), TempClassInfo);
  if not ClassRegistered then begin
    WndClass.style := CS_GLOBALCLASS or CS_NOCLOSE or CS_SAVEBITS {or CS_DROPSHADOW};
    WndClass.lpfnWndProc := @DefWindowProc;
    WndClass.hInstance := HInst;
    WndClass.hbrBackground := 0;
    WndClass.lpszMenuName := '';
    WndClass.lpszClassName := PChar(@A);
    WndClass.hCursor := LoadCursor(0, IDC_ARROW);
    HA := Windows.RegisterClass(WndClass);
    if HA = 0 then RaiseLastOSError;
  end;
  try
    UpdateBrush(fColor, fBrush);
    if fFont = 0 then InternalSetFont(fFont, 0, dMessageFont);
    if LongInt(fIcon) = -1 then UpdateIcon(fIcon, fIcon);
    if (fBoundsRect.Right - fBoundsRect.Left) = 0 then UpdateBoundsRect;
    DoAfterSetBounds(fBoundsRect, fWindowRect, fClientRect);

    Style := WS_POPUP;
    if not fEnabled then
      Style := Style or WS_DISABLED;

    fWND := CreateWindowEx(WS_EX_TOOLWINDOW or WS_EX_TOPMOST or WS_EX_NOACTIVATE {or WS_EX_LAYOUTRTL},
      PChar(@A),
      'WaitNew',
      Style,
      fWindowRect.Left,
      fWindowRect.Top,
      Abs(fWindowRect.Right - fWindowRect.Left),
      Abs(fWindowRect.Bottom - fWindowRect.Top),
      0, 0,
      HInst,
      nil);
    if fWND = 0 then RaiseLastOSError;
    fHandleCreatedTick := GetTickCount;
    if fAlphaShow then
      UpdateBlend(fWND, 1)
    else
      UpdateBlend(fWND, fAlphaBlendValue);
    if Assigned(Method) then begin
      fHObj := MakeObjectInstance(Method);
      Windows.SetWindowLong(fWND, GWL_WNDPROC, Integer(fHObj));
    end;
  except
    DeallocateHWnd;
    raise;
  end;
end;

// Удаление дескриптора окна

procedure TThreadWindow.DeallocateHWnd;
begin
  try
    try
      if fWND <> 0 then begin
        if DestroyWindow(fWND) then
          fWND := 0
        else
          RaiseLastOSError;
      end;
    finally
      if fHObj <> nil then begin
        FreeObjectInstance(fHObj);
        fHObj := nil;
      end;
    end;
  finally
    fVisible := false;
    if fFont <> 0 then DeleteObject(fFont);
    UpdateBrush($1FFFFFFF, fBrush);
  end;
end;

procedure TThreadWindow.Invalidate(Area: TUpdateArea = uaWindow);
var R: PRect;
begin
  if Area = uaAll then fLayoutUpdated := False;
  if fWND <> 0 then begin
    case Area of
      uaIcon: R := @fElementPos.IconRect;
      uaProgress: R := @fElementPos.ProgressRect;
    else
      R := nil;
    end;
    InvalidateRect(fWND, R, True);
  end;
end;

function TThreadWindow.MakeWParam(IndexProp, Part: Word): Longint;
begin
  result := ((Part) shl (16)) or IndexProp;
end;

procedure TThreadWindow.UMGetPropertyData(var Message: TUMPropertyData);
  procedure CopyBuffer(var Buffer; Size: integer);
  begin
    if Message.Value^.DataSize <= 0 then begin
      Message.Value^.DataSize := Size;
      ReallocMem(Message.Value^.Data, Message.Value^.DataSize);
    end;
    FillChar(Message.Value^.Data^, Message.Value^.DataSize, 0);
    if @Buffer <> nil then
      Move(Buffer, Message.Value^.Data^, Min(Message.Value^.DataSize, Size));
  end;
begin
  if (Message.Value = nil) or
    (Message.Value^.RecordSize <> SizeOf(TPropertyData)) or
    ((Message.Value^.DataSize <= 0) and (Message.Value^.Data <> nil)) or
    ((Message.Value^.DataSize > 0) and (Message.Value^.Data = nil)) then begin
    Message.Result := 0;
    Exit;
  end;
  Message.Result := 1;
  case Message.IndexProp of
    IDVisible: CopyBuffer(fVisible, SizeOf(fVisible));
    IdColor: CopyBuffer(fColor, SizeOf(fColor));
    IdFontColor: CopyBuffer(fFontColor, SizeOf(fFontColor));
    IdIcon: CopyBuffer(fIcon, SizeOf(fIcon));
    IdIconIndex: CopyBuffer(fIconIndex, SizeOf(fIconIndex));
    IdIconSize: CopyBuffer(fIconSize, SizeOf(fIconSize));
    IdBoundsRect: CopyBuffer(fBoundsRect, SizeOf(fBoundsRect));
    IdText: begin
        case Message.Part of
          0: if fText <> '' then CopyBuffer(fText[1], SizeOf(fText[1]) * (Length(fText) + 1));
        end;
      end;
    IdAlphaBlendValue: CopyBuffer(fAlphaBlendValue, SizeOf(fAlphaBlendValue));
    IdFont: CopyBuffer(fFont, SizeOf(fFont));
  else
    Message.Result := 0;
  end;
end;

procedure TThreadWindow.UMSetPropertyValue(var Message: TUMPropertyValue);
var S: string;
  I: LongInt;
begin
  Message.Result := 1;
  I := Message.Value;
  case Message.IndexProp of
    IDVisible: begin
        if fVisible <> (I <> 0) then begin
          fVisible := I <> 0;
          if not fAlphaShow then begin
            if AlphaBlendValue = 0 then AlphaBlendValue := 255;
          end;
        end;
      end;
    IdColor: begin
        if fColor <> Cardinal(I) then begin
          fColor := Cardinal(I);
          if fWND <> 0 then begin
            UpdateBrush(fColor, fBrush);
            fUpdateAreas := fUpdateAreas + [uaWindow];
          end;
        end;
      end;
    IdFontColor: begin
        if fFontColor <> Cardinal(I) then begin
          fFontColor := Cardinal(I);
          fUpdateAreas := fUpdateAreas + [uaWindow];
        end;
      end;
    IdIcon: begin
        UpdateIcon(HIcon(I), fIcon);
        Invalidate(uaIcon);
      end;
    IdIconIndex:
      if fIconIndex <> I then begin
        fIconIndex := I;
        Invalidate(uaIcon);
      end;
    IdIconSize:
      if fIconSize <> I then begin
        fIconSize := I;
        fUpdateAreas := fUpdateAreas + [uaAll];
      end;
    IdBoundsRect: begin
        Move(Pointer(I)^, fBoundsRect, SizeOf(fBoundsRect));
        DoAfterSetBounds(fBoundsRect, fWindowRect, fClientRect);
        if (fWND <> 0) and (Visible) then begin
          Invalidate(uaAll);
          SetWindowPos(fWND,
            0,
            fWindowRect.Left,
            fWindowRect.Top,
            fWindowRect.Right - fWindowRect.Left,
            fWindowRect.Bottom - fWindowRect.Top,
            SWP_NOACTIVATE or SWP_NOOWNERZORDER);
        end;
      end;
    IdText: begin
        S := PChar(Message.Value);
        case Message.Part of
          0: begin
              if S <> fText then begin
                fText := S;
                Invalidate(uaWindow);
              end;
            end;
        end;
      end;
    IdAlphaBlendValue: if fAlphaBlendValue <> I then begin
        fAlphaBlendValue := I;
        if not fAlphaShow then begin
          if fAlphaBlendValue = 0 then
            fVisible := False
          else
            UpdateBlend(fWND, fAlphaBlendValue);
        end;
      end
      else
        Message.Result := 0;
    IdFont: begin
        if InternalSetFont(fFont, HFont(I), dMessageFont) then
          Invalidate(uaAll);
      end;
  else
    Message.Result := 0;
  end;
end;

procedure TThreadWindow.WMERASEBKGND(var Message: TWMERASEBKGND);
var NeedDC: boolean;
  OldBrush: HBrush;
  OldPen: HPen;
  OldFont: HFont;
  OldBk: Integer;
begin
  if (CallDispath = cdInWindow) and (fWND <> 0) and (not Terminated) then
    with Message do begin
      NeedDC := DC = 0;
      if NeedDC then DC := GetWindowDC(fWND);
      try
        if not fLayoutUpdated then begin
          UpdateLayout(fClientRect, fElementPos);
          fLayoutUpdated := True;
        end;
        if fBrush <> 0 then
          OldBrush := SelectObject(DC, fBrush)
        else
          OldBrush := SelectObject(DC, GetStockObject(NULL_BRUSH));
        OldPen := SelectObject(DC, GetStockObject(BLACK_PEN));
        OldBk := GetBkMode(DC);
        OldFont := SelectObject(DC, fFont);
        SetTextColor(DC, fFontColor);
        try
          SetBkMode(DC, TRANSPARENT);
          DrawWND(DC, fWindowRect);
        finally
          SetBkMode(DC, OldBk);
          SelectObject(DC, OldFont);
          SelectObject(DC, OldPen);
          SelectObject(DC, OldBrush);
        end;
      finally
        if NeedDC then begin
          ReleaseDC(fWND, DC);
          DC := 0;
        end;
      end;
      Message.Result := 1;
    end;
end;

procedure TThreadWindow.WMLBUTTONDOWN(var Message: TWMLBUTTONDOWN);
var P: TPoint;
  R: TRect;
begin
  P.X := Message.XPos;
  P.Y := Message.YPos;
  if PtInRect(fClientRect, P) then begin
    GetWindowRect(fWND, R);
    fHotPoint.X := P.X + R.Left;
    fHotPoint.Y := P.Y + R.Top;
  end;
end;

procedure TThreadWindow.WMLBUTTONUP(var Message: TWMLBUTTONUP);
begin
  fHotPoint.X := -1;
  fHotPoint.Y := -1;
end;

procedure TThreadWindow.WMSHOWWINDOW(var Message: TWMSHOWWINDOW);
begin
  Visible := Message.Show;
  Message.Result := 1;
end;

procedure TThreadWindow.WMTIMER(var Message: TWMTIMER);
var CurrBlend: Double;
  P: TPoint;
  R: TRect;
  UpdateAreas: TUpdateAreas;
  A: TUpdateArea;
begin
  if (fVisible) and (not Terminated) then begin
    UpdateAreas := fUpdateAreas;
    Change(UpdateAreas);
    fUpdateAreas := [];
    if uaAll in UpdateAreas then
      Invalidate(uaAll)
    else if uaWindow in UpdateAreas then
      Invalidate(uaWindow)
    else begin
      A := uaWindow;
      repeat
        if A < High(TUpdateArea) then A := Succ(A);
        if A in UpdateAreas then Invalidate(A);
      until A = High(TUpdateArea);
    end;
  end;
  if fAlphaShow and
    (UINT(Message.TimerID) = fTimer) and
    (fIntervalAlphaShow > 0) and
    (CallDispath = cdInWindow) then begin
    CurrBlend := GetTickCount;
    CurrBlend := Abs(CurrBlend - fHandleCreatedTick) / fIntervalAlphaShow;
    if CurrBlend >= 1 then begin
      fAlphaShow := False;
      UpdateBlend(fWND, fAlphaBlendValue);
    end
    else begin
      UpdateBlend(fWND, Round(CurrBlend * fAlphaBlendValue));
    end;
  end;
  if ((fHotPoint.X <> -1) or (fHotPoint.Y <> -1)) then begin
    windows.GetCursorPos(P);
    if (P.X <> fHotPoint.X) or (P.Y <> fHotPoint.Y) then begin
      ResetEvent(fHandleCreated);
      try
        R := BoundsRect;
        OffsetRect(R, P.X - fHotPoint.X, P.Y - fHotPoint.Y);
        BoundsRect := R;
        Inc(fHotPoint.X, P.X - fHotPoint.X);
        Inc(fHotPoint.Y, P.Y - fHotPoint.Y);
      finally
        SetEvent(fHandleCreated);
      end;
    end;
  end;
end;

procedure TThreadWindow.WMWINDOWPOSCHANGED(var Message: TWMWINDOWPOSCHANGED);
begin
  with Message.WindowPos^ do begin
    if Test(flags, SWP_HIDEWINDOW) then Visible := false;
    if Test(flags, SWP_SHOWWINDOW) then Visible := true;
  end;
end;

// Освобождение дескриптора иконки

procedure TThreadWindow.FreeIcon(var DestIcon: HIcon);
begin
  if (DestIcon <> 0) and
    (DestIcon <> THandle(-1)) and
    (DestIcon <> LoadIcon(0, IDI_APPLICATION)) then begin
    if DestroyIcon(DestIcon) then
      DestIcon := 0
    else
      RaiseLastOSError;
  end
  else
    DestIcon := 0;
end;

procedure TThreadWindow.UpdateIcon(SourceIcon: HIcon; var DestIcon: HIcon);
var IconInfo: TIconInfo;
  function LoadDefIcon: HIcon;
  begin
    result := LoadIcon(hInstance, NameIconWait);
    if result = 0 then result := LoadIcon(hInstance, 'MAINICON');
    if result = 0 then result := LoadIcon(0, IDI_APPLICATION);
  end;
begin
  FreeIcon(DestIcon);
  if (SourceIcon = HIcon(-1)) or (fIconSize = -1) then begin
    DestIcon := LoadDefIcon;
    fIconSize := GetSystemMetrics(SM_CXICON);
  end
  else begin
    fillchar(IconInfo, SizeOf(IconInfo), 0);
    IconInfo.fIcon := true;
    if GetIconInfo(SourceIcon, IconInfo) then begin
      DestIcon := CreateIconIndirect(IconInfo);
      if IconInfo.hbmColor <> 0 then
        if not DeleteObject(IconInfo.hbmColor) then RaiseLastOSError;
      if IconInfo.hbmMask <> 0 then
        if not DeleteObject(IconInfo.hbmMask) then RaiseLastOSError;
    end
    else
      DestIcon := LoadDefIcon;
  end;
end;

procedure TThreadWindow.UpdateLayout(ClientRect: TRect;
  var ElementPos: TElementPos);
var H, Tmp, RealIconSize: integer;
begin
  H := (ClientRect.Bottom - ClientRect.Top) - 2 * BorderWidth;
  with ElementPos do begin
    // Координаты иконки
    RealIconSize := Max(IconSize, 0);
    if RealIconSize < H then begin
      Tmp := Min(((H - RealIconSize) div (2)), 0) + BorderWidth;
      IconRect := Rect(ClientRect.Left + BorderWidth,
        ClientRect.Top + TMP,
        ClientRect.Left + BorderWidth + RealIconSize,
        ClientRect.Top + TMP + RealIconSize)
    end
    else
      IconRect := Rect(ClientRect.Left + BorderWidth,
        ClientRect.Top + BorderWidth,
        ClientRect.Left + BorderWidth + RealIconSize,
        ClientRect.Top + BorderWidth + RealIconSize);
    // Координаты процента выполнения
    ProgressRect := Rect(ClientRect.Left + BorderWidth,
      ClientRect.Bottom - 2 * BorderWidth,
      ClientRect.Right - BorderWidth,
      ClientRect.Bottom - BorderWidth);

    if fPercent < 0 then
      ProgressRect.Top := ProgressRect.Bottom;
    if (ProgressRect.Top < IconRect.Bottom + BorderWidth) and
      (IconSize > 0) then
      ProgressRect.Left := IconRect.Right + BorderWidth;
    // Координаты текста
    TextRect := ClientRect;
    InflateRect(TextRect, -BorderWidth, -BorderWidth);
    if IconSize > 0 then
      TextRect.Left := IconRect.Right + BorderWidth;
    if fPercent >= 0 then
      TextRect.Bottom := ProgressRect.Top - 1;
  end;
end;

//Создание кисти

procedure TThreadWindow.UpdateBrush(const Color: Cardinal; var Brush: HBrush);
begin
  if Brush <> 0 then
    if not DeleteObject(Brush) then
      RaiseLastOSError
    else
      Brush := 0;
  if (Color <> $1FFFFFFF) and (Brush = 0) then
    Brush := CreateSolidBrush(Color);
end;

// Изменение прозрачности окна

procedure TThreadWindow.UpdateBlend(const WND: HWND; Value: Byte);
var AStyle: DWORD;
begin
  if (WND <> 0) and (@SetLayeredWindowAttributes <> nil) then begin
    AStyle := GetWindowLong(WND, GWL_EXSTYLE);
    if (Value = 255) then begin
      if AStyle and WS_EX_LAYERED <> 0 then
        SetWindowLong(WND, GWL_EXSTYLE, AStyle and (not WS_EX_LAYERED));
    end
    else begin
      if AStyle and WS_EX_LAYERED = 0 then
        if SetWindowLong(WND, GWL_EXSTYLE, AStyle or WS_EX_LAYERED) = 0 then
          raise EOSError.Create(SysErrorMessage(GetLastError));
      if not SetLayeredWindowAttributes(WND, 0, Value, LWA_ALPHA) then
        raise EOSError.Create(SysErrorMessage(GetLastError));
    end;
  end;
end;

procedure TThreadWindow.GetPropertyData(IndexProp, Part: Word; var Buffer; Size: LongInt);
var WParam: Longint;
  Value: TPropertyData;
begin
  WParam := ((Part) shl (16)) or IndexProp;
  Value.RecordSize := SizeOf(Value);
  Value.DataSize := Size;
  if Size <= 0 then
    raise EThreadWindow.CreateFmt(ErrorParam, ['Size', inttostr(Size)]);
  Value.Data := @Buffer;
  if Value.Data = nil then
    raise EThreadWindow.CreateFmt(ErrorParam, ['Buffer', 'nil']);
  Perform(UM_GetPropertyData, WParam, LongInt(@Value));
end;

procedure TThreadWindow.GetPropertyData(IndexProp, Part: Word; var S: string);
var WParam: Longint;
  Value: TPropertyData;
  Len: integer;
begin
  WParam := ((Part) shl (16)) or IndexProp;
  Value.RecordSize := SizeOf(Value);
  Value.DataSize := 0;
  Value.Data := nil;
  Perform(UM_GetPropertyData, WParam, LongInt(@Value));
  S := '';
  if (Value.Data <> nil) then begin
    try
      Len := Value.DataSize div SizeOf(S[1]);
      if PChar(Value.Data)[Len - 1] = #0 then Dec(Len);
      if Len > 0 then begin
        SetLength(S, Len);
        Move(Value.Data^, S[1], Len * SizeOf(S[1]));
      end;
    finally
      ReallocMem(Value.Data, 0);
    end;
  end;
end;

procedure TThreadWindow.GetPropertyData(IndexProp, Part: Word; var I: Integer);
var WParam: Longint;
  Value: TPropertyData;
begin
  WParam := ((Part) shl (16)) or IndexProp;
  Value.RecordSize := SizeOf(Value);
  Value.DataSize := SizeOf(I);
  Value.Data := @I;
  Perform(UM_GetPropertyData, WParam, LongInt(@Value));
end;

procedure TThreadWindow.GetPropertyData(IndexProp, Part: Word; var B: boolean);
var I: LongInt;
begin
  GetPropertyData(IndexProp, Part, I);
  B := (I <> 0);
end;


procedure TThreadWindow.SetText(const Value: string);
begin
  Perform(UM_SetPropertyValue, MakeWParam(IdText, 0), Longint(PChar(Value)));
end;

function TThreadWindow.GetText: string;
begin
  if InThread then
    result := fText
  else
    GetPropertyData(IdText, 0, Result);
end;

function TThreadWindow.GetVisible: boolean;
begin
  if InThread then
    result := fVisible
  else
    GetPropertyData(IdVisible, 0, Result);
end;

function TThreadWindow.GetBoundsRect: TRect;
begin
  GetPropertyData(IdBoundsRect, 0, Result, SizeOf(Result));
end;

procedure TThreadWindow.SetAlphaBlendValue(const Value: byte);
begin
  Perform(UM_SetPropertyValue, MakeWParam(IdAlphaBlendValue, 0), Longint(Value));
end;

procedure TThreadWindow.SetBoundsRect(const Value: TRect);
begin
  Perform(UM_SetPropertyValue, MakeWParam(IdBoundsRect, 0), Longint(@Value));
end;

procedure TThreadWindow.SetIcon(const Value: HIcon);
begin
  Perform(UM_SetPropertyValue, MakeWParam(IdIcon, 0), Longint(Value));
end;

procedure TThreadWindow.SetIconIndex(const Value: LongInt);
begin
  Perform(UM_SetPropertyValue, MakeWParam(IdIconIndex, 0), Value);
end;

procedure TThreadWindow.SetIconSize(const Value: LongInt);
begin
  Perform(UM_SetPropertyValue, MakeWParam(IDIconSize, 0), Value);
end;

procedure TThreadWindow.SetColor(const Value: Cardinal);
begin
  Perform(UM_SetPropertyValue, MakeWParam(IDColor, 0), LongInt(Value));
end;

procedure TThreadWindow.SetFont(const Value: hFont);
begin
  Perform(UM_SetPropertyValue, MakeWParam(IDFont, 0), LongInt(Value));
end;

procedure TThreadWindow.SetFontColor(const Value: Cardinal);
begin
  Perform(UM_SetPropertyValue, MakeWParam(IDFontColor, 0), LongInt(Value));
end;

procedure TThreadWindow.SetVisible(const Value: boolean);
begin
  Perform(UM_SetPropertyValue, MakeWParam(IDVisible, 0), IntBool[Value]);
end;

//Перед выполнением потока устанавливаем параметры по умолчанию

procedure TThreadWindow.AfterConstruction;
begin
  // Приоритет потока в котором работает окно ожидания
  Priority := {tpLowest tpTimeCritical} tpHighest;
  fOldPercent := fPercent;
  try
    DoBeforeResume;
  finally
    if not Terminated then begin
      fBusy := Windows.CreateEvent(nil, false, True, nil);
      fHandleCreated := Windows.CreateEvent(nil, True, True, nil);
    end;
    inherited;
    if not Terminated then begin
      Resume;
      WaitBusy(True);
    end;
  end;
end;

constructor TThreadWindow.Show(AMessage: string);
begin
  inherited Create(true);
  fEnabled := True;
  fHotPoint.X := -1;
  fHotPoint.Y := -1;
  AlphaBlendValue := 255;
  AlphaShow := true;
  IntervalAlphaShow := 1000;
  Interval := 500;
  FontColor := GetSysColor(COLOR_WINDOWTEXT);
  Color := GetSysColor(COLOR_BTNFACE);
  Percent := -1;
  IconSize := -1;
  fIcon := HIcon(-1);
  if AMessage = '' then AMessage := DefaultMessage;
  Text := AMessage;
  Visible := true;
end;

procedure TThreadWindow.DoBeforeResume;
begin

end;

procedure TThreadWindow.DoAfterSetBounds(NewBoundsRect: TRect;
  var NewWindowRect, NewClientRect: TRect);
begin
  NewWindowRect := NewBoundsRect;
  NewClientRect := NewWindowRect;
  OffsetRect(NewClientRect, -NewClientRect.Left, -NewClientRect.Top);
end;

procedure TThreadWindow.DoAfterStop;
begin

end;

procedure TThreadWindow.DoBeforeDispath(var Message: TMessage);
begin

end;

procedure TThreadWindow.DrawBorder(DC: HDC; ARect: TRect; Ctl3D: boolean;
  Width: Integer; IsDown: boolean);
var OldPen, Pen: HPen;
begin
  OldPen := 0;
  Pen := 0;
  try
    windows.Rectangle(DC, ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
    Pen := CreatePen(PS_SOLID, 1, GetSysColor(COLOR_WINDOWFRAME));
    InflateRect(ARect, -1, -1);
    OldPen := SelectObject(DC, Pen);
    windows.Rectangle(DC, ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
  finally
    SelectObject(DC, OldPen);
    DeleteObject(Pen);
  end;
end;

procedure TThreadWindow.DrawIcon(DC: HDC; ARect: TRect; Icon: HIcon; Brush: HBrush);
begin
  if Icon <> 0 then begin
    Windows.DrawIconEx(DC,
      ARect.Left, ARect.Top,
      Icon,
      ARect.Right - ARect.Left, ARect.Bottom - ARect.Top,
      fIconIndex, Brush, DI_NORMAL);
  end;
end;

procedure TThreadWindow.DrawProgress(DC: HDC; ARect: TRect; Percent: integer);
var TmpR: TRect;
  //  Br: HBrush;
begin
  if (Percent >= 0) then begin
    Percent := min(Percent, 1000);
    TMPR := ARect;
    inflateRect(TMPR, -1, -1);
    TMPR.Right := TMPR.Left + ((TMPR.Right - TMPR.Left) * Percent + 500) div (1000);
    if TMPR.Right <> TMPR.Left then begin
      //Br := CreateSolidBrush(GetHighLightColor(Color, 50));
      try
        FillRect(DC, TMPR, GetSysColorBrush(COLOR_3DHIGHLIGHT));
      finally
        //DeleteObject(Br);
        ExcludeClipRect(DC, TMPR.Left, TMPR.Top, TMPR.Right, TMPR.Bottom);
      end;
    end;
    Rectangle(DC, ARect.Left,
      ARect.Top,
      ARect.Right,
      ARect.Bottom);
  end;
end;

procedure TThreadWindow.DrawText(DC: HDC; ARect: TRect; Text: PChar; Len: integer);
begin
  if Text <> nil then Windows.DrawText(DC, Text, Len, ARect, DT_WORDBREAK or DT_LEFT);
end;

procedure TThreadWindow.DrawWND(DC: HDC; ARect: TRect);
var R: TRect;
  Pen, OldPen: HPen;
  function NotNullRect(R: TRect): boolean;
  begin
    result := (R.Right > R.Left) and (R.Bottom > R.Top);
  end;
  //Рисуем иконку
  procedure PaintIcon;
  begin
    if (fIcon <> 0) and (LongInt(fIcon) <> -1) and (NotNullRect(fElementPos.IconRect)) then
      with fElementPos do begin
        DrawIcon(DC, IconRect, fIcon, fBrush);
        ExcludeClipRect(DC, IconRect.Left, IconRect.Top, IconRect.Right, IconRect.Bottom);
      end;
  end;
  //Рисуем текст сообщения
  procedure PaintText;
  begin
    if (fText <> '') and NotNullRect(fElementPos.TextRect) then
      with fElementPos do begin
        SelectObject(DC, fFont);
        SetTextColor(DC, fFontColor);
        SetBkColor(DC, Color);
        SetBkMode(DC, TRANSPARENT);
        SelectObject(DC, fBrush);
        DrawText(DC, TextRect, PChar(fText), Length(fText));
      end;
  end;
begin
  R := ARect;
  OffsetRect(R, -R.Left, -R.Top);
  try
    Pen := CreatePen(PS_SOLID, 1, GetSysColor(COLOR_BTNSHADOW) {GetShadowColor(Color, -50)});
    OldPen := SelectObject(DC, Pen);
    SelectObject(DC, fBrush);
    try
      if (fPercent >= 0) and (NotNullRect(fElementPos.ProgressRect)) then
        with fElementPos do begin
          DrawProgress(DC, ProgressRect, fPercent);
          ExcludeClipRect(DC, ProgressRect.Left, ProgressRect.Top, ProgressRect.Right, ProgressRect.Bottom);
        end;
      PaintIcon;
      DrawBorder(DC, fClientRect, True, 2);
      PaintText;
    finally
      SelectObject(DC, OldPen);
      if not DeleteObject(Pen) then RaiseLastOSError;
    end;
  finally
  end;
end;

procedure TThreadWindow.WNDCreated(WND: HWND);
begin

end;

procedure TThreadWindow.WNDDestroy(var WND: HWND);
begin

end;

end.
