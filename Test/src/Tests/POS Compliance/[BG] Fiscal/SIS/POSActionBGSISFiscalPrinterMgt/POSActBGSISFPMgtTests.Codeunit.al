codeunit 85176 "NPR POSActBGSISFPMgt Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Item: Record Item;
        VoucherTypeDefault: Record "NPR NpRv Voucher Type";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSUnit: Record "NPR POS Unit";
        ReturnReason: Record "Return Reason";
        Salesperson: Record "Salesperson/Purchaser";
        Assert: Codeunit Assert;
        POSSession: Codeunit "NPR POS Session";
        Initialized: Boolean;
        SalesMustBeFiscalizedErr: Label 'Sales must be fiscalized by the fiscal printer.', Locked = true;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RefreshFiscalPrinterInfo()
    var
        BGSISPOSUnitMapping: Record "NPR BG SIS POS Unit Mapping";
        BGSISFiscalLibrary: Codeunit "NPR Library BG SIS Fiscal";
        POSActionBGSISFPMgtB: Codeunit "NPR POS Action: BG SIS FP MgtB";
        RelatedMappingMustBePopulatedErr: Label 'Related mapping must be populated.', Locked = true;
        Method: Option getMfcInfo,printReceipt,printXReport,printZReport,printDuplicate,cashHandling,printLastNotFiscalized,printSelectedNotFiscalized,getCashBalance;
    begin
        // [SCENARIO] Checks that refresh fiscal printer info gets successful response from the fiscal printer when BG SIS audit handler is enabled on POS unit.
        // [GIVEN] POS and BG SIS audit setup
        InitializeData();

        // [GIVEN] Fiscal printer info on related mapping is blank
        BGSISPOSUnitMapping.Get(POSUnit."No.");
        BGSISPOSUnitMapping."Fiscal Printer Device No." := '';
        BGSISPOSUnitMapping."Fiscal Printer Memory No." := '';
        BGSISPOSUnitMapping."Fiscal Printer Info Refreshed" := 0DT;
        BGSISPOSUnitMapping.Modify();

        // [WHEN] Refreshing the fiscal printer info
        POSActionBGSISFPMgtB.PrepareHTTPRequest(Method::getMfcInfo, POSUnit."No.", '', 0);
        POSActionBGSISFPMgtB.HandleResponse(BGSISFiscalLibrary.GetMfcInfoMockResponse(), Method::getMfcInfo, POSUnit."No.", '', 0);

        // [THEN] Fiscal printer info on related mapping is populated
        BGSISPOSUnitMapping.Get(POSUnit."No.");
        Assert.IsTrue(BGSISPOSUnitMapping."Fiscal Printer Device No." <> '', RelatedMappingMustBePopulatedErr);
        Assert.IsTrue(BGSISPOSUnitMapping."Fiscal Printer Memory No." <> '', RelatedMappingMustBePopulatedErr);
        Assert.IsTrue(BGSISPOSUnitMapping."Fiscal Printer Info Refreshed" <> 0DT, RelatedMappingMustBePopulatedErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler')]
    procedure NormalFiscalSales()
    var
        BGSISPOSAuditLogAux: Record "NPR BG SIS POS Audit Log Aux.";
        POSEntryNo: Integer;
    begin
        // [SCENARIO] Checks that successful cash sales gets successful response from the fiscal printer when BG SIS audit handler is enabled on POS unit.
        // [GIVEN] POS and BG SIS audit setup
        InitializeData();

        // [WHEN] Ending normal cash sale
        POSEntryNo := DoItemSale();

        // [THEN] For normal cash sale BG SIS Audit Log is created and populated from the fiscal printer
        BGSISPOSAuditLogAux.SetRange("Audit Entry Type", BGSISPOSAuditLogAux."Audit Entry Type"::"POS Entry");
        BGSISPOSAuditLogAux.SetRange("POS Entry No.", POSEntryNo);
        BGSISPOSAuditLogAux.FindFirst();
        Assert.IsTrue(BGSISPOSAuditLogAux."Receipt Timestamp" <> '', SalesMustBeFiscalizedErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler')]
    procedure NormalFiscalSalesWithRefund()
    var
        BGSISPOSAuditLogAux: Record "NPR BG SIS POS Audit Log Aux.";
        POSEntry: Record "NPR POS Entry";
        POSEntryNo: Integer;
        ReturnPOSEntryNo: Integer;
    begin
        // [SCENARIO] Checks that successful cash sales refund gets successful response from the fiscal printer when BG SIS audit handler is enabled on POS unit.
        // [GIVEN] POS and BG SIS audit setup
        InitializeData();

        // [WHEN] Refudning the sale
        POSEntryNo := DoItemSale();
        POSEntry.Get(POSEntryNo);
        ReturnPOSEntryNo := DoReturnSale(POSEntry."Document No.");

        // [THEN] For normal cash sale BG SIS Audit Log is created and populated from the fiscal printer for both sales and refund
        BGSISPOSAuditLogAux.SetRange("Audit Entry Type", BGSISPOSAuditLogAux."Audit Entry Type"::"POS Entry");
        BGSISPOSAuditLogAux.SetRange("POS Entry No.", POSEntryNo);
        BGSISPOSAuditLogAux.FindFirst();
        Assert.IsTrue(BGSISPOSAuditLogAux."Receipt Timestamp" <> '', SalesMustBeFiscalizedErr);

        BGSISPOSAuditLogAux.SetRange("Audit Entry Type", BGSISPOSAuditLogAux."Audit Entry Type"::"POS Entry");
        BGSISPOSAuditLogAux.SetRange("POS Entry No.", ReturnPOSEntryNo);
        BGSISPOSAuditLogAux.FindFirst();
        Assert.IsTrue(BGSISPOSAuditLogAux."Receipt Timestamp" <> '', SalesMustBeFiscalizedErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PrintXReport()
    var
        BGSISFiscalLibrary: Codeunit "NPR Library BG SIS Fiscal";
        POSActionBGSISFPMgtB: Codeunit "NPR POS Action: BG SIS FP MgtB";
        Method: Option getMfcInfo,printReceipt,printXReport,printZReport,printDuplicate,cashHandling,printLastNotFiscalized,printSelectedNotFiscalized,getCashBalance;
    begin
        // [SCENARIO] Checks that print X report gets successful response from the fiscal printer when BG SIS audit handler is enabled on POS unit.
        // [GIVEN] POS and BG SIS audit setup
        InitializeData();

        // [WHEN] Printing X report
        POSActionBGSISFPMgtB.PrepareHTTPRequest(Method::printXReport, POSUnit."No.", '', 0);

        // [THEN] Seccessful response is received
        POSActionBGSISFPMgtB.HandleResponse(BGSISFiscalLibrary.GetPrintXReportMockResponse(), Method::printXReport, POSUnit."No.", '', 0);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PrintZReport()
    var
        BGSISFiscalLibrary: Codeunit "NPR Library BG SIS Fiscal";
        POSActionBGSISFPMgtB: Codeunit "NPR POS Action: BG SIS FP MgtB";
        Method: Option getMfcInfo,printReceipt,printXReport,printZReport,printDuplicate,cashHandling,printLastNotFiscalized,printSelectedNotFiscalized,getCashBalance;
    begin
        // [SCENARIO] Checks that print Z report gets successful response from the fiscal printer when BG SIS audit handler is enabled on POS unit.
        // [GIVEN] POS and BG SIS audit setup
        InitializeData();

        // [WHEN] Printing Z report
        POSActionBGSISFPMgtB.PrepareHTTPRequest(Method::printZReport, POSUnit."No.", '', 0);

        // [THEN] Seccessful response is received
        POSActionBGSISFPMgtB.HandleResponse(BGSISFiscalLibrary.GetPrintZReportMockResponse(), Method::printZReport, POSUnit."No.", '', 0);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PrintDuplicate()
    var
        BGSISFiscalLibrary: Codeunit "NPR Library BG SIS Fiscal";
        POSActionBGSISFPMgtB: Codeunit "NPR POS Action: BG SIS FP MgtB";
        Method: Option getMfcInfo,printReceipt,printXReport,printZReport,printDuplicate,cashHandling,printLastNotFiscalized,printSelectedNotFiscalized,getCashBalance;
    begin
        // [SCENARIO] Checks that print duplicate gets successful response from the fiscal printer when BG SIS audit handler is enabled on POS unit.
        // [GIVEN] POS and BG SIS audit setup
        InitializeData();

        // [WHEN] Printing duplicate
        POSActionBGSISFPMgtB.PrepareHTTPRequest(Method::printDuplicate, POSUnit."No.", '', 0);

        // [THEN] Seccessful response is received
        POSActionBGSISFPMgtB.HandleResponse(BGSISFiscalLibrary.GetPrintDuplicateMockResponse(), Method::printDuplicate, POSUnit."No.", '', 0);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler,PageHandler_POSPaymentBinCheckpoint_LookupOK')]
    procedure CashHandling()
    var
        BGSISFiscalLibrary: Codeunit "NPR Library BG SIS Fiscal";
        POSActionBGSISFPMgtB: Codeunit "NPR POS Action: BG SIS FP MgtB";
        Method: Option getMfcInfo,printReceipt,printXReport,printZReport,printDuplicate,cashHandling,printLastNotFiscalized,printSelectedNotFiscalized,getCashBalance;
    begin
        // [SCENARIO] Checks that cash handling gets successful response from the fiscal printer when BG SIS audit handler is enabled on POS unit.
        // [GIVEN] POS and BG SIS audit setup
        InitializeData();

        // [WHEN] Transferring contents to bin
        TransferContentsToBin();

        // [THEN] Seccessful response is received
        POSActionBGSISFPMgtB.HandleResponse(BGSISFiscalLibrary.GetCashHandlingMockResponse(), Method::cashHandling, '', '', 0);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler')]
    procedure NormalFiscalSales_PrintLastNotFiscalized()
    var
        BGSISPOSAuditLogAux: Record "NPR BG SIS POS Audit Log Aux.";
        POSEntryNo: Integer;
    begin
        // [SCENARIO] Checks that printing of the last cash sales which wasn't fiscalized at the end of sale, gets successful response from the fiscal printer when BG SIS audit handler is enabled on POS unit.
        // [GIVEN] POS and BG SIS audit setup
        InitializeData();

        // [GIVEN] Normal cash sale not fiscalized
        POSEntryNo := DoItemSaleWithoutFiscalization();

        // [WHEN] Fiscalizing normal cash sale
        PrintLastNotFiscalized();

        // [THEN] For normal cash sale BG SIS Audit Log is created and populated from the fiscal printer
        BGSISPOSAuditLogAux.SetRange("Audit Entry Type", BGSISPOSAuditLogAux."Audit Entry Type"::"POS Entry");
        BGSISPOSAuditLogAux.SetRange("POS Entry No.", POSEntryNo);
        BGSISPOSAuditLogAux.FindFirst();
        Assert.IsTrue(BGSISPOSAuditLogAux."Receipt Timestamp" <> '', SalesMustBeFiscalizedErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler,ModalPageHandler_BGSISPOSAuditLogAux_SelectFirst')]
    procedure NormalFiscalSales_PrintSelectedNotFiscalized()
    var
        BGSISPOSAuditLogAux: Record "NPR BG SIS POS Audit Log Aux.";
        POSEntryNo: Integer;
    begin
        // [SCENARIO] Checks that printing of the selected cash sales which wasn't fiscalized at the end of sale, gets successful response from the fiscal printer when BG SIS audit handler is enabled on POS unit.
        // [GIVEN] POS and BG SIS audit setup
        InitializeData();

        // [GIVEN] Normal cash sale not fiscalized
        POSEntryNo := DoItemSaleWithoutFiscalization();

        // [WHEN] Fiscalizing normal cash sale
        PrintSelectedNotFiscalized();

        // [THEN] For normal cash sale BG SIS Audit Log is created and populated from the fiscal printer
        BGSISPOSAuditLogAux.SetRange("Audit Entry Type", BGSISPOSAuditLogAux."Audit Entry Type"::"POS Entry");
        BGSISPOSAuditLogAux.SetRange("POS Entry No.", POSEntryNo);
        BGSISPOSAuditLogAux.FindFirst();
        Assert.IsTrue(BGSISPOSAuditLogAux."Receipt Timestamp" <> '', SalesMustBeFiscalizedErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MessageHandler_GetCashBalance')]
    procedure GetCashBalance()
    var
        BGSISFiscalLibrary: Codeunit "NPR Library BG SIS Fiscal";
        POSActionBGSISFPMgtB: Codeunit "NPR POS Action: BG SIS FP MgtB";
        Method: Option getMfcInfo,printReceipt,printXReport,printZReport,printDuplicate,cashHandling,printLastNotFiscalized,printSelectedNotFiscalized,getCashBalance;
    begin
        // [SCENARIO] Checks that get cash balance gets successful response from the fiscal printer when BG SIS audit handler is enabled on POS unit.
        // [GIVEN] POS and BG SIS audit setup
        InitializeData();

        // [WHEN] Getting cash balance
        POSActionBGSISFPMgtB.PrepareHTTPRequest(Method::getCashBalance, POSUnit."No.", '', 0);

        // [THEN] Seccessful response is received
        POSActionBGSISFPMgtB.HandleResponse(BGSISFiscalLibrary.GetGetCashBalanceMockResponse(), Method::getCashBalance, POSUnit."No.", '', 0);
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

    local procedure DoReturnSale(ReceiptNumberToReturn: Code[20]): Integer
    var
        POSEntry: Record "NPR POS Entry";
        POSSale: Record "NPR POS Sale";
        POSMockLibrary: Codeunit "NPR Library - POS Mock";
        BGSISFiscalLibrary: Codeunit "NPR Library BG SIS Fiscal";
        POSActionBGSISFPMgtB: Codeunit "NPR POS Action: BG SIS FP MgtB";
        POSActionRevDirSaleB: Codeunit "NPR POS Action: Rev.Dir.Sale B";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        ChangeAmount: Decimal;
        PaidAmount: Decimal;
        RoundingAmount: Decimal;
        SalesAmount: Decimal;
        SaleNotEndedAsExpectedErr: Label 'Sale not ended as expected.', Locked = true;
        Method: Option getMfcInfo,printReceipt,printXReport,printZReport,printDuplicate,cashHandling,printLastNotFiscalized,printSelectedNotFiscalized,getCashBalance;
    begin
        POSMockLibrary.InitializePOSSessionAndStartSale(POSSession, POSUnit, Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(POSSale);
        POSActionRevDirSaleB.ReverseSalesTicket(POSSale, ReceiptNumberToReturn, ReturnReason.Code, true);
        POSSaleWrapper.GetTotals(SalesAmount, PaidAmount, ChangeAmount, RoundingAmount);
        if not POSMockLibrary.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, SalesAmount, '') then
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

    local procedure PrintLastNotFiscalized()
    var
        BGSISFiscalLibrary: Codeunit "NPR Library BG SIS Fiscal";
        POSActionBGSISFPMgtB: Codeunit "NPR POS Action: BG SIS FP MgtB";
        Method: Option getMfcInfo,printReceipt,printXReport,printZReport,printDuplicate,cashHandling,printLastNotFiscalized,printSelectedNotFiscalized,getCashBalance;
    begin
        POSActionBGSISFPMgtB.PrepareHTTPRequest(Method::printLastNotFiscalized, POSUnit."No.", '', 0);
        POSActionBGSISFPMgtB.HandleResponse(BGSISFiscalLibrary.GetPrintReceiptMockResponse(), Method::printLastNotFiscalized, POSUnit."No.", '', 0);
    end;

    local procedure PrintSelectedNotFiscalized()
    var
        BGSISFiscalLibrary: Codeunit "NPR Library BG SIS Fiscal";
        POSActionBGSISFPMgtB: Codeunit "NPR POS Action: BG SIS FP MgtB";
        Method: Option getMfcInfo,printReceipt,printXReport,printZReport,printDuplicate,cashHandling,printLastNotFiscalized,printSelectedNotFiscalized,getCashBalance;
    begin
        POSActionBGSISFPMgtB.PrepareHTTPRequest(Method::printSelectedNotFiscalized, POSUnit."No.", '', 0);
        POSActionBGSISFPMgtB.HandleResponse(BGSISFiscalLibrary.GetPrintReceiptMockResponse(), Method::printSelectedNotFiscalized, POSUnit."No.", '', 0);
    end;

    local procedure TransferContentsToBin()
    var
        POSMockLibrary: Codeunit "NPR Library - POS Mock";
        POSActionBGSISFPMgtB: Codeunit "NPR POS Action: BG SIS FP MgtB";
        POSActionBinTransferB: Codeunit "NPR POS Action: Bin Transfer B";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        POSWorkshiftCheckpoint: Codeunit "NPR POS Workshift Checkpoint";
        FromBinNo: Code[10];
        CheckpointEntryNo: Integer;
        Method: Option getMfcInfo,printReceipt,printXReport,printZReport,printDuplicate,cashHandling,printLastNotFiscalized,printSelectedNotFiscalized,getCashBalance;
    begin
        DoItemSale();

        POSMockLibrary.InitializePOSSessionAndStartSale(POSSession, POSUnit, Salesperson, POSSaleWrapper);

        FromBinNo := POSActionBinTransferB.GetDefaultUnitBin(POSUnit);
        POSActionBinTransferB.GetPosUnitFromBin(FromBinNo, PosUnit);
        CheckpointEntryNo := POSWorkshiftCheckpoint.CreateEndWorkshiftCheckpoint_POSEntry(POSUnit."POS Store Code", POSUnit."No.", POSUnit.Status);

        POSActionBinTransferB.TransferContentsToBin(POSSession, FromBinNo, CheckpointEntryNo);
        POSActionBGSISFPMgtB.PrepareHTTPRequest(Method::cashHandling, POSUnit."No.", '', CheckpointEntryNo);

        Clear(POSSession);
    end;

    [ConfirmHandler]
    procedure GeneralConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    var
        AllowedTaxRatesVATPostingSetupQst: Label 'Allowed Tax Rates, VAT Posting Setup will be updated. Do you want to proceed?', Locked = true;
        CreateExtendedFiscalReceiptQst: Label 'Do you want to create extended fiscal receipt?', Locked = true;
        FinishTransferAndPostResultsQst: Label 'Do you want to finish transfer and post results?', Locked = true;
        QuestionNotExpectedErr: Label 'Question "%1" is not expected.', Locked = true;
    begin
        case true of
            Question = AllowedTaxRatesVATPostingSetupQst:
                Reply := true;
            Question = CreateExtendedFiscalReceiptQst:
                Reply := false;
            Question = FinishTransferAndPostResultsQst:
                Reply := true;
            else
                Error(QuestionNotExpectedErr, Question);
        end;
    end;

    [ModalPageHandler]
    procedure PageHandler_POSPaymentBinCheckpoint_LookupOK(var BinToTransfer: Page "NPR POS Payment Bin Checkpoint"; var ActionResponse: Action)
    begin
        BinToTransfer.DoOnOpenPageProcessing();
        BinToTransfer.DoOnClosePageProcessing();
        ActionResponse := Action::LookupOK;
    end;

    [ModalPageHandler]
    procedure ModalPageHandler_BGSISPOSAuditLogAux_SelectFirst(var BGSISPOSAuditLogAux: TestPage "NPR BG SIS POS Audit Log Aux.")
    begin
        BGSISPOSAuditLogAux.First();
        BGSISPOSAuditLogAux.OK().Invoke();
    end;

    [MessageHandler]
    procedure MessageHandler_GetCashBalance(Message: Text[1024])
    var
        GetCashBalanceMsg: Label 'Cash balance is 100.00.', Locked = true;
        MessageNotExpectedErr: Label 'Message "%1" is not expected.', Locked = true;
    begin
        Assert.IsTrue(Message = GetCashBalanceMsg, StrSubstNo(MessageNotExpectedErr, Message));
    end;

    local procedure InitializeData()
    var
        POSAuditLog: Record "NPR POS Audit Log";
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSSetup: Record "NPR POS Setup";
        POSStore: Record "NPR POS Store";
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