unit Web.mORMot.StringUtils;

{-------------------------------------------------------------------------------

Adapted from mORMot v1 CrossPlatform units.

See original file for copyright and licence information at:

https://github.com/synopse/mORMot

-------------------------------------------------------------------------------}

interface

uses
  JS,
  Types,

  Web.mORMot.Types;

type
  TEncodingType = (etNone, etHttp);

  TStringArrayHelper = record helper for TStringDynArray
    function Join(const separator: string): string;
    procedure Add(const s: string);
    procedure Clear;
  end;



/// convert a text into UTF-8 binary buffer
function TextToHttpBody(const Text: string): THttpBody;

/// convert a UTF-8 binary buffer into texts
procedure HttpBodyToText(const Body: THttpBody; var Text: string);

implementation

//------------------------------------------------------------------------------
function TextToHttpBody(const Text: string): THttpBody;
begin
  // http://ecmanaut.blogspot.fr/2006/07/encoding-decoding-utf8-in-javascript.html
  //asm
  //  @result=unescape(encodeURIComponent(@Text));
  //end;

  result := encodeURIComponent(Text);
end;
//------------------------------------------------------------------------------
procedure HttpBodyToText(const Body: THttpBody; var Text: string);
begin
  Text := decodeURIComponent(Body);
end;


{ TStringArrayHelper }

//------------------------------------------------------------------------------
procedure TStringArrayHelper.Add(const s: string);
var
  l: integer;
begin
  { TODO : TStringArrayHelper.Add -> make more efficient? }
  l := length(self);
  SetLength(self, l + 1);
  self[l] := s;
end;
//------------------------------------------------------------------------------
procedure TStringArrayHelper.Clear;
begin
  SetLength(self, 0);
end;
//------------------------------------------------------------------------------
function TStringArrayHelper.Join(const separator: string): string;
var
  i: integer;
  l: integer;
begin
  l := length(self);
  for i := 0 to l - 2 do
    result := result + self[i] + separator;
  result := result + self[l - 1];
end;

end.
