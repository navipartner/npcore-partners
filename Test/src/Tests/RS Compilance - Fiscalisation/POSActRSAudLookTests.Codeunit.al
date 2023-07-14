codeunit 85077 "NPR POS Act. RSAud.Look. Tests"
{
    Subtype = Test;

    var
        _Item: Record Item;
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _POSUnit: Record "NPR POS Unit";
        _Salesperson: Record "Salesperson/Purchaser";
        _Assert: Codeunit Assert;
        _POSSession: Codeunit "NPR POS Session";
        _Initialized: Boolean;

    [Test]
    [HandlerFunctions('AllowedTaxRatesUpdateConfirmHandler,AllowedTaxRatesUpdateMessageHandler,OpenModalPageHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OpenRSAuditLogPageWithAllFiscalisedParameter()
    var
        LibraryRSFiscal: Codeunit "NPR Library RS Fiscal";
        ParameterShow: Option All,AllFiscalised,AllNonFiscalised,LastTransaction;
        POSActionRSAuditLkpB: Codeunit "NPR POS Action: RSAudit Lkp-B";
    begin
        // [Scenario] Test action for opening RS Audit Log Info
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryRSFiscal);

        // [Given] POS and RS audit setup
        InitializeData();

        // [When] Ending normal cash sale
        DoItemSale();

        //[Then]
        POSActionRSAuditLkpB.ProcessRequest(ParameterShow::AllFiscalised);
        UnbindSubscription(LibraryRSFiscal);
    end;

    [Test]
    [HandlerFunctions('AllowedTaxRatesUpdateConfirmHandler,AllowedTaxRatesUpdateMessageHandler,OpenModalPageHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OpenRSAuditLogPageWithAllParameter()
    var
        LibraryRSFiscal: Codeunit "NPR Library RS Fiscal";
        POSActionRSAuditLkpB: Codeunit "NPR POS Action: RSAudit Lkp-B";
        ParameterShow: Option All,AllFiscalised,AllNonFiscalised,LastTransaction;
    begin
        // [Scenario] Test action for opening RS Audit Log Info
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryRSFiscal);

        // [Given] POS and RS audit setup
        InitializeData();

        // [When] Ending normal cash sale
        DoItemSale();

        //[Then]
        POSActionRSAuditLkpB.ProcessRequest(ParameterShow::All);
        UnbindSubscription(LibraryRSFiscal);
    end;

    [Test]
    [HandlerFunctions('AllowedTaxRatesUpdateConfirmHandler,AllowedTaxRatesUpdateMessageHandler,OpenModalPageHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OpenRSAuditLogPageWithAllNonFiscalisedParameter()
    var
        LibraryRSFiscal: Codeunit "NPR Library RS Fiscal";
        POSActionRSAuditLkpB: Codeunit "NPR POS Action: RSAudit Lkp-B";
        ParameterShow: Option All,AllFiscalised,AllNonFiscalised,LastTransaction;
    begin
        // [Scenario] Test action for opening RS Audit Log Info
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryRSFiscal);

        // [Given] POS and RS audit setup
        InitializeData();

        // [When] Ending normal cash sale
        DoItemSale();

        //[Then]
        POSActionRSAuditLkpB.ProcessRequest(ParameterShow::AllNonFiscalised);
        UnbindSubscription(LibraryRSFiscal);
    end;

    [Test]
    [HandlerFunctions('AllowedTaxRatesUpdateConfirmHandler,AllowedTaxRatesUpdateMessageHandler,OpenModalPageHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OpenRSAuditLogPageWithLastTransactionParameter()
    var
        LibraryRSFiscal: Codeunit "NPR Library RS Fiscal";
        POSActionRSAuditLkpB: Codeunit "NPR POS Action: RSAudit Lkp-B";
        ParameterShow: Option All,AllFiscalised,AllNonFiscalised,LastTransaction;
    begin
        // [Scenario] Test action for opening RS Audit Log Info
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryRSFiscal);

        // [Given] POS and RS audit setup
        InitializeData();

        // [When] Ending normal cash sale
        DoItemSale();

        //[Then]
        POSActionRSAuditLkpB.ProcessRequest(ParameterShow::LastTransaction);
        UnbindSubscription(LibraryRSFiscal);
    end;

    internal procedure InitializeData()
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        ObjectOutputSelection: Record "NPR Object Output Selection";
        POSAuditLog: Record "NPR POS Audit Log";
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSEndOfDayProfile: Record "NPR POS End of Day Profile";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSSetup: Record "NPR POS Setup";
        POSStore: Record "NPR POS Store";
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        TemplateHeader: Record "NPR RP Template Header";
        ReturnReason: Record "Return Reason";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryERM: Codeunit "Library - ERM";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryRPTemplate: Codeunit "NPR Library - RP Template Data";
        LibraryRSFiscal: Codeunit "NPR Library RS Fiscal";
        RSTaxCommunicationMgt: Codeunit "NPR RS Tax Communication Mgt.";
    begin
        if _Initialized then begin
            //Refresh Allowed Tax Rates
            RSTaxCommunicationMgt.PullAndFillAllowedTaxRates();
            //Clean any previous mock session
            _POSSession.ClearAll();
            Clear(_POSSession);
        end else begin
            NPRLibraryPOSMasterData.CreatePOSSetup(POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultVoucherType(VoucherType, false);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            POSPostingProfile."POS Period Register No. Series" := '';
            POSPostingProfile.Modify();
            NPRLibraryPOSMasterData.CreatePOSStore(POSStore, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(_POSUnit, POSStore.Code, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_POSPaymentMethod, _POSPaymentMethod."Processing Type"::CASH, '', false);
            NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(_Item, _POSUnit, POSStore);
            NPRLibraryPOSMasterData.CreateSalespersonForPOSUsage(_Salesperson);

            POSEndOfDayProfile.Code := 'EOD-TEST';
            POSEndOfDayProfile."Z-Report UI" := POSEndOfDayProfile."Z-Report UI"::BALANCING;
            POSEndOfDayProfile.Insert();

            _POSUnit."POS End of Day Profile" := POSEndOfDayProfile.Code;
            _POSUnit.Modify();

            LibraryERM.CreateReturnReasonCode(ReturnReason);
            _Item."Unit Price" := 10;
            _Item.Modify();

            VATPostingSetup.SetRange("VAT Prod. Posting Group", _Item."VAT Prod. Posting Group");
            VATPostingSetup.SetRange("VAT Bus. Posting Group", POSPostingProfile."VAT Bus. Posting Group");
            VATPostingSetup.SetFilter("VAT %", '<>%1', 0);
            VATPostingSetup.FindFirst();
            LibraryRSFiscal.CreateAuditProfileAndRSSetup(POSAuditProfile, VATPostingSetup, _POSUnit);

            ReportSelectionRetail.SetRange("Report Type", ReportSelectionRetail."Report Type"::"Sales Receipt (POS Entry)");
            ReportSelectionRetail.DeleteAll();
            ObjectOutputSelection.DeleteAll();

            LibraryRPTemplate.CreateDummySalesReceipt(TemplateHeader);
            LibraryRPTemplate.ConfigureReportSelection(ReportSelectionRetail."Report Type"::"Sales Receipt (POS Entry)", TemplateHeader);

            _Initialized := true;
        end;

        POSAuditLog.DeleteAll(true); //Clean in between tests
        Commit();
    end;

    local procedure DoItemSale(): Integer
    var
        POSEntry: Record "NPR POS Entry";
        POSSaleRecord: Record "NPR POS Sale";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleWrapper: Codeunit "NPR POS Sale";
    begin
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(POSSaleRecord);
        NPRLibraryPOSMock.CreateItemLine(_POSSession, _Item."No.", 1);
        if not (NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, _Item."Unit Price", '')) then
            Error('Sale did not end as expected');
        POSEntry.SetRange("Document No.", POSSaleRecord."Sales Ticket No.");
        POSEntry.FindFirst();
        _POSSession.ClearAll();
        Clear(_POSSession);
        exit(POSEntry."Entry No.");
    end;

    [ModalPageHandler]
    procedure OpenModalPageHandler(var RSPOSAuditLogAuxInfoPage: TestPage "NPR RS POS Audit Log Aux. Info")
    begin
        _Assert.IsTrue(true, 'Page opened.');
    end;

    [ConfirmHandler]
    procedure AllowedTaxRatesUpdateConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    var
        Assert: Codeunit Assert;
    begin
        Assert.ExpectedMessage('Allowed Tax Rates, VAT Posting Setup will be updated. Do you want to proceed?', Question);
        Reply := true;
    end;

    [MessageHandler]
    procedure AllowedTaxRatesUpdateMessageHandler(Msg: Text[1024])
    var
        Assert: Codeunit Assert;
    begin
        Assert.ExpectedMessage('Allowed Tax Rates have been updated.', Msg);
    end;
}