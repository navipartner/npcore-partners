codeunit 85297 "NPR Library - Customer GDPR"
{
    // Customer Creation

    internal procedure CreateCustomer(): Code[20]
    var
        Customer: Record Customer;
    begin
        Customer.Init();
        Customer."No." := GenerateCode20();
        Customer.Name := 'Test Customer';
        Customer.Address := '123 Main Street';
        Customer.City := 'TestCity';
        Customer."Phone No." := '555-0000';
        Customer."E-Mail" := 'test@example.com';
        Customer."Home Page" := 'www.example.com';
        Customer."VAT Registration No." := 'TEST1234';
        Customer.Insert(false);
        exit(Customer."No.");
    end;

    internal procedure CreateAnonymizedCustomer(): Code[20]
    var
        Customer: Record Customer;
        CustNo: Code[20];
    begin
        CustNo := CreateCustomer();
        Customer.Get(CustNo);
        Customer."NPR Anonymized" := true;
        Customer.Modify(false);
        exit(CustNo);
    end;

    internal procedure CreateCustomerWithFutureCleanupDate(): Code[20]
    var
        Customer: Record Customer;
        CustNo: Code[20];
    begin
        CustNo := CreateCustomer();
        Customer.Get(CustNo);
        Customer."NPR Estimated Cleanup Date" := CalcDate('<+30D>');
        Customer.Modify(false);
        exit(CustNo);
    end;

    internal procedure CreateCustomerWithPastCleanupDate(): Code[20]
    var
        Customer: Record Customer;
        CustNo: Code[20];
    begin
        CustNo := CreateCustomer();
        Customer.Get(CustNo);
        Customer."NPR Estimated Cleanup Date" := CalcDate('<-1D>');
        Customer.Modify(false);
        exit(CustNo);
    end;

    internal procedure SetBillToCustomer(CustNo: Code[20]; BillToCustNo: Code[20])
    var
        Customer: Record Customer;
    begin
        Customer.Get(CustNo);
        Customer."Bill-to Customer No." := BillToCustNo;
        Customer.Modify(false);
    end;

    // User Setup

    internal procedure SetupUserPermission()
    var
        UserSetup: Record "User Setup";
    begin
        if not UserSetup.Get(UserId()) then begin
            UserSetup.Init();
            UserSetup."User ID" := UserId();
            UserSetup.Insert(false);
        end;
        UserSetup."NPR Anonymize Customers" := true;
        UserSetup.Modify(false);
    end;

    internal procedure SetupForcePermission()
    var
        UserSetup: Record "User Setup";
    begin
        if not UserSetup.Get(UserId()) then begin
            UserSetup.Init();
            UserSetup."User ID" := UserId();
            UserSetup.Insert(false);
        end;
        UserSetup."NPR Force Anonymize Customers" := true;
        UserSetup.Modify(false);
    end;

    internal procedure SetupForcePermissionDisabled()
    var
        UserSetup: Record "User Setup";
    begin
        if not UserSetup.Get(UserId()) then begin
            UserSetup.Init();
            UserSetup."User ID" := UserId();
            UserSetup.Insert(false);
        end;
        UserSetup."NPR Force Anonymize Customers" := false;
        UserSetup.Modify(false);
    end;

    internal procedure SetupUserPermissionDisabled()
    var
        UserSetup: Record "User Setup";
    begin
        if not UserSetup.Get(UserId()) then begin
            UserSetup.Init();
            UserSetup."User ID" := UserId();
            UserSetup.Insert(false);
        end;
        UserSetup."NPR Anonymize Customers" := false;
        UserSetup.Modify(false);
    end;

    internal procedure RemoveUserPermission()
    var
        UserSetup: Record "User Setup";
    begin
        if UserSetup.Get(UserId()) then
            UserSetup.Delete(false);
    end;

    // Blocking Conditions

    internal procedure CreateSalesOrder(CustNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := GenerateCode20();
        SalesHeader."Sell-to Customer No." := CustNo;
        SalesHeader.Insert(false);
    end;

    internal procedure CreateOpenCustLedgerEntry(CustNo: Code[20])
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        _EntryNo: Integer;
    begin
        if CustLedgerEntry.FindLast() then
            _EntryNo := CustLedgerEntry."Entry No." + 1
        else
            _EntryNo := 1;

        CustLedgerEntry.Init();
        CustLedgerEntry."Entry No." := _EntryNo;
        CustLedgerEntry."Customer No." := CustNo;
        CustLedgerEntry.Open := true;
        CustLedgerEntry.Insert(false);
    end;

    internal procedure CreateGenJnlLine(CustNo: Code[20])
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlLine.Init();
        GenJnlLine."Journal Template Name" := 'GDPRTEST';
        GenJnlLine."Journal Batch Name" := 'DEFAULT';
        GenJnlLine."Line No." := 10000;
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
        GenJnlLine."Account No." := CustNo;
        GenJnlLine.Insert(false);
    end;

    internal procedure CreateMembershipForCustomer(CustNo: Code[20])
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
    begin
        if not MembershipSetup.Get('GDPRTEST') then begin
            MembershipSetup.Code := 'GDPRTEST';
            MembershipSetup.Insert();
        end;

        Membership.Init();
        Membership."Membership Code" := 'GDPRTEST';
        Membership."Customer No." := CustNo;
        Membership.Insert();
    end;

    // Feature flag toggle (bypasses the irreversibility OnBeforeValidate to keep tests unattended)

    internal procedure EnableCustomerGDPRV2Feature()
    var
        Feature: Record "NPR Feature";
        CustomerGDPRV2: Codeunit "NPR Customer GDPR V2";
    begin
        if not Feature.Get(CustomerGDPRV2.GetFeatureId()) then begin
            Feature.Init();
            Feature.Id := CustomerGDPRV2.GetFeatureId();
            Feature.Validate(Feature, Enum::"NPR Feature"::"Customer GDPR V2");
            Feature.Insert();
        end;
        // Bypass OnBeforeValidate (which would prompt the user with a Confirm) by writing the field directly.
        Feature.Enabled := true;
        Feature.Modify(false);
    end;

    internal procedure DisableCustomerGDPRv2Feature()
    var
        Feature: Record "NPR Feature";
        CustomerGDPRV2: Codeunit "NPR Customer GDPR V2";
    begin
        if not Feature.Get(CustomerGDPRV2.GetFeatureId()) then
            exit;
        Feature.Enabled := false;
        Feature.Modify(false);
    end;

    internal procedure EnsureGDPRSetup(AnonymizeAfter: Text)
    var
        Setup: Record "NPR Customer GDPR SetUp";
        Formula: DateFormula;
    begin
        Evaluate(Formula, AnonymizeAfter);
        if not Setup.Get() then begin
            Setup.Init();
            Setup."Primary key" := '';
            Setup."Anonymize After" := Formula;
            Setup.Insert();
        end else begin
            Setup."Anonymize After" := Formula;
            Setup.Modify();
        end;
    end;

    // Anonymization Request

    internal procedure CreateAnonymizationRequest(CustNo: Code[20]; IsCompany: Boolean): Integer
    var
        Request: Record "NPR GDPR Anonymization Request";
    begin
        Request.Init();
        Request."Customer No." := CustNo;
        if IsCompany then
            Request.Type := Request.Type::COMPANY
        else
            Request.Type := Request.Type::PERSON;
        Request.Status := Request.Status::NEW;
        Request."Request Received" := CurrentDateTime;
        Request.Insert(true);
        exit(Request."Entry No.");
    end;

    // Assertions

    internal procedure Assert_CustomerIsAnonymized(CustNo: Code[20])
    var
        Customer: Record Customer;
        Assert: Codeunit Assert;
    begin
        Assert.IsTrue(Customer.Get(CustNo), 'Customer not found.');
        Assert.AreEqual('------', Customer.Name, 'Customer Name should be anonymized.');
        Assert.IsTrue(Customer."NPR Anonymized", 'Customer should be marked as anonymized.');
        Assert.AreEqual(Customer.Blocked::All, Customer.Blocked, 'Customer should be blocked.');
        Assert.AreEqual('------@----', Customer."E-Mail", 'Customer E-Mail should be anonymized.');
        Assert.AreEqual('', Customer."Phone No.", 'Customer Phone No. should be cleared.');
        Assert.AreEqual('', Customer."Post Code", 'Customer Post Code should be cleared.');
    end;

    internal procedure Assert_CustomerIsNotAnonymized(CustNo: Code[20])
    var
        Customer: Record Customer;
        Assert: Codeunit Assert;
    begin
        Assert.IsTrue(Customer.Get(CustNo), 'Customer not found.');
        Assert.AreNotEqual('------', Customer.Name, 'Customer Name should not be anonymized.');
        Assert.IsFalse(Customer."NPR Anonymized", 'Customer should not be marked as anonymized.');
    end;

    internal procedure Assert_LogEntryExists(CustNo: Code[20]; ExpectedSuccess: Boolean)
    var
        GDPRLogEntry: Record "NPR Customer GDPR Log Entries";
        Assert: Codeunit Assert;
    begin
        GDPRLogEntry.SetRange("Customer No", CustNo);
        Assert.IsTrue(GDPRLogEntry.FindLast(), 'GDPR Log Entry not found for customer ' + CustNo);
        if ExpectedSuccess then
            Assert.AreEqual(GDPRLogEntry.Status::Anonymised, GDPRLogEntry.Status, 'Log entry status should be Anonymised.')
        else
            Assert.AreEqual(GDPRLogEntry.Status::"Could Not be anonymised", GDPRLogEntry.Status, 'Log entry status should be Could Not be anonymised.');
    end;

    internal procedure Assert_LogEntryCount(CustNo: Code[20]; ExpectedCount: Integer)
    var
        GDPRLogEntry: Record "NPR Customer GDPR Log Entries";
        Assert: Codeunit Assert;
    begin
        GDPRLogEntry.SetRange("Customer No", CustNo);
        Assert.AreEqual(ExpectedCount, GDPRLogEntry.Count(), 'Unexpected number of log entries for customer ' + CustNo);
    end;

    local procedure GenerateCode20(): Code[20]
    begin
        exit(CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, 20));
    end;

    // Contact / Contact Business Relation

    internal procedure CreateCompanyContact(): Code[20]
    var
        Contact: Record Contact;
        ContactNo: Code[20];
    begin
        ContactNo := GenerateCode20();
        Contact.Init();
        Contact."No." := ContactNo;
        Contact.Type := Contact.Type::Company;
        Contact.Name := 'Test Co ' + ContactNo;
        Contact."Company No." := ContactNo;
        Contact."Company Name" := Contact.Name;
        Contact."E-Mail" := 'co@example.com';
        Contact."Phone No." := '555-1111';
        Contact.Insert(false);
        exit(ContactNo);
    end;

    internal procedure LinkCustomerToContact(CustNo: Code[20]; ContactNo: Code[20])
    var
        ContBusRel: Record "Contact Business Relation";
    begin
        // Business Relation Code is part of the PK; use the customer's own no. so a contact can be linked to multiple test customers without a PK collision.
        ContBusRel.Init();
        ContBusRel."Contact No." := ContactNo;
        ContBusRel."Business Relation Code" := CopyStr(CustNo, 1, MaxStrLen(ContBusRel."Business Relation Code"));
        ContBusRel."Link to Table" := ContBusRel."Link to Table"::Customer;
        ContBusRel."No." := CustNo;
        ContBusRel.Insert(false);
    end;

    internal procedure LinkVendorToContact(VendorNo: Code[20]; ContactNo: Code[20])
    var
        ContBusRel: Record "Contact Business Relation";
    begin
        ContBusRel.Init();
        ContBusRel."Contact No." := ContactNo;
        ContBusRel."Business Relation Code" := CopyStr(VendorNo, 1, MaxStrLen(ContBusRel."Business Relation Code"));
        ContBusRel."Link to Table" := ContBusRel."Link to Table"::Vendor;
        ContBusRel."No." := VendorNo;
        ContBusRel.Insert(false);
    end;

    internal procedure Assert_ContactWiped(ContactNo: Code[20])
    var
        Contact: Record Contact;
        Assert: Codeunit Assert;
    begin
        Assert.IsTrue(Contact.Get(ContactNo), 'Contact not found: ' + ContactNo);
        Assert.AreEqual('------', Contact.Name, 'Contact Name should be wiped.');
    end;

    internal procedure Assert_ContactNotWiped(ContactNo: Code[20])
    var
        Contact: Record Contact;
        Assert: Codeunit Assert;
    begin
        Assert.IsTrue(Contact.Get(ContactNo), 'Contact not found: ' + ContactNo);
        Assert.AreNotEqual('------', Contact.Name, 'Contact Name should not have been wiped.');
    end;

    internal procedure SeedPOSEntryForCustomer(CustomerNo: Code[20]; EntryDate: Date) EntryNo: Integer
    var
        POSEntry: Record "NPR POS Entry";
    begin
        POSEntry.Init();
        POSEntry."Entry No." := GetNextPOSEntryNo();
        POSEntry."Customer No." := CustomerNo;
        POSEntry."Entry Date" := EntryDate;
        POSEntry.Insert();
        exit(POSEntry."Entry No.");
    end;

    internal procedure SeedCustLedgerEntryForCustomer(CustomerNo: Code[20]; PostingDate: Date) EntryNo: Integer
    var
        CLE: Record "Cust. Ledger Entry";
    begin
        CLE.Init();
        CLE."Entry No." := GetNextCLENo();
        CLE."Customer No." := CustomerNo;
        CLE."Posting Date" := PostingDate;
        CLE.Insert();
        exit(CLE."Entry No.");
    end;

    internal procedure SeedItemLedgerEntryForCustomer(CustomerNo: Code[20]; PostingDate: Date) EntryNo: Integer
    var
        ILE: Record "Item Ledger Entry";
    begin
        ILE.Init();
        ILE."Entry No." := GetNextILENo();
        ILE."Source Type" := ILE."Source Type"::Customer;
        ILE."Source No." := CustomerNo;
        ILE."Posting Date" := PostingDate;
        ILE.Insert();
        exit(ILE."Entry No.");
    end;

    local procedure GetNextPOSEntryNo(): Integer
    var
        POSEntry: Record "NPR POS Entry";
    begin
        if POSEntry.FindLast() then
            exit(POSEntry."Entry No." + 1);
        exit(1);
    end;

    local procedure GetNextCLENo(): Integer
    var
        CLE: Record "Cust. Ledger Entry";
    begin
        if CLE.FindLast() then
            exit(CLE."Entry No." + 1);
        exit(1);
    end;

    local procedure GetNextILENo(): Integer
    var
        ILE: Record "Item Ledger Entry";
    begin
        if ILE.FindLast() then
            exit(ILE."Entry No." + 1);
        exit(1);
    end;
}
