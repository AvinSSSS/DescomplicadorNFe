unit NFeReader;

interface

uses
  System.SysUtils,
  System.IOUtils,
  System.StrUtils,
  System.RegularExpressions,
  Xml.XMLIntf,
  Xml.XMLDoc;

type
  /// <summary>Dados principais extraídos de uma Nota Fiscal Eletrônica.</summary>
  TNFeData = record
    /// <summary>Caminho do arquivo XML de origem.</summary>
    FileName: string;
    /// <summary>Conteúdo XML original do documento.</summary>
    XmlContent: string;
    /// <summary>Razão social ou nome do fornecedor.</summary>
    Supplier: string;
    /// <summary>CNPJ do emitente.</summary>
    CNPJ: string;
    /// <summary>Data de emissão conforme registrada no XML.</summary>
    DateText: string;
    /// <summary>Número da nota fiscal.</summary>
    NumberText: string;
    /// <summary>Valor total da nota fiscal.</summary>
    Total: Currency;
    /// <summary>Indica se os campos essenciais foram encontrados.</summary>
    Valid: Boolean;
    /// <summary>Descrição do erro de leitura ou validação, quando houver.</summary>
    ErrorText: string;
  end;

/// <summary>Lê um XML de NFe e extrai seus dados principais.</summary>
/// <param name="FileName">Caminho do arquivo XML que será processado.</param>
/// <returns>Dados extraídos e o resultado da validação.</returns>
function ReadNFe(const FileName: string): TNFeData;

/// <summary>Sincroniza no XML os campos editáveis do registro.</summary>
/// <param name="Data">Registro e XML que serão atualizados em memória.</param>
/// <returns>Verdadeiro quando o XML foi atualizado corretamente.</returns>
function UpdateNFeXml(var Data: TNFeData): Boolean;

/// <summary>Serializa os dados de uma NFe como uma linha de CSV.</summary>
/// <param name="Data">Dados que serão serializados.</param>
/// <returns>Linha com campos separados por ponto e vírgula.</returns>
function CsvLine(const Data: TNFeData): string;

implementation

const
  MaxXmlFileSize = 10 * 1024 * 1024;

/// <summary>Localiza recursivamente um nó pelo nome local, ignorando namespaces.</summary>
function FindByLocalName(const Node: IXMLNode; const Name: string): IXMLNode;
var
  Index: Integer;
begin
  Result := nil;
  if Node = nil then
    Exit;

  if SameText(Node.LocalName, Name) then
    Exit(Node);

  for Index := 0 to Node.ChildNodes.Count - 1 do
  begin
    Result := FindByLocalName(Node.ChildNodes[Index], Name);
    if Result <> nil then
      Exit;
  end;
end;

/// <summary>Obtém o texto do primeiro nó que possui o nome local informado.</summary>
function TextOf(const Root: IXMLNode; const Name: string): string;
var
  Node: IXMLNode;
begin
  Node := FindByLocalName(Root, Name);
  if Node <> nil then
    Result := Node.Text
  else
    Result := '';
end;

function ReadNFe(const FileName: string): TNFeData;
var
  Document: IXMLDocument;
  Root: IXMLNode;
  Issuer: IXMLNode;
  TotalNode: IXMLNode;
  TotalText: string;
  FormatSettings: TFormatSettings;
begin
  Result := Default(TNFeData);
  Result.FileName := FileName;

  FormatSettings := TFormatSettings.Create('pt-BR');
  FormatSettings.DecimalSeparator := '.';

  try
    if TFile.GetSize(FileName) > MaxXmlFileSize then
      raise Exception.Create('O XML excede o limite de 10 MB.');

    Result.XmlContent := TFile.ReadAllText(FileName, TEncoding.UTF8);
    if ContainsText(Result.XmlContent, '<!DOCTYPE') or
      ContainsText(Result.XmlContent, '<!ENTITY') then
      raise Exception.Create('DTD e entidades externas não são permitidas.');

    Document := NewXMLDocument;
    Document.ParseOptions := [];
    Document.LoadFromXML(Result.XmlContent);
    Root := Document.DocumentElement;
    Issuer := FindByLocalName(Root, 'emit');
    TotalNode := FindByLocalName(Root, 'ICMSTot');

    Result.Supplier := TextOf(Issuer, 'xNome');
    Result.CNPJ := TextOf(Issuer, 'CNPJ');
    Result.DateText := TextOf(Root, 'dhEmi');
    if Result.DateText = '' then
      Result.DateText := TextOf(Root, 'dEmi');

    Result.NumberText := TextOf(Root, 'nNF');
    TotalText := TextOf(TotalNode, 'vNF');
    if not TryStrToCurr(TotalText, Result.Total, FormatSettings) then
      Result.Total := 0;

    Result.Valid := (Result.NumberText <> '') and (Result.Supplier <> '');
    if not Result.Valid then
      Result.ErrorText := 'Campos essenciais ausentes';
  except
    on E: Exception do
    begin
      Result.Valid := False;
      Result.ErrorText := E.Message;
    end;
  end;
end;

function UpdateNFeXml(var Data: TNFeData): Boolean;
var
  Document: IXMLDocument;
  Root: IXMLNode;
  Issuer: IXMLNode;
  Node: IXMLNode;
  TotalNode: IXMLNode;
  FormatSettings: TFormatSettings;
begin
  Result := False;
  try
    Document := NewXMLDocument;
    Document.ParseOptions := [];
    Document.LoadFromXML(Data.XmlContent);
    Root := Document.DocumentElement;
    Issuer := FindByLocalName(Root, 'emit');
    TotalNode := FindByLocalName(Root, 'ICMSTot');

    Node := FindByLocalName(Issuer, 'xNome');
    if Node <> nil then
      Node.Text := Data.Supplier;
    Node := FindByLocalName(Issuer, 'CNPJ');
    if Node <> nil then
      Node.Text := Data.CNPJ;
    Node := FindByLocalName(Root, 'dhEmi');
    if Node = nil then
      Node := FindByLocalName(Root, 'dEmi');
    if Node <> nil then
      Node.Text := Data.DateText;
    Node := FindByLocalName(Root, 'nNF');
    if Node <> nil then
      Node.Text := Data.NumberText;
    Node := FindByLocalName(TotalNode, 'vNF');
    if Node <> nil then
    begin
      FormatSettings := TFormatSettings.Invariant;
      Node.Text := CurrToStr(Data.Total, FormatSettings);
    end;

    Data.XmlContent := Document.XML.Text;
    Result := True;
  except
    on E: Exception do
      Data.ErrorText := 'Não foi possível atualizar o XML: ' + E.Message;
  end;
end;

/// <summary>Protege um texto para uso em um campo CSV delimitado por aspas.</summary>
function QuoteCsv(const Value: string): string;
var
  SafeValue: string;
begin
  SafeValue := Value;
  if (SafeValue <> '') and CharInSet(SafeValue[1], ['=', '+', '-', '@']) then
    SafeValue := '''' + SafeValue;
  Result := '"' + StringReplace(SafeValue, '"', '""', [rfReplaceAll]) + '"';
end;

/// <summary>Remove a indentação entre tags sem alterar valores textuais.</summary>
function CompactXml(const XmlContent: string): string;
begin
  Result := TRegEx.Replace(Trim(XmlContent), '>\s+<', '><');
end;

function CsvLine(const Data: TNFeData): string;
begin
  Result :=
    QuoteCsv(ExtractFileName(Data.FileName)) + ';' +
    QuoteCsv(Data.Supplier) + ';' +
    QuoteCsv(Data.CNPJ) + ';' +
    QuoteCsv(Data.DateText) + ';' +
    QuoteCsv(Data.NumberText) + ';' +
    CurrToStr(Data.Total) + ';' +
    QuoteCsv(Data.ErrorText) + ';' +
    QuoteCsv(CompactXml(Data.XmlContent));
end;

end.
