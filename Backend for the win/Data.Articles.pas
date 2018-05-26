unit Data.Articles;

interface

uses
  System.StrUtils, System.Math;

type
  TSource = (scDPA);

  TSourceHelper = record helper for TSource
    constructor Create(const ASourceCode: String);
    function ToString: String;
  end;

  TLanguage = (laEN, laDE);

  TLanguageHelper = record helper for TLanguage
    constructor Create(const ALanguageCode: String);
    function ToString: String;
  end;

  TSentiment = (seNegative = -1, seNeutral = 0, sePositive = 1);

  TSentimentHelper = record helper for TSentiment
    constructor Create(const ASentimentAmount: Double);
    function ToDouble: Double;
  end;

  ICategory = interface
    ['{7306F1EE-9108-4FD6-8A44-69E75E9E1EAE}']
    function GetName: String;
    function GetParent: ICategory;
    property Name: String read GetName;
    property Parent: ICategory read GetParent;
  end;

  IGoogleArticle = interface
    ['{0C06D550-31BB-45C2-A5A1-F9DE920C089F}']
    function GetCaption: String;
    function GetSource: TSource;
    function GetLanguage: TLanguage;
    function GetSentiment: TSentiment;
    function GetCategories(const AIndex: Integer): ICategory;
    function GetCategoryCount: Integer;
    property Caption: String read GetCaption;
    property Source: TSource read GetSource;
    property Language: TLanguage read GetLanguage;
    property Sentiment: TSentiment read GetSentiment;
    property Categories[const AIndex: Integer]: ICategory read GetCategories;
    property CategoryCount: Integer read GetCategoryCount;
  end;

  IGoogleArticles = interface
    ['{F56CB0F1-9D1B-4CB2-8C91-9FB24F1E1EE9}']
    function GetArticles(const AIndex: Integer): IGoogleArticle;
    function GetCount: Integer;
    property Articles[const AIndex: Integer]: IGoogleArticle read GetArticles;
    property Count: Integer read GetCount;
  end;

  IiPoolArticle = interface
    ['{07129344-C577-499D-BAFD-031052A6633F}']
    function GetHeading: String;
    function GetContent: String;
    function GetPublisher: String;
    property Heading: String read GetHeading;
    property Content: String read GetContent;
    property Publisher: String read GetPublisher;
  end;

  IiPoolArticles = interface
    ['{F56CB0F1-9D1B-4CB2-8C91-9FB24F1E1EE9}']
    function GetArticles(const AIndex: Integer): IiPoolArticle;
    function GetCount: Integer;
    property Articles[const AIndex: Integer]: IiPoolArticle read GetArticles;
    property Count: Integer read GetCount;
  end;

implementation

{ TSourceHelper }

constructor TSourceHelper.Create(const ASourceCode: String);
begin
  Self := TSource(IndexText(ASourceCode, ['DPA']));
end;

function TSourceHelper.ToString: String;
begin
  case Self of
    scDPA:
      Result := 'DPA';
  end;
end;

{ TLanguageHelper }

constructor TLanguageHelper.Create(const ALanguageCode: String);
begin
  Self := TLanguage(IndexText(ALanguageCode, ['en', 'de']));
end;

function TLanguageHelper.ToString: String;
begin
  case Self of
    laEN:
      Result := 'en';
    laDE:
      Result := 'de';
  end;
end;

{ TSentimentHelper }

constructor TSentimentHelper.Create(const ASentimentAmount: Double);
begin
  Self := TSentiment(Sign(ASentimentAmount));
end;

function TSentimentHelper.ToDouble: Double;
begin
  Result := Ord(Self);
end;

end.
