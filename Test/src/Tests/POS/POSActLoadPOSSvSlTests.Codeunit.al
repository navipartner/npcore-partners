codeunit 85086 "NPR POS ActLoadPOSSvSl Tests"
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
    procedure TestLoadFromQuote()
    var
        POSActGetParkedSaleB: Codeunit "NPR POS Action: LoadPOSSvSl B";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Item: Record Item;
        POSActSaveSale: Codeunit "NPR POS Action: SavePOSSvSl B";
        POSQuoteEntry: Record "NPR POS Saved Sale Entry";
        SalePOS: Record "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";

    begin

        InitializeData();

        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        NPRLibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        POSActSaveSale.CreatePOSQuoteAndStartNewSale(POSSession, POSQuoteEntry);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        POSActGetParkedSaleB.LoadFromQuote(POSQuoteEntry, SalePOS);

        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("No.", Item."No.");
        SaleLinePOS.SetRange(Quantity, 1);

        Assert.IsTrue(SaleLinePOS.FindFirst(), 'Parked Sale Inserted');
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