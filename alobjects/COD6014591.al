codeunit 6014591 "Network Test Library"
{

    trigger OnRun()
    begin
        case Method of
          'PING'   : Ping();
          'Invoke' : InvokeAddress();
        end;
    end;

    var
        ServerAddress: Text;
        ClientUsername: Text;
        Password: Text;
        Domain: Text;
        Method: Text;

    local procedure Ping()
    var
        Ping: DotNet Ping;
        PingReply: DotNet PingReply;
        IPStatus: DotNet IPStatus;
        Uri: DotNet Uri;
        Url: Text;
    begin
        Uri  := Uri.Uri(ServerAddress);
        Url  := Uri.Host;
        Ping := Ping.Ping();
        PingReply := Ping.Send(Url,3000);
        if not PingReply.Status.Equals(IPStatus.Success) then
          Error('No response from %1.',Url);
    end;

    local procedure InvokeAddress() ReturnStatus: Integer
    var
        HttpWebRequest: DotNet HttpWebRequest;
        HttpWebResponse: DotNet HttpWebResponse;
        RequestStream: DotNet StreamWriter;
    begin
        // Create XMLHTTP and SEND
        HttpWebRequest        := HttpWebRequest.Create(ServerAddress);
        HttpWebRequest.Method := 'GET';

        SetCredentials(HttpWebRequest);

        RequestStream   := HttpWebRequest.GetRequestStream();

        HttpWebResponse := HttpWebRequest.GetResponse();

        if HttpWebResponse.StatusCode <> 200 then Error('Bad response from %1 : %2.',ServerAddress,HttpWebResponse.StatusCode);
    end;

    local procedure SetCredentials(var HttpWebRequest: DotNet HttpWebRequest)
    var
        NetworkCredentials: DotNet NetworkCredential;
    begin
        if ClientUsername <> '' then begin
          NetworkCredentials := NetworkCredentials.NetworkCredential();
          NetworkCredentials.Password := Password;
          NetworkCredentials.UserName := ClientUsername;
          NetworkCredentials.Domain   := Domain;

          HttpWebRequest.Credentials  := NetworkCredentials;
        end;
    end;

    local procedure "-- Methods"()
    begin
    end;

    procedure PingAddress(Url: Text): Boolean
    var
        This: Codeunit "Network Test Library";
    begin
        This.UseServerAddress := Url;
        This.UseMethod        := 'Ping';
        exit(This.Run())
    end;

    procedure InvokeAddres(Url: Text;Domain: Text;Username: Text;Password: Text): Boolean
    var
        This: Codeunit "Network Test Library";
    begin
        This.UseMethod        := 'Invoke';
        This.UseServerAddress := Url;
        This.UseUsername      := Username;
        This.UsePassword      := Password;
        This.UseDomain        := Domain;
        exit(This.Run());
    end;

    procedure "-- Mutators"()
    begin
    end;

    procedure UseMethod(MethodIn: Text)
    begin
        Method := UpperCase(MethodIn);
        if not (Method in ['PING','INVOKE']) then
          Error('Illegal method. Valid methods at Invoke or Ping.');
    end;

    procedure UseServerAddress(ServerAddressIn: Text)
    begin
        ServerAddress := ServerAddressIn;
    end;

    procedure UseUsername(UsernameIn: Text)
    begin
        ClientUsername := UsernameIn;
    end;

    procedure UsePassword(PasswordIn: Text)
    begin
        Password := PasswordIn;
    end;

    procedure UseDomain(DomainIn: Text)
    begin
        Domain   := DomainIn;
    end;
}

