unit Data.API.Google;

interface

uses
  System.StrUtils;

type
  TTextType = (ttPLAINTEXT);

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

  TNumber = (nuUNKNOWN, nuSINGULAR, nuPLURAL);

  TNumberHelper = record helper for TNumber
    constructor Create(const ANumberCode: String);
    function ToString: String;
  end;

  TTense = (teUNKNOWN, tePRESENT);

  TTenseHelper = record helper for TTense
    constructor Create(const ATenseCode: String);
    function ToString: String;
  end;

  TPerson = (peUNKNOWN, peFIRST, peSECOND, peTHIRD);

  TPersonHelper = record helper for TPerson
    constructor Create(const APersonCode: String);
    function ToString: String;
  end;

  TGender = (geUNKNOWN, geMASCULINE, geFEMININE, geNEUTER);

  TGenderHelper = record helper for TGender
    constructor Create(const AGenderCode: String);
    function ToString: String;
  end;

  TCase = (csUNKNOWN, csAKKUSATIVE, csDATIVE, csGENITIVE, csNOMINATIVE);

  TCaseHelper = record helper for TCase
    constructor Create(const ACaseCode: String);
    function ToString: String;
  end;

  IToken = interface
    ['{853F36B0-8698-4A7A-8DEB-0036A4F9BFAB}']
    function GetText: String;
    function GetOffset: Integer;
    function GetLemma: String;
    function GetTag: TTag;
    function GetLabel: TLabel;
    function GetNumber: TNumber;
    function GetTense: TTense;
    function GetPerson: TPerson;
    function GetGender: TGender;
    function GetCase: TCase;
    function GetDependency: IToken;
    property Text: String read GetText;
    property Offset: Integer read GetOffset;
    property Lemma: String read GetLemma;
    property Tag: TTag read GetTag;
    property &Label: TLabel read GetLabel;
    property Number: TNumber read GetNumber;
    property Tense: TTense read GetTense;
    property Person: TPerson read GetPerson;
    property Gender: TGender read GetGender;
    property &Case: TCase read GetCase;
    property Dependency: IToken read GetDependency;
  end;

  ISentence = interface
    ['{FE12CEDF-AB5F-430A-979B-3DC5ED37FE43}']
    function GetOffset: Integer;
    function GetTokens(const AIndex: Integer): IToken;
    function GetTokenCount: Integer;
    property Offset: Integer read GetOffset;
    property Tokens[const AIndex: Integer]: IToken read GetTokens;
    property TokenCount: Integer read GetTokenCount;
  end;

  IResponse = interface
    ['{43A760A4-A572-484D-8425-954D62D34228}']
    function GetSentences(const AIndex: Integer): ISentence;
    function GetSentenceCount: Integer;
    property Sentences[const AIndex: Integer]: ISentence read GetSentences;
    property SentenceCount: Integer read GetSentenceCount;
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
    ttPLAINTEXT:
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

{ TNumberHelper }

constructor TNumberHelper.Create(const ANumberCode: String);
begin
  Self := TNumber(IndexText(ANumberCode, ['NUMBER_UNKNOWN', 'SINGULAR',
    'PLURAL']));
end;

function TNumberHelper.ToString: String;
begin
  case Self of
    nuUNKNOWN:
      Result := 'NUMBER_UNKNOWN';
    nuSINGULAR:
      Result := 'SINGULAR';
    nuPLURAL:
      Result := 'PLURAL';
  end;
end;

{ TTenseHelper }

constructor TTenseHelper.Create(const ATenseCode: String);
begin
  Self := TTense(IndexText(ATenseCode, ['TENSE_UNKNOWN', 'PRESENT']));
end;

function TTenseHelper.ToString: String;
begin
  case Self of
    teUNKNOWN:
      Result := 'TENSE_UNKNOWN';
    tePRESENT:
      Result := 'PRESENT';
  end;
end;

{ TPersonHelper }

constructor TPersonHelper.Create(const APersonCode: String);
begin
  Self := TPerson(IndexText(APersonCode, ['PERSON_UNKNOWN', 'FIRST', 'SECOND',
    'THIRD']));
end;

function TPersonHelper.ToString: String;
begin
  case Self of
    peUNKNOWN:
      Result := 'PERSON_UNKNOWN';
    peFIRST:
      Result := 'FIRST';
    peSECOND:
      Result := 'SECOND';
    peTHIRD:
      Result := 'THIRD';
  end;
end;

{ TGenderHelper }

constructor TGenderHelper.Create(const AGenderCode: String);
begin
  Self := TGender(IndexText(AGenderCode, ['GENDER_UNKNOWN', 'MASCULINE',
    'FEMININE', 'NEUTER']));
end;

function TGenderHelper.ToString: String;
begin
  case Self of
    geUNKNOWN:
      Result := 'GENDER_UNKNOWN';
    geMASCULINE:
      Result := 'MASCULINE';
    geFEMININE:
      Result := 'FEMININE';
    geNEUTER:
      Result := 'NEUTER';
  end;
end;

{ TCaseHelper }

constructor TCaseHelper.Create(const ACaseCode: String);
begin
  Self := TCase(IndexText(ACaseCode, ['CASE_UNKNOWN', 'AKKUSATIVE', 'DATIVE',
    'GENITIVE', 'NOMINATIVE']));
end;

function TCaseHelper.ToString: String;
begin
  case Self of
    csUNKNOWN:
      Result := 'CASE_UNKNOWN';
    csAKKUSATIVE:
      Result := 'AKKUSATIVE';
    csDATIVE:
      Result := 'DATIVE';
    csGENITIVE:
      Result := 'GENITIVE';
    csNOMINATIVE:
      Result := 'NOMINATIVE';
  end;
end;

end.
