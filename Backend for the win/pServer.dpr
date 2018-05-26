program pServer;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  Data.User.Preferences in 'Data.User.Preferences.pas',
  Data.Articles in 'Data.Articles.pas',
  Backend.MARSServer in 'Backend.MARSServer.pas',
  Backend.Resource in 'Backend.Resource.pas',
  Data.API.iPool in 'Data.API.iPool.pas',
  Data.API.Google in 'Data.API.Google.pas',
  Backend.iPool.DM in 'Backend.iPool.DM.pas' {DMiPool: TDataModule},
  Backend.iPool.Connector in 'Backend.iPool.Connector.pas';

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
