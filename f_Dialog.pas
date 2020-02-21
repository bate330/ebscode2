unit f_Dialog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TDialogForm = class(TForm)
    CancelButton: TButton;
    OkButton: TButton;
    procedure OkButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
  private
    FExecuted: Boolean;
  public
    function Execute: Boolean;
  end;

var
  DialogForm: TDialogForm;

implementation

{$R *.dfm}

{ TDialogForm }

procedure TDialogForm.CancelButtonClick(Sender: TObject);
begin
  Close;
end;

function TDialogForm.Execute: Boolean;
begin
  Position := poMainFormCenter;
  FExecuted := false;
  ShowModal;
  Result := FExecuted;
end;

procedure TDialogForm.OkButtonClick(Sender: TObject);
begin
  FExecuted := true;
  Close;
end;

end.
