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

    [Test]
    procedure ExportToOrderWithoutPosting()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        POSEntry: Record "NPR POS Entry";
        SalesHeader: Record "Sales Header";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
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
        SelectCustomerAction.AttachCustomer(_POSSession, '', 0, _Customer."No.");

        // [When] Exporting to sales order without posting                
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalesDocumentExportMgt.SetDocumentTypeOrder();
        SalesDocumentExportMgt.ProcessPOSSale(SalePOS);

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
    procedure ExportToOrderWithFullPosting()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        POSEntry: Record "NPR POS Entry";
        SalesHeader: Record "Sales Header";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
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
        SelectCustomerAction.AttachCustomer(_POSSession, '', 0, _Customer."No.");

        // [When] Exporting to sales order with posting                
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalesDocumentExportMgt.SetDocumentTypeOrder();
        SalesDocumentExportMgt.SetInvoice(true);
        SalesDocumentExportMgt.SetShip(true);
        SalesDocumentExportMgt.ProcessPOSSale(SalePOS);

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



    procedure InitializeData()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibrarySales: Codeunit "Library - Sales";
    begin
        if _Initialized then begin
            //Clean any previous mock session
            _POSSession.Destructor();
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
}