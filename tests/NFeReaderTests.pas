unit NFeReaderTests;

interface

uses
  DUnitX.TestFramework,
  NFeReader;

type
  [TestFixture]
  TNFeReaderTests = class
  private
    function CreateXmlFile(const Xml: string): string;
  public
    [Test]
    procedure ReadsNamespacedNFe;

    [Test]
    procedure UsesLegacyEmissionDate;

    [Test]
    procedure ReportsMalformedXml;

    [Test]
    procedure ReportsMissingEssentialFields;

    [Test]
    procedure RejectsDocumentTypeDeclaration;

    [Test]
    procedure UpdatesEditedFieldsInXml;

    [Test]
    procedure ProtectsCsvAgainstFormulas;

    [Test]
    procedure ExportsXmlWithoutIndentation;
  end;

implementation

uses
  System.SysUtils,
  System.IOUtils,
  System.StrUtils;

function TNFeReaderTests.CreateXmlFile(const Xml: string): string;
begin
  Result := TPath.GetTempFileName;
  TFile.WriteAllText(Result, Xml, TEncoding.UTF8);
end;

procedure TNFeReaderTests.ReadsNamespacedNFe;
const
  Xml = '<NFe xmlns="http://www.portalfiscal.inf.br/nfe"><infNFe>' +
    '<ide><nNF>42</nNF><dhEmi>2026-08-22T10:00:00-03:00</dhEmi></ide>' +
    '<emit><CNPJ>11111111000101</CNPJ><xNome>Fornecedor Teste</xNome></emit>' +
    '<total><ICMSTot><vNF>125.90</vNF></ICMSTot></total>' +
    '</infNFe></NFe>';
var
  FileName: string;
  Data: TNFeData;
begin
  FileName := CreateXmlFile(Xml);
  try
    Data := ReadNFe(FileName);
    Assert.IsTrue(Data.Valid);
    Assert.AreEqual('Fornecedor Teste', Data.Supplier);
    Assert.AreEqual('11111111000101', Data.CNPJ);
    Assert.AreEqual('42', Data.NumberText);
    Assert.AreEqual(Currency(125.90), Data.Total);
  finally
    TFile.Delete(FileName);
  end;
end;

procedure TNFeReaderTests.UsesLegacyEmissionDate;
const
  Xml = '<NFe><ide><nNF>7</nNF><dEmi>2026-08-20</dEmi></ide>' +
    '<emit><CNPJ>1</CNPJ><xNome>Teste</xNome></emit>' +
    '<total><ICMSTot><vNF>1.00</vNF></ICMSTot></total></NFe>';
var
  FileName: string;
  Data: TNFeData;
begin
  FileName := CreateXmlFile(Xml);
  try
    Data := ReadNFe(FileName);
    Assert.AreEqual('2026-08-20', Data.DateText);
  finally
    TFile.Delete(FileName);
  end;
end;

procedure TNFeReaderTests.ReportsMalformedXml;
var
  FileName: string;
  Data: TNFeData;
begin
  FileName := CreateXmlFile('<NFe><infNFe>');
  try
    Data := ReadNFe(FileName);
    Assert.IsFalse(Data.Valid);
    Assert.IsNotEmpty(Data.ErrorText);
  finally
    TFile.Delete(FileName);
  end;
end;

procedure TNFeReaderTests.ReportsMissingEssentialFields;
var
  FileName: string;
  Data: TNFeData;
begin
  FileName := CreateXmlFile('<NFe><emit/><total><ICMSTot><vNF>0</vNF>' +
    '</ICMSTot></total></NFe>');
  try
    Data := ReadNFe(FileName);
    Assert.IsFalse(Data.Valid);
    Assert.AreEqual('Campos essenciais ausentes', Data.ErrorText);
  finally
    TFile.Delete(FileName);
  end;
end;

procedure TNFeReaderTests.RejectsDocumentTypeDeclaration;
var
  FileName: string;
  Data: TNFeData;
begin
  FileName := CreateXmlFile('<!DOCTYPE NFe [<!ENTITY xxe SYSTEM "file:///c:/windows/win.ini">]>' +
    '<NFe><emit><xNome>&xxe;</xNome></emit></NFe>');
  try
    Data := ReadNFe(FileName);
    Assert.IsFalse(Data.Valid);
    Assert.IsTrue(ContainsText(Data.ErrorText, 'não são permitidas'));
  finally
    TFile.Delete(FileName);
  end;
end;

procedure TNFeReaderTests.UpdatesEditedFieldsInXml;
const
  Xml = '<NFe><ide><nNF>1</nNF><dEmi>2026-01-01</dEmi></ide>' +
    '<emit><CNPJ>1</CNPJ><xNome>Original</xNome></emit>' +
    '<total><ICMSTot><vNF>1.00</vNF></ICMSTot></total></NFe>';
var
  FileName: string;
  Data: TNFeData;
begin
  FileName := CreateXmlFile(Xml);
  try
    Data := ReadNFe(FileName);
    Data.Supplier := 'Fornecedor Editado';
    Data.NumberText := '99';
    Data.Total := 25.50;
    Assert.IsTrue(UpdateNFeXml(Data));
    Assert.IsTrue(ContainsText(Data.XmlContent, 'Fornecedor Editado'));
    Assert.IsTrue(ContainsText(Data.XmlContent, '>99<'));
    Assert.IsTrue(ContainsText(Data.XmlContent, '>25.5<'));
  finally
    TFile.Delete(FileName);
  end;
end;

procedure TNFeReaderTests.ProtectsCsvAgainstFormulas;
var
  Data: TNFeData;
  Line: string;
begin
  Data := Default(TNFeData);
  Data.FileName := '=CMD.xml';
  Data.Supplier := '+Fornecedor';
  Line := CsvLine(Data);
  Assert.IsTrue(ContainsText(Line, '''=CMD.xml'));
  Assert.IsTrue(ContainsText(Line, '''+Fornecedor'));
end;

procedure TNFeReaderTests.ExportsXmlWithoutIndentation;
var
  Data: TNFeData;
  Line: string;
begin
  Data := Default(TNFeData);
  Data.XmlContent := '<NFe>' + sLineBreak +
    '  <emit>' + sLineBreak +
    '    <xNome>Fornecedor Teste</xNome>' + sLineBreak +
    '  </emit>' + sLineBreak +
    '</NFe>';

  Line := CsvLine(Data);
  Assert.IsFalse(ContainsText(Line, sLineBreak));
  Assert.IsTrue(ContainsText(Line,
    '<NFe><emit><xNome>Fornecedor Teste</xNome></emit></NFe>'));
end;

initialization
  TDUnitX.RegisterTestFixture(TNFeReaderTests);

end.
