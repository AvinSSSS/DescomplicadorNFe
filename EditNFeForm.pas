unit EditNFeForm;

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  NFeReader;

type
  /// <summary>Formulário modal utilizado para editar um registro de NFe.</summary>
  TEditNFeWindow = class(TForm)
    pnlHeader: TPanel;
    lblTitle: TLabel;
    lblSubtitle: TLabel;
    pnlContent: TPanel;
    lblSupplier: TLabel;
    edtSupplier: TEdit;
    lblCnpj: TLabel;
    edtCnpj: TEdit;
    lblDate: TLabel;
    edtDate: TEdit;
    lblNumber: TLabel;
    edtNumber: TEdit;
    lblTotal: TLabel;
    edtTotal: TEdit;
    lblError: TLabel;
    edtError: TEdit;
    pnlButtons: TPanel;
    btnCancel: TButton;
    btnSave: TButton;

    /// <summary>Valida os campos antes de confirmar a edição.</summary>
    procedure btnSaveClick(Sender: TObject);
  private
    /// <summary>Preenche os controles com os dados atuais.</summary>
    procedure LoadData(const Data: TNFeData);

    /// <summary>Transfere os valores editados para o registro.</summary>
    procedure SaveData(var Data: TNFeData);
  public
    /// <summary>Exibe o editor e atualiza o registro quando confirmado.</summary>
    class function Execute(AOwner: TComponent; var Data: TNFeData): Boolean;
  end;

implementation

uses
  Vcl.Dialogs;

{$R *.dfm}

class function TEditNFeWindow.Execute(AOwner: TComponent;
  var Data: TNFeData): Boolean;
var
  Window: TEditNFeWindow;
begin
  Window := TEditNFeWindow.Create(AOwner);
  try
    Window.LoadData(Data);
    Result := Window.ShowModal = mrOk;
    if Result then
      Window.SaveData(Data);
  finally
    Window.Free;
  end;
end;

procedure TEditNFeWindow.LoadData(const Data: TNFeData);
begin
  edtSupplier.Text := Data.Supplier;
  edtCnpj.Text := Data.CNPJ;
  edtDate.Text := Data.DateText;
  edtNumber.Text := Data.NumberText;
  edtTotal.Text := CurrToStr(Data.Total);
  edtError.Text := Data.ErrorText;
end;

procedure TEditNFeWindow.btnSaveClick(Sender: TObject);
var
  TotalValue: Currency;
begin
  if Trim(edtSupplier.Text) = '' then
  begin
    MessageDlg('Informe o fornecedor.', mtWarning, [mbOK], 0);
    edtSupplier.SetFocus;
    Exit;
  end;

  if not TryStrToCurr(edtTotal.Text, TotalValue) then
  begin
    MessageDlg('Informe um valor total válido.', mtWarning, [mbOK], 0);
    edtTotal.SetFocus;
    Exit;
  end;

  ModalResult := mrOk;
end;

procedure TEditNFeWindow.SaveData(var Data: TNFeData);
begin
  Data.Supplier := Trim(edtSupplier.Text);
  Data.CNPJ := Trim(edtCnpj.Text);
  Data.DateText := Trim(edtDate.Text);
  Data.NumberText := Trim(edtNumber.Text);
  TryStrToCurr(edtTotal.Text, Data.Total);
  Data.ErrorText := Trim(edtError.Text);
  Data.Valid := (Data.Supplier <> '') and (Data.NumberText <> '');
  UpdateNFeXml(Data);
end;

end.
