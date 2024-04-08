codeunit 85132 "NPR POS Act.Send Receipt Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";
        POSActionSendRcptB: Codeunit "NPR POS Action: Send Rcpt.-B";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SetLastReceipt()
    var
        POSEntry: Record "NPR POS Entry";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Item: Record Item;
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        OptionSetting: Option "Last Receipt","Choose Receipt";
        ReceiptListFilterOption: Option "None","POS Store","POS Unit",Salesperson;
        SelectionDialogType: Option TextField,List;
        PresetTableView: Text;
        ManualReceiptNo: Code[20];
        ObfuscationMethod: Option None,MI;
        SaleEnded: Boolean;
        SalesTicketNo: Code[20];
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalesTicketNo := SalePOS."Sales Ticket No.";
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Item."Unit Price" := 10;
        Item.Modify();
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        // Paying full amount so POS Sale is moved to POS Entry
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, 10, '');

        // Action parameters
        OptionSetting := OptionSetting::"Last Receipt";
        ReceiptListFilterOption := ReceiptListFilterOption::Salesperson;
        SelectionDialogType := SelectionDialogType::List;
        ObfuscationMethod := ObfuscationMethod::None;

        // [When] Set POS entry
        POSActionSendRcptB.SetReceipt(POSEntry, OptionSetting,
                                     ReceiptListFilterOption,
                                     PresetTableView,
                                     SelectionDialogType,
                                     ManualReceiptNo,
                                     ObfuscationMethod);

        Assert.IsTrue(POSEntry."Document No." = SalesTicketNo, 'Last Sale set');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('OpenPageHandler')]
    procedure ChooseReceipt()
    var
        POSEntry: Record "NPR POS Entry";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        OptionSetting: Option "Last Receipt","Choose Receipt";
        ReceiptListFilterOption: Option "None","POS Store","POS Unit",Salesperson;
        SelectionDialogType: Option TextField,List;
        PresetTableView: Text;
        ManualReceiptNo: Code[20];
        ObfuscationMethod: Option None,MI;
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        // Action parameters
        OptionSetting := OptionSetting::"Choose Receipt";
        ReceiptListFilterOption := ReceiptListFilterOption::Salesperson;
        SelectionDialogType := SelectionDialogType::List;
        ObfuscationMethod := ObfuscationMethod::None;
        // [When] No POS Entry
        asserterror POSActionSendRcptB.SetReceipt(POSEntry, OptionSetting,
                                    ReceiptListFilterOption,
                                    PresetTableView,
                                    SelectionDialogType,
                                    ManualReceiptNo,
                                    ObfuscationMethod);
        // [Then] POS Entries page must be opened

    end;

    [ModalPageHandler]
    procedure OpenPageHandler(var POSEntries: TestPage "NPR POS Entries")
    begin
        Assert.IsTrue(true, 'Page opened.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('SelectSecondOnPageHandler')]
    procedure ChooseAnotherReceipt()
    var
        POSEntry: Record "NPR POS Entry";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Item: Record Item;
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        OptionSetting: Option "Last Receipt","Choose Receipt";
        ReceiptListFilterOption: Option "None","POS Store","POS Unit",Salesperson;
        SelectionDialogType: Option TextField,List;
        PresetTableView: Text;
        ManualReceiptNo: Code[20];
        ObfuscationMethod: Option None,MI;
        SaleEnded: Boolean;
        SalesTicketNo: Code[20];
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalesTicketNo := SalePOS."Sales Ticket No.";

        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Item."Unit Price" := 10;
        Item.Modify();

        // [Given] First Sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);
        // [Given] Paying full amount so POS Sale is moved to POS Entry
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, 10, '');

        // [Given] Second Sale 
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);
        // [Given] Paying full amount so POS Sale is moved to POS Entry
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, 10, '');

        // Action parameters
        OptionSetting := OptionSetting::"Choose Receipt";
        ReceiptListFilterOption := ReceiptListFilterOption::Salesperson;
        SelectionDialogType := SelectionDialogType::List;
        ObfuscationMethod := ObfuscationMethod::None;

        // [When] Set POS entry
        POSActionSendRcptB.SetReceipt(POSEntry, OptionSetting,
                                     ReceiptListFilterOption,
                                     PresetTableView,
                                     SelectionDialogType,
                                     ManualReceiptNo,
                                     ObfuscationMethod);
        // [Then] POS Entries page must be opened and first Sale set
        Assert.IsTrue(POSEntry."Document No." = SalesTicketNo, 'First Sale set');
    end;

    [ModalPageHandler]
    procedure SelectSecondOnPageHandler(var POSEntries: TestPage "NPR POS Entries")
    begin
        POSEntries.First();
        POSEntries.Next();
        POSEntries.OK().Invoke();
    end;


}