unit Core.Articles.Gen;

interface

uses
  System.SysUtils, System.Classes, Data.API.Google;

type
  IArticle = interface
    ['{C81436AF-BC56-45BC-910F-ECCDE35B32E6}']
    function GetCaption: String;
    function GetText: String;
    function GetCategories(const AIndex: Integer): String;
    function GetCategoryCount: Integer;
    property Caption: String read GetCaption;
    property Text: String read GetCaption;
    property Categories[const AIndex: Integer]: String read GetCategories;
    property CategoryCount: Integer read GetCategoryCount;
  end;

  TArticle = class(TInterfacedObject, IArticle)
  private
    FCaption: String;
    FText: String;
    FCategories: TStrings;
    function GetCaption: String;
    function GetText: String;
    function GetCategories(const AIndex: Integer): String;
    function GetCategoryCount: Integer;
  protected
    procedure LoadFromGoogleArticle(const AGoogleArticle: IGoogleArticle);
  public
    constructor Create(const AGoogleArticle: IGoogleArticle);
    destructor Destroy; override;
  end;

implementation

{ TArticle }

constructor TArticle.Create(const AGoogleArticle: IGoogleArticle);
begin
  inherited Create;
  FCategories := TStringList.Create;
  LoadFromGoogleArticle(AGoogleArticle);
end;

destructor TArticle.Destroy;
begin
  FCategories.Free;
  inherited;
end;

function TArticle.GetCaption: String;
begin
  Result := FCaption;
end;

function TArticle.GetCategories(const AIndex: Integer): String;
begin
  Result := FCategories[AIndex];
end;

function TArticle.GetCategoryCount: Integer;
begin
  Result := FCategories.Count;
end;

function TArticle.GetText: String;
begin
  Result := FText;
end;

procedure TArticle.LoadFromGoogleArticle(const AGoogleArticle: IGoogleArticle);
var
  Article: IGoogleArticle absolute AGoogleArticle;
  Index: Integer;

  function FindTokens(const ADependency: IToken; const ALabel: TLabel)
    : TArray<IToken>;
  var
    TokenIndex: Integer;
  begin
    for TokenIndex := 0 to Pred(Article.Sentences[Index].TokenCount) do
    begin
      if (Article.Sentences[Index].Tokens[TokenIndex].Dependency = ADependency)
        and (Article.Sentences[Index].Tokens[TokenIndex].&Label = ALabel) then
      begin
        Result := Concat(Result, [Article.Sentences[Index].Tokens[TokenIndex]]);
      end;
    end;
  end;

  function Build(const ATokens: TArray<IToken>): String;
  var
    Current: IToken;
  begin
    for Current in ATokens do
    begin
      case Current.&Label of
        laNSUBJ,
        laDOBJ,
        laPOBJ,
        laATTR:
          // Articles + Adverbs
          Result := Concat(Build(FindTokens(Current, laDET)),
            Build(FindTokens(Current, laAMOD)), Current.Text);
        laROOT:
          // Subjects + Adverbs + D.Objects + Attribs + Punctations
          Result := Concat(Build(FindTokens(Current, laNSUBJ)),
            Build(FindTokens(Current, laADVMOD)), Current.Text,
            Build(FindTokens(Current, laDOBJ)),
            Build(FindTokens(Current, laATTR)),
            Build(FindTokens(Current, laP)));
        laPREP:
          // P.Objects
          Result := Concat(Current.Text, Build(FindTokens(Current, laPOBJ)));
        laP,
        laDET,
        laADVMOD:
          Result := Current.Text;
        laAMOD:
          // Adverbs
          Result := Concat(Build(FindTokens(Current, laADVMOD)), Current.Text);
      end;
    end;
    if not Result.IsEmpty then
    begin
      Result := Concat(Result, ' ');
    end;
  end;

var
  Category: TArray<String>;
begin
  FCaption := Article.Caption;
  for Index := 0 to Pred(Article.CategoryCount) do
  begin
    Category := Article.Categories[Index].Split(['/'], '"');
    FCategories.Add(Category[Low(Category)]);
  end;
  for Index := 0 to Pred(Article.SentenceCount) do
  begin
    FText := Concat(FText, Build(FindTokens(nil, laROOT)));
  end;
  FText[Low(FText)] := UpCase(FText[Low(FText)]);
end;

end.
