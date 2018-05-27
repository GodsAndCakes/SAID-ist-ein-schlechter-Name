unit Backend.Google.Connector;

interface

uses
  Data.Articles,
  Data.API.Google,

  Core.Articles.Gen,

  JOSE.Core.JWT,
  JOSE.Core.JWK,
  JOSE.Core.JWS,
  JOSE.Core.JWA,
  JOSE.Types.Bytes,

  System.IOUtils,
  System.DateUtils,
  System.SysUtils;

type
  TGoogleConnector = class
    function AnalyzeArticles(AInput: IiPoolArticles): IArticle;
  end;

  TTokenGenerator = class
    function GenerateJWT: TJOSEBytes;
  end;

implementation

{ TGoogleConnector }

function TGoogleConnector.AnalyzeArticles(AInput: IiPoolArticles): IArticle;
begin

end;

{ TTokenGenerator }

function TTokenGenerator.GenerateJWT: TJOSEBytes;
var
  LToken: TJWT;
  LKey: TJWK;
  LJWS: TJWS;
  LDT: TDateTime;
begin
  LToken := TJWT.Create;
  LToken.Claims.SetClaimOfType('iss',
    'backend@said-205321.iam.gserviceaccount.com');
  LToken.Claims.SetClaimOfType('scope',
    'https://www.googleapis.com/auth/cloud-language');
  LToken.Claims.Audience := 'https://www.googleapis.com/oauth2/v4/token';
  LToken.Claims.IssuedAt := Now;
  LDT := Now;
  IncMinute(LDT, 30);
  LToken.Claims.Expiration := LDT;
  LKey := TJWK.Create(TFile.ReadAllBytes('kk.txt'));
  LJWS := TJWS.Create(LToken);
  LJWS.Sign(LKey, TJOSEAlgorithmId.RS256);
end;

end.
