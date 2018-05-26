object DMiPool: TDMiPool
  OldCreateOrder = False
  Height = 418
  Width = 429
  object RESTClient1: TRESTClient
    Authenticator = HTTPBasicAuthenticator1
    Accept = 'application/json, text/plain; q=0.9, text/html;q=0.8,'
    AcceptCharset = 'UTF-8, *;q=0.8'
    BaseURL = 
      'https://sandbox-api.ipool.asideas.de/sandbox/api/search?types=ar' +
      'ticle&languages=EN&limit=30'
    Params = <>
    HandleRedirects = True
    RaiseExceptionOn500 = False
    Left = 152
    Top = 96
  end
  object RESTRequest1: TRESTRequest
    Client = RESTClient1
    Params = <>
    Response = RESTResponse1
    SynchronizedEvents = False
    Left = 80
    Top = 96
  end
  object RESTResponse1: TRESTResponse
    ContentType = 'application/json'
    Left = 80
    Top = 168
  end
  object HTTPBasicAuthenticator1: THTTPBasicAuthenticator
    Username = 'hackathon'
    Password = 'mediahack'
    Left = 80
    Top = 224
  end
end
