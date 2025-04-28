codeunit 85226 "NPR POS Act HU L Receipt Tests"
{
    SubType = Test;

    var
        _Item: Record Item;
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _ReturnReason: Record "Return Reason";
        _Salesperson: Record "Salesperson/Purchaser";
        _POSUnit: Record "NPR POS Unit";
        _Customer: Record Customer;
        _Assert: Codeunit Assert;
        _POSSession: Codeunit "NPR POS Session";
        _Initialized: Boolean;
        SalesMustBeFiscalizedErr: Label 'Sales must be fiscalized by the fiscal control unit.', Locked = true;

    [Test]
    [HandlerFunctions('CustomerDataInputHandlerFalse')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NormalFiscalSales()
    var
        HULPOSAuditLogAux: Record "NPR HU L POS Audit Log Aux.";
        POSEntryNo: Integer;
    begin
        // [SCENARIO] Checks that successful cash sales gets successful response from the fiscal printer when HU Laurel audit handler is enabled on POS unit.
        // [GIVEN] POS and HU Laurel audit setup
        InitializeData();

        // [WHEN] Ending normal cash sale
        POSEntryNo := DoItemSale();

        // [THEN] For normal cash sale HU Laurel Audit Log is created and populated from the fiscal printer
        HULPOSAuditLogAux.SetRange("Audit Entry Type", HULPOSAuditLogAux."Audit Entry Type"::"POS Entry");
        HULPOSAuditLogAux.SetRange("POS Entry No.", POSEntryNo);
        HULPOSAuditLogAux.FindFirst();
        _Assert.IsTrue(HULPOSAuditLogAux."FCU BBOX ID" <> '', SalesMustBeFiscalizedErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('CustomerDataInputHandlerTrue,CustomerInfoInputPageHandler')]
    procedure NormalFiscalSalesWithRefund()
    var
        HULPOSAuditLogAux: Record "NPR HU L POS Audit Log Aux.";
        POSEntry: Record "NPR POS Entry";
        POSEntryNo: Integer;
        ReturnPOSEntryNo: Integer;
    begin
        // [SCENARIO] Checks that successful cash sales refund gets successful response from the fiscal printer when HU Laurel audit handler is enabled on POS unit.
        // [GIVEN] POS and HU Laurel audit setup
        InitializeData();

        // [WHEN] Refudning the sale
        POSEntryNo := DoItemSale();
        POSEntry.Get(POSEntryNo);
        ReturnPOSEntryNo := DoReturnSale(POSEntry."Document No.");

        // [THEN] For normal cash sale HU Laurel Audit Log is created and populated from the fiscal printer for both sales and refund
        HULPOSAuditLogAux.SetRange("Audit Entry Type", HULPOSAuditLogAux."Audit Entry Type"::"POS Entry");
        HULPOSAuditLogAux.SetRange("POS Entry No.", POSEntryNo);
        HULPOSAuditLogAux.FindFirst();
        _Assert.IsTrue(HULPOSAuditLogAux."FCU BBOX ID" <> '', SalesMustBeFiscalizedErr);

        HULPOSAuditLogAux.SetRange("Audit Entry Type", HULPOSAuditLogAux."Audit Entry Type"::"POS Entry");
        HULPOSAuditLogAux.SetRange("POS Entry No.", ReturnPOSEntryNo);
        HULPOSAuditLogAux.FindFirst();
        _Assert.IsTrue(HULPOSAuditLogAux."FCU BBOX ID" <> '', SalesMustBeFiscalizedErr);
    end;

    local procedure InitializeData()
    var
        POSAuditLog: Record "NPR POS Audit Log";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSSetup: Record "NPR POS Setup";
        POSStore: Record "NPR POS Store";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryERM: Codeunit "Library - ERM";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryHULFiscal: Codeunit "NPR Library HU L Fiscal";
    begin
        //Clean any previous mock session
        _POSSession.ClearAll();
        Clear(_POSSession);

        if not _Initialized then begin
            LibraryPOSMasterData.CreatePOSSetup(POSSetup);
            LibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            POSPostingProfile."POS Period Register No. Series" := '';
            POSPostingProfile.Modify();

            LibraryPOSMasterData.CreatePOSStore(POSStore, POSPostingProfile.Code);
            LibraryPOSMasterData.CreatePOSUnit(_POSUnit, POSStore.Code, POSPostingProfile.Code);
            LibraryHULFiscal.CreateHULPOSUnitMapping(_POSUnit."No.");

            LibraryHULFiscal.CreateSalesperson(_Salesperson);

            LibraryPOSMasterData.CreatePOSPaymentMethod(_POSPaymentMethod, _POSPaymentMethod."Processing Type"::CASH, '', false);
            LibraryHULFiscal.CreateHULPOSPaymentMethodMapping(_POSPaymentMethod);

            LibraryPOSMasterData.CreateItemForPOSSaleUsage(_Item, _POSUnit, POSStore);
            _Item."Unit Price" := 10;
            _Item.Modify();

            LibraryERM.CreateReturnReasonCode(_ReturnReason);
            LibraryHULFiscal.CreateHULReturnReasonMapping(_ReturnReason.Code);

            VATPostingSetup.SetRange("VAT Prod. Posting Group", _Item."VAT Prod. Posting Group");
            VATPostingSetup.SetRange("VAT Bus. Posting Group", POSPostingProfile."VAT Bus. Posting Group");
            VATPostingSetup.SetFilter("VAT %", '<>%1', 0);
            VATPostingSetup.FindFirst();
            LibraryHULFiscal.CreateHULVATPostingSetupMapping(VATPostingSetup);

            LibraryHULFiscal.CreateCustomer(_Customer, POSPostingProfile."VAT Bus. Posting Group");

            LibraryHULFiscal.CreateHULPOSAuditProfileAndSetToPOSUnit(_POSUnit);
            LibraryHULFiscal.CreateHULFiscalizationSetup();

            _Initialized := true;
        end;

        POSAuditLog.DeleteAll(true); //Clean in between tests
        Commit();
    end;

    local procedure DoItemSale(): Integer
    var
        POSEntry: Record "NPR POS Entry";
        POSSale: Record "NPR POS Sale";
        POSMockLibrary: Codeunit "NPR Library - POS Mock";
        LibraryHULFiscal: Codeunit "NPR Library HU L Fiscal";
        POSActionHULReceiptB: Codeunit "NPR POS Action: HU L Receipt B";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        SaleNotEndedAsExpectedErr: Label 'Sale not ended as expected.', Locked = true;
        RequestObject: JsonObject;
    begin
        POSMockLibrary.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(POSSale);
        POSSale.Validate("Customer No.", _Customer."No.");
        POSMockLibrary.CreateItemLine(_POSSession, _Item."No.", 1);
        if not POSMockLibrary.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, _Item."Unit Price", '') then
            Error(SaleNotEndedAsExpectedErr);

        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();

        POSActionHULReceiptB.CreatePrintReceiptRequest(RequestObject, POSEntry);
        POSActionHULReceiptB.ProcessLaurelMiniPOSResponse(LibraryHULFiscal.GetPrintReceiptMockResponse(), POSEntry);

        _POSSession.ClearAll();
        Clear(_POSSession);
        exit(POSEntry."Entry No.");
    end;

    local procedure DoReturnSale(ReceiptNumberToReturn: Code[20]): Integer
    var
        POSEntry: Record "NPR POS Entry";
        POSSale: Record "NPR POS Sale";
        POSMockLibrary: Codeunit "NPR Library - POS Mock";
        LibraryHULFiscal: Codeunit "NPR Library HU L Fiscal";
        POSActionHULReceiptB: Codeunit "NPR POS Action: HU L Receipt B";
        POSActionRevDirSaleB: Codeunit "NPR POS Action: Rev.Dir.Sale B";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        ChangeAmount: Decimal;
        PaidAmount: Decimal;
        RoundingAmount: Decimal;
        SalesAmount: Decimal;
        RequestObject: JsonObject;
        SaleNotEndedAsExpectedErr: Label 'Sale not ended as expected.', Locked = true;
    begin
        POSMockLibrary.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(POSSale);
        POSSale.Validate("Customer No.", _Customer."No.");
        POSActionRevDirSaleB.ReverseSalesTicket(POSSale, ReceiptNumberToReturn, _ReturnReason.Code, true);
        POSSaleWrapper.GetTotals(SalesAmount, PaidAmount, ChangeAmount, RoundingAmount);
        if not POSMockLibrary.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, SalesAmount, '') then
            Error(SaleNotEndedAsExpectedErr);

        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();

        POSActionHULReceiptB.CreatePrintReceiptRequest(RequestObject, POSEntry);
        POSActionHULReceiptB.ProcessLaurelMiniPOSResponse(LibraryHULFiscal.GetPrintReceiptMockResponse(), POSEntry);

        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();
        _POSSession.ClearAll();
        Clear(_POSSession);
        exit(POSEntry."Entry No.");
    end;

    [ConfirmHandler]
    procedure CustomerDataInputHandlerFalse(Question: Text[1024]; var Reply: Boolean)
    var
        AddCustomerDataQst: Label 'Do you want to add customer data to the receipt?';
    begin
        _Assert.ExpectedMessage(AddCustomerDataQst, Question);
        Reply := false;
    end;

    [ConfirmHandler]
    procedure CustomerDataInputHandlerTrue(Question: Text[1024]; var Reply: Boolean)
    var
        AddCustomerDataQst: Label 'Do you want to add customer data to the receipt?';
    begin
        _Assert.ExpectedMessage(AddCustomerDataQst, Question);
        Reply := true;
    end;

    [ModalPageHandler]
    procedure CustomerInfoInputPageHandler(var Page: Page "NPR Input Dialog"; var Response: Action)
    begin
        Response := Action::OK;
    end;
}