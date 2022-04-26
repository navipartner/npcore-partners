codeunit 85050 "NPR TM Performance Test"
{
    Subtype = Test;

    var
        _Initialized: Boolean;
        _POSUnit: Record "NPR POS Unit";
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _POSSession: Codeunit "NPR POS Session";
        _POSStore: Record "NPR POS Store";
        _POSSetup: Record "NPR POS Setup";

    [Test]
    procedure Create_10_Tickets_Warmup()
    var
    begin
        PosTickets_Create(10);
    end;

    [Test]
    procedure Create_10_Tickets()
    var
    begin
        PosTickets_Create(10);
    end;

    [Test]
    procedure EndSale_10_Tickets()
    var
    begin
        PosTickets_EndSale(10);
    end;

    [Test]
    procedure Cancel_10_Tickets()
    var
    begin
        PosTickets_Cancel(10, false);
    end;

    [Test]
    procedure Create_100_Tickets()
    var
    begin
        PosTickets_Create(100);
    end;

    [Test]
    procedure Cancel_100_Tickets()
    var
    begin
        PosTickets_Cancel(100, false);
    end;

    [Test]
    procedure EndSale_100_Tickets()
    var
    begin
        PosTickets_EndSale(100);
    end;


    [Test]
    procedure Create_1000_Tickets()
    var
    begin
        PosTickets_Create(1000);
    end;

    [Test]
    procedure EndSale_1000_Tickets()
    var
    begin
        PosTickets_EndSale(1000);
    end;

    [Test]
    procedure Cancel_1000_Tickets()
    var
    begin
        PosTickets_Cancel(1000, false);
    end;

    [Test]
    procedure Cancel_1000_Tickets_WithStats()
    var
    begin
        PosTickets_Cancel(1000, true);
    end;

    local procedure PosTickets_Create(TicketsToSell: Integer)
    var
        Assert: Codeunit "Assert";
        i: Integer;

        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalePOS: Record "NPR POS Sale";
        Item: Record Item;

        POSSale: Codeunit "NPR POS Sale";
        Ticket: Record "NPR TM Ticket";
        CountBefore, CountAfter : Integer;
        UnitPrice: Decimal;
    begin
        UnitPrice := 1.23;

        // [Given] Ticket, POS & Payment setup
        Item.Get(SelectSmokeTestScenario());
        InitializeData();
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        UpdateItemForPOSSaleUsage(Item, _POSUnit, _POSStore, UnitPrice, true);
        CountBefore := Ticket.Count();

        for i := 1 to TicketsToSell do
            NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        CountAfter := Ticket.Count();
        Assert.AreEqual(TicketsToSell, CountAfter - CountBefore, StrSubstNo('Number of tickets to be created must be %1.', TicketsToSell));

    end;

    local procedure PosTickets_Cancel(TicketsToSell: Integer; WithStatistics: Boolean)
    var
        Assert: Codeunit "Assert";
        i: Integer;

        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        TicketStats: Codeunit "NPR TM Ticket Access Stats";
        SalePOS: Record "NPR POS Sale";
        Item: Record Item;

        POSSale: Codeunit "NPR POS Sale";
        ActionCancelSale: Codeunit "NPR POSAction: Cancel Sale";
        Ticket: Record "NPR TM Ticket";
        CountBefore, CountAfter : Integer;
        UnitPrice: Decimal;
    begin
        UnitPrice := 1.23;

        // [Given] Ticket, POS & Payment setup
        Item.Get(SelectSmokeTestScenario());
        InitializeData();
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        UpdateItemForPOSSaleUsage(Item, _POSUnit, _POSStore, UnitPrice, true);
        CountBefore := Ticket.Count();

        if (WithStatistics) then
            TicketStats.BuildCompressedStatistics(Today, false);

        for i := 1 to TicketsToSell do
            NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        CountAfter := Ticket.Count();
        Assert.AreEqual(TicketsToSell, CountAfter - CountBefore, StrSubstNo('Number of tickets to be created must be %1.', TicketsToSell));

        if (WithStatistics) then
            TicketStats.BuildCompressedStatistics(Today, false);

        ActionCancelSale.CancelSale(_POSSession);

        CountAfter := Ticket.Count();
        Assert.AreEqual(0, CountAfter - CountBefore, StrSubstNo('Number of tickets after cancel sale must be %1.', 0));

    end;

    local procedure PosTickets_EndSale(TicketsToSell: Integer)
    var
        Assert: Codeunit "Assert";
        i: Integer;

        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalePOS: Record "NPR POS Sale";
        Item: Record Item;

        POSSale: Codeunit "NPR POS Sale";
        Ticket: Record "NPR TM Ticket";
        CountBefore, CountAfter : Integer;
        UnitPrice: Decimal;
    begin
        UnitPrice := 1.23;

        // [Given] Ticket, POS & Payment setup
        Item.Get(SelectSmokeTestScenario());
        InitializeData();
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        UpdateItemForPOSSaleUsage(Item, _POSUnit, _POSStore, UnitPrice, true);
        CountBefore := Ticket.Count();

        for i := 1 to TicketsToSell do
            NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        CountAfter := Ticket.Count();
        Assert.AreEqual(TicketsToSell, CountAfter - CountBefore, StrSubstNo('Number of tickets to be created must be %1.', TicketsToSell));

        if (not NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, UnitPrice * TicketsToSell, '')) then
            Error('Sale expected to end.');

    end;

    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;


    local procedure UpdateItemForPOSSaleUsage(var Item: Record Item; POSUnit: Record "NPR POS Unit"; POSStore: Record "NPR POS Store"; UnitPrice: Decimal; IncludesVat: Boolean)
    var
        LibraryRandom: Codeunit "Library - Random";
        LibraryInventory: Codeunit "Library - Inventory";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        POSStore.GetProfile(POSPostingProfile);
        Item.Validate("VAT Bus. Posting Gr. (Price)", POSPostingProfile."VAT Bus. Posting Group");

        Item."Price Includes VAT" := IncludesVat;
        Item."Unit Price" := UnitPrice;
        Item."Unit Cost" := LibraryRandom.RandDecInDecimalRange(0.01, UnitPrice, 1);
        Item.Modify();

        POSMasterData.CreatePostingSetupForSaleItem(Item, POSUnit, POSStore);
    end;


    [Normal]
    local procedure SelectSmokeTestScenario() ItemNo: Code[20]
    var
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
    begin
        ItemNo := TicketLibrary.CreateScenario_SmokeTest();
    end;


    procedure InitializeData()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
    begin
        if _Initialized then begin
            //Clean any previous mock session
            _POSSession.ClearAll();
            Clear(_POSSession);
        end;

        if not _Initialized then begin
            NPRLibraryPOSMasterData.CreatePOSSetup(_POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            NPRLibraryPOSMasterData.CreatePOSStore(_POSStore, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(_POSUnit, _POSStore.Code, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_POSPaymentMethod, _POSPaymentMethod."Processing Type"::CASH, '', false);
            _Initialized := true;
        end;

        Commit();
    end;

}