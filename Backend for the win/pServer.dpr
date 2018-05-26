program pServer;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  Data.User.Preferences in 'Data.User.Preferences.pas',
  Data.Articles in 'Data.Articles.pas',
  Backend.MARSServer in 'Backend.MARSServer.pas';

var
  LServer: TBackendMARSServer;

begin
  LServer := TBackendMARSServer.Create;
  try
    try
      LServer.Run;
      Readln;
    except
      on E: Exception do
        Writeln(E.ClassName, ': ', E.Message);
    end;
  finally
    FreeAndNil(LServer);
  end;

end.
