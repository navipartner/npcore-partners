codeunit 85060 "NPR POS Act. Transfer Ord Test"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Initialized: Boolean;
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";

    [Test]
    [HandlerFunctions('OpenTransferOrder')]
    procedure InsertTransferOrder()
    var
        POSActionBusinessLogic: Codeunit "NPR POS Action Transfer Order";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryRandom: Codeunit "Library - Random";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";

        POSParameterValue: Record "NPR POS Parameter Value";
        POSMenuButton: Record "NPR POS Menu Button";

        TransferHeader: Record "Transfer Header";
        Location: Record Location;
        ExistingRecords: Integer;
        UpdateExistingRecords: Integer;
    begin
        //initialize POS
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        POSMenuButton.SetRange("Action Code", 'TRANSFER_ORDER');
        if POSMenuButton.FindFirst() then;
        if POSParameterValue.Get(DATABASE::"NPR POS Menu Button", POSMenuButton."Menu Code", POSMenuButton.ID, POSMenuButton.RecordId, 'DefaultTransferToCode') then;

        //count existing 
        TransferHeader.SetRange("Transfer-from Code", POSStore."Location Code");
        TransferHeader.SetRange("Shortcut Dimension 1 Code", POSUnit."Global Dimension 1 Code");
        if Location.Get(CopyStr(POSParameterValue.Value, 1, MaxStrLen(Location.Code))) then
            if not Location."Use As In-Transit" and (TransferHeader."Transfer-from Code" <> Location.Code) then
                TransferHeader.SetRange("Transfer-to Code", POSParameterValue.Value);
        ExistingRecords := TransferHeader.count;
        POSActionBusinessLogic.CreateTransferOrder(POSStore, POSUnit, POSParameterValue.Value);

        //count updated
        UpdateExistingRecords := TransferHeader.Count;

        Assert.IsTrue(ExistingRecords + 1 = UpdateExistingRecords, 'New Transfer Order is created');

    end;

    [PageHandler]
    procedure OpenTransferOrder(var TransferOrderCard: Page "Transfer Order")
    var
    begin
        TransferOrderCard.Close();
    end;
}
