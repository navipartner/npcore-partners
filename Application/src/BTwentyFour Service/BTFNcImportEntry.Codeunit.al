codeunit 6014649 "NPR BTF Nc Import Entry"
{
    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    begin
        ProcessImportEntry(Rec);
    end;

    var
        DocIDToRecIDLbl: Label 'Document ID of %1:%2 can''t be converted to record id.', Comment = '%1=ImportEntry.TableCaption();%2=ImportEntry."Entry No."';
        RecIDToRecordLb: Label 'Content from field %1 (%2%3) can''t be fetched to Record.', Comment = '%1=ImportEntry.FieldName("Document ID");%2=ImportEntry.TableCaption();%3=ImportEntry."Entry No."';
        UnexpectedRecordLbl: Label 'Expected record %1 in the %2 (%3:%4).', Comment = '%1=ServiceEndPoint.TableName();%2=ImportEntry.FieldName("Document ID");%3=ImportEntry.TableCaption();%4=ImportEntry."Entry No."';
        EmptyContentLbl: Label 'Nothing to process. Empty content in a field %1 (%2%3)', Comment = '%1=ImportEntry.FieldName("Document Source");%2=ImportEntry.TableCaption();%3=ImportEntry."Entry No."';

    local procedure ProcessImportEntry(ImportEntry: Record "NPR Nc Import Entry")
    var
        ServiceEndPoint: Record "NPR BTF Service EndPoint";
        Content: Codeunit "Temp Blob";
        EndPoint: Interface "NPR BTF IEndPoint";
    begin
        PreProcessingCheck(ImportEntry, ServiceEndPoint);
        Content.FromRecord(ImportEntry, ImportEntry.FieldNo("Document Source"));
        EndPoint := ServiceEndPoint."EndPoint Method";
        EndPoint.ProcessImportedContent(Content, ServiceEndPoint);
    end;

    local procedure PreProcessingCheck(var ImportEntry: Record "NPR Nc Import Entry"; var ServiceEndPoint: Record "NPR BTF Service EndPoint")
    var
        DataTypeMgt: Codeunit "Data Type Management";
        RecId: RecordId;
        RecRef: RecordRef;
    begin
        if not ImportEntry."Document Source".HasValue() then begin
            error(EmptyContentLbl, ImportEntry.FieldName("DOcument Source"), ImportEntry.TableCaption(), ImportEntry."Entry No.");
        end;
        if not evaluate(RecId, ImportEntry."Document ID") then begin
            error(DocIDToRecIDLbl, ImportEntry.TableCaption(), ImportEntry."Entry No.");
        end;
        if not DataTypeMgt.GetRecordRef(RecId, RecRef) then begin
            Error(RecIDToRecordLb, ImportEntry.FieldName("Document ID"), ImportEntry.TableCaption(), ImportEntry."Entry No.");
        end;
        if RecRef.Name() <> ServiceEndPoint.TableName() then begin
            error(UnexpectedRecordLbl, ServiceEndpoint.TableName(), ImportEntry.FieldName("Document ID"), ImportEntry.TableCaption(), ImportEntry."Entry No.");
        end;
        RecRef.SetTable(ServiceEndPoint);
    end;
}