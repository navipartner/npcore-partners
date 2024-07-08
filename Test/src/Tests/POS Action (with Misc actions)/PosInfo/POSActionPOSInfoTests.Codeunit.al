codeunit 85109 "NPR POS Action: POS Info Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('POSInfoMessage')]
    procedure ApplyPOSInfoActionOnSaleLines()
    var
        Item: Record Item;
        POSInfo: Record "NPR POS Info";
        POSInfoTransaction: Record "NPR POS Info Transaction";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSActionBusinessLogic: Codeunit "NPR POS Action: POS Info-B";
        ApplicationScope: Option " ","Current Line","All Lines","New Lines","Ask";
        i: Integer;
        ClearPOSInfo: Boolean;
        UserInputString: Text;
    begin
        //[Scenario] Apply POS info action on a sigle line in multiple lines POS Sale and check the result.

        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        NPRLibraryPOSMasterData.CreatePOSInfo('INVTEXT', POSInfo."Input Type"::Text, POSInfo.Type::"Show Message", 'This Action works OK!');

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        // [Given] Create three POS Sale lines
        for i := 1 to 3 do begin
            NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
            LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);
        end;

        // [When] Apply POS info action on single line
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        POSInfo.Get('INVTEXT');
        ApplicationScope := ApplicationScope::"All Lines";
        ClearPOSInfo := false;
        POSActionBusinessLogic.OpenPOSInfoPage(SalePOS, SaleLinePOS, POSInfo, UserInputString, ApplicationScope, ClearPOSInfo);

        // [Then] Check if the all lines have applied POS Info transactions
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if SaleLinePOS.Findset() then
            repeat
                POSInfoTransaction.SetRange("POS Info Code", POSInfo.Code);
                POSInfoTransaction.SetRange("Register No.", SaleLinePOS."Register No.");
                POSInfoTransaction.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
                POSInfoTransaction.SetRange("Sales Line No.", SaleLinePOS."Line No.");
                POSInfoTransaction.FindFirst();
                Assert.AreEqual(POSInfoTransaction."POS Info Code", 'INVTEXT', 'ApplyPOSInfoActionOnSaleLines');
            until SaleLinePOS.Next() = 0;
    end;

    [MessageHandler]
    procedure POSInfoMessage(Message: Text[1024])
    var
        POSInfoMessage: Label 'This Action works OK!';
    begin
        Assert.AreEqual(Message, POSInfoMessage, 'MessageHandler');
    end;
}