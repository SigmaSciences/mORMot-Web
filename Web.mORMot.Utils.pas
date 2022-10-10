unit Web.mORMot.Utils;

{-------------------------------------------------------------------------------

Adapted from mORMot v1 CrossPlatform units.

See original file for copyright and licence information at:

https://github.com/synopse/mORMot

-------------------------------------------------------------------------------}

interface

uses
  SysUtils,

  JS,
  Web,

  Web.mORMot.Types,
  Web.JSTypes;


/// compute a TTimeLog value from Delphi date/time type
function DateTimeToTTimeLog(Value: TDateTime): TTimeLog;

/// convert a TTimeLog value into the Delphi date/time type
function TTimeLogToDateTime(Value: TTimeLog): TDateTime;

/// compute the ISO-8601 JSON text representation of the current date/time value
// - e.g. "2015-06-27T20:59:29"
function NowToIso8601: string;

/// compute the unquoted ISO-8601 text representation of a date/time value
// - e.g. 'YYYY-MM-DD' 'Thh:mm:ss' or 'YYYY-MM-DDThh:mm:ss'
// - if Date is 0, will return ''
function DateTimeToIso8601(Value: TDateTime): string;



implementation

//------------------------------------------------------------------------------
function DateTimeToTTimeLog(Value: TDateTime): TTimeLog;
var
  HH,MM,SS,MS,Y,M,D: Word;
  //V: Int64;
begin
  DecodeTime(Value, HH, MM, SS, MS);
  DecodeDate(Value, Y, M, D);
  //{$ifdef ISSMS} // JavaScript truncates to 32 bit binary
  result := SS+MM*$40+(HH+D*$20+M*$400+Y*$4000-$420)*$1000;
  //{$else}
  //V := HH+D shl 5+M shl 10+Y shl 14-(1 shl 5+1 shl 10);
  //result := SS+MM shl 6+V shl 12;
  //{$endif}
end;
//------------------------------------------------------------------------------
function TTimeLogToDateTime(Value: TTimeLog): TDateTime;
var
  Y: cardinal;
  M: cardinal;
  D: cardinal;
  Time: TDateTime;
begin
  //{$ifdef ISSMS} // JavaScript truncates to 32 bit binary
  Y := (Value div $4000000) and 4095;
  M := 1 + (Value shr (6+6+5+5)) and 15;
  D := 1 + (Value shr (6+6+5)) and 31;
  //{$else}
  //Y := (Value shr (6+6+5+5+4)) and 4095;
  //{$endif}
  if (Y = 0) or not TryEncodeDate(Y, M, D, {DateTimeZone.UTC,} result) then
    result := 0;
  if (Value and (1 shl (6+6+5)-1)<>0) and
     TryEncodeTime((Value shr (6+6)) and 31,
       (Value shr 6) and 63,Value and 63, 0, Time) then
    result := result + Time;
end;
//------------------------------------------------------------------------------
function NowToIso8601: string;
begin
  result := DateTimeToIso8601(Now);
end;
//------------------------------------------------------------------------------
function DateTimeToIso8601(Value: TDateTime): string;
begin // e.g. YYYY-MM-DD Thh:mm:ss or YYYY-MM-DDThh:mm:ss
  if Value=0 then
    result := '' else
  if frac(Value)=0 then
    result := FormatDateTime('yyyy"-"mm"-"dd',Value) else
  if trunc(Value)=0 then
    result := FormatDateTime('"T"hh":"nn":"ss',Value) else
    result := FormatDateTime('yyyy"-"mm"-"dd"T"hh":"nn":"ss',Value);
end;



end.
