/// cryptographic cross-platform units
// - this unit is a part of the freeware Synopse mORMot framework,
// licensed under a MPL/GPL/LGPL tri-license; version 1.18
unit Web.mORMot.SHA256;

{-------------------------------------------------------------------------------

Adapted from mORMot v1 SynCrossPlatformCrypto.pas.

See below for copyright and licence information.

-------------------------------------------------------------------------------}


{ TODO : Remove dead code. }
{ TODO : Test with DWScript/SMS/Quartex. }
{ TODO : Fix the range check error warnings? }

{
    This file is part of Synopse mORMot framework.

    Synopse mORMot framework. Copyright (C) 2022 Arnaud Bouchez
      Synopse Informatique - https://synopse.info

  *** BEGIN LICENSE BLOCK *****
  Version: MPL 1.1/GPL 2.0/LGPL 2.1

  The contents of this file are subject to the Mozilla Public License Version
  1.1 (the "License"); you may not use this file except in compliance with
  the License. You may obtain a copy of the License at
  http://www.mozilla.org/MPL

  Software distributed under the License is distributed on an "AS IS" basis,
  WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
  for the specific language governing rights and limitations under the License.

  The Original Code is Synopse mORMot framework.

  The Initial Developer of the Original Code is Arnaud Bouchez.

  Portions created by the Initial Developer are Copyright (C) 2022
  the Initial Developer. All Rights Reserved.

  Contributor(s):
  
  Alternatively, the contents of this file may be used under the terms of
  either the GNU General Public License Version 2 or later (the "GPL"), or
  the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
  in which case the provisions of the GPL or the LGPL are applicable instead
  of those above. If you wish to allow use of your version of this file only
  under the terms of either the GPL or the LGPL, and not to allow others to
  use your version of this file under the terms of the MPL, indicate your
  decision by deleting the provisions above and replace them with the notice
  and other provisions required by the GPL or the LGPL. If you do not delete
  the provisions above, a recipient may use your version of this file under
  the terms of any one of the MPL, the GPL or the LGPL.

  ***** END LICENSE BLOCK *****

  *******************************************************************
  Modified by Robert L. S. Devine to work with TMS WebCore Sept. 2022.

}



interface


uses
  SysUtils,

  Web,     // -- WebCore unit.

  Web.mORMot.Types,
  Web.mORMot.StringUtils,
  Web.mORMot.CryptoUtils;


type
  hash32 = integer;


type
  /// internal buffer for SHA256 hashing
  TSHA256Buffer = array[0..63] of hash32;
  /// internal work buffer for SHA256 hashing
  TSHAHash = record
    A,B,C,D,E,F,G,H: integer;  //hash32;
  end;
  /// class for SHA256 hashing
  TSHA256 = class
  private
    // Working hash
    Hash: TSHAHash;
    // 64bit msg length
    MLen: integer;
    // Block buffer
    Buffer: TSHA256Buffer;
    // Index in buffer
    Index: integer;
    // used by Update and Finalize
    procedure Compress;
  public
    /// initialize SHA256 context for hashing
    constructor Create;
{$ifndef ISDWS}
    /// update the SHA256 context with some data
    procedure Update(const buf: array of byte); overload;
{$endif}
    /// update the SHA256 context with 8 bit ascii data (e.g. UTF-8)
    procedure Update(const ascii: string); overload;
    /// finalize and compute the resulting SHA256 hash Digest of all data
    // affected to Update() method
    // - returns the data as Hexadecimal
    function Finalize: string;
  end;

{$ifndef ISDWS}
/// compute SHA256 hexa digest of a supplied buffer
function SHA256(const buf: array of byte): string; overload;
{$endif}

/// compute SHA256 hexa digest of a supplied 8 bit ascii data (e.g. UTF-8)
function SHA256(const buf: string): string; overload;

/// hash the supplied text values after UTF-8 encoding
// - as expected by the framework server
function SHA256Compute(const Values: array of string): string;


implementation

const
  K: TSHA256Buffer = (
   $428a2f98, $71374491, $b5c0fbcf, $e9b5dba5, $3956c25b, $59f111f1,
   $923f82a4, $ab1c5ed5, $d807aa98, $12835b01, $243185be, $550c7dc3,
   $72be5d74, $80deb1fe, $9bdc06a7, $c19bf174, $e49b69c1, $efbe4786,
   $0fc19dc6, $240ca1cc, $2de92c6f, $4a7484aa, $5cb0a9dc, $76f988da,
   $983e5152, $a831c66d, $b00327c8, $bf597fc7, $c6e00bf3, $d5a79147,
   $06ca6351, $14292967, $27b70a85, $2e1b2138, $4d2c6dfc, $53380d13,
   $650a7354, $766a0abb, $81c2c92e, $92722c85, $a2bfe8a1, $a81a664b,
   $c24b8b70, $c76c51a3, $d192e819, $d6990624, $f40e3585, $106aa070,
   $19a4c116, $1e376c08, $2748774c, $34b0bcb5, $391c0cb3, $4ed8aa4a,
   $5b9cca4f, $682e6ff3, $748f82ee, $78a5636f, $84c87814, $8cc70208,
   $90befffa, $a4506ceb, $bef9a3f7, $c67178f2);

procedure TSHA256.Compress;
var W: TSHA256Buffer;
    H: TSHAHash;
    i: integer;
    t1, t2: hash32;
begin
  H := Hash;
  for i := 0 to 15 do
    W[i]:= shr0((Buffer[i*4] shl 24)or(Buffer[i*4+1] shl 16)or
                (Buffer[i*4+2] shl 8)or Buffer[i*4+3]);

  for i := 16 to 63 do
    W[i] := shr0((((W[i-2]shr 17)or(W[i-2]shl 15))xor((W[i-2]shr 19)or(W[i-2]shl 13))
      xor (W[i-2]shr 10))+W[i-7]+(((W[i-15]shr 7)or(W[i-15]shl 25))
      xor ((W[i-15]shr 18)or(W[i-15]shl 14))xor(W[i-15]shr 3))+W[i-16]);

  for i := 0 to high(W) do begin
    t1 := shr0(H.H+(((H.E shr 6)or(H.E shl 26)) xor ((H.E shr 11)or(H.E shl 21)) xor
      ((H.E shr 25) or (H.E shl 7)))+((H.E and H.F) xor (not H.E and H.G)) + K[i] + W[i]);


    t2 := shr0((((H.A shr 2) or (H.A shl 30)) xor ((H.A shr 13) or (H.A shl 19)) xor
      ((H.A shr 22) xor (H.A shl 10))) + ((H.A and H.B) xor (H.A and H.C) xor (H.B and H.C)));

    H.H := H.G; H.G := H.F; H.F := H.E; H.E := shr0(H.D+t1);
    H.D := H.C; H.C := H.B; H.B := H.A; H.A := shr0(t1+t2);
  end;

  Hash.A := shr0(Hash.A+H.A);
  Hash.B := shr0(Hash.B+H.B);
  Hash.C := shr0(Hash.C+H.C);
  Hash.D := shr0(Hash.D+H.D);
  Hash.E := shr0(Hash.E+H.E);
  Hash.F := shr0(Hash.F+H.F);
  Hash.G := shr0(Hash.G+H.G);
  Hash.H := shr0(Hash.H+H.H);
end;

constructor TSHA256.Create;
begin
  Hash.A := $6a09e667;
  Hash.B := $bb67ae85;
  Hash.C := $3c6ef372;
  Hash.D := $a54ff53a;
  Hash.E := $510e527f;
  Hash.F := $9b05688c;
  Hash.G := $1f83d9ab;
  Hash.H := $5be0cd19;
end;


{$ifndef ISDWS}
procedure TSHA256.Update(const buf: array of byte);
var Len, aLen, i: integer;
    DataNdx: integer;
begin
  Len := length(buf);
  DataNdx := 0;
  inc(MLen,Len shl 3);
  while Len>0 do begin
    aLen := 64-Index;
    if aLen<=Len then begin
      for i := 0 to aLen-1 do
        Buffer[Index+i] := buf[DataNdx+i];
      dec(Len,aLen);
      inc(DataNdx,aLen);
      Compress;
      Index:= 0;
    end else begin
      for i := 0 to Len-1 do
        Buffer[Index+i] := buf[DataNdx+i];
      inc(Index,Len);
      break;
    end;
  end;
end;
{$endif ISDWS}


procedure TSHA256.Update(const ascii: string);
var Len, aLen, i: integer;
    DataNdx: integer;
begin
  Len := length(ascii);

  DataNdx := 1;
  inc(MLen,Len shl 3);
  while Len>0 do begin
    aLen := 64-Index;
    if aLen<=Len then begin
      for i := 0 to aLen-1 do
        Buffer[Index+i] := ord(ascii[DataNdx+i]);
      dec(Len,aLen);
      inc(DataNdx,aLen);
      Compress;
      Index:= 0;
    end else begin
      for i := 0 to Len-1 do
        Buffer[Index+i] := ord(ascii[DataNdx+i]);
      inc(Index,Len);
      break;
    end;
  end;
end;

function TSHA256.Finalize: string;
var i: integer;
begin
  // Message padding
  // 1. append bit '1' after Buffer

  Buffer[Index]:= $80;
  for i := Index+1 to 63 do
    Buffer[i] := 0;
  // 2. Compress if more than 448 bits, (no room for 64 bit length)
  if Index>=56 then begin
    Compress;
    for i := 0 to 59 do
      Buffer[i] := 0;
  end;
  // Write 64 bit Buffer length into the last bits of the last block
  // (in big endian format) and do a final compress
  Buffer[60] := (MLen and $ff000000)shr 24;
  Buffer[61] := (MLen and $ff0000)shr 16;
  Buffer[62] := (MLen and $ff00)shr 8;
  Buffer[63] := MLen and $ff;
  Compress;

  // Hash -> Digest to big endian format
  result := LowerCase(IntToHex(Hash.A,8)+IntToHex(Hash.B,8)+IntToHex(Hash.C,8)+
    IntToHex(Hash.D,8)+IntToHex(Hash.E,8)+IntToHex(Hash.F,8)+IntToHex(Hash.G,8)+
    IntToHex(Hash.H,8));
end;


{$ifndef ISDWS}
function SHA256(const buf: array of byte): string;
var SHA: TSHA256;
begin
  SHA := TSHA256.Create;
  try
    SHA.Update(buf);
    result := SHA.Finalize;
  finally
    SHA.Free;
  end;
end;
{$endif}


function SHA256(const buf: string): string;
var SHA: TSHA256;
begin
  SHA := TSHA256.Create;
  try
    SHA.Update(buf);
    result := SHA.Finalize;
  finally
    SHA.Free;
  end;
end;
//------------------------------------------------------------------------------
function SHA256Compute(const Values: array of string): string;
var buf: THttpBody;
    a: integer;
    sha: TSHA256;
begin
  sha := TSHA256.Create;
  try
    for a := 0 to high(Values) do begin
      buf := TextToHttpBody(Values[a]);
      sha.Update(buf);
    end;
    result := sha.Finalize;
  finally
    sha.Free;
  end;
end;


end.
