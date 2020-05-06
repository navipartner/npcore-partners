codeunit 6184864 "Mock Request"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created
    // 
    // only used for development and automated tests
    // object outdated in BC (once interfaces are available)

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

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

