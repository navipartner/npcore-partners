codeunit 85109 "NPR POS Action: POS Info Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        LibraryRandom: Codeunit "Library - Random";
        POSStore: Record "NPR POS Store";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('POSInfoMessage')]
    procedure ApplyPOSInfoActionOnSaleLines()
    var
        Item: Record Item;
        Line: Record "NPR POS Sale Line";
        POSInfo: Record "NPR POS Info";
        POSInfoTransaction: Record "NPR POS Info Transaction";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
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
        POSInfo.Get('INVTEXT');
        ApplicationScope := ApplicationScope::"All Lines";
        ClearPOSInfo := false;
        POSActionBusinessLogic.OpenPOSInfoPage(POSInfo, POSSession, UserInputString, ApplicationScope, ClearPOSInfo);

        // [Then] Check if the all lines have applied POS Info transactions
        SaleLinePOS.SetRange("Register No.", POSUnit."No.");
        SaleLinePOS.SetRange("Date", WorkDate());
        if SaleLinePOS.Findset() then
            repeat
                POSInfoTransaction.SetRange("Register No.", POSUnit."No.");
                POSInfoTransaction.SetRange("Sales Line No.", SaleLinePOS."Line No.");
                POSInfoTransaction.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
                POSInfoTransaction.SetRange("Sale Date", WorkDate());
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