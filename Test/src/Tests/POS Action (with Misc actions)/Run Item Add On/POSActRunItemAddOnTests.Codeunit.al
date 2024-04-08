codeunit 85140 "NPR POS Act. RunItemAddOnTests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AddItemAddOn()
    var
        Item: Record Item;
        POSSaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSActionBusinessLogic: Codeunit "NPR POS Action: RunItemAddOn B";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        ItemAddOnNo: code[20];
        UserSelectionJToken: JsonToken;
        POSActionInsertItem: Codeunit "NPR POS Action: Insert Item B";
        FrontEnd: Codeunit "NPR POS Front End Management";
        ItemReference: Record "Item Reference";
        BaseLineNo: Integer;
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        POSActionInsertItem.AddItemLine(Item, ItemReference, 0, 1, 0, '', '', '', POSSession, FrontEnd, '');
        BaseLineNo := POSActionInsertItem.GetLineNo;
        ItemAddOnNo := CreateItemAddOnTypeQuantity(Item);

        POSSale.GetCurrentSale(SalePOS);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);


        POSActionBusinessLogic.RunItemAddOns(BaseLineNo,
                                            ItemAddOnNo,
                                            false,
                                            true,
                                            false,
                                            UserSelectionJToken);

        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("No.", ItemAddOnLine."Item No.");

        Assert.IsTrue(SaleLinePOS.FindFirst(), 'Item Inserted');
        Assert.IsTrue(SaleLinePOS.Quantity = 2, 'Quantity inserted');
    end;

    local procedure CreateItemAddOnTypeQuantity(var Item: Record Item) ItemAddOnNo: Code[20]
    var
        ItemAddOn: Record "NPR NpIa Item AddOn";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        ItemForAddOn: Record Item;
        LibraryRandom: Codeunit "Library - Random";
    begin
        ItemAddOn.Init();
        ItemAddOn.Validate("No.", LibraryRandom.RandText(20));
        ItemAddOn.Enabled := true;
        ItemAddOn.Insert(true);

        ItemAddOnNo := ItemAddOn."No.";

        ItemAddOnLine.Init();
        ItemAddOnLine.Validate("AddOn No.", ItemAddOn."No.");
        ItemAddOnLine.Validate("Line No.", 10000);
        ItemAddOnLine.Validate(Type, ItemAddOnLine.Type::Quantity);
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(ItemForAddOn, POSUnit, POSStore);
        ItemAddOnLine.Validate("Item No.", ItemForAddOn."No.");
        ItemAddOnLine.Validate(Quantity, 2);
        ItemAddOnLine.Validate("Fixed Quantity", true);
        ItemAddOnLine.Validate(Mandatory, true);
        ItemAddOnLine.Insert(true);

        Item.Validate("NPR Item AddOn No.", ItemAddOn."No.");
        Item.Modify();
    end;
}