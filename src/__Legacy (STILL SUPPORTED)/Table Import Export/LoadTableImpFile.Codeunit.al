codeunit 6150695 "NPR Load Table Imp. File"
{
    // NPR5.48/MMV /20181221 CASE 340086 Created object


    trigger OnRun()
    begin
    end;

    procedure LoadFileInsertOnly(File: Text)
    begin
        Import(File, true, true, false);
    end;

    procedure LoadFile(File: Text)
    begin
        Import(File, false, true, false);
    end;

    procedure LoadFileSkipValidate(File: Text)
    begin
        Import(File, false, false, false);
    end;

    procedure LoadFileSkipValidateAndDeleteAll(File: Text)
    begin
        Import(File, false, false, true);
    end;

    local procedure Import(File: Text; InsertOnly: Boolean; ValidateTypes: Boolean; DeleteAllBeforeImport: Boolean)
    var
        TableImportLibrary: Codeunit "NPR Table Import Library";
    begin
        TableImportLibrary.SetFieldStartDelimeter('');
        TableImportLibrary.SetFieldEndDelimeter('');
        TableImportLibrary.SetFieldSeparator('|');
        TableImportLibrary.SetRecordSeparator('<NEWLINE>');
        TableImportLibrary.SetDataItemSeparator('<NEWLINE><NEWLINE>');
        TableImportLibrary.SetEscapeCharacter('\');
        TableImportLibrary.SetXmlDataFormat(true);
        TableImportLibrary.SetInFileEncoding('utf-8');
        TableImportLibrary.SetFileModeDotNetStream();
        TableImportLibrary.SetErrorOnMissingFields(false);
        TableImportLibrary.SetErrorOnDataMismatch(ValidateTypes);
        TableImportLibrary.SetAutoSave(true);
        TableImportLibrary.SetAutoUpdate(not InsertOnly);
        TableImportLibrary.SetAutoReplace(false);
        TableImportLibrary.SetDeleteAllBeforeImport(DeleteAllBeforeImport);

        TableImportLibrary.SetFileName(File);
        TableImportLibrary.ImportTableBatch();
    end;
}

