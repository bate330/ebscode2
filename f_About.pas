unit f_About;
interface

//==============================================================================
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Imaging.pngimage, Vcl.ExtCtrls;

//==============================================================================
type
  TAboutForm = class(TForm)
    Image: TImage;
    AppNameLabel: TLabel;
    AppVerLabel: TLabel;
    OkButton: TButton;
    Memo: TMemo;
    LinkLabel: TLabel;
    procedure OkButtonClick(Sender: TObject);
    procedure LinkLabelClick(Sender: TObject);
    procedure LinkLabelMouseEnter(Sender: TObject);
    procedure LinkLabelMouseLeave(Sender: TObject);
  private
    procedure LoadAppInfo;
  public
    function ShowModal: Integer; override;
    procedure Show;
  end;

//==============================================================================
var
  AboutForm: TAboutForm;

//==============================================================================
implementation uses ShellApi, AppInfo;

{$R *.dfm}

//==============================================================================
{ TAboutForm }

//------------------------------------------------------------------------------
procedure TAboutForm.LinkLabelClick(Sender: TObject);
begin
  ShellExecute(0, 'Open', PChar('https://ebs-inkjet.pl/'), '', nil, SW_SHOWNORMAL);
end;
//------------------------------------------------------------------------------
procedure TAboutForm.LinkLabelMouseEnter(Sender: TObject);
begin
  LinkLabel.Caption := 'Kliknij tutaj!';
end;

//------------------------------------------------------------------------------
procedure TAboutForm.LinkLabelMouseLeave(Sender: TObject);
begin
  LinkLabel.Caption := 'Zapraszamy do nas';
end;

//------------------------------------------------------------------------------
procedure TAboutForm.LoadAppInfo;
begin
  AppNameLabel.Caption := TAppInfo.Name;
  AppVerLabel.Caption := 'ver: ' + TAppInfo.Version.AsString;
end;

//------------------------------------------------------------------------------
procedure TAboutForm.OkButtonClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------
procedure TAboutForm.Show;
begin
  LoadAppInfo;
  Position := poMainFormCenter;
  inherited Show;
end;

function TAboutForm.ShowModal: Integer;
begin
  LoadAppInfo;
  Position := poMainFormCenter;
  Result := inherited;
end;

end.
