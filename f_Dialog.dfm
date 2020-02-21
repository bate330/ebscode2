object DialogForm: TDialogForm
  Left = 0
  Top = 0
  BorderIcons = [biMinimize, biMaximize]
  BorderStyle = bsDialog
  Caption = '...'
  ClientHeight = 305
  ClientWidth = 504
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    504
    305)
  PixelsPerInch = 96
  TextHeight = 13
  object CancelButton: TButton
    Left = 421
    Top = 272
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Anuluj'
    TabOrder = 0
    OnClick = CancelButtonClick
    ExplicitLeft = 497
    ExplicitTop = 268
  end
  object OkButton: TButton
    Left = 340
    Top = 272
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    TabOrder = 1
    OnClick = OkButtonClick
    ExplicitLeft = 416
    ExplicitTop = 268
  end
end
