codeunit 6014649 "NPR BTF Nc Import Entry" implements "NPR Nc Import List IProcess"
{
    Access = Internal;
    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    begin
    end;

    var
        DocIDToRecIDErr: Label 'Document ID of %1:%2 can''t be converted to record id.', Comment = '%1=ImportEntry.TableCaption();%2=ImportEntry."Entry No."';
        RecIDToRecordErr: Label 'Content from field %1 (%2%3) can''t be fetched to Record.', Comment = '%1=ImportEntry.FieldName("Document ID");%2=ImportEntry.TableCaption();%3=ImportEntry."Entry No."';
        UnexpectedRecordErr: Label 'Expected record %1 in the %2 (%3:%4).', Comment = '%1=ServiceEndPoint.TableName();%2=ImportEntry.FieldName("Document ID");%3=ImportEntry.TableCaption();%4=ImportEntry."Entry No."';
        EmptyContentErr: Label 'Nothing to process. Empty content in a field %1 (%2%3)', Comment = '%1=ImportEntry.FieldName("Document Source");%2=ImportEntry.TableCaption();%3=ImportEntry."Entry No."';
        ReferToServiceEndPointErrorLogLbl: Label 'Check out "%1" (%2 -> Service Endpoints -> %3 -> Error Log)', Comment = '%1="NPR BTF EndPoint Error Log".TableCaption();%2="NPR BTF Service Setup".Caption();%3=ServiceEndpoint."EndPoint ID"';


    internal procedure RunProcessImportEntry(ImportEntry: Record "NPR Nc Import Entry")
    begin
        ProcessImportEntry(ImportEntry);
    end;

    local procedure ProcessImportEntry(ImportEntry: Record "NPR Nc Import Entry")
    var
        ServiceEndPoint: Record "NPR BTF Service EndPoint";
        Content: Codeunit "Temp Blob";
        ServiceSetup: page "NPR BTF Service Setup";
        EndPoint: Interface "NPR BTF IEndPoint";
        ErrorMsg: Text;
    begin
        ClearLastError();
        PreProcessingCheck(ImportEntry, ServiceEndPoint);
        Content.FromRecord(ImportEntry, ImportEntry.FieldNo("Document Source"));
        EndPoint := ServiceEndPoint."EndPoint Method";
        if not EndPoint.ProcessImportedContent(Content, ServiceEndPoint) then begin
            ErrorMsg := GetLastErrorText();
            if ErrorMsg = '' then
                ErrorMsg := StrSubstNo(ReferToServiceEndPointErrorLogLbl, ServiceEndPoint.TableCaption(), ServiceSetup.Caption(), ServiceEndPoint."EndPoint ID");
            Error(ErrorMsg);
        end;
    end;

    local procedure PreProcessingCheck(var ImportEntry: Record "NPR Nc Import Entry"; var ServiceEndPoint: Record "NPR BTF Service EndPoint")
    var
        DataTypeMgt: Codeunit "Data Type Management";
        RecId: RecordId;
        RecRef: RecordRef;
    begin
        if not ImportEntry."Document Source".HasValue() then
            error(EmptyContentErr, ImportEntry.FieldCaption("DOcument Source"), ImportEntry.TableCaption(), ImportEntry."Entry No.");

        if not evaluate(RecId, ImportEntry."Document ID") then
            error(DocIDToRecIDErr, ImportEntry.TableCaption(), ImportEntry."Entry No.");

        if not DataTypeMgt.GetRecordRef(RecId, RecRef) then
            Error(RecIDToRecordErr, ImportEntry.FieldCaption("Document ID"), ImportEntry.TableCaption(), ImportEntry."Entry No.");

        if RecRef.Name() <> ServiceEndPoint.TableName() then
            error(UnexpectedRecordErr, ServiceEndpoint.TableCaption(), ImportEntry.FieldCaption("Document ID"), ImportEntry.TableCaption(), ImportEntry."Entry No.");

        RecRef.SetTable(ServiceEndPoint);
    end;
}
