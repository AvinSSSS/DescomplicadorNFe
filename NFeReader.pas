unit NFeReader;
interface
uses System.SysUtils, System.Generics.Collections, Xml.XMLIntf, Xml.XMLDoc;
type TNFeData = record FileName, Supplier, CNPJ, DateText, NumberText: string; Total: Currency; Valid: Boolean; ErrorText: string; end;
function ReadNFe(const FileName: string): TNFeData;
function CsvLine(const Data: TNFeData): string;
implementation
function FindByLocalName(const Node: IXMLNode; const Name: string): IXMLNode;
var I: Integer;
begin Result := nil; if Node = nil then Exit; if SameText(Node.LocalName, Name) then Exit(Node); for I := 0 to Node.ChildNodes.Count - 1 do begin Result := FindByLocalName(Node.ChildNodes[I], Name); if Result <> nil then Exit; end; end;
function TextOf(const Root: IXMLNode; const Name: string): string; var N: IXMLNode; begin N := FindByLocalName(Root, Name); if N <> nil then Result := N.Text else Result := ''; end;
function ReadNFe(const FileName: string): TNFeData;
var Doc: IXMLDocument; Root, Emit, TotalNode: IXMLNode; S: string; FS: TFormatSettings;
begin Result := Default(TNFeData); Result.FileName := FileName; FS := TFormatSettings.Create('pt-BR'); FS.DecimalSeparator := '.';
  try Doc := LoadXMLDocument(FileName); Root := Doc.DocumentElement; Emit := FindByLocalName(Root, 'emit'); TotalNode := FindByLocalName(Root, 'ICMSTot');
    Result.Supplier := TextOf(Emit, 'xNome'); Result.CNPJ := TextOf(Emit, 'CNPJ'); Result.DateText := TextOf(Root, 'dhEmi'); if Result.DateText = '' then Result.DateText := TextOf(Root, 'dEmi'); Result.NumberText := TextOf(Root, 'nNF'); S := TextOf(TotalNode, 'vNF'); if not TryStrToCurr(S, Result.Total, FS) then Result.Total := 0; Result.Valid := (Result.NumberText <> '') and (Result.Supplier <> ''); if not Result.Valid then Result.ErrorText := 'Campos essenciais ausentes';
  except on E: Exception do begin Result.Valid := False; Result.ErrorText := E.Message; end; end;
end;
function Q(const S: string): string; begin Result := '"' + StringReplace(S, '"', '""', [rfReplaceAll]) + '"'; end;
function CsvLine(const Data: TNFeData): string; begin Result := Q(ExtractFileName(Data.FileName)) + ';' + Q(Data.Supplier) + ';' + Q(Data.CNPJ) + ';' + Q(Data.DateText) + ';' + Q(Data.NumberText) + ';' + CurrToStr(Data.Total) + ';' + Q(Data.ErrorText); end;
end.
