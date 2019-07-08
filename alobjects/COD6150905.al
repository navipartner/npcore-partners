codeunit 6150905 "HC Process Unprocessed Imports"
{
    // NPR5.37/BR  /20171027 CASE 267552 HQ Connector Created Object


    trigger OnRun()
    var
        ImportEntry: Record "Nc Import Entry";
        NcSyncMgt: Codeunit "Nc Sync. Mgt.";
    begin
        ImportEntry.SetRange(Imported,false);
        ImportEntry.SetFilter("Error Message",'=%1','');
        if ImportEntry.FindSet then
          repeat
            NcSyncMgt.ProcessImportEntry(ImportEntry);
          until ImportEntry.Next = 0;
    end;
}

