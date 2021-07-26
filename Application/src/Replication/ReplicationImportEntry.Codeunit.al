codeunit 6014622 "NPR Replication Import Entry"
{
    Access = Internal;
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
        ServiceEndPoint: Record "NPR Replication Endpoint";
        Content: Codeunit "Temp Blob";
        EndPoint: Interface "NPR Replication IEndpoint Meth";
    begin
        GetServiceEndpoint(ImportEntry, ServiceEndPoint);
        Content.FromRecord(ImportEntry, ImportEntry.FieldNo("Document Source"));
        EndPoint := ServiceEndPoint."EndPoint Method";
        EndPoint.ProcessImportedContent(Content, ServiceEndPoint);
    end;

    local procedure GetServiceEndpoint(ImportEntry: Record "NPR Nc Import Entry"; var ServiceEndPoint: Record "NPR Replication Endpoint")
    var
        DataTypeMgt: Codeunit "Data Type Management";
        RecId: RecordId;
        RecRef: RecordRef;
    begin
        if not ImportEntry."Document Source".HasValue() then
            Error(EmptyContentLbl, ImportEntry.FieldName("Document Source"), ImportEntry.TableCaption(), ImportEntry."Entry No.");
        if not evaluate(RecId, ImportEntry."Document ID") then
            Error(DocIDToRecIDLbl, ImportEntry.TableCaption(), ImportEntry."Entry No.");
        if not DataTypeMgt.GetRecordRef(RecId, RecRef) then
            Error(RecIDToRecordLb, ImportEntry.FieldName("Document ID"), ImportEntry.TableCaption(), ImportEntry."Entry No.");
        if RecRef.Name() <> ServiceEndPoint.TableName() then
            Error(UnexpectedRecordLbl, ServiceEndpoint.TableName(), ImportEntry.FieldName("Document ID"), ImportEntry.TableCaption(), ImportEntry."Entry No.");
        RecRef.SetTable(ServiceEndPoint);
    end;
}