unit Backend.iPool.Connector;

interface

uses
  System.JSON,
  System.Generics.Collections,
  System.SysUtils,

  Backend.iPool.DM,

  Data.Articles,
  Data.User.Preferences;

type

  TSAIDiPoolArticle = class(TInterfacedObject, IiPoolArticle)
  private
    FContent: string;
    FHeading: string;
    FPublisher: string;
  public
    constructor Create(AContent: string; AHeading: string; APublisher: string);
    function GetContent: string;
    function GetHeading: string;
    function GetPublisher: string;
    property Heading: string read GetHeading;
    property Content: string read GetContent;
    property Publisher: string read GetPublisher;
  end;

  TSAIDiPoolArticles = class(TInterfacedObject, IiPoolArticles)
  private
    FArticles: TList<IiPoolArticle>;
  public
    constructor Create(AArticles: TList<IiPoolArticle>);
    function GetArticles(const AIndex: Integer): IiPoolArticle;
    function GetCount: Integer;
    property Articles[const AIndex: Integer]: IiPoolArticle read GetArticles;
    property Count: Integer read GetCount;
    destructor Destroy; override;
  end;

  TSAIDiPoolConnector = class
    function GetArticles(APreferences: IPreferences): IiPoolArticles;
  end;

implementation

{ TSAIDiPoolConnector }

function TSAIDiPoolConnector.GetArticles(APreferences: IPreferences)
  : IiPoolArticles;
var
  LJSONResponse, LJSONDocEntry: TJSONObject;
  LDocuments: TJSONArray;
  LPreferences: IPreferences;
  LPublisherStr, LHeadingStr, LContentStr: string;
  i: Integer;
  LArticles: TList<IiPoolArticle>;
begin
  LJSONResponse := DoRequestiPool(APreferences);
  LArticles := TList<IiPoolArticle>.Create;
  LDocuments := LJSONResponse.Values['documents'] as TJSONArray;
  for i := 0 to LDocuments.Count - 1 do
  begin
    LJSONDocEntry := LDocuments.Items[i] as TJSONObject;
    LPublisherStr := (LJSONDocEntry.Values['publisher'] as TJSONString).Value;
    LHeadingStr := (LJSONDocEntry.Values['title'] as TJSONString).Value;
    LContentStr := (LJSONDocEntry.Values['content'] as TJSONString).Value;
    LArticles.Add(TSAIDiPoolArticle.Create(LContentStr, LHeadingStr,
      LPublisherStr));
  end;
  Result := TSAIDiPoolArticles.Create(LArticles);
end;

{ TSAIDiPoolArticle }

constructor TSAIDiPoolArticle.Create(AContent, AHeading, APublisher: string);
begin
  FContent := AContent;
  FHeading := AHeading;
  FPublisher := APublisher;
end;

function TSAIDiPoolArticle.GetContent: string;
begin
  Result := FContent;
end;

function TSAIDiPoolArticle.GetHeading: string;
begin
  Result := FHeading;
end;

function TSAIDiPoolArticle.GetPublisher: string;
begin
  Result := FPublisher;
end;

{ TSAIDiPoolArticles }

constructor TSAIDiPoolArticles.Create(AArticles: TList<IiPoolArticle>);
begin
  FArticles := AArticles;
end;

destructor TSAIDiPoolArticles.Destroy;
begin
  FreeAndNil(FArticles);
  inherited;
end;

function TSAIDiPoolArticles.GetArticles(const AIndex: Integer): IiPoolArticle;
begin
  Result := FArticles.Items[AIndex];
end;

function TSAIDiPoolArticles.GetCount: Integer;
begin
  Result := FArticles.Count;
end;

end.
