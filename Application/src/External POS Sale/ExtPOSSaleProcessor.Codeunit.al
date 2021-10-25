codeunit 6014625 "NPR Ext. POS Sale Processor"
{
    Access = Internal;
    TableNo = "NPR Nc Import Entry";

    var
        DocIDToRecIDLbl: Label 'Document ID of %1:%2 can''t be converted to record id.', Comment = '%1=ImportEntry.TableCaption();%2=ImportEntry."Entry No."';
        RecIDToRecordLb: Label 'Content from field %1 (%2%3) can''t be fetched to Record.', Comment = '%1=ImportEntry.FieldName("Document ID");%2=ImportEntry.TableCaption();%3=ImportEntry."Entry No."';
        UnexpectedRecordLbl: Label 'Expected record %1 in the %2 (%3:%4).', Comment = '%1=ServiceEndPoint.TableName();%2=ImportEntry.FieldName("Document ID");%3=ImportEntry.TableCaption();%4=ImportEntry."Entry No."';

        ProcessingErrorLbl: Label 'An error occured while processing. Please check %1 - %2 for error details.';

        ImportTypeDescriptionLbl: Label 'Process External POS Sales';

    trigger OnRun()
    begin
        ProcessImportEntry(Rec);
    end;

    local procedure ProcessImportEntry(ImportEntry: Record "NPR Nc Import Entry")
    var
        ExtPOSSale: Record "NPR External POS Sale";
        ExtPOSSaleConverter: Codeunit "NPR Ext. POS Sale Converter";
    begin
        GetExternalPOSSale(ImportEntry, ExtPOSSale);
        ClearLastError();
        IF NOT ExtPOSSaleConverter.RUN(ExtPOSSale) then begin
            AddConversionError(ExtPOSSale, GetLastErrorText());
            Commit();
            Error(ProcessingErrorLbl, ExtPOSSale.TableCaption(), ExtPOSSale."Entry No.");
        end;
    end;

    procedure AddConversionError(var ExtPOSSale: Record "NPR External POS Sale"; ErrorTxt: Text)
    begin
        ExtPOSSale."Has Conversion Error" := true;
        ExtPOSSale."Last Conversion Error Message" := CopyStr(ErrorTxt, 1, MaxStrLen(ExtPOSSale."Last Conversion Error Message"));
        ExtPOSSale.Modify();
    end;

    procedure GetExternalPOSSale(ImportEntry: Record "NPR Nc Import Entry"; var ExtPOSSale: Record "NPR External POS Sale")
    var
        DataTypeMgt: Codeunit "Data Type Management";
        RecId: RecordId;
        RecRef: RecordRef;
    begin
        if not evaluate(RecId, ImportEntry."Document ID") then
            Error(DocIDToRecIDLbl, ImportEntry.TableCaption(), ImportEntry."Entry No.");
        if not DataTypeMgt.GetRecordRef(RecId, RecRef) then
            Error(RecIDToRecordLb, ImportEntry.FieldName("Document ID"), ImportEntry.TableCaption(), ImportEntry."Entry No.");
        if RecRef.Name() <> ExtPOSSale.TableName() then
            Error(UnexpectedRecordLbl, ExtPOSSale.TableName(), ImportEntry.FieldName("Document ID"), ImportEntry.TableCaption(), ImportEntry."Entry No.");
        RecRef.SetTable(ExtPOSSale);
    end;

    #region Import Type Registration
    procedure RegisterNcImportType(ImportTypeCode: Code[20])
    var
        ImportType: Record "NPR Nc Import Type";
    begin
        if ImportTypeCode = '' then
            exit;
        IF CheckImportTypeExist() then
            exit;
        ImportType.Init();
        ImportType.Code := ImportTypeCode;
        ImportType.Description := Copystr(ImportTypeDescriptionLbl, 1, MaxStrLen(ImportType.Description));
        ImportType."Import List Update Handler" := ImportType."Import List Update Handler"::ExternalPOSSale;
        ImportType."Import Codeunit ID" := Codeunit::"NPR Ext. POS Sale Processor";
        ImportType."Lookup Codeunit ID" := Codeunit::"NPR Ext. POS Sale Lookup";
        ImportType."Keep Import Entries for" := 7 * 24 * 60 * 60 * 1000; // 7 days
        ImportType.Insert(true);
    end;

    procedure DeleteNCImportType(ImportTypeCode: Code[20])
    var
        ImportType: Record "NPR Nc Import Type";
    begin
        IF ImportType.Get(ImportTypeCode) then
            ImportType.Delete(true);
    end;

    local procedure CheckImportTypeExist(): Boolean
    var
        ImportType: Record "NPR Nc Import Type";
    begin
        ImportType.SetRange("Import List Update Handler", ImportType."Import List Update Handler"::ExternalPOSSale);
        Exit(NOT ImportType.IsEmpty());
    end;
    #EndRegion
}
