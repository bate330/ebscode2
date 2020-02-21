program EbsCode2;

uses
  Vcl.Forms,
  SysUtils,
  f_Main in 'f_Main.pas' {MainForm},
  PrinterThread in 'PrinterThread.pas',
  c_Printer in 'c_Printer.pas',
  f_Dialog in 'f_Dialog.pas' {DialogForm},
  f_Config in 'f_Config.pas' {ConfigForm},
  c_Config in 'c_Config.pas',
  mpcomport in 'mpcomport.pas',
  f_About in 'f_About.pas' {AboutForm},
  AppInfo in 'AppInfo.pas',
  AppVersion in 'AppVersion.pas';

{$R *.res}

procedure WaitForStop;
begin
  while Printer.Running do
  begin
    Sleep(1);
    Application.ProcessMessages;
  end;
end;


begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TDialogForm, DialogForm);
  Application.CreateForm(TConfigForm, ConfigForm);
  Application.CreateForm(TAboutForm, AboutForm);
  Printer := TPrinter.Create;
  Printer.OnStop := MainForm.PrinterStopped;
  Printer.OnAck := MainForm.PrinterAckReceived;

  Config := TConfig.Create;
  Config.LoadFromFile;

  Application.Run;

  Printer.Stop;
  WaitForStop;

  FreeAndNil(Config);
  FreeAndNil(Printer);

end.
