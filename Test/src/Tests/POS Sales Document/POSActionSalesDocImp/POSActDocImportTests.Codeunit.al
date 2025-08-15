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
        NPRGroupCode: Record "NPR Group Code";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('SelectDocumentPageHandler,MessageHandler')]
    procedure ImportQuote()
    var
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

        // [GIVEN] Posting Setup
        CreatePostingSetup(SalesHeader);

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
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSession: Codeunit "NPR POS Session";
        LibrarySales: Codeunit "Library - Sales";
        POSActionDocImpB: Codeunit "NPR POS Action: Doc. Import B";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
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

        // [GIVEN] Posting Setup
        CreatePostingSetup(SalesHeader);

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

    #region ImportOrderWithGroupCodeFilterEnabledNoGroupCodeAssignedAndNoGropCodeSelected
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('SelectDocumentPageHandler,NPRGroupCodesCancelOpenPageHandler,MessageHandler')]
    procedure ImportOrderWithGroupCodeFilterEnabledNoGroupCodeAssignedAndNoGropCodeSelected()
    var
        SalesHeader: record "Sales Header";
        SaleLine: Record "Sales Line";
        SalePOS: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibrarySales: Codeunit "Library - Sales";
        POSActionDocImpB: Codeunit "NPR POS Action: Doc. Import B";
        POSSale: Codeunit "NPR POS Sale";
        SelectCustomer, ConfirmInvDiscAmt, SalesPersonFromOrder : Boolean;
        DocumentType: Integer;
        LocationSource: Option "POS Store","Location Filter Parameter";
        LocationFilter: Text;
        SalesDocViewString: Text;
        GroupCodeFilterEnabled: Boolean;
        GroupCodeFilter: Text;
    begin
        //[SCENARIO] Import Sales Order with group code filter functionality enabled, no group code assigned and no code selected from the lookup

        //[GIVEN] given
        SelectCustomer := false;
        ConfirmInvDiscAmt := false;
        SalesPersonFromOrder := false;
        DocumentType := 1;
        LocationSource := LocationSource::"Location Filter Parameter";
        LocationFilter := '';

        //[GIVEN] Group Code Filter functionality enabled and no Group Code Filter Assigned
        GroupCodeFilterEnabled := true;
        GroupCodeFilter := '';

        NPRLibraryPOSMock.InitializeData(Initialized,
                                         POSUnit,
                                         POSStore,
                                         POSPaymentMethod);

        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(POSSession,
                                                           POSUnit,
                                                           POSSale);

        LibrarySales.CreateSalesOrder(SalesHeader);

        SaleLine.SetRange("Document No.", SalesHeader."No.");
        SaleLine.SetRange("Document Type", SalesHeader."Document Type");
        SaleLine.FindFirst();

        // [GIVEN] Posting Setup
        CreatePostingSetup(SalesHeader);

        SetPosSaleCustomer(POSSale,
                           SalesHeader."Bill-to Customer No.");

        SalesDocViewString := StrSubstNo('Sorting(No.) Order(Ascending) Where(No.=Const(%1))', SalesHeader."No.");

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [When] Import document
        POSActionDocImpB.ImportDocument(SelectCustomer,
                                        ConfirmInvDiscAmt,
                                        DocumentType,
                                        LocationSource,
                                        LocationFilter,
                                        SalesDocViewString,
                                        SalesPersonFromOrder,
                                        GroupCodeFilterEnabled,
                                        GroupCodeFilter,
                                        POSSale);

        // [THEN] Check if the values are correct
        CheckValues(SalePOS,
                    SaleLine,
                    SalesHeader,
                    false,
                    false);
    end;
    #endregion ImportOrderWithGroupCodeFilterEnabledNoGroupCodeAssignedAndNoGropCodeSelected

    #region ImportOrderWithGroupCodeFilterEnabledNoGroupCodeAssignedAndGropCodeSelected
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('SelectDocumentPageHandler,NPRGroupCodesSelectExistingGroupCodePageHandler,MessageHandler')]
    procedure ImportOrderWithGroupCodeFilterEnabledNoGroupCodeAssignedAndGropCodeSelected()
    var
        SalesHeader: record "Sales Header";
        SaleLine: Record "Sales Line";
        SalePOS: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibrarySales: Codeunit "Library - Sales";
        POSActionDocImpB: Codeunit "NPR POS Action: Doc. Import B";
        POSSale: Codeunit "NPR POS Sale";
        SelectCustomer, ConfirmInvDiscAmt, SalesPersonFromOrder : Boolean;
        DocumentType: Integer;
        LocationSource: Option "POS Store","Location Filter Parameter";
        LocationFilter: Text;
        SalesDocViewString: Text;
        GroupCodeFilterEnabled: Boolean;
        GroupCodeFilter: Text;
    begin
        //[SCENARIO] Import Sales Order with group code filter functionality enabled, no group code assigned and group code selected from the lookup

        //[GIVEN] given
        SelectCustomer := false;
        ConfirmInvDiscAmt := false;
        SalesPersonFromOrder := false;
        DocumentType := 1;
        LocationSource := LocationSource::"Location Filter Parameter";
        LocationFilter := '';
        //[GIVEN] given Group Code Filter Functionality enabled and no Group Code Filter Assigned
        GroupCodeFilterEnabled := true;
        GroupCodeFilter := '';

        //[GIVEN] Group Code Setup Exists
        NPRLibraryPOSMasterData.CreateDefaultGroupCodeSetup(NPRGroupCode);

        NPRLibraryPOSMock.InitializeData(Initialized,
                                         POSUnit,
                                         POSStore,
                                         POSPaymentMethod);

        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(POSSession,
                                                           POSUnit,
                                                           POSSale);

        LibrarySales.CreateSalesOrder(SalesHeader);

        //[GIVEN] Sales Header has the default group code assigned
        SalesHeader."NPR Group Code" := NPRGroupCode.Code;
        SalesHeader.Modify();

        SaleLine.SetRange("Document No.", SalesHeader."No.");
        SaleLine.SetRange("Document Type", SalesHeader."Document Type");
        SaleLine.FindFirst();

        // [GIVEN] Posting Setup
        CreatePostingSetup(SalesHeader);

        SetPosSaleCustomer(POSSale,
                           SalesHeader."Bill-to Customer No.");

        SalesDocViewString := StrSubstNo('Sorting(No.) Order(Ascending) Where(No.=Const(%1))', SalesHeader."No.");

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [When] Import document
        POSActionDocImpB.ImportDocument(SelectCustomer,
                                        ConfirmInvDiscAmt,
                                        DocumentType,
                                        LocationSource,
                                        LocationFilter,
                                        SalesDocViewString,
                                        SalesPersonFromOrder,
                                        GroupCodeFilterEnabled,
                                        GroupCodeFilter,
                                        POSSale);

        // [THEN] Check if the values are correct
        CheckValues(SalePOS,
                    SaleLine,
                    SalesHeader,
                    false,
                    false);

        // [THEN] Check if Selected Sales Header has correct Group Code (the test is choosing the created default group code)
        GroupCodeFilter := NPRGroupCode.Code;
        CheckGroupCodeInSelectedSalesHeader(SalesHeader,
                                            GroupCodeFilter);
        // [CLEANUP] 
        NPRGroupCode.Delete();

    end;
    #endregion ImportOrderWithGroupCodeFilterEnabledNoGroupCodeAssignedAndGropCodeSelected

    #region ImportOrderWithGroupCodeFilterEnabledGroupCodeAssigned
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('SelectDocumentPageHandler,MessageHandler')]
    procedure ImportOrderWithGroupCodeFilterEnabledGroupCodeAssigned()
    var
        SalesHeader: record "Sales Header";
        SaleLine: Record "Sales Line";
        SalePOS: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibrarySales: Codeunit "Library - Sales";
        POSActionDocImpB: Codeunit "NPR POS Action: Doc. Import B";
        POSSale: Codeunit "NPR POS Sale";
        SelectCustomer, ConfirmInvDiscAmt, SalesPersonFromOrder : Boolean;
        DocumentType: Integer;
        LocationSource: Option "POS Store","Location Filter Parameter";
        LocationFilter: Text;
        SalesDocViewString: Text;
        GroupCodeFilterEnabled: Boolean;
        GroupCodeFilter: Text;
    begin
        //[SCENARIO] Import Sales Order with group code filter functionality enabled and group code filter assigned

        //[GIVEN] given
        SelectCustomer := false;
        ConfirmInvDiscAmt := false;
        SalesPersonFromOrder := false;
        DocumentType := 1;
        LocationSource := LocationSource::"Location Filter Parameter";
        LocationFilter := '';

        //[GIVEN] Group code filter functionality enabled
        GroupCodeFilterEnabled := true;

        //[GIVEN] Group Code Setup Exists
        NPRLibraryPOSMasterData.CreateDefaultGroupCodeSetup(NPRGroupCode);

        //[GIVEN] Group Code Filter is set
        GroupCodeFilter := NPRGroupCode.Code;

        NPRLibraryPOSMock.InitializeData(Initialized,
                                         POSUnit,
                                         POSStore,
                                         POSPaymentMethod);

        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(POSSession,
                                                           POSUnit,
                                                           POSSale);

        LibrarySales.CreateSalesOrder(SalesHeader);

        //[GIVEN] Sales Header has the default group code assigned
        SalesHeader."NPR Group Code" := NPRGroupCode.Code;
        SalesHeader.Modify();

        SaleLine.SetRange("Document No.", SalesHeader."No.");
        SaleLine.SetRange("Document Type", SalesHeader."Document Type");
        SaleLine.FindFirst();

        // [GIVEN] Posting Setup
        CreatePostingSetup(SalesHeader);

        SetPosSaleCustomer(POSSale,
                           SalesHeader."Bill-to Customer No.");

        SalesDocViewString := StrSubstNo('Sorting(No.) Order(Ascending) Where(No.=Const(%1))', SalesHeader."No.");

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [When] Import document
        POSActionDocImpB.ImportDocument(SelectCustomer,
                                        ConfirmInvDiscAmt,
                                        DocumentType,
                                        LocationSource,
                                        LocationFilter,
                                        SalesDocViewString,
                                        SalesPersonFromOrder,
                                        GroupCodeFilterEnabled,
                                        GroupCodeFilter,
                                        POSSale);

        // [THEN] Check if the values are correct
        CheckValues(SalePOS,
                    SaleLine,
                    SalesHeader,
                    false,
                    false);

        // [THEN] Check if Selected Sales Header has correct Group Code (the test is choosing the created default group code)
        CheckGroupCodeInSelectedSalesHeader(SalesHeader,
                                            GroupCodeFilter);
        // [CLEANUP] 
        NPRGroupCode.Delete();

    end;
    #endregion ImportOrderWithGroupCodeFilterEnabledGroupCodeAssigned

    #region ImportOrderWithGroupCodeFilterEnabledWithDifferenceInTheAssignedGroupCodes
#if not BC18
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('SelectDocumentPageHandler')]
    procedure ImportOrderWithGroupCodeFilterEnabledWithDifferenceInTheAssignedGroupCodes()
    var
        SalesHeader: record "Sales Header";
        SaleLine: Record "Sales Line";
        SalePOS: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibrarySales: Codeunit "Library - Sales";
        POSActionDocImpB: Codeunit "NPR POS Action: Doc. Import B";
        POSSale: Codeunit "NPR POS Sale";
        SelectCustomer, ConfirmInvDiscAmt, SalesPersonFromOrder : Boolean;
        DocumentType: Integer;
        LocationSource: Option "POS Store","Location Filter Parameter";
        LocationFilter: Text;
        SalesDocViewString: Text;
        GroupCodeFilterEnabled: Boolean;
        GroupCodeFilter: Text;
    begin
        //[SCENARIO] Import Sales Order with group code filter functionality enabled and group code filter assigned is different
        //than the group code assigned to the sales header

        //[GIVEN] given
        SelectCustomer := false;
        ConfirmInvDiscAmt := false;
        SalesPersonFromOrder := false;
        DocumentType := 1;
        LocationSource := LocationSource::"Location Filter Parameter";
        LocationFilter := '';

        //[GIVEN] Group Code Filter functionality enabled
        GroupCodeFilterEnabled := true;

        //[GIVEN] Group Code Setup Exists
        NPRLibraryPOSMasterData.CreateDefaultGroupCodeSetup(NPRGroupCode);

        //[GIVEN] Group Code Filter is set
        GroupCodeFilter := NPRGroupCode.Code;

        NPRLibraryPOSMock.InitializeData(Initialized,
                                         POSUnit,
                                         POSStore,
                                         POSPaymentMethod);

        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(POSSession,
                                                           POSUnit,
                                                           POSSale);

        //[GIVEN] Group Code in the sales header is different than the assigned filter
        LibrarySales.CreateSalesOrder(SalesHeader);


        SaleLine.SetRange("Document No.", SalesHeader."No.");
        SaleLine.SetRange("Document Type", SalesHeader."Document Type");
        SaleLine.FindFirst();

        // [GIVEN] Posting Setup
        CreatePostingSetup(SalesHeader);

        SetPosSaleCustomer(POSSale,
                           SalesHeader."Bill-to Customer No.");

        SalesDocViewString := StrSubstNo('Sorting(No.) Order(Ascending) Where(No.=Const(%1))', SalesHeader."No.");

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [When] Import document
        asserterror POSActionDocImpB.ImportDocument(SelectCustomer,
                                                    ConfirmInvDiscAmt,
                                                    DocumentType,
                                                    LocationSource,
                                                    LocationFilter,
                                                    SalesDocViewString,
                                                    SalesPersonFromOrder,
                                                    GroupCodeFilterEnabled,
                                                    GroupCodeFilter,
                                                    POSSale);

        // [Then] The system should return an error that you cant assign number series manually - because the lookup page is empty.
        Assert.IsTrue(
                    GetLastErrorText().Contains('You may not enter numbers manually'),
                    StrSubstNo('Error message should relate to the no series because the lookup page should be empty."!\\Message: %1', GetLastErrorText()));

        // [CLEANUP] 
        NPRGroupCode.Delete();

    end;
#endif
    #endregion ImportOrderWithGroupCodeFilterEnabledWithDifferenceInTheAssignedGroupCodes

    #region ImportOrderWithGroupCodeFilterEnabledWithDifferenceInTheChosenGroupCodes
#if not BC18
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('SelectDocumentPageHandler,NPRGroupCodesSelectExistingGroupCodePageHandler')]
    procedure ImportOrderWithGroupCodeFilterEnabledWithDifferenceInTheChosenGroupCodes()
    var
        SalesHeader: record "Sales Header";
        SaleLine: Record "Sales Line";
        SalePOS: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibrarySales: Codeunit "Library - Sales";
        POSActionDocImpB: Codeunit "NPR POS Action: Doc. Import B";
        POSSale: Codeunit "NPR POS Sale";
        SelectCustomer, ConfirmInvDiscAmt, SalesPersonFromOrder : Boolean;
        DocumentType: Integer;
        LocationSource: Option "POS Store","Location Filter Parameter";
        LocationFilter: Text;
        SalesDocViewString: Text;
        GroupCodeFilterEnabled: Boolean;
        GroupCodeFilter: Text;
    begin
        //[SCENARIO] Import Sales Order with group code filter functionality enabled no group code filter assigned and difference
        //between the chosen group code from the lookup page and the assigned group code to the sales header

        //[GIVEN] given
        SelectCustomer := false;
        ConfirmInvDiscAmt := false;
        SalesPersonFromOrder := false;
        DocumentType := 1;
        LocationSource := LocationSource::"Location Filter Parameter";
        LocationFilter := '';

        //[GIVEN] Group Code Enabled and no Group Code Filter Assigned
        GroupCodeFilterEnabled := true;
        GroupCodeFilter := '';

        //[GIVEN] Group Code Setup Exists
        NPRLibraryPOSMasterData.CreateDefaultGroupCodeSetup(NPRGroupCode);

        NPRLibraryPOSMock.InitializeData(Initialized,
                                         POSUnit,
                                         POSStore,
                                         POSPaymentMethod);

        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(POSSession,
                                                           POSUnit,
                                                           POSSale);

        //[GIVEN] Group Code in the sales header is different than the chosen filter
        LibrarySales.CreateSalesOrder(SalesHeader);


        SaleLine.SetRange("Document No.", SalesHeader."No.");
        SaleLine.SetRange("Document Type", SalesHeader."Document Type");
        SaleLine.FindFirst();

        // [GIVEN] Posting Setup
        CreatePostingSetup(SalesHeader);

        SetPosSaleCustomer(POSSale,
                           SalesHeader."Bill-to Customer No.");

        SalesDocViewString := StrSubstNo('Sorting(No.) Order(Ascending) Where(No.=Const(%1))', SalesHeader."No.");

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);


        // [When] Import document the sales header is going to have an empty group code, 
        //but from the lookup page we're going to choose the default group code
        asserterror POSActionDocImpB.ImportDocument(SelectCustomer,
                                                    ConfirmInvDiscAmt,
                                                    DocumentType,
                                                    LocationSource,
                                                    LocationFilter,
                                                    SalesDocViewString,
                                                    SalesPersonFromOrder,
                                                    GroupCodeFilterEnabled,
                                                    GroupCodeFilter,
                                                    POSSale);

        // [Then] The system should return an error that you cant assign number series manually - because the lookup page is empty.
        Assert.IsTrue(
                    GetLastErrorText().Contains('You may not enter numbers manually'),
                    StrSubstNo('Error message should relate to the no series because the lookup page should be empty."!\\Message: %1', GetLastErrorText()));

        // [CLEANUP] 
        NPRGroupCode.Delete();

    end;
#endif
    #endregion ImportOrderWithGroupCodeFilterEnabledWithDifferenceInTheChosenGroupCodes

    #region ImportOrderWithGroupCodeFilterDisabledAndGroupCodeAssigned
#if not BC18
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('SelectDocumentPageHandler,MessageHandler')]
    procedure ImportOrderWithGroupCodeFilterDisabledAndGroupCodeAssigned()
    var
        SalesHeader: record "Sales Header";
        SaleLine: Record "Sales Line";
        SalePOS: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibrarySales: Codeunit "Library - Sales";
        POSActionDocImpB: Codeunit "NPR POS Action: Doc. Import B";
        POSSale: Codeunit "NPR POS Sale";
        SelectCustomer, ConfirmInvDiscAmt, SalesPersonFromOrder : Boolean;
        DocumentType: Integer;
        LocationSource: Option "POS Store","Location Filter Parameter";
        LocationFilter: Text;
        SalesDocViewString: Text;
        GroupCodeFilterEnabled: Boolean;
        GroupCodeFilter: Text;
    begin
        //[SCENARIO] Import Sales Order with group code filter functionality enabled and group code filter assigned

        //[GIVEN] given
        SelectCustomer := false;
        ConfirmInvDiscAmt := false;
        SalesPersonFromOrder := false;
        DocumentType := 1;
        LocationSource := LocationSource::"Location Filter Parameter";
        LocationFilter := '';

        //[GIVEN] Group code filter functionality enabled
        GroupCodeFilterEnabled := false;

        //[GIVEN] Group Code Setup Exists
        NPRLibraryPOSMasterData.CreateDefaultGroupCodeSetup(NPRGroupCode);

        //[GIVEN] Group Code Filter is set
        GroupCodeFilter := NPRGroupCode.Code;

        NPRLibraryPOSMock.InitializeData(Initialized,
                                         POSUnit,
                                         POSStore,
                                         POSPaymentMethod);

        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(POSSession,
                                                           POSUnit,
                                                           POSSale);

        //[GIVEN] Sales Header has different filter than the assigned group code
        LibrarySales.CreateSalesOrder(SalesHeader);

        SaleLine.SetRange("Document No.", SalesHeader."No.");
        SaleLine.SetRange("Document Type", SalesHeader."Document Type");
        SaleLine.FindFirst();

        // [GIVEN] Posting Setup
        CreatePostingSetup(SalesHeader);

        SetPosSaleCustomer(POSSale,
                           SalesHeader."Bill-to Customer No.");

        SalesDocViewString := StrSubstNo('Sorting(No.) Order(Ascending) Where(No.=Const(%1))', SalesHeader."No.");

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [When] Import document
        POSActionDocImpB.ImportDocument(SelectCustomer,
                                        ConfirmInvDiscAmt,
                                        DocumentType,
                                        LocationSource,
                                        LocationFilter,
                                        SalesDocViewString,
                                        SalesPersonFromOrder,
                                        GroupCodeFilterEnabled,
                                        GroupCodeFilter,
                                        POSSale);

        // [THEN] Check if the values are correct
        CheckValues(SalePOS,
                    SaleLine,
                    SalesHeader,
                    false,
                    false);

        // [CLEANUP] 
        NPRGroupCode.Delete();

    end;
#endif
    #endregion ImportOrderWithGroupCodeFilterDisabledAndGroupCodeAssigned

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('SelectDocumentPageHandler,MessageHandler')]
    procedure ImportInovice()
    var
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSession: Codeunit "NPR POS Session";
        LibrarySales: Codeunit "Library - Sales";
        POSActionDocImpB: Codeunit "NPR POS Action: Doc. Import B";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
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

        // [GIVEN] Posting Setup
        CreatePostingSetup(SalesHeader);

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
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSession: Codeunit "NPR POS Session";
        LibrarySales: Codeunit "Library - Sales";
        POSActionDocImpB: Codeunit "NPR POS Action: Doc. Import B";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
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

        // [GIVEN] Posting Setup
        CreatePostingSetup(SalesHeader);

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
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSession: Codeunit "NPR POS Session";
        LibrarySales: Codeunit "Library - Sales";
        POSActionDocImpB: Codeunit "NPR POS Action: Doc. Import B";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
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

        // [GIVEN] Posting Setup
        CreatePostingSetup(SalesHeader);

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
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSession: Codeunit "NPR POS Session";
        LibrarySales: Codeunit "Library - Sales";
        POSActionDocImpB: Codeunit "NPR POS Action: Doc. Import B";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
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

        // [GIVEN] Posting Setup
        CreatePostingSetup(SalesHeader);

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
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSession: Codeunit "NPR POS Session";
        LibrarySales: Codeunit "Library - Sales";
        POSActionDocImpB: Codeunit "NPR POS Action: Doc. Import B";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
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

        // [GIVEN] Posting Setup
        CreatePostingSetup(SalesHeader);

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
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSession: Codeunit "NPR POS Session";
        LibrarySales: Codeunit "Library - Sales";
        POSActionDocImpB: Codeunit "NPR POS Action: Doc. Import B";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
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

        // [GIVEN] Posting Setup
        CreatePostingSetup(SalesHeader);

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
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSession: Codeunit "NPR POS Session";
        LibrarySales: Codeunit "Library - Sales";
        POSActionDocImpB: Codeunit "NPR POS Action: Doc. Import B";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
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

        // [GIVEN] Posting Setup
        CreatePostingSetup(SalesHeader);

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
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSession: Codeunit "NPR POS Session";
        LibrarySales: Codeunit "Library - Sales";
        POSActionDocImpB: Codeunit "NPR POS Action: Doc. Import B";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
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

        // [GIVEN] Posting Setup
        CreatePostingSetup(SalesHeader);

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

    #region ImportOrderItemsWithTracking
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('SelectDocumentPageHandler,MessageHandler')]
    procedure ImportOrderWithSalesLineItemWithTracking()
    // [SCENARIO] Import Sales Order with Sales Line Item with Tracking 
    var
        SaleLine: Record "Sales Line";
        SalePOS: Record "NPR POS Sale";
        SalesHeader: Record "Sales Header";
        Item: Record Item;
        ItemTracking: Record "Item Tracking Code";
        POSSession: Codeunit "NPR POS Session";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        POSActionDocImpB: Codeunit "NPR POS Action: Doc. Import B";
        POSSale: Codeunit "NPR POS Sale";
        SelectCustomer, ConfirmInvDiscAmt, SalesPersonFromOrder : Boolean;
        DocumentType: Integer;
        LocationSource: Option "POS Store","Location Filter Parameter";
        LocationFilter: Text;
        SalesDocViewString: Text;
    begin
        SelectCustomer := false;
        ConfirmInvDiscAmt := false;
        SalesPersonFromOrder := false;
        DocumentType := 1;
        LocationSource := LocationSource::"Location Filter Parameter";
        LocationFilter := '';

        NPRLibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        // [GIVEN] Item with tracking
        LibraryInventory.CreateItem(Item);
        CreateItemTrackingAndAssignToItem(Item, ItemTracking);
        LibrarySales.CreateSalesDocumentWithItem(SalesHeader, SaleLine, Enum::"Sales Document Type"::Order, '', Item."No.", 1, '', Today + 7);

        SaleLine.SetRange("Document No.", SalesHeader."No.");
        SaleLine.SetRange("Document Type", SalesHeader."Document Type");
        SaleLine.FindFirst();

        // [GIVEN] Posting Setup
        CreatePostingSetup(SalesHeader);

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

    internal procedure CreateItemTrackingAndAssignToItem(var Item: Record Item; var ItemTrackingCode: Record "Item Tracking Code")
    var
        LibraryUtility: Codeunit "Library - Utility";
        TrackingCode: Code[10];
    begin
        TrackingCode := LibraryUtility.GenerateRandomCode(ItemTrackingCode.FieldNo(Code), Database::"Item Tracking Code");
        if ItemTrackingCode.Get(TrackingCode) then
            ItemTrackingCode.Delete();
        ItemTrackingCode.Init();
        ItemTrackingCode.Code := TrackingCode;
        ItemTrackingCode."SN Specific Tracking" := true;
        ItemTrackingCode."SN Sales Inbound Tracking" := true;
        ItemTrackingCode."SN Sales Outbound Tracking" := true;
        ItemTrackingCode.Insert();
        Item."Item Tracking Code" := ItemTrackingCode.Code;
        Item.Modify();
    end;
    #endregion ImportOrderItemsWithTracking

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

    #region CheckGroupCodeInSelectedSalesHeader
    local procedure CheckGroupCodeInSelectedSalesHeader(SalesHeader: Record "Sales Header";
                                                        GroupCodeFilter: Text)
    var
        TempSalesHeader: Record "Sales Header" temporary;
    begin
        TempSalesHeader.Init();
        TempSalesHeader := SalesHeader;
        TempSalesHeader.Insert();

        TempSalesHeader.SetFilter("NPR Group Code", groupCodeFilter);

        Assert.IsTrue(not TempSalesHeader.IsEmpty(), 'Selected Sales Header is with correct group code');
    end;
    #endregion CheckGroupCodeInSelectedSalesHeader

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

    #region NPRGroupCodesCancelOpenPageHandler
    [ModalPageHandler]
    procedure NPRGroupCodesCancelOpenPageHandler(var NPRGroupCodes: TestPage "NPR Group Codes")
    begin
        NPRGroupCodes.Cancel().Invoke();
    end;
    #endregion NPRGroupCodesCancelOpenPageHandler

    #region NPRGroupCodesSelectExistingGroupCodePageHandler
    [ModalPageHandler]
    procedure NPRGroupCodesSelectExistingGroupCodePageHandler(var NPRGroupCodes: TestPage "NPR Group Codes")
    begin
        NPRGroupCodes.GoToRecord(NPRGroupCode);
        NPRGroupCodes.OK().Invoke();
    end;
    #endregion NPRGroupCodesSelectExistingGroupCodePageHandler


    local procedure CreatePostingSetup(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        Item: Record Item;
        LibraryPOSMasterData: codeunit "NPR Library - POS Master Data";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, "Sales Line Type"::Item);
        SalesLine.SetLoadFields("No.");
        if SalesLine.FindSet() then
            repeat
                Item.Get(SalesLine."No.");
                LibraryPOSMasterData.CreatePostingSetupForSaleItem(Item, POSUnit, POSStore);
            until SalesLine.Next() = 0;
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