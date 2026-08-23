unit MainForm;

interface

uses
  Winapi.Windows, Winapi.ActiveX, System.SysUtils, System.Classes, System.IOUtils,
  System.StrUtils, System.Types, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Dialogs, Vcl.Grids, Vcl.Graphics, Vcl.ImgList, NFeReader,
  System.ImageList, Vcl.ComCtrls,Winapi.Messages, System.Variants;

type
  /// <summary>
  ///   Janela principal responsável pela seleção, leitura, edição e exportação
  ///   das NFes.
  /// </summary>
  TMainWindow = class(TForm)
    pnlHeader: TPanel;
    lblAppTitle: TLabel;
    lblAppSubtitle: TLabel;
    pnlContent: TPanel;
    pnlToolbar: TPanel;
    lblFolder: TLabel;
    btnChoose: TButton;
    btnLoad: TButton;
    btnExport: TButton;
    pnlGrid: TPanel;
    lblGridTitle: TLabel;
    lblRecordCount: TLabel;
    edtSearch: TEdit;
    edtFolder: TEdit;
    grdData: TStringGrid;
    pnlTotals: TPanel;
    lblTotalDocuments: TLabel;
    lblValidDocuments: TLabel;
    lblInvalidDocuments: TLabel;
    lblTotalValue: TLabel;
    pnlFooter: TPanel;
    lblStatus: TLabel;
    dlgFolder: TFileOpenDialog;
    dlgCsvSave: TSaveDialog;
    imlActions: TImageList;
    btnCancel: TButton;
    pgbLoadProgress: TProgressBar;

    /// <summary>Inicializa a aparência, os ícones e a grade.</summary>
    procedure FormCreate(Sender: TObject);

    /// <summary>Abre o seletor da pasta que contém os arquivos XML.</summary>
    procedure btnChooseClick(Sender: TObject);

    /// <summary>Lê os XMLs da pasta selecionada e preenche a grade.</summary>
    procedure btnLoadClick(Sender: TObject);

    /// <summary>Exporta para CSV os dados exibidos na grade.</summary>
    procedure btnExportClick(Sender: TObject);

    /// <summary>Desenha os ícones de edição e exclusão de cada registro.</summary>
    procedure grdDataDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);

    /// <summary>Executa a ação selecionada na linha da grade.</summary>
    procedure grdDataMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

    /// <summary>Filtra a grade conforme o texto informado pelo usuário.</summary>
    procedure edtSearchChange(Sender: TObject);

    /// <summary>Direciona o foco ao campo ao clicar no placeholder.</summary>
    procedure lblSearchHintClick(Sender: TObject);

    /// <summary>Solicita o cancelamento da leitura em andamento.</summary>
    procedure btnCancelClick(Sender: TObject);

    /// <summary>Impede o fechamento enquanto a leitura está terminando.</summary>
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FData: TArray<TNFeData>;
    FVisibleIndexes: TArray<Integer>;
    FLoading: Boolean;
    FCancelRequested: Boolean;
    FSortColumn: Integer;
    FSortAscending: Boolean;

    /// <summary>Atualiza uma linha da grade a partir do registro informado.</summary>
    procedure FillGridRow(const RowIndex, DataIndex: Integer);

    /// <summary>Reconstrói a grade aplicando o filtro de pesquisa atual.</summary>
    procedure ApplyFilter;

    /// <summary>Recalcula os totalizadores dos registros visíveis.</summary>
    procedure UpdateTotals;

    /// <summary>Exibe ou oculta o placeholder do campo de pesquisa.</summary>
    procedure UpdateSearchHint;

    /// <summary>Ordena o mapa de registros visíveis pela coluna atual.</summary>
    procedure SortVisibleIndexes;

    /// <summary>Compara dois registros conforme a coluna selecionada.</summary>
    function CompareDataIndices(const LeftIndex, RightIndex: Integer): Integer;

    /// <summary>Atualiza os indicadores de direção nos cabeçalhos.</summary>
    procedure UpdateSortHeaders;

    /// <summary>Atualiza a quantidade de documentos e a mensagem de estado.</summary>
    procedure UpdateSummary(const StatusText: string);

    /// <summary>Abre o formulário de edição para o registro indicado.</summary>
    procedure EditRecord(const DataIndex: Integer);

    /// <summary>Abre o conteúdo XML do registro dentro do aplicativo.</summary>
    procedure ViewRecord(const DataIndex: Integer);

    /// <summary>Solicita confirmação e exclui o registro indicado.</summary>
    procedure DeleteRecord(const DataIndex: Integer);

    /// <summary>Alterna os controles entre os estados ocioso e carregando.</summary>
    procedure SetLoading(const Value: Boolean);

    /// <summary>Conclui na interface uma operação de leitura assíncrona.</summary>
    procedure FinishLoad(const LoadedData: TArray<TNFeData>;
      const WasCancelled: Boolean; const ErrorText: string);
  end;

var
  MainWindow: TMainWindow;

implementation

uses
  EditNFeForm,
  XmlViewerForm;

{$R *.dfm}

const
  ColorSurface = $00FFFFFF;

procedure TMainWindow.FormCreate(Sender: TObject);
begin
  FSortColumn := -1;
  FSortAscending := True;
  grdData.Cells[0, 0] := 'ARQUIVO';
  grdData.Cells[1, 0] := 'FORNECEDOR';
  grdData.Cells[2, 0] := 'CNPJ';
  grdData.Cells[3, 0] := 'DATA';
  grdData.Cells[4, 0] := 'NÚMERO';
  grdData.Cells[5, 0] := 'TOTAL';
  grdData.Cells[6, 0] := 'STATUS';
  grdData.Cells[7, 0] := 'AÇÕES';
  grdData.ColWidths[0] := 170;
  grdData.ColWidths[1] := 220;
  grdData.ColWidths[2] := 125;
  grdData.ColWidths[3] := 140;
  grdData.ColWidths[4] := 80;
  grdData.ColWidths[5] := 95;
  grdData.ColWidths[6] := 155;
  grdData.ColWidths[7] := 132;
  grdData.DefaultRowHeight := 36;

  UpdateSearchHint;
  UpdateSummary('Selecione uma pasta para começar.');
end;

procedure TMainWindow.btnChooseClick(Sender: TObject);
begin
  if dlgFolder.Execute then
    edtFolder.Text := dlgFolder.FileName;
end;

procedure TMainWindow.btnLoadClick(Sender: TObject);
var
  FolderPath: string;
begin
  if FLoading then
    Exit;

  if not TDirectory.Exists(edtFolder.Text) then
  begin
    MessageDlg('Selecione uma pasta válida.', mtWarning, [mbOK], 0);
    Exit;
  end;

  FolderPath := edtFolder.Text;
  pgbLoadProgress.Position := 0;
  pgbLoadProgress.Style := pbstMarquee;
  pgbLoadProgress.MarqueeInterval := 35;
  FCancelRequested := False;
  SetLoading(True);

  TThread.CreateAnonymousThread(
    procedure
    var
      Files: TArray<string>;
      Index: Integer;
      ProcessedCount: Integer;
      LoadedData: TArray<TNFeData>;
      WasCancelled: Boolean;
      ErrorText: string;
    begin
      CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
      try
        WasCancelled := False;
        ErrorText := '';
        ProcessedCount := 0;
        try
          Files := TDirectory.GetFiles(FolderPath, '*.xml');
          TThread.Synchronize(nil,
            procedure
            begin
              pgbLoadProgress.Style := pbstNormal;
              if Length(Files) = 0 then
                pgbLoadProgress.Max := 1
              else
                pgbLoadProgress.Max := Length(Files);
              pgbLoadProgress.Position := 0;
              lblStatus.Caption := Format('%d arquivo(s) XML encontrado(s).',
                [Length(Files)]);
            end);

          SetLength(LoadedData, Length(Files));
          for Index := 0 to High(Files) do
          begin
            if FCancelRequested then
            begin
              WasCancelled := True;
              SetLength(LoadedData, ProcessedCount);
              Break;
            end;

            LoadedData[Index] := ReadNFe(Files[Index]);
            Inc(ProcessedCount);
            TThread.Synchronize(nil,
              procedure
              begin
                pgbLoadProgress.Position := Index + 1;
                lblStatus.Caption := Format('Lendo documento %d de %d...',
                  [Index + 1, Length(Files)]);
              end);
          end;
        except
          on E: Exception do
          begin
            ErrorText := E.Message;
            SetLength(LoadedData, ProcessedCount);
          end;
        end;

        TThread.Synchronize(nil,
          procedure
          begin
            FinishLoad(LoadedData, WasCancelled, ErrorText);
          end);
      finally
        CoUninitialize;
      end;
    end).Start;
end;

procedure TMainWindow.SetLoading(const Value: Boolean);
begin
  FLoading := Value;
  btnChoose.Enabled := not Value;
  btnLoad.Enabled := not Value;
  edtFolder.Enabled := not Value;
  edtSearch.Enabled := not Value;
  btnCancel.Visible := Value;
  btnCancel.Enabled := Value;
  pgbLoadProgress.Visible := True;
  btnExport.Enabled := (not Value) and (Length(FData) > 0);
  if Value then
    lblStatus.Caption := 'Preparando a leitura...';
end;

procedure TMainWindow.FinishLoad(const LoadedData: TArray<TNFeData>;
  const WasCancelled: Boolean; const ErrorText: string);
begin
  FData := LoadedData;
  edtSearch.Clear;
  ApplyFilter;
  SetLoading(False);
  pgbLoadProgress.Style := pbstNormal;
  if (not WasCancelled) and (ErrorText = '') then
    pgbLoadProgress.Position := pgbLoadProgress.Max;

  if ErrorText <> '' then
    UpdateSummary('Falha durante a leitura: ' + ErrorText)
  else if WasCancelled then
    UpdateSummary('Leitura cancelada. Documentos já processados foram mantidos.')
  else
    UpdateSummary('Leitura concluída com sucesso.');
end;

procedure TMainWindow.btnCancelClick(Sender: TObject);
begin
  FCancelRequested := True;
  btnCancel.Enabled := False;
  lblStatus.Caption := 'Cancelando a leitura...';
end;

procedure TMainWindow.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not FLoading;
  if not CanClose then
  begin
    FCancelRequested := True;
    lblStatus.Caption := 'Aguarde o encerramento da leitura antes de fechar.';
  end;
end;

procedure TMainWindow.ApplyFilter;
var
  DataIndex: Integer;
  VisibleCount: Integer;
  SearchText: string;
  SearchableText: string;
begin
  SearchText := Trim(edtSearch.Text);
  SetLength(FVisibleIndexes, Length(FData));
  VisibleCount := 0;

  for DataIndex := 0 to High(FData) do
  begin
    SearchableText :=
      ExtractFileName(FData[DataIndex].FileName) + ' ' +
      FData[DataIndex].Supplier + ' ' +
      FData[DataIndex].CNPJ + ' ' +
      FData[DataIndex].DateText + ' ' +
      FData[DataIndex].NumberText + ' ' +
      CurrToStr(FData[DataIndex].Total) + ' ' +
      FData[DataIndex].ErrorText;

    if (SearchText = '') or ContainsText(SearchableText, SearchText) then
    begin
      FVisibleIndexes[VisibleCount] := DataIndex;
      Inc(VisibleCount);
    end;
  end;

  SetLength(FVisibleIndexes, VisibleCount);
  SortVisibleIndexes;
  grdData.RowCount := VisibleCount + 1;
  for DataIndex := 0 to VisibleCount - 1 do
    FillGridRow(DataIndex + 1, FVisibleIndexes[DataIndex]);
  grdData.Invalidate;
  UpdateTotals;
end;

function TMainWindow.CompareDataIndices(const LeftIndex,
  RightIndex: Integer): Integer;
var
  LeftNumber: Int64;
  RightNumber: Int64;
begin
  case FSortColumn of
    0:
      Result := CompareText(ExtractFileName(FData[LeftIndex].FileName),
        ExtractFileName(FData[RightIndex].FileName));
    1:
      Result := CompareText(FData[LeftIndex].Supplier,
        FData[RightIndex].Supplier);
    2:
      Result := CompareText(FData[LeftIndex].CNPJ, FData[RightIndex].CNPJ);
    3:
      Result := CompareText(FData[LeftIndex].DateText,
        FData[RightIndex].DateText);
    4:
      begin
        if TryStrToInt64(FData[LeftIndex].NumberText, LeftNumber) and
          TryStrToInt64(FData[RightIndex].NumberText, RightNumber) then
        begin
          if LeftNumber < RightNumber then
            Result := -1
          else if LeftNumber > RightNumber then
            Result := 1
          else
            Result := 0;
        end
        else
          Result := CompareText(FData[LeftIndex].NumberText,
            FData[RightIndex].NumberText);
      end;
    5:
      begin
        if FData[LeftIndex].Total < FData[RightIndex].Total then
          Result := -1
        else if FData[LeftIndex].Total > FData[RightIndex].Total then
          Result := 1
        else
          Result := 0;
      end;
    6:
      Result := CompareText(FData[LeftIndex].ErrorText,
        FData[RightIndex].ErrorText);
  else
    Result := 0;
  end;

  if (Result = 0) and (FSortColumn <> 0) then
    Result := CompareText(ExtractFileName(FData[LeftIndex].FileName),
      ExtractFileName(FData[RightIndex].FileName));
  if not FSortAscending then
    Result := -Result;
end;

procedure TMainWindow.SortVisibleIndexes;

  procedure QuickSort(const Left, Right: Integer);
  var
    LowIndex: Integer;
    HighIndex: Integer;
    PivotDataIndex: Integer;
    TemporaryIndex: Integer;
  begin
    LowIndex := Left;
    HighIndex := Right;
    PivotDataIndex := FVisibleIndexes[(Left + Right) div 2];
    repeat
      while CompareDataIndices(FVisibleIndexes[LowIndex], PivotDataIndex) < 0 do
        Inc(LowIndex);
      while CompareDataIndices(FVisibleIndexes[HighIndex], PivotDataIndex) > 0 do
        Dec(HighIndex);
      if LowIndex <= HighIndex then
      begin
        TemporaryIndex := FVisibleIndexes[LowIndex];
        FVisibleIndexes[LowIndex] := FVisibleIndexes[HighIndex];
        FVisibleIndexes[HighIndex] := TemporaryIndex;
        Inc(LowIndex);
        Dec(HighIndex);
      end;
    until LowIndex > HighIndex;
    if Left < HighIndex then
      QuickSort(Left, HighIndex);
    if LowIndex < Right then
      QuickSort(LowIndex, Right);
  end;

begin
  if (FSortColumn < 0) or (Length(FVisibleIndexes) < 2) then
    Exit;
  QuickSort(0, High(FVisibleIndexes));
end;

procedure TMainWindow.UpdateSortHeaders;
const
  HeaderNames: array[0..7] of string = (
    'ARQUIVO', 'FORNECEDOR', 'CNPJ', 'DATA', 'NÚMERO', 'TOTAL', 'STATUS',
    'AÇÕES');
var
  ColumnIndex: Integer;
begin
  for ColumnIndex := Low(HeaderNames) to High(HeaderNames) do
    grdData.Cells[ColumnIndex, 0] := HeaderNames[ColumnIndex];

  if FSortColumn >= 0 then
    if FSortAscending then
      grdData.Cells[FSortColumn, 0] := HeaderNames[FSortColumn] + ' ▲'
    else
      grdData.Cells[FSortColumn, 0] := HeaderNames[FSortColumn] + ' ▼';
end;

procedure TMainWindow.UpdateTotals;
var
  VisibleIndex: Integer;
  DataIndex: Integer;
  ValidCount: Integer;
  InvalidCount: Integer;
  TotalValue: Currency;
begin
  ValidCount := 0;
  InvalidCount := 0;
  TotalValue := 0;

  for VisibleIndex := 0 to High(FVisibleIndexes) do
  begin
    DataIndex := FVisibleIndexes[VisibleIndex];
    if FData[DataIndex].Valid then
      Inc(ValidCount)
    else
      Inc(InvalidCount);
    TotalValue := TotalValue + FData[DataIndex].Total;
  end;

  lblTotalDocuments.Caption := Format('DOCUMENTOS  %d',
    [Length(FVisibleIndexes)]);
  lblValidDocuments.Caption := Format('VÁLIDOS  %d', [ValidCount]);
  lblInvalidDocuments.Caption := Format('COM ERRO  %d', [InvalidCount]);
  lblTotalValue.Caption := 'VALOR TOTAL  ' +
    FormatCurr('R$ #,##0.00', TotalValue);
end;

procedure TMainWindow.edtSearchChange(Sender: TObject);
begin
  UpdateSearchHint;
  ApplyFilter;
  if Trim(edtSearch.Text) = '' then
    UpdateSummary('Exibindo todos os documentos.')
  else
    UpdateSummary('Filtro de pesquisa aplicado.');
end;

procedure TMainWindow.UpdateSearchHint;
begin
//  lblSearchHint.Visible := edtSearch.Text = '';
//  if lblSearchHint.Visible then
//    lblSearchHint.BringToFront;
end;

procedure TMainWindow.lblSearchHintClick(Sender: TObject);
begin
  if edtSearch.CanFocus then
    edtSearch.SetFocus;
end;

procedure TMainWindow.FillGridRow(const RowIndex, DataIndex: Integer);
begin
  grdData.Cells[0, RowIndex] := ExtractFileName(FData[DataIndex].FileName);
  grdData.Cells[1, RowIndex] := FData[DataIndex].Supplier;
  grdData.Cells[2, RowIndex] := FData[DataIndex].CNPJ;
  grdData.Cells[3, RowIndex] := FData[DataIndex].DateText;
  grdData.Cells[4, RowIndex] := FData[DataIndex].NumberText;
  grdData.Cells[5, RowIndex] := FormatCurr('R$ #,##0.00', FData[DataIndex].Total);
  if FData[DataIndex].Valid then
    grdData.Cells[6, RowIndex] := 'Documento válido'
  else
    grdData.Cells[6, RowIndex] := FData[DataIndex].ErrorText;
  grdData.Cells[7, RowIndex] := '';
end;

procedure TMainWindow.UpdateSummary(const StatusText: string);
begin
  if Trim(edtSearch.Text) = '' then
    lblRecordCount.Caption := Format('%d documento(s)', [Length(FData)])
  else
    lblRecordCount.Caption := Format('%d de %d documento(s)',
      [Length(FVisibleIndexes), Length(FData)]);
  lblStatus.Caption := StatusText;
  btnExport.Enabled := Length(FData) > 0;
end;

procedure TMainWindow.grdDataDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  SectionWidth: Integer;
  IconY: Integer;
begin
  if (ACol <> 7) or (ARow = 0) then
    Exit;

  grdData.Canvas.Brush.Color := ColorSurface;
  grdData.Canvas.FillRect(Rect);
  if imlActions.Count < 3 then
    Exit;

  SectionWidth := Rect.Width div 3;
  IconY := Rect.Top + (Rect.Height - imlActions.Height) div 2;
  imlActions.Draw(grdData.Canvas,
    Rect.Left + (SectionWidth - imlActions.Width) div 2, IconY, 0, True);
  imlActions.Draw(grdData.Canvas,
    Rect.Left + SectionWidth + (SectionWidth - imlActions.Width) div 2,
    IconY, 1, True);
  imlActions.Draw(grdData.Canvas,
    Rect.Left + (SectionWidth * 2) +
    (SectionWidth - imlActions.Width) div 2, IconY, 2, True);
end;

procedure TMainWindow.grdDataMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ColIndex: Integer;
  RowIndex: Integer;
  CellRect: TRect;
  DataIndex: Integer;
  RelativeX: Integer;
begin
  if Button <> mbLeft then
    Exit;

  grdData.MouseToCell(X, Y, ColIndex, RowIndex);
  if RowIndex = 0 then
  begin
    if (ColIndex >= 0) and (ColIndex <= 6) then
    begin
      if FSortColumn = ColIndex then
        FSortAscending := not FSortAscending
      else
      begin
        FSortColumn := ColIndex;
        FSortAscending := True;
      end;
      UpdateSortHeaders;
      ApplyFilter;
    end;
    Exit;
  end;

  if (ColIndex <> 7) or (RowIndex <= 0) or
    (RowIndex > Length(FVisibleIndexes)) then
    Exit;

  CellRect := grdData.CellRect(ColIndex, RowIndex);
  DataIndex := FVisibleIndexes[RowIndex - 1];
  RelativeX := X - CellRect.Left;
  if RelativeX < CellRect.Width div 3 then
    ViewRecord(DataIndex)
  else if RelativeX < CellRect.Width * 2 div 3 then
    EditRecord(DataIndex)
  else
    DeleteRecord(DataIndex);
end;

procedure TMainWindow.ViewRecord(const DataIndex: Integer);
begin
  TXmlViewerWindow.Execute(Self, ExtractFileName(FData[DataIndex].FileName),
    FData[DataIndex].XmlContent);
end;

procedure TMainWindow.EditRecord(const DataIndex: Integer);
begin
  if TEditNFeWindow.Execute(Self, FData[DataIndex]) then
  begin
    ApplyFilter;
    UpdateSummary('Registro atualizado.');
  end;
end;

procedure TMainWindow.DeleteRecord(const DataIndex: Integer);
var
  Index: Integer;
begin
  if MessageDlg('Deseja excluir este registro da lista?', mtConfirmation,
    [mbYes, mbNo], 0) <> mrYes then
    Exit;

  for Index := DataIndex to High(FData) - 1 do
    FData[Index] := FData[Index + 1];
  SetLength(FData, Length(FData) - 1);

  ApplyFilter;
  UpdateSummary('Registro excluído da lista.');
end;

procedure TMainWindow.btnExportClick(Sender: TObject);
var
  Lines: TStringList;
  Item: TNFeData;
begin
  if Length(FData) = 0 then
    Exit;

  if not dlgCsvSave.Execute then
    Exit;

  Lines := TStringList.Create;
  try
    Lines.Add('Arquivo;Fornecedor;CNPJ;Data;Numero;Total;Erro;XML');
    for Item in FData do
      Lines.Add(CsvLine(Item));

    Lines.SaveToFile(dlgCsvSave.FileName, TEncoding.UTF8);
    UpdateSummary('CSV exportado com sucesso.');
  finally
    Lines.Free;
  end;
end;

end.
