unit Backend.Resource;

interface

uses
  System.JSON,
  System.SysUtils,
  System.Classes,

  Data.User.Preferences,
  Data.Articles,
  Backend.iPool.Connector,

  MARS.Core.Registry,
  MARS.Core.Attributes,
  MARS.Core.MediaType,
  MARS.Core.JSON,
  MARS.Core.MessageBodyWriters,
  MARS.Core.MessageBodyReaders,
  MARS.mORMotJWT.Token;

type

  [Path('/default')]
  TSAIDResource = class
  public
    [GET, Path('/articles'), Produces(TMediaType.APPLICATION_JSON)]
    function GetArticles([BodyParam] AData: TJSONObject): TJSONObject;
  end;

  TSAIDPreferences = class(TinterfacedObject, IPreferences)
  private
    FPreferences : TStringList;
  public
    constructor Create(APref: TStringList);
    function GetFavourable(const AKeyword: String): Boolean;
    function GetUnfavourable(const AKeyword: String): Boolean;
    property Favourable[const AKeyword: String]: Boolean read GetFavourable;
    property Unfavourable[const AKeywords: String]: Boolean
      read GetUnfavourable;
    function GetAllPreferences: TStringList;
    destructor Destroy; override;
  end;

  TConverterToPrefrences = class
    class function Convert(AData: TJSONObject): IPreferences;
  end;

implementation

{ TSAIDResource }

function TSAIDResource.GetArticles(AData: TJSONObject): TJSONObject;
var
  LPreferences: IPreferences;
  iPoolConnector: TSAIDiPoolConnector;
  LiPoolArticles: IiPoolArticles;
  LArr: TJSONArray;
  LObj: TJSONObject;
  LArticle: IiPoolArticle;
  i: integer;
begin
  LPreferences := TConverterToPrefrences.Convert(AData);
  iPoolConnector := TSAIDiPoolConnector.Create;
  LiPoolArticles := iPoolConnector.GetArticles(LPreferences);
  FreeAndNil(iPoolConnector);
  Result := TJSONObject.Create;
  LArr := TJSONArray.Create;
  Result.AddPair('lolbjects',LArr);
  for i:=0 to LiPoolArticles.Count-1 do
  begin
    LArticle := LiPoolArticles.Articles[i];
    LObj := TJSONObject.Create;
    LObj.AddPair('heading',LArticle.Heading);
    LObj.AddPair('content',LArticle.Content);
    LObj.AddPair('publisher',LArticle.Publisher);
    LArr.AddElement(LObj);
  end;
end;

{ TConverterToPrefrences }

class function TConverterToPrefrences.Convert(AData: TJSONObject): IPreferences;
var
  LPreferenceJSONArr: TJSONArray;
  LPreferenceJSONStr: TJSONString;
  i: integer;
  LPreferences: TStringList;
begin
  LPreferences := TStringList.Create;
  LPreferenceJSONArr := AData.GetValue('preferences') as TJSONArray;
  for i := 0 to LPreferenceJSONArr.Count - 1 do
  begin
    LPreferenceJSONStr := LPreferenceJSONArr.Items[i] as TJSONString;
    LPreferences.Add(LPreferenceJSONStr.Value);
  end;
  Result := TSAIDPreferences.Create(LPreferences);
end;

{ TSAIDPreferences }

constructor TSAIDPreferences.Create(APref: TStringList);
begin
  FPreferences := APref;
end;

destructor TSAIDPreferences.Destroy;
begin
  FreeAndNil(FPreferences);
  inherited;
end;

function TSAIDPreferences.GetAllPreferences: TStringList;
begin
  Result := FPreferences;
end;

function TSAIDPreferences.GetFavourable(const AKeyword: String): Boolean;
begin
  Result := FPreferences.IndexOf(AKeyword) <> -1;
end;

function TSAIDPreferences.GetUnfavourable(const AKeyword: String): Boolean;
begin
  Result := not GetFavourable(AKeyword);
end;

initialization

TMARSResourceRegistry.Instance.RegisterResource<TSAIDResource>;

end.
