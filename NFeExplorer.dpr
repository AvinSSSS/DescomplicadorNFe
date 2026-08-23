program NFeExplorer;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {MainWindow},
  NFeReader in 'NFeReader.pas',
  EditNFeForm in 'EditNFeForm.pas',
  XmlViewerForm in 'XmlViewerForm.pas' {XmlViewerWindow},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainWindow, MainWindow);
  Application.Run;
end.
