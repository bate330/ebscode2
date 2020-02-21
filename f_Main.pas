unit f_Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.Actions,
  Vcl.ActnList, Vcl.ComCtrls, System.ImageList, Vcl.ImgList;

type
  TMainForm = class(TForm)
    ProgressBar: TProgressBar;
    OpenDialog: TOpenDialog;
    OpenDialogButton: TButton;
    OpenDialogTextBox: TEdit;
    StartButton: TButton;
    TextToTransferMemo: TMemo;
    Actions: TActionList;
    ClearButton: TButton;
    ProgressBarLabel: TLabel;
    StartAction: TAction;
    StopAction: TAction;
    ConfigButton: TButton;
    ShowConfigAction: TAction;
    Images16: TImageList;
    AboutButton: TButton;
    procedure ClearButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OpenDialogButtonClick(Sender: TObject);
    procedure StartActionExecute(Sender: TObject);
    procedure StopActionExecute(Sender: TObject);
    procedure ShowConfigActionExecute(Sender: TObject);
    procedure AboutButtonClick(Sender: TObject);

  private
    Row: Integer;
    Input: TStrings;
    Output: TStrings;
    procedure UpdateCtrls;
    function IsRunning: Boolean;

    property Running: Boolean read IsRunning;

  public
    OutputFileName : string;

    procedure PrinterStopped(ASender: TObject);
    procedure PrinterAckReceived(ASender: TObject);

  end;

//==============================================================================
var
  MainForm: TMainForm;



implementation uses f_Config, c_Config, c_Printer, f_About;

{$R *.dfm}

procedure TMainForm.OpenDialogButtonClick(Sender: TObject);
begin
    if (OpenDialog.Execute)  then
     begin
       Input.LoadFromFile(OpenDialog.FileName);
       Row := 0;
       StartButton.Visible :=true;
       StartButton.Caption := 'Start';
       ProgressBar.Visible :=true;
       ClearButton.Visible :=true;
       if Input.Count = Output.Count then (inttostr(Output.Count));
       OpenDialogTextBox.Text := OpenDialog.FileName;
       OutputFileName := ExtractFilePath  (OpenDialog.FileName) + ExtractFileName  (ChangeFileExt   (OpenDialog.FileName,'')) + '-printed' + ExtractFileExt   (OpenDialog.FileName);
       if FileExists(OutputFileName) then Output.LoadFromFile(OutputFileName) ;
       if (Output.Count <> 0) and (Output.Count = Input.Count) then begin ShowMessage('All codes printed!');
       Input.Clear;
       Output.Clear;
       OpenDialogTextBox.Clear; StartButton.Visible :=false; end;
    end;

end;


procedure TMainForm.PrinterStopped(ASender: TObject);
begin
  UpdateCtrls;
end;


procedure TMainForm.ShowConfigActionExecute(Sender: TObject);
begin
  ConfigForm.LoadConfig;
  if ConfigForm.Execute then
  begin
    ConfigForm.ApplyConfig;
    Config.SaveToFile;
  end;
end;


procedure TMainForm.StartActionExecute(Sender: TObject);
begin
  Printer.Start;
  Printer.Send(Input[Output.Count]);
  UpdateCtrls;
end;


procedure TMainForm.StopActionExecute(Sender: TObject);
begin
  Printer.Stop;
end;


procedure TMainForm.UpdateCtrls;
begin
  if Running then begin
     StartButton.Action := StopAction;
     StartButton.ImageIndex := 5;
     StartButton.Caption := 'Stop'
  end else begin
     StartButton.Action := StartAction;
     StartButton.ImageIndex := 3;
     StartButton.Caption := 'Start'
  end;

  
end;


procedure TMainForm.FormCreate(Sender: TObject);
begin
     Input := TStringList.Create;
     Output := TStringList.Create;
end;


procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(Input);
  Output.Free;
end;


function TMainForm.IsRunning: Boolean;
begin
  Result := Printer.Running;
end;

//------------------------------------------------------------------------------
procedure TMainForm.PrinterAckReceived(ASender: TObject);
var
    OutputFile : TextFile;
    TextToSaveToOutputFile: TStringlist;
    count: integer;
begin
  OutputFileName := ExtractFilePath  (OpenDialog.FileName) + ExtractFileName  (ChangeFileExt   (OpenDialog.FileName,'')) + '-printed' + ExtractFileExt   (OpenDialog.FileName);
  ProgressBar.min := 0;
  ProgressBar.max := Input.Count;
  ProgressBarLabel.Visible := true;
  if FileExists(OutputFileName) then Output.LoadFromFile(OutputFileName);

  if Input.Count > Output.Count then
  begin

    if Row < (Input.Count-1) then Row := Row + 1;
    TextToSaveToOutputFile:= TStringlist.create;
    if not FileExists(OutputFileName) then TextToSaveToOutputFile.SaveToFile(OutputFileName);
    AssignFile(OutputFile, OutputFileName);
    Append(OutputFile);
    Writeln(OutputFile, Input[Output.Count]);
    CloseFile(OutputFile);
    TextToTransferMemo.Lines.LoadFromFile(OutputFileName);
    count := TextToTransferMemo.Lines.Count;
    ProgressBar.Position := count;
    ProgressBarLabel.Caption := IntToStr(count) + ' / ' + IntToStr(Input.Count);

    Printer.Send(Input[Output.Count]);

  end else begin

    Printer.Stop;
    ShowMessage('All codes printed!');

  end;

end;

//------------------------------------------------------------------------------
procedure TMainForm.AboutButtonClick(Sender: TObject);
begin
  AboutForm.ShowModal;
end;


procedure TMainForm.ClearButtonClick(Sender: TObject);
begin
  Input.Clear;
  Output.Clear;
  ProgressBar.Position := Output.Count;
  StartButton.Action := StartAction;
  StartButton.Visible :=false;
  ProgressBar.Visible :=false;
  ClearButton.Visible :=false;
  ProgressBarLabel.Visible :=false;
  OpenDialogTextBox.Clear;
end;
end.
