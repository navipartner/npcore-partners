codeunit 6151503 "NPR Nc Webservice"
{
    // NC1.20/MHA/20151009  CASE 218525 Object created
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect


    trigger OnRun()
    begin
    end;

    var
        FileMgt: Codeunit "File Management";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";

    procedure ImportIncommingDocuments(var documents: XMLport "NPR Nc Import Entry")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        TempImportEntry: Record "NPR Nc Import Entry" temporary;
        NcImportMgt: Codeunit "NPR Nc Import Mgt.";
        NcSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
    begin
        NcImportMgt.InsertImportEntries('IN_DOC', documents, TempImportEntry);
        if not TempImportEntry.FindSet then
            exit;

        repeat
            ImportEntry.Get(TempImportEntry."Entry No.");
            NcSyncMgt.ProcessImportEntry(ImportEntry)
        until TempImportEntry.Next = 0;
    end;
}

