codeunit 6151182 "NPR ES Offline Invoice Mgt."
{
    Access = Internal;

    // Invoices issued while Fiskaly SIGN ES was unreachable are kept locally and submitted later, oldest first,
    // so that Fiskaly receives them in a correlative way (see https://developer.fiskaly.com/sign-es/connectionloss_verifactu).
    // A client stops at its first failed invoice, so later invoices of that client are never submitted ahead of it.

    #region Submission
    internal procedure HasPendingOfflineInvoices(ESClientId: Guid): Boolean
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
    begin
        ESPOSAuditLogAuxInfo.SetPendingOfflineSubmissionFilter();
        ESPOSAuditLogAuxInfo.SetRange("ES Client Id", ESClientId);
        exit(not ESPOSAuditLogAuxInfo.IsEmpty());
    end;

    internal procedure IsSaleRetryDue(ESClientId: Guid): Boolean
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
    begin
        if not FindOldestPendingOfflineInvoice(ESClientId, ESPOSAuditLogAuxInfo) then
            exit(false);
        if ESPOSAuditLogAuxInfo."Last Submission Attempt At" = 0DT then
            exit(true);
        exit(CurrentDateTime() - ESPOSAuditLogAuxInfo."Last Submission Attempt At" >= SaleRetryInterval());
    end;

    internal procedure GetOldestPendingOfflineInvoiceError(ESClientId: Guid): Text
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
    begin
        if FindOldestPendingOfflineInvoice(ESClientId, ESPOSAuditLogAuxInfo) then
            exit(ESPOSAuditLogAuxInfo."Last Submission Error");
    end;

    local procedure FindOldestPendingOfflineInvoice(ESClientId: Guid; var ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info"): Boolean
    begin
        ESPOSAuditLogAuxInfo.SetPendingOfflineSubmissionFilter();
        ESPOSAuditLogAuxInfo.SetRange("ES Client Id", ESClientId);
        exit(ESPOSAuditLogAuxInfo.FindFirst());
    end;

    local procedure SaleRetryInterval(): Duration
    begin
        exit(2 * 60 * 1000);
    end;

    internal procedure SubmitPendingOfflineInvoices(ESClientId: Guid; MaxSubmissions: Integer): Boolean
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        PermanentFailure: Boolean;
        Submissions: Integer;
    begin
        ESPOSAuditLogAuxInfo.SetPendingOfflineSubmissionFilter();
        ESPOSAuditLogAuxInfo.SetRange("ES Client Id", ESClientId);

        // A successful submission moves the record out of the filter, so always continue with the oldest one left.
        while ESPOSAuditLogAuxInfo.FindFirst() do begin
            if Submissions >= MaxSubmissions then
                exit(false);
            Submissions += 1;
            if not TrySubmitOfflineInvoice(ESPOSAuditLogAuxInfo, PermanentFailure) then
                exit(false);
        end;

        exit(true);
    end;

    internal procedure SubmitAllPendingOfflineInvoices(MaxSubmissions: Integer; var RejectedInvoices: Integer)
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        BlockedESClientIds: List of [Guid];
        PendingRecordIds: List of [RecordId];
        PendingRecordId: RecordId;
        PermanentFailure: Boolean;
        Submissions: Integer;
    begin
        // Oldest first across all clients, so an invoice issued on one POS unit reaches Fiskaly before a correction issued on another.
        ESPOSAuditLogAuxInfo.SetPendingOfflineSubmissionFilter();
        ESPOSAuditLogAuxInfo.SetLoadFields("Audit Entry Type", "Audit Entry No.");
        if ESPOSAuditLogAuxInfo.FindSet() then
            repeat
                PendingRecordIds.Add(ESPOSAuditLogAuxInfo.RecordId());
            until ESPOSAuditLogAuxInfo.Next() = 0;
        ESPOSAuditLogAuxInfo.SetLoadFields();

        foreach PendingRecordId in PendingRecordIds do begin
            if Submissions >= MaxSubmissions then
                exit;
            if ESPOSAuditLogAuxInfo.Get(PendingRecordId) then
                if ESPOSAuditLogAuxInfo.IsPendingOfflineSubmission() and not BlockedESClientIds.Contains(ESPOSAuditLogAuxInfo."ES Client Id") then begin
                    Submissions += 1;
                    if not TrySubmitOfflineInvoice(ESPOSAuditLogAuxInfo, PermanentFailure) then begin
                        BlockedESClientIds.Add(ESPOSAuditLogAuxInfo."ES Client Id");
                        if PermanentFailure then
                            RejectedInvoices += 1;
                    end;
                end;
        end;
    end;

    internal procedure TrySubmitOfflineInvoice(var ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info"; var PermanentFailure: Boolean): Boolean
    var
        ESPOSAuditLogAuxInfo2: Record "NPR ES POS Audit Log Aux. Info";
        ESSubmitOfflineInvoice: Codeunit "NPR ES Submit Offline Invoice";
        Sentry: Codeunit "NPR Sentry";
        LastErrorText: Text;
    begin
        PermanentFailure := false;
        ESPOSAuditLogAuxInfo2 := ESPOSAuditLogAuxInfo;
        Commit();
        ClearLastError();
        if ESSubmitOfflineInvoice.Run(ESPOSAuditLogAuxInfo2) then begin
            ESPOSAuditLogAuxInfo := ESPOSAuditLogAuxInfo2;
            exit(true);
        end;

        LastErrorText := GetLastErrorText();

        ESPOSAuditLogAuxInfo2.Get(ESPOSAuditLogAuxInfo."Audit Entry Type", ESPOSAuditLogAuxInfo."Audit Entry No.");
        if not ESPOSAuditLogAuxInfo2.IsPendingOfflineSubmission() then begin
            ESPOSAuditLogAuxInfo := ESPOSAuditLogAuxInfo2;
            exit(true);
        end;

        PermanentFailure := not ESSubmitOfflineInvoice.IsLastFailureTransient();
        if PermanentFailure then
            Sentry.AddLastErrorIfProgrammingBug();

        ESPOSAuditLogAuxInfo2."Submission Attempts" += 1;
        ESPOSAuditLogAuxInfo2."Last Submission Attempt At" := CurrentDateTime();
        ESPOSAuditLogAuxInfo2."Last Submission Error" := CopyStr(LastErrorText, 1, MaxStrLen(ESPOSAuditLogAuxInfo2."Last Submission Error"));
        ESPOSAuditLogAuxInfo2.Modify();
        Commit();

        ESPOSAuditLogAuxInfo := ESPOSAuditLogAuxInfo2;
        exit(false);
    end;
    #endregion

    #region Offline Validation QR Code
    internal procedure CreateOfflineValidationUrl(ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info"): Text
    var
        ESFiscalizationSetup: Record "NPR ES Fiscalization Setup";
        ESOrganization: Record "NPR ES Organization";
        Uri: Codeunit Uri;
        LiveValidationBaseUrlLbl: Label 'https://www2.agenciatributaria.gob.es/wlpl/TIKE-CONT/ValidarQR', Locked = true;
        TestValidationBaseUrlLbl: Label 'https://prewww2.aeat.es/wlpl/TIKE-CONT/ValidarQR', Locked = true;
        ValidationUrlLbl: Label '%1?nif=%2&numserie=%3&fecha=%4&importe=%5', Locked = true, Comment = '%1 - base url, %2 - issuer tax number, %3 - invoice series and number, %4 - issue date, %5 - total amount';
        BaseUrl: Text;
        IssuedAtTimestamp: Text;
        IssueDate: Text;
    begin
        // The tax authority QR code can only be built locally for invoices validated at AEAT. TicketBAI and Navarre codes
        // contain data that only Fiskaly can produce, so those receipts are printed without a QR code until the invoice is submitted.
        if not ESOrganization.Get(ESPOSAuditLogAuxInfo."ES Organization Code") then
            exit('');
        if not IsAEATValidationTerritory(ESOrganization) then
            exit('');

        ESFiscalizationSetup.Get();
        if ESFiscalizationSetup.Live then
            BaseUrl := LiveValidationBaseUrlLbl
        else
            BaseUrl := TestValidationBaseUrlLbl;

        IssuedAtTimestamp := GetLocalIssuedAtTimestamp(ESPOSAuditLogAuxInfo."Offline Issued At", ESOrganization);
        IssueDate := CopyStr(IssuedAtTimestamp, 9, 2) + '-' + CopyStr(IssuedAtTimestamp, 6, 2) + '-' + CopyStr(IssuedAtTimestamp, 1, 4);

        exit(StrSubstNo(ValidationUrlLbl,
            BaseUrl,
            Uri.EscapeDataString(GetIssuerTaxNumber()),
            Uri.EscapeDataString(GetInvoiceSeriesNumber(ESPOSAuditLogAuxInfo)),
            IssueDate,
            Format(ESPOSAuditLogAuxInfo."Amount Incl. Tax", 0, '<Precision,2:2><Standard Format,2>')));
    end;

    local procedure IsAEATValidationTerritory(ESOrganization: Record "NPR ES Organization"): Boolean
    begin
        exit(ESOrganization."Taxpayer Territory" in [ESOrganization."Taxpayer Territory"::CANARY_ISLANDS,
                                                     ESOrganization."Taxpayer Territory"::CEUTA,
                                                     ESOrganization."Taxpayer Territory"::MELILLA,
                                                     ESOrganization."Taxpayer Territory"::SPAIN_OTHER]);
    end;

    local procedure GetIssuerTaxNumber(): Text
    var
        CompanyInformation: Record "Company Information";
    begin
        // The taxpayer is registered at Fiskaly with this value as issuer tax number. "Company Tax Number" on the ES Organization
        // is the tax number of the software producer, so it must not be used here.
        CompanyInformation.Get();
        exit(CompanyInformation."VAT Registration No.");
    end;

    local procedure GetInvoiceSeriesNumber(ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info"): Text
    begin
        // Mirrors the create invoice request, which only sends a series for complete and correcting invoices.
        if ESPOSAuditLogAuxInfo."Invoice Type" in [ESPOSAuditLogAuxInfo."Invoice Type"::COMPLETE, ESPOSAuditLogAuxInfo."Invoice Type"::CORRECTING] then
            exit(ESPOSAuditLogAuxInfo."Invoice No. Series" + ESPOSAuditLogAuxInfo."Invoice No.");

        exit(ESPOSAuditLogAuxInfo."Invoice No.");
    end;
    #endregion

    #region Issue Timestamp
    internal procedure GetLocalIssuedAtTimestamp(IssuedAt: DateTime; ESOrganization: Record "NPR ES Organization"): Text
    var
        TimeZone: Codeunit "Time Zone";
        LocalIssuedAt: DateTime;
        Offset: Duration;
        OffsetMinutes: Integer;
        OffsetSign: Text;
        TimestampLbl: Label '%1%2%3:%4', Locked = true, Comment = '%1 - local date and time, %2 - offset sign, %3 - offset hours, %4 - offset minutes';
    begin
        // Fiskaly expects the local time of the issuing location with its UTC offset, e.g. 2025-03-25T15:45:00+01:00.
        Offset := TimeZone.GetTimezoneOffset(IssuedAt, GetTimeZoneId(ESOrganization));
        LocalIssuedAt := IssuedAt + Offset;

        OffsetMinutes := Round(Offset / 60000, 1);
        if OffsetMinutes < 0 then
            OffsetSign := '-'
        else
            OffsetSign := '+';
        OffsetMinutes := Abs(OffsetMinutes);

        // Format 9 renders the value as UTC, which is the shifted local wall-clock time here.
        exit(StrSubstNo(TimestampLbl,
            CopyStr(Format(LocalIssuedAt, 0, 9), 1, 19),
            OffsetSign,
            Format(OffsetMinutes div 60, 0, '<Integer,2><Filler Character,0>'),
            Format(OffsetMinutes mod 60, 0, '<Integer,2><Filler Character,0>')));
    end;

    local procedure GetTimeZoneId(ESOrganization: Record "NPR ES Organization"): Text
    var
        CanaryIslandsTimeZoneIdLbl: Label 'GMT Standard Time', Locked = true;
        MainlandSpainTimeZoneIdLbl: Label 'Romance Standard Time', Locked = true;
    begin
        if ESOrganization."Taxpayer Territory" = ESOrganization."Taxpayer Territory"::CANARY_ISLANDS then
            exit(CanaryIslandsTimeZoneIdLbl);

        exit(MainlandSpainTimeZoneIdLbl);
    end;
    #endregion
}
