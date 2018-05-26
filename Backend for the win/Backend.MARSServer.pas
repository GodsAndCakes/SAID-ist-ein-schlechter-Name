unit Backend.MARSServer;

interface

uses
  System.SysUtils,

  MARS.HTTP.Server.Indy,
  MARS.Core.Engine,
  MARS.Core.Application;

type
  TBackendMARSServer = class
  private
    FEngine: TMARSEngine;
    FServer: TMARSHTTPServerIndy;
  public
    constructor Create;
    procedure Run;
    destructor Destroy; override;
  end;

implementation

{ TBackendMARSServer }

constructor TBackendMARSServer.Create;
begin
  FEngine := TMARSEngine.Create;
  FEngine.Port := 80;
  FEngine.ThreadPoolSize := 4;
  // FEngine.AddApplication()
  FServer := TMARSHTTPServerIndy.Create(FEngine);
  FServer.DefaultPort := FEngine.Port;
end;

destructor TBackendMARSServer.Destroy;
begin
  FreeAndNil(FEngine);
  FreeAndNil(FServer);
  inherited;
end;

procedure TBackendMARSServer.Run;
begin
  FServer.Active := true;
end;

end.
