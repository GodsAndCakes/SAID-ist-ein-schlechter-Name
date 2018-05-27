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
  System.SysUtils,
  System.Net.HTTPClient,
  System.Net.HTTPClientComponent,
  System.Net.URLClient,
  System.Classes,
  System.JSON,
  System.Generics.Collections;

type

   TSAIDGoogleArticle = class(TInterfacedObject, IGoogleArticle)
   private
     FCaption: string;
     FCategories: TStringList;
     FLanguage: TLanguage;
     FSentences: TList<ISentence>;
     FSentiment: TSentiment;
     FSource: TSource;
   public
     constructor Create(ACaption: string; ACategories: TStringList;
       ALanguage: TLanguage; ASentences: TList<ISentence>;
       ASentiment: TSentiment; ASource: TSource);
     function GetCaption: string;
     function GetCategories(const AIndex: Integer): string;
     function GetCategoryCount: Integer;
     function GetLanguage: TLanguage;
     function GetSentenceCount: Integer;
     function GetSentences(const AIndex: Integer): ISentence;
     function GetSentiment: TSentiment;
     function GetSource: TSource;
  end;

  TGoogleConnector = class
  private
    function SendReqToGoogle(AAccessToken: string; AArticles: IiPoolArticles)
      : TJSONObject;
    function ConvertJSONToGoogleArticle(ACaption: string; AJSONObject: TJSONObject)
      : IGoogleArticle;
  public
    function AnalyzeArticles(AInput: IiPoolArticles): IArticle;
  end;

  TTokenGenerator = class
    function GenerateJWT: TJOSEBytes;
    function GenerateAccessToken(AJWT: TJOSEBytes): string;
  end;

implementation

{ TGoogleConnector }

function TGoogleConnector.AnalyzeArticles(AInput: IiPoolArticles): IArticle;
var
  LJWT: TJOSEBytes;
  LTokenGenerator: TTokenGenerator;
  LAccessToken: string;
begin
  LTokenGenerator := TTokenGenerator.Create;
  LJWT := LTokenGenerator.GenerateJWT;
  LAccessToken := LTokenGenerator.GenerateAccessToken(LJWT);
  FreeAndNil(LTokenGenerator);

end;

function TGoogleConnector.ConvertJSONToGoogleArticle(ACaption: string; AJSONObject: TJSONObject)
      : IGoogleArticle;
var
  LCaption: string;
  LCategories: TStringList;
  LLanguage: TLanguage;
  LSentences: TList<ISentence>;
  LSentiment: TSentiment;
  LSource: TSource;
begin
  LCaption := ACaption;
  LCategories :=
  Result := TSAIDGoogleArticle.Create(LCaption, LCategories, LLanguage,
  LSentences, LSentiment, LSource);
end;

function TGoogleConnector.SendReqToGoogle(AAccessToken: string;
  AArticles: IiPoolArticles): TJSONObject;
var
  i: Integer;
  LJSONReq: TJSONObject;
  LObj, LFeat: TJSONObject;
  HTTPClient: TNetHTTPClient;
  LOutputString: TStream;
  LHeaders: TNetHeaders;
  LOutputJSON: TJSONObject;
  LStreamReader: TStreamReader;
  LArticle: IArticle;
  LGarticle: IGoogleArticle;
begin
  HTTPClient := TNetHTTPClient.Create(nil);
  LJSONReq := TJSONObject.Create;
  LJSONReq.AddPair('encoding', 'UTF8');
  LObj := TJSONObject.Create;
  LObj.AddPair('type', 'PLAIN_TEXT');
  LJSONReq.AddPair('document', LObj);
  LFeat := TJSONObject.Create;
  LFeat.AddPair('extractSyntax', TJSONBool.Create(true));
  LFeat.AddPair('extractDocumentSentiment', TJSONBool.Create(true));
  LJSONReq.AddPair('features', LFeat);
  SetLength(LHeaders, 1);
  LHeaders[0].Value := 'Bearer ' + AAccessToken;
  LHeaders[0].Name := 'Authorization';
  for i := 0 to AArticles.Count - 1 do
  begin
    LOutputString := TStringStream.Create;
    LObj.AddPair('content', AArticles.Articles[i].Content);
    HTTPClient.Post
      ('https://language.googleapis.com/v1/documents:analyzeSyntax',
      TStringStream.Create(LJSONReq.ToString), LOutputString, LHeaders);
    LStreamReader := TStreamReader.Create(LOutputString);
    LOutputJSON := TJSONObject.ParseJSONValue(LStreamReader.ReadToEnd)
      as TJSONObject;
    FreeAndNil(LStreamReader);
    FreeAndNil(LOutputString);
    LGarticle := ConvertJSONToGoogleArticle(LOutputJSON);
    LArticle := TArticle.Create(LGarticle);
  end;
end;

{ TTokenGenerator }

function TTokenGenerator.GenerateAccessToken(AJWT: TJOSEBytes): string;
var
  HTTPClient: TNetHTTPClient;
  LStrStream: TStream;
  LResponse: IHTTPResponse;
  LJSONResponse: TJSONObject;
  LHeaders: TNetHeaders;
begin
  HTTPClient := TNetHTTPClient.Create(nil);
  LStrStream := TStringStream.Create
    ('grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion='
    + AJWT.AsString);
  SetLength(LHeaders, 1);
  LHeaders[0].Name := 'Content-Type';
  LHeaders[0].Value := 'application/x-www-form-urlencoded';
  LResponse := HTTPClient.Post('https://www.googleapis.com/oauth2/v4/token',
    LStrStream, nil, LHeaders);
  LJSONResponse := TJSONObject.ParseJSONValue(LResponse.ContentAsString)
    as TJSONObject;
  Result := LJSONResponse.Values['access_token'].Value;
  FreeAndNil(HTTPClient);
  FreeAndNil(LJSONResponse);
  FreeAndNil(LStrStream);
end;

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
  Result := LJWS.CompactToken;
end;

end.
