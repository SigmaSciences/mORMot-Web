unit JS_SHA256;

{-------------------------------------------------------------------------------

pas2js interface unit for https://github.com/emn178/js-sha256

Copyright (c) 2022 Sigma Sciences Ltd.

Originator: Robert L S Devine

-------------------------------------------------------------------------------}

{******************************************************************************}
{                                                                              }
{     Licensed under the Apache License, Version 2.0 (the "License");          }
{     you may not use this file except in compliance with the License.         }
{     You may obtain a copy of the License at                                  }
{                                                                              }
{         http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                              }
{     Unless required by applicable law or agreed to in writing, software      }
{     distributed under the License is distributed on an "AS IS" BASIS,        }
{     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{     See the License for the specific language governing permissions and      }
{     limitations under the License.                                           }
{                                                                              }
{******************************************************************************}

{$modeswitch externalclass}

interface

uses
  JS,

  Web.mORMot.StringUtils;


function Sha256(s: string): string; external name 'sha256';

function Sha256Encoded(const s: string; encodingType: TEncodingType): string;
function SHA256FromArray(const Values: array of string; encodingType: TEncodingType): string;

implementation


//------------------------------------------------------------------------------
function Sha256Encoded(const s: string; encodingType: TEncodingType): string;
var
  bs: string;
begin
  if encodingType = etHttp then
    bs := TextToHttpBody(s)
  else
    bs := s;

  result := Sha256(bs);
end;
//------------------------------------------------------------------------------
function SHA256FromArray(const Values: array of string;
  encodingType: TEncodingType): string;
var
  s: string;
  st: string;
  bs: string;
begin
  for s in Values do
  begin
    if encodingType = etHttp then
      bs := TextToHttpBody(s)
    else
      bs := s;
    st := st + bs;
  end;

  result := Sha256(st);
end;

end.
