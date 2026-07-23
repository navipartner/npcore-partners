codeunit 85258 "NPR ES Posting Check Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Item: Record Item;
        ESClient: Record "NPR ES Client";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        Salesperson: Record "Salesperson/Purchaser";
        Assert: Codeunit Assert;
        POSSession: Codeunit "NPR POS Session";
        Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler')]
    procedure PostingAnonymousSaleWithoutVATCustomerErrorsUnderES()
    var
        POSEntry: Record "NPR POS Entry";
        POSPostEntries: Codeunit "NPR POS Post Entries";
        POSEntryNo: Integer;
        Success: Boolean;
        ShouldNotPostErr: Label 'Posting an anonymous sale under ES with a blank VAT Customer No. should be blocked.', Locked = true;
        WrongErrorErr: Label 'Posting failed for a reason other than the missing VAT Customer No. Actual error: %1', Locked = true;
    begin
        // [SCENARIO] Posting an anonymous cash sale to G/L while ES fiscalization is enabled and the posting profile has no VAT Customer No. must be blocked with a clear message.
        // [GIVEN] ES fiscalization enabled and a posting profile with a blank VAT Customer No.
        InitializeData();
        POSPostingProfile.Get(POSPostingProfile.Code);
        POSPostingProfile."VAT Customer No." := '';
        POSPostingProfile.Modify();

        // [GIVEN] A finished anonymous cash sale (no customer) producing an unposted POS Entry
        POSEntryNo := DoItemSale();

        // [WHEN] Posting the POS Entry to G/L
        POSEntry.Get(POSEntryNo);
        POSEntry.SetRange("Entry No.", POSEntryNo);
        POSPostEntries.SetPostPOSEntries(true);
        POSPostEntries.SetStopOnError(true);
        Commit();
        ClearLastError();
        Success := POSPostEntries.Run(POSEntry);

        // [THEN] Posting is blocked, and the error points to the VAT Customer No. field
        Assert.IsFalse(Success, ShouldNotPostErr);
        Assert.IsTrue(
            StrPos(GetLastErrorText(), POSPostingProfile.FieldCaption("VAT Customer No.")) > 0,
            StrSubstNo(WrongErrorErr, GetLastErrorText()));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PostingAllowedWhenVATCustomerConfiguredUnderES()
    var
        Customer: Record Customer;
        POSEntry: Record "NPR POS Entry";
        ESAuditMgt: Codeunit "NPR ES Audit Mgt.";
        LibrarySales: Codeunit "Library - Sales";
        WrongErrorErr: Label 'The check either passed via an early exit or failed for a reason other than the missing VAT Customer No. Actual error: %1', Locked = true;
    begin
        // [SCENARIO] With ES fiscalization enabled, the posting check reaches the VAT Customer No. gate: it blocks an anonymous sale when the profile's VAT Customer No. is blank, and allows it once configured.
        InitializeData();
        LibrarySales.CreateCustomer(Customer);

        // [GIVEN] An anonymous direct-sale POS entry for the store (valid entry type, blank customer, resolvable store/profile) so the check runs past every early exit down to the VAT Customer No. gate
        POSEntry.Init();
        POSEntry."Entry Type" := POSEntry."Entry Type"::"Direct Sale";
        POSEntry."POS Store Code" := POSStore.Code;
        POSEntry."Customer No." := '';

        // [GIVEN] A blank VAT Customer No. on the posting profile
        POSPostingProfile.Get(POSPostingProfile.Code);
        POSPostingProfile."VAT Customer No." := '';
        POSPostingProfile.Modify();

        // [WHEN] Checking the posting restriction
        // [THEN] It errors (not a silent exit), and the error points at the VAT Customer No. field - proving the gate was reached
        asserterror ESAuditMgt.CheckESVATCustomerRequirement(POSEntry);
        Assert.IsTrue(
            StrPos(GetLastErrorText(), POSPostingProfile.FieldCaption("VAT Customer No.")) > 0,
            StrSubstNo(WrongErrorErr, GetLastErrorText()));

        // [GIVEN] A generic VAT Customer No. configured on the posting profile
        POSPostingProfile."VAT Customer No." := Customer."No.";
        POSPostingProfile.Modify();

        // [WHEN/THEN] Checking the same entry no longer raises an error (test fails if it does)
        ESAuditMgt.CheckESVATCustomerRequirement(POSEntry);
    end;

    local procedure DoItemSale(): Integer
    var
        POSEntry: Record "NPR POS Entry";
        POSSale: Record "NPR POS Sale";
        POSMockLibrary: Codeunit "NPR Library - POS Mock";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        SaleNotEndedAsExpectedErr: Label 'Sale not ended as expected.', Locked = true;
    begin
        POSMockLibrary.InitializePOSSessionAndStartSale(POSSession, POSUnit, Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(POSSale);
        POSMockLibrary.CreateItemLine(POSSession, Item."No.", 1);
        ESFiscalLibrary.SetInvoiceRegistrationState(Enum::"NPR ES Inv. Registration State"::PENDING);
        BindSubscription(ESFiscalLibrary);
        // PostSaleImmediately = false: end the sale (creating the unposted POS Entry) without auto-posting to G/L,
        // so the caller controls when posting happens and can observe the ES posting guard.
        if not POSMockLibrary.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, Item."Unit Price", '', false) then
            Error(SaleNotEndedAsExpectedErr);
        UnbindSubscription(ESFiscalLibrary);

        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();
        POSSession.ClearAll();
        Clear(POSSession);
        exit(POSEntry."Entry No.");
    end;

    [ConfirmHandler]
    procedure GeneralConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    var
        CreateCompleteInvoiceQst: Label 'Do you want to create complete invoice?', Locked = true;
        QuestionNotExpectedErr: Label 'Question "%1" is not expected.', Locked = true;
    begin
        case true of
            Question = CreateCompleteInvoiceQst:
                Reply := false;
            else
                Error(QuestionNotExpectedErr, Question);
        end;
    end;

    local procedure InitializeData()
    var
        ESOrganization: Record "NPR ES Organization";
        ESSigner: Record "NPR ES Signer";
        VoucherTypeDefault: Record "NPR NpRv Voucher Type";
        POSAuditLog: Record "NPR POS Audit Log";
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSSetup: Record "NPR POS Setup";
        ReturnReason: Record "Return Reason";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryERM: Codeunit "Library - ERM";
        POSMasterDataLibrary: Codeunit "NPR Library - POS Master Data";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
    begin
        if Initialized then begin
            // Clean any previous mock session
            POSSession.ClearAll();
            Clear(POSSession);
        end else begin
            POSMasterDataLibrary.CreatePOSSetup(POSSetup);
            POSMasterDataLibrary.CreateDefaultVoucherType(VoucherTypeDefault, false);
            POSMasterDataLibrary.CreateDefaultPostingSetup(POSPostingProfile);
            POSPostingProfile."POS Period Register No. Series" := '';
            POSPostingProfile.Modify();
            POSMasterDataLibrary.CreatePOSStore(POSStore, POSPostingProfile.Code);
            POSMasterDataLibrary.CreatePOSUnit(POSUnit, POSStore.Code, POSPostingProfile.Code);
            POSMasterDataLibrary.CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);
            POSMasterDataLibrary.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
            CreateSalesperson();

            LibraryERM.CreateReturnReasonCode(ReturnReason);
            Item."Unit Price" := 10;
            Item.Modify();

            VATPostingSetup.SetRange("VAT Prod. Posting Group", Item."VAT Prod. Posting Group");
            VATPostingSetup.SetRange("VAT Bus. Posting Group", POSPostingProfile."VAT Bus. Posting Group");
            VATPostingSetup.SetFilter("VAT %", '<>%1', 0);
            VATPostingSetup.FindFirst();
            ESFiscalLibrary.CreateAuditProfileAndESSetups(POSAuditProfile, VATPostingSetup, POSUnit);
            ESFiscalLibrary.CreateESOrganization(ESOrganization, Enum::"NPR ES Taxpayer Territory"::BIZKAIA, Enum::"NPR ES Taxpayer Type"::COMPANY);
            ESFiscalLibrary.CreateESSigner(ESSigner, ESOrganization.Code);
            ESFiscalLibrary.CreateESClient(ESClient, ESSigner, POSUnit."No.", ESOrganization.Code);

            Initialized := true;
        end;

        POSAuditLog.DeleteAll(true); // Clean between tests
        Commit();
    end;

    local procedure CreateSalesperson()
    begin
        if not Salesperson.Get('1') then begin
            Salesperson.Init();
            Salesperson.Validate(Code, '1');
            Salesperson.Validate(Name, 'Test');
            Salesperson.Insert();
        end;
        Salesperson."NPR Register Password" := '1';
        Salesperson.Modify();
    end;
}
