codeunit 6060084 "NPR POS HTML Disp. Session"
{
    Access = Internal;
    SingleInstance = true;

    var
        MediaDownloaded: Boolean;
        HwcGUIDs: JsonObject;
        LastTicketNo: Code[20];

    procedure SetDidDownload(didDownload: Boolean)
    begin
        MediaDownloaded := didDownload;
    end;

    procedure MediaIsDownloaded(): Boolean
    begin
        exit(MediaDownloaded);
    end;

    procedure AddGuid(Guid: Guid; ReqType: Text): Boolean
    begin
        exit(HwcGUIDs.Add(Guid, ReqType));
    end;

    [TryFunction]
    procedure PopGuid(Guid: Guid; var ReqType: Text)
    var
        JToken: JsonToken;
    begin
        HwcGUIDs.Get(Guid, JToken);
        HwcGUIDs.Remove(Guid);
        ReqType := JToken.AsValue().AsText();
    end;

    procedure SetLastTicketNo(TicketNo: Code[20])
    begin
        LastTicketNo := TicketNo;
    end;

    procedure GetLastTicketNo(): Code[20]
    begin
        exit(LastTicketNo);
    end;

    procedure ClearLastTicketNo()
    begin
        Clear(LastTicketNo);
    end;
}