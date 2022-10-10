unit Web.mORMot.Http;

{-------------------------------------------------------------------------------

mORMot for TMS WebCore.

Adapted from mORMot v1 CrossPlatform units.

See original file for copyright and licence information at:

https://github.com/synopse/mORMot


Note: Manual RTTI for SMS has been removed.

-------------------------------------------------------------------------------}

interface

uses
  SysUtils,

  JS,
  Web,

  Web.mORMot.RestTypes,
  Web.mORMot.RestUtils,
  Web.mORMot.HttpTypes;


type
  /// abstract class for HTTP client connection
  TAbstractHttpConnection = class
  protected
    fParameters: TRestConnectionParams;
    fURL: string;
    fOpaqueConnection: TObject;
  public
    /// this is the main entry point for all HTTP clients
    // - connect to http://aServer:aPort or https://aServer:aPort
    // - optional aProxyName may contain the name of the proxy server to use,
    // and aProxyByPass an optional semicolon delimited list of host names or
    // IP addresses, or both, that should not be routed through the proxy
    constructor Create(const aParameters: TRestConnectionParams); virtual;
    /// perform the request
    // - this is the main entry point of this class
    // - inherited classes should override this abstract method
    procedure URI(var Call: TRestURIParams; const InDataType: string;
      KeepAlive: integer); virtual; abstract;

    /// the remote server full URI
    // - e.g. 'http://myserver:888/'
    property Server: string read fURL;
    /// the connection parameters
    property Parameters: TRestConnectionParams read fParameters;
    /// opaque access to the effective connection class instance
    // - which may be a TFPHttpClient, a TIdHTTP or a TWinHttpAPI
    property ActualConnection: TObject read fOpaqueConnection;
  end;

  /// define the inherited class for HTTP client connection
  TAbstractHttpConnectionClass = class of TAbstractHttpConnection;


  // -- Note that we're only defining one connection class type for now.
  { TODO : Incorporate additional connection class types. }
  TWebHttpConnectionClass = class(TAbstractHttpConnection)
  protected  // see http://www.w3.org/TR/XMLHttpRequest
  public
    procedure URI(var Call: TRestURIParams; const InDataType: string;
      KeepAlive: integer); override;
  end;


  /// gives access to the class type to implement a HTTP connection
  // - will use WinHTTP API (from our SynCrtSock) under Windows
  // - will use Indy for Delphi on other platforms
  // - will use fcl-web (fphttpclient) with FreePascal
  function HttpConnectionClass: TAbstractHttpConnectionClass;


implementation

//------------------------------------------------------------------------------
{function HttpConnectionClass: TAbstractHttpConnectionClass;
begin
  result := THttpClientHttpConnectionClass;
end;}


{ TAbstractHttpConnection }

//------------------------------------------------------------------------------
constructor TAbstractHttpConnection.Create(
  const aParameters: TRestConnectionParams);
begin
  inherited Create;
  fParameters := aParameters;
  if fParameters.Port = 0 then
    if fParameters.Https then
      fParameters.Port := INTERNET_DEFAULT_HTTPS_PORT else
      fParameters.Port := INTERNET_DEFAULT_HTTP_PORT;
  if fParameters.Https then
    fURL := 'https://' else
    fURL := 'http://';
  fURL := fURL + fParameters.Server + ':' + IntToStr(fParameters.Port) + '/';
end;



{ TWebHttpConnectionClass } // - formerly TSMSHttpConnectionClass. 

{ TODO : Implement Call.XHR.onerror }
//------------------------------------------------------------------------------
procedure TWebHttpConnectionClass.URI(var Call: TRestURIParams;
  const InDataType: string; KeepAlive: integer);
var
  i: integer;
  l: integer;
  line: string;
  head: string;
  value: string;
begin
  asm
    Call.XHR = new XMLHttpRequest();
  end;

  if Assigned(Call.OnSuccess) then     // asynchronous call
  begin
    Call.XHR.onreadystatechange :=
    procedure
    begin
      if Call.XHR.readyState = Call.XHR.DONE then
      begin
        Call.XHR.onreadystatechange := nil; // avoid any further trigger
        Call.OutStatus := Call.XHR.status;
        Call.OutHead := Call.XHR.getAllResponseHeaders();
        Call.OutBody := Call.XHR.responseText;
        Call.OnSuccess;
      end;
    end;
    //Call.XHR.onerror := Call.OnError;

    Call.XHR.open(Call.Verb, fURL + Call.Url, true);  // true for asynch call
  end
  else
    Call.XHR.open(Call.Verb, fURL + Call.Url, false); // false for synch call

  if Call.InHead <> '' then
  begin
    i := 1;
    while GetNextCSV(Call.InHead, i, line, #10) do
    begin
      l := pos(':', line);
      if l = 0 then
        continue;
      head := trim(copy(line, 1, l - 1));
      value := trim(copy(line, l + 1, length(line)));
      if (head <> '') and (value <> '') then
        Call.XHR.setRequestHeader(head, value);
    end;
  end;

  if Call.InBody = '' then
    Call.XHR.send(null)
  else
    Call.XHR.send(Call.InBody);

  if not Assigned(Call.OnSuccess) then begin // synchronous call
    Call.OutStatus := Call.XHR.status;
    Call.OutHead := Call.XHR.getAllResponseHeaders();
    Call.OutBody := Call.XHR.responseText;
  end;
end;
//------------------------------------------------------------------------------
function HttpConnectionClass: TAbstractHttpConnectionClass;
begin
  result := TWebHttpConnectionClass;
end;


end.
