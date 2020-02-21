inherited ConfigForm: TConfigForm
  Caption = 'Konfiguracja...'
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 215
    Top = 110
    Width = 13
    Height = 13
    Caption = 'ms'
  end
  object PortComboBox: TComboBox
    Left = 64
    Top = 80
    Width = 145
    Height = 21
    Style = csDropDownList
    TabOrder = 2
    TextHint = 'Port..'
    OnChange = PortComboBoxChange
  end
  object BaudrateComboBox: TComboBox
    Left = 215
    Top = 80
    Width = 145
    Height = 21
    Style = csDropDownList
    TabOrder = 3
    TextHint = 'Baudrate..'
    Items.Strings = (
      '9600'
      '19200')
  end
  object AwaitComboBox: TComboBox
    Left = 64
    Top = 107
    Width = 145
    Height = 21
    Style = csDropDownList
    TabOrder = 4
    TextHint = 'Await..'
  end
end
