codeunit 85026 "NPR POS Resume Tests"
{
    // [Feature] Test that POS resume sale works when logging in.
    Subtype = Test;

    var
        _Initialized: Boolean;
        _POSUnit: Record "NPR POS Unit";
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _POSSession: Codeunit "NPR POS Session";
        _POSStore: Record "NPR POS Store";
        _POSSetup: Record "NPR POS Setup";

    [Test]
    [HandlerFunctions('ResumeDialogHandler')]
    procedure CrashAndResume()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
        POSActionSavePOSQuote: codeunit "NPR POS Action: SavePOSSvSl";
        POSActionLoadPOSQuote: codeunit "NPR POS Action: LoadPOSSvSl";
        POSQuoteEntry: Record "NPR POS Saved Sale Entry";
        POSQuoteLine: Record "NPR POS Saved Sale Line";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        POSSetup: Codeunit "NPR POS Setup";
        PreviousSaleSystemId: Guid;
        PreviousSaleLineSystemId: Guid;
        PreviousSalesTicketNo: Text;
        POSActionLogin: Codeunit "NPR POS Action - Login";
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
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.FindFirst();
        PreviousSaleLineSystemId := SaleLinePOS.SystemId;
        PreviousSaleSystemId := SalePOS.SystemId;
        PreviousSalesTicketNo := SalePOS."Sales Ticket No.";

        // [Given] A crashed session when a sale was active
        _POSSession.ClearAll();
        Clear(_POSSession);

        // [When] Using the login action to enter a new sale and confirming the prompt to resume previous sale
        InitializeData();
        NPRLibraryPOSMock.InitializePOSSession(_POSSession, _POSUnit);
        _POSSession.GetFrontEnd(POSFrontEnd, true);
        _POSSession.GetSetup(POSSetup);
        POSActionLogin.StartPOS(_POSSession);

        // [Then] Correct data is resumed
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.TestField("Sales Ticket No.", PreviousSalesTicketNo);
        SalePOS.TestField(SystemId, PreviousSaleSystemId);
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.FindFirst();
        SaleLinePOS.TestField(SystemId, PreviousSaleLineSystemId);
        SaleLinePOS.TestField("No.", Item."No.");
        SaleLinePOS.TestField("Unit Price", Item."Unit Price");
    end;

    procedure InitializeData()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        POSEndOfDayTests: Codeunit "NPR POS End of Day";
        POSUnitNo: Text;
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

        Commit;
    end;

    [ModalPageHandler]
    procedure ResumeDialogHandler(var UnfinishedPOSSalePage: Page "NPR Unfinished POS Sale"; var ActionResponse: Action)
    var
    begin
        ActionResponse := Action::Yes;
    end;
}