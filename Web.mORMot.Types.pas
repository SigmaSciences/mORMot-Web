unit Web.mORMot.Types;

{-------------------------------------------------------------------------------

Adapted from mORMot v1 CrossPlatform units.

See original file for copyright and licence information at:

https://github.com/synopse/mORMot

-------------------------------------------------------------------------------}

interface

uses
  SysUtils;

type
  // HTTP body may not match the string type, and could be binary
  THttpBody = string;

  /// alias to share the same string type between client and server
  RawUTF8 = string;

  TTimeLog = NativeInt;      //Int53
  TModTime = TTimeLog;
  TCreateTime = TTimeLog;

  TGUID = string;
  THandle = cardinal;

  { Should TID be a string since number is limited to 53-bit in JavaScript?
    -> or define and use an explicit Int52 type for SMS? }
  /// the TSQLRecord primary key is a 64 bit integer
  TID = NativeInt;   //Int64;
  hash32 = integer;

  ERestException = class(Exception);

  /// Exception type raised when working with interface-based service process
  EServiceException = class(ERestException);

  TProcedureRef = reference to procedure;

implementation

end.
