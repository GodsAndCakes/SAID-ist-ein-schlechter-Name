(*
  Copyright 2016, MARS-Curiosity library

  Home: https://github.com/andrea-magni/MARS
*)
unit MARS.Core.MessageBodyReaders;

{$I MARS.inc}

interface

uses
  Classes, SysUtils, Rtti

  , MARS.Core.Attributes
  , MARS.Core.Activation.Interfaces
  , MARS.Core.Declarations
  , MARS.Core.MediaType
  , MARS.Core.MessageBodyReader
  ;

type
  [Consumes(TMediaType.APPLICATION_JSON)]
  TObjectReader = class(TInterfacedObject, IMessageBodyReader)
  public
    function ReadFrom(
    {$ifdef Delphi10Berlin_UP}const AInputData: TBytes;{$else}const AInputData: AnsiString;{$endif}
      const ADestination: TRttiObject; const AMediaType: TMediaType;
      const AActivation: IMARSActivation
    ): TValue; virtual;
  end;

  [Consumes(TMediaType.APPLICATION_JSON)]
  TArrayOfObjectReader = class(TInterfacedObject, IMessageBodyReader)
  public
    function ReadFrom(
    {$ifdef Delphi10Berlin_UP}const AInputData: TBytes;{$else}const AInputData: AnsiString;{$endif}
      const ADestination: TRttiObject; const AMediaType: TMediaType;
      const AActivation: IMARSActivation
    ): TValue; virtual;
  end;


  [Consumes(TMediaType.APPLICATION_JSON)]
  TJSONValueReader = class(TInterfacedObject, IMessageBodyReader)
  public
    function ReadFrom(
    {$ifdef Delphi10Berlin_UP}const AInputData: TBytes;{$else}const AInputData: AnsiString;{$endif}
      const ADestination: TRttiObject; const AMediaType: TMediaType;
      const AActivation: IMARSActivation
    ): TValue; virtual;

    class function ReadJSONValue(
      {$ifdef Delphi10Berlin_UP}const AInputData: TBytes;{$else}const AInputData: AnsiString;{$endif}
      const ADestination: TRttiObject; const AMediaType: TMediaType;
      const AActivation: IMARSActivation
    ): TValue;

  end;

  [Consumes(TMediaType.APPLICATION_JSON)
 , Consumes(TMediaType.APPLICATION_FORM_URLENCODED_TYPE)
 , Consumes(TMediaType.MULTIPART_FORM_DATA)
  ]
  TRecordReader = class(TInterfacedObject, IMessageBodyReader)
  public
    function ReadFrom(
    {$ifdef Delphi10Berlin_UP}const AInputData: TBytes;{$else}const AInputData: AnsiString;{$endif}
      const ADestination: TRttiObject; const AMediaType: TMediaType;
      const AActivation: IMARSActivation
    ): TValue; virtual;
  end;

  [Consumes(TMediaType.APPLICATION_JSON)]
  TArrayOfRecordReader = class(TInterfacedObject, IMessageBodyReader)
  public
    function ReadFrom(
    {$ifdef Delphi10Berlin_UP}const AInputData: TBytes;{$else}const AInputData: AnsiString;{$endif}
      const ADestination: TRttiObject; const AMediaType: TMediaType;
      const AActivation: IMARSActivation
    ): TValue; virtual;
  end;

  [Consumes(TMediaType.APPLICATION_OCTET_STREAM), Consumes(TMediaType.WILDCARD)]
  TStreamReader = class(TInterfacedObject, IMessageBodyReader)
  public
    function ReadFrom(
    {$ifdef Delphi10Berlin_UP}const AInputData: TBytes;{$else}const AInputData: AnsiString;{$endif}
      const ADestination: TRttiObject; const AMediaType: TMediaType;
      const AActivation: IMARSActivation
    ): TValue; virtual;
  end;

  [Consumes(TMediaType.TEXT_PLAIN)]
  TStringReader = class(TInterfacedObject, IMessageBodyReader)
  public
    function ReadFrom(
    {$ifdef Delphi10Berlin_UP}const AInputData: TBytes;{$else}const AInputData: AnsiString;{$endif}
      const ADestination: TRttiObject; const AMediaType: TMediaType;
      const AActivation: IMARSActivation
    ): TValue; virtual;
  end;

  [Consumes(TMediaType.APPLICATION_FORM_URLENCODED_TYPE)
 , Consumes(TMediaType.MULTIPART_FORM_DATA)
  ]
  TFormParamReader = class(TInterfacedObject, IMessageBodyReader)
  public
    function ReadFrom(
    {$ifdef Delphi10Berlin_UP}const AInputData: TBytes;{$else}const AInputData: AnsiString;{$endif}
      const ADestination: TRttiObject; const AMediaType: TMediaType;
      const AActivation: IMARSActivation
    ): TValue; virtual;
  end;

  [Consumes(TMediaType.APPLICATION_FORM_URLENCODED_TYPE)
 , Consumes(TMediaType.MULTIPART_FORM_DATA)
  ]
  TArrayOfTFormParamReader = class(TInterfacedObject, IMessageBodyReader)
  public
    function ReadFrom(
    {$ifdef Delphi10Berlin_UP}const AInputData: TBytes;{$else}const AInputData: AnsiString;{$endif}
      const ADestination: TRttiObject; const AMediaType: TMediaType;
      const AActivation: IMARSActivation
    ): TValue; virtual;
  end;


implementation

uses
  StrUtils, NetEncoding, Web.HttpApp
  , MARS.Core.JSON
  , MARS.Core.Utils, MARS.Rtti.Utils
  {$ifdef DelphiXE7_UP}, System.JSON {$endif}
  ;

{ TJSONValueReader }


function TJSONValueReader.ReadFrom(
{$ifdef Delphi10Berlin_UP}const AInputData: TBytes;{$else}const AInputData: AnsiString;{$endif}
  const ADestination: TRttiObject; const AMediaType: TMediaType;
  const AActivation: IMARSActivation
): TValue;
var
  LJSONValue: TJSONValue;
begin
  Result := TValue.Empty;

{$ifdef Delphi10Berlin_UP}
  LJSONValue := TJSONObject.ParseJSONValue(AInputData, 0);
{$else}
  LJSONValue := TJSONObject.ParseJSONValue(string(AInputData));
{$endif}
  if Assigned(LJSONValue) then
    Result := LJSONValue;
end;

class function TJSONValueReader.ReadJSONValue(
  {$ifdef Delphi10Berlin_UP}const AInputData: TBytes;{$else}const AInputData: AnsiString;{$endif}
  const ADestination: TRttiObject; const AMediaType: TMediaType;
  const AActivation: IMARSActivation): TValue;
var
  LJSONReader: TJSONValueReader;
begin
  LJSONReader := TJSONValueReader.Create;
  try
    Result := LJSONReader.ReadFrom(AInputData, ADestination, AMediaType, AActivation);
  finally
    LJSONReader.Free;
  end;
end;

{ TStreamReader }

function TStreamReader.ReadFrom(
{$ifdef Delphi10Berlin_UP}const AInputData: TBytes;{$else}const AInputData: AnsiString;{$endif}
  const ADestination: TRttiObject; const AMediaType: TMediaType;
  const AActivation: IMARSActivation
): TValue;
var
  LStream: TStream;
begin
{$ifdef Delphi10Berlin_UP}
  LStream := TBytesStream.Create(AInputData);
{$else}
  LStream := TStringStream.Create(AInputData);
{$endif}
  try
    LStream.Position := 0;
    Result := LStream;
  except
    LStream.Free;
    raise;
  end;
end;

{ TRecordReader }

function TRecordReader.ReadFrom(
{$ifdef Delphi10Berlin_UP}const AInputData: TBytes;{$else}const AInputData: AnsiString;{$endif}
  const ADestination: TRttiObject; const AMediaType: TMediaType;
  const AActivation: IMARSActivation
): TValue;
var
  LJSON: TJSONObject;
  LRequest: TWebRequest;
begin
  Result := TValue.Empty;

  if AMediaType.Matches(TMediaType.APPLICATION_FORM_URLENCODED_TYPE)
    or AMediaType.Matches(TMediaType.MULTIPART_FORM_DATA)
  then
  begin
    LRequest := AActivation.Request;
    Result := StringsToRecord(LRequest.ContentFields, ADestination.GetRttiType
    , procedure (const AName: string; const AField: TRttiField; var AValue: TValue)
      begin
        if AField.FieldType.Handle = TypeInfo(TFormParamFile) then
          AValue := TValue.From<TFormParamFile>(
            TFormParamFile.CreateFromRequest(LRequest, AName)
          );
      end
    );
  end
  else
  begin
    LJSON := TJSONValueReader.ReadJSONValue(
      AInputData, ADestination, AMediaType, AActivation).AsType<TJSONObject>;
    if Assigned(LJSON) then
      try
        Result := LJSON.ToRecord(ADestination.GetRttiType);
      finally
        LJSON.Free;
      end;
  end;
end;

{ TObjectReader }

function TObjectReader.ReadFrom(
{$ifdef Delphi10Berlin_UP}const AInputData: TBytes;{$else}const AInputData: AnsiString;{$endif}
  const ADestination: TRttiObject; const AMediaType: TMediaType;
  const AActivation: IMARSActivation): TValue;
var
  LJSON: TJSONValue;
begin
  Result := TValue.Empty;

  LJSON := TJSONValueReader.ReadJSONValue(
    AInputData, ADestination, AMediaType, AActivation).AsType<TJSONValue>;
  if Assigned(LJSON) then
    try
      if (LJSON is TJSONObject) and (ADestination.GetRttiType is TRttiInstanceType) then
        Result := TJSONObject.JSONToObject(
            TRttiInstanceType(ADestination.GetRttiType).MetaclassType
          , TJSONObject(LJSON)
        );
    finally
      LJSON.Free;
    end;
end;


{ TArrayOfObjectReader }

function TArrayOfObjectReader.ReadFrom(
{$ifdef Delphi10Berlin_UP}const AInputData: TBytes;{$else}const AInputData: AnsiString;{$endif}
  const ADestination: TRttiObject; const AMediaType: TMediaType;
  const AActivation: IMARSActivation): TValue;
var
  LJSONArray: TJSONArray;
  LJSONValue: TJSONValue;
  LJSONObject: TJSONObject;
  LElementType: TRttiType;
  LArray: TValue;
  LArrayType: TRttiType;
  LIndex: Integer;
begin
  Result := TValue.Empty;
  LArrayType := ADestination.GetRttiType;
  LElementType := LArrayType.GetArrayElementType;
  if not Assigned(LElementType) then
    Exit;

  if not (LElementType is TRttiInstanceType) then
    Exit;

  LJSONValue := TJSONValueReader.ReadJSONValue(
    AInputData, ADestination, AMediaType, AActivation).AsType<TJSONValue>;
  if Assigned(LJSONValue) then
    try
      TValue.Make(nil, LArrayType.Handle, LArray);
      if LJSONValue is TJSONArray then
      begin
        LJSONArray := TJSONArray(LJSONValue);

        SetArrayLength(LArray, LArrayType, LJSONArray.Count);
        for LIndex := 0 to LJSONArray.Count-1 do //AM Refactor using ForEach<TJSONObject>
        begin
          LJSONObject := LJSONArray.Items[LIndex] as TJSONObject;
          if Assigned(LJSONObject) then
            LArray.SetArrayElement(
                LIndex
              , TJSONObject.JSONToObject(
                  TRttiInstanceType(LElementType).MetaclassType
                , LJSONObject
              )
            );
        end;
      end
      else if LJSONValue is TJSONObject then // a single obj, let's build an array of one element
      begin
        SetArrayLength(LArray, LArrayType, 1);
        LArray.SetArrayElement(
            0
          , TJSONObject.JSONToObject(
                TRttiInstanceType(LElementType).MetaclassType
              , TJSONObject(LJSONValue)
            )
        );
      end;

      Result := LArray;
    finally
      LJSONValue.Free;
    end;
end;


{ TArrayOfRecordReader }

function TArrayOfRecordReader.ReadFrom(
{$ifdef Delphi10Berlin_UP}const AInputData: TBytes;{$else}const AInputData: AnsiString;{$endif}
  const ADestination: TRttiObject; const AMediaType: TMediaType;
  const AActivation: IMARSActivation
): TValue;
var
  LJSONArray: TJSONArray;
  LJSONValue: TJSONValue;
  LJSONObject: TJSONObject;
  LElementType: TRttiType;
  LArray: TValue;
  LArrayType: TRttiType;
  LIndex: Integer;
begin
  Result := TValue.Empty;
  LArrayType := ADestination.GetRttiType;
  LElementType := LArrayType.GetArrayElementType;
  if not Assigned(LElementType) then
    Exit;

  LJSONValue := TJSONValueReader.ReadJSONValue(
    AInputData, ADestination, AMediaType, AActivation).AsType<TJSONValue>;
  if Assigned(LJSONValue) then
    try
      TValue.Make(nil, LArrayType.Handle, LArray);
      if LJSONValue is TJSONArray then
      begin
        LJSONArray := TJSONArray(LJSONValue);

        SetArrayLength(LArray, LArrayType, LJSONArray.Count);
        for LIndex := 0 to LJSONArray.Count-1 do //AM Refactor using ForEach<TJSONObject>
        begin
          LJSONObject := LJSONArray.Items[LIndex] as TJSONObject;
          if Assigned(LJSONObject) then
            LArray.SetArrayElement(LIndex, LJSONObject.ToRecord(LElementType));
        end;
      end
      else if LJSONValue is TJSONObject then // a single obj, let's build an array of one element
      begin
        SetArrayLength(LArray, LArrayType, 1);
        LArray.SetArrayElement(0, TJSONObject(LJSONValue).ToRecord(LElementType));
      end;

      Result := LArray;
    finally
      LJSONValue.Free;
    end;
end;

{ TStringReader }

function TStringReader.ReadFrom(
  {$ifdef Delphi10Berlin_UP}const AInputData: TBytes;{$else}const AInputData: AnsiString;{$endif}
  const ADestination: TRttiObject; const AMediaType: TMediaType;
  const AActivation: IMARSActivation): TValue;
var
  LType: TRttiType;
  LSL: TStringList;
  {$ifdef Delphi10Berlin_UP}
  LBytesStream: TBytesStream;
  {$endif}
begin
  Result := TValue.Empty;
  LType := ADestination.GetRttiType;

  {$ifdef Delphi10Berlin_UP}
  LBytesStream := TBytesStream.Create(AInputData);
  try
    LSL := TStringList.Create;
    try
      LSL.LoadFromStream(LBytesStream);
      if LType.IsDynamicArrayOf<string> then
        Result := TValue.From<TArray<string>>( LSL.ToStringArray )
      else if LType.Handle = TypeInfo(string) then
        Result := LSL.Text;
    finally
      LSL.Free;
    end;
  finally
    LBytesStream.Free;
  end;
  {$else}
  LSL := TStringList.Create;
  try
    LSL.Text := string(AInputData);
    if LType.IsDynamicArrayOf<string> then
      Result := TValue.From<TArray<string>>( LSL.ToStringArray )
    else if LType.Handle = TypeInfo(string) then
      Result := LSL.Text;
  finally
    LSL.Free;
  end;
 {$endif}
end;

{ TFormParamReader }

function TFormParamReader.ReadFrom(
  {$ifdef Delphi10Berlin_UP}const AInputData: TBytes;{$else}const AInputData: AnsiString;{$endif}
    const ADestination: TRttiObject; const AMediaType: TMediaType;
    const AActivation: IMARSActivation
): TValue;
var
  LNamedObject: TRttiNamedObject;
  LName: string;
begin
  Result := TValue.Empty;
  LNamedObject := ADestination as TRttiNamedObject;
  if Assigned(LNamedObject) then
  begin
    LName := LNamedObject.Name;
    ADestination.HasAttribute<FormParamAttribute>(
      procedure (AAttribute: FormParamAttribute)
      begin
        if AAttribute.Name <> '' then
          LName := AAttribute.Name;
      end
    );

    Result := TValue.From<TFormParam>(
      TFormParam.CreateFromRequest(AActivation.Request, LName)
    );
  end;
end;

{ TArrayOfTFormParamReader }

function TArrayOfTFormParamReader.ReadFrom(
  {$ifdef Delphi10Berlin_UP}const AInputData: TBytes;{$else}const AInputData: AnsiString;{$endif}
  const ADestination: TRttiObject; const AMediaType: TMediaType;
  const AActivation: IMARSActivation
): TValue;
var
  LResult: TArray<TFormParam>;
  LRequest: TWebRequest;
  LIndex: Integer;
begin
  LResult := [];

  if AMediaType.Matches(TMediaType.APPLICATION_FORM_URLENCODED_TYPE)
    or AMediaType.Matches(TMediaType.MULTIPART_FORM_DATA)
  then
  begin
    LRequest := AActivation.Request;

    for LIndex := 0 to LRequest.ContentFields.Count - 1 do
      LResult := LResult + [TFormParam.CreateFromRequest(LRequest, LRequest.ContentFields.Names[LIndex])];

    for LIndex := 0 to LRequest.Files.Count - 1 do
      LResult := LResult + [TFormParam.CreateFromRequest(LRequest, LIndex)];
  end;

  Result := TValue.From<TArray<TFormParam>>(LResult);
end;


procedure RegisterReaders;
begin
  TMARSMessageBodyReaderRegistry.Instance.RegisterReader(
    TObjectReader
    , function (AType: TRttiType; const AAttributes: TAttributeArray; AMediaType: string): Boolean
      begin
        Result := AType.IsObjectOfType<TObject>;
      end
    , function (AType: TRttiType; const AAttributes: TAttributeArray; AMediaType: string): Integer
      begin
        Result := TMARSMessageBodyReaderRegistry.AFFINITY_LOW;
      end
  );

  TMARSMessageBodyReaderRegistry.Instance.RegisterReader(
    TArrayOfObjectReader
    , function (AType: TRttiType; const AAttributes: TAttributeArray; AMediaType: string): Boolean
      begin
        Result := AType.IsDynamicArrayOf<TObject>;
      end
    , function (AType: TRttiType; const AAttributes: TAttributeArray; AMediaType: string): Integer
      begin
        Result := TMARSMessageBodyReaderRegistry.AFFINITY_LOW;
      end
  );

  TMARSMessageBodyReaderRegistry.Instance.RegisterReader<TJSONValue>(TJSONValueReader);
  TMARSMessageBodyReaderRegistry.Instance.RegisterReader<TStream>(TStreamReader);

  TMARSMessageBodyReaderRegistry.Instance.RegisterReader(
    TRecordReader
    , function (AType: TRttiType; const AAttributes: TAttributeArray; AMediaType: string): Boolean
      begin
        Result := AType.IsRecord;
      end
    , function (AType: TRttiType; const AAttributes: TAttributeArray; AMediaType: string): Integer
      begin
        Result := TMARSMessageBodyReaderRegistry.AFFINITY_MEDIUM;
      end
  );

  TMARSMessageBodyReaderRegistry.Instance.RegisterReader(
    TArrayOfRecordReader
    , function (AType: TRttiType; const AAttributes: TAttributeArray; AMediaType: string): Boolean
      begin
        Result := AType.IsDynamicArrayOfRecord;
      end
    , function (AType: TRttiType; const AAttributes: TAttributeArray; AMediaType: string): Integer
      begin
        Result := TMARSMessageBodyReaderRegistry.AFFINITY_MEDIUM;
      end
  );

  TMARSMessageBodyReaderRegistry.Instance.RegisterReader(
    TStringReader
    , function (AType: TRttiType; const AAttributes: TAttributeArray; AMediaType: string): Boolean
      begin
        Result := (AType.Handle = TypeInfo(string)) or AType.IsDynamicArrayOf<string>;
      end
    , function (AType: TRttiType; const AAttributes: TAttributeArray; AMediaType: string): Integer
      begin
        Result := TMARSMessageBodyReaderRegistry.AFFINITY_MEDIUM;
      end
  );

  TMARSMessageBodyReaderRegistry.Instance.RegisterReader<TFormParam>(TFormParamReader);
  TMARSMessageBodyReaderRegistry.Instance.RegisterReader(
    TArrayOfTFormParamReader
    , function (AType: TRttiType; const AAttributes: TAttributeArray; AMediaType: string): Boolean
      begin
        Result := AType.IsDynamicArrayOf<TFormParam>(false);
      end
    , function (AType: TRttiType; const AAttributes: TAttributeArray; AMediaType: string): Integer
      begin
        Result := TMARSMessageBodyReaderRegistry.AFFINITY_MEDIUM;
      end
  );

end;

initialization
  RegisterReaders;

end.
