unit UnitMain;

interface

uses
  System.SysUtils, System.Classes, JS, Web, WEBLib.Graphics, WEBLib.Controls,
  WEBLib.Forms, WEBLib.Dialogs, WEBLib.StdCtrls, Vcl.Controls, Vcl.StdCtrls,
  WebLib.JSON,

  Types,   // Dynamic array types defined here (WebCore).
  Web.mORMot.Types,
  Web.mORMot.Rest,
  Web.mORMotClient, WEBLib.ExtCtrls;

type
  TMainForm = class(TWebForm)
    ConnectButton: TWebButton;
    WebLabel1: TWebLabel;
    ebUserName: TWebEdit;
    WebLabel2: TWebLabel;
    ebPassword: TWebEdit;
    DisconnectButton: TWebButton;
    MainPanel: TWebPanel;
    WebLabel3: TWebLabel;
    StatusLabel: TWebLabel;
    AddButton: TWebButton;
    WebEdit1: TWebEdit;
    WebEdit2: TWebEdit;
    AddEdit: TWebEdit;
    SumButton: TWebButton;
    SumEdit: TWebEdit;
    CountButton: TWebButton;
    CountEdit: TWebEdit;
    ValueButton: TWebButton;
    ValueEdit: TWebEdit;
    IndexEdit: TWebEdit;
    procedure ConnectButtonClick(Sender: TObject);
    procedure AddButtonClick(Sender: TObject);
    procedure SumButtonClick(Sender: TObject);
    procedure CountButtonClick(Sender: TObject);
    procedure ValueButtonClick(Sender: TObject);
    procedure DisconnectButtonClick(Sender: TObject);
  private
    { Private declarations }
  protected
    Client: TRestClientURI;
  public
    { Public declarations }
  end;


  //TDynDoubleArray = array of double;

  TArrayRec = packed record
    Arr: TDoubleDynArray;
    VarArr: TJSValueDynArray;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

//------------------------------------------------------------------------------
procedure TMainForm.ConnectButtonClick(Sender: TObject);
var
  userName: string;
  password: string;
begin
  userName := ebUserName.Text;
  password := ebPassword.Text;

  if Client = nil then
    // -- GetClient is defined in mORMotClient.pas
    GetClient('127.0.0.1', userName, password,
      procedure(aClient: TRestClientURI)
      begin
        console.log('Connected');
        Client := aClient;

        StatusLabel.Caption := 'Connected';
        MainPanel.Visible := true;
        ConnectButton.Enabled := false;
        DisconnectButton.Enabled := true;
      end,
      procedure(aClient: TRestClientURI)
      begin
        console.log('Unable to connect to server');
      end)
  else
  begin
    console.log('Already connected');
    Showmessage('Already connected');
  end;
end;
//------------------------------------------------------------------------------
procedure TMainForm.CountButtonClick(Sender: TObject);
var
  rec: TArrayRec;
  jsn: RawUTF8;
begin
  SetLength(rec.VarArr, 5);
  rec.VarArr[0] := 'abc';
  rec.VarArr[1] := 99;
  rec.VarArr[2] := 5.5;
  rec.VarArr[3] := 'xyz';
  rec.VarArr[4] := 33;

  jsn := TJSJSON.stringify(rec);

  TServiceCalculator.Create(Client).CountArray(
    jsn,
    procedure(res: integer)
    begin
      CountEdit.Text := IntToStr(res);
    end,
    procedure(Client: TRestClientURI)
    begin
      console.log('Error calling the CountArray method');
    end);
end;
//------------------------------------------------------------------------------
procedure TMainForm.AddButtonClick(Sender: TObject);
begin
  TServiceCalculator.Create(Client).Add(
    StrToInt(WebEdit1.Text), StrToInt(WebEdit2.Text),
    procedure(res: integer)
    begin
      AddEdit.Text := IntToStr(res);
    end,
    procedure(Client: TRestClientURI)
    begin
      console.log('Error calling the Add method');
      //ShowMessage('Error calling the Add method');
    end);
end;
//------------------------------------------------------------------------------
procedure TMainForm.SumButtonClick(Sender: TObject);
var
  i: integer;
  //arrJS: array of double;
  rec: TArrayRec;
  jsn: RawUTF8;
begin
  {SetLength(arrJS, 10);
  for i := 0 to 9 do
    arrJS[i] := i + 1.1;}

  SetLength(rec.Arr, 10);
  for i := 0 to 9 do
    rec.Arr[i] := i + 1.1;

  jsn := TJSJSON.stringify(rec);

  TServiceCalculator.Create(Client).SumArray(
    jsn,
    procedure(res: double)
    begin
      SumEdit.Text := FloatToStr(res);
    end,
    procedure(Client: TRestClientURI)
    begin
      console.log('Error calling the SumArray method');
    end);
end;
//------------------------------------------------------------------------------
procedure TMainForm.ValueButtonClick(Sender: TObject);
var
  arr: TJSValueDynArray;
  ix: integer;
  jsn: RawUTF8;
begin
  SetLength(arr, 5);
  arr[0] := 'abc';
  arr[1] := 99;
  arr[2] := 5.5;
  arr[3] := 'xyz';
  arr[4] := 33;

  ix := StrToInt(IndexEdit.Text);
  jsn := TJSJSON.stringify(arr);

  TServiceCalculator.Create(Client).ArrayValue(
    jsn, ix,
    procedure(res: string)
    begin
      ValueEdit.Text := res;
    end,
    procedure(Client: TRestClientURI)
    begin
      console.log('Error calling the ArrayValue method');
    end);
end;
//------------------------------------------------------------------------------
procedure TMainForm.DisconnectButtonClick(Sender: TObject);
begin
  MainPanel.Visible := false;
  StatusLabel.Caption := 'Disconnected';
  ConnectButton.Enabled := true;
  DisconnectButton.Enabled := false;

  AddEdit.Text := '';
  SumEdit.Text := '';
  CountEdit.Text := '';
  ValueEdit.Text := '';

  console.log('Disconnected');
  Client.Free;
  Client := nil;
end;

end.
