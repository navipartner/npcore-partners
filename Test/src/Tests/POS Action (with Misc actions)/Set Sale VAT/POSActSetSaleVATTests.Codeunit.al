codeunit 85116 "NPR POS Act. Set SaleVAT Tests"
{
    Subtype = Test;

    var
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        Assert: Codeunit Assert;
        POSSession: Codeunit "NPR POS Session";
        Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ChangeSaleVATBusPostingGroup()
    var
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRPOSSetSaleVATB: Codeunit "NPR POS Action-Set Sale VAT-B.";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        LibraryERM.CreateVATPostingSetupWithAccounts(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT", LibraryRandom.RandDecInDecimalRange(10, 25, 0));
        LibraryERM.CreateGenBusPostingGroup(GenBusinessPostingGroup);
        NPRLibraryPOSMasterData.CreateVATPostingSetupForSaleItem(VATPostingSetup."VAT Bus. Posting Group", Item."VAT Prod. Posting Group");

        // [WHEN]
        POSSession.GetSaleLine(POSSaleLine);
        NPRPOSSetSaleVATB.ChangeSaleVATBusPostingGroup(POSSale, POSSaleLine, GenBusinessPostingGroup.Code, VATPostingSetup."VAT Bus. Posting Group", false);

        // [THEN]
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        Assert.IsTrue(SaleLinePOS."VAT Bus. Posting Group" = VATPostingSetup."VAT Bus. Posting Group", 'VAT Bus. Posting Group is not changed.');
        Assert.IsTrue(SaleLinePOS."Gen. Bus. Posting Group" = GenBusinessPostingGroup.Code, 'Gen. Bus. Posting Group is not changed.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ChangeSaleVATBusPostingGroupRecalculatesCustomPrice()
    var
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        NewVATPostingSetup: Record "VAT Posting Setup";
        ItemVATPostingSetup: Record "VAT Posting Setup";
        LibraryERM: Codeunit "Library - ERM";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRPOSSetSaleVATB: Codeunit "NPR POS Action-Set Sale VAT-B.";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        OldVATPct: Decimal;
        NewVATPct: Decimal;
        KnownUnitPrice: Decimal;
        ExpectedUnitPrice: Decimal;
    begin
        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        // [GIVEN] Item with a known unit price (125.00) under VAT rate A (25%)
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        OldVATPct := 25; // fixed in CreateVATPostingSetupForSaleItem
        KnownUnitPrice := 125;
        Item."Unit Price" := KnownUnitPrice;
        Item.Modify();
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        // [GIVEN] Sale line is marked as Custom Price
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLinePOS."Custom Price" := true;
        SaleLinePOS.Modify();

        // [GIVEN] New VAT Bus. Posting Group with VAT rate B (10%) for this item's VAT Prod. Posting Group
        NewVATPct := 10;
        LibraryERM.CreateVATPostingSetupWithAccounts(NewVATPostingSetup, NewVATPostingSetup."VAT Calculation Type"::"Normal VAT", NewVATPct);
        LibraryERM.CreateVATPostingSetup(ItemVATPostingSetup, NewVATPostingSetup."VAT Bus. Posting Group", Item."VAT Prod. Posting Group");
        ItemVATPostingSetup."VAT %" := NewVATPct;
        ItemVATPostingSetup."VAT Calculation Type" := ItemVATPostingSetup."VAT Calculation Type"::"Normal VAT";
        ItemVATPostingSetup.Validate("Sales VAT Account", LibraryERM.CreateGLAccountNo());
        ItemVATPostingSetup.Validate("Purchase VAT Account", LibraryERM.CreateGLAccountNo());
        ItemVATPostingSetup.Modify();

        // [WHEN] VAT Bus. Posting Group is changed to rate B
        NPRPOSSetSaleVATB.ChangeSaleVATBusPostingGroup(POSSale, POSSaleLine, '', NewVATPostingSetup."VAT Bus. Posting Group", false);

        // [THEN] Unit Price is recalculated: OldPrice * (100 + NewVAT%) / (100 + OldVAT%)
        ExpectedUnitPrice := Round(KnownUnitPrice * (100 + NewVATPct) / (100 + OldVATPct), 0.00001);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        Assert.AreNearlyEqual(ExpectedUnitPrice, SaleLinePOS."Unit Price", 0.01, 'Unit Price was not recalculated correctly after VAT rate change.');
    end;
}