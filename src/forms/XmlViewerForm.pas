unit XmlViewerForm;

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ExtCtrls;

type
  /// <summary>Janela interna e somente leitura para visualização do XML.</summary>
  TXmlViewerWindow = class(TForm)
    pnlHeader: TPanel;
    lblTitle: TLabel;
    lblFileName: TLabel;
    memXml: TMemo;
    pnlButtons: TPanel;
    btnCopy: TButton;
    btnClose: TButton;

    /// <summary>Copia todo o XML exibido para a área de transferência.</summary>
    procedure btnCopyClick(Sender: TObject);
  public
    /// <summary>Abre o XML informado em uma janela modal.</summary>
    class procedure Execute(AOwner: TComponent; const FileName,
      XmlContent: string);
  end;

implementation

uses
  Vcl.Clipbrd,
  Xml.XMLDoc;

{$R *.dfm}

class procedure TXmlViewerWindow.Execute(AOwner: TComponent;
  const FileName, XmlContent: string);
var
  Window: TXmlViewerWindow;
begin
  Window := TXmlViewerWindow.Create(AOwner);
  try
    Window.lblFileName.Caption := FileName;
    try
      Window.memXml.Text := FormatXMLData(XmlContent);
    except
      on E: Exception do
        Window.memXml.Text := XmlContent;
    end;
    Window.memXml.SelStart := 0;
    Window.ShowModal;
  finally
    Window.Free;
  end;
end;

procedure TXmlViewerWindow.btnCopyClick(Sender: TObject);
begin
  Clipboard.AsText := memXml.Text;
  btnCopy.Caption := 'XML copiado';
end;

end.
