codeunit 85078 "NPR POS Doc.Pay&Post Tests"
{
    Subtype = Test;

    var
        Item: Record Item;
        POSPaymentMethodCash: Record "NPR POS Payment Method";
        POSSetup: Record "NPR POS Setup";
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        Assert: Codeunit Assert;
        POSActionDocPayPostB: Codeunit "NPR POS Action: Doc.Pay&Post B";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSession: Codeunit "NPR POS Session";
        Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('SelectFromCustomerListPageHandler')]
    internal procedure CheckCustomer()
    var
        SalePOS: Record "NPR POS Sale";
        Customer: Record Customer;
        POSSale: Codeunit "NPR POS Sale";
        SelectCustomer: Boolean;
    begin
        // [Scenario]
        // [Given]
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        // parameters
        SelectCustomer := true;
        // [When]
        POSActionDocPayPostB.CheckCustomer(SalePOS, POSSale, SelectCustomer);
        // [Then]
        Customer.FindFirst();
        Assert.IsTrue(SalePOS."Customer No." = Customer."No.", 'Customer added to sale');
    end;

    [ModalPageHandler]
    procedure SelectFromCustomerListPageHandler(var CustomerLookup: TestPage "Customer Lookup")
    begin
        CustomerLookup.First();
        CustomerLookup.OK().Invoke();
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('SelectDocumentPageHandler')]
    internal procedure SelectDocumentIntoPOS()
    var
        SalePOS: Record "NPR POS Sale";
        Customer: Record Customer;
        POSSale: Codeunit "NPR POS Sale";
        SalesHeader: Record "Sales Header";
        NewSalesHeader: Record "Sales Header";
        LibrarySales: Codeunit "Library - Sales";
        SaleLinePOS: Codeunit "NPR POS Sale Line";
        POSSaleLine: Record "NPR POS Sale Line";
        POSSalesDocumentPost: Enum "NPR POS Sales Document Post";
    begin
        // [Scenario] Select order from list and import to POS
        // [Given]
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        POSSale.GetCurrentSale(SalePOS);
        POSSalesDocumentPost := POSSalesDocumentPost::No;
        // [When]
        POSActionDocPayPostB.SelectDocument(SalePOS, NewSalesHeader);
        POSActionDocPayPostB.CreateDocumentPaymentLine(POSSession, NewSalesHeader, false, false, false, POSSalesDocumentPost);
        // [Then]
        POSSession.GetSaleLine(SaleLinePOS);
        SaleLinePOS.GetCurrentSaleLine(POSSaleLine);
        Assert.IsTrue(POSSaleLine."Sales Document No." = NewSalesHeader."No.", 'Order No. added to sale');
        Assert.IsTrue(POSSaleLine."Sales Document Type" = NewSalesHeader."Document Type"::Order, 'Order Type added to sale');
    end;

    [ModalPageHandler]
    procedure SelectDocumentPageHandler(var SalesList: TestPage "Sales List")
    begin
        SalesList.First();
        SalesList.OK().Invoke();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure MarkLinesForPostingErr()
    var
        SalePOS: Record "NPR POS Sale";
        Customer: Record Customer;
        POSSale: Codeunit "NPR POS Sale";
        SalesHeader: Record "Sales Header";
        LibrarySales: Codeunit "Library - Sales";
        AutoQtyOpt: Option Disabled,None,All;
        ExpectedErrMsg: Text;
        NoLinesErr: Label 'Selected Document %1 has no lines.', Comment = '%1 = Sales Header No.';
    begin
        // [Scenario] Select order without lines and try import to POS
        // [Given]
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        POSSale.GetCurrentSale(SalePOS);
        // [When]
        asserterror POSActionDocPayPostB.SetLinesToPost(SalesHeader, AutoQtyOpt::All, AutoQtyOpt::Disabled, AutoQtyOpt::Disabled);
        // [Then]
        ExpectedErrMsg := StrSubstNo(NoLinesErr, SalesHeader."No.");
        Assert.IsTrue(GetLastErrorText() = ExpectedErrMsg, 'Selected Document has no lines');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure MarkLinesForPosting()
    var
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LibrarySales: Codeunit "Library - Sales";
        AutoQtyOpt: Option Disabled,None,All;
    begin
        // [Scenario] Set "Qty. to Ship" only
        // [Given]
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        LibrarySales.CreateSalesOrder(SalesHeader); //Sales Order With with one line
        POSSale.GetCurrentSale(SalePOS);
        // [When]
        POSActionDocPayPostB.SetLinesToPost(SalesHeader, AutoQtyOpt::None, AutoQtyOpt::All, AutoQtyOpt::Disabled);
        // [Then]
        SalesLine.Get(SalesHeader."Document Type", SalesHeader."No.", 10000);
        Assert.AreEqual(SalesLine.Quantity, SalesLine."Qty. to Ship", 'Qty. to Ship Set');
        Assert.AreEqual(SalesLine."Qty. to Invoice", 0, 'Qty. to Invoice set to 0');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure CreateDocumentAndPost()
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LibrarySales: Codeunit "Library - Sales";
        AutoQtyOpt: Option Disabled,None,All;
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
        POSSalesDocumentPost: Enum "NPR POS Sales Document Post";
    begin
        // [Scenario] Create document and post it
        // [Given]
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        LibrarySales.CreateSalesOrder(SalesHeader); //Sales Order With with one line
        POSSale.GetCurrentSale(SalePOS);
        POSSalesDocumentPost := POSSalesDocumentPost::Synchronous;
        // [When]
        POSActionDocPayPostB.SetLinesToPost(SalesHeader, AutoQtyOpt::All, AutoQtyOpt::All, AutoQtyOpt::Disabled);
        POSActionDocPayPostB.CreateDocumentPaymentLine(POSSession, SalesHeader, false, false, false, POSSalesDocumentPost);
        // [Then]
        SalesLine.Get(SalesHeader."Document Type", SalesHeader."No.", 10000);
        Assert.AreEqual(SalesLine.Quantity, SalesLine."Qty. to Invoice", 'Qty. to Invoice Set');
        Assert.AreEqual(SalesLine.Quantity, SalesLine."Qty. to Ship", 'Qty. to Ship Set');

        // [Then] Order is imported 
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        Assert.IsTrue(SaleLinePOS."Sales Document No." = SalesHeader."No.", 'Order is imported in POS');
        Assert.IsTrue(SaleLinePOS."Sales Document Invoice" = true, 'Order marked for invoicing');
        Assert.IsTrue(SaleLinePOS."Sales Document Ship" = true, 'Order marked for shipping');
        Assert.IsTrue(SaleLinePOS."Sales Document Receive" = false, 'Order not marked for receiving');

        // [Then] End Sale
        SalesHeader.CalcFields("Amount Including VAT");
        SaleEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethodCash.Code, SalesHeader."Amount Including VAT", '');

        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();

        POSEntrySalesDocLink.SetRange("POS Entry No.", POSEntry."Entry No.");
        // Posted invoice
        POSEntrySalesDocLink.SetRange("Sales Document Type", POSEntrySalesDocLink."Sales Document Type"::POSTED_INVOICE);
        Assert.IsTrue(POSEntrySalesDocLink.FindFirst(), 'Posted Invoice');
        // Posted shipment
        POSEntrySalesDocLink.SetRange("Sales Document Type", POSEntrySalesDocLink."Sales Document Type"::SHIPMENT);
        Assert.IsTrue(POSEntrySalesDocLink.FindFirst(), 'Posted Shipment');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure CreateDocumentWithoutPosting()
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LibrarySales: Codeunit "Library - Sales";
        AutoQtyOpt: Option Disabled,None,All;
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
        POSSalesDocumentPost: Enum "NPR POS Sales Document Post";
    begin
        // [Scenario] Create document and finish sale
        // [Given]
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        LibrarySales.CreateSalesOrder(SalesHeader); //Sales Order With with one line
        POSSale.GetCurrentSale(SalePOS);
        POSSalesDocumentPost := POSSalesDocumentPost::Asynchronous;
        // [When]
        POSActionDocPayPostB.SetLinesToPost(SalesHeader, AutoQtyOpt::None, AutoQtyOpt::None, AutoQtyOpt::None);
        POSActionDocPayPostB.CreateDocumentPaymentLine(POSSession, SalesHeader, false, false, false, POSSalesDocumentPost);
        // [Then]
        SalesLine.Get(SalesHeader."Document Type", SalesHeader."No.", 10000);
        Assert.AreEqual(SalesLine."Qty. to Invoice", 0, 'Qty. to Invoice 0');
        Assert.AreEqual(SalesLine."Qty. to Ship", 0, 'Qty. to Ship 0');

        // [Then] Order is imported 
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        Assert.IsTrue(SaleLinePOS."Sales Document No." = SalesHeader."No.", 'Order is imported in POS');
        Assert.IsTrue(SaleLinePOS."Sales Document Invoice" = false, 'Order not marked for invoicing');
        Assert.IsTrue(SaleLinePOS."Sales Document Ship" = false, 'Order not marked for shipping');
        Assert.IsTrue(SaleLinePOS."Sales Document Receive" = false, 'Order not marked for receiving');

        // [Then] End Sale
        SalesHeader.CalcFields("Amount Including VAT");
        SaleEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethodCash.Code, SalesHeader."Amount Including VAT", '');

        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();

        POSEntrySalesDocLink.SetRange("POS Entry No.", POSEntry."Entry No.");
        // Posted invoice
        POSEntrySalesDocLink.SetRange("Sales Document Type", POSEntrySalesDocLink."Sales Document Type"::POSTED_INVOICE);
        Assert.IsFalse(POSEntrySalesDocLink.FindFirst(), 'No Invoice is posted');
        // Posted shipment
        POSEntrySalesDocLink.SetRange("Sales Document Type", POSEntrySalesDocLink."Sales Document Type"::SHIPMENT);
        Assert.IsFalse(POSEntrySalesDocLink.FindFirst(), 'No Shipment is posted');
        // Only order
        POSEntrySalesDocLink.SetRange("Sales Document Type", POSEntrySalesDocLink."Sales Document Type"::ORDER);
        Assert.IsTrue(POSEntrySalesDocLink.FindFirst(), 'Order is created');

    end;

    internal procedure Initialize()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        if Initialized then begin
            //Clean any previous mock session
            POSSession.ClearAll();
            Clear(POSSession);
        end;

        if not Initialized then begin
            NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
            NPRLibraryPOSMasterData.CreatePOSSetup(POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            NPRLibraryPOSMasterData.CreatePOSStore(POSStore, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(POSUnit, POSStore.Code, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethodCash, POSPaymentMethodCash."Processing Type"::CASH, '', false);

            Initialized := true;
        end;

        Commit();
    end;


}
