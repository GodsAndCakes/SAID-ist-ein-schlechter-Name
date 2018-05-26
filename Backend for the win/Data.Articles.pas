unit Data.Articles;

interface

uses
  System.StrUtils;

type
  TSource = (scDPA);

  TSourceHelper = record helper for TSource
    constructor Create(const ASourceCode: String);
    function ToString: String;
  end;

  TLanguage = (laENG, laGER);

  TLanguageHelper = record helper for TLanguage
    constructor Create(const ALanguageCode: String);
    function ToString: String;
  end;

  IArticle = interface
    ['{0C06D550-31BB-45C2-A5A1-F9DE920C089F}']
    function GetText: String;
    function GetSource: TSource;
    function GetLanguage: TLanguage;
    property Text: String read GetText;
    property Source: TSource read GetSource;
    property Language: TLanguage read GetLanguage;
  end;

  IArticles = interface
    ['{F56CB0F1-9D1B-4CB2-8C91-9FB24F1E1EE9}']
    function GetArticles(const AIndex: Integer): IArticle;
    function GetCount: Integer;
    property Articles[const AIndex: Integer]: IArticle read GetArticles;
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
  Self := TLanguage(IndexText(ALanguageCode, ['ENG', 'GER']));
end;

function TLanguageHelper.ToString: String;
begin
  case Self of
    laENG:
      Result := 'ENG';
    laGER:
      Result := 'GER';
  end;
end;

end.
