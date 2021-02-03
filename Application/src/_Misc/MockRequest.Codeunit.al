codeunit 6184864 "NPR Mock Request"
{
    // only used for development and automated tests
    // object outdated in BC (once interfaces are available)
    SingleInstance = true;

    var
        Response: Text;

    procedure SetResponse(ResponseText: Text)
    begin
        Response := ResponseText;
    end;

    procedure GetResponse(): Text
    begin
        exit(Response);
    end;
}

