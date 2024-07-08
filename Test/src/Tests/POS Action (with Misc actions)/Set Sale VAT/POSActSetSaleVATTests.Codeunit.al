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

}