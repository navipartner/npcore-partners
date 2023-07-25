﻿codeunit 6150905 "NPR HC Process Unprocess. Imp."
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = 'NPR24.0';
    ObsoleteReason = 'HQ Connector will no longer be supported';
    trigger OnRun()
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NcSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
    begin
        ImportEntry.SetRange(Imported, false);
        ImportEntry.SetFilter("Error Message", '=%1', '');
        if ImportEntry.FindSet() then
            repeat
                NcSyncMgt.ProcessImportEntry(ImportEntry);
            until ImportEntry.Next() = 0;
    end;
}

