codeunit 6060062 "NPR Process Catalog File"
{
    // NPR5.39/BR  /20171212 CASE 295322 Object Created

    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    begin
        case GetExtension("Document Name") of
            'CSV':
                ProcessCSVFile(Rec);
            'ZIP', '':
                ProcessZipFile(Rec);
        end;
    end;

    local procedure ProcessCSVFile(var NcImportEntry: Record "NPR Nc Import Entry")
    var
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        ImportVendorCatalogFile: Codeunit "NPR Imp. Vendor Catalog File";
    begin
        if Exists(TemporaryPath + NcImportEntry."Document Name") then
            Erase(TemporaryPath + NcImportEntry."Document Name");
        NcImportEntry.CalcFields("Document Source");
        TempBlob.FromRecord(NcImportEntry, NcImportEntry.FieldNo("Document Source"));
        FileManagement.BLOBImport(TempBlob, TemporaryPath + NcImportEntry."Document Name");
        ImportVendorCatalogFile.ReadFile('', TempBlob, false, true);
    end;

    local procedure ProcessZipFile(var NcImportEntry: Record "NPR Nc Import Entry")
    var
        TempBlob: Codeunit "Temp Blob";
        ImportVendorCatalogFile: Codeunit "NPR Imp. Vendor Catalog File";
        DataCompression: Codeunit "Data Compression";
        ArchiveEntryList: List of [Text];
        ArchiveEntry: Text;
        ArchiveEntrySize: Integer;
        InStr: InStream;
        OutStr: OutStream;
    begin
        if Exists(TemporaryPath + GetZipFilename()) then
            Erase(TemporaryPath + GetZipFilename());

        //Store blob as zipfile
        NcImportEntry.CalcFields("Document Source");
        TempBlob.FromRecord(NcImportEntry, NcImportEntry.FieldNo("Document Source"));
        TempBlob.CreateInStream(InStr);

        if DataCompression.IsGZip(InStr) then begin
            TempBlob.CreateOutStream(OutStr);
            DataCompression.GZipDecompress(InStr, OutStr);
            ImportVendorCatalogFile.ReadFile('', TempBlob, false, true);
        end else begin
            DataCompression.OpenZipArchive(TempBlob, false);
            DataCompression.GetEntryList(ArchiveEntryList);
            foreach ArchiveEntry in ArchiveEntryList do begin
                TempBlob.CreateOutStream(OutStr);
                DataCompression.ExtractEntry(ArchiveEntry, OutStr, ArchiveEntrySize);
                ImportVendorCatalogFile.ReadFile('', TempBlob, false, true);
                Clear(OutStr);
            end;
        end;
    end;

    local procedure GetZipFilename(): Text
    begin
        exit('TempCatalog.zip');
    end;

    local procedure GetExtension(Filename: Text): Text
    begin
        if (StrPos(Filename, '.') = 0) then
            exit('');
        if StrPos(Filename, '.') = StrLen(Filename) then
            exit('');
        exit(UpperCase(CopyStr(Filename, StrPos(Filename, '.') + 1)));
    end;
}

