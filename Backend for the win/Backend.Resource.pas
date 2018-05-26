unit Backend.Resource;

interface

uses
  System.JSON,


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

implementation

{ TSAIDResource }

function TSAIDResource.GetArticles(AData: TJSONObject): TJSONObject;
begin
  Result := AData.Clone as TJSONObject;
end;

initialization

TMARSResourceRegistry.Instance.RegisterResource<TSAIDResource>;

end.
