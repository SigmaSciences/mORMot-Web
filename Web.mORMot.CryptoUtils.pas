unit Web.mORMot.CryptoUtils;

{-------------------------------------------------------------------------------

Adapted from mORMot v1 SynCrossPlatformCrypto.pas.

See original file for copyright and licence information at:

https://github.com/synopse/mORMot

-------------------------------------------------------------------------------}

interface

uses
  Web.mORMot.Types;

/// compute the zlib/deflate crc32 hash value on a supplied ASCII-7 buffer
function crc32ascii(aCrc32: hash32; const buf: string): hash32;

function shr0(c: hash32): hash32;



var
  /// table used by crc32() function
  // - table content is created from code in initialization section below
  crc32tab: array of hash32;

implementation

//------------------------------------------------------------------------------
function crc32(aCrc32: hash32; const buf: array of byte): hash32;
var i: integer;
begin
  result := shr0(not aCRC32);
  for i := 0 to length(buf)-1 do
    result := crc32tab[(result xor buf[i]) and $ff] xor (result shr 8);
  result := shr0(not result);
end;
//------------------------------------------------------------------------------
function crc32ascii(aCrc32: hash32; const buf: string): hash32;
var
  i: integer;
begin
  result := shr0(not aCRC32);
  for i := 1 to length(buf) do
    result := crc32tab[(result xor ord(buf[i])) and $ff] xor (result shr 8);
  result := shr0(not result);
end;
//------------------------------------------------------------------------------
function shr0(c: hash32): hash32;
begin
  result := c shr 0;
end;
//------------------------------------------------------------------------------
procedure InitCrc32Tab;
var
  i,n,crc: hash32;
begin
  for i := 0 to 255 do begin
    crc := i;
    for n := 1 to 8 do
      if (crc and 1) <> 0 then
        // $edb88320 from polynomial p=(0,1,2,4,5,7,8,10,11,12,16,22,23,26)
        crc := shr0((crc shr 1) xor $edb88320)
      else
        crc := crc shr 1;

    crc32tab[i] := crc;
  end;
end;




initialization
  InitCrc32Tab;

end.
