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
    constructor Create;
    destructor Destroy; override;
    function GetCaption: string;
    function GetCategories(const AIndex: Integer): string;
    function GetCategoryCount: Integer;
    function GetLanguage: TLanguage;
    function GetSentenceCount: Integer;
    function GetSentences(const AIndex: Integer): ISentence;
    function GetSentiment: TSentiment;
    function GetSource: TSource;
  end;

  TSAIDSentence = class(TInterfacedObject, ISentence)
  private
    FOffset: Integer;
    FTokens: TList<IToken>;
  public
    constructor Create(AOffset: Integer; ATokens: TList<IToken>);
    function GetOffset: Integer;
    function GetTokenCount: Integer;
    function GetTokens(const AIndex: Integer): IToken;
  end;

  TSAIDToken = class(TInterfacedObject, IToken)
  private
    FCase: TCase;
    FDependency: IToken;
    FGender: TGender;
    FLabel: TLabel;
    FNumber: TNumber;
    FOffset: Integer;
    FPerson: TPerson;
    FTag: TTag;
    FTense: TTense;
    FText: string;
    FLemma: string;
  public
    constructor Create(ACase: TCase; ADependency: IToken; AGender: TGender;
      ALabel: TLabel; ANumber: TNumber; AOffset: Integer; APerson: TPerson;
      ATag: TTag; ATense: TTense; AText: string; ALemma: string);
    function GetCase: TCase;
    function GetDependency: IToken;
    function GetGender: TGender;
    function GetLabel: TLabel;
    function GetNumber: TNumber;
    function GetOffset: Integer;
    function GetPerson: TPerson;
    function GetTag: TTag;
    function GetTense: TTense;
    function GetText: string;
    function GetLemma: string;
  end;

  TGoogleConnector = class
  private
    function SendReqToGoogle(AAccessToken: string; AArticles: IiPoolArticles)
      : TJSONObject;
    function ConvertJSONToGoogleArticle(ACaption: string;
      AJSONObject: TJSONObject): IGoogleArticle;
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
  SendReqToGoogle(LAccessToken, AInput);
end;

function TGoogleConnector.ConvertJSONToGoogleArticle(ACaption: string;
  AJSONObject: TJSONObject): IGoogleArticle;
var
  LCategoriesJSON, LSentencesJSON, LTokensJSON: TJSONArray;
  LSentenceJSON: TJSONObject;
  i, j: Integer;
begin
  Result := TSAIDGoogleArticle.Create;
  (Result as TSAIDGoogleArticle).FCaption := ACaption;

  // Read categories
  LCategoriesJSON := AJSONObject.Values['categories'] as TJSONArray;
  for i := 0 to LCategoriesJSON.Count - 1 do
    (Result as TSAIDGoogleArticle).FCategories.Add(LCategoriesJSON.Items[i].Value);

  (Result as TSAIDGoogleArticle) := TLanguage.laEN;

  // Read sentences and tokens
  (Result as TSAIDGoogleArticle).F := 0;
  LSentences := TList<ISentence>.Create;
  LSentencesJSON := AJSONObject.Values['sentences'] as TJSONArray;
  LTokensJSON := AJSONObject.Values['tokens'] as TJSONArray;
  for i := 0 to LSentencesJSON.Count - 1 do
  begin
    LSentenceJSON := LSentencesJSON.Items[i] as TJSONObject;
    if i < LSentences.Count - 1 then
      LOffset := (((LSentencesJSON.Items[i + 1] as TJSONObject).Values['text']
        as TJSONObject).Values['beginOffset'] as TJSONNumber).Value.ToInteger
    else
      LOffset := LTokensJSON.Count - 1;
    for j := LOldOffset to LOffset do

  end;

  // LSentiment := ;
  LSource := TSource.scDPA;
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
  LOutputStream: TStream;
  LHeaders: TNetHeaders;
  LOutputJSON: TJSONObject;
  LStreamReader: TStreamReader;
  LArticle: IArticle;
  LGarticle: IGoogleArticle;
begin
  HTTPClient := TNetHTTPClient.Create(nil);
  LJSONReq := TJSONObject.Create;
  LJSONReq.AddPair('encodingType', 'UTF8');
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
    LOutputStream := TStringStream.Create;
    LObj.AddPair('content', AArticles.Articles[i].Content);
    HTTPClient.Post('https://language.googleapis.com/v1/documents:annotateText',
      TStringStream.Create(LJSONReq.ToString), LOutputStream, LHeaders);
    LStreamReader := TStreamReader.Create(LOutputStream);
    LOutputJSON := TJSONObject.ParseJSONValue(LStreamReader.ReadToEnd)
      as TJSONObject;
    FreeAndNil(LStreamReader);
    FreeAndNil(LOutputStream);
    LGarticle := ConvertJSONToGoogleArticle(AArticles.Articles[i].Heading,
      LOutputJSON);
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

{ TSAIDGoogleArticle }

constructor TSAIDGoogleArticle.Create;
begin
  FCategories := TStringList.Create;
  FSentences := TList<TSAIDSentence>.Create;
end;

destructor TSAIDGoogleArticle.Destroy;
begin
  FCategories.Free;
  FSentences.Free;
  inherited;
end;

function TSAIDGoogleArticle.GetCaption: string;
begin
  Result := FCaption;
end;

function TSAIDGoogleArticle.GetCategories(const AIndex: Integer): string;
begin
  Result := FCategories[AIndex];
end;

function TSAIDGoogleArticle.GetCategoryCount: Integer;
begin
  Result := FCategories.Count;
end;

function TSAIDGoogleArticle.GetLanguage: TLanguage;
begin
  Result := FLanguage;
end;

function TSAIDGoogleArticle.GetSentenceCount: Integer;
begin
  Result := FSentences.Count;
end;

function TSAIDGoogleArticle.GetSentences(const AIndex: Integer): ISentence;
begin
  Result := FSentences[AIndex];
end;

function TSAIDGoogleArticle.GetSentiment: TSentiment;
begin
  Result := FSentiment;
end;

function TSAIDGoogleArticle.GetSource: TSource;
begin
  Result := FSource;
end;

{ TSAIDSentence }

constructor TSAIDSentence.Create(AOffset: Integer; ATokens: TList<IToken>);
begin
  FOffset := AOffset;
  FTokens := ATokens;
end;

function TSAIDSentence.GetOffset: Integer;
begin
  Result := FOffset;
end;

function TSAIDSentence.GetTokenCount: Integer;
begin
  Result := FTokens.Count;
end;

function TSAIDSentence.GetTokens(const AIndex: Integer): IToken;
begin
  Result := FTokens[AIndex];
end;

{ TSAIDToken }

constructor TSAIDToken.Create(ACase: TCase; ADependency: IToken;
  AGender: TGender; ALabel: TLabel; ANumber: TNumber; AOffset: Integer;
  APerson: TPerson; ATag: TTag; ATense: TTense; AText, ALemma: string);
begin
  FCase := ACase;
  FDependency := ADependency;
  FGender := AGender;
  FLabel := ALabel;
  FNumber := ANumber;
  FOffset := AOffset;
  FPerson := APerson;
  FTag := ATag;
  FTense := ATense;
  FText := AText;
  FLemma := ALemma;
end;

function TSAIDToken.GetCase: TCase;
begin
  Result := FCase;
end;

function TSAIDToken.GetDependency: IToken;
begin
  Result := FDependency;
end;

function TSAIDToken.GetGender: TGender;
begin
  Result := FGender;
end;

function TSAIDToken.GetLabel: TLabel;
begin
  Result := FLabel;
end;

function TSAIDToken.GetLemma: string;
begin
  Result := FLemma;
end;

function TSAIDToken.GetNumber: TNumber;
begin
  Result := FNumber;
end;

function TSAIDToken.GetOffset: Integer;
begin
  Result := FOffset;
end;

function TSAIDToken.GetPerson: TPerson;
begin
  Result := FPerson;
end;

function TSAIDToken.GetTag: TTag;
begin
  Result := FTag;
end;

function TSAIDToken.GetTense: TTense;
begin
  Result := FTense;
end;

function TSAIDToken.GetText: string;
begin
  Result := FText;
end;

end.
