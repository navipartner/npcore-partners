codeunit 85007 "NPR POS Quote Tests"
{
    Subtype = Test;

    var
        _Initialized: Boolean;
        _POSUnit: Record "NPR POS Unit";
        _PaymentTypePOS: Record "NPR Payment Type POS";
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _POSSession: Codeunit "NPR POS Session";
        _POSStore: Record "NPR POS Store";
        _POSSetup: Record "NPR POS Setup";

    [Test]
    procedure POSQuote_SaveAndLoad()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalePOS: Record "NPR Sale POS";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR Sale Line POS";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
        POSActionSavePOSQuote: codeunit "NPR POS Action: SavePOSQuote";
        POSActionLoadPOSQuote: codeunit "NPR POS Action: Load POS Quote";
        POSQuoteEntry: Record "NPR POS Quote Entry";
        POSQuoteLine: Record "NPR POS Quote Line";
    begin
        // [Given] POS & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Item line worth 10 LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := 10;
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        POSSession.GetSale(POSSale);
        POSActionSavePOSQuote.CreatePOSQuote(SalePOS, POSQuoteEntry);

        POSQuoteLine.SetRange("Quote Entry No.", POSQuoteEntry."Entry No.");
        POSQuoteLine.FindFirst();

        _POSSession.Destructor();
        Clear(_POSSession);

        // Load POS Quote in the another POS session
        InitializeData();
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSActionLoadPOSQuote.LoadFromQuote(POSQuoteEntry, SalePOS);

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SalePOS.Date);
        SaleLinePOS.SetRange("Sale Type", SalePOS."Sale type");
        SaleLinePOS.FindFirst();
    end;

    [Test]
    procedure POSQuote_SaveAndLoadDiffDate()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalePOS: Record "NPR Sale POS";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR Sale Line POS";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
        POSActionSavePOSQuote: codeunit "NPR POS Action: SavePOSQuote";
        POSActionLoadPOSQuote: codeunit "NPR POS Action: Load POS Quote";
        POSQuoteEntry: Record "NPR POS Quote Entry";
        POSQuoteLine: Record "NPR POS Quote Line";
    begin
        //Switch to previous date to make a quote
        WorkDate(CalcDate('<-2D>', Today()));

        // [Given] POS & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Item line worth 10 LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := 10;
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        POSSession.GetSale(POSSale);
        POSActionSavePOSQuote.CreatePOSQuote(SalePOS, POSQuoteEntry);

        POSQuoteLine.SetRange("Quote Entry No.", POSQuoteEntry."Entry No.");
        POSQuoteLine.FindFirst();

        _POSSession.Destructor();
        Clear(_POSSession);

        // Load POS Quote in the another POS session

        //Switch to current date to restore a quote
        WorkDate(Today());

        InitializeData();
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSActionLoadPOSQuote.LoadFromQuote(POSQuoteEntry, SalePOS);

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SalePOS.Date);
        SaleLinePOS.SetRange("Sale Type", SalePOS."Sale type");
        SaleLinePOS.FindFirst();
    end;

    procedure InitializeData()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
    begin
        if _Initialized then begin
            //Clean any previous mock session
            _POSSession.Destructor();
            Clear(_POSSession);
        end;

        if not _Initialized then begin
            NPRLibraryPOSMasterData.CreatePOSSetup(_POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup();
            NPRLibraryPOSMasterData.CreatePOSStore(_POSStore);
            NPRLibraryPOSMasterData.CreatePOSUnit(_POSUnit, _POSStore.Code);
            NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_POSPaymentMethod, _POSPaymentMethod."Processing Type"::CASH, '', false);
            _Initialized := true;
        end;

        Commit;
    end;
}