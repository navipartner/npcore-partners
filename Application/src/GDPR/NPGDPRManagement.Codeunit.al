codeunit 6151060 "NPR NP GDPR Management"
{
    Access = Internal;
    Permissions = TableData "Sales Shipment Header" = rm,
                  TableData "Sales Invoice Header" = rm,
                  TableData "Sales Cr.Memo Header" = rm,
                  TableData "Return Receipt Header" = rm,
                  TableData "Job Queue Entry" = rm,
                  TableData "Issued Reminder Header" = rm;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        CustomerGDPRV2: Codeunit "NPR Customer GDPR V2";
        Customer: Record Customer;
        CustToAnonymise: Record "NPR Customers to Anonymize";
        GDPRSetup: Record "NPR Customer GDPR SetUp";
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
        ReasonText: Text;
        VarNoOfCustomers: Integer;
        AnonRunner: Codeunit "NPR NP GDPR Anon. Runner";
        Sentry: Codeunit "NPR Sentry";
        DueCustomerNos: List of [Code[20]];
        DueCustomerNo: Code[20];
    begin
        if not DataTypeManagement.GetRecordRef(Rec."Record ID to Process", RecRef) then
            exit;
        if RecRef.Name() <> GDPRSetup.TableName() then
            exit;
        GetJobQueueParameters(VarCheckPeriod, VarNoOfCustomers, Rec."Parameter String");

        case VarCheckPeriod of
            false:
                begin
                    Customer.Reset();
                    Customer.SetRange(Customer."NPR Anonymized", false);
                    if CustomerGDPRV2.IsFeatureEnabled() then begin
                        Customer.SetFilter(Customer."NPR Estimated Cleanup Date", '>%1&<=%2', 0D, Today());
                        // The Job Queue runs this OnRun via a guarded Codeunit.Run, where a nested [TryFunction]
                        // may not write and a nested guarded Run must see no uncommitted writes. Snapshot the due
                        // customers first (keeping the read cursor separate from the write/commit cycle), then
                        // anonymize each through the runner's guarded Run and Commit after each so the next
                        // iteration starts on a clean transaction.
                        Customer.SetLoadFields("No.");
                        if Customer.FindSet() then
                            repeat
                                DueCustomerNos.Add(Customer."No.");
                            until Customer.Next() = 0;
                        AnonRunner.SetCheckPeriod(false);
                        foreach DueCustomerNo in DueCustomerNos do begin
                            AnonRunner.SetCustomer(DueCustomerNo);
                            if AnonRunner.Run() then begin
                                if AnonRunner.WasAnonymized() then
                                    VarCount += 1;
                            end else
                                Sentry.AddLastErrorIfProgrammingBug();
                            Commit();
                        end;
                    end else begin
                        Customer.SetFilter(Customer."NPR To Anonymize On", '>%1&<=%2', 0D, Today());
                        if Customer.FindSet() then
                            repeat
                                DoAnonymization(Customer."No.", ReasonText);
                            until Customer.Next() = 0;
                    end;
                end;
            true:
                begin
                    PopulateCustToAnonymise();
                    // Commit the staging-table writes made by PopulateCustToAnonymise before the first guarded
                    // Run below (a guarded Codeunit.Run may not be entered with uncommitted caller writes).
                    if CustomerGDPRV2.IsFeatureEnabled() then
                        Commit();
                    AnonRunner.SetCheckPeriod(true);
                    // Drain the queue with FindFirst (not FindSet+Next): each row is deleted as it is processed,
                    // so re-finding stays safe across the per-customer Commit and terminates.
                    CustToAnonymise.Reset();
                    while CustToAnonymise.FindFirst() do begin
                        if CustomerGDPRV2.IsFeatureEnabled() then begin
                            AnonRunner.SetCustomer(CustToAnonymise."Customer No");
                            if AnonRunner.Run() then begin
                                if AnonRunner.WasAnonymized() then
                                    VarCount += 1;
                            end else
                                Sentry.AddLastErrorIfProgrammingBug();
                        end else
                            DoAnonymization(CustToAnonymise."Customer No", ReasonText);
                        CustToAnonymise.Delete();
                        if CustomerGDPRV2.IsFeatureEnabled() then
                            Commit();
                        if VarCount = VarNoOfCustomers then
                            exit;
                    end;
                end;
        end;

    end;

    var
        CustomerHaveOpenEntriesMsg: Label 'You cannot anonymize Customer %1 because it has open entries/documents.', Comment = '%1=Customer No.';
        CustomerHasBeenAnonymizedMsg: Label 'Customer %1  has been anonymized.', Comment = '%1=Customer No.';
        CustomerForceAnonymizedMsg: Label 'Customer %1 has been anonymized (forced past the retention period).', Comment = '%1=Customer No.';
        UseMemberAnonymizationMsg: Label 'Customer %1 is a member. Please use Member Anonymization.', Comment = '%1=Customer No.';
        UserNotAllowedToAnonymizeErr: Label 'You do not have permission to anonymize customers. Contact your administrator to give you access.';
        CustomerDoesNotExistLbl: Label 'Customer does not exist.';
        CustomerAlreadyAnonymizedLbl: Label 'Customer has already been anonymized.';
        CustomerNotYetDueLbl: Label 'Customer not yet due to be anonymized.';
        CustomerIsBillToForOthersLbl: Label 'Customer cannot be anonymized: it is set as Bill-to Customer on one or more live customers. Re-point those customers or anonymize them first.';
        UnknownReasonLbl: Label 'Unknown reason.';
        UserNotAllowedToForceAnonymizeErr: Label 'You do not have permission to force customer anonymization. Contact your administrator to give you access.';
        CheckPeriodLbl: Label 'CHECK_PERIOD', Locked = true;
        NoOfCustomersLbl: Label 'NO_OF_CUSTOMERS', Locked = true;
        DefJobCategoryCodeLbl: Label 'NPR-GDPR', Locked = true;
        DefJobCategoryDescLbl: Label 'GDPR Anonymization';
        GDPRSetupMissingErr: Label 'Customer GDPR Setup is missing.';
        VarCheckPeriod: Boolean;
        EntryNo: Integer;
        VarCount: Integer;


    procedure DoAnonymization(CustNo: Code[20]; var VarReason: Text): Boolean
    var
        CustomerGDPRV2: Codeunit "NPR Customer GDPR V2";
        ActivityRefresh: Codeunit "NPR Cust. Activity Refresh";
        GDPRSetup: Record "NPR Customer GDPR SetUp";
        GDPRLogEntry: Record "NPR Customer GDPR Log Entries";
        UserSetup: Record "User Setup";
        VarPeriod: DateFormula;
        AnonymizationResponseValue: Integer;
        OpenDocFound, TransactionFound, OpenTransactionFound, MemberFound, JournalFound : Boolean;
        FeatureEnabled: Boolean;
    begin
        VarReason := ''; // caller may pass a page-global reused across invocations; never surface a stale reason
        FeatureEnabled := CustomerGDPRV2.IsFeatureEnabled();

        if FeatureEnabled then begin
            if not GDPRSetup.Get() then
                Error(GDPRSetupMissingErr);
        end else
            if GDPRSetup.Get() then;

        // Force permission is a superset of the base permission, so a force-permitted user may also run the
        // normal (non-forced) anonymization the Customer Card falls through to.
        if UserSetup.Get(UserId()) then begin
            if not (UserSetup."NPR Anonymize Customers" or UserSetup."NPR Force Anonymize Customers") then
                Error(UserNotAllowedToAnonymizeErr);
        end else
            Error(UserNotAllowedToAnonymizeErr);

        if GDPRLogEntry.FindLast() then
            EntryNo := GDPRLogEntry."Entry No";

        // Re-verify live activity before the irreversible wipe; persist so the -3 gate below reads fresh data.
        if FeatureEnabled then
            ActivityRefresh.RecalculateForAnonymization(CustNo);

        if VarCheckPeriod then
            Evaluate(VarPeriod, '-' + Format(GDPRSetup."Anonymize After"));
        IsCustomerValidForAnonymization(CustNo, VarCheckPeriod, VarPeriod, false, AnonymizationResponseValue);

        // Decode negative reason codes (-1 not found, -2 already anonymized, -3 not due, -4 Bill-to) regardless
        // of the feature flag. -4 (and -1/-2) are set independent of the feature, and feeding a negative value
        // into the bit-decoder below would wrongly decode to "all gates clear" and anonymize the customer.
        if CheckNegativeResponseValue(AnonymizationResponseValue, VarReason) then begin
            InsertLogEntry(CustNo, false, false, false, false, false, false, VarReason);
            exit(false);
        end;

        OpenDocFound := EvaluateResponseValue(AnonymizationResponseValue, 0);
        TransactionFound := EvaluateResponseValue(AnonymizationResponseValue, 1);
        OpenTransactionFound := EvaluateResponseValue(AnonymizationResponseValue, 2);
        MemberFound := EvaluateResponseValue(AnonymizationResponseValue, 3);
        JournalFound := EvaluateResponseValue(AnonymizationResponseValue, 4);

        if (OpenDocFound = false) and (TransactionFound = false) and (OpenTransactionFound = false) and (MemberFound = false) and (JournalFound = false) then begin
            AnonymizeCustomer(CustNo);
            OnAfterDoAnonymization(CustNo);
            VarReason := StrSubstNo(CustomerHasBeenAnonymizedMsg, CustNo);
            if FeatureEnabled then
                InsertLogEntry(CustNo, true, OpenDocFound, OpenTransactionFound, TransactionFound, MemberFound, JournalFound, VarReason)
            else begin
                VarCount += 1;
                InsertLogEntry(CustNo, true, OpenDocFound, OpenTransactionFound, TransactionFound, MemberFound, JournalFound);
            end;
            exit(true);
        end;

        if (VarReason = '') and (MemberFound) then
            VarReason := StrSubstNo(UseMemberAnonymizationMsg, CustNo);
        if (VarReason = '') and (not MemberFound) then
            VarReason := StrSubstNo(CustomerHaveOpenEntriesMsg, CustNo);

        if FeatureEnabled then
            InsertLogEntry(CustNo, false, OpenDocFound, OpenTransactionFound, TransactionFound, MemberFound, JournalFound, VarReason)
        else
            InsertLogEntry(CustNo, false, OpenDocFound, OpenTransactionFound, TransactionFound, MemberFound, JournalFound);

        exit(false);
    end;

    procedure AnonymizeSingle(CustNo: Code[20]; CheckPeriod: Boolean; var VarReason: Text): Boolean
    begin
        // Entry point for the per-customer isolation runner ("NPR NP GDPR Anon. Runner"): set the
        // check-period mode on this (fresh) instance, then delegate to the shared anonymization logic.
        VarCheckPeriod := CheckPeriod;
        exit(DoAnonymization(CustNo, VarReason));
    end;

    procedure ForceAnonymization(CustNo: Code[20]; var VarReason: Text): Boolean
    var
        Customer: Record Customer;
        UserSetup: Record "User Setup";
        GDPRLogEntry: Record "NPR Customer GDPR Log Entries";
        VarPeriod: DateFormula;
        AnonymizationResponseValue: Integer;
        OpenDocFound, TransactionFound, OpenTransactionFound, MemberFound, JournalFound : Boolean;
    begin
        if UserSetup.Get(UserId()) then begin
            if not UserSetup."NPR Force Anonymize Customers" then
                Error(UserNotAllowedToForceAnonymizeErr);
        end else
            Error(UserNotAllowedToForceAnonymizeErr);

        if not Customer.Get(CustNo) then begin
            VarReason := CustomerDoesNotExistLbl;
            exit(false);
        end;

        if Customer."NPR Anonymized" then begin
            VarReason := CustomerAlreadyAnonymizedLbl;
            exit(false);
        end;

        if GDPRLogEntry.FindLast() then
            EntryNo := GDPRLogEntry."Entry No";

        if IsReferencedAsBillToByLiveCustomer(CustNo) then begin
            VarReason := CustomerIsBillToForOthersLbl;
            InsertLogEntry(CustNo, false, false, false, false, false, false, VarReason);
            exit(false);
        end;

        // Gated force: override only the soft retention gate (not-yet-due / recent activity), but still refuse
        // every hard integrity gate (open documents, open ledger entries, active membership, pending journal
        // lines) so a forced erasure can never orphan data.
        IsCustomerValidForAnonymization(CustNo, false, VarPeriod, true, AnonymizationResponseValue);
        OpenDocFound := EvaluateResponseValue(AnonymizationResponseValue, 0);
        TransactionFound := EvaluateResponseValue(AnonymizationResponseValue, 1);
        OpenTransactionFound := EvaluateResponseValue(AnonymizationResponseValue, 2);
        MemberFound := EvaluateResponseValue(AnonymizationResponseValue, 3);
        JournalFound := EvaluateResponseValue(AnonymizationResponseValue, 4);

        if OpenDocFound or OpenTransactionFound or MemberFound or JournalFound then begin
            if MemberFound then
                VarReason := StrSubstNo(UseMemberAnonymizationMsg, CustNo)
            else
                VarReason := StrSubstNo(CustomerHaveOpenEntriesMsg, CustNo);
            InsertLogEntry(CustNo, false, OpenDocFound, OpenTransactionFound, TransactionFound, MemberFound, JournalFound, VarReason);
            exit(false);
        end;

        AnonymizeCustomer(CustNo);
        OnAfterDoAnonymization(CustNo);
        VarReason := StrSubstNo(CustomerForceAnonymizedMsg, CustNo);
        InsertLogEntry(CustNo, true, false, false, false, false, false, VarReason);
        exit(true);
    end;

    procedure IsBlockedByRetentionOnly(CustNo: Code[20]): Boolean
    var
        VarPeriod: DateFormula;
        AnonymizationResponseValue: Integer;
    begin
        // True only when the customer fails the normal gates BUT the sole blocker is the retention schedule -
        // i.e. with the retention gate overridden it is fully anonymizable (no open documents, ledger entries,
        // active membership, pending journal lines or Bill-to reference). The Customer Card uses this to decide
        // whether to offer the force option, and to skip the normal, failure-logging path when it will force.
        if IsCustomerValidForAnonymization(CustNo, false, VarPeriod, false, AnonymizationResponseValue) then
            exit(false);
        exit(IsCustomerValidForAnonymization(CustNo, false, VarPeriod, true, AnonymizationResponseValue));
    end;

    local procedure CheckNegativeResponseValue(AnonymizationResponseValue: Integer; var VarReason: Text): Boolean
    begin
        if AnonymizationResponseValue >= 0 then
            exit(false);

        case AnonymizationResponseValue of
            -1:
                VarReason := CustomerDoesNotExistLbl;
            -2:
                VarReason := CustomerAlreadyAnonymizedLbl;
            -3:
                VarReason := CustomerNotYetDueLbl;
            -4:
                VarReason := CustomerIsBillToForOthersLbl;
            else
                VarReason := UnknownReasonLbl;
        end;

        exit(true);
    end;

    procedure IsCustomerValidForAnonymization(CustomerNo: Code[20]; LimitedTimePeriod: Boolean; LimitingDateFormula: DateFormula; OverrideRetentionGate: Boolean; var ReasonCode: Integer): Boolean
    var
        CustomerGDPRV2: Codeunit "NPR Customer GDPR V2";
        CLE: Record "Cust. Ledger Entry";
        SalesHdr: Record "Sales Header";
        Membership: Record "NPR MM Membership";
        ILE: Record "Item Ledger Entry";
        GenJnlLine: Record "Gen. Journal Line";
        Customer: Record Customer;
    begin
        ReasonCode := 0;

        if (not Customer.Get(CustomerNo)) then begin
            ReasonCode := -1;
            exit(false);
        end;

        if (Customer."NPR Anonymized") then begin
            ReasonCode := -2;
            exit(false);
        end;

        if CustomerGDPRV2.IsFeatureEnabled() then
            if (not OverrideRetentionGate) and (Customer."NPR Estimated Cleanup Date" <> 0D) and (Customer."NPR Estimated Cleanup Date" > Today()) then begin
                ReasonCode := -3;
                exit(false);
            end;

        // Bill-to is a data-integrity gate, not a GDPR-feature gate: anonymizing a customer still referenced as
        // Bill-to by a live customer would break that customer's invoicing, so it must block regardless of the
        // feature flag and can never be bypassed by a force override.
        if IsReferencedAsBillToByLiveCustomer(CustomerNo) then begin
            ReasonCode := -4;
            exit(false);
        end;

        SalesHdr.SetCurrentKey("Sell-to Customer No.", "External Document No.");
        SalesHdr.SetRange("Sell-to Customer No.", CustomerNo);
        if not SalesHdr.IsEmpty() then
            ReasonCode += Power(2, 0);

        if LimitedTimePeriod and (not OverrideRetentionGate) then begin
            CLE.SetCurrentKey("Customer No.", "Posting Date", "Currency Code");
            CLE.SetRange("Customer No.", CustomerNo);
            CLE.SetFilter("Posting Date", '>%1', CalcDate(LimitingDateFormula, Today()));
            if not CLE.IsEmpty() then
                ReasonCode += Power(2, 1)
            else begin
                ILE.Reset();
                ILE.SetCurrentKey("Source Type", "Source No.", "Item No.", "Variant Code", "Posting Date");
                ILE.SetRange(ILE."Source Type", ILE."Source Type"::Customer);
                ILE.SetRange(ILE."Source No.", CustomerNo);
                ILE.SetFilter("Posting Date", '>%1', CalcDate(LimitingDateFormula, Today()));
                if not ILE.IsEmpty() then
                    ReasonCode += Power(2, 1);
            end;
        end;

        CLE.Reset();
        CLE.SetCurrentKey("Customer No.", Open, Positive, "Due Date", "Currency Code");
        CLE.SetRange("Customer No.", CustomerNo);
        CLE.SetRange(Open, true);
        if not CLE.IsEmpty() then
            ReasonCode += Power(2, 2);

        Membership.SetRange("Customer No.", CustomerNo);
        if not Membership.IsEmpty() then
            ReasonCode += Power(2, 3);

        GenJnlLine.SetRange(GenJnlLine."Account Type", GenJnlLine."Account Type"::Customer);
        GenJnlLine.SetRange(GenJnlLine."Account No.", CustomerNo);
        if not GenJnlLine.IsEmpty() then
            ReasonCode += Power(2, 4);

        exit(ReasonCode = 0);
    end;

    local procedure IsReferencedAsBillToByLiveCustomer(VarCustNo: Code[20]): Boolean
    var
        BillToCustomer: Record Customer;
    begin
        BillToCustomer.SetRange("Bill-to Customer No.", VarCustNo);
        BillToCustomer.SetFilter("No.", '<>%1', VarCustNo);
        BillToCustomer.SetRange("NPR Anonymized", false);
        exit(not BillToCustomer.IsEmpty());
    end;

    local procedure EvaluateResponseValue(ResponseValue: Integer; BitPosition: Integer): Boolean
    begin
        exit((Round(ResponseValue / Power(2, BitPosition), 1, '<') mod 2 = 1))
    end;

    procedure AnonymizeCustomer(CustNo: Code[20])
    var
        Customer: Record Customer;
    begin
        AnonymizePrimaryContact(CustNo);
        AnonymizeSalesInvoices(CustNo);
        AnonymizeSalesCrMemos(CustNo);
        AnonymizeSalesShipments(CustNo);
        AnonymizeReturnReceipts(CustNo);
        AnonymizeJobs(CustNo);
        AnonymizeIssuedReminders(CustNo);

        if not Customer.Get(CustNo) then
            exit;

        Customer.Name := '------';
        Customer."Search Name" := '------';
        Customer."Name 2" := '------';
        Customer.Address := '------ --';
        Customer."Address 2" := '------ --';
        Customer.City := '';
        Customer.Contact := '------';
        Customer."Phone No." := '';
        Customer."Telex No." := '';
        Customer."Fax No." := '';
        Customer."VAT Registration No." := '';
        if Customer.Image.HasValue() then
            Clear(Customer.Image);
        Customer.GLN := '';
        Customer."Post Code" := '';
        Customer."Country/Region Code" := '';
        Customer."E-Mail" := '------@----';
        Customer."Home Page" := 'nowhere.com';
        Customer."NPR Anonymized" := true;
        Customer."NPR Anonymized Date" := CurrentDateTime;
        Customer."NPR To Anonymize" := false;

        Customer.Blocked := Customer.Blocked::All;
        // Persist without firing OnModify: the customer's contact is already anonymized explicitly above
        // (AnonymizePrimaryContact/AnonymizeCompanyNo, which preserves a shared contact). Letting the
        // standard Customer->Contact sync (CustCont-Update) run here would re-touch the shared contact and
        // cascade the anonymized data to other entities linked to it (other customers, vendors).
        Customer.Modify(false);
    end;

    local procedure AnonymizePrimaryContact(VarCustNo: Code[20])
    var
        Contact: Record Contact;
        ContBusRel: Record "Contact Business Relation";
    begin
        ContBusRel.SetCurrentKey("Link to Table", "No.");
        ContBusRel.SetRange("Link to Table", ContBusRel."Link to Table"::Customer);
        ContBusRel.SetRange("No.", VarCustNo);
        if not ContBusRel.FindFirst() then
            exit;

        if not Contact.Get(ContBusRel."Contact No.") then
            exit;

        // When the primary contact is the company-level record itself (BC's default for a customer),
        // route through the guarded company-wipe path so a shared company is preserved.
        if Contact.Type = Contact.Type::Company then begin
            AnonymizeCompanyNo(Contact."No.", VarCustNo);
            exit;
        end;

        Contact.Name := '------';
        Contact."Search Name" := '------';
        Contact."Name 2" := '------';
        Contact.Address := '------ --';
        Contact."Address 2" := '------ --';
        Contact.City := '';
        Contact."Phone No." := '';
        Contact."Fax No." := '';
        Contact."VAT Registration No." := '';
        if Contact.Image.HasValue() then
            Clear(Contact.Image);
        Contact."Post Code" := '';
        Contact."Country/Region Code" := '';
        Contact."E-Mail" := '------@----';
        Contact."Home Page" := 'www.nowhere.com';
        Contact."First Name" := '------';
        Contact."Middle Name" := '------';
        Contact.Surname := '------';
        Contact."Job Title" := '------';
        Contact.Initials := '------';
        Contact."Mobile Phone No." := '';
        Contact."Search E-Mail" := '------@----';
        Contact."Company Name" := '------';
        Contact.Pager := '';
        Contact."NPR Magento Contact" := false;
        Contact.Modify(true);

        if Contact."Company No." = '' then
            exit;
        AnonymizeCompanyNo(Contact."Company No.", VarCustNo);
    end;

    local procedure AnonymizeCompanyNo(VarContactNo: Code[20]; VarAnonymizingCustNo: Code[20])
    var
        Contact: Record Contact;
    begin
        if VarContactNo = '' then
            exit;

        if IsCompanyContactSharedWithOtherEntities(VarContactNo, VarAnonymizingCustNo) then
            exit;

        if Contact.Get(VarContactNo) then begin
            Contact.Name := '------';
            Contact."Search Name" := '------';
            Contact."Name 2" := '------';
            Contact.Address := '------ --';
            Contact."Address 2" := '------ --';
            Contact.City := '';
            Contact."Phone No." := '';
            Contact."Fax No." := '';
            Contact."VAT Registration No." := '';
            if Contact.Image.HasValue() then
                Clear(Contact.Image);
            Contact."Post Code" := '';
            Contact."Country/Region Code" := '';
            Contact."E-Mail" := '------@----';
            Contact."Home Page" := 'www.nowhere.com';
            Contact."First Name" := '------';
            Contact."Middle Name" := '------';
            Contact.Surname := '------';
            Contact."Job Title" := '------';
            Contact.Initials := '------';
            Contact."Mobile Phone No." := '';
            Contact."Search E-Mail" := '------@----';
            Contact."Company Name" := '------';
            Contact.Pager := '';
            Contact."NPR Magento Contact" := false;
            Contact.Modify(true);
        end;
    end;

    local procedure IsCompanyContactSharedWithOtherEntities(VarCompanyContactNo: Code[20]; VarAnonymizingCustNo: Code[20]): Boolean
    var
        ContBusRel: Record "Contact Business Relation";
        Customer: Record Customer;
    begin
        ContBusRel.SetRange("Contact No.", VarCompanyContactNo);
        if not ContBusRel.FindSet() then
            exit(false);

        repeat
            case ContBusRel."Link to Table" of
                ContBusRel."Link to Table"::Customer:
                    if ContBusRel."No." <> VarAnonymizingCustNo then
                        if Customer.Get(ContBusRel."No.") then
                            if not Customer."NPR Anonymized" then
                                exit(true);
                ContBusRel."Link to Table"::Vendor,
                ContBusRel."Link to Table"::"Bank Account",
                ContBusRel."Link to Table"::Employee:
                    exit(true);
            end;
        until ContBusRel.Next() = 0;

        exit(false);
    end;

    local procedure AnonymizeSalesInvoices(VarCustNo: Code[20])
    var
        SalesInvHdr: Record "Sales Invoice Header";
    begin
        SalesInvHdr.SetRange("Sell-to Customer No.", VarCustNo);
        if SalesInvHdr.IsEmpty() then
            exit;
        SalesInvHdr.FindSet();
        repeat
            SalesInvHdr."Sell-to Customer Name" := '------';
            SalesInvHdr."Sell-to Customer Name 2" := '------';
            SalesInvHdr."Sell-to Address" := '------ --';
            SalesInvHdr."Sell-to Address 2" := '------ --';
            SalesInvHdr."Sell-to City" := '';
            SalesInvHdr."Sell-to Contact" := '------';
            SalesInvHdr."Sell-to Post Code" := '';
            SalesInvHdr."Sell-to County" := '';
            SalesInvHdr."Sell-to Country/Region Code" := '';
            SalesInvHdr."Ship-to Post Code" := '';
            SalesInvHdr."Ship-to County" := '';
            SalesInvHdr."Ship-to Country/Region Code" := '';
            SalesInvHdr."Ship-to Name" := '------';
            SalesInvHdr."Ship-to Name 2" := '------';
            SalesInvHdr."Ship-to Address" := '------ --';
            SalesInvHdr."Ship-to Address 2" := '------ --';
            SalesInvHdr."Ship-to City" := '';
            SalesInvHdr."Ship-to Contact" := '------';
            SalesInvHdr."Ship-to Code" := '';

            // Wipe Bill-to identity only when the Bill-to is the same anonymized customer.
            // A third-party Bill-to (e.g. a parent company that paid for a subsidiary) must keep its link and details so it can still trace the invoices it paid.
            if SalesInvHdr."Bill-to Customer No." = VarCustNo then begin
                SalesInvHdr."VAT Registration No." := '';
                SalesInvHdr."Bill-to Customer No." := '';
                SalesInvHdr."Bill-to Name" := '------';
                SalesInvHdr."Bill-to Name 2" := '------';
                SalesInvHdr."Bill-to Address" := '------ --';
                SalesInvHdr."Bill-to Address 2" := '------ --';
                SalesInvHdr."Bill-to City" := '';
                SalesInvHdr."Bill-to Contact" := '------';
                SalesInvHdr."Bill-to Post Code" := '';
                SalesInvHdr."Bill-to County" := '';
                SalesInvHdr."Bill-to Country/Region Code" := '';
            end;

            SalesInvHdr.Modify(true);
        until SalesInvHdr.Next() = 0;
    end;

    local procedure AnonymizeSalesCrMemos(VarCustNo: Code[20])
    var
        SalesCrMemoHdr: Record "Sales Cr.Memo Header";
    begin
        SalesCrMemoHdr.SetRange("Sell-to Customer No.", VarCustNo);
        if SalesCrMemoHdr.IsEmpty() then
            exit;
        SalesCrMemoHdr.FindSet();
        repeat
            SalesCrMemoHdr."Sell-to Customer Name" := '------';
            SalesCrMemoHdr."Sell-to Customer Name 2" := '------';
            SalesCrMemoHdr."Sell-to Address" := '------ --';
            SalesCrMemoHdr."Sell-to Address 2" := '------ --';
            SalesCrMemoHdr."Sell-to City" := '';
            SalesCrMemoHdr."Sell-to Contact" := '------';
            SalesCrMemoHdr."Sell-to Post Code" := '';
            SalesCrMemoHdr."Sell-to County" := '';
            SalesCrMemoHdr."Sell-to Country/Region Code" := '';
            SalesCrMemoHdr."Ship-to Post Code" := '';
            SalesCrMemoHdr."Ship-to County" := '';
            SalesCrMemoHdr."Ship-to Country/Region Code" := '';
            SalesCrMemoHdr."Ship-to Name" := '------';
            SalesCrMemoHdr."Ship-to Name 2" := '------';
            SalesCrMemoHdr."Ship-to Address" := '------ --';
            SalesCrMemoHdr."Ship-to Address 2" := '------ --';
            SalesCrMemoHdr."Ship-to City" := '';
            SalesCrMemoHdr."Ship-to Contact" := '------';
            SalesCrMemoHdr."Ship-to Code" := '';

            if SalesCrMemoHdr."Bill-to Customer No." = VarCustNo then begin
                SalesCrMemoHdr."VAT Registration No." := '';
                SalesCrMemoHdr."Bill-to Customer No." := '';
                SalesCrMemoHdr."Bill-to Name" := '------';
                SalesCrMemoHdr."Bill-to Name 2" := '------';
                SalesCrMemoHdr."Bill-to Address" := '------ --';
                SalesCrMemoHdr."Bill-to Address 2" := '------ --';
                SalesCrMemoHdr."Bill-to City" := '';
                SalesCrMemoHdr."Bill-to Contact" := '------';
                SalesCrMemoHdr."Bill-to Post Code" := '';
                SalesCrMemoHdr."Bill-to County" := '';
                SalesCrMemoHdr."Bill-to Country/Region Code" := '';
            end;

            SalesCrMemoHdr.Modify(true);
        until SalesCrMemoHdr.Next() = 0;
    end;

    local procedure InsertLogEntry(CustNo: Code[20]; Success: Boolean; OpenSales: Boolean; OpenCLE: Boolean; TransactionInPeriod: Boolean; Member: Boolean; Journals: Boolean)
    begin
        InsertLogEntry(CustNo, Success, OpenSales, OpenCLE, TransactionInPeriod, Member, Journals, '');
    end;

    local procedure InsertLogEntry(CustNo: Code[20]; Success: Boolean; OpenSales: Boolean; OpenCLE: Boolean; TransactionInPeriod: Boolean; Member: Boolean; Journals: Boolean; Reason: Text)
    var
        GDPRLogEntry: Record "NPR Customer GDPR Log Entries";
    begin
        GDPRLogEntry.Init();
        GDPRLogEntry."Entry No" := EntryNo + 1;
        GDPRLogEntry."Customer No" := CustNo;
        case Success of
            true:
                GDPRLogEntry.Status := GDPRLogEntry.Status::Anonymised;
            false:
                GDPRLogEntry.Status := GDPRLogEntry.Status::"Could Not be anonymised";
        end;

        GDPRLogEntry."Open Sales Documents" := OpenSales;
        GDPRLogEntry."Open Cust. Ledger Entry" := OpenCLE;
        GDPRLogEntry."Has transactions" := TransactionInPeriod;
        GDPRLogEntry."Customer is a Member" := Member;
        GDPRLogEntry."Open Journal Entries/Statement" := Journals;
        GDPRLogEntry."Log Entry Date Time" := CurrentDateTime;
        GDPRLogEntry."Anonymized By" := CopyStr(UserId, 1, MaxStrLen(GDPRLogEntry."Anonymized By"));
        if Reason <> '' then
            GDPRLogEntry.Reason := CopyStr(Reason, 1, MaxStrLen(GDPRLogEntry.Reason));
        GDPRLogEntry.Insert();

        EntryNo += 1;
    end;

    local procedure AnonymizeSalesShipments(VarCustNo: Code[20])
    var
        SalesShipmentHdr: Record "Sales Shipment Header";
    begin
        SalesShipmentHdr.SetRange("Sell-to Customer No.", VarCustNo);
        if SalesShipmentHdr.IsEmpty() then
            exit;
        SalesShipmentHdr.FindSet();
        repeat
            SalesShipmentHdr."Sell-to Customer Name" := '------';
            SalesShipmentHdr."Sell-to Customer Name 2" := '------';
            SalesShipmentHdr."Sell-to Address" := '------ --';
            SalesShipmentHdr."Sell-to Address 2" := '------ --';
            SalesShipmentHdr."Sell-to City" := '';
            SalesShipmentHdr."Sell-to Contact" := '------';
            SalesShipmentHdr."Sell-to Post Code" := '';
            SalesShipmentHdr."Sell-to County" := '';
            SalesShipmentHdr."Sell-to Country/Region Code" := '';
            SalesShipmentHdr."Ship-to Post Code" := '';
            SalesShipmentHdr."Ship-to County" := '';
            SalesShipmentHdr."Ship-to Country/Region Code" := '';
            SalesShipmentHdr."Ship-to Name" := '------';
            SalesShipmentHdr."Ship-to Name 2" := '------';
            SalesShipmentHdr."Ship-to Address" := '------ --';
            SalesShipmentHdr."Ship-to Address 2" := '------ --';
            SalesShipmentHdr."Ship-to City" := '';
            SalesShipmentHdr."Ship-to Contact" := '------';
            SalesShipmentHdr."Ship-to Code" := '';

            if SalesShipmentHdr."Bill-to Customer No." = VarCustNo then begin
                SalesShipmentHdr."VAT Registration No." := '';
                SalesShipmentHdr."Bill-to Customer No." := '';
                SalesShipmentHdr."Bill-to Name" := '------';
                SalesShipmentHdr."Bill-to Name 2" := '------';
                SalesShipmentHdr."Bill-to Address" := '------ --';
                SalesShipmentHdr."Bill-to Address 2" := '------ --';
                SalesShipmentHdr."Bill-to City" := '';
                SalesShipmentHdr."Bill-to Contact" := '------';
                SalesShipmentHdr."Bill-to Post Code" := '';
                SalesShipmentHdr."Bill-to County" := '';
                SalesShipmentHdr."Bill-to Country/Region Code" := '';
            end;

            SalesShipmentHdr.Modify(true);
        until SalesShipmentHdr.Next() = 0;
    end;

    local procedure AnonymizeReturnReceipts(VarCustNo: Code[20])
    var
        ReturnRcptHdr: Record "Return Receipt Header";
    begin
        ReturnRcptHdr.SetRange("Sell-to Customer No.", VarCustNo);
        if ReturnRcptHdr.IsEmpty() then
            exit;
        ReturnRcptHdr.FindSet();
        repeat
            ReturnRcptHdr."Sell-to Customer Name" := '------';
            ReturnRcptHdr."Sell-to Customer Name 2" := '------';
            ReturnRcptHdr."Sell-to Address" := '------ --';
            ReturnRcptHdr."Sell-to Address 2" := '------ --';
            ReturnRcptHdr."Sell-to City" := '';
            ReturnRcptHdr."Sell-to Contact" := '------';
            ReturnRcptHdr."Sell-to Post Code" := '';
            ReturnRcptHdr."Sell-to County" := '';
            ReturnRcptHdr."Sell-to Country/Region Code" := '';
            ReturnRcptHdr."Ship-to Post Code" := '';
            ReturnRcptHdr."Ship-to County" := '';
            ReturnRcptHdr."Ship-to Country/Region Code" := '';
            ReturnRcptHdr."Ship-to Name" := '------';
            ReturnRcptHdr."Ship-to Name 2" := '------';
            ReturnRcptHdr."Ship-to Address" := '------ --';
            ReturnRcptHdr."Ship-to Address 2" := '------ --';
            ReturnRcptHdr."Ship-to City" := '';
            ReturnRcptHdr."Ship-to Contact" := '------';
            ReturnRcptHdr."Ship-to Code" := '';

            if ReturnRcptHdr."Bill-to Customer No." = VarCustNo then begin
                ReturnRcptHdr."VAT Registration No." := '';
                ReturnRcptHdr."Bill-to Customer No." := '';
                ReturnRcptHdr."Bill-to Name" := '------';
                ReturnRcptHdr."Bill-to Name 2" := '------';
                ReturnRcptHdr."Bill-to Address" := '------ --';
                ReturnRcptHdr."Bill-to Address 2" := '------ --';
                ReturnRcptHdr."Bill-to City" := '';
                ReturnRcptHdr."Bill-to Contact" := '------';
                ReturnRcptHdr."Bill-to Post Code" := '';
                ReturnRcptHdr."Bill-to County" := '';
                ReturnRcptHdr."Bill-to Country/Region Code" := '';
            end;

            ReturnRcptHdr.Modify(true);
        until ReturnRcptHdr.Next() = 0;
    end;

    local procedure AnonymizeJobs(VarCustNo: Code[20])
    var
        Job: Record Job;
    begin
        Job.Reset();
        Job.SetRange("Bill-to Customer No.", VarCustNo);
        if Job.IsEmpty() then
            exit;
        Job.FindSet();
        repeat
            Job."Bill-to Address" := '------ --';
            Job."Bill-to Address 2" := '------ --';
            Job."Bill-to City" := '';
            Job."Bill-to Contact" := '------';
            Job."Bill-to Country/Region Code" := '';
            Job."Bill-to County" := '';
            Job."NPR Bill-to E-Mail" := '------@----';
            Job."Bill-to Name" := '------';
            Job."Bill-to Name 2" := '------';
            Job."Bill-to Post Code" := '';
            Job."NPR Organizer E-Mail" := '------@----';
            Job."Person Responsible" := '------';
            Job.Modify(true);
        until Job.Next() = 0;
    end;

    internal procedure PopulateCustToAnonymise()
    var
        CustomerGDPRV2: Codeunit "NPR Customer GDPR V2";
        Customer: Record Customer;
        GDPRSetup: Record "NPR Customer GDPR SetUp";
        CustToAnonymize: Record "NPR Customers to Anonymize";
        DateFormulaTxt: Text[250];
        VarPeriod: DateFormula;
        Window: Dialog;
        VarEntryNo, CalculatedVarPeriod : Integer;
        NoTrans, NoTransPeriod : Boolean;
        Text000: Label 'Existing Customers will be lost, do you want to continue?';
    begin
        if CustomerGDPRV2.IsFeatureEnabled() then begin
            if not GDPRSetup.Get() then
                Error(GDPRSetupMissingErr);
        end else
            if GDPRSetup.Get() then;

        CustToAnonymize.Reset();
        if GuiAllowed then
            if (CustToAnonymize.FindFirst()) then
                if (not Confirm(Text000, false)) then
                    exit;

        CustToAnonymize.DeleteAll();

        if GuiAllowed then
            Window.Open('Customer #1##################');

        VarEntryNo := 0;

        Customer.SetRange("NPR Anonymized", false);
        Customer.SetFilter("Customer Posting Group", GDPRSetup."Customer Posting Group Filter");
        Customer.SetFilter("Gen. Bus. Posting Group", GDPRSetup."Gen. Bus. Posting Group Filter");

        if CustomerGDPRV2.IsFeatureEnabled() then begin
            Customer.SetFilter("NPR Estimated Cleanup Date", '<>%1&<=%2', 0D, Today());
            if Customer.FindSet() then
                repeat
                    if GuiAllowed then
                        Window.Update(1, Customer."No.");
                    InsertCustomerToAnonymize(VarEntryNo, Customer."No.", Customer.Name);
                until Customer.Next() = 0;
        end else begin
            DateFormulaTxt := '-' + Format(GDPRSetup."Anonymize After");
            Evaluate(VarPeriod, DateFormulaTxt);
            CalculatedVarPeriod := Today - CalcDate(VarPeriod, Today);

            Customer.SetFilter("Last Date Modified", '<>%1', 0D);
            if Customer.FindSet() then
                repeat
                    if GuiAllowed then
                        Window.Update(1, Customer."No.");

                    NoTrans := CheckNoTransactions(Customer."No.", false, 0D);
                    if NoTrans then begin
                        if (Today - Customer."Last Date Modified") >= CalculatedVarPeriod then
                            InsertCustomerToAnonymize(VarEntryNo, Customer."No.", Customer.Name);
                    end else begin
                        NoTransPeriod := CheckNoTransactions(Customer."No.", true, CalcDate(VarPeriod, Today()));

                        if NoTransPeriod then
                            InsertCustomerToAnonymize(VarEntryNo, Customer."No.", Customer.Name);
                    end;
                until Customer.Next() = 0;
        end;

        if GuiAllowed then begin
            Window.Close();
            Message('Completed');
        end;
    end;

    local procedure CheckNoTransactions(CustomerNo: Code[20]; CheckForPeriod: Boolean; PeriodCalcDate: Date): Boolean
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        CustLedgerEntry.SetCurrentKey("Customer No.", "Posting Date", "Currency Code");
        CustLedgerEntry.SetRange("Customer No.", CustomerNo);
        if CheckForPeriod then
            CustLedgerEntry.SetFilter("Posting Date", '>%1', PeriodCalcDate);

        if CustLedgerEntry.IsEmpty() then begin
            ItemLedgerEntry.SetCurrentKey("Source Type", "Source No.", "Item No.", "Variant Code", "Posting Date");
            ItemLedgerEntry.SetRange(ItemLedgerEntry."Source Type", ItemLedgerEntry."Source Type"::Customer);
            ItemLedgerEntry.SetRange(ItemLedgerEntry."Source No.", CustomerNo);
            if CheckForPeriod then
                ItemLedgerEntry.SetFilter("Posting Date", '>%1', PeriodCalcDate);

            exit(CustLedgerEntry.IsEmpty() and ItemLedgerEntry.IsEmpty());
        end;

        exit(false);
    end;

    local procedure InsertCustomerToAnonymize(var _EntryNo: Integer; CustomerNo: Code[20]; CustomerName: Text[100])
    var
        CustToAnonymize: Record "NPR Customers to Anonymize";
    begin
        CustToAnonymize.Init();
        CustToAnonymize."Entry No" := _EntryNo;
        CustToAnonymize."Customer No" := CustomerNo;
        CustToAnonymize."Customer Name" := CustomerName;
        CustToAnonymize.Insert();
        _EntryNo += 1;
    end;

    local procedure AnonymizeIssuedReminders(VarCustNo: Code[20])
    var
        IssuedReminderHdr: Record "Issued Reminder Header";
    begin
        IssuedReminderHdr.SetRange("Customer No.", VarCustNo);
        if IssuedReminderHdr.IsEmpty() then
            exit;
        IssuedReminderHdr.FindSet();
        repeat
            IssuedReminderHdr.Name := '------';
            IssuedReminderHdr."Name 2" := '------';
            IssuedReminderHdr.Address := '------ --';
            IssuedReminderHdr."Address 2" := '------ --';
            IssuedReminderHdr."Post Code" := '';
            IssuedReminderHdr.City := '';
            IssuedReminderHdr.County := '';
            IssuedReminderHdr."Country/Region Code" := '';
            IssuedReminderHdr."VAT Registration No." := '';
            IssuedReminderHdr.Modify(true);
        until IssuedReminderHdr.Next() = 0;

    end;

    procedure ShowJobQueueEntries(CustomerGDPRSetup: Record "NPR Customer GDPR SetUp")
    var
        JobQueueEntry: Record "Job Queue Entry";
        PageManagement: Codeunit "Page Management";
    begin
        FilterJobQueueEntries(JobQueueEntry, CustomerGDPRSetup);
        PageManagement.PageRun(JobQueueEntry);
    end;

    procedure EnqueueJobEntries(var CustomerGDPRSetup: Record "NPR Customer GDPR SetUp")
    var
        CustomerGDPRV2: Codeunit "NPR Customer GDPR V2";
        CustomerCount: Integer;
    begin
        if CustomerGDPRSetup."Enable Job Queue" then begin
            CustomerCount := 2500;
            EnableJobQueueEntry(CustomerGDPRSetup, true, CustomerCount);
            EnableJobQueueEntry(CustomerGDPRSetup, false);

            if CustomerGDPRV2.IsFeatureEnabled() then
                EnableActivityRefreshJobQueueEntry(CustomerGDPRSetup);
        end else begin
            DisableJobQueueEntries(CustomerGDPRSetup);
        end;
    end;

    local procedure DisableJobQueueEntries(CustomerGDPRSetup: Record "NPR Customer GDPR SetUp")
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
    begin
        FilterJobQueueEntries(JobQueueEntry, CustomerGDPRSetup);
        if not JobQueueEntry.IsEmpty() then
            JobQueueMgt.CancelNpManagedJobs(JobQueueEntry);
    end;

    local procedure FilterJobQueueEntries(var JobQueueEntry: Record "Job Queue Entry"; CustomerGDPRSetup: Record "NPR Customer GDPR SetUp")
    begin
        JobQueueEntry.Reset();
        JobQueueEntry.SetRange("Record ID to Process", CustomerGDPRSetup.RecordId());
    end;

    local procedure EnableJobQueueEntry(CustomerGDPRSetup: Record "NPR Customer GDPR SetUp"; ParameterCheckPeriod: Boolean; ParameterNoOfCustomers: Integer)
    var
        JObject: JsonObject;
        JobQueueParameterString: Text;
    begin
        JObject.Add(CheckPeriodLbl, ParameterCheckPeriod);
        JObject.Add(NoOfCustomersLbl, ParameterNoOfCustomers);
        JObject.WriteTo(JobQueueParameterString);
        ScheduleJobQueueEntry(CustomerGDPRSetup, JobQueueParameterString);
    end;

    local procedure EnableJobQueueEntry(CustomerGDPRSetup: Record "NPR Customer GDPR SetUp"; ParameterCheckPeriod: Boolean)
    var
        JObject: JsonObject;
        JobQueueParameterString: Text;
    begin
        JObject.Add(CheckPeriodLbl, ParameterCheckPeriod);
        JObject.WriteTo(JobQueueParameterString);
        ScheduleJobQueueEntry(CustomerGDPRSetup, JobQueueParameterString);
    end;

    local procedure ScheduleJobQueueEntry(CustomerGDPRSetup: Record "NPR Customer GDPR SetUp"; JobQueueParameterString: Text)
    var
        JobQueueCategory: Record "Job Queue Category";
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        NextRunDateFormula: DateFormula;
    begin
        Evaluate(NextRunDateFormula, '<1D>');
        JobQueueCategory.InsertRec(DefJobCategoryCodeLbl, DefJobCategoryDescLbl);
        JobQueueMgt.SetProtected(true);
        if JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            Codeunit::"NPR NP GDPR Management",
            JobQueueParameterString,
            DefJobCategoryDescLbl,
            JobQueueMgt.NowWithDelayInSeconds(360),
            230000T,
            235959T,
            NextRunDateFormula,
            JobQueueCategory.Code,
            CustomerGDPRSetup.RecordId(),
            JobQueueEntry)
        then
            JobQueueMgt.StartJobQueueEntry(JobQueueEntry);
    end;

    local procedure EnableActivityRefreshJobQueueEntry(CustomerGDPRSetup: Record "NPR Customer GDPR SetUp")
    var
        JobQueueCategory: Record "Job Queue Category";
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        NextRunDateFormula: DateFormula;
    begin
        Evaluate(NextRunDateFormula, '<1D>');
        JobQueueCategory.InsertRec(DefJobCategoryCodeLbl, DefJobCategoryDescLbl);
        JobQueueMgt.SetProtected(true);
        if JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            Codeunit::"NPR Cust. Activity Refresh",
            '',
            DefJobCategoryDescLbl,
            JobQueueMgt.NowWithDelayInSeconds(360),
            230000T,
            235959T,
            NextRunDateFormula,
            JobQueueCategory.Code,
            CustomerGDPRSetup.RecordId(),
            JobQueueEntry)
        then
            JobQueueMgt.StartJobQueueEntry(JobQueueEntry);
    end;

    local procedure GetJobQueueParameters(var ParameterCheckPeriod: Boolean; var ParameterNoOfCustomers: Integer; ParameterString: Text)
    var
        JObject: JsonObject;
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        ParameterCheckPeriod := false;
        ParameterNoOfCustomers := 0;
        if JObject.ReadFrom(ParameterString) then begin
            if JObject.Get(CheckPeriodLbl, JToken) then begin
                JValue := JToken.AsValue();
                if (not JValue.IsNull()) and (not JValue.IsUndefined()) then
                    ParameterCheckPeriod := JValue.AsBoolean();
            end;
            if JObject.Get(NoOfCustomersLbl, JToken) then begin
                JValue := JToken.AsValue();
                if (not JValue.IsNull()) and (not JValue.IsUndefined()) then
                    ParameterNoOfCustomers := JValue.AsInteger();
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
    local procedure RefreshJobQueueEntry()
    var
        CustomerGDPRSetUp: Record "NPR Customer GDPR SetUp";
    begin
        if not CustomerGDPRSetUp.Get() then
            exit;
        EnqueueJobEntries(CustomerGDPRSetUp);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDoAnonymization(CustNo: Code[20])
    begin
    end;
}
