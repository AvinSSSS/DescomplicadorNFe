object XmlViewerWindow: TXmlViewerWindow
  Left = 0
  Top = 0
  Caption = 'Visualizar XML'
  ClientHeight = 640
  ClientWidth = 900
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
    Width = 900
    Height = 78
    Align = alTop
    BevelOuter = bvNone
    Color = 10840623
    ParentBackground = False
    TabOrder = 0
    object lblTitle: TLabel
      Left = 24
      Top = 14
      Width = 121
      Height = 25
      Caption = 'Conteúdo XML'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -19
      Font.Name = 'Segoe UI Semibold'
      Font.Style = []
      ParentFont = False
    end
    object lblFileName: TLabel
      Left = 25
      Top = 45
      Width = 121
      Height = 17
      Caption = 'documento.xml'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 15787760
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object memXml: TMemo
    Left = 20
    Top = 98
    Width = 860
    Height = 474
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = 16448250
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 3485227
    Font.Height = -13
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 1
    WantReturns = False
    WordWrap = False
  end
  object pnlButtons: TPanel
    Left = 0
    Top = 586
    Width = 900
    Height = 54
    Align = alBottom
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 2
    object btnCopy: TButton
      Left = 638
      Top = 10
      Width = 132
      Height = 34
      Caption = 'Copiar XML'
      TabOrder = 0
      OnClick = btnCopyClick
    end
    object btnClose: TButton
      Left = 780
      Top = 10
      Width = 100
      Height = 34
      Cancel = True
      Caption = 'Fechar'
      ModalResult = 2
      TabOrder = 1
    end
  end
end
