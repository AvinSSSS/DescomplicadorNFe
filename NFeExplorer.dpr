program NFeExplorer;

uses
  Vcl.Forms,
  MainForm in 'src\forms\MainForm.pas' {MainWindow},
  NFeReader in 'src\NFeReader.pas',
  EditNFeForm in 'src\forms\EditNFeForm.pas',
  XmlViewerForm in 'src\forms\XmlViewerForm.pas' {XmlViewerWindow},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainWindow, MainWindow);
  Application.Run;
end.
