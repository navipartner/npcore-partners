codeunit 85049 "NPR POS Act. Adjust Inv. Tests"
{
    Subtype = Test;

    trigger OnRun()
    begin

    end;

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
    [HandlerFunctions('ConfirmYesHandler,ClickOnOKMsg')]
    procedure AdjustInventory()
    var
        Item: Record Item;
        POSSaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryRandom: Codeunit "Library - Random";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSActionBusinessLogic: Codeunit "NPR POS Action: Adjust Inv. B";
        ItemNo: Code[20];
        ReasonCode: Code[10];
    begin
        // [Given] POS & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        ItemNo := Item."No.";
        LibraryPOSMock.CreateItemLine(POSSession, ItemNo, Quantity);

        POSSession.GetSaleLine(POSSaleLine);
        Quantity := LibraryRandom.RandDec(100, 4);

        POSActionBusinessLogic.PerformAdjustInventory(POSSale, POSSaleLine, Quantity, ReasonCode);

        Item.Get(ItemNo);
        Item.CalcFields(Inventory);
        Assert.IsTrue(Item.Inventory = Quantity, 'Inventory Inserted');
    end;

    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure ClickOnOKMsg(Msg: Text[1024])
    var
        Text005: Label 'Adjust Quantity %1 performed';
    begin
        Assert.IsTrue(Msg = StrSubstNo(Text005, Quantity), Msg);
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