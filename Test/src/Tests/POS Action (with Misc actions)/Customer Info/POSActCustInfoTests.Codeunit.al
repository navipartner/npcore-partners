codeunit 85149 "NPR POS Act. Cust.Info Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibrarySales: Codeunit "Library - Sales";
        BusinessLogic: Codeunit "NPR POS Action: Cust.Info-I B";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FindCustNoFromPOS()
    var
        Customer: Record Customer;
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        CustNo: Code[20];
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        // [Given] Create Customer
        LibrarySales.CreateCustomer(Customer);

        // [GIVEN] Customer applied to sale
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);
        POSSale.RefreshCurrent();
        //[When] Find Customer No. from active POS
        BusinessLogic.GetCustomerNo(POSSale, CustNo);

        //[Then] Check Customer No.
        Assert.IsTrue(CustNo = Customer."No.", 'Got Customer No. from POS Sale.');
    end;

    [Test]
    [HandlerFunctions('CustomerLedgerEntry')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Open_CustLedgerEntries()
    var
        Customer: Record Customer;
    begin
        // [Given] Create Customer
        LibrarySales.CreateCustomer(Customer);

        //[When] Open page "Customer Ledger Entries"
        BusinessLogic.ShowCLE(Customer."No.");
    end;

    [Test]
    [HandlerFunctions('ItemLedgerEntry')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Open_ItemLedgerEntries()
    var
        Customer: Record Customer;
    begin
        // [Given] Create Customer
        LibrarySales.CreateCustomer(Customer);

        //[When] Open page "Customer Ledger Entries"
        BusinessLogic.ShowILE(Customer."No.");
    end;

    [Test]
    [HandlerFunctions('CustomerCard')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Open_CustCard()
    var
        Customer: Record Customer;
    begin
        // [Given] Create Customer
        LibrarySales.CreateCustomer(Customer);

        //[When] Open page "Customer Ledger Entries"
        BusinessLogic.ShowCustomerCard(Customer."No.");
    end;

    [PageHandler]
    procedure CustomerLedgerEntry(var CustLedgEntries: TestPage "Customer Ledger Entries")
    begin
        Assert.IsTrue(true, 'Customer Ledger Entries page opened.');
    end;

    [PageHandler]
    procedure ItemLedgerEntry(var ItemLedgEntries: TestPage "Item Ledger Entries")
    begin
        Assert.IsTrue(true, 'Item Ledger Entries page opened.');
    end;

    [PageHandler]
    procedure CustomerCard(var CustCard: TestPage "Customer Card")
    begin
        Assert.IsTrue(true, 'Customer Card opened.');
    end;
}