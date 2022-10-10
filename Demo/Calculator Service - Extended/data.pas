unit data;

interface

{$I mormot.defines.inc}
uses
  mormot.core.base,
  mormot.core.data,
  mormot.core.json,
  mormot.core.interfaces,
  mormot.orm.base,
  mormot.orm.core;

const
  HttpPort = '888';
  ROOT_NAME = 'root';


type
  ICalculator = interface(IInvokable)
    ['{9A60C8ED-CEB2-4E09-87D4-4A16F496E5FE}']
    function Add(n1, n2: integer): integer;
    function ArrayValue(arrJSON: RawUTF8; ix: integer): variant;
    function CountArray(jsn: RawUTF8): integer;
    function SumArray(jsn: RawUTF8): double;
  end;



implementation




initialization

  TInterfaceFactory.RegisterInterfaces([TypeInfo(ICalculator)]);
end.
