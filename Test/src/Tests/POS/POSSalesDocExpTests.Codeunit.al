codeunit 85022 "NPR POS Sales Doc Exp Tests"
{
    // // [Feature] POS sales document export tests

    Subtype = Test;

    var
        _Initialized: Boolean;
        _POSUnit: Record "NPR POS Unit";
        _POSSession: Codeunit "NPR POS Session";
        _POSStore: Record "NPR POS Store";
        _POSSetup: Record "NPR POS Setup";
        _Customer: Record "Customer";
        _Salesperson: Record "Salesperson/Purchaser";
        _NPRGroupCode: Record "NPR Group Code";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExportToOrderWithoutPosting()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalePOS: Record "NPR POS Sale";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        POSEntry: Record "NPR POS Entry";
        SalesHeader: Record "Sales Header";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        SalesDocumentExportMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
    begin
        // [Scenario] Check that a successful export to open sales order leaves it created but not shipped or invoiced.

        // [Given] POS & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Item line worth 10 LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := 10;
        Item.Modify();
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        // [Given] Customer applied to sale
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, _Customer."No.", false);

        // [When] Exporting to sales order without posting                
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalesDocumentExportMgt.SetDocumentTypeOrder();
        SalesDocumentExportMgt.ProcessPOSSale(POSSale);

        // [Then] POS entry created as credit sale, POS sale ended and sales document is created, open and linked to POS entry.
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();
        POSEntry.TestField("Entry Type", POSEntry."Entry Type"::"Credit Sale");

        Assert.IsFalse(SalePOS.Find(), 'Sale must end when exporting to sales order');

        POSEntrySalesDocLink.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesDocLink.SetRange("POS Entry Reference Type", POSEntrySalesDocLink."POS Entry Reference Type"::HEADER);
        POSEntrySalesDocLink.FindFirst();
        POSEntrySalesDocLink.TestField("Sales Document Type", POSEntrySalesDocLink."Sales Document Type"::ORDER);
        POSEntrySalesDocLink.TestField("Sales Document No");
        SalesHeader.Get(SalesHeader."Document Type"::Order, POSEntrySalesDocLink."Sales Document No");
        SalesHeader.TestField("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.TestField("Last Posting No.", '');
        SalesHeader.TestField("Last Shipping No.", '');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExportToOrderWithFullPosting()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalePOS: Record "NPR POS Sale";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        POSEntry: Record "NPR POS Entry";
        SalesHeader: Record "Sales Header";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        SalesDocumentExportMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
    begin
        // [Scenario] Check successful export to sales order with posting

        // [Given] POS & Payment setup
        InitializeData();

        // [Given] Active POS session & sale with salesperson on it.
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Item line worth 10 LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := 10;
        Item.Modify();
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        // [Given] Customer applied to sale
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, _Customer."No.", false);

        // [When] Exporting to sales order with posting                
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalesDocumentExportMgt.SetDocumentTypeOrder();
        SalesDocumentExportMgt.SetInvoice(true);
        SalesDocumentExportMgt.SetShip(true);
        SalesDocumentExportMgt.ProcessPOSSale(POSSale);

        // [Then] POS entry as credit sale is created, sale ended and order was posted
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();
        POSEntry.TestField("Entry Type", POSEntry."Entry Type"::"Credit Sale");

        Assert.IsFalse(SalePOS.Find(), 'Sale must end when exporting to sales order');

        POSEntrySalesDocLink.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesDocLink.SetRange("POS Entry Reference Type", POSEntrySalesDocLink."POS Entry Reference Type"::HEADER);
        POSEntrySalesDocLink.SetRange("Sales Document Type", POSEntrySalesDocLink."Sales Document Type"::ORDER);
        POSEntrySalesDocLink.FindFirst();
        Assert.IsFalse(SalesHeader.Get(SalesHeader."Document Type"::Order, POSEntrySalesDocLink."Sales Document No"), 'Sales Header must be gone after full posting');
        POSEntrySalesDocLink.SetRange("Sales Document Type", POSEntrySalesDocLink."Sales Document Type"::POSTED_INVOICE);
        POSEntrySalesDocLink.FindFirst();
        SalesInvoiceHeader.Get(POSEntrySalesDocLink."Sales Document No");
        POSEntrySalesDocLink.SetRange("Sales Document Type", POSEntrySalesDocLink."Sales Document Type"::SHIPMENT);
        POSEntrySalesDocLink.FindFirst();
        SalesShipmentHeader.Get(POSEntrySalesDocLink."Sales Document No");
    end;

    #region ExportToOrderWithoutGroupCodeEnabled
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExportToOrderWithoutGroupCodeEnabled()
    var
        SalePOS: Record "NPR POS Sale";
        SalesHeader: Record "Sales Header";
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit Assert;
        GroupCodesEnabled: Boolean;
        GroupCode: Code[10];
    begin
        // [Scenario] Check that a successful export to open sales order doesn't have a group code when group code functionality is disabled

        // [Given] POS & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        // [Given] Item line worth 10 LCY
        // [Given] Customer applied to sale
        // [Given] Group Code not enabled and group code is not set
        GroupCodesEnabled := false;
        GroupCode := '';
        CreatePOSSaleWithCustomerAndItemLineAndAssignGroupCode(SalePOS,
                                                               POSSale,
                                                               GroupCodesEnabled,
                                                               GroupCode);

        // [When] Exporting to sales order without posting                
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        ExportPOSSAlesToSalesOrder(POSSale,
                                   false,
                                   false,
                                   SalesHeader);

        // [Then] POS Sale's group code should be empty and should match the group code in the created sales header
        CheckGroupCodeInCreatedSalesDocument(SalePOS,
                                             SalesHeader,
                                             GroupCodesEnabled,
                                             GroupCode);

        // [Then] Sales must not exist after export
        Assert.IsFalse(SalePOS.Find(), 'Sale must end when exporting to sales order');

    end;
    #endregion ExportToOrderWithoutGroupCodeEnabled

    #region ExportToOrderWithGroupCodesEnabledAndNoGroupCodeAssignedAndNoGroupCodeChosen
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('NPRGroupCodesCancelOpenPageHandler')]
    procedure ExportToOrderWithGroupCodesEnabledAndNoGroupCodeAssignedAndNoGroupCodeChosen()
    var
        SalePOS: Record "NPR POS Sale";
        SalesHeader: Record "Sales Header";
        POSSale: Codeunit "NPR POS Sale";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        GroupCodeEnabled: Boolean;
        GroupCode: Code[10];
    begin
        // [Scenario] Check that a successful export to open sales order doesn't have a group code when group code functionality is enabled
        //and group code is not set and is not chosen

        // [Given] POS & Payment setup
        InitializeData();

        // [Given] Group Codes Setup
        NPRLibraryPOSMasterData.CreateDefaultGroupCodeSetup(_NPRGroupCode);

        // [Given] Active POS session & sale
        // [Given] Item line worth 10 LCY
        // [Given] Customer applied to sale
        // [Given] Group Code enabled and group code is not set
        GroupCodeEnabled := true;
        GroupCode := '';
        CreatePOSSaleWithCustomerAndItemLineAndAssignGroupCode(SalePOS,
                                                               POSSale,
                                                               GroupCodeEnabled,
                                                               GroupCode);


        // [When] Exporting to sales order without posting                
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        ExportPOSSAlesToSalesOrder(POSSale,
                                   false,
                                   false,
                                   SalesHeader);

        // [Then] POS Sale's group code should be empty and should match the group code in the created sales header

        CheckGroupCodeInCreatedSalesDocument(SalePOS,
                                             SalesHeader,
                                             GroupCodeEnabled,
                                             GroupCode);

        // [Then] Sales must not exist after export
        Assert.IsFalse(SalePOS.Find(), 'Sale must end when exporting to sales order');

        // [Cleanup] Delete Group Code
        _NPRGroupCode.Delete();
    end;
    #endregion ExportToOrderWithGroupCodesEnabledAndNoGroupCodeAssignedAndNoGroupCodeChosen

    #region ExportToOrderWithGroupCodesEnabledAndNoGroupCodeAssignedAndGroupCodeChosen
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('NPRGroupCodesSelectEnqueuedOptionPageHandler')]
    procedure ExportToOrderWithGroupCodesEnabledAndNoGroupCodeAssignedAndGroupCodeChosen()
    var
        SalePOS: Record "NPR POS Sale";
        SalesHeader: Record "Sales Header";
        POSSale: Codeunit "NPR POS Sale";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        GroupCodeEnabled: Boolean;
        GroupCode: Code[10];
    begin
        // [Scenario] Check that a successful export to open sales order has group code when group code functionality is enabled
        //and group code is not set but chosen on runtime

        // [Given] POS & Payment setup
        InitializeData();

        // [Given] Group Codes Setup
        NPRLibraryPOSMasterData.CreateDefaultGroupCodeSetup(_NPRGroupCode);

        // [Given] Active POS session & sale
        // [Given] Item line worth 10 LCY
        // [Given] Customer applied to sale
        // [Given] Group Code enabled and group code is not set
        GroupCodeEnabled := true;
        GroupCode := '';
        CreatePOSSaleWithCustomerAndItemLineAndAssignGroupCode(SalePOS,
                                                               POSSale,
                                                               GroupCodeEnabled,
                                                               GroupCode);

        //[Given] NPRGroupCode.Code is selected from a runmodal page
        GroupCode := _NPRGroupCode.Code;

        // [When] Exporting to sales order without posting                
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        ExportPOSSAlesToSalesOrder(POSSale,
                                   false,
                                   false,
                                   SalesHeader);

        // [Then] POS Sale's group code must match the group code in the created sales header
        CheckGroupCodeInCreatedSalesDocument(SalePOS,
                                             SalesHeader,
                                             GroupCodeEnabled,
                                             GroupCode);

        // [Then] Sales must not exist after export
        Assert.IsFalse(SalePOS.Find(), 'Sale must end when exporting to sales order');

        // [Cleanup] Delete Group Code
        _NPRGroupCode.Delete();
    end;
    #endregion ExportToOrderWithGroupCodesEnabledAndNoGroupCodeAssignedAndGroupCodeChosen


    #region ExportToOrderWithGroupCodesEnabledAndGroupCodeAssigned
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExportToOrderWithGroupCodesEnabledAndGroupCodeAssigned()
    var
        SalePOS: Record "NPR POS Sale";
        SalesHeader: Record "Sales Header";
        POSSale: Codeunit "NPR POS Sale";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        GroupCodeEnabled: Boolean;
        GroupCode: Code[10];
    begin
        // [Scenario] Check that a successful export to open sales order has group code when group code functionality is enabled
        //and group code is set

        // [Given] POS & Payment setup
        InitializeData();

        // [Given] Group Codes Setup
        NPRLibraryPOSMasterData.CreateDefaultGroupCodeSetup(_NPRGroupCode);

        // [Given] Active POS session & sale
        // [Given] Item line worth 10 LCY
        // [Given] Customer applied to sale
        // [Given] Group Code enabled and group code set with existing value
        GroupCodeEnabled := true;
        GroupCode := _NPRGroupCode.Code;
        CreatePOSSaleWithCustomerAndItemLineAndAssignGroupCode(SalePOS,
                                                               POSSale,
                                                               GroupCodeEnabled,
                                                               GroupCode);


        // [When] Exporting to sales order without posting                
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        ExportPOSSAlesToSalesOrder(POSSale,
                                   false,
                                   false,
                                   SalesHeader);

        // [Then] POS Sale's group code must match the group code in the created sales header
        CheckGroupCodeInCreatedSalesDocument(SalePOS,
                                             SalesHeader,
                                             GroupCodeEnabled,
                                             GroupCode);

        // [Then] Sales must not exist after export
        Assert.IsFalse(SalePOS.Find(), 'Sale must end when exporting to sales order');

        // [Cleanup] Delete Group Code
        _NPRGroupCode.Delete();
    end;
    #endregion ExportToOrderWithGroupCodesEnabledAndGroupCodeAssigned

    #region ExportToOrderWithGroupCodesEnabledAndNonExistingGroupCodeAssigned
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExportToOrderWithGroupCodesEnabledAndNonExistingGroupCodeAssigned()
    var
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        GroupCodeEnabled: Boolean;
        GroupCode: Code[10];
    begin
        // [Scenario] Check that a successful export to open sales order has group code when group code functionality is enabled
        //and group code is set with none existing value

        // [Given] POS & Payment setup
        InitializeData();

        // [Given]No Group Codes Setup
        _NPRGroupCode.Reset();
        if not _NPRGroupCode.IsEmpty then
            _NPRGroupCode.DeleteAll();


        // [Given] Active POS session & sale
        // [Given] Item line worth 10 LCY
        // [Given] Customer applied to sale
        // [Given] Group Code enabled and group code set with none existing value
        GroupCodeEnabled := true;
        GroupCode := 'DEFAULT';

        // [When] Exporting to sales order with non existing group code assigned
        asserterror CreatePOSSaleWithCustomerAndItemLineAndAssignGroupCode(SalePOS,
                                                                           POSSale,
                                                                           GroupCodeEnabled,
                                                                           GroupCode);

        // [Then] The system should return an error that the group code doesn't exist
        Assert.IsTrue(
                    GetLastErrorText().Contains('Group Code'),
                    StrSubstNo('Error message should relate to Group Code behavior, but did not contain the keyword "Group Code"!\\Message: %1', GetLastErrorText()));



    end;
    #endregion ExportToOrderWithGroupCodesEnabledAndNonExistingGroupCodeAssigned


    #region ExportToOrderWithGroupCodesDisabledAndGroupCodeAssigned
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExportToOrderWithGroupCodesDisabledAndGroupCodeAssigned()
    var
        SalePOS: Record "NPR POS Sale";
        SalesHeader: Record "Sales Header";
        POSSale: Codeunit "NPR POS Sale";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        GroupCodeEnabled: Boolean;
        GroupCode: Code[10];
    begin
        // [Scenario] Check that a successful export to open sales order has group code when group code functionality is not enabled
        //and group code is set with existing value

        // [Given] POS & Payment setup
        InitializeData();

        // [Given] Group Codes Setup
        NPRLibraryPOSMasterData.CreateDefaultGroupCodeSetup(_NPRGroupCode);

        // [Given] Active POS session & sale
        // [Given] Item line worth 10 LCY
        // [Given] Customer applied to sale
        // [Given] Group Code not enabled and group code set with existing value
        GroupCodeEnabled := false;
        GroupCode := _NPRGroupCode.Code;
        CreatePOSSaleWithCustomerAndItemLineAndAssignGroupCode(SalePOS,
                                                               POSSale,
                                                               GroupCodeEnabled,
                                                               GroupCode);


        // [When] Exporting to sales order without posting                
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        ExportPOSSAlesToSalesOrder(POSSale,
                                   false,
                                   false,
                                   SalesHeader);

        // [Then] POS Sale's group code should be empty and should match the group code in the created sales header
        CheckGroupCodeInCreatedSalesDocument(SalePOS,
                                             SalesHeader,
                                             GroupCodeEnabled,
                                             GroupCode);

        // [Then] Sales must not exist after export
        Assert.IsFalse(SalePOS.Find(), 'Sale must end when exporting to sales order');

        // [Cleanup] Delete Group Code
        _NPRGroupCode.Delete();
    end;
    #endregion ExportToOrderWithGroupCodesDisabledAndGroupCodeAssigned


    #region ExportToOrderWithGroupCodesDisabledAndNonExistingGroupCodeAssigned
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExportToOrderWithGroupCodesDisabledAndNonExistingGroupCodeAssigned()
    var
        SalePOS: Record "NPR POS Sale";
        SalesHeader: Record "Sales Header";
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit Assert;
        GroupCodeEnabled: Boolean;
        GroupCode: Code[10];
    begin
        // [Scenario] Check that a successful export to open sales order has group code when group code functionality is not enabled
        //and group code is set with none existing value

        // [Given] POS & Payment setup
        InitializeData();

        // [Given]No Group Codes Setup exists
        _NPRGroupCode.Reset();
        if not _NPRGroupCode.IsEmpty then
            _NPRGroupCode.DeleteAll();

        // [Given] Active POS session & sale
        // [Given] Item line worth 10 LCY
        // [Given] Customer applied to sale
        // [Given] Group Code not enabled and group code set with none existing value
        GroupCodeEnabled := false;
        GroupCode := 'DEFAULT';
        CreatePOSSaleWithCustomerAndItemLineAndAssignGroupCode(SalePOS,
                                                               POSSale,
                                                               GroupCodeEnabled,
                                                               GroupCode);


        // [When] Exporting to sales order without posting                
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        ExportPOSSAlesToSalesOrder(POSSale,
                                   false,
                                   false,
                                   SalesHeader);

        // [Then] POS Sale's group code should be empty and should match the group code in the created sales header
        CheckGroupCodeInCreatedSalesDocument(SalePOS,
                                             SalesHeader,
                                             GroupCodeEnabled,
                                             GroupCode);

        // [Then] Sales must not exist after export
        Assert.IsFalse(SalePOS.Find(), 'Sale must end when exporting to sales order');
    end;
    #endregion ExportToOrderWithGroupCodesDisabledAndNonExistingGroupCodeAssigned

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExportToOrderWithFullPostingAndGroupCodeEnabledAndSelected()
    var
        SalePOS: Record "NPR POS Sale";
        SalesHeader: Record "Sales Header";
        POSEntry: Record "NPR POS Entry";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
        POSSale: Codeunit "NPR POS Sale";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        GroupCodeEnabled: Boolean;
        GroupCode: Code[10];
    begin
        // [Scenario] Check that you can export to sales order with full posting and group code functionality enabled and group code selected

        // [Given] POS & Payment setup
        InitializeData();

        // [Given] Group Codes Setup
        NPRLibraryPOSMasterData.CreateDefaultGroupCodeSetup(_NPRGroupCode);

        // [Given] Active POS session & sale
        // [Given] Item line worth 10 LCY
        // [Given] Customer applied to sale
        // [Given] Group Code enabled and group code set with existing value
        GroupCodeEnabled := true;
        GroupCode := _NPRGroupCode.Code;
        CreatePOSSaleWithCustomerAndItemLineAndAssignGroupCode(SalePOS,
                                                               POSSale,
                                                               GroupCodeEnabled,
                                                               GroupCode);


        // [When] Exporting to sales order with posting posting                
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        ExportPOSSAlesToSalesOrder(POSSale,
                                   true,
                                   true,
                                   SalesHeader);

        // [Then] POS Sale's group code should be empty and should match the group code in the created sales header
        CheckGroupCodeInCreatedSalesDocument(SalePOS,
                                             SalesHeader,
                                             GroupCodeEnabled,
                                             GroupCode);

        // [Then] POS entry as credit sale is created, sale ended and order was posted
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();
        POSEntry.TestField("Entry Type", POSEntry."Entry Type"::"Credit Sale");

        Assert.IsFalse(SalePOS.Find(), 'Sale must end when exporting to sales order');

        POSEntrySalesDocLink.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesDocLink.SetRange("POS Entry Reference Type", POSEntrySalesDocLink."POS Entry Reference Type"::HEADER);
        POSEntrySalesDocLink.SetRange("Sales Document Type", POSEntrySalesDocLink."Sales Document Type"::ORDER);
        POSEntrySalesDocLink.FindFirst();
        Assert.IsFalse(SalesHeader.Get(SalesHeader."Document Type"::Order, POSEntrySalesDocLink."Sales Document No"), 'Sales Header must be gone after full posting');
        POSEntrySalesDocLink.SetRange("Sales Document Type", POSEntrySalesDocLink."Sales Document Type"::POSTED_INVOICE);
        POSEntrySalesDocLink.FindFirst();
        SalesInvoiceHeader.Get(POSEntrySalesDocLink."Sales Document No");
        POSEntrySalesDocLink.SetRange("Sales Document Type", POSEntrySalesDocLink."Sales Document Type"::SHIPMENT);
        POSEntrySalesDocLink.FindFirst();
        SalesShipmentHeader.Get(POSEntrySalesDocLink."Sales Document No");

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExportBOMItemWithAssembleToOrderPolicy()
    var
        SalePOS: Record "NPR POS Sale";
        POSEntry: Record "NPR POS Entry";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalesHeader: Record "Sales Header";
        AssemblyHeader: Record "Assembly Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Item: Record Item;
        AssembleToOrderLink: Record "Assemble-to-Order Link";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        Assert: Codeunit "Assert";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
    begin
        // [Scenario] Check that a successful export of item with Assemble-To-Order Assembly Policy creates corresponding Assembly Order alongside with regular Sales Order.

        // [Given] POS & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSale);

        // [Given] Item Line
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        AddBOMAndAssemblyPolicyToItem(Item);
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [Given] Customer applied to sale
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, _Customer."No.", false);

        // [When] Exporting to sales order without posting                
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        ExportPOSSAlesToSalesOrder(POSSale, false, false, SalesHeader);

        // [Then] POS entry created as credit sale, POS sale ended and sales document is created, open and linked to POS entry.
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        Assert.IsTrue(POSEntry.FindFirst(), 'Related POS Entry not found.');
        Assert.IsTrue(POSEntry."Entry Type" = POSEntry."Entry Type"::"Credit Sale", 'POS Entry not created as Credit Sale.');

        Assert.IsFalse(SalePOS.Find(), 'Sale must end when exporting to sales order');

        AssembleToOrderLink.SetRange("Document Type", Enum::"Assembly Document Type"::Order);
        AssembleToOrderLink.SetRange("Document No.", POSEntry."Sales Document No.");
        AssembleToOrderLink.SetRange("Document Line No.", SaleLinePOS."Line No.");
        Assert.IsTrue(AssembleToOrderLink.FindFirst(), 'Assemble-To-Order not found.');

        Assert.IsTrue(AssemblyHeader.Get(Enum::"Assembly Document Type"::Order, AssembleToOrderLink."Assembly Document No."), 'Assembly Order must be created.');
    end;

    procedure InitializeData()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibrarySales: Codeunit "Library - Sales";
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
            NPRLibraryPOSMasterData.CreateSalespersonForPOSUsage(_Salesperson);
            LibrarySales.CreateCustomerWithAddress(_Customer);
            _Initialized := true;
        end;

        Commit();
    end;

    #region NPRGroupCodesSelectEnqueuedOptionPageHandler
    [ModalPageHandler]
    procedure NPRGroupCodesSelectEnqueuedOptionPageHandler(var NPRGroupCodes: TestPage "NPR Group Codes")
    begin
        NPRGroupCodes.GoToRecord(_NPRGroupCode);
        NPRGroupCodes.OK().Invoke();
    end;
    #endregion NPRGroupCodesSelectEnqueuedOptionPageHandler


    #region NPRGroupCodesCancelOpenPageHandler
    [ModalPageHandler]
    procedure NPRGroupCodesCancelOpenPageHandler(var NPRGroupCodes: TestPage "NPR Group Codes")
    begin
        NPRGroupCodes.Cancel().Invoke();
    end;
    #endregion NPRGroupCodesCancelOpenPageHandler

    #region CheckGroupCodeInCreatedSalesDocument
    local procedure CheckGroupCodeInCreatedSalesDocument(SalePOS: Record "NPR POS Sale";
                                                         SalesHeader: Record "Sales Header";
                                                         GroupCodesEnabled: Boolean;
                                                         GroupCode: Code[10])
    var
        Assert: Codeunit Assert;
    begin
        if GroupCodesEnabled then begin
            Assert.IsTrue(SalePOS."Group Code" = GroupCode, 'Group Code not assigned correctly to POS Sale');
            Assert.IsTrue(SalesHeader."NPR Group Code" = GroupCode, 'Group Code not assigned correctly to Sales Header');
            Assert.IsTrue(SalePOS."Group Code" = SalesHeader."NPR Group Code", 'Sales Header and POS Sales Group Codes match');
        end else begin
            Assert.IsTrue(SalePOS."Group Code" = '', 'Group Code not assigned correctly to POS Sale');
            Assert.IsTrue(SalesHeader."NPR Group Code" = '', 'Group Code not assigned correctly to Sales Header');
        end;

    end;
    #endregion CheckGroupCodeInCreatedSalesDocument

    #region CreatePOSSaleWithCustomerAndItemLineAndAssignGroupCode
    local procedure CreatePOSSaleWithCustomerAndItemLineAndAssignGroupCode(var SalePOS: Record "NPR POS Sale";
                                                                           var POSSale: Codeunit "NPR POS Sale";
                                                                           GroupCodeEnabled: Boolean;
                                                                           GroupCode: Code[10])
    var
        Item: Record Item;
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        NPRPOSActionDocExport: Codeunit "NPR POS Action: Doc. Export";
    begin
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSale);

        POSSale.GetCurrentSale(SalePOS);

        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);

        Item."Unit Price" := 10;
        Item.Modify();

        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, _Customer."No.", false);

        NPRPOSActionDocExport.SetGroupCode(SalePOS, GroupCodeEnabled, GroupCode);
    end;
    #endregion CreatePOSSaleWithCustomerAndItemLineAndAssignGroupCode

    #region ExportPOSSAlesToSalesOrder
    local procedure ExportPOSSAlesToSalesOrder(var POSSale: Codeunit "NPR POS Sale";
                                               Ship: Boolean;
                                               Invoice: Boolean;
                                               var SalesHeader: Record "Sales Header")
    var
        SalesDocumentExportMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
    begin
        SalesDocumentExportMgt.SetDocumentTypeOrder();
        SalesDocumentExportMgt.SetShip(ship);
        SalesDocumentExportMgt.SetInvoice(Invoice);
        SalesDocumentExportMgt.ProcessPOSSale(POSSale);
        SalesDocumentExportMgt.GetCreatedSalesHeader(SalesHeader);
    end;
    #endregion ExportPOSSAlesToSalesOrder

    #region ModifyItemWithBOMAndAssemblyPolicy
    local procedure AddBOMAndAssemblyPolicyToItem(var BOMItem: Record Item)
    var
        LibraryInventory: Codeunit "Library - Inventory";
        BOMComponentItem: Record Item;
        BOMComponent: Record "BOM Component";
    begin
        LibraryInventory.CreateItem(BOMComponentItem);
        BOMComponent.Init();
        BOMComponent."Parent Item No." := BOMItem."No.";
        BOMComponent."No." := BOMComponentItem."No.";
        BOMComponent."Line No." := 10000;
        BOMComponent.Insert();

        BOMItem."Assembly Policy" := "Assembly Policy"::"Assemble-to-Order";
        BOMItem."Replenishment System" := "Replenishment System"::Assembly;
        BOMItem.Modify();
    end;
    #endregion ModifyItemWithBOMAndAssemblyPolicy
}