codeunit 6014447 "NPR Document Send. Profile Sub"
{
    SingleInstance = true; //For performance, not state sharing.
    [EventSubscriber(ObjectType::Table, Database::"Document Sending Profile", 'OnBeforeSendCustomerRecords', '', true, true)]
    local procedure NPRDocumentSendingProfileOnBeforeSendCustomerRecords(ReportUsage: Integer; RecordVariant: Variant; DocName: Text[150]; CustomerNo: Code[20]; DocumentNo: Code[20]; CustomerFieldNo: Integer; DocumentFieldNo: Integer; var Handled: Boolean)
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        SingleCustomerSelected: Boolean;
    begin
        SingleCustomerSelected := IsSingleRecordSelected(RecordVariant, CustomerNo, CustomerFieldNo);
        if SingleCustomerSelected then begin
            DocumentSendingProfile.GetDefaultForCustomer(CustomerNo, DocumentSendingProfile);
            DocumentSendingProfile.Send(ReportUsage, RecordVariant, DocumentNo, CustomerNo, DocName, CustomerFieldNo, DocumentFieldNo);
            Handled := true;
        end;
    end;

    local procedure IsSingleRecordSelected(RecordVariant: Variant; CVNo: Code[20]; CVFieldNo: Integer): Boolean
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        RecRef.GetTable(RecordVariant);
        if not RecRef.FindSet() then
            exit(false);
        if RecRef.Next() = 0 then
            exit(true);
        FieldRef := RecRef.Field(CVFieldNo);
        FieldRef.SetFilter('<>%1', CVNo);
        exit(RecRef.IsEmpty());
    end;
}
