codeunit 6151503 "NPR Nc Webservice"
{
    procedure ImportIncommingDocuments(var documents: XMLport "NPR Nc Import Entry")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        TempImportEntry: Record "NPR Nc Import Entry" temporary;
        NcImportMgt: Codeunit "NPR Nc Import Mgt.";
        NcSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
    begin
        NcImportMgt.InsertImportEntries('IN_DOC', documents, TempImportEntry);
        if not TempImportEntry.FindSet() then
            exit;

        repeat
            ImportEntry.Get(TempImportEntry."Entry No.");
            NcSyncMgt.ProcessImportEntry(ImportEntry)
        until TempImportEntry.Next() = 0;
    end;
}

