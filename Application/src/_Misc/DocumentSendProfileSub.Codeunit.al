codeunit 6014447 "NPR Document Send. Profile Sub"
{
    Access = Internal;
    SingleInstance = true; //For performance, not state sharing.

    [EventSubscriber(ObjectType::Table, Database::"Document Sending Profile", 'OnBeforeSendCustomerRecords', '', true, true)]
    local procedure NPRDocumentSendingProfileOnBeforeSendCustomerRecords(ReportUsage: Integer; RecordVariant: Variant; DocName: Text[150]; CustomerNo: Code[20]; DocumentNo: Code[20]; CustomerFieldNo: Integer; DocumentFieldNo: Integer; var Handled: Boolean)
    var
        DocumentSendingProfile: Record "Document Sending Profile";
    begin
        // SendCustomerRecords forces ShowDialog := true for a single-customer selection, so the base app pops the
        // "Select Sending Options" dialog (via LookupProfile) BEFORE it ever calls Send - the OnBeforeSend subscriber
        // below fires too late to suppress it. The POS post-and-send path lands exactly here (SendDocument ->
        // SalesInvHeader/SalesCrMemoHeader.SendRecords -> SendCustomerRecords), so without this handler that modal
        // pops over the POS at sale end for every single-customer Send. Route a single-customer selection straight
        // to the customer's default profile Send - which raises OnBeforeSend, where NP Email replaces the e-mail
        // step when configured - and mark it handled so the dialog is skipped. A multi-customer selection falls
        // through to the standard per-customer grouped handling (its dialog is intentional there).
        if Handled then
            exit;
        if not IsSingleRecordSelected(RecordVariant, CustomerNo, CustomerFieldNo) then
            exit;

        DocumentSendingProfile.GetDefaultForCustomer(CustomerNo, DocumentSendingProfile);
        DocumentSendingProfile.Send(ReportUsage, RecordVariant, DocumentNo, CustomerNo, DocName, CustomerFieldNo, DocumentFieldNo);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Document Sending Profile", 'OnBeforeSend', '', true, true)]
    local procedure NPRDocumentSendingProfileOnBeforeSend(var Sender: Record "Document Sending Profile"; ReportUsage: Integer; RecordVariant: Variant; DocNo: Code[20]; ToCust: Code[20]; DocName: Text[150]; CustomerFieldNo: Integer; DocumentNoFieldNo: Integer; var IsHandled: Boolean)
    var
        OtherChannelsProfile: Record "Document Sending Profile";
    begin
        // Every "Send" funnels through Document Sending Profile.Send: the manual posted-document "Send" action
        // (single customer, or multi-customer which the base app splits into one Send per document) and
        // Post-and-Send (SendPostedDocumentRecord -> SendProfile -> Send) both reach it. So this one subscriber
        // replaces the e-mail step for all of them. "Sender" is the profile this Send actually runs on.
        //
        // NP Email replaces ONLY the e-mail step: send the NP Emails for the records in this Send, then re-issue
        // the profile's remaining channels (Printer / Disk / Electronic Document) with the e-mail step suppressed.
        // The re-issue runs on a COPY with E-Mail blanked - with E-Mail = No, TryHandleWithNPEmail returns false for
        // the re-issued Send, so this same subscriber skips it and there is no recursion and no duplicate NP Email.
        // The shared Sender record is never mutated (the caller reuses it, e.g. for the shipment in a Ship+Invoice send).
        if IsHandled then
            exit;
        if not TryHandleWithNPEmail(RecordVariant, Sender) then
            exit;

        OtherChannelsProfile := Sender;
        OtherChannelsProfile."E-Mail" := OtherChannelsProfile."E-Mail"::No;
        if HasNonEmailChannel(OtherChannelsProfile) then
            OtherChannelsProfile.Send(ReportUsage, RecordVariant, DocNo, ToCust, DocName, CustomerFieldNo, DocumentNoFieldNo);

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Document Sending Profile", 'OnBeforeTrySendToEMail', '', true, true)]
    local procedure NPRDocSendProfileOnBeforeTrySendToEMail(ReportUsage: Integer; RecordVariant: Variant; DocumentNoFieldNo: Integer; DocName: Text[150]; CustomerFieldNo: Integer; var ShowDialog: Boolean; var Handled: Boolean; var IsCustomer: Boolean)
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        RecRef: RecordRef;
        CustomerFieldRef: FieldRef;
        CustomerNo: Code[20];
        NPEmailFeature: Codeunit "NPR NP Email Feature";
        NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
    begin
        // The "Send by E-mail" action routes through TrySendToEMail, which goes straight to the grouped e-mail
        // send WITHOUT calling Send - so it is not covered by the OnBeforeSend subscriber above and needs its own
        // handler here. It is e-mail only (no other channels), so we simply suppress the standard e-mail when NP
        // Email handles it. Only take over a single-customer selection; a multi-customer selection falls through to
        // the standard grouped send (otherwise one customer's profile/template would apply to the whole batch).
        if Handled then
            exit;
        if not NewEmailExpFeature.IsFeatureEnabled() then
            exit;
        if not NPEmailFeature.IsFeatureEnabled() then
            exit;
        if not IsCustomer then
            exit;
        if CustomerFieldNo = 0 then
            exit;

        RecRef.GetTable(RecordVariant);
        if not RecRef.FindFirst() then
            exit;
        CustomerFieldRef := RecRef.Field(CustomerFieldNo);
        CustomerNo := CopyStr(Format(CustomerFieldRef.Value), 1, MaxStrLen(CustomerNo));

        if not IsSingleRecordSelected(RecordVariant, CustomerNo, CustomerFieldNo) then
            exit;

        DocumentSendingProfile.GetDefaultForCustomer(CustomerNo, DocumentSendingProfile);

        // When NP Email is the configured handler it owns delivery, so suppress the standard e-mail.
        if TryHandleWithNPEmail(RecordVariant, DocumentSendingProfile) then
            Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post and Send", 'OnBeforeConfirmAndSend', '', true, true)]
    local procedure NPRSalesPostAndSendOnBeforeConfirmAndSend(SalesHeader: Record "Sales Header"; var TempDocumentSendingProfile: Record "Document Sending Profile" temporary; var Result: Boolean; var IsHandled: Boolean)
    var
        NPEmailFeature: Codeunit "NPR NP Email Feature";
        NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
        DocTmplSelMgt: Codeunit "NPR NPEmailDocTmplSelMgt";
        DocumentType: Enum "NPR NPEmailDocType";
    begin
        // Skip the standard "Post and Send Confirmation" dialog (page 365) only when NP Email is the sole delivery
        // channel for the document this header posts into: NP Email is configured for that document type and e-mail
        // is the only active step (Printer, Disk and Electronic Document all No). The document type matters - NP
        // Email may be configured for invoices but not credit memos, and then only the invoice dialog is skipped
        // while the credit memo keeps the standard confirmation. When any other channel is active, or NP Email is
        // not configured for the type, the dialog is kept. NP Email delivery itself happens later, in the
        // OnBeforeSend subscriber, after the document is posted.
        if IsHandled then
            exit;
        if not NewEmailExpFeature.IsFeatureEnabled() then
            exit;
        if not NPEmailFeature.IsFeatureEnabled() then
            exit;
        if not DocTmplSelMgt.TryResolveDocTypeFromSalesHeader(SalesHeader, DocumentType) then
            exit;
        if not DocTmplSelMgt.IsNPEmailSoleDeliveryChannel(TempDocumentSendingProfile, DocumentType) then
            exit;

        Result := true;
        IsHandled := true;
    end;

    local procedure TryHandleWithNPEmail(RecordVariant: Variant; DocumentSendingProfile: Record "Document Sending Profile"): Boolean
    var
        NPEmailFeature: Codeunit "NPR NP Email Feature";
        NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
        DocTmplSelMgt: Codeunit "NPR NPEmailDocTmplSelMgt";
        IDocType: Interface "NPR INPEmailDocType";
        DocumentType: Enum "NPR NPEmailDocType";
        RecRef: RecordRef;
        Positions: List of [Text];
        Position: Text;
        TemplateId: Code[20];
    begin
        // NP Email handles the e-mail step when the feature is on, the profile keeps the e-mail step active
        // (E-Mail <> No), and a template is configured for the resolved document type (i.e. a record exists in
        // NPEmailDocTmplSelection). Returns whether NP Email is that configured handler, so the caller can suppress
        // the standard e-mail. One NP Email is sent per record in the set.
        //
        // The record positions are collected up front and each record is re-read while sending, because a send
        // commits (NPEmail.TrySendEmail commits before it runs) and a commit inside a live FindSet loop ends the
        // loop after the first record - which is why a multi-document selection previously e-mailed only the first
        // document. Sends are best-effort: TrySendNPEmail logs genuine failures to Sentry, and a failed send is
        // NOT replaced by the standard e-mail (NP Email owns the channel). When NP Email is not the configured
        // handler, the standard send proceeds unchanged.
        if not NewEmailExpFeature.IsFeatureEnabled() then
            exit(false);
        if not NPEmailFeature.IsFeatureEnabled() then
            exit(false);
        if DocumentSendingProfile."E-Mail" = DocumentSendingProfile."E-Mail"::No then
            exit(false);

        RecRef.GetTable(RecordVariant);
        if not DocTmplSelMgt.TryResolveDocType(RecRef.Number(), DocumentType) then
            exit(false);
        if not DocTmplSelMgt.TryGetTemplateId(DocumentType, TemplateId) then
            exit(false);
        if not RecRef.FindSet() then
            exit(false);
        repeat
            Positions.Add(RecRef.GetPosition(false));
        until RecRef.Next() = 0;

        IDocType := DocumentType;
        foreach Position in Positions do begin
            RecRef.SetPosition(Position);
            if RecRef.Find('=') then
                IDocType.TrySendNPEmail(RecRef, TemplateId);
        end;
        exit(true);
    end;

    local procedure HasNonEmailChannel(DocumentSendingProfile: Record "Document Sending Profile"): Boolean
    begin
        exit(
            (DocumentSendingProfile.Printer <> DocumentSendingProfile.Printer::No) or
            (DocumentSendingProfile.Disk <> DocumentSendingProfile.Disk::No) or
            (DocumentSendingProfile."Electronic Document" <> DocumentSendingProfile."Electronic Document"::No));
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
