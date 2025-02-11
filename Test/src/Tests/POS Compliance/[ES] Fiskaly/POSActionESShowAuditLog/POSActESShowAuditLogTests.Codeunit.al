codeunit 85208 "NPR POSActESShowAuditLog Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Item: Record Item;
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSUnit: Record "NPR POS Unit";
        Salesperson: Record "Salesperson/Purchaser";
        Assert: Codeunit Assert;
        POSSession: Codeunit "NPR POS Session";
        Initialized: Boolean;
        POSEntryNo1, POSEntryNo2 : Integer;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler,ModalPageHandler_ESPOSAuditLogAuxInfo_Show')]
    procedure ESPOSAuditLogAuxInfo_ShowAll()
    var
        POSActionESAuditLkpB: Codeunit "NPR POS Action: ES Audit Lkp B";
        Show: Option All,AllRegistered,AllNonRegistered,LastTransaction;
    begin
        // [SCENARIO] Tests action for showing all ES POS Audit Log Aux. Info records
        // [GIVEN] POS and ES audit setup
        InitializeData();

        // [GIVEN] Normal cash sale registered and normal cash sale not registered exists
        POSEntryNo1 := DoItemSale();
        POSEntryNo2 := DoItemSaleWithoutRegistering();

        // [WHEN] Use action for showing all ES POS Audit Log Aux. Info records
        POSActionESAuditLkpB.ShowESAuditLog(Show::All);

        // [THEN] All ES POS Audit Log Aux. Info records are shown
        // handled in ModalPageHandler_ESPOSAuditLogAuxInfo_Show
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler,ModalPageHandler_ESPOSAuditLogAuxInfo_Show')]
    procedure ESPOSAuditLogAuxInfo_ShowAllRegistered()
    var
        POSActionESAuditLkpB: Codeunit "NPR POS Action: ES Audit Lkp B";
        Show: Option All,AllRegistered,AllNonRegistered,LastTransaction;
    begin
        // [SCENARIO] Tests action for showing all registered ES POS Audit Log Aux. Info records
        // [GIVEN] POS and ES audit setup
        InitializeData();

        // [GIVEN] 2 normal cash sales registered
        POSEntryNo1 := DoItemSale();
        POSEntryNo2 := DoItemSale();

        // [WHEN] Use action for showing all registered ES POS Audit Log Aux. Info records
        POSActionESAuditLkpB.ShowESAuditLog(Show::AllRegistered);

        // [THEN] All registered ES POS Audit Log Aux. Info records are shown
        // handled in ModalPageHandler_ESPOSAuditLogAuxInfo_Show
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler,ModalPageHandler_ESPOSAuditLogAuxInfo_Show')]
    procedure ESPOSAuditLogAuxInfo_ShowAllNonRegistered()
    var
        POSActionESAuditLkpB: Codeunit "NPR POS Action: ES Audit Lkp B";
        Show: Option All,AllRegistered,AllNonRegistered,LastTransaction;
    begin
        // [SCENARIO] Tests action for showing all non-registered ES POS Audit Log Aux. Info records
        // [GIVEN] POS and ES audit setup
        InitializeData();

        // [GIVEN] 2 non-registered normal cash sales
        POSEntryNo1 := DoItemSaleWithoutRegistering();
        POSEntryNo2 := DoItemSaleWithoutRegistering();

        // [WHEN] Use action for showing all non-registered ES POS Audit Log Aux. Info records
        POSActionESAuditLkpB.ShowESAuditLog(Show::AllNonRegistered);

        // [THEN] All non-registered ES POS Audit Log Aux. Info records are shown
        // handled in ModalPageHandler_ESPOSAuditLogAuxInfo_Show
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
        ESFiscalLibrary.SetInvoiceRegistrationState(Enum::"NPR ES Inv. Registration State"::REGISTERED);
        BindSubscription(ESFiscalLibrary);
        if not POSMockLibrary.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, Item."Unit Price", '') then
            Error(SaleNotEndedAsExpectedErr);
        UnbindSubscription(ESFiscalLibrary);

        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();
        POSSession.ClearAll();
        Clear(POSSession);
        exit(POSEntry."Entry No.");
    end;

    local procedure DoItemSaleWithoutRegistering(): Integer
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
        if not POSMockLibrary.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, Item."Unit Price", '') then
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

    [ModalPageHandler]
    procedure ModalPageHandler_ESPOSAuditLogAuxInfo_Show(var ESPOSAuditLogAuxInfo: TestPage "NPR ES POS Audit Log Aux. Info")
    var
        RecordsNotProperlyShownErr: Label 'Records are not properly shown.', Locked = true;
    begin
        ESPOSAuditLogAuxInfo.Filter.SetFilter("POS Entry No.", Format(POSEntryNo1));
        Assert.IsTrue(ESPOSAuditLogAuxInfo.First(), RecordsNotProperlyShownErr);
        ESPOSAuditLogAuxInfo.Filter.SetFilter("POS Entry No.", Format(POSEntryNo2));
        Assert.IsTrue(ESPOSAuditLogAuxInfo.First(), RecordsNotProperlyShownErr);
    end;

    local procedure InitializeData()
    var
        ESOrganization: Record "NPR ES Organization";
        ESClient: Record "NPR ES Client";
        ESSigner: Record "NPR ES Signer";
        VoucherTypeDefault: Record "NPR NpRv Voucher Type";
        POSAuditLog: Record "NPR POS Audit Log";
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSSetup: Record "NPR POS Setup";
        POSStore: Record "NPR POS Store";
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