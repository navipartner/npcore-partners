codeunit 85094 "NPR POS Sales Doc Show Tests"
{
    Subtype = Test;

    var
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        SalesHeader: Record "Sales Header";
        Assert: Codeunit Assert;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSActionDocShowB: Codeunit "NPR POS Action: Doc. Show-B";
        POSSession: Codeunit "NPR POS Session";
        Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('SelectFromCustomerListPageHandler')]
    internal procedure CheckCustomer()
    var
        Customer: Record Customer;
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        SelectCustomer: Boolean;
    begin
        // [Scenario]
        // [Given]
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        // parameters
        SelectCustomer := true;
        // [When]
        POSActionDocShowB.CheckCustomer(SalePOS, SelectCustomer);
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
    [HandlerFunctions('OpenSalesOrderListPageHandler,OpenSalesOrderPageHandler')]
    procedure ShowSaleDocument()
    var
        Customer: Record Customer;
        SalePOS: Record "NPR POS Sale";
        POSSaleLine: Record "NPR POS Sale Line";
        LibrarySales: Codeunit "Library - Sales";
        POSSale: Codeunit "NPR POS Sale";
        SaleLinePOS: Codeunit "NPR POS Sale Line";
    begin
        // [Scenario] Open order from list
        // [Given]
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        SalesHeader.SetStatus("Sales Document Status"::Released.AsInteger());

        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(SaleLinePOS);
        SaleLinePOS.GetCurrentSaleLine(POSSaleLine);

        SalePOS.Validate("Customer No.", Customer."No.");
        POSSale.RefreshCurrent();

        // [When]
        POSActionDocShowB.ShowSaleDocument(POSSale, SaleLinePOS, false, 0, '');
    end;

    [ModalPageHandler]
    procedure OpenSalesOrderListPageHandler(var SalesOrders: TestPage "Sales List")
    begin
        SalesOrders.Last();
        SalesOrders.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure OpenSalesOrderPageHandler(var SalesOrder: TestPage "Sales Order")
    begin
        // [Then]
        Assert.IsTrue(SalesOrder."No.".Value = SalesHeader."No.", 'Created Sales Order opened.');
    end;

    local procedure GetDefaultPageId(): Integer
    var
        SalesHeader: Record "Sales Header";
        PageMgt: Codeunit "Page Management";
    begin
        exit(PageMgt.GetPageID(SalesHeader));
    end;
}