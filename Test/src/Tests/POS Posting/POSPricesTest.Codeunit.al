codeunit 85143 "NPR POS Prices Test"
{
    Subtype = Test;

    var
        _Initialized: Boolean;
        _POSUnit: Record "NPR POS Unit";
        _Customer: Record Customer;
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _POSSession: Codeunit "NPR POS Session";
        _POSStore: Record "NPR POS Store";
        _POSSetup: Record "NPR POS Setup";
        _Item: Record Item;
        _POSPrice, _CustomerPrice : Decimal;
        _PriceProfileLbl: Label 'PRICEPROFILE20230414', Locked = true;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TestPriceList()
    var
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalePOS: Record "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        POSSaleLine: Record "NPR POS Sale Line";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
    begin
        // [Scenario] Check that scanned item had correct prices without customer and with customer selected.

        // [Given] POS & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        NPRLibraryPOSMock.CreateItemLine(_POSSession, _Item."No.", 1);
        // [THEN] Verify POS Unit price
        _POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        Assert.AreEqual(_POSPrice, POSSaleLine."Amount Including VAT", 'POS Unit price not according to test scenario');

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, _Customer."No.", false);

        // [THEN] Verify customer price
        _POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        Assert.AreEqual(_CustomerPrice, POSSaleLine."Amount Including VAT", 'Customer price not according to test scenario');
    end;

    procedure InitializeData()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        //Clean any previous mock session
        _POSSession.ClearAll();
        Clear(_POSSession);

        if not _Initialized then begin
            NPRLibraryPOSMasterData.CreatePOSSetup(_POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            NPRLibraryPOSMasterData.CreatePOSStore(_POSStore, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePriceProfile(_PriceProfileLbl);
            NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(_Item, _POSUnit, _POSStore);
            NPRLibraryPOSMasterData.CreatePOSUnit(_POSUnit, _POSStore.Code, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_POSPaymentMethod, _POSPaymentMethod."Processing Type"::CASH, '', false);
            _POSUnit."POS Pricing Profile" := _PriceProfileLbl;
            _POSUnit.Modify();
            CreateCustomer();
            CreatePrices();
            _Initialized := true;
        end;

        Commit;
    end;

    local procedure CreateCustomer()
    var
        LibrarySales: Codeunit "Library - Sales";
        CustomerPriceGroup: Record "Customer Price Group";
    begin
        LibrarySales.CreateCustomer(_Customer);
        LibrarySales.CreateCustomerPriceGroup(CustomerPriceGroup);
        _Customer.Validate("Customer Price Group", CustomerPriceGroup.Code);
        _Customer.Validate("VAT Bus. Posting Group", _Item."VAT Bus. Posting Gr. (Price)");
        _Customer."Prices Including VAT" := true;
        _Customer.Modify();
    end;

    local procedure CreatePrices()
    var
        LibraryRandom: Codeunit "Library - Random";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        PriceSourceType: Enum "Price Source Type";
    begin
        _POSPrice := LibraryRandom.RandDecInRange(10, 1000, 2);
        _CustomerPrice := _POSPrice - LibraryRandom.RandDecInRange(0, 9, 2);
        NPRLibraryPOSMasterData.CreatePriceListLine(PriceSourceType::"NPR POS Price Profile", _PriceProfileLbl, _Item."No.", _POSPrice, _Customer."VAT Bus. Posting Group");
        NPRLibraryPOSMasterData.CreatePriceListLine(PriceSourceType::"Customer Price Group", _Customer."Customer Price Group", _Item."No.", _CustomerPrice, _Customer."VAT Bus. Posting Group");
    end;

    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: text; var Reply: Boolean)
    begin
        Reply := true;
    end;
}