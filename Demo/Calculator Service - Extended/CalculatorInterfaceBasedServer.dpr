program CalculatorInterfaceBasedServer;

{$APPTYPE CONSOLE}

{$I mormot.defines.inc}
uses
  {$I mormot.uses.inc}
  SysUtils,
  mormot.core.base,
  mormot.core.os,
  mormot.core.log,
  mormot.rest.server,
  mormot.rest.memserver,
  mormot.orm.core,
  mormot.db.raw.sqlite3,
  mormot.rest.http.server,
  mormot.soa.core,
  mormot.soa.server,
  data in 'data.pas',
  server in 'server.pas';

var
  aModel: TORMModel;
  CalcServer: TRestServer;
  HttpServer: TRestHttpServer;
  LogFamily: TSynLogFamily;
  //factory: TServiceFactoryServer;
begin
  LogFamily := SQLite3Log.Family;
  LogFamily.Level := LOG_VERBOSE;
  LogFamily.PerThreadLog := ptIdentifiedInOneFile;
  LogFamily.EchoToConsole := LOG_VERBOSE;

  aModel := TORMModel.Create([], ROOT_NAME);
  try
    // -- Initialize a TObjectList-based database engine
    CalcServer := TRestServerFullMemory.Create(aModel, 'test.json', false, true);
    //factory := CalcServer.Services.Info(TypeInfo(ICalculator)) as TServiceFactoryServer;

    try
      CalcServer.ServiceDefine(TCalculatorService, [ICalculator], sicShared);

      HttpServer := TRestHttpServer.Create(HttpPort, [CalcServer], '+', HTTP_DEFAULT_MODE);
      HttpServer.AccessControlAllowOrigin := '*';
      try
        Writeln('Server started on port ' + HttpPort);
        Readln;
      finally
        HttpServer.Free;
      end;
    finally
      CalcServer.Free;
    end;
  finally
    aModel.Free;
  end;
end.




