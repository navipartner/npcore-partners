codeunit 85092 "NPR POS Act. Doc. Import Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('SelectDocumentPageHandler,MessageHandler')]
    procedure ImportQuote()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSession: Codeunit "NPR POS Session";
        LibrarySales: Codeunit "Library - Sales";
        POSActionDocImpB: Codeunit "NPR POS Action: Doc. Import B";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        SaleLinePOS: Record "NPR POS Sale Line";
        Customer: Record Customer;
        SelectCustomer, ConfirmInvDiscAmt, SalesPersonFromOrder : Boolean;
        DocumentType: Integer;
        LocationSource: Option "POS Store","Location Filter Parameter";
        LocationFilter: Text;
        SalesDocViewString: Text;
        SaleLine: Record "Sales Line";
        SalesHeader: record "Sales Header";
    begin
        //[GIVEN] given
        SelectCustomer := false;
        ConfirmInvDiscAmt := false;
        SalesPersonFromOrder := false;
        DocumentType := 0;
        LocationSource := LocationSource::"Location Filter Parameter";
        LocationFilter := '';


        NPRLibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateSalesQuoteForCustomerNo(SalesHeader, Customer."No.");

        SaleLine.SetRange("Document No.", SalesHeader."No.");
        SaleLine.SetRange("Document Type", SalesHeader."Document Type");
        SaleLine.FindFirst();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        SetPosSaleCustomer(POSSale, Customer."No.");

        SalesDocViewString := StrSubstNo('Sorting(No.) Order(Ascending) Where(No.=Const(%1))', SalesHeader."No.");

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        POSActionDocImpB.ImportDocument(SelectCustomer,
                                ConfirmInvDiscAmt,
                                DocumentType,
                                LocationSource,
                                LocationFilter,
                                SalesDocViewString,
                                SalesPersonFromOrder,
                                POSSale);

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("No.", SaleLine."No.");

        CheckValues(SalePOS, SaleLine, SalesHeader, false, false);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('SelectDocumentPageHandler,MessageHandler')]
    procedure ImportOrder()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSession: Codeunit "NPR POS Session";
        LibrarySales: Codeunit "Library - Sales";
        POSActionDocImpB: Codeunit "NPR POS Action: Doc. Import B";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        SaleLinePOS: Record "NPR POS Sale Line";
        Customer: Record Customer;
        SelectCustomer, ConfirmInvDiscAmt, SalesPersonFromOrder : Boolean;
        DocumentType: Integer;
        LocationSource: Option "POS Store","Location Filter Parameter";
        LocationFilter: Text;
        SalesDocViewString: Text;
        SaleLine: Record "Sales Line";
        SalesHeader: record "Sales Header";
    begin
        //[GIVEN] given
        SelectCustomer := false;
        ConfirmInvDiscAmt := false;
        SalesPersonFromOrder := false;
        DocumentType := 1;
        LocationSource := LocationSource::"Location Filter Parameter";
        LocationFilter := '';

        NPRLibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        LibrarySales.CreateSalesOrder(SalesHeader);

        SaleLine.SetRange("Document No.", SalesHeader."No.");
        SaleLine.SetRange("Document Type", SalesHeader."Document Type");
        SaleLine.FindFirst();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        SetPosSaleCustomer(POSSale, SalesHeader."Bill-to Customer No.");

        SalesDocViewString := StrSubstNo('Sorting(No.) Order(Ascending) Where(No.=Const(%1))', SalesHeader."No.");

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        POSActionDocImpB.ImportDocument(SelectCustomer,
                                ConfirmInvDiscAmt,
                                DocumentType,
                                LocationSource,
                                LocationFilter,
                                SalesDocViewString,
                                SalesPersonFromOrder,
                                POSSale);

        CheckValues(SalePOS, SaleLine, SalesHeader, false, false);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('SelectDocumentPageHandler,MessageHandler')]
    procedure ImportInovice()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSession: Codeunit "NPR POS Session";
        LibrarySales: Codeunit "Library - Sales";
        POSActionDocImpB: Codeunit "NPR POS Action: Doc. Import B";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        SaleLinePOS: Record "NPR POS Sale Line";
        Customer: Record Customer;
        SelectCustomer, ConfirmInvDiscAmt, SalesPersonFromOrder : Boolean;
        DocumentType: Integer;
        LocationSource: Option "POS Store","Location Filter Parameter";
        LocationFilter: Text;
        SalesDocViewString: Text;
        SaleLine: Record "Sales Line";
        SalesHeader: record "Sales Header";
    begin
        //[GIVEN] given
        SelectCustomer := false;
        ConfirmInvDiscAmt := false;
        SalesPersonFromOrder := false;
        DocumentType := 2;
        LocationSource := LocationSource::"Location Filter Parameter";
        LocationFilter := '';


        NPRLibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateSalesInvoiceForCustomerNo(SalesHeader, Customer."No.");

        SaleLine.SetRange("Document No.", SalesHeader."No.");
        SaleLine.SetRange("Document Type", SalesHeader."Document Type");
        SaleLine.FindFirst();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        SetPosSaleCustomer(POSSale, Customer."No.");

        SalesDocViewString := StrSubstNo('Sorting(No.) Order(Ascending) Where(No.=Const(%1))', SalesHeader."No.");

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        POSActionDocImpB.ImportDocument(SelectCustomer,
                                ConfirmInvDiscAmt,
                                DocumentType,
                                LocationSource,
                                LocationFilter,
                                SalesDocViewString,
                                SalesPersonFromOrder,
                                POSSale);

        CheckValues(SalePOS, SaleLine, SalesHeader, false, false);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('SelectDocumentPageHandler,MessageHandler')]
    procedure ImportCreditMemo()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSession: Codeunit "NPR POS Session";
        LibrarySales: Codeunit "Library - Sales";
        POSActionDocImpB: Codeunit "NPR POS Action: Doc. Import B";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        SaleLinePOS: Record "NPR POS Sale Line";
        SelectCustomer, ConfirmInvDiscAmt, SalesPersonFromOrder : Boolean;
        DocumentType: Integer;
        LocationSource: Option "POS Store","Location Filter Parameter";
        LocationFilter: Text;
        SalesDocViewString: Text;
        SaleLine: Record "Sales Line";
        SalesHeader: record "Sales Header";
    begin
        //[GIVEN] given
        SelectCustomer := false;
        ConfirmInvDiscAmt := false;
        SalesPersonFromOrder := false;
        DocumentType := 3;
        LocationSource := LocationSource::"Location Filter Parameter";
        LocationFilter := '';

        NPRLibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        LibrarySales.CreateSalesCreditMemo(SalesHeader);

        SaleLine.SetRange("Document No.", SalesHeader."No.");
        SaleLine.SetRange("Document Type", SalesHeader."Document Type");
        SaleLine.FindFirst();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        SetPosSaleCustomer(POSSale, SalesHeader."Bill-to Customer No.");

        SalesDocViewString := StrSubstNo('Sorting(No.) Order(Ascending) Where(No.=Const(%1))', SalesHeader."No.");

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        POSActionDocImpB.ImportDocument(SelectCustomer,
                                ConfirmInvDiscAmt,
                                DocumentType,
                                LocationSource,
                                LocationFilter,
                                SalesDocViewString,
                                SalesPersonFromOrder,
                                POSSale);

        CheckValues(SalePOS, SaleLine, SalesHeader, true, false);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('SelectDocumentPageHandler,MessageHandler')]
    procedure ImportQuoteWithSalesPerson()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSession: Codeunit "NPR POS Session";
        LibrarySales: Codeunit "Library - Sales";
        POSActionDocImpB: Codeunit "NPR POS Action: Doc. Import B";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        SaleLinePOS: Record "NPR POS Sale Line";
        Customer: Record Customer;
        SelectCustomer, ConfirmInvDiscAmt, SalesPersonFromOrder : Boolean;
        DocumentType: Integer;
        LocationSource: Option "POS Store","Location Filter Parameter";
        LocationFilter: Text;
        SalesDocViewString: Text;
        SaleLine: Record "Sales Line";
        SalesHeader: record "Sales Header";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
    begin
        //[GIVEN] given
        SelectCustomer := false;
        ConfirmInvDiscAmt := false;
        SalesPersonFromOrder := true;
        DocumentType := 0;
        LocationSource := LocationSource::"Location Filter Parameter";
        LocationFilter := '';

        NPRLibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateSalesQuoteForCustomerNo(SalesHeader, Customer."No.");
        LibrarySales.CreateSalesperson(SalespersonPurchaser);

        SaleLine.SetRange("Document No.", SalesHeader."No.");
        SaleLine.SetRange("Document Type", SalesHeader."Document Type");
        SaleLine.FindFirst();

        InsertSalesPersonToSalesHeader(SalespersonPurchaser, SalesHeader);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        SetPosSaleCustomer(POSSale, Customer."No.");

        SalesDocViewString := StrSubstNo('Sorting(No.) Order(Ascending) Where(No.=Const(%1))', SalesHeader."No.");

        POSSession.GetSale(POSSale);

        POSActionDocImpB.ImportDocument(SelectCustomer,
                                ConfirmInvDiscAmt,
                                DocumentType,
                                LocationSource,
                                LocationFilter,
                                SalesDocViewString,
                                SalesPersonFromOrder,
                                POSSale);

        POSSale.GetCurrentSale(SalePOS);

        CheckValues(SalePOS, SaleLine, SalesHeader, false, true);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('SelectDocumentPageHandler,MessageHandler')]
    procedure ImportOrderWithSalesPerson()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSession: Codeunit "NPR POS Session";
        LibrarySales: Codeunit "Library - Sales";
        POSActionDocImpB: Codeunit "NPR POS Action: Doc. Import B";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        SaleLinePOS: Record "NPR POS Sale Line";
        Customer: Record Customer;
        SelectCustomer, ConfirmInvDiscAmt, SalesPersonFromOrder : Boolean;
        DocumentType: Integer;
        LocationSource: Option "POS Store","Location Filter Parameter";
        LocationFilter: Text;
        SalesDocViewString: Text;
        SaleLine: Record "Sales Line";
        SalesHeader: record "Sales Header";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
    begin
        //[GIVEN] given
        SelectCustomer := false;
        ConfirmInvDiscAmt := false;
        SalesPersonFromOrder := true;
        DocumentType := 1;
        LocationSource := LocationSource::"Location Filter Parameter";
        LocationFilter := '';

        NPRLibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        LibrarySales.CreateSalesOrder(SalesHeader);
        LibrarySales.CreateSalesperson(SalespersonPurchaser);

        SaleLine.SetRange("Document No.", SalesHeader."No.");
        SaleLine.SetRange("Document Type", SalesHeader."Document Type");
        SaleLine.FindFirst();

        InsertSalesPersonToSalesHeader(SalespersonPurchaser, SalesHeader);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        SetPosSaleCustomer(POSSale, SalesHeader."Bill-to Customer No.");

        SalesDocViewString := StrSubstNo('Sorting(No.) Order(Ascending) Where(No.=Const(%1))', SalesHeader."No.");

        POSSession.GetSale(POSSale);

        POSActionDocImpB.ImportDocument(SelectCustomer,
                                ConfirmInvDiscAmt,
                                DocumentType,
                                LocationSource,
                                LocationFilter,
                                SalesDocViewString,
                                SalesPersonFromOrder,
                                POSSale);

        POSSale.GetCurrentSale(SalePOS);

        CheckValues(SalePOS, SaleLine, SalesHeader, false, true);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('SelectDocumentPageHandler,MessageHandler')]
    procedure ImportInoviceWithSalesPerson()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSession: Codeunit "NPR POS Session";
        LibrarySales: Codeunit "Library - Sales";
        POSActionDocImpB: Codeunit "NPR POS Action: Doc. Import B";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        SaleLinePOS: Record "NPR POS Sale Line";
        Customer: Record Customer;
        SelectCustomer, ConfirmInvDiscAmt, SalesPersonFromOrder : Boolean;
        DocumentType: Integer;
        LocationSource: Option "POS Store","Location Filter Parameter";
        LocationFilter: Text;
        SalesDocViewString: Text;
        SaleLine: Record "Sales Line";
        SalesHeader: record "Sales Header";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
    begin
        //[GIVEN] given
        SelectCustomer := false;
        ConfirmInvDiscAmt := false;
        SalesPersonFromOrder := true;
        DocumentType := 2;
        LocationSource := LocationSource::"Location Filter Parameter";
        LocationFilter := '';

        NPRLibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateSalesInvoiceForCustomerNo(SalesHeader, Customer."No.");
        LibrarySales.CreateSalesperson(SalespersonPurchaser);

        SaleLine.SetRange("Document No.", SalesHeader."No.");
        SaleLine.SetRange("Document Type", SalesHeader."Document Type");
        SaleLine.FindFirst();

        InsertSalesPersonToSalesHeader(SalespersonPurchaser, SalesHeader);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        SetPosSaleCustomer(POSSale, Customer."No.");

        SalesDocViewString := StrSubstNo('Sorting(No.) Order(Ascending) Where(No.=Const(%1))', SalesHeader."No.");

        POSSession.GetSale(POSSale);

        POSActionDocImpB.ImportDocument(SelectCustomer,
                                ConfirmInvDiscAmt,
                                DocumentType,
                                LocationSource,
                                LocationFilter,
                                SalesDocViewString,
                                SalesPersonFromOrder,
                                POSSale);

        POSSale.GetCurrentSale(SalePOS);

        CheckValues(SalePOS, SaleLine, SalesHeader, false, true);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('SelectDocumentPageHandler,MessageHandler')]
    procedure ImportCreditMemoWithSalesPerson()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSession: Codeunit "NPR POS Session";
        LibrarySales: Codeunit "Library - Sales";
        POSActionDocImpB: Codeunit "NPR POS Action: Doc. Import B";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        SaleLinePOS: Record "NPR POS Sale Line";
        Customer: Record Customer;
        SelectCustomer, ConfirmInvDiscAmt, SalesPersonFromOrder : Boolean;
        DocumentType: Integer;
        LocationSource: Option "POS Store","Location Filter Parameter";
        LocationFilter: Text;
        SalesDocViewString: Text;
        SaleLine: Record "Sales Line";
        SalesHeader: record "Sales Header";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
    begin
        //[GIVEN] given
        SelectCustomer := false;
        ConfirmInvDiscAmt := false;
        SalesPersonFromOrder := true;
        DocumentType := 3;
        LocationSource := LocationSource::"Location Filter Parameter";
        LocationFilter := '';

        NPRLibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        LibrarySales.CreateSalesCreditMemo(SalesHeader);
        LibrarySales.CreateSalesperson(SalespersonPurchaser);

        SaleLine.SetRange("Document No.", SalesHeader."No.");
        SaleLine.SetRange("Document Type", SalesHeader."Document Type");
        SaleLine.FindFirst();

        InsertSalesPersonToSalesHeader(SalespersonPurchaser, SalesHeader);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        SetPosSaleCustomer(POSSale, SalesHeader."Bill-to Customer No.");

        SalesDocViewString := StrSubstNo('Sorting(No.) Order(Ascending) Where(No.=Const(%1))', SalesHeader."No.");

        POSSession.GetSale(POSSale);

        POSActionDocImpB.ImportDocument(SelectCustomer,
                                ConfirmInvDiscAmt,
                                DocumentType,
                                LocationSource,
                                LocationFilter,
                                SalesDocViewString,
                                SalesPersonFromOrder,
                                POSSale);

        POSSale.GetCurrentSale(SalePOS);

        CheckValues(SalePOS, SaleLine, SalesHeader, true, true);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('SelectDocumentPageHandler,MessageHandler')]
    procedure ImportBlaketOrder()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSession: Codeunit "NPR POS Session";
        LibrarySales: Codeunit "Library - Sales";
        POSActionDocImpB: Codeunit "NPR POS Action: Doc. Import B";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        SaleLinePOS: Record "NPR POS Sale Line";
        Customer: Record Customer;
        SelectCustomer, ConfirmInvDiscAmt, SalesPersonFromOrder : Boolean;
        DocumentType: Integer;
        LocationSource: Option "POS Store","Location Filter Parameter";
        LocationFilter: Text;
        SalesDocViewString: Text;
        SaleLine: Record "Sales Line";
        SalesHeader: record "Sales Header";
    begin
        //[GIVEN] given
        SelectCustomer := false;
        ConfirmInvDiscAmt := false;
        SalesPersonFromOrder := false;
        DocumentType := 4;
        LocationSource := LocationSource::"Location Filter Parameter";
        LocationFilter := '';

        NPRLibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        LibrarySales.CreateCustomer(Customer);

        CreateSalesBlanketOrderForCustomerNo(SalesHeader, Customer."No.");
        SaleLine.SetRange("Document No.", SalesHeader."No.");
        SaleLine.SetRange("Document Type", SalesHeader."Document Type");
        SaleLine.FindFirst();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        SetPosSaleCustomer(POSSale, SalesHeader."Bill-to Customer No.");

        SalesDocViewString := StrSubstNo('Sorting(No.) Order(Ascending) Where(No.=Const(%1))', SalesHeader."No.");

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        POSActionDocImpB.ImportDocument(SelectCustomer,
                                ConfirmInvDiscAmt,
                                DocumentType,
                                LocationSource,
                                LocationFilter,
                                SalesDocViewString,
                                SalesPersonFromOrder,
                                POSSale);

        CheckValues(SalePOS, SaleLine, SalesHeader, false, false);

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('SelectDocumentPageHandler,MessageHandler')]
    procedure ImportReturnOrder()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSession: Codeunit "NPR POS Session";
        LibrarySales: Codeunit "Library - Sales";
        POSActionDocImpB: Codeunit "NPR POS Action: Doc. Import B";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        SaleLinePOS: Record "NPR POS Sale Line";
        Customer: Record Customer;
        SelectCustomer, ConfirmInvDiscAmt, SalesPersonFromOrder : Boolean;
        DocumentType: Integer;
        LocationSource: Option "POS Store","Location Filter Parameter";
        LocationFilter: Text;
        SalesDocViewString: Text;
        SaleLine: Record "Sales Line";
        SalesHeader: record "Sales Header";
    begin
        //[GIVEN] given
        SelectCustomer := false;
        ConfirmInvDiscAmt := false;
        SalesPersonFromOrder := false;
        DocumentType := 5;
        LocationSource := LocationSource::"Location Filter Parameter";
        LocationFilter := '';

        NPRLibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        LibrarySales.CreateCustomer(Customer);

        CreateSalesReturnOrderForCustomerNo(SalesHeader, Customer."No.");
        SaleLine.SetRange("Document No.", SalesHeader."No.");
        SaleLine.SetRange("Document Type", SalesHeader."Document Type");
        SaleLine.FindFirst();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        SetPosSaleCustomer(POSSale, SalesHeader."Bill-to Customer No.");

        SalesDocViewString := StrSubstNo('Sorting(No.) Order(Ascending) Where(No.=Const(%1))', SalesHeader."No.");

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        POSActionDocImpB.ImportDocument(SelectCustomer,
                                ConfirmInvDiscAmt,
                                DocumentType,
                                LocationSource,
                                LocationFilter,
                                SalesDocViewString,
                                SalesPersonFromOrder,
                                POSSale);

        CheckValues(SalePOS, SaleLine, SalesHeader, true, false);
    end;

    local procedure CheckValues(SalePOS: Record "NPR POS Sale"; SaleLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; NegativeQty: Boolean; SalesPerson: Boolean)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("No.", SaleLine."No.");

        Assert.IsTrue(SaleLinePOS.FindFirst(), 'Item line inserted');
        if NegativeQty then
            Assert.IsTrue(SaleLinePOS.Quantity = -SaleLine.Quantity, 'Quantity reversed')
        else
            Assert.IsTrue(SaleLinePOS.Quantity = SaleLine.Quantity, 'Quantity reversed');
        Assert.IsTrue(SaleLinePOS."Unit Price" = SaleLine."Unit Price", 'Unit price inserted');
        Assert.IsTrue(SaleLinePOS."Unit of Measure Code" = SaleLine."Unit of Measure Code", 'Unit of measure inserted');
        Assert.IsTrue(SaleLinePOS.Description = SaleLine.Description, 'Description inserted');
        Assert.IsTrue(SaleLinePOS."Description 2" = SaleLine."Description 2", 'Description 2 inserted');
        Assert.IsTrue(SaleLinePOS."Variant Code" = SaleLine."Variant Code", 'Variant Code inserted');
        Assert.IsTrue(SaleLinePOS."Discount %" = SaleLine."Line Discount %", 'Discount % inserted');
        Assert.IsTrue(SaleLinePOS."Discount Amount" = SaleLine."Line Discount Amount", 'Discount Amount inserted');
        Assert.IsTrue(SaleLinePOS."Bin Code" = SaleLine."Bin Code", 'Bin Code inserted');
        Assert.IsTrue(SaleLinePOS."Shortcut Dimension 1 Code" = SaleLine."Shortcut Dimension 1 Code", 'Shortcut Dimension 1 inserted');
        Assert.IsTrue(SaleLinePOS."Shortcut Dimension 2 Code" = SaleLine."Shortcut Dimension 2 Code", 'Shortcut Dimension 2 inserted');
        if SalesPerson then
            Assert.IsTrue(SalePOS."Salesperson Code" = SalesHeader."Salesperson Code", 'Salesperson Code inserted');
    end;

    procedure SetPosSaleCustomer(POSSale: Codeunit "NPR POS Sale"; CustomerNo: Code[20])
    var
        SalePOS: Record "NPR POS Sale";
    begin
        POSSale.GetCurrentSale(SalePOS);
        if SalePOS."Customer No." <> '' then
            exit;
        SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
        SalePOS.Validate("Customer No.", CustomerNo);
        SalePOS.Modify(true);
    end;


    [ModalPageHandler]
    procedure SelectDocumentPageHandler(var SalesList: TestPage "Sales List")
    begin
        SalesList.First();
        SalesList.OK().Invoke();
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    local procedure CreateVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; TaxCaclType: Enum "NPR POS Tax Calc. Type")
    var
        VATProductPostingGroup: Record "VAT Product Posting Group";
        LibraryTaxCalc2: codeunit "NPR POS Lib. - Tax Calc.";
        LibraryERM: Codeunit "Library - ERM";
    begin
        LibraryERM.CreateVATProductPostingGroup(VATProductPostingGroup);
        if TaxCaclType = TaxCaclType::"Sales Tax" then
            LibraryTaxCalc2.CreateSalesTaxPostingSetup(VATPostingSetup, VATBusinessPostingGroup.Code, VATProductPostingGroup.Code, TaxCaclType)
        else
            LibraryTaxCalc2.CreateTaxPostingSetup(VATPostingSetup, VATBusinessPostingGroup.Code, VATProductPostingGroup.Code, TaxCaclType);
    end;

    local procedure AssignVATBusPostGroupToPOSPostingProfile(VATBusPostingGroupCode: Code[20])
    var
        LibraryPOSMasterData: codeunit "NPR Library - POS Master Data";
    begin
        LibraryPOSMasterData.AssignVATBusPostGroupToPOSPostingProfile(POSStore, VATBusPostingGroupCode);
    end;

    local procedure AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup: Record "VAT Posting Setup")
    var
        LibraryPOSMasterData: codeunit "NPR Library - POS Master Data";
    begin
        LibraryPOSMasterData.AssignVATPostGroupToPOSSalesRoundingAcc(POSStore, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
    end;

    local procedure InsertSalesPersonToSalesHeader(SalespersonPurchaser: Record "Salesperson/Purchaser"; var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.Validate("Salesperson Code", SalespersonPurchaser.Code);
        SalesHeader.Modify();
    end;

    procedure CreateSalesBlanketOrderForCustomerNo(var SalesHeader: Record "Sales Header"; CustomerNo: Code[20])
    var
        Item: Record Item;
        SalesLine: Record "Sales Line";
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::"Blanket Order", CustomerNo);
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(
          Item, LibraryRandom.RandDecInRange(1, 100, 2), LibraryRandom.RandDecInRange(1, 100, 2));
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", LibraryRandom.RandInt(100));
    end;

    procedure CreateSalesReturnOrderForCustomerNo(var SalesHeader: Record "Sales Header"; CustomerNo: Code[20])
    var
        Item: Record Item;
        SalesLine: Record "Sales Line";
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::"Return Order", CustomerNo);
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(
          Item, LibraryRandom.RandDecInRange(1, 100, 2), LibraryRandom.RandDecInRange(1, 100, 2));
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", LibraryRandom.RandInt(100));
    end;

}