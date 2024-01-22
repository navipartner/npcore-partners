codeunit 85075 "NPR POS Act. InsAddCusId Tests"
{
    Subtype = Test;

    var
        _POSUnit: Record "NPR POS Unit";
        _Assert: Codeunit Assert;
        _POSSession: Codeunit "NPR POS Session";
        _Initialized: Boolean;

    [Test]
    [HandlerFunctions('AllowedTaxRatesUpdateConfirmHandler,AllowedTaxRatesUpdateMessageHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure InsertAdditionalCustomerIdentification()
    var
        SalePOS: Record "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        RSPOSSale: Record "NPR RS POS Sale";
        NewDesc: Text;
    begin
        // [Scenario] Activate POS Session and add Customer Identification to it
        // [Given] POS & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [When] Add Customer identification
        AddCustomerIdentification(SalePOS, POSSale, NewDesc);

        // [Then] AdditionaCustomer identification is added to POS Sale
        POSSale.GetCurrentSale(SalePOS);
        RSPOSSale.Get(SalePOS.SystemId);
        _Assert.IsTrue(RSPOSSale."RS Add. Customer Field" = NewDesc, 'New Additional Customer Identification is not inserted.');
    end;

    internal procedure InitializeData()
    var
        Item: Record Item;
        VoucherType: Record "NPR NpRv Voucher Type";
        ObjectOutputSelection: Record "NPR Object Output Selection";
        POSAuditLog: Record "NPR POS Audit Log";
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSEndOfDayProfile: Record "NPR POS End of Day Profile";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSSetup: Record "NPR POS Setup";
        POSStore: Record "NPR POS Store";
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        TemplateHeader: Record "NPR RP Template Header";
        ReturnReason: Record "Return Reason";
        Salesperson: Record "Salesperson/Purchaser";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryERM: Codeunit "Library - ERM";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryRPTemplate: Codeunit "NPR Library - RP Template Data";
        LibraryRSFiscal: Codeunit "NPR Library RS Fiscal";
        RSTaxCommunicationMgt: Codeunit "NPR RS Tax Communication Mgt.";
    begin
        //Clean any previous mock session
        _POSSession.ClearAll();
        Clear(_POSSession);

        if _Initialized then begin
            //Refresh Allowed Tax Rates
            RSTaxCommunicationMgt.PullAndFillAllowedTaxRates();
        end else begin
            NPRLibraryPOSMasterData.CreatePOSSetup(POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultVoucherType(VoucherType, false);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            POSPostingProfile."POS Period Register No. Series" := '';
            POSPostingProfile.Modify();
            NPRLibraryPOSMasterData.CreatePOSStore(POSStore, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(_POSUnit, POSStore.Code, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);
            NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, POSStore);
            NPRLibraryPOSMasterData.CreateSalespersonForPOSUsage(Salesperson);

            POSEndOfDayProfile.Code := 'EOD-TEST';
            POSEndOfDayProfile."Z-Report UI" := POSEndOfDayProfile."Z-Report UI"::BALANCING;
            POSEndOfDayProfile.Insert();

            _POSUnit."POS End of Day Profile" := POSEndOfDayProfile.Code;
            _POSUnit.Modify();

            LibraryERM.CreateReturnReasonCode(ReturnReason);
            Item."Unit Price" := 10;
            Item.Modify();

            VATPostingSetup.SetRange("VAT Prod. Posting Group", Item."VAT Prod. Posting Group");
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

    local procedure AddCustomerIdentification(var SalePOS: Record "NPR POS Sale"; POSSale: Codeunit "NPR POS Sale"; var NewDesc: Text)
    var
        LibraryRandom: Codeunit "Library - Random";
        RSPOSSale: Record "NPR RS POS Sale";
    begin
        POSSale.GetCurrentSale(SalePOS);
        NewDesc := Format(LibraryRandom.RandIntInRange(111111111, 999999999));
        RSPOSSale."POS Sale SystemId" := SalePOS.SystemId;
        RSPOSSale."RS Add. Customer Field" := NewDesc;
        if not RSPOSSale.Insert() then
            RSPOSSale.Modify();
    end;

    [ConfirmHandler]
    procedure AllowedTaxRatesUpdateConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        _Assert.ExpectedMessage('Allowed Tax Rates, VAT Posting Setup will be updated. Do you want to proceed?', Question);
        Reply := true;
    end;

    [MessageHandler]
    procedure AllowedTaxRatesUpdateMessageHandler(Msg: Text[1024])
    begin
        _Assert.ExpectedMessage('Allowed Tax Rates have been updated.', Msg);
    end;
}