unit Core.Articles.Gen;

interface

uses
  System.Classes, Data.Articles;

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

end.
