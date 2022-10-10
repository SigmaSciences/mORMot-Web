unit Web.mORMot.Routing;

{-------------------------------------------------------------------------------

Adapted from mORMot v1 CrossPlatform units.

See original file for copyright and licence information at:

https://github.com/synopse/mORMot

Client-side routing classes derived from TRestRoutingAbstract.

History:

07/09/2022: Implement simple REST protocol subclass. Ignore RPC subclass for now.

-------------------------------------------------------------------------------}

interface



type
  /// class used to determine the protocol of interface-based services
  // - see TRestRoutingREST. TSQLRestRoutingJSON_RPC
  // for overridden methods - NEVER set this abstract TSQLRestRoutingAbstract
  // class on TSQLRest.ServicesRouting property !
  TRestRoutingAbstract = class
  public
    /// at Client Side, compute URI and BODY according to the routing scheme
    // - abstract implementation which is to be overridden
    // - as input, "method" should be the method name to be executed for "uri",
    // "params" should contain the incoming parameters as JSON array (with []),
    // and "clientDriven" ID should contain the optional Client ID value
    // - at output, should update the HTTP "uri" corresponding to the proper
    // routing, and should return the corresponding HTTP body within "sent"
    class procedure ClientSideInvoke(var uri: string;
      const method, params, clientDrivenID: string; var sent: string); virtual; abstract;
  end;

  /// used to define the protocol of interface-based services
  TRestRoutingAbstractClass = class of TRestRoutingAbstract;

  /// default simple REST protocol for interface-based services
  // - this is the default protocol used by TSQLRest
  TRestRoutingREST = class(TRestRoutingAbstract)
  public
    /// at Client Side, compute URI and BODY according to RESTful routing scheme
    // - e.g. on input uri='root/Calculator', method='Add', params='[1,2]' and
    // clientDrivenID='1234' -> on output uri='root/Calculator.Add/1234' and
    // sent='[1,2]'
    class procedure ClientSideInvoke(var uri: string;
      const method, params, clientDrivenID: string; var sent: string); override;
  end;



implementation


{ TRestRoutingREST }

//------------------------------------------------------------------------------
class procedure TRestRoutingREST.ClientSideInvoke(var uri: String;
  const method: String; const params: String; const clientDrivenID: String;
  var sent: String);
begin
  if clientDrivenID <> '' then
    uri := uri + '.' +method + '/' +clientDrivenID else
    uri := uri + '.' + method;
  sent := params; // we may also encode them within the URI
end;

end.
