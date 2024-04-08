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
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('OpenTransferOrder')]
    procedure InsertTransferOrder()
    var
        POSActionBusinessLogic: Codeunit "NPR POS Action Transfer Order";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";

        POSParameterValue: Record "NPR POS Parameter Value";

        TransferHeader: Record "Transfer Header";
        Location: Record Location;
        ExistingRecords: Integer;
        UpdateExistingRecords: Integer;
    begin
        // [Given]
        //initialize POS
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        //count existing 
        TransferHeader.SetRange("Transfer-from Code", POSStore."Location Code");
        TransferHeader.SetRange("Shortcut Dimension 1 Code", POSUnit."Global Dimension 1 Code");
        if Location.Get(CopyStr(POSParameterValue.Value, 1, MaxStrLen(Location.Code))) then
            if not Location."Use As In-Transit" and (TransferHeader."Transfer-from Code" <> Location.Code) then
                TransferHeader.SetRange("Transfer-to Code", POSParameterValue.Value);
        ExistingRecords := TransferHeader.count;
        // [When]
        POSActionBusinessLogic.CreateTransferOrder(POSStore, POSUnit, POSParameterValue.Value);
        // [Then]
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
