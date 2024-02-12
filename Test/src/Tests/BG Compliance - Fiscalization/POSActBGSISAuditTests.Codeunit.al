codeunit 85178 "NPR POSActBGSISAudit Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Item: Record Item;
        VoucherTypeDefault: Record "NPR NpRv Voucher Type";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSUnit: Record "NPR POS Unit";
        Salesperson: Record "Salesperson/Purchaser";
        Assert: Codeunit Assert;
        POSSession: Codeunit "NPR POS Session";
        Initialized: Boolean;
        POSEntryNo1, POSEntryNo2 : Integer;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler,ModalPageHandler_BGSISPOSAuditLogAux_Show')]
    procedure BGSISPOSAuditLogAux_ShowAll()
    var
        POSActionBGSISAuditB: Codeunit "NPR POS Action: BG SIS Audit B";
        Show: Option All,AllFiscalized,AllNonFiscalized,LastTransaction;
    begin
        // [SCENARIO] Tests action for showing all BG SIS POS Audit Log Aux. records
        // [GIVEN] POS and BG SIS audit setup
        InitializeData();

        // [GIVEN] Normal cash sale fiscalized and normal cash sale not fiscalized exists
        POSEntryNo1 := DoItemSale();
        POSEntryNo2 := DoItemSaleWithoutFiscalization();

        // [WHEN] Use action for showing all BG SIS POS Audit Log Aux. records
        POSActionBGSISAuditB.ShowBGSISAuditLog(Show::All);

        // [THEN] All BG SIS POS Audit Log Aux. records are shown
        // handled in ModalPageHandler_BGSISPOSAuditLogAux_Show
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler,ModalPageHandler_BGSISPOSAuditLogAux_Show')]
    procedure BGSISPOSAuditLogAux_ShowAllFiscalized()
    var
        POSActionBGSISAuditB: Codeunit "NPR POS Action: BG SIS Audit B";
        Show: Option All,AllFiscalized,AllNonFiscalized,LastTransaction;
    begin
        // [SCENARIO] Tests action for showing all fiscalized BG SIS POS Audit Log Aux. records
        // [GIVEN] POS and BG SIS audit setup
        InitializeData();

        // [GIVEN] 2 normal cash sales fiscalized
        POSEntryNo1 := DoItemSale();
        POSEntryNo2 := DoItemSale();

        // [WHEN] Use action for showing all fiscalized BG SIS POS Audit Log Aux. records
        POSActionBGSISAuditB.ShowBGSISAuditLog(Show::AllFiscalized);

        // [THEN] All fiscalized BG SIS POS Audit Log Aux. records are shown
        // handled in ModalPageHandler_BGSISPOSAuditLogAux_Show
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ModalPageHandler_BGSISPOSAuditLogAux_Show')]
    procedure BGSISPOSAuditLogAux_ShowAllNonFiscalized()
    var
        POSActionBGSISAuditB: Codeunit "NPR POS Action: BG SIS Audit B";
        Show: Option All,AllFiscalized,AllNonFiscalized,LastTransaction;
    begin
        // [SCENARIO] Tests action for showing all non-fiscalized BG SIS POS Audit Log Aux. records
        // [GIVEN] POS and BG SIS audit setup
        InitializeData();

        // [GIVEN] 2 non-fiscalized normal cash sales
        POSEntryNo1 := DoItemSaleWithoutFiscalization();
        POSEntryNo2 := DoItemSaleWithoutFiscalization();

        // [WHEN] Use action for showing all non-fiscalized BG SIS POS Audit Log Aux. records
        POSActionBGSISAuditB.ShowBGSISAuditLog(Show::AllNonFiscalized);

        // [THEN] All non-fiscalized BG SIS POS Audit Log Aux. records are shown
        // handled in ModalPageHandler_BGSISPOSAuditLogAux_Show
    end;

    local procedure DoItemSale(): Integer
    var
        POSEntry: Record "NPR POS Entry";
        POSSale: Record "NPR POS Sale";
        POSMockLibrary: Codeunit "NPR Library - POS Mock";
        BGSISFiscalLibrary: Codeunit "NPR Library BG SIS Fiscal";
        POSActionBGSISFPMgtB: Codeunit "NPR POS Action: BG SIS FP MgtB";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        SaleNotEndedAsExpectedErr: Label 'Sale not ended as expected.', Locked = true;
        Method: Option getMfcInfo,printReceipt,printXReport,printZReport,printDuplicate,cashHandling,printLastNotFiscalized,printSelectedNotFiscalized,getCashBalance;
    begin
        POSMockLibrary.InitializePOSSessionAndStartSale(POSSession, POSUnit, Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(POSSale);
        POSMockLibrary.CreateItemLine(POSSession, Item."No.", 1);
        if not POSMockLibrary.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, Item."Unit Price", '') then
            Error(SaleNotEndedAsExpectedErr);

        POSActionBGSISFPMgtB.PrepareHTTPRequest(Method::printReceipt, POSUnit."No.", POSSale."Sales Ticket No.", 0);
        POSActionBGSISFPMgtB.HandleResponse(BGSISFiscalLibrary.GetPrintReceiptMockResponse(), Method::printReceipt, POSUnit."No.", POSSale."Sales Ticket No.", 0);

        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();
        POSSession.ClearAll();
        Clear(POSSession);
        exit(POSEntry."Entry No.");
    end;

    local procedure DoItemSaleWithoutFiscalization(): Integer
    var
        POSEntry: Record "NPR POS Entry";
        POSSale: Record "NPR POS Sale";
        POSMockLibrary: Codeunit "NPR Library - POS Mock";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        SaleNotEndedAsExpectedErr: Label 'Sale not ended as expected.', Locked = true;
    begin
        POSMockLibrary.InitializePOSSessionAndStartSale(POSSession, POSUnit, Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(POSSale);
        POSMockLibrary.CreateItemLine(POSSession, Item."No.", 1);
        if not POSMockLibrary.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, Item."Unit Price", '') then
            Error(SaleNotEndedAsExpectedErr);

        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();
        POSSession.ClearAll();
        Clear(POSSession);
        exit(POSEntry."Entry No.");
    end;

    [ConfirmHandler]
    procedure GeneralConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    var
        AllowedTaxRatesVATPostingSetupQst: Label 'Allowed Tax Rates, VAT Posting Setup will be updated. Do you want to proceed?', Locked = true;
        CreateExtendedFiscalReceiptQst: Label 'Do you want to create extended fiscal receipt?', Locked = true;
        QuestionNotExpectedErr: Label 'Question "%1" is not expected.', Locked = true;
    begin
        case true of
            Question = AllowedTaxRatesVATPostingSetupQst:
                Reply := true;
            Question = CreateExtendedFiscalReceiptQst:
                Reply := false;
            else
                Error(QuestionNotExpectedErr, Question);
        end;
    end;

    [ModalPageHandler]
    procedure ModalPageHandler_BGSISPOSAuditLogAux_Show(var BGSISPOSAuditLogAux: TestPage "NPR BG SIS POS Audit Log Aux.")
    var
        RecordsNotProperlyShownErr: Label 'Records are not properly shown.', Locked = true;
    begin
        BGSISPOSAuditLogAux.Filter.SetFilter("POS Entry No.", Format(POSEntryNo1));
        Assert.IsTrue(BGSISPOSAuditLogAux.First(), RecordsNotProperlyShownErr);
        BGSISPOSAuditLogAux.Filter.SetFilter("POS Entry No.", Format(POSEntryNo2));
        Assert.IsTrue(BGSISPOSAuditLogAux.First(), RecordsNotProperlyShownErr);
    end;

    local procedure InitializeData()
    var
        POSAuditLog: Record "NPR POS Audit Log";
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSSetup: Record "NPR POS Setup";
        POSStore: Record "NPR POS Store";
        ReturnReason: Record "Return Reason";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryERM: Codeunit "Library - ERM";
        POSMasterDataLibrary: Codeunit "NPR Library - POS Master Data";
        BGSISFiscalLibrary: Codeunit "NPR Library BG SIS Fiscal";
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
            BGSISFiscalLibrary.CreateAuditProfileAndBGSISSetups(POSAuditProfile, VATPostingSetup, POSUnit);

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