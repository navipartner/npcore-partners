codeunit 6059846 "NPR Data Log"
{
    Access = Public;
    procedure LogDatabaseInsert(RecRef: RecordRef)
    var
        DataLogManagement: Codeunit "NPR Data Log Management";
    begin
        DataLogManagement.LogDatabaseInsert(RecRef);
    end;
}