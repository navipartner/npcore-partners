codeunit 6151060 "NPR NP GDPR Management"
{
    Permissions = TableData "Sales Shipment Header" = rm,
                  TableData "Sales Invoice Header" = rm,
                  TableData "Sales Cr.Memo Header" = rm,
                  TableData "Return Receipt Header" = rm,
                  TableData "Job Queue Entry" = rm,
                  TableData "Issued Reminder Header" = rm;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        Customer: Record Customer;
        CustToAnonymise: Record "NPR Customers to Anonymize";
        GDPRSetup: Record "NPR Customer GDPR SetUp";
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
        ReasonText: Text;
        VarNoOfCustomers: Integer;
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
                    Customer.SetFilter(Customer."NPR To Anonymize On", '>%1&<=%2', 0D, Today());
                    if Customer.FindSet() then
                        repeat
                            DoAnonymization(Customer."No.", ReasonText);
                        until Customer.Next() = 0;
                end;

            true:
                begin
                    PopulateCustToAnonymise();
                    CustToAnonymise.Reset();
                    if CustToAnonymise.FindSet() then
                        repeat
                            DoAnonymization(CustToAnonymise."Customer No", ReasonText);
                            CustToAnonymise.Delete();
                        until (CustToAnonymise.Next() = 0) or (VarCount = VarNoOfCustomers);
                end;
        end;

    end;

    var
        CustomerHaveOpenEntriesMsg: Label 'You cannot anonymize Customer %1 because it has open entries/documents.', Comment = '%1=Customer No.';
        CustomerHasBeenAnonymizedMsg: Label 'Customer %1  has been anonymized.', Comment = '%1=Customer No.';
        UseMemberAnonymizationMsg: Label 'Customer %1 is a member. Please use Member Anonymization.', Comment = '%1=Customer No.';
        UserNotAllowedToAnonymizeErr: Label 'You do not have permission to anonymize customers. Contact your administrator to give you access.';
        CheckPeriodLbl: Label 'CHECK_PERIOD', Locked = true;
        NoOfCustomersLbl: Label 'NO_OF_CUSTOMERS', Locked = true;
        DefJobCategoryCodeLbl: Label 'NPR-GDPR', Locked = true;
        DefJobCategoryDescLbl: Label 'GDPR Anonymization';

        VarCheckPeriod: Boolean;
        EntryNo: Integer;
        VarCount: Integer;

    procedure DoAnonymization(CustNo: Code[20]; var VarReason: Text): Boolean
    var
        GDPRSetup: Record "NPR Customer GDPR SetUp";
        OpenDocFound: Boolean;
        TransactionFound: Boolean;
        VarPeriod: DateFormula;
        OpenTransactionFound: Boolean;
        GDPRLogEntry: Record "NPR Customer GDPR Log Entries";
        MemberFound: Boolean;
        UserSetup: Record "User Setup";
        JournalFound: Boolean;
        AnonymizationResponseValue: Integer;
    begin
        if UserSetup.Get(UserId()) then
            if not UserSetup."NPR Anonymize Customers" then
                Error(UserNotAllowedToAnonymizeErr);

        if GDPRLogEntry.FindLast() then
            EntryNo := GDPRLogEntry."Entry No"
        else
            EntryNo := 0;

        if GDPRSetup.Get() then;

        OpenDocFound := false;
        TransactionFound := false;
        OpenTransactionFound := false;
        MemberFound := false;
        JournalFound := false;

        if (VarCheckPeriod) then
            Evaluate(VarPeriod, '-' + Format(GDPRSetup."Anonymize After"));
        IsCustomerValidForAnonymization(CustNo, VarCheckPeriod, VarPeriod, AnonymizationResponseValue);

        OpenDocFound := EvaluateResponseValue(AnonymizationResponseValue, 0);
        TransactionFound := EvaluateResponseValue(AnonymizationResponseValue, 1);
        OpenTransactionFound := EvaluateResponseValue(AnonymizationResponseValue, 2);
        MemberFound := EvaluateResponseValue(AnonymizationResponseValue, 3);
        JournalFound := EvaluateResponseValue(AnonymizationResponseValue, 4);

        if (OpenDocFound = false) and (TransactionFound = false) and (OpenTransactionFound = false) and (MemberFound = false) and (JournalFound = false) then begin
            AnonymizeCustomer(CustNo);
            OnAfterDoAnonymization(CustNo);
            VarCount += 1;
            InsertLogEntry(CustNo, true, OpenDocFound, OpenTransactionFound, TransactionFound, MemberFound, JournalFound);

            VarReason := StrSubstNo(CustomerHasBeenAnonymizedMsg, CustNo);
            exit(true);
        end;

        InsertLogEntry(CustNo, false, OpenDocFound, OpenTransactionFound, TransactionFound, MemberFound, JournalFound);

        if (VarReason = '') and (MemberFound) then
            VarReason := StrSubstNo(UseMemberAnonymizationMsg, CustNo);

        if (VarReason = '') and (not MemberFound) then
            VarReason := StrSubstNo(CustomerHaveOpenEntriesMsg, CustNo);
        exit(false);
    end;

    procedure IsCustomerValidForAnonymization(CustomerNo: Code[20]; LimitedTimePeriod: Boolean; LimitingDateFormula: DateFormula; var ReasonCode: Integer): Boolean
    var
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

        SalesHdr.SetCurrentKey("Sell-to Customer No.", "External Document No.");
        SalesHdr.SetRange("Sell-to Customer No.", CustomerNo);
        if not SalesHdr.IsEmpty() then
            ReasonCode += Power(2, 0);

        if LimitedTimePeriod then begin
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

        Customer.Get(CustNo);

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
        Customer.Modify(true);
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

        if Contact.Get(ContBusRel."Contact No.") then begin
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
            AnonymizeCompanyNo(Contact."Company No.");
        end;
    end;

    local procedure AnonymizeCompanyNo(VarContactNo: Code[20])
    var
        Contact: Record Contact;
    begin
        if VarContactNo = '' then
            exit;

        if Contact.Get(Contact."Company No.") then begin
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
            SalesInvHdr."VAT Registration No." := '';
            SalesInvHdr."Bill-to Customer No." := '';
            SalesInvHdr."Bill-to Name" := '------';
            SalesInvHdr."Bill-to Name 2" := '------';
            SalesInvHdr."Bill-to Address" := '------ --';
            SalesInvHdr."Bill-to Address 2" := '------ --';
            SalesInvHdr."Bill-to City" := '';
            SalesInvHdr."Bill-to Contact" := '------';
            SalesInvHdr."Ship-to Code" := '';
            SalesInvHdr."Bill-to Post Code" := '';
            SalesInvHdr."Bill-to County" := '';
            SalesInvHdr."Bill-to Country/Region Code" := '';
            SalesInvHdr."Sell-to Post Code" := '';
            SalesInvHdr."Sell-to County" := '';
            SalesInvHdr."Sell-to Country/Region Code" := '';

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
            SalesCrMemoHdr."VAT Registration No." := '';
            SalesCrMemoHdr."Bill-to Customer No." := '';
            SalesCrMemoHdr."Bill-to Name" := '------';
            SalesCrMemoHdr."Bill-to Name 2" := '------';
            SalesCrMemoHdr."Bill-to Address" := '------ --';
            SalesCrMemoHdr."Bill-to Address 2" := '------ --';
            SalesCrMemoHdr."Bill-to City" := '';
            SalesCrMemoHdr."Bill-to Contact" := '------';
            SalesCrMemoHdr."Ship-to Code" := '';
            SalesCrMemoHdr."Bill-to Post Code" := '';
            SalesCrMemoHdr."Bill-to County" := '';
            SalesCrMemoHdr."Bill-to Country/Region Code" := '';
            SalesCrMemoHdr."Sell-to Post Code" := '';
            SalesCrMemoHdr."Sell-to County" := '';
            SalesCrMemoHdr."Sell-to Country/Region Code" := '';
            SalesCrMemoHdr.Modify(true);
        until SalesCrMemoHdr.Next() = 0;
    end;

    local procedure InsertLogEntry(CustNo: Code[20]; Success: Boolean; OpenSales: Boolean; OpenCLE: Boolean; TransactionInPeriod: Boolean; Member: Boolean; Journals: Boolean)
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
        GDPRLogEntry."Anonymized By" := UserId;
        GDPRLogEntry.Insert();
    end;

    local procedure AnonymizeSalesArchives(VarCustNo: Code[20])
    var
        SalesHdrArchive: Record "Sales Header Archive";
    begin
        SalesHdrArchive.SetRange("Sell-to Customer No.", VarCustNo);
        if SalesHdrArchive.IsEmpty() then
            exit;
        SalesHdrArchive.FindSet();
        repeat
            SalesHdrArchive."Sell-to Customer Name" := '------';
            SalesHdrArchive."Sell-to Customer Name 2" := '------';
            SalesHdrArchive."Sell-to Address" := '------ --';
            SalesHdrArchive."Sell-to Address 2" := '------ --';
            SalesHdrArchive."Sell-to City" := '';
            SalesHdrArchive."Sell-to Contact" := '------';
            SalesHdrArchive."Sell-to Post Code" := '';
            SalesHdrArchive."Sell-to County" := '';
            SalesHdrArchive."Sell-to Country/Region Code" := '';
            SalesHdrArchive."Ship-to Post Code" := '';
            SalesHdrArchive."Ship-to County" := '';
            SalesHdrArchive."Ship-to Country/Region Code" := '';
            SalesHdrArchive."Ship-to Name" := '------';
            SalesHdrArchive."Ship-to Name 2" := '------';
            SalesHdrArchive."Ship-to Address" := '------ --';
            SalesHdrArchive."Ship-to Address 2" := '------ --';
            SalesHdrArchive."Ship-to City" := '';
            SalesHdrArchive."Ship-to Contact" := '------';
            SalesHdrArchive."VAT Registration No." := '';
            SalesHdrArchive."Bill-to Customer No." := '';
            SalesHdrArchive."Bill-to Name" := '------';
            SalesHdrArchive."Bill-to Name 2" := '------';
            SalesHdrArchive."Bill-to Address" := '------ --';
            SalesHdrArchive."Bill-to Address 2" := '------ --';
            SalesHdrArchive."Bill-to City" := '';
            SalesHdrArchive."Bill-to Contact" := '------';
            SalesHdrArchive."Ship-to Code" := '';
            SalesHdrArchive."Bill-to Post Code" := '';
            SalesHdrArchive."Bill-to County" := '';
            SalesHdrArchive."Bill-to Country/Region Code" := '';
            SalesHdrArchive."Sell-to Post Code" := '';
            SalesHdrArchive."Sell-to County" := '';
            SalesHdrArchive."Sell-to Country/Region Code" := '';
            SalesHdrArchive.Modify(true);
        until SalesHdrArchive.Next() = 0;
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
            SalesShipmentHdr."VAT Registration No." := '';
            SalesShipmentHdr."Bill-to Customer No." := '';
            SalesShipmentHdr."Bill-to Name" := '------';
            SalesShipmentHdr."Bill-to Name 2" := '------';
            SalesShipmentHdr."Bill-to Address" := '------ --';
            SalesShipmentHdr."Bill-to Address 2" := '------ --';
            SalesShipmentHdr."Bill-to City" := '';
            SalesShipmentHdr."Bill-to Contact" := '------';
            SalesShipmentHdr."Ship-to Code" := '';
            SalesShipmentHdr."Bill-to Post Code" := '';
            SalesShipmentHdr."Bill-to County" := '';
            SalesShipmentHdr."Bill-to Country/Region Code" := '';
            SalesShipmentHdr."Sell-to Post Code" := '';
            SalesShipmentHdr."Sell-to County" := '';
            SalesShipmentHdr."Sell-to Country/Region Code" := '';
            SalesShipmentHdr."NPR Bill-to E-mail" := '------@----';
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
            ReturnRcptHdr."VAT Registration No." := '';
            ReturnRcptHdr."Bill-to Customer No." := '';
            ReturnRcptHdr."Bill-to Name" := '------';
            ReturnRcptHdr."Bill-to Name 2" := '------';
            ReturnRcptHdr."Bill-to Address" := '------ --';
            ReturnRcptHdr."Bill-to Address 2" := '------ --';
            ReturnRcptHdr."Bill-to City" := '';
            ReturnRcptHdr."Bill-to Contact" := '------';
            ReturnRcptHdr."Ship-to Code" := '';
            ReturnRcptHdr."Bill-to Post Code" := '';
            ReturnRcptHdr."Bill-to County" := '';
            ReturnRcptHdr."Bill-to Country/Region Code" := '';
            ReturnRcptHdr."Sell-to Post Code" := '';
            ReturnRcptHdr."Sell-to County" := '';
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
            Job."NPR Person Responsible Name" := '------';
            Job."Person Responsible" := '------';
            Job.Modify(true);
        until Job.Next() = 0;
    end;

    local procedure PopulateCustToAnonymise()
    var
        GDPRSetup: Record "NPR Customer GDPR SetUp";
        DateFormulaTxt: Text[250];
        VarPeriod: DateFormula;
        VarEntryNo: Integer;
        Customer: Record Customer;
        CLE: Record "Cust. Ledger Entry";
        CustToAnonymize: Record "NPR Customers to Anonymize";
        ILE: Record "Item Ledger Entry";
        NoCLE: Boolean;
        NoILE: Boolean;
        NoTrans: Boolean;
    begin
        CustToAnonymize.Reset();
        CustToAnonymize.DeleteAll();
        if GDPRSetup.Get() then;

        DateFormulaTxt := '-' + Format(GDPRSetup."Anonymize After");
        Evaluate(VarPeriod, DateFormulaTxt);


        VarEntryNo := 0;
        Customer.SetRange(Customer."NPR Anonymized", false);
        Customer.SetFilter(Customer."Customer Posting Group", GDPRSetup."Customer Posting Group Filter");
        Customer.SetFilter(Customer."Gen. Bus. Posting Group", GDPRSetup."Gen. Bus. Posting Group Filter");
        Customer.SetFilter("Last Date Modified", '<>%1', 0D);
        if Customer.FindSet() then
            repeat
                NoTrans := true;

                CLE.Reset();
                CLE.SetCurrentKey("Customer No.", "Posting Date", "Currency Code");
                CLE.SetRange("Customer No.", Customer."No.");
                NoTrans := not CLE.IsEmpty();

                if NoTrans then begin
                    ILE.Reset();
                    ILE.SetCurrentKey("Source Type", "Source No.", "Item No.", "Variant Code", "Posting Date");
                    ILE.SetRange(ILE."Source Type", ILE."Source Type"::Customer);
                    ILE.SetRange(ILE."Source No.", Customer."No.");
                    NoTrans := not ILE.IsEmpty();
                end;

                if NoTrans then begin
                    if (Today - Customer."Last Date Modified") >= (Today - CalcDate(VarPeriod, Today)) then begin
                        CustToAnonymize.Init();
                        CustToAnonymize."Entry No" := VarEntryNo;
                        CustToAnonymize."Customer No" := Customer."No.";
                        CustToAnonymize."Customer Name" := Customer.Name;
                        CustToAnonymize.Insert();
                        VarEntryNo += 1;
                    end;
                end else begin
                    NoCLE := false;
                    NoILE := false;
                    CLE.Reset();
                    CLE.SetCurrentKey("Customer No.", "Posting Date", "Currency Code");
                    CLE.SetRange("Customer No.", Customer."No.");
                    CLE.SetFilter("Posting Date", '>%1', CalcDate(VarPeriod, Today));
                    NoCLE := CLE.IsEmpty();

                    ILE.Reset();
                    ILE.SetCurrentKey("Source Type", "Source No.", "Item No.", "Variant Code", "Posting Date");
                    ILE.SetRange(ILE."Source Type", ILE."Source Type"::Customer);
                    ILE.SetRange(ILE."Source No.", Customer."No.");
                    ILE.SetFilter("Posting Date", '>%1', CalcDate(VarPeriod, Today()));
                    NoILE := ILE.IsEmpty();

                    if NoILE and NoCLE then begin
                        CustToAnonymize.Init();
                        CustToAnonymize."Entry No" := VarEntryNo;
                        CustToAnonymize."Customer No" := Customer."No.";
                        CustToAnonymize."Customer Name" := Customer.Name;
                        CustToAnonymize.Insert();
                        VarEntryNo += 1;
                    end;
                end;
            until Customer.Next() = 0;
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
        CustomerCount: Integer;
    begin
        if CustomerGDPRSetup."Enable Job Queue" then begin
            CustomerCount := 2500;
            EnableJobQueueEntry(CustomerGDPRSetup, true, CustomerCount);
            EnableJobQueueEntry(CustomerGDPRSetup, false);
        end else begin
            DisableJobQueueEntries(CustomerGDPRSetup);
        end;
    end;

    local procedure DisableJobQueueEntries(CustomerGDPRSetup: Record "NPR Customer GDPR SetUp")
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        FilterJobQueueEntries(JobQueueEntry, CustomerGDPRSetup);
        if JobQueueEntry.FindSet() then
            repeat
                JobQueueEntry.Cancel();
            until JobQueueEntry.Next() = 0;
    end;

    local procedure FilterJobQueueEntries(var JobQueueEntry: Record "Job Queue Entry"; CustomerGDPRSetup: Record "NPR Customer GDPR SetUp")
    begin
        JobQueueEntry.Reset();
        JobQueueEntry.SetRange("Record ID to Process", CustomerGDPRSetup.RecordId());
    end;

    local procedure EnableJobQueueEntry(CustomerGDPRSetup: Record "NPR Customer GDPR SetUp"; ParameterCheckPeriod: Boolean; ParameterNoOfCustomers: Integer)
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueCategory: Record "Job Queue Category";
        JObject: JsonObject;
        JobQueueParameterString: Text;
    begin
        JObject.Add(CheckPeriodLbl, ParameterCheckPeriod);
        JObject.Add(NoOfCustomersLbl, ParameterNoOfCustomers);
        JObject.WriteTo(JobQueueParameterString);
        JobQueueCategory.InsertRec(DefJobCategoryCodeLbl, DefJobCategoryDescLbl);
        JobQueueEntry.ScheduleJobQueueEntryForLater(Codeunit::"NPR NP GDPR Management", CurrentDateTime() + 360 * 1000, JobQueueCategory.Code, JobQueueParameterString);
        UpdateJobQueueEntryAsRecurring(JobQueueEntry, CustomerGDPRSetup);
    end;

    local procedure EnableJobQueueEntry(CustomerGDPRSetup: Record "NPR Customer GDPR SetUp"; ParameterCheckPeriod: Boolean)
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueCategory: Record "Job Queue Category";
        JObject: JsonObject;
        JobQueueParameterString: Text;
    begin
        JObject.Add(CheckPeriodLbl, ParameterCheckPeriod);
        JObject.WriteTo(JobQueueParameterString);
        JobQueueCategory.InsertRec(DefJobCategoryCodeLbl, DefJobCategoryDescLbl);
        JobQueueEntry.ScheduleJobQueueEntryForLater(Codeunit::"NPR NP GDPR Management", CurrentDateTime() + 360 * 1000, JobQueueCategory.Code, JobQueueParameterString);
        UpdateJobQueueEntryAsRecurring(JobQueueEntry, CustomerGDPRSetup);
    end;

    local procedure UpdateJobQueueEntryAsRecurring(var JobQueueEntry: Record "Job Queue Entry"; CustomerGDPRSetup: Record "NPR Customer GDPR SetUp")
    begin
        JobQueueEntry."Record ID to Process" := CustomerGDPRSetup.RecordId();
        JobQueueEntry.validate("Run on Mondays", true);
        JobQueueEntry.validate("Run on Tuesdays", true);
        JobQueueEntry.validate("Run on Wednesdays", true);
        JobQueueEntry.validate("Run on Thursdays", true);
        JobQueueEntry.validate("Run on Fridays", true);
        JobQueueEntry.validate("Run on Saturdays", true);
        JobQueueEntry.validate("Run on Sundays", true);
        JobQueueEntry."No. of Minutes between Runs" := 1440;
        JobQueueEntry.Modify(true);
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

    [IntegrationEvent(false, false)]
    local procedure OnAfterDoAnonymization(CustNo: Code[20])
    begin
    end;
}

