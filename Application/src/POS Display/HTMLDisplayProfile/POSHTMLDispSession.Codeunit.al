codeunit 6060084 "NPR POS HTML Disp. Session"
{
    Access = Internal;
    SingleInstance = true;

    var
        hwcGUIDs: JsonObject;


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
}