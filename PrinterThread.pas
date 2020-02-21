unit PrinterThread;
interface uses System.Classes;

type

  { TPrinterThread }

  TPrinterThread = class(TThread)
  private
    WaitForAck: Boolean;

    procedure CheckDataToSend;
    procedure CheckAck;
    procedure DoOnAck;
    function GetPrinterIdleTime: Integer;

  protected
    procedure Execute(); override;

  public
    DataToSend: string;
    OnAck: TNotifyEvent;

    property PrinterIdleTime: Integer read GetPrinterIdleTime;

  end;

//==============================================================================
implementation uses Forms, c_Printer, SysUtils;

{ TPrinterThread }

procedure TPrinterThread.CheckAck;
begin
  if Printer.AckReceived then
  begin
    WaitForAck := false;
    DoOnAck;
  end;
end;


procedure TPrinterThread.CheckDataToSend;
begin
  if DataToSend = '' then Exit;

  Printer.SendNow(DataToSend);
  DataToSend := '';
  WaitForAck := true;
end;

//------------------------------------------------------------------------------
procedure TPrinterThread.DoOnAck;
begin
  if Assigned(OnAck) then
    Synchronize(procedure begin OnAck(Self) end);
end;

//------------------------------------------------------------------------------
procedure TPrinterThread.Execute();
begin
  FreeOnTerminate := true;

  try
    Printer.Connect;

    WaitForAck := false;

    while not (Terminated or Application.Terminated) do
    begin

      if WaitForAck then
        CheckAck
      else
        CheckDataToSend;

      Sleep(PrinterIdleTime);

    end;

  finally
    Printer.Disconnect;

  end;

end;

function TPrinterThread.GetPrinterIdleTime: Integer;
begin
  Result := Printer.IdleTime;
end;


end.

