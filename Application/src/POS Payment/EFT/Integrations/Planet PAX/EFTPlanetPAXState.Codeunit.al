codeunit 6150932 "NPR EFT Planet Pax State"
{
    Access = Internal;
    SingleInstance = True;

    var
        EftTaskStatus: Dictionary of [Text, Integer];
        EftTaskResponse: Dictionary of [Text, Text];
        EftTaskRequest: Dictionary of [Text, Text];
        AbortCount: Integer;

    procedure SetEftReqStatus(EftRef: Integer; Status: Enum "NPR EFT Planet PAX Status")
    begin
        SetEftReqStatus(Format(EftRef), Status);
    end;

    procedure SetEftReqStatus(EftRef: Text; Status: Enum "NPR EFT Planet PAX Status")
    begin
        EftTaskStatus.Set(EftRef, Status.AsInteger())
    end;

    procedure AddEftReqResponse(EftRef: Integer; Response: Text)
    begin
        AddEftReqResponse(Format(EftRef), Response);
    end;

    procedure AddEftReqResponse(EftRef: Text; Response: Text)
    begin
        EftTaskResponse.Add(EftRef, Response);
    end;

    procedure AddEftReqRequest(EftRef: Integer; Request: Text)
    begin
        AddEftReqRequest(Format(EftRef), Request);
    end;

    procedure AddEftReqRequest(EftRef: Text; Request: Text)
    begin
        EftTaskRequest.Add(EftRef, Request);
    end;

    procedure GetEftReqStatus(EftRef: Integer): Enum "NPR EFT Planet PAX Status"
    begin
        exit(GetEftReqStatus(Format(EftRef)));
    end;

    procedure GetEftReqStatus(EftRef: Text): Enum "NPR EFT Planet PAX Status"
    begin
        if (EftTaskStatus.ContainsKey(EftRef)) then
            exit("NPR EFT Planet PAX Status".FromInteger(EftTaskStatus.Get(EftRef)))
        else
            exit("NPR EFT Planet PAX Status"::Uninitialized);
    end;

    procedure GetResponse(EftRef: Integer): Text
    begin
        exit(GetResponse(Format(EftRef)));
    end;

    procedure GetResponse(EftRef: Text): Text
    begin
        exit(EftTaskResponse.Get(EftRef));
    end;

    procedure GetRequest(EftRef: Integer): Text
    begin
        exit(GetRequest(Format(EftRef)));
    end;

    procedure GetRequest(EftRef: Text): Text
    begin
        exit(EftTaskRequest.Get(EftRef));
    end;

    procedure GetAndIncrementAbortCount(): Integer
    var
        tmp: Integer;
    begin
        tmp := AbortCount;
        AbortCount := AbortCount + 1;
        exit(tmp);
    end;

    procedure ClearState()
    begin
        clear(EftTaskStatus);
        clear(EftTaskResponse);
        clear(EftTaskRequest);
        AbortCount := 0;
    end;
}