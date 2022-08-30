codeunit 85069 "NPR POS Act. Change Amt. Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";

    [Test]
    procedure ChangeLineAmt()
    var
        Item: Record Item;
        POSSaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryRandom: Codeunit "Library - Random";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        NewLineAmount: Decimal;
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        NewLineAmount := LibraryRandom.RandDecInDecimalRange(0.01, Item."Unit Price", 1);

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        SaleLinePOS.Validate("Amount Including VAT", NewLineAmount);
        SaleLinePOS.Modify();

        Assert.IsTrue(SaleLinePOS."Line Amount" = NewLineAmount, 'Amount is changed.')
    end;

}