codeunit 6060062 "Process Catalog File"
{
    // NPR5.39/BR  /20171212 CASE 295322 Object Created

    TableNo = "Nc Import Entry";

    trigger OnRun()
    begin
        case GetExtension("Document Name") of
            'CSV':
                ProcessCSVFile(Rec);
            'ZIP', '':
                ProcessZipFile(Rec);
        end;
    end;

    local procedure ProcessCSVFile(var NcImportEntry: Record "Nc Import Entry")
    var
        TempBlob: Codeunit "Temp Blob";
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        FileManagement: Codeunit "File Management";
        ImportVendorCatalogFile: Codeunit "Import Vendor Catalog File";
        ServerTempPath: Text;
    begin
        if Exists(TemporaryPath + NcImportEntry."Document Name") then
            Erase(TemporaryPath + NcImportEntry."Document Name");
        NcImportEntry.CalcFields("Document Source");
        TempBlob.FromRecord(NcImportEntry, NcImportEntry.FieldNo("Document Source"));
        FileManagement.BLOBExportToServerFile(TempBlob, TemporaryPath + NcImportEntry."Document Name");
        ImportVendorCatalogFile.ReadFile('', TemporaryPath + NcImportEntry."Document Name", false, true);
        FileManagement.DeleteServerFile(TemporaryPath + NcImportEntry."Document Name");
    end;

    local procedure ProcessZipFile(var NcImportEntry: Record "Nc Import Entry")
    var
        TempBlob: Codeunit "Temp Blob";
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        FileManagement: Codeunit "File Management";
        ImportVendorCatalogFile: Codeunit "Import Vendor Catalog File";
        ServerTempPath: Text;
        DataCompression: Codeunit "Data Compression";
        ArchiveEntryList: List of [Text];
        ArchiveEntry: Text;
        ArchiveEntrySize: Integer;
        TempFile: File;
        InStr: InStream;
        OutStr: OutStream;
    begin
        if Exists(TemporaryPath + GetZipFilename) then
            Erase(TemporaryPath + GetZipFilename);

        //Store blob as zipfile
        NcImportEntry.CalcFields("Document Source");
        TempBlob.FromRecord(NcImportEntry, NcImportEntry.FieldNo("Document Source"));
        TempBlob.CreateInStream(InStr);
        //Extract zipfile
        TempFile.CreateTempFile();
        TempFile.CreateOutStream(OutStr);

        if DataCompression.IsGZip(InStr) then begin
            DataCompression.GZipDecompress(InStr, OutStr);
        end else begin
            DataCompression.OpenZipArchive(TempBlob, false);
            DataCompression.GetEntryList(ArchiveEntryList);
            foreach ArchiveEntry in ArchiveEntryList do begin
                DataCompression.ExtractEntry(ArchiveEntry, OutStr, ArchiveEntrySize);
            end;
            TempFile.Close();
        end;

        FileManagement.GetServerDirectoryFilesList(TempNameValueBuffer, TempFile.Name);

        //Process fields
        if TempNameValueBuffer.FindFirst then
            repeat
                ImportVendorCatalogFile.ReadFile('', TempNameValueBuffer.Name, false, true);
            until TempNameValueBuffer.Next = 0;

        //Delete files
        FileManagement.ServerRemoveDirectory(ServerTempPath, true);
        FileManagement.DeleteServerFile(TemporaryPath + GetZipFilename);
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

