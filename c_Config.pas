unit c_Config;

interface

uses
System.inifiles, Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.Actions,
  Vcl.ActnList, Vcl.ComCtrls;
//==============================================================================
type
  TConfig = class
  private
    function GetPort: Byte;
    procedure SetPort(const AValue: Byte);
    function GetPrinterBaudrate: Integer;
    procedure SetPrinterBaudrate(const AValue: Integer);
    function GetPrinterIdleTime: Integer;
    procedure SetPrinterIdleTime(const AValue: Integer);

  public
    procedure SaveToFile;
    procedure LoadFromFile;
    property PrinterPort: Byte read GetPort write SetPort;
    property PrinterBaudrate: Integer read GetPrinterBaudrate write SetPrinterBaudrate;
    property PrinterIdleTime: Integer read GetPrinterIdleTime write SetPrinterIdleTime;

  end;

//==============================================================================
var
  Config: TConfig;
  IniFile : TIniFile;
  LoadPort : Integer;
  LoadBaud : Integer;

//==============================================================================
implementation uses c_Printer, PrinterThread, f_Config;

{ TConfig }

function TConfig.GetPrinterIdleTime: Integer;
begin
  Result := Printer.IdleTime;
end;

//------------------------------------------------------------------------------
function TConfig.GetPrinterBaudrate: Integer;
begin
  Result := Printer.BaudRate;
end;


procedure TConfig.LoadFromFile;
var
  AIni: TIniFile;

begin

  AIni := TIniFile.Create(ExtractFilePath(Application.ExeName)+'myapp.ini');
  try
    PrinterPort := AIni.ReadInteger('Config','Port',1);
    PrinterBaudrate := AIni.ReadInteger('Config','Baud',9600);
    PrinterIdleTime := AIni.ReadInteger('Config','Await',10);
  finally
    FreeAndNil(AIni);
  end;

end;

function TConfig.GetPort: Byte;
begin
  Result := Printer.Port;
end;


procedure TConfig.SetPrinterIdleTime(const AValue: Integer);
begin
  Printer.IdleTime := AValue;
end;


procedure TConfig.SetPrinterBaudrate(const AValue: Integer);
begin
  c_Printer.Printer.BaudRate := AValue;
end;

procedure TConfig.SaveToFile;
begin
  IniFile := TIniFile.Create(ExtractFilePath(Application.ExeName)+'myapp.ini') ;
 try
  IniFile.WriteInteger('Config', 'Baud', c_Printer.Printer.BaudRate );
  IniFile.WriteString('Config', 'Port', c_Printer.Printer.Port.ToString );
  IniFile.WriteInteger('Config', 'Await', PrinterIdleTime);
 finally
  IniFile.Free;
 end;
end;

procedure TConfig.SetPort(const AValue: Byte);
begin
  c_Printer.Printer.Port := AValue;
end;

end.
