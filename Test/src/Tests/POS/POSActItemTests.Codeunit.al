codeunit 85085 "NPR POS Act. Item Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Quantity: Decimal;
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";
        POSSetup: Record "NPR POS Setup";

    [Test]
    procedure AddSalesLine()
    var
        Item: Record Item;
        POSSaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryRandom: Codeunit "Library - Random";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        ItemReference: Record "Item Reference";
        ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference;
        ItemQuantity: Decimal;
        UnitPrice: Decimal;
        CustomDescription: Text;
        CustomDescription2: Text;
        InputSerial: Text;
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
    begin
        // [Given] POS & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);

        ItemIdentifierType := ItemIdentifierType::ItemNo;
        Quantity := 1;
        UnitPrice := LibraryRandom.RandDec(100, 4);
        CustomDescription := LibraryRandom.RandText(50);
        CustomDescription2 := LibraryRandom.RandText(30);

        LibraryPOSMock.CreateItemLine(POSSession,
                                    Item,
                                    ItemReference,
                                    ItemIdentifierType,
                                    ItemQuantity,
                                    UnitPrice,
                                    CustomDescription,
                                    CustomDescription2,
                                    InputSerial);

        POSSale.GetCurrentSale(SalePOS);

        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if SaleLinePOS.FindFirst() then;

        Assert.IsTrue(SaleLinePOS."No." = Item."No.", 'Item Inserted');
        Assert.IsTrue(SaleLinePOS.Quantity = Quantity, 'Quantity Inserted');
        Assert.IsTrue(SaleLinePOS."Unit Price" = UnitPrice, 'Unit Price Inserted');
        Assert.IsTrue(SaleLinePOS.Description = CustomDescription, 'New description inserted');
        Assert.IsTrue(SaleLinePOS."Description 2" = CustomDescription2, 'New description 2 inserted');
    end;

    procedure InitializeData()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
    begin
        if Initialized then begin
            //Clean any previous mock session
            POSSession.ClearAll();
            Clear(POSSession);
        end;

        if not Initialized then begin
            NPRLibraryPOSMasterData.CreatePOSSetup(POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            NPRLibraryPOSMasterData.CreatePOSStore(POSStore, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(POSUnit, POSStore.Code, POSPostingProfile.Code);
            Initialized := true;
        end;

        Commit();
    end;

}