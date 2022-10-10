unit Web.mORMot.RestUtils;

{-------------------------------------------------------------------------------

Adapted from mORMot v1 CrossPlatform units.

See original file for copyright and licence information at:

https://github.com/synopse/mORMot

-------------------------------------------------------------------------------}

interface

uses
  SysUtils,
  StrUtils,

  JS,
  Web,
  Types,

  WebLib.JSON,

  Web.mORMot.Types,
  Web.mORMot.RestTypes,
  Web.mORMot.HttpTypes,
  Web.mORMot.StringUtils;



function CallGetResult(const aCall: TRestURIParams; var outID: NativeInt): TJSObject;

function FindHeader(const Headers, Name: string): string;

/// will return the next CSV value from the supplied text
function GetNextCSV(const str: string; var index: Integer; var res: string;
  Sep: char=','; resultTrim: boolean=false): boolean;

/// retrieve one header from a low-level HTTP response
// - use e.g. location := GetOutHeader(Call,'location');
function GetOutHeader(const Call: TRestURIParams; const Name: string): string;

function TVarRecToString(v: TVarRec): string;

function UrlEncode(const aValue: string): string; overload;

/// encode name=value pairs as defined by RFC 3986
function UrlEncode(const aNameValueParameters: array of const): string; overload;


implementation

//------------------------------------------------------------------------------
/// marshall {result:...,id:...} and {result:...} body answers
function CallGetResult(const aCall: TRestURIParams; var outID: NativeInt): TJSObject;
var
  //doc: string;
  json: TJSON;
  jsonObj: TJSONObject;
begin
  // -- Process the JSValue in the calling procedure.
  outID := 0;

  if aCall.OutStatus <> HTTP_SUCCESS then
    exit;

  json := TJSON.Create;
  try
    jsonObj := json.Parse(aCall.OutBody);
    result := jsonObj.JSObject;
  finally
    json.Free;
  end;
end;
//------------------------------------------------------------------------------
// dedicated function using faster JavaScript library
function FindHeader(const Headers, Name: string): string;
var
  search, nameValue: string;
  searchLen: integer;
  arr: TStringDynArray;
begin
  if Headers = '' then
    exit('');
  search := UpperCase(Name);
  searchLen := Length(search);
  arr := SplitString(Headers, #13#10);

  //for nameValue in Headers.Split(#13#10) do
  for nameValue in arr do
    if uppercase(copy(nameValue, 1, searchLen)) = search then
      exit(copy(nameValue, searchLen + 1, length(nameValue)));
end;
//------------------------------------------------------------------------------
function GetNextCSV(const str: string; var index: Integer; var res: string;
  Sep: char=','; resultTrim: boolean=false): boolean;
var i,j,L: integer;
begin
  L := length(str);
  if index<=L then begin
    i := index;
    while i<=L do
      if str[i]=Sep then
        break else
        inc(i);
    j := index;
    index := i+1;
    if resultTrim then begin
      while (j<L) and (ord(str[j])<=32) do inc(j);
      while (i>j) and (ord(str[i-1])<=32) do dec(i);
    end;
    res := copy(str,j,i-j);
    result := true;
  end else
    result := false;
end;
//------------------------------------------------------------------------------
function GetOutHeader(const Call: TRestURIParams; const Name: string): string;
begin
//{$ifdef ISSMS_XHRISBUGGY} // retrieval from Call.XHR is buggy on some browers :(
  // see https://synopse.info/forum/viewtopic.php?pid=11730#p11730
//  if VarIsValidRef(Call.XHR) then
//    result := Call.XHR.getResponseHeader(Name);
//{$else}
  result := FindHeader(Call.OutHead, Name + ': ');
//{$endif}
end;
//------------------------------------------------------------------------------
function TVarRecToString(v: TVarRec): string;
begin
{ TODO : Extend TVarRecToString types. }

  if not hasValue(v.VJSValue) then exit('');

  //wasString := not (V.VType in
  //  [vtBoolean,vtInteger,vtInt64,vtCurrency,vtExtended,vtVariant]);
  if isString(v.VJSValue) then
    result := toString(v.VJSValue)
  else if isInteger(v.VJSValue) then
    result := IntToStr(toInteger(v.VJSValue))
  else if isNumber(v.VJSValue) then
    result := FloatToStr(toNumber(v.VJSValue))
  else result := '';
end;
//------------------------------------------------------------------------------
function UrlEncode(const aValue: string): string; overload;
begin
  result := encodeURIComponent(aValue);
end;
//------------------------------------------------------------------------------
function UrlEncode(const aNameValueParameters: array of const): string; overload;
var
  i, n, a: integer;
  name, value: string;
begin
  result := '';

  n := high(aNameValueParameters);
  if n > 0 then begin
    for a := 0 to n div 2 do begin
      name := TVarRecToString(aNameValueParameters[a * 2]);
      for i := 1 to length(name) do
        if not (ord(name[i]) in [ord('a')..ord('z'),ord('A')..ord('Z')]) then
          raise ERestException.CreateFmt(
            'UrlEncode() expect alphabetic names, not "%s"',[name]);
      value := TVarRecToString(aNameValueParameters[a * 2 + 1]);

      result := result + '&' + name + '=' + UrlEncode(value);
    end;
  end;
  if result <> '' then
    result[1] := '?';
end;




end.
