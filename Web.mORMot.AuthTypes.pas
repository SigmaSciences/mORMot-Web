unit Web.mORMot.AuthTypes;

{-------------------------------------------------------------------------------

mORMot for pas2js/TMS WebCore.

Port of TAuthUser and TAuthGroup from SynCrossPlatformREST.pas.

See original file for copyright and licence information at:

https://github.com/synopse/mORMot


Note: Manual RTTI for SMS has been removed.

-------------------------------------------------------------------------------}

interface

uses
  JS,

  WebLib.Crypto,

  {$IFDEF JS_SHA}
  JS_SHA256,
  {$ELSE}
  Web.mORMot.SHA256,
  {$ENDIF}

  Web.mORMot.StringUtils,
  Web.mORMot.Types,
  Web.JSTypes,
  Web.mORMot.Utils,
  Web.mORMot.OrmTypes;


type
  /// table containing the available user access rights for authentication
  // - is added here since should be part of the model
  // - no wrapper is available to handle AccessRights, since for security
  // reasons it is not available remotely from client side
  TAuthGroup = class(TOrm)
  protected
    fIdent: string;
    fAccessRights: string;
    fSessionTimeOut: integer;
    //{$ifdef ISSMS}
    //class function ComputeRTTI: TRTTIPropInfos; override;
    //procedure SetProperty(FieldIndex: integer; const Value: variant); override;
    //function GetProperty(FieldIndex: integer): variant; override;
    //{$endif}
  published
    /// the access right identifier, ready to be displayed
    // - the same identifier can be used only once (this column is marked as
    // unique via a "stored AS_UNIQUE" (i.e. "stored false") attribute)
    property Ident: string read fIdent write fIdent;  // {$ifndef ISDWS}stored AS_UNIQUE{$endif};
    /// the number of minutes a session is kept alive
    property SessionTimeout: integer read fSessionTimeOut write fSessionTimeOut;
    /// a textual representation of a TSQLAccessRights buffer
    property AccessRights: string read fAccessRights write fAccessRights;
  end;

  /// class of the table containing the available user access rights for authentication
  TAuthGroupClass = class of TAuthGroup;

  /// table containing the Users registered for authentication
  TAuthUser = class(TOrm)
  protected
    fLogonName: string;
    fPasswordHashHexa: string;
    fDisplayName: string;
    fData: TRawBlob;
    fGroup: TID;
    //{$ifdef ISSMS}
    //class function ComputeRTTI: TRTTIPropInfos; override;
    //procedure SetProperty(FieldIndex: integer; const Value: variant); override;
    //function GetProperty(FieldIndex: integer): variant; override;
    //{$endif}

    procedure SetPasswordPlain(const Value: string);
  public
    /// able to set the PasswordHashHexa field from a plain password content
    // - in fact, PasswordHashHexa := SHA256('salt'+PasswordPlain) in UTF-8
    property PasswordPlain: string write SetPasswordPlain;
  published
    /// the User identification Name, as entered at log-in
    // - the same identifier can be used only once (this column is marked as
    // unique via a "stored AS_UNIQUE" - i.e. "stored false" - attribute), and
    // therefore indexed in the database (e.g. hashed in TSQLRestStorageInMemory)
    property LogonName: string read fLogonName write fLogonName;
      //{$ifndef ISDWS}stored AS_UNIQUE{$endif};

    /// the User Name, as may be displayed or printed
    property DisplayName: string read fDisplayName write fDisplayName;
    /// the hexa encoded associated SHA-256 hash of the password
    property PasswordHashHexa: string read fPasswordHashHexa write fPasswordHashHexa;
    /// the associated access rights of this user in TSQLAuthGroup
    // - access rights are managed by group
    // - note that 'Group' field name is not allowed by SQLite
    property GroupRights: TID read fGroup write fGroup;
    /// some custom data, associated to the User
    // - Server application may store here custom data
    // - its content is not used by the framework but 'may' be used by your
    // application
    property Data: TRawBlob read fData write fData;
  end;



implementation


{ TAuthUser }

//------------------------------------------------------------------------------
procedure TAuthUser.SetPasswordPlain(const Value: string);
begin
  {$IFDEF JS_SHA}
  PasswordHashHexa := SHA256FromArray(['salt', Value], etHttp);
  {$ELSE}
  PasswordHashHexa := SHA256Compute(['salt', Value]);
  {$ENDIF}
end;


end.
