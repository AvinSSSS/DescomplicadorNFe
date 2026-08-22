program NFeExplorer;
uses Vcl.Forms, MainForm in 'MainForm.pas', NFeReader in 'NFeReader.pas';
begin Application.Initialize; Application.MainFormOnTaskbar := True; Application.CreateForm(TMainWindow, MainWindow); Application.Run; end.
