unit Web.mORMot.RestTypes;

{-------------------------------------------------------------------------------

Adapted from mORMot v1 CrossPlatform units.

See original file for copyright and licence information at:

https://github.com/synopse/mORMot

Parts

-------------------------------------------------------------------------------}

interface

uses
  Web,
  JS,

  Web.mORMot.Types;

type
  TProcedureInt = reference to procedure(result: integer);
  TProcedureDouble = reference to procedure(result: double);
  TProcedureJSValue = reference to procedure(result: JSValue);
  TProcedureString = reference to procedure(result: string);

  /// used to store the request of a REST call
  {$ifdef USEOBJECTINSTEADOFRECORD}
  TRestURIParams = object
  {$else}
  TRestURIParams = record
  {$endif}
    /// input parameter containing the caller URI
    Url: string;
    /// caller URI, without any appended signature
    UrlWithoutSignature: string;
    /// input parameter containing the caller method
    Verb: string;
    /// input parameter containing the caller message headers
    InHead: string;
    /// input parameter containing the caller message body
    InBody: THttpBody;
    /// output parameter to be set to the response message header
    OutHead: string;
    /// output parameter to be set to the response message body
    OutBody: THttpBody;
    /// output parameter to be set to the HTTP status integer code
    OutStatus: THandle;
    //{$ifdef ISDWS}
    /// the associated TXMLHttpRequest instance
    XHR: TJSXMLHttpRequest;
    /// callback events for asynchronous call
    // - will be affected to the corresponding XHR events
    OnSuccess: TProcedureRef;
    OnError: TProcedureRef;
    //{$endif}
    /// set the caller content
    procedure Init(const aUrl, aVerb, aUTF8Body: string);
    /// get the response message body as UTF-8
    function OutBodyUtf8: string;
  end;

  /// the connection parameters, as stored and used by TAbstractHttpConnection
  TRestConnectionParams = record
    /// the server name or IP address
    Server: string;
    /// the server port
    Port: integer;
    /// if the connection should be HTTPS
    Https: boolean;
    (*{$ifndef ISSMS}
    /// the optional proxy name to be used
    ProxyName: string;
    /// the optional proxy password to be used
    ProxyByPass: string;
    /// the connection timeout, in ms
    ConnectionTimeOut: integer;
    /// the timeout when sending data, in ms
    SendTimeout: cardinal;
    /// the timeout when receiving data, in ms
    ReceiveTimeout: cardinal
    {$endif}*)
  end;

  TResult = record
    result: string;
    id: integer;
  end;


implementation


{ TRestURIParams }

//------------------------------------------------------------------------------
procedure TRestURIParams.Init(const aUrl, aVerb, aUTF8Body: string);
begin
  Url := aUrl;
  Verb := aVerb;
  if aUTF8Body = '' then
    exit;
  //{$ifdef ISSMS}
  InBody := aUTF8Body;
  //{$else}
  //InBody := TextToHttpBody(aUTF8Body);
  //{$endif}
end;
//------------------------------------------------------------------------------
function TRestURIParams.OutBodyUtf8: String;
begin
  //{$ifdef ISSMS}
  result := OutBody; // XMLHttpRequest did convert UTF-8 into DomString
  //{$else}
  //HttpBodyToText(OutBody,result);
  //{$endif}
end;

end.
