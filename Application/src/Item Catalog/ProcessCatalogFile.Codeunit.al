codeunit 6060062 "NPR Process Catalog File"
{
    Access = Internal;

    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    begin
        case GetExtension(Rec."Document Name") of
            'CSV':
                ProcessCSVFile(Rec);
            'ZIP', '':
                ProcessZipFile(Rec);
        end;
    end;

    local procedure ProcessCSVFile(var NcImportEntry: Record "NPR Nc Import Entry")
    var
        TempBlob: Codeunit "Temp Blob";
        ImportVendorCatalogFile: Codeunit "NPR Imp. Vendor Catalog File";
    begin
        NcImportEntry.CalcFields("Document Source");
        TempBlob.FromRecord(NcImportEntry, NcImportEntry.FieldNo("Document Source"));
        ImportVendorCatalogFile.ReadFile('', TempBlob, false, true);
    end;

    local procedure ProcessZipFile(var NcImportEntry: Record "NPR Nc Import Entry")
    var
        TempBlob: Codeunit "Temp Blob";
        ImportVendorCatalogFile: Codeunit "NPR Imp. Vendor Catalog File";
        DataCompression: Codeunit "Data Compression";
        ArchiveEntryList: List of [Text];
        ArchiveEntry: Text;
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22
        ArchiveEntrySize: Integer;
#endif
        InStr: InStream;
        OutStr: OutStream;
    begin
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
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22
                DataCompression.ExtractEntry(ArchiveEntry, OutStr, ArchiveEntrySize);
#else
                DataCompression.ExtractEntry(ArchiveEntry, OutStr);
#endif
                ImportVendorCatalogFile.ReadFile('', TempBlob, false, true);
                Clear(OutStr);
            end;
        end;
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

