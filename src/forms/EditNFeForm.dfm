object EditNFeWindow: TEditNFeWindow
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Editar documento'
  ClientHeight = 510
  ClientWidth = 570
  Color = 16250354
  Font.Charset = DEFAULT_CHARSET
  Font.Color = 3485227
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  TextHeight = 17
  object pnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 570
    Height = 82
    Align = alTop
    BevelOuter = bvNone
    Color = 10840623
    ParentBackground = False
    TabOrder = 0
    object lblTitle: TLabel
      Left = 24
      Top = 16
      Width = 173
      Height = 25
      Caption = 'Editar documento'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -19
      Font.Name = 'Segoe UI Semibold'
      Font.Style = []
      ParentFont = False
    end
    object lblSubtitle: TLabel
      Left = 25
      Top = 47
      Width = 294
      Height = 17
      Caption = 'Revise os dados extraídos antes de salvar'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 15787760
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object pnlContent: TPanel
    Left = 0
    Top = 82
    Width = 570
    Height = 370
    Align = alClient
    BevelOuter = bvNone
    Color = 16250354
    ParentBackground = False
    TabOrder = 1
    object lblSupplier: TLabel
      Left = 24
      Top = 18
      Width = 73
      Height = 17
      Caption = 'Fornecedor'
    end
    object edtSupplier: TEdit
      Left = 24
      Top = 40
      Width = 522
      Height = 30
      AutoSize = False
      TabOrder = 0
    end
    object lblCnpj: TLabel
      Left = 24
      Top = 82
      Width = 31
      Height = 17
      Caption = 'CNPJ'
    end
    object edtCnpj: TEdit
      Left = 24
      Top = 104
      Width = 250
      Height = 30
      AutoSize = False
      TabOrder = 1
    end
    object lblDate: TLabel
      Left = 296
      Top = 82
      Width = 91
      Height = 17
      Caption = 'Data de emissão'
    end
    object edtDate: TEdit
      Left = 296
      Top = 104
      Width = 250
      Height = 30
      AutoSize = False
      TabOrder = 2
    end
    object lblNumber: TLabel
      Left = 24
      Top = 146
      Width = 47
      Height = 17
      Caption = 'Número'
    end
    object edtNumber: TEdit
      Left = 24
      Top = 168
      Width = 250
      Height = 30
      AutoSize = False
      TabOrder = 3
    end
    object lblTotal: TLabel
      Left = 296
      Top = 146
      Width = 57
      Height = 17
      Caption = 'Valor total'
    end
    object edtTotal: TEdit
      Left = 296
      Top = 168
      Width = 250
      Height = 30
      AutoSize = False
      TabOrder = 4
    end
    object lblError: TLabel
      Left = 24
      Top = 210
      Width = 114
      Height = 17
      Caption = 'Observação ou erro'
    end
    object edtError: TEdit
      Left = 24
      Top = 232
      Width = 522
      Height = 30
      AutoSize = False
      TabOrder = 5
    end
  end
  object pnlButtons: TPanel
    Left = 0
    Top = 452
    Width = 570
    Height = 58
    Align = alBottom
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 2
    object btnCancel: TButton
      Left = 332
      Top = 12
      Width = 100
      Height = 34
      Cancel = True
      Caption = 'Cancelar'
      ModalResult = 2
      TabOrder = 0
    end
    object btnSave: TButton
      Left = 446
      Top = 12
      Width = 100
      Height = 34
      Caption = 'Salvar'
      Default = True
      TabOrder = 1
      OnClick = btnSaveClick
    end
  end
end
