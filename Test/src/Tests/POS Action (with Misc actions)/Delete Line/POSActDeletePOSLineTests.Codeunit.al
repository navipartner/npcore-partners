codeunit 85110 "NPR POSAct:DeletePOSLine Tests"
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
    procedure DeleteLine()
    var
        Item: Record Item;
        POSSaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        ActionDeleteLine: Codeunit "NPR POSAct:Delete POS Line-B";
    begin
        // [SCENARIO]
        //Delete Line
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        POSSession.GetSaleLine(POSSaleLine);

        //[When]
        ActionDeleteLine.DeleteSaleLine(POSSaleLine);

        //[Then]
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        Assert.IsTrue(SaleLinePOS.IsEmpty, 'Line is not deleted.');
    end;
}