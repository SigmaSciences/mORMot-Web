unit server;

interface

{$I mormot.defines.inc}
uses
  SysUtils,
  mormot.core.base,
  mormot.core.data,
  mormot.core.json,
  mormot.core.rtti,
  mormot.core.unicode,
  mormot.core.variants,
  mormot.orm.core,
  mormot.orm.rest,
  mormot.rest.server,
  mormot.rest.memserver,
  mormot.soa.core,
  mormot.soa.server,
  mormot.rest.sqlite3,
  mormot.db.raw.sqlite3.static,
  data;

type
  TCalculatorService = class(TInjectableObjectRest, ICalculator)
  public
    function Add(n1, n2: integer): integer;
    function ArrayValue(arrJSON: RawUTF8; ix: integer): variant;
    function CountArray(jsn: RawUTF8): integer;
    function SumArray(jsn: RawUTF8): double;
  end;

  TArrayRec = packed record
    Arr: TDoubleDynArray;
    VarArr: TVariantDynArray;
  end;

  {TCalcServerAuthentication = class(TRestServerAuthenticationHttpBasic)
  public
    constructor Create(aServer: TRestServer); override;
    function Auth(Ctxt: TRestServerURIContext): boolean; override;
  end;

  TCalculatorServer = class(TRestServerFullMemory)
  public
    constructor CreateWithOwnModel; overload;
  end;}

implementation



{
******************************** TCalculatorServer *****************************
}
{constructor TCalculatorServer.CreateWithOwnModel;
var
  factory: TServiceFactoryServerAbstract;
begin
  inherited CreateWithOwnModel([], true, 'root');
  //AuthenticationRegister(TRestServerAuthenticationNone);
  //AuthenticationRegister(TCalcServerAuthentication);
  factory := ServiceDefine(TCalculatorService, [ICalculator], sicShared);
  // -- Use ByPassAuthentication to allow unrestricted access.
  //factory.ByPassAuthentication := true;
end;}


{ TExampleService }

//------------------------------------------------------------------------------
function TCalculatorService.Add(n1, n2: integer): integer;
begin
  result := n1 + n2;
end;
//------------------------------------------------------------------------------
function TCalculatorService.ArrayValue(arrJSON: RawUTF8;
  ix: integer): variant;
var
  arr: TVariantDynArray;
begin
  DynArrayLoadJSON(arr, @arrJSON[1], TypeInfo(TVariantDynArray));
  result := arr[ix];
end;
//------------------------------------------------------------------------------
function TCalculatorService.CountArray(jsn: RawUTF8): integer;
var
  i: integer;
  rec: TArrayRec;
begin
  RecordLoadJSON(rec, @jsn[1], TypeInfo(TArrayRec));
  result := Length(rec.VarArr);
end;
//------------------------------------------------------------------------------
function TCalculatorService.SumArray(jsn: RawUTF8): double;
var
  i: integer;
  rec: TArrayRec;
begin
  RecordLoadJSON(rec, @jsn[1], TypeInfo(TArrayRec));
  for i := 0 to Length(rec.Arr) do
    result := result + rec.Arr[i];
end;



{ TCalcServerAuthentication }

//------------------------------------------------------------------------------
//-- We could create custom authentication but this would still require the
//-- initiation of a service.
{function TCalcServerAuthentication.Auth(Ctxt: TRestServerURIContext): boolean;
var
  uname: RawUtf8;
begin
  uname := Ctxt.InputUtf8OrVoid['UserName'];
  if uname = '' then
    uname := 'Guest';

  result := true;
end;
//------------------------------------------------------------------------------
constructor TCalcServerAuthentication.Create(aServer: TRestServer);
begin
  inherited Create(aServer);

end;}





end.
