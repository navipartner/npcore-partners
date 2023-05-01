codeunit 6060084 "NPR POS HTML Disp. Session"
{
    Access = Internal;
    SingleInstance = true;

    var
        hwcGUIDs: JsonObject;
        lastTicketNo: Code[20];


    procedure PeekGuid(Guid: Guid): Boolean
    begin
        exit(hwcGUIDs.Contains(Guid));
    end;

    procedure AddGuid(Guid: Guid): Boolean
    begin
        exit(hwcGUIDs.Add(Guid, ''))
    end;

    procedure PopGuid(Guid: Guid): Boolean
    begin
        exit(hwcGUIDs.Remove(Guid));
    end;

    procedure SetLastTicketNo(TicketNo: Code[20])
    begin
        lastTicketNo := TicketNo;
    end;

    procedure GetLastTicketNo(): Code[20]
    begin
        exit(lastTicketNo);
    end;

    procedure ClearLastTicketNo()
    begin
        Clear(lastTicketNo);
    end;
}