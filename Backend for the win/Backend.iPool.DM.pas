unit Backend.iPool.DM;

interface

uses
  System.SysUtils, System.JSON, System.Classes, IPPeerClient, REST.Client,
  REST.Authenticator.Basic, Data.Bind.Components, Data.Bind.ObjectScope,
  Data.User.Preferences;

type
  TDMiPool = class(TDataModule)
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    HTTPBasicAuthenticator1: THTTPBasicAuthenticator;
  private
    { Private declarations }
  public
    { Public declarations }
    function MakeRequest(AORQueryList: TStringList): TJSONObject;
  end;

function DoRequestiPool(APreferences: IPreferences): TJSONObject;

implementation

function DoRequestiPool(APreferences: IPreferences): TJSONObject;
var
  LDMiPool: TDMiPool;
begin
  LDMiPool := TDMiPool.Create(nil);
  Result := LDMiPool.MakeRequest(APreferences.GetAllPreferences);
end;

{%CLASSGROUP 'System.Classes.TPersistent'}
{$R *.dfm}
{ TDataModule1 }

function TDMiPool.MakeRequest(AORQueryList: TStringList): TJSONObject;
var
  LURL: string;
  LQueryPreference: string;
  FlagStarted: boolean;
begin
  LURL := 'https://sandbox-api.ipool.asideas.de/sandbox/api/search?types=article&languages=EN&limit=10&q=';
  FlagStarted := false;
  for LQueryPreference in AORQueryList do
  begin
    if FlagStarted then
      LURL := LURL + '%20OR%20'
    else
      FlagStarted := true;
    LURL := LURL + LQueryPreference;
  end;
  RESTClient1.BaseURL := LURL;
  RESTRequest1.Execute;
  Result := RESTResponse1.JSONValue as TJSONObject;
end;

end.
