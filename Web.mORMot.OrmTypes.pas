unit Web.mORMot.OrmTypes;

{-------------------------------------------------------------------------------

mORMot for pas2js/TMS WebCore.

Port of TSQLRecord and other Orm-related classes from SynCrossPlatformREST.

Adapted from mORMot v1 CrossPlatform units.

See original file for copyright and licence information at:

https://github.com/synopse/mORMot


1. Remove all constructors that involve a dependency on TRest. In mORMot v2 the
TOrm constructors use the IRestOrm interface instead. The initial version for
WebCore will not provide direct access to the ORM.

-------------------------------------------------------------------------------}

interface

uses
  Classes,

  Web.mORMot.Types,
  Web.mORMot.Utils;



type
  TOrm = class;        // TSQLRecord
  TORMModel = class;   // TSQLModel

  TOrmClass = class of TOrm;
  TOrmClassDynArray = array of TOrmClass;


  /// abstract ORM class to access remote tables
  // - in comparison to mORMot.pas TSQLRecord published fields, dynamic arrays
  // shall be defined as JSValue (since SynCrossPlatformJSON do not serialize)
  // - inherit from TPersistent to have RTTI for its published properties
  // (SmartMobileStudio does not allow {$M+} in the source)
  TOrm = class(TPersistent)
  protected
    fID: TID;
    fInternalState: cardinal;
  public
    /// this constructor initializes the record
    constructor Create; overload; virtual;

    /// internal state counter of the mORMot server at last access time
    // - can be used to check if retrieved data may be out of date
    property InternalState: cardinal read fInternalState;
  published
    /// stores the record's primary key
    property ID: TID read fID write fID;
  end;

  TORMModel = class
  protected
    fRoot: string;
    //fInfo: TOrmModelInfoDynArray;
  public
    /// initialize the Database Model
    // - set the Tables to be associated with this Model, as TSQLRecord classes
    // - set the optional Root URI path of this Model - default is 'root'
    constructor Create(const Tables: array of TORMClass;
      const aRoot: string ='root');

    (*
    /// register a new Table class to this Model
    procedure Add(Table: TSQLRecordClass);
    {$ifndef ISSMS}
    /// finalize the memory used
    destructor Destroy; override;
    {$endif}
    /// get index of aTable in Tables[], returns -1 if not found
    function GetTableIndex(aTable: TSQLRecordClass): integer; overload;
    /// get index of aTable in Tables[], returns -1 if not found
    function GetTableIndex(const aTableName: string): integer; overload;
    /// get index of aTable in Tables[], raise an ERestException if not found
    function GetTableIndexExisting(aTable: TSQLRecordClass): integer;
    /// get the RTTI information for the specified class or raise an ERestException
    function InfoExisting(aTable: TSQLRecordClass): TSQLModelInfo;
    /// the RTTI information for each class
    property Info: TSQLModelInfoDynArray read fInfo;
    *)

    /// the Root URI path of this Database Model
    property Root: string read fRoot;
  end;


implementation

{ TOrm }

//------------------------------------------------------------------------------
constructor TOrm.Create;
begin
  // -- Leave empty for now.
end;


{ TORMModel }

//------------------------------------------------------------------------------
constructor TORMModel.Create(const Tables: array of TORMClass;
  const aRoot: string);
//var t: integer;
begin
  (*
  {$ifdef ISSMS}
  for t := 0 to high(Tables) do
    fInfo.Add(TSQLModelInfo.CreateFromRTTI(Tables[t]));
  {$else}
  SetLength(fInfo, length(Tables));
  for t := 0 to high(fInfo) do
    fInfo[t] := TSQLModelInfo.CreateFromRTTI(Tables[t]);
  {$endif}
  *)

  if aRoot<>'' then
    if aRoot[length(aRoot)] = '/' then
      fRoot := copy(aRoot, 1, Length(aRoot) - 1) else
      fRoot := aRoot;
end;


end.
