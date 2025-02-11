codeunit 85192 "NPR POSActATShowAuditLog Tests"
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
    [HandlerFunctions('ModalPageHandler_ATPOSAuditLogAuxInfo_Show')]
    procedure ATPOSAuditLogAuxInfo_ShowAll()
    var
        POSActionATAuditLkpB: Codeunit "NPR POS Action: AT Audit Lkp B";
        Show: Option All,AllSigned,AllNonSigned,LastTransaction;
    begin
        // [SCENARIO] Tests action for showing all AT POS Audit Log Aux. Info records
        // [GIVEN] POS and AT audit setup
        InitializeData();

        // [GIVEN] Normal cash sale signed and normal cash sale not signed exists
        POSEntryNo1 := DoItemSale();
        POSEntryNo2 := DoItemSaleWithoutSigning();

        // [WHEN] Use action for showing all AT POS Audit Log Aux. Info records
        POSActionATAuditLkpB.ShowATAuditLog(Show::All);

        // [THEN] All AT POS Audit Log Aux. Info records are shown
        // handled in ModalPageHandler_ATPOSAuditLogAuxInfo_Show
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ModalPageHandler_ATPOSAuditLogAuxInfo_Show')]
    procedure ATPOSAuditLogAuxInfo_ShowAllSigned()
    var
        POSActionATAuditLkpB: Codeunit "NPR POS Action: AT Audit Lkp B";
        Show: Option All,AllSigned,AllNonSigned,LastTransaction;
    begin
        // [SCENARIO] Tests action for showing all signed AT POS Audit Log Aux. Info records
        // [GIVEN] POS and AT audit setup
        InitializeData();

        // [GIVEN] 2 normal cash sales signed
        POSEntryNo1 := DoItemSale();
        POSEntryNo2 := DoItemSale();

        // [WHEN] Use action for showing all signed AT POS Audit Log Aux. Info records
        POSActionATAuditLkpB.ShowATAuditLog(Show::AllSigned);

        // [THEN] All signed AT POS Audit Log Aux. Info records are shown
        // handled in ModalPageHandler_ATPOSAuditLogAuxInfo_Show
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ModalPageHandler_ATPOSAuditLogAuxInfo_Show')]
    procedure ATPOSAuditLogAuxInfo_ShowAllNonSigned()
    var
        POSActionATAuditLkpB: Codeunit "NPR POS Action: AT Audit Lkp B";
        Show: Option All,AllSigned,AllNonSigned,LastTransaction;
    begin
        // [SCENARIO] Tests action for showing all non-signed AT POS Audit Log Aux. Info records
        // [GIVEN] POS and AT audit setup
        InitializeData();

        // [GIVEN] 2 non-signed normal cash sales
        POSEntryNo1 := DoItemSaleWithoutSigning();
        POSEntryNo2 := DoItemSaleWithoutSigning();

        // [WHEN] Use action for showing all non-signed AT POS Audit Log Aux. Info records
        POSActionATAuditLkpB.ShowATAuditLog(Show::AllNonSigned);

        // [THEN] All non-signed AT POS Audit Log Aux. Info records are shown
        // handled in ModalPageHandler_ATPOSAuditLogAuxInfo_Show
    end;

    local procedure DoItemSale(): Integer
    var
        POSEntry: Record "NPR POS Entry";
        POSSale: Record "NPR POS Sale";
        POSMockLibrary: Codeunit "NPR Library - POS Mock";
        ATFiscalLibrary: Codeunit "NPR Library AT Fiscal";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        SaleNotEndedAsExpectedErr: Label 'Sale not ended as expected.', Locked = true;
    begin
        POSMockLibrary.InitializePOSSessionAndStartSale(POSSession, POSUnit, Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(POSSale);
        POSMockLibrary.CreateItemLine(POSSession, Item."No.", 1);
        ATFiscalLibrary.SetSigned(true);
        BindSubscription(ATFiscalLibrary);
        if not POSMockLibrary.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, Item."Unit Price", '') then
            Error(SaleNotEndedAsExpectedErr);
        UnbindSubscription(ATFiscalLibrary);

        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();
        POSSession.ClearAll();
        Clear(POSSession);
        exit(POSEntry."Entry No.");
    end;

    local procedure DoItemSaleWithoutSigning(): Integer
    var
        POSEntry: Record "NPR POS Entry";
        POSSale: Record "NPR POS Sale";
        POSMockLibrary: Codeunit "NPR Library - POS Mock";
        ATFiscalLibrary: Codeunit "NPR Library AT Fiscal";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        SaleNotEndedAsExpectedErr: Label 'Sale not ended as expected.', Locked = true;
    begin
        POSMockLibrary.InitializePOSSessionAndStartSale(POSSession, POSUnit, Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(POSSale);
        POSMockLibrary.CreateItemLine(POSSession, Item."No.", 1);
        ATFiscalLibrary.SetSigned(false);
        BindSubscription(ATFiscalLibrary);
        if not POSMockLibrary.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, Item."Unit Price", '') then
            Error(SaleNotEndedAsExpectedErr);
        UnbindSubscription(ATFiscalLibrary);

        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();
        POSSession.ClearAll();
        Clear(POSSession);
        exit(POSEntry."Entry No.");
    end;

    [ModalPageHandler]
    procedure ModalPageHandler_ATPOSAuditLogAuxInfo_Show(var ATPOSAuditLogAuxInfo: TestPage "NPR AT POS Audit Log Aux. Info")
    var
        RecordsNotProperlyShownErr: Label 'Records are not properly shown.', Locked = true;
    begin
        ATPOSAuditLogAuxInfo.Filter.SetFilter("POS Entry No.", Format(POSEntryNo1));
        Assert.IsTrue(ATPOSAuditLogAuxInfo.First(), RecordsNotProperlyShownErr);
        ATPOSAuditLogAuxInfo.Filter.SetFilter("POS Entry No.", Format(POSEntryNo2));
        Assert.IsTrue(ATPOSAuditLogAuxInfo.First(), RecordsNotProperlyShownErr);
    end;

    local procedure InitializeData()
    var
        ATOrganization: Record "NPR AT Organization";
        ATSCU: Record "NPR AT SCU";
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
        ATFiscalLibrary: Codeunit "NPR Library AT Fiscal";
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
            ATFiscalLibrary.CreateAuditProfileAndATSetups(POSAuditProfile, VATPostingSetup, POSUnit);
            CreateATOrganization(ATOrganization);
            CreateATSCU(ATSCU, ATOrganization.Code);
            CreateATCashRegister(POSUnit."No.", ATSCU.Code);

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

    local procedure CreateATOrganization(var ATOrganization: Record "NPR AT Organization")
    var
        ATFiscalLibrary: Codeunit "NPR Library AT Fiscal";
    begin
        ATFiscalLibrary.CreateATOrganization(ATOrganization);
        ATFiscalLibrary.AuthenticateATOrganizaiton(ATOrganization);
    end;

    local procedure CreateATSCU(var ATSCU: Record "NPR AT SCU"; ATOrganizationCode: Code[20])
    var
        ATFiscalLibrary: Codeunit "NPR Library AT Fiscal";
    begin
        ATFiscalLibrary.CreateATSCU(ATSCU);
        ATFiscalLibrary.InitializeATSCU(ATSCU, ATOrganizationCode);
    end;

    local procedure CreateATCashRegister(POSUnitNo: Code[10]; ATSCUCode: Code[20])
    var
        ATCashRegister: Record "NPR AT Cash Register";
        ATFiscalLibrary: Codeunit "NPR Library AT Fiscal";
    begin
        ATFiscalLibrary.CreateATCashRegister(ATCashRegister, POSUnitNo);
        ATFiscalLibrary.InitializeATCashRegister(ATCashRegister, ATSCUCode);
    end;
}