unit Web.mORMot.Rest;

{-------------------------------------------------------------------------------

Adapted from mORMot v1 CrossPlatform units.

See original file for copyright and licence information at:

https://github.com/synopse/mORMot

-------------------------------------------------------------------------------}


{ TODO : Re-instate all logging. }


interface

uses
  SysUtils,
  Classes,

  Web,
  JS,
  Types,

  WebLib.Utils,
  WebLib.Crypto,

 {$IFDEF JS_SHA}
  JS_SHA256,
  {$ELSE}
  Web.mORMot.SHA256,
  {$ENDIF}

  Web.mORMot.StringUtils,
  //Web.mORMot.SHA,
  Web.mORMot.Utils,
  Web.mORMot.Types,
  Web.mORMot.RestTypes,
  Web.mORMot.OrmTypes,
  Web.mORMot.AuthTypes,
  Web.mORMot.RestUtils,
  Web.mORMot.Routing,
  Web.mORMot.HttpTypes,
  Web.mORMot.Http,
  Web.mORMot.CryptoUtils;


type

  // -- In mormot.rest.core.
  TRest = class;       // TSQLRest


  /// store information of several TOrm classes
  //TSQLModelInfoDynArray = array of TOrmModelInfo;

  TRestServerAuthentication = class;

  /// class used for client authentication
  TRestServerAuthenticationClass = class of TRestServerAuthentication;

  /// the possible Server-side instance implementation patterns for
  // interface-based services
  // - each interface-based service will be implemented by a corresponding
  // class instance on the server: this parameter is used to define how
  // class instances are created and managed
  // - on the Client-side, each instance will be handled depending on the
  // server side implementation (i.e. with sicClientDriven behavior if necessary)
  TServiceInstanceImplementation = (
    sicSingle, sicShared, sicClientDriven, sicPerSession, sicPerUser, sicPerGroup,
    sicPerThread);

  TRestClientURI = class;

  TSynLogInfo = (
    sllNone, sllInfo, sllDebug, sllTrace, sllWarning, sllError,
    sllEnter, sllLeave,
    sllLastError, sllException, sllExceptionOS, sllMemory, sllStackTrace,
    sllFail, sllSQL, sllCache, sllResult, sllDB, sllHTTP, sllClient, sllServer,
    sllServiceCall, sllServiceReturn, sllUserAuth,
    sllCustom1, sllCustom2, sllCustom3, sllCustom4,
    sllNewRun, sllDDDError, sllDDDInfo);

  /// used to define a set of logging level abilities
  // - i.e. a combination of none or several logging event
  // - e.g. use LOG_VERBOSE constant to log all events, or LOG_STACKTRACE
  // to log all errors and exceptions
  TSynLogInfos = set of TSynLogInfo;

  /// abstract ancestor to all client-side interface-based services
  // - any overriden class will in fact call the server to execute its methods
  // - inherited classes are in fact the main entry point for all interface-based
  // services, without any interface use:
  // ! aCalculator := TServiceCalculator.Create(aClient);
  // ! try
  // !   aIntegerResult := aCalculator.Add(10,20);
  // ! finally
  // !   aCalculator.Free;
  // ! end;
  // - under SmartMobileStudio, calling Free is mandatory only for
  // sicClientDriven mode (to release the server-side associated session),
  // so e.g. for a sicShared instance, you can safely write:
  // ! aIntegerResult := TServiceCalculator.Create(aClient).Add(10,20);
  // - as you already noted, server-side interface-based services are in fact
  // consumed without any interface in this cross-platform unit!
  { NOTE: Keep the same class name as in mORMot v1 since there is currently no
  equivalent in v2. }
  { TODO : Use TInterfacedObject in pas2js? }
  TServiceClientAbstract = class     //{$ifndef ISDWS}(TInterfacedObject){$endif}
  protected
    fClient: TRestClientURI;
    fServiceName: string;
    fServiceURI: string;
    fInstanceImplementation: TServiceInstanceImplementation;
    fContractExpected: string;
    function GetClient: TRestClientURI;
    function GetContractExpected: string;
    function GetInstanceImplementation: TServiceInstanceImplementation;
    function GetRunningInstance: TServiceClientAbstract;
    function GetServiceName: string;
    function GetServiceURI: string;
  public
    /// initialize the fake instance
    // - this method will synchronously (i.e. blocking) check the server
    // contract according to the one expected by the client
    // - overriden constructors will set the parameters expected by the server
    constructor Create(aClient: TRestClientURI); virtual;
    /// the associated TRestClientURI instance
    property Client: TRestClientURI read GetClient;
    /// the unmangdled remote service name
    property ServiceName: string read GetServiceName;
    /// the URI to access to the remote service
    property ServiceURI: string read GetServiceURI;
    /// how this instance lifetime is expected to be handled
    property InstanceImplementation: TServiceInstanceImplementation read GetInstanceImplementation;
    /// the published service contract, as expected by both client and server
    property ContractExpected: string read GetContractExpected;
  end;


  /// class type used to identify an interface-based service
  // - we do not rely on interfaces here, but simply on abstract classes
  TServiceClientAbstractClass = class of TServiceClientAbstract;


  /// callback used e.g. by TRestClientURI.Connect() overloaded method
  TRestEvent = reference to procedure(Client: TRestClientURI);

  TRestSuccessEvent = reference to procedure(res: TJSValueDynArray);

  /// callback which should return TRUE on process success, or FALSE on error
  TRestEventProcess = reference to function: boolean;

  /// abstract REST access class
  TRest = class
  protected
    fModel: TORMModel;
    fServerTimeStampOffset: TDateTime;
    //fBatch: string;
    //fBatchTable: TSQLRecordClass;
    //fBatchCount: integer;
    fServicesRouting: TRestRoutingAbstractClass;
    fInternalState: cardinal;
    fOwnModel: boolean;
    //fLogLevel: TSynLogInfos;
    //fOnLog: TOnSQLRestLog;
    //{$ifdef ISSMS}
    fLogClient: TRestClientURI;
    procedure LogToRemoteServerText(const Text: string);
    //{$else}
    //fLogClient: TSQLRestLogClientThread;
    //fLogFileBuffer: array of byte;
    //fLogFile: system.text;
    //procedure LogToFileText(const Text: string);
    //{$endif}
    //procedure LogClose;
    function GetServerTimeStamp: TTimeLog;
    function SetServerTimeStamp(const ServerResponse: string): boolean;
    //function InternalBatch(Table: TSQLRecordClass; const CMD: string; var Info: TSQLModelInfo): Integer;
    //function ExecuteAdd(tableIndex: integer; const json: string): TID; virtual; abstract;
    //function ExecuteUpdate(tableIndex: integer; ID: TID; const json: string): boolean; virtual; abstract;
    //function ExecuteBatchSend(Table: TSQLRecordClass; const Data: string;
    //  var Results: TIDDynArray): integer; virtual; abstract;
  public
    /// initialize the class, and associate it to a specified database Model
    // - if aOwnModel is TRUE, this class destructor will free aModel instance
    constructor Create(aModel: TORMModel; aOwnModel: boolean=false); virtual;
    /// will release the associated Model, if aOwnModel was TRUE at Create()
    destructor Destroy; override;

    { Removed all ORM-related members, Retrieve, MultiFieldValues etc. down to BatchAbort. }

    { Comment-out all logging call until needed. }
    (*
    /// call this method to add some information to the log at a specified level
    // - the supplied log level will be checked against TSQLRest.LogLevel
    // - if Instance is set, it will log the corresponding class name and address
    // - will compute the text line in the very same format as TSynLog class
    // - use LogToFile() or LogToRemoteServer() to set the OnLog callback
    procedure Log(Level: TSynLogInfo; const Text: string; Instance: TObject=nil); overload;
    /// call this method to add some information to the log at a specified level
    // - overloaded method which will call Format() to render the text
    // - here the Fmt layout is e.g. '%s %d %g', as standard Format(), and not
    // the same as with SynCommons' FormatUTF8()
    // - the supplied log level will be checked against TSQLRest.LogLevel
    // - if Instance is set, it will log the corresponding class name and address
    // - use LogToFile() or LogToRemoteServer() to set the OnLog callback
    procedure Log(Level: TSynLogInfo; const Fmt: string; const Args: array of const;
      Instance: TObject=nil); overload;
    /// call this method to add some information to the log at a specified level
    // - overloaded method which will log the corresponding class name and address
    // - the supplied log level will be checked against TSQLRest.LogLevel
    // - use LogToFile() or LogToRemoteServer() to set the OnLog callback
    procedure Log(Level: TSynLogInfo; Instance: TObject); overload;
    /// call this method to add some information to the log for an Exception
    // - will log the Exception class name and message, if sllExecption is set
    procedure Log(E: Exception); overload;
    {$ifdef ISSMS}
    /// start the logging process into a remote log server
    // - the server could be for instance a LogView tool running in server mode
    procedure LogToRemoteServer(LogLevel: TSynLogInfos;
      const aServer: string; aPort: integer=8091; aRoot: string='LogService');
    {$else}
    /// start the logging process into a file
    // - if no directory is specified, will use the current one
    // - if no file name is supplied, will compute a new one with the current
    // time stamp, in the specified directory
    procedure LogToFile(LogLevel: TSynLogInfos;
      const aFolderName: TFileName=''; const aFileName: TFileName='');
    /// start the logging process into a remote log server
    // - the server could be for instance a LogView tool running in server mode
    procedure LogToRemoteServer(LogLevel: TSynLogInfos;
      const aServer: string; aPort: integer=8091; const aRoot: string='LogService');
    {$endif}
    *)

    /// the associated data model
    property Model: TORMModel read fModel;
    /// the set of log events which will be logged by Log() overloaded methods
    // - set to [] by default, meaning that log is disabled
    //property LogLevel: TSynLogInfos read fLogLevel write fLogLevel;
    /// the callback to be executed by Log() overloaded methods
    // - if none is set, the instance won't log anything
    //property OnLog: TOnSQLRestLog read fOnLog write fOnLog;
    /// the current Date and Time, as retrieved from the server at connection
    property ServerTimeStamp: TTimeLog read GetServerTimeStamp;
    /// internal state counter of the mORMot server at last access time
    // - can be used to check if retrieved data may be out of date
    property InternalState: cardinal read fInternalState;
    /// the access protocol to be used for interface-based services
    // - is set to TSQLRestRoutingREST by default
    // - you can set TSQLRestRoutingJSON_RPC if the server expects this protocol
    property ServicesRouting: TRestRoutingAbstractClass read fServicesRouting;
  end;


  /// REST client access class
  TRestClientURI = class(TRest)
  protected
    fAuthentication: TRestServerAuthentication;
    fOnlyJSONRequests: boolean;
    fRunningClientDriven: TStringList;
    //{$ifdef ISSMS}
    fAsynchCount: integer;
    fAsynchPendingText: TStringDynArray;
    procedure SetAsynchText(const Text: string);
    procedure CallAsynchText;
    /// connect to the REST server, and retrieve its time stamp offset
    // - under SMS, you SHOULD use this asynchronous method, which won't block
    // the browser, e.g. if the network is offline
    procedure SetAsynch(var Call: TRestURIParams; onSuccess, onError: TRestEvent;
      onBeforeSuccess: TRestEventProcess);
    //{$endif}
    function getURI(aTable: TOrmClass): string;
    function getURIID(aTableExistingIndex: integer; aID: TID): string;
    function getURICallBack(const aMethodName: string; aTable: TOrmClass; aID: TID): string;

    {
    function ExecuteAdd(tableIndex: integer; const json: string): TID; override;
    function ExecuteUpdate(tableIndex: integer; ID: TID; const json: string): boolean; override;
    function ExecuteBatchSend(Table: TSQLRecordClass; const Data: string;
      var Results: TIDDynArray): integer; override;
    }

    procedure InternalURI(var Call: TRestURIParams); virtual; abstract;
    procedure InternalStateUpdate(const Call: TRestURIParams);
    procedure CallRemoteServiceInternal(var Call: TRestURIParams;
      aCaller: TServiceClientAbstract; const aMethod, aParams: string);
    procedure InternalServiceCheck(const aMethodName: string;
      const Call: TRestURIParams);
  public
    //{$ifndef ISSMS}
    /// initialize the class, and associate it to a specified database Model
    // - if aOwnModel is TRUE, this class destructor will free aModel instance
    //constructor Create(aModel: TORMModel; aOwnModel: boolean=false); override;
    //{$endif}
    /// will call SessionClose
    destructor Destroy; override;

    /// connect to the REST server, and retrieve its time stamp offset
    // - under SMS, only this asynchronous method is available, which won't
    // block the browser, e.g. if the network is offline
    // - code sample using two lambda functions may be:
    // !  client := TSQLRestClientHTTP.Create(ServerAddress.Text,888,model,false);
    // !  client.Connect(
    // !  lambda
    // !    if client.ServerTimeStamp=0 then
    // !      ShowMessage('Impossible to retrieve server time stamp') else
    // !      writeln('ServerTimeStamp='+IntToStr(client.ServerTimeStamp));
    // !    if not client.SetUser(TSQLRestServerAuthenticationDefault,LogonName.Text,LogonPassWord.Text) then
    // !      ShowMessage('Authentication Error');
    // !    writeln('Safely connected with SessionID='+IntToStr(client.Authentication.SessionID));
    // !    people := TSQLRecordPeople.Create(client,1); // blocking request
    // !    assert(people.ID=1);
    // !    writeln('Disconnect from server');
    // !    client.Free;
    // !  end,
    // !  lambda
    // !    ShowMessage('Impossible to connect to the server');
    // !  end);
    procedure Connect(onSuccess, onError: TRestEvent);

    /// method calling the remote Server via a RESTful command
    // - calls the InternalURI abstract method
    // - this method will sign the url, if authentication is enabled
    procedure URI(var Call: TRestURIParams); virtual;

    (*
    /// get a member from its ID using URI()
    function Retrieve(aID: TID; Value: TOrm;
      ForUpdate: boolean=false): boolean; overload; override;
    {$ifndef ISSMS}
    /// get a blob field content from its record ID and supplied blob field name
    // - returns true on success, and the blob binary data, as direclty
    // retrieved from the server via a dedicated HTTP GET request
    function RetrieveBlob(Table: TSQLRecordClass; aID: TID;
      const BlobFieldName: string; out BlobData: TSQLRawBlob): boolean; override;
    {$endif}
    /// execute directly a SQL statement, returning a list of rows or nil
    // - we expect reUrlEncodedSQL to be defined in AllowRemoteExecute on
    // server side, since we will encode the SQL at URL level, so that all
    // HTTP client libraires will accept this layout (e.g. Indy or AJAX)
    function ExecuteList(const SQL: string): TSQLTableJSON; override;
    /// delete a member
    function Delete(Table: TOrmClass; ID: TID): boolean; override;
    *)

    /// wrapper to the protected URI method to call a method on the server
    // - perform a ModelRoot/[TableName/[ID/]]MethodName RESTful GET request
    // - if no Table is expected, set aTable=nil (we do not define nil as
    // default parameter, since the SMS compiler is sometimes confused)
    procedure CallBackGet(const aMethodName: string;
      const aNameValueParameters: array of const; var Call: TRestURIParams;
      aTable: TOrmClass; aID: TID=0);
    /// decode "result":... content as returned by CallBackGet()
    // - if no Table is expected, set aTable=nil (we do not define nil as
    // default parameter, since the SMS compiler is sometimes confused)
    function CallBackGetResult(const aMethodName: string;
      const aNameValueParameters: array of const;
      aTable: TOrmClass; aID: TID=0): string;
    /// authenticate an User to the current connected Server
    // - using TSQLRestServerAuthenticationDefault or TSQLRestServerAuthenticationNone
    // - will set Authentication property on success
    function SetUser(aAuthenticationClass: TRestServerAuthenticationClass;
      const aUserName, aPassword: string; aHashedPassword: Boolean=False): boolean;
    /// close the session initiated with SetUser()
    // - will reset Authentication property to nil
    procedure SessionClose;

    //{$ifdef ISSMS}
    /// asynchronous execution a specified interface-based service method on the server
    // - under SMS, this asynchronous method won't block the browser, e.g. if
    // the network is offline
    // - you should not call it, but directly TServiceClient* methods
    procedure CallRemoteServiceAsynch(aCaller: TServiceClientAbstract;
      const aMethodName: string; aExpectedOutputParamsCount: integer;
        const aInputParams: TJSValueDynArray;
          onSuccess: TRestSuccessEvent; onError: TRestEvent;
            aReturnsCustomAnswer: boolean=false);
    /// synchronous execution a specified interface-based service method on the server
    // - under SMS, this synchronous method would block the browser, e.g. if
    // the network is offline, or the server is late to answer
    // - but synchronous code is somewhat easier to follow than asynchronous
    // - you should not call it, but directly TServiceClient* methods
    //function CallRemoteServiceSynch(aCaller: TServiceClientAbstract;
    //  const aMethodName: string; aExpectedOutputParamsCount: integer;
    //  const aInputParams: TJSValueDynArray; aReturnsCustomAnswer: boolean = false): TJSValueDynArray;

    /// set this property to TRUE if the server expects only APPLICATION/JSON
    // - applies only for AJAX clients (i.e. SmartMobileStudio platform)
    // - true will let any remote call be identified as "preflighted requests",
    // so will send an OPTIONS method prior to any request: may be twice slower
    // - the default is false, as in TSQLHttpServer.OnlyJSONRequests
    property OnlyJSONRequests: boolean read fOnlyJSONRequests write fOnlyJSONRequests;
    /// if not nil, point to the current authentication session running
    property Authentication: TRestServerAuthentication read fAuthentication;
  end;


  /// REST client via HTTP
  // - note that this implementation is not thread-safe yet
  TRestClientHTTP = class(TRestClientURI)
  protected
    fConnection: TAbstractHttpConnection;
    fParameters: TRestConnectionParams;
    fKeepAlive: Integer;
    fCustomHttpHeader: RawUTF8; // e.g. for SetHttpBasicAuthHeaders()
    fForceTerminate: Boolean;
    procedure InternalURI(var Call: TRestURIParams); override;
  public
    /// access to a mORMot server via HTTP
    constructor Create(const aServer: string; aPort: integer; aModel: TOrmModel;
      aOwnModel: boolean=false; aHttps: boolean=false
    (*{$ifndef ISSMS}; const aProxyName: string='';
      const aProxyByPass: string=''; aSendTimeout: Cardinal=30000;
      aReceiveTimeout: Cardinal=30000; aConnectionTimeOut: cardinal=30000{$endif}*));
      reintroduce; virtual;
    /// finalize the connection
    destructor Destroy; override;
    /// force the HTTP headers of any request to contain some HTTP BASIC
    // authentication, without creating any remote session
    // - here the password should be given as clear content
    // - potential use case is to use a mORMot client through a HTTPS proxy
    // - then you can use SetUser(TSQLRestServerAuthenticationDefault,...) to
    // define any another "mORMot only" authentication
    procedure SetHttpBasicAuthHeaders(const aUserName, aPasswordClear: RawUTF8);

    /// the associated connection, if active
    property Connection: TAbstractHttpConnection read fConnection;
    /// the connection parameters
    property Parameters: TRestConnectionParams read fParameters;
    //{$ifndef ISSMS}
    /// the keep-alive timeout, in ms (20000 by default)
    //property KeepAlive: Integer read fKeepAlive write fKeepAlive;
    //{$endif ISSMS}
  end;


  /// abstract class used for client authentication
  TRestServerAuthentication = class
  protected
    fUser: TAuthUser;
    fSessionID: cardinal;
    fSessionIDHexa8: string;
    procedure SetSessionID(Value: Cardinal);
    // override this method to return the session key
    function ClientComputeSessionKey(Sender: TRestClientURI): string;
      virtual; abstract;
    function ClientSessionComputeSignature(Sender: TRestClientURI;
      const url: string): string; virtual; abstract;
  public
    /// initialize client authentication instance, i.e. the User associated instance
    constructor Create(const aUserName, aPassword: string;
      aHashedPassword: Boolean=false);
    /// finalize the instance
    destructor Destroy; override;
    /// read-only access to the logged user information
    // - only LogonName and PasswordHashHexa are set here
    property User: TAuthUser read fUser;
    /// contains the session ID used for the authentication
    property SessionID: cardinal read fSessionID;
  end;


  /// mORMot secure RESTful authentication scheme
  TRestServerAuthenticationDefault = class(TRestServerAuthentication)
  protected
    fSessionPrivateKey: hash32;
    function ClientComputeSessionKey(Sender: TRestClientURI): string; override;
    function ClientSessionComputeSignature(Sender: TRestClientURI;
      const url: string): string; override;
  end;


type
  TServiceInternalMethod = (imFree, imContract, imSignature);

const
  SERVICE_PSEUDO_METHOD: array[TServiceInternalMethod] of string = (
    '_free_','_contract_','_signature_');




implementation

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------





{ TServiceClientAbstract }

//------------------------------------------------------------------------------
constructor TServiceClientAbstract.Create(aClient: TRestClientURI);
var
  Call: TRestURIParams; // manual synchronous call
  dummyID: TID;
  contract: string;

  rtn: TJSObject;
  arr: TJSArray;
  jsv: JSValue;
begin
  if (fServiceName = '') or (fServiceURI = '') then
    raise EServiceException.CreateFmt(
      'Overriden %s.Create should have set properties',[ClassName]);
  if aClient = nil then
    raise EServiceException.CreateFmt('%s.Create(nil)',[ClassName]);

  fClient := aClient;
  fClient.CallRemoteServiceInternal(Call, self, SERVICE_PSEUDO_METHOD[imContract], '[]');
  rtn := CallGetResult(Call, dummyID);

  jsv := rtn.Properties['result'];
  if isArray(jsv) then
  begin
    arr := TJSArray(jsv);
    contract := string(arr[0]);
  end
  else
    contract := string(jsv);

  if contract <> fContractExpected then
    raise EServiceException.CreateFmt('Invalid contract "%s" for %s: expected "%s"',
      [contract, ClassName, fContractExpected]);
end;
//------------------------------------------------------------------------------
function TServiceClientAbstract.GetClient: TRestClientURI;
begin
  result := fClient;
end;
//------------------------------------------------------------------------------
function TServiceClientAbstract.GetContractExpected: string;
begin
  result := fContractExpected;
end;
//------------------------------------------------------------------------------
function TServiceClientAbstract.GetInstanceImplementation: TServiceInstanceImplementation;
begin
  result := fInstanceImplementation;
end;
//------------------------------------------------------------------------------
function TServiceClientAbstract.GetRunningInstance: TServiceClientAbstract;
begin
  result := self;
end;
//------------------------------------------------------------------------------
function TServiceClientAbstract.GetServiceName: string;
begin
  result := fServiceName;
end;
//------------------------------------------------------------------------------
function TServiceClientAbstract.GetServiceURI: string;
begin
  result := fServiceURI;
end;




{ TRest }

//------------------------------------------------------------------------------
constructor TRest.Create(aModel: TORMModel; aOwnModel: boolean);
begin
  inherited Create;
  fModel := aModel;
  fOwnModel := aOwnModel;
  fServicesRouting := TRestRoutingREST;
end;
//------------------------------------------------------------------------------
destructor TRest.Destroy;
begin
  //Log(sllInfo,'Destroy',self);
  inherited;
  if fOwnModel then
    fModel.Free;
  //LogClose;
end;
//------------------------------------------------------------------------------
function TRest.GetServerTimeStamp: TTimeLog;
begin
  if fServerTimeStampOffset = 0 then
    result := 0
  else
    result := DateTimeToTTimeLog(Now + fServerTimeStampOffset);
end;
//------------------------------------------------------------------------------
procedure TRest.LogToRemoteServerText(const Text: string);
begin
  if fLogClient<>nil then
    fLogClient.SetAsynchText(Text);
end;
//------------------------------------------------------------------------------
function TRest.SetServerTimeStamp(const ServerResponse: string): boolean;
var
  TimeStamp: Int64;
begin
  if not TryStrToInt64(ServerResponse, TimeStamp) then
    result := false else begin
    fServerTimeStampOffset := TTimeLogToDateTime(TimeStamp) - Now;
    if fServerTimeStampOffset = 0 then
      fServerTimeStampOffset := 0.000001; // ensure <> 0 (indicates error)
    result := true;
  end;
end;



{ TRestClientURI }

const
  LOGLEVELDB: array[boolean] of TSynLogInfo = (sllError, sllDB);


//------------------------------------------------------------------------------
procedure TRestClientURI.SessionClose;
var
  Call: TRestURIParams;
begin
  if (self <> nil) and (fAuthentication <> nil) then
    try // notify Server to end of session
      CallBackGet('Auth', ['UserName', fAuthentication.User.LogonName,
        'Session', fAuthentication.SessionID], Call, nil);
    finally
      fAuthentication.Free;
      fAuthentication := nil;
    end;
end;
//------------------------------------------------------------------------------
procedure TRestClientURI.SetAsynch(var Call: TRestURIParams;
  onSuccess, onError: TRestEvent; onBeforeSuccess: TRestEventProcess);
begin
  if not Assigned(onSuccess) then
    raise ERestException.Create('SetAsynch expects onSuccess');

  inc(fAsynchCount);

  Call.OnSuccess :=
  procedure
  begin
    if Call.XHR.readyState = Call.XHR.DONE then
    begin
      InternalStateUpdate(Call);
      if not assigned(onBeforeSuccess) then
        onSuccess(self) else
        if onBeforeSuccess then
          onSuccess(self) else
          if assigned(onError) then
            onError(self);
      if fAsynchCount > 0 then
        dec(fAsynchCount);

      { TODO : CallAsynchText }
      if fAsynchCount = 0 then
        CallAsynchText; // send any pending asynchronous task
    end;
  end;

  Call.OnError :=
  procedure
  begin
    if Assigned(onError) then
      onError(Self);
    if fAsynchCount>0 then
      dec(fAsynchCount);

    if fAsynchCount=0 then
      CallAsynchText; // send any pending asynchronous task, even on error
  end;
end;
//------------------------------------------------------------------------------
procedure TRestClientURI.SetAsynchText(const Text: string);
begin
  fAsynchPendingText.Add(Text);
  if fAsynchCount=0 then
    CallAsynchText; // send it now if no pending asynchronous task
end;
//------------------------------------------------------------------------------
function TRestClientURI.SetUser(
  aAuthenticationClass: TRestServerAuthenticationClass; const aUserName,
  aPassword: string; aHashedPassword: Boolean): boolean;
var
  aKey, aSessionID: string;
  i: integer;
begin
  result := false;

  if fAuthentication<>nil then
    SessionClose;

  if aAuthenticationClass = nil then
    exit;

  fAuthentication := aAuthenticationClass.Create(aUserName, aPassword, aHashedPassword);
  try
    aKey := fAuthentication.ClientComputeSessionKey(self);
    i := 1;
    GetNextCSV(aKey, i, aSessionID, '+');
    if TryStrToInt(aSessionID, i) and (i > 0) then begin
      fAuthentication.SetSessionID(i);
      //Log(sllUserAuth,'Session %d created for "%s" with %s',
      //  [i,aUserName,fAuthentication.ClassName]);
      result := true;
    end else begin
      fAuthentication.Free;
      fAuthentication := nil;
    end;
  except
    fAuthentication.Free;
    fAuthentication := nil;
  end;

  //if fAuthentication=nil then
  //  Log(sllError,'Session not created for "%s"',[aUserName]);
end;
//------------------------------------------------------------------------------
procedure TRestClientURI.CallAsynchText;
var
  Call: TRestURIParams;
begin
  if length(fAsynchPendingText) = 0 then
    exit; // nothing to send

  Call.Init(getURICallBack('RemoteLog', nil, 0), 'PUT', fAsynchPendingText.Join(#13#10)); // all rows sent at once

  fAsynchPendingText.Clear;

  SetAsynch(Call,
            procedure(Client: TRestClientURI)
            begin
            end,
            nil,
            nil); // asynchronous call without error check

  URI(Call);
end;
//------------------------------------------------------------------------------
procedure TRestClientURI.Connect(onSuccess, onError: TRestEvent);
var
  Call: TRestURIParams;
begin
  SetAsynch(Call, onSuccess, onError,
  function: boolean
  begin
    result := (Call.OutStatus = HTTP_SUCCESS) and SetServerTimeStamp(Call.OutBody);
  end);
  CallBackGet('TimeStamp', [], Call, nil); // asynchronous call
end;
//------------------------------------------------------------------------------
destructor TRestClientURI.Destroy;
begin
  SessionClose;
  inherited;
end;
//------------------------------------------------------------------------------
procedure TRestClientURI.CallBackGet(const aMethodName: string;
  const aNameValueParameters: array of const; var Call: TRestURIParams;
  aTable: TOrmClass; aID: TID);
begin
  //Log(sllServiceCall,'Method-based service %s',[aMethodName]);

  Call.Url := getURICallBack(aMethodName, aTable, aID) + UrlEncode(aNameValueParameters);
  Call.Verb := 'GET';

  URI(Call);

  // -- The following is only for synchronous calls.
  InternalServiceCheck(aMethodName, Call);
end;
//------------------------------------------------------------------------------
function TRestClientURI.CallBackGetResult(const aMethodName: string;
  const aNameValueParameters: array of const; aTable: TOrmClass;
    aID: TID): string;
var
  Call: TRestURIParams;
  dummyID: NativeInt;
  res: JSValue;
  rec: TResult;
begin
  CallBackGet(aMethodName, aNameValueParameters, Call, aTable, aID);

  res := CallGetResult(Call, dummyID);
  // -- At this point we have the returned JSON as a JSValue.
  rec := TResult(res);
  result := rec.result;
end;
//------------------------------------------------------------------------------
procedure TRestClientURI.CallRemoteServiceAsynch(aCaller: TServiceClientAbstract;
  const aMethodName: string; aExpectedOutputParamsCount: integer;
  const aInputParams: TJSValueDynArray;
  onSuccess: TRestSuccessEvent; onError: TRestEvent;
  aReturnsCustomAnswer: boolean);
var
  Call: TRestURIParams;
  jsv: JSValue;
  arrResults: TJSValueDynArray;
begin
  // ForceServiceResultAsJSONObject not implemented yet

  SetAsynch(Call,
    procedure(Client: TRestClientURI)
    var
      outID: TID;
      arr: TStringDynArray;          // Was TVariantDynArray in SMS.
      rtn: TJSObject;
    begin
      if not assigned(onSuccess) then
        exit; // no result to handle

      if aReturnsCustomAnswer then begin
        if Call.OutStatus = HTTP_SUCCESS then begin
          arr.Add(Call.OutBody);
          onSuccess(arr);
        end else
          if Assigned(onError) then
            onError(self);
        exit;
      end;

      rtn := CallGetResult(Call, outID); // from {result:...,id:...}

      if assigned(rtn) then
      begin
        { TODO : Implement sicClientDriven }
        //if (aCaller.fInstanceImplementation = sicClientDriven) and (outID <> 0) then
        //  (aCaller as TServiceClientAbstractClientDriven).fClientID := IntToStr(outID);

        if aExpectedOutputParamsCount = 0 then
          onSuccess([])
        else
        begin
          jsv := rtn.Properties['result'];
          if isArray(jsv) then
          begin
            arrResults := TJSValueDynArray(jsv);
            if Length(arrResults) = aExpectedOutputParamsCount then
              onSuccess(arrResults)
            else
              if Assigned(onError) then
                onError(self);
          end;
        end;
      end;
    end,
    onError,
    function: boolean
    begin
      result := (Call.OutStatus = HTTP_SUCCESS) and (Call.OutBody <> '');
    end);

  CallRemoteServiceInternal(Call, aCaller, aMethodName, TJSJSON.stringify(JSValue(aInputParams)));
end;
//------------------------------------------------------------------------------
procedure TRestClientURI.CallRemoteServiceInternal(var Call: TRestURIParams;
  aCaller: TServiceClientAbstract; const aMethod, aParams: string);
var
  url, clientDrivenID, sent, methName: string;
begin
  methName := aCaller.fServiceURI + '.' + aMethod;
  //Log(sllServiceCall,'Interface-based service '+methName);
  url := Model.Root + '/' + aCaller.fServiceURI;

  { TODO : Implement sicClientDriven }
  //if aCaller.fInstanceImplementation=sicClientDriven then
  //  clientDrivenID := (aCaller as TServiceClientAbstractClientDriven).ClientID;

  ServicesRouting.ClientSideInvoke(url, aMethod, aParams, clientDrivenID, sent);
  Call.Init(url, 'POST', sent);

  URI(Call); // asynchronous or synchronous call

  InternalServiceCheck(methName, Call); // will log only for synchronous call
end;
//------------------------------------------------------------------------------
function TRestClientURI.getURI(aTable: TOrmClass): string;
begin
  result := Model.Root;

  { TODO : TRestClientURI.getURI for TOrmClass }
  //if (aTable<>nil) and (aTable<>TOrm) then // SMS converts nil->TSQLRecord
  //  result := result+'/'+Model.InfoExisting(aTable).Name;
end;
//------------------------------------------------------------------------------
function TRestClientURI.getURICallBack(const aMethodName: string;
  aTable: TOrmClass; aID: TID): string;
begin
  result := getURI(aTable);
  if aID > 0 then
    result := result + '/' + IntToStr(aID);
  result := result + '/' + aMethodName;
end;
//------------------------------------------------------------------------------
function TRestClientURI.getURIID(aTableExistingIndex: integer; aID: TID): string;
begin
  { TODO : TRestClientURI.getURIID }
  //result := Model.Root+'/'+Model.Info[aTableExistingIndex].Name;
  if aID>0 then
    result := result + '/' + IntToStr(aID);
end;
//------------------------------------------------------------------------------
procedure TRestClientURI.InternalStateUpdate(const Call: TRestURIParams);
var
  receivedState: cardinal;
begin
  if Call.OutHead = '' then
    exit; // nothing to update (e.g. from asynchronous call)
  receivedState := StrToIntDef(GetOutHeader(Call, 'Server-InternalState'), 0);
  if receivedState > fInternalState then
    fInternalState := receivedState;

  {if sllTrace in fLogLevel then
    Log(sllTrace,'%s %s status=%d state=%d in=%d out=%d',
      [Call.Verb,Call.UrlWithoutSignature,Call.OutStatus,fInternalState,
       length(Call.InBody), length(Call.OutBody)]);}
end;
//------------------------------------------------------------------------------
procedure TRestClientURI.URI(var Call: TRestURIParams);
var sign: string;
begin
  Call.OutStatus := HTTP_UNAVAILABLE;

  if self = nil then
    exit;

  Call.UrlWithoutSignature := Call.Url;
  if (fAuthentication <> nil) and (fAuthentication.SessionID <> 0) then begin
    if Pos('?', Call.Url) = 0 then
      sign := '?session_signature=' else
      sign := '&session_signature=';
    Call.Url := Call.Url + sign +
      fAuthentication.ClientSessionComputeSignature(self, Call.Url);
  end;

  InternalURI(Call);
  InternalStateUpdate(Call);
end;
//------------------------------------------------------------------------------
procedure TRestClientURI.InternalServiceCheck(const aMethodName: string;
  const Call: TRestURIParams);
begin
  if Assigned(Call.OnSuccess) then
    exit; // An asynchronous call won't have a result yet.

  //if Call.OutStatus<>HTTP_SUCCESS then
  //  Log(sllError,'Service %s returned %s',[aMethodName,Call.OutBodyUtf8]) else
  //  Log(sllServiceReturn,'%s success',[aMethodName]);
end;


{ TRestClientHTTP }

//------------------------------------------------------------------------------
constructor TRestClientHTTP.Create(const aServer: string;
  aPort: integer; aModel: TOrmModel; aOwnModel, aHttps: boolean
  (*{$ifndef ISSMS}; const aProxyName, aProxyByPass: string;
  aSendTimeout, aReceiveTimeout, aConnectionTimeOut: Cardinal{$endif}*));
begin
  inherited Create(aModel, aOwnModel);
  fParameters.Server := aServer;
  fParameters.Port := aPort;
  fParameters.Https := aHttps;
  (*{$ifndef ISSMS}
  fParameters.ProxyName := aProxyName;
  fParameters.ProxyByPass := aProxyByPass;
  fParameters.ConnectionTimeOut := aConnectionTimeOut;
  fParameters.SendTimeout := aSendTimeout;
  fParameters.ReceiveTimeout := aReceiveTimeout;
  {$endif}*)
  fKeepAlive := 20000;
end;
//------------------------------------------------------------------------------
destructor TRestClientHTTP.Destroy;
begin
  inherited;
  fAuthentication.Free;
  fConnection.Free;
end;
//------------------------------------------------------------------------------
procedure TRestClientHTTP.InternalURI(var Call: TRestURIParams);
var inType: string;
    retry: integer;
begin
  inType := FindHeader(Call.InHead, 'content-type: ');
  if inType = '' then begin
    if OnlyJSONRequests then
      inType := JSON_CONTENT_TYPE else
      inType := 'text/plain'; // avoid slow CORS preflighted requests
    Call.InHead := trim(Call.InHead + #13#10'content-type: ' + inType);
  end;

  if fCustomHttpHeader<>'' then
    Call.InHead := trim(Call.InHead + fCustomHttpHeader);

  for retry := 0 to 1 do begin
    if fConnection = nil then
      try
        fConnection := HttpConnectionClass.Create(fParameters);
        // TODO: handle SynLZ compression and SHA/AES encryption?
      except
        on E: Exception do begin
          //Log(E);
          fConnection.Free;
          fConnection := nil;
        end;
      end;

    if fConnection = nil then begin
      Call.OutStatus := HTTP_NOTIMPLEMENTED;
      break;
    end;

    try
      fConnection.URI(Call, inType, fKeepAlive);
      break; // do not retry on transmission success, or asynchronous request
    except
      on E: Exception do begin
        //Log(E);
        fConnection.Free;
        fConnection := nil;
        Call.OutStatus := HTTP_NOTIMPLEMENTED;
        if fForceTerminate then
          break;
      end; // will retry once (e.g. if connection broken)
    end;
  end;
end;
//------------------------------------------------------------------------------
procedure TRestClientHTTP.SetHttpBasicAuthHeaders(const aUserName, aPasswordClear: RawUTF8);
var
  base64: RawUTF8;
begin
  base64 := aUsername + ':' + aPasswordClear;
  base64 := StringToBase64(base64);
  (*{$ifdef ISSMS}
  base64 := w3_base64encode(base64);
  {$else}
  base64 := BytesToBase64JSONString(TByteDynArray(TextToHttpBody(base64)), false);
  {$endif}*)
  fCustomHttpHeader := #13#10'Authorization: Basic ' + base64;
end;


{ TSQLRestServerAuthentication }

//------------------------------------------------------------------------------
constructor TRestServerAuthentication.Create(const aUserName, aPassword: string;
  aHashedPassword: Boolean);
begin
  fUser := TAuthUser.Create;
  fUser.LogonName := aUserName;
  if aHashedPassword then
    fUser.PasswordHashHexa := aPassword
      else
        fUser.PasswordPlain := aPassword;
end;
//------------------------------------------------------------------------------
destructor TRestServerAuthentication.Destroy;
begin
  fUser.Free;
  inherited;
end;
//------------------------------------------------------------------------------
procedure TRestServerAuthentication.SetSessionID(Value: Cardinal);
begin
  fSessionID := Value;
  fSessionIDHexa8 := LowerCase(IntToHex(Value,8));
end;


{ TRestServerAuthenticationDefault }

//------------------------------------------------------------------------------
function TRestServerAuthenticationDefault.ClientComputeSessionKey(
  Sender: TRestClientURI): string;
var
  aServerNonce, aClientNonce, aPassHash: string;
  s: string;
  //sha: TmWebSHA;
begin
  if fUser.LogonName = '' then
    exit;

  aServerNonce := Sender.CallBackGetResult('Auth', ['UserName', User.LogonName], nil);
  if aServerNonce = '' then
    exit;

  //if aServerNonce = 'undefined' then
  //  raise ERestException.Create('Server nonce is undefined');

  s := Copy(NowToIso8601, 1, 16);

  {$IFDEF JS_SHA}
  aClientNonce := Sha256Encoded(s, etHttp);
  aPassHash := Sha256FromArray([Sender.Model.Root, aServerNonce, aClientNonce,
    User.LogonName, User.PasswordHashHexa], etHttp);
  {$ELSE}
  aClientNonce := SHA256Compute([s]);
  aPassHash := SHA256Compute([Sender.Model.Root, aServerNonce, aClientNonce,
    User.LogonName, User.PasswordHashHexa]);
  {$ENDIF}

  result := Sender.CallBackGetResult('Auth', ['UserName', User.LogonName,
    'Password', aPassHash, 'ClientNonce', aClientNonce], nil);
  fSessionPrivateKey := crc32ascii(crc32ascii(0, result), fUser.PasswordHashHexa);
end;
//------------------------------------------------------------------------------
function TRestServerAuthenticationDefault.ClientSessionComputeSignature(
  Sender: TRestClientURI; const url: string): string;
var
  nonce: string;
begin
  nonce := LowerCase(IntToHex(trunc(Now * (24*60*60)), 8));
  result := fSessionIDHexa8 + nonce + LowerCase(IntToHex(crc32ascii(crc32ascii(fSessionPrivateKey, nonce), url), 8));
end;


end.
