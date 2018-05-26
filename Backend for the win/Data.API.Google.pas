unit Data.API.Google;

interface

uses
  System.StrUtils;

type
  TTextType = (ttPlainText);

  TTextTypeHelper = record helper for TTextType
    constructor Create(const ATextTypeCode: String);
    function ToString: String;
  end;

  TQuery = record
  private
    FText: String;
    FTextType: TTextType;
  public
    property Text: String read FText;
    property TextType: TTextType read FTextType default ttPlainText;
    constructor Create(const AText: String;
      const ATextType: TTextType = ttPlainText);
  end;

  TToken = record

  end;

  TResponse = record
  private
    FTokens: TArray<TToken>;
  public
    property Tokens: TArray<TToken> read FTokens;
    constructor Create(const ATokens: TArray<TToken>);
  end;

  IGoogleCloudAPI = interface
    property Query[const AQuery: TQuery]: TResponse;
  end;

implementation

{ TTextTypeHelper }

constructor TTextTypeHelper.Create(const ATextTypeCode: String);
begin
  Self := TTextType(IndexText(ATextTypeCode, ['PLAIN_TEXT']));
end;

function TTextTypeHelper.ToString: String;
begin
  case Self of
    ttPlainText:
      Result := 'PLAIN_TEXT';
  end;
end;

{ TQuery }

constructor TQuery.Create(const AText: String; const ATextType: TTextType);
begin
  FText := AText;
  FTextType := ATextType;
end;

end.
