codeunit 6059846 "NPR Data Log"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Access = Public;
    procedure LogDatabaseInsert(RecRef: RecordRef)
    var
        DataLogManagement: Codeunit "NPR Data Log Management";
    begin
        DataLogManagement.LogDatabaseInsert(RecRef);
    end;
}