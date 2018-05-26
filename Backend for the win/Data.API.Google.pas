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

  IQuery = interface
    ['{9DD2DF53-37BB-46BE-B91A-56613FA5132C}']
    function GetText: String;
    function GetTextType: TTextType;
    property Text: String read GetText;
    property TextType: TTextType read GetTextType;
  end;

  TTag = (taNOUN, taVERB, taPRON, taPRT, taPUNCT, taDET, taADJ, taADV);

  TTagHelper = record helper for TTag
    constructor Create(const ATagCode: String);
    function ToString: String;
  end;

  TLabel = (laNSUBJ, taDOBJ, taROOT, laP, laDET, laAMOD, laADVMOD);

  TLabelHelper = record helper for TLabel
    constructor Create(const ALabelCode: String);
    function ToString: String;
  end;

  IToken = interface
    ['{853F36B0-8698-4A7A-8DEB-0036A4F9BFAB}']
    function GetLemma: String;
    function GetTag: TTag;
    function GetDependencies(const AIndex: Integer): IToken;
    property Lemma: String read GetLemma;
    property Tag: TTag read GetTag;
    property Dependencies[const AIndex: Integer]: IToken read GetDependencies;
  end;

  IResponse = interface
    ['{FE12CEDF-AB5F-430A-979B-3DC5ED37FE43}']
    function GetTokens(const AIndex: Integer): IToken;
    property Tokens[const AIndex: Integer]: IToken read GetTokens;
  end;

  IGoogleCloudAPI = interface
    ['{D5EFA4BC-47A7-4117-B7A6-C3C60238662D}']
    function GetQuery(const AQuery: IQuery): IResponse;
    property Query[const AQuery: IQuery]: IResponse read GetQuery;
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

{ TTagHelper }

constructor TTagHelper.Create(const ATagCode: String);
begin
  Self := TTag(IndexText(ATagCode, ['NOUN', 'VERB', 'PRON', 'PRT', 'PUNCT',
    'DET', 'ADJ', 'ADV']));
end;

function TTagHelper.ToString: String;
begin
  case Self of
    taNOUN:
      Result := 'NOUN';
    taVERB:
      Result := 'VERB';
    taPRON:
      Result := 'PRON';
    taPRT:
      Result := 'PRT';
    taPUNCT:
      Result := 'PUNCT';
    taDET:
      Result := 'DET';
    taADJ:
      Result := 'ADJ';
    taADV:
      Result := 'ADV';
  end;
end;

{ TLabelHelper }

constructor TLabelHelper.Create(const ALabelCode: String);
begin
  Self := TLabel(IndexText(ALabelCode, ['NSUBJ', 'DOBJ', 'ROOT', 'P', 'DET',
    'AMOD', 'ADVMOD']));
end;

function TLabelHelper.ToString: String;
begin
  case Self of
    laNSUBJ:
      Result := 'NSUBJ';
    taDOBJ:
      Result := 'DOBJ';
    taROOT:
      Result := 'ROOT';
    laP:
      Result := 'P';
    laDET:
      Result := 'DET';
    laAMOD:
      Result := 'AMOD';
    laADVMOD:
      Result := 'ADVMOD';
  end;
end;

end.
