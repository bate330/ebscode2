unit mpComPort;

interface
uses SysUtils, Windows, Classes;

//==============================================================================
type
  TComParity = (cpEven, cpMark, cpNone, cpOdd);
  TComStopBits = (csbOne, csbOne5, csbTwo);

//------------------------------------------------------------------------------
  TmpComPort = class(TComponent)
  strict private
    FPort: Integer;
    FBaudrate: Integer;
    FParity: TComParity;
    FStopBits: TComStopBits;
    FByteSize: Integer;
    FOpened: Boolean;
    PortHandle: THandle;
    EventMask: Cardinal;
    FTxBufferSize: Cardinal;
    FRxBufferSize: Cardinal;
    FReadTimeout: Cardinal;

    procedure SetPort(AValue: Integer);
    function GetPortName: string;
    procedure SetBaudrate(AValue: Integer);
    procedure SetParity(AValue: TComParity);
    procedure SetStopBits(AValue: TComStopBits);
    procedure SetByteSize(AValue: Integer);
    function GetRxCount: Cardinal;

  strict protected
    procedure AssignTo(ADest: TPersistent); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Open;
    procedure Close;
    procedure Write(AData: Pointer; ASize: Cardinal); overload;
    procedure Write(AData: TBytes); overload;
    procedure Write(AByte: Byte); overload;
    procedure Write(AWord: Word); overload;
    procedure Read(AData: Pointer; ASize: Cardinal);
    function ReadByte: Byte;
    function ReadWord: Word;

    property Opened: Boolean read FOpened;

  published
    property Port: Integer read FPort write SetPort;
    property PortName: string read GetPortName;
    property Baudrate: Integer read FBaudrate write SetBaudrate;
    property Parity: TComParity read FParity write SetParity;
    property StopBits: TComStopBits read FStopBits write SetStopBits;
    property ByteSize: Integer read FByteSize write SetByteSize;
    property TxBufferSize: Cardinal read FTxBufferSize write FTxBufferSize;
    property RxBufferSize: Cardinal read FRxBufferSize write FRxBufferSize;
    property ReadTimeout: Cardinal read FReadTimeout write FReadTimeout;
    property RxCount: Cardinal read GetRxCount;


  end;

//------------------------------------------------------------------------------
procedure SetAllComPortList(AStrings: TStrings);
procedure SetDCBBaudrate(var ADCB: TDCB; ABaudrate: Integer);
procedure SetDCBParity(var ADCB: TDCB; AParity: TComParity);
procedure SetDCBStopBits(var ADCB: TDCB; AStopBits: TComStopBits);
procedure SetDCBByteSize(var ADCB: TDCB; AByteSize: Integer);
function ToStr(AParity: TComParity): string; overload;
function ToStr(AStopBits: TComStopBits): string; overload;

//==============================================================================
procedure Register;

//==============================================================================
implementation

//==============================================================================
//=== TmpfComPort ==============================================================
//==============================================================================
constructor TmpComPort.Create(AOwner: TComponent);
begin
  inherited;
  FPort := 1;
  FBaudrate := 9600;
  FParity := cpNone;
  FStopBits := csbOne;
  FByteSize := 8;
  FTxBufferSize := 2048;
  FRxBufferSize := 2048;
  FReadTimeout := 5000;
  FOpened := false;
end;

//------------------------------------------------------------------------------
destructor TmpComPort.Destroy;
begin
  Close;
  inherited;
end;

//------------------------------------------------------------------------------
procedure TmpComPort.AssignTo(ADest: TPersistent);
var
  ADestCom: TmpComPort;
begin
  if ADest is TmpComPort then
  begin
    ADestCom := ADest as TmpComPort;
    ADestCom.FPort := FPort;
    ADestCom.FBaudrate := FBaudrate;
    ADestCom.FParity := FParity;
    ADestCom.FStopBits := FStopBits;
    ADestCom.FByteSize := FByteSize;
    ADestCom.FTxBufferSize := FTxBufferSize;
    ADestCom.FRxBufferSize := FRxBufferSize;
    ADestCom.FReadTimeout := FReadTimeout;
  end;

end;

//------------------------------------------------------------------------------
procedure TmpComPort.SetPort(AValue: Integer);
begin
  if AValue <> FPort then
  begin
    if not Opened then
    begin
      if (AValue >= 1) and (AValue <= 256) then
        FPort := AValue
      else
        raise Exception.Create('TComPort.SetPort error. Port number out of range!');
    end else
      raise Exception.Create('TComPort.SetPort error. Can not change port when open!');
  end;
end;

//------------------------------------------------------------------------------
function TmpComPort.GetPortName: string;
begin
  Result := 'COM'+IntToStr(Port);
end;

//------------------------------------------------------------------------------
function TmpComPort.GetRxCount: Cardinal;
var
  AErrors: Cardinal;
  AComStat: TComStat;
begin
  ClearCommError(PortHandle, AErrors, @AComStat);
  Result := AComStat.cbInQue;
end;

//------------------------------------------------------------------------------
procedure TmpComPort.SetBaudrate(AValue: Integer);
var
  ADCB: TDCB;
begin
  if AValue <> FBaudrate then
  begin
    if (AValue=110) or (AValue=300) or (AValue=600) or (AValue=1200) or
      (AValue=2400) or (AValue=4800) or (AValue=9600) or (AValue=14400) or
      (AValue=19200) or (AValue=38400) or (AValue=56000) or (AValue=57600) or
      (AValue=115200) or (AValue=128000) or (AValue=256000) then
    begin
      FBaudrate := AValue;
      if Opened then
      begin
        GetCommState(PortHandle, ADCB);
        SetDCBBaudrate(ADCB, FBaudrate);
        SetCommState(PortHandle, ADCB);
      end;
    end else
      raise Exception.Create('TComPort.SetBaudrate error. Not alowed value: '+IntToStr(AValue)+'!');
  end;
end;

//------------------------------------------------------------------------------
procedure TmpComPort.SetParity(AValue: TComParity);
var
  ADCB: TDCB;
begin
  if AValue <> Parity then
  begin
    FParity := AValue;
    if Opened then
    begin
      GetCommState(PortHandle, ADCB);
      SetDCBParity(ADCB, Parity);
      SetCommState(PortHandle, ADCB);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TmpComPort.SetStopBits(AValue: TComStopBits);
var
  ADCB: TDCB;
begin
  if AValue <> StopBits then
  begin
    FStopBits := AValue;
    if Opened then
    begin
      GetCommState(PortHandle, ADCB);
      SetDCBStopBits(ADCB, StopBits);
      SetCommState(PortHandle, ADCB);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TmpComPort.SetByteSize(AValue: Integer);
var
  ADCB: TDCB;
begin
  if AValue <> FByteSize then
  begin
    if (AValue=5) or (AValue=6) or (AValue=7) or (AValue=8) then
    begin
      FByteSize := AValue;
      if Opened then
      begin
        GetCommState(PortHandle, ADCB);
        SetDCBByteSize(ADCB, ByteSize);
        SetCommState(PortHandle, ADCB);
      end;
    end else
      raise Exception.Create('TComPort.SetByteSize error. ByteSize: '+IntToStr(AValue)+' not allowed!');
  end;
end;

//------------------------------------------------------------------------------
procedure TmpComPort.Open;
var
  ADCB: TDCB;

begin
  if not Opened then
  begin
    PortHandle := CreateFile(PWideChar(PortName), GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, 0, 0);

    if PortHandle <> INVALID_HANDLE_VALUE then
    begin
      {wielkoœæ buforów In i Out}
      SetupComm(PortHandle, FRxBufferSize, FTxBufferSize);

      ADCB.DCBlength := SizeOf(ADCB);
      GetCommState(PortHandle, ADCB);
      SetDCBBaudrate(ADCB, Baudrate);
      SetDCBParity(ADCB, Parity);
      SetDCBStopBits(ADCB, StopBits);
      SetDCBByteSize(ADCB, ByteSize);
      SetCommState(PortHandle, ADCB);

      GetCommMask(PortHandle, EventMask);
      SetCommMask(PortHandle, EV_TXEMPTY);

      FOpened := true;

    end else begin
      FOpened := false;
      raise Exception.Create('TComPort.OpenPort error. Can not open port: '+PortName+'!');
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TmpComPort.Close;
begin
  if Opened then
  begin
    CloseHandle(PortHandle);
    FOpened := false;
  end;
end;

//------------------------------------------------------------------------------
procedure TmpComPort.Write(AData: Pointer; ASize: Cardinal);
var
  ABytesWritten: Cardinal;

begin
  if Opened then
  begin
    if ASize <= FTxBufferSize then
    begin
      WriteFile(PortHandle, AData^, ASize, ABytesWritten, nil);
      WaitCommEvent(PortHandle, EventMask, nil);
      FlushFileBuffers(PortHandle);
    end else
      raise Exception.Create('TComPort.Send error. Data is larger then TxBuffer');
  end else
    raise Exception.Create('TComPort.Send error. Port not opened!');

end;

//------------------------------------------------------------------------------
procedure TmpComPort.Write(AByte: Byte);
begin
  Write(@AByte, 1);
end;

//------------------------------------------------------------------------------
procedure TmpComPort.Write(AWord: Word);
begin
  Write(@AWord, 2);
end;

//------------------------------------------------------------------------------
procedure TmpComPort.Write(AData: TBytes);
begin
  Write(AData, Length(AData));
end;

//------------------------------------------------------------------------------
procedure TmpComPort.Read(AData: Pointer; ASize: Cardinal);
var
  AErrors: Cardinal;
  AComStat: TComStat;
  ALoopCount: Cardinal;
  ABytesRead: Cardinal;

begin
  {receive data}
  ALoopCount := FReadTimeout;
  repeat

    ClearCommError(PortHandle, AErrors, @AComStat);

    if FReadTimeout > 0 then
    begin
      if ALoopCount = 0 then
        raise Exception.Create('TComPort.Read error. Read timeout!')
      else
        ALoopCount := ALoopCount - 1;
    end;

    Sleep(1);

  until AComStat.cbInQue >= ASize;

  ReadFile(PortHandle, AData^, ASize, ABytesRead, nil);

end;

//------------------------------------------------------------------------------
function TmpComPort.ReadByte: Byte;
begin
  Read(@Result, 1);
end;

//------------------------------------------------------------------------------
function TmpComPort.ReadWord: Word;
begin
  Read(@Result, 2);
end;



//

//  SetLength(ARxData, AComStat.cbInQue);
//  for i:=0 to AComStat.cbInQue-1 do ARxData[i] := RxData[i];
//
//  ShowMessage('RX: ' + BytesToHex(ARxData, ' '));




//procedure TComPort.Read(AByteCount: Integer);
//begin
//  TimeoutError := false;
//  BytesToRead := ACount;
//  if ReadBuffer.Size < BytesToRead then
//    ReadTimer.Enabled := true
//  else
//    ReadTimer.Enabled := false;
//end;


//function TComPort.ReadByte: Byte;
//begin
//  Timeout := false;
//  BytesToRead := 1;
//
//
//
//  while Timer.Enabled do
//    Application.ProcessMessages;
//
//  {dane ju¿ s¹ albo timeout...}
//  if TimeoutError then
//  begin
//    TimeoutError := false;
//    raise Exception.Create('Read timeout.');
//  end;
//
//  ReadTimer.Enabled := false;
//  Result := ReadBuffer.First;
//  ReadBuffer.Position := 0;
//  ReadBuffer.Cut(1);
//end;

//==============================================================================
//==============================================================================
//==============================================================================
procedure SetAllComPortList(AStrings: TStrings);
var
  i: Integer;
begin
  AStrings.BeginUpdate;
  try
    AStrings.Clear;
    for i:=1 to 256 do AStrings.Add('COM' + IntToStr(i));
  finally
    AStrings.EndUpdate;
  end;
end;

//------------------------------------------------------------------------------
procedure SetDCBBaudrate(var ADCB: TDCB; ABaudrate: Integer);
begin
  case ABaudrate of
    110   : ADCB.BaudRate := CBR_110;
    300   : ADCB.BaudRate := CBR_300;
    600   : ADCB.BaudRate := CBR_600;
    1200  : ADCB.BaudRate := CBR_1200;
    2400  : ADCB.BaudRate := CBR_2400;
    4800  : ADCB.BaudRate := CBR_4800;
    9600  : ADCB.BaudRate := CBR_9600;
    14400 : ADCB.BaudRate := CBR_14400;
    19200 : ADCB.BaudRate := CBR_19200;
    38400 : ADCB.BaudRate := CBR_38400;
    56000 : ADCB.BaudRate := CBR_56000;
    57600 : ADCB.BaudRate := CBR_57600;
    115200: ADCB.BaudRate := CBR_115200;
    128000: ADCB.BaudRate := CBR_128000;
    256000: ADCB.BaudRate := CBR_256000;
  else
    raise Exception.Create('SetDCBBaudrate error. Not allowed Baudrate: '+IntToStr(ABaudrate)+'!');
  end;
end;

//------------------------------------------------------------------------------
procedure SetDCBParity(var ADCB: TDCB; AParity: TComParity);
begin
  case AParity of
    cpEven: ADCB.Parity := EVENPARITY;
    cpMark: ADCB.Parity := MARKPARITY;
    cpNone: ADCB.Parity := NOPARITY;
    cpOdd:  ADCB.Parity := ODDPARITY;
  end;
end;

//------------------------------------------------------------------------------
procedure SetDCBStopBits(var ADCB: TDCB; AStopBits: TComStopBits);
begin
  case AStopBits of
    csbOne  : ADCB.StopBits := ONESTOPBIT;
    csbOne5 : ADCB.StopBits := ONE5STOPBITS;
    csbTwo  : ADCB.StopBits := TWOSTOPBITS;
  end;
end;

//------------------------------------------------------------------------------
procedure SetDCBByteSize(var ADCB: TDCB; AByteSize: Integer);
begin
  if (AByteSize=5) or (AByteSize=6) or (AByteSize=7) or (AByteSize=8) then
    ADCB.ByteSize := AByteSize
  else
    raise Exception.Create('SetDCBByteSize error. ByteSize: '+IntToStr(AByteSize)+' not allowed!');
end;

//------------------------------------------------------------------------------
function ToStr(AParity: TComParity): string;
begin
  case AParity of
    cpEven: Result := 'Even';
    cpMark: Result := 'Mark';
    cpNone: Result := 'None';
    cpOdd:  Result := 'Odd';
  end;
end;

//------------------------------------------------------------------------------
function ToStr(AStopBits: TComStopBits): string;
begin
  case AStopBits of
    csbOne:   Result := '1';
    csbOne5:  Result := '1.5';
    csbTwo:   Result := '2';
  end;
end;

//==============================================================================
procedure Register;
begin
  RegisterComponents('mpBase', [TmpComPort]);
end;

end.
