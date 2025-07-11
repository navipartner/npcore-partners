codeunit 85067 "NPR POS Act. ImpPstdInv Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Initialized: Boolean;
        PostedInvoiceNo: Code[20];
        POSUnit: Record "NPR POS Unit";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ClickOnOKMsg')]

    procedure TestPostedInvToPOSNegativeValues()
    var
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSession: Codeunit "NPR POS Session";
        LibrarySales: Codeunit "Library - Sales";
        SalesHeader: record "Sales Header";
        POSActImpPstdInvB: Codeunit "NPR POS Action: Imp. PstdInv B";
        SalesInvHdr: Record "Sales Invoice Header";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        SalesInvLine: Record "Sales Invoice Line";
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        //[GIVEN] given
        NPRLibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        LibrarySales.CreateSalesInvoice(SalesHeader);
        PostedInvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, false, true);

        SalesInvHdr.Get(PostedInvoiceNo);

        // [GIVEN] Posting Setup for Posted Invoice Lines
        CreatePostingSetup(PostedInvoiceNo);

        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        POSActImpPstdInvB.SetPosSaleCustomer(POSSale, SalesInvHdr."Bill-to Customer No.");

        POSActImpPstdInvB.PostedInvToPOS(POSSession, SalesInvHdr, true, true, true, true, '');

        SalesInvLine.SetRange("Document No.", SalesInvHdr."No.");
        SalesInvLine.FindFirst();

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("No.", SalesInvLine."No.");

        Assert.IsTrue(SaleLinePOS.FindFirst(), 'Item line inserted');
        Assert.IsTrue(SaleLinePOS.Quantity = -SalesInvLine.Quantity, 'Quantity reversed');
        Assert.IsTrue(SaleLinePOS."Unit Price" = SalesInvLine."Unit Price", 'Unit price inserted');
        Assert.IsTrue(SaleLinePOS."Unit of Measure Code" = SalesInvLine."Unit of Measure Code", 'Unit of measure inserted');
        Assert.IsTrue(SaleLinePOS.Description = SalesInvLine.Description, 'Description inserted');
        Assert.IsTrue(SaleLinePOS."Description 2" = SalesInvLine."Description 2", 'Description 2 inserted');
        Assert.IsTrue(SaleLinePOS."Variant Code" = SalesInvLine."Variant Code", 'Variant Code inserted');
        Assert.IsTrue(SaleLinePOS."Discount %" = SalesInvLine."Line Discount %", 'Discount % inserted');
        Assert.IsTrue(SaleLinePOS."Discount Amount" = SalesInvLine."Line Discount Amount", 'Discount Amount inserted');
        Assert.IsTrue(SaleLinePOS."Bin Code" = SalesInvLine."Bin Code", 'Bin Code inserted');
        Assert.IsTrue(SaleLinePOS."Shortcut Dimension 1 Code" = SalesInvLine."Shortcut Dimension 1 Code", 'Shortcut Dimension 1 inserted');
        Assert.IsTrue(SaleLinePOS."Shortcut Dimension 2 Code" = SalesInvLine."Shortcut Dimension 2 Code", 'Shortcut Dimension 2 inserted');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ClickOnOKMsg')]

    procedure TestPostedInvToPOSPositiveValues()
    var
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSession: Codeunit "NPR POS Session";
        LibrarySales: Codeunit "Library - Sales";
        SalesHeader: record "Sales Header";
        POSActImpPstdInvB: Codeunit "NPR POS Action: Imp. PstdInv B";
        SalesInvHdr: Record "Sales Invoice Header";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        SalesInvLine: Record "Sales Invoice Line";
        SaleLinePOS: Record "NPR POS Sale Line";
    begin

        //[GIVEN] given
        NPRLibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);

        LibrarySales.CreateSalesInvoice(SalesHeader);
        PostedInvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, false, true);

        SalesInvHdr.Get(PostedInvoiceNo);

        // [GIVEN] Posting Setup for Posted Invoice Lines
        CreatePostingSetup(PostedInvoiceNo);

        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        POSActImpPstdInvB.SetPosSaleCustomer(POSSale, SalesInvHdr."Bill-to Customer No.");

        POSActImpPstdInvB.PostedInvToPOS(POSSession, SalesInvHdr, false, true, true, true, '');

        SalesInvLine.SetRange("Document No.", SalesInvHdr."No.");
        SalesInvLine.FindFirst();

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("No.", SalesInvLine."No.");

        Assert.IsTrue(SaleLinePOS.FindFirst(), 'Item line inserted');
        Assert.IsTrue(SaleLinePOS.Quantity = SalesInvLine.Quantity, 'Quantity inserted');
        Assert.IsTrue(SaleLinePOS."Unit Price" = SalesInvLine."Unit Price", 'Unit price inserted');
        Assert.IsTrue(SaleLinePOS."Unit of Measure Code" = SalesInvLine."Unit of Measure Code", 'Unit of measure inserted');
        Assert.IsTrue(SaleLinePOS.Description = SalesInvLine.Description, 'Description inserted');
        Assert.IsTrue(SaleLinePOS."Description 2" = SalesInvLine."Description 2", 'Description 2 inserted');
        Assert.IsTrue(SaleLinePOS."Variant Code" = SalesInvLine."Variant Code", 'Variant Code inserted');
        Assert.IsTrue(SaleLinePOS."Discount %" = SalesInvLine."Line Discount %", 'Discount % inserted');
        Assert.IsTrue(SaleLinePOS."Discount Amount" = SalesInvLine."Line Discount Amount", 'Discount Amount inserted');
        Assert.IsTrue(SaleLinePOS."Bin Code" = SalesInvLine."Bin Code", 'Bin Code inserted');
        Assert.IsTrue(SaleLinePOS."Shortcut Dimension 1 Code" = SalesInvLine."Shortcut Dimension 1 Code", 'Shortcut Dimension 1 inserted');
        Assert.IsTrue(SaleLinePOS."Shortcut Dimension 2 Code" = SalesInvLine."Shortcut Dimension 2 Code", 'Shortcut Dimension 2 inserted');
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TestPOSSaleCustomer()
    var
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        LibrarySales: Codeunit "Library - Sales";
        Customer: Record Customer;
        POSActImpPstdInvB: Codeunit "NPR POS Action: Imp. PstdInv B";

    begin
        //[GIVEN] given
        NPRLibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        LibrarySales.CreateCustomer(Customer);

        POSActImpPstdInvB.SetPosSaleCustomer(POSSale, Customer."No.");

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        Assert.IsTrue(SalePOS."Customer No." = Customer."No.", 'Customer inserted');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TestUpdateSalesPerson()
    var
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        LibrarySales: Codeunit "Library - Sales";
        POSActImpPstdInvB: Codeunit "NPR POS Action: Imp. PstdInv B";
        SalesHeader: record "Sales Header";
        SalesInvHdr: Record "Sales Invoice Header";
        VATPostingSetup: Record "VAT Posting Setup";
        SalesPerson: Record "Salesperson/Purchaser";

    begin
        //[GIVEN] given
        NPRLibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        LibrarySales.CreateSalesInvoice(SalesHeader);
        LibrarySales.CreateSalesperson(SalesPerson);

        SalesHeader.Validate("Salesperson Code", SalesPerson.Code);
        SalesHeader.Modify();

        PostedInvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, false, true);

        SalesInvHdr.Get(PostedInvoiceNo);

        // [GIVEN] Posting Setup for Posted Invoice Lines
        CreatePostingSetup(PostedInvoiceNo);

        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        POSActImpPstdInvB.UpdateSalesPerson(POSSale, SalesInvHdr);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        Assert.IsTrue(SalePOS."Salesperson Code" = SalesInvHdr."Salesperson Code", 'Salesperson inserted');
    end;

    [MessageHandler]
    procedure ClickOnOKMsg(Msg: Text[1024])
    var
        DOCUMENT_IMPORTED: Label 'Invoice %1 was imported in POS.';
    begin
        Assert.IsTrue(Msg = StrSubstNo(DOCUMENT_IMPORTED, PostedInvoiceNo), Msg);
    end;

    local procedure CreatePostingSetup(PostedInvoiceNo: Code[20])
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        Item: Record Item;
        LibraryPOSMasterData: codeunit "NPR Library - POS Master Data";
    begin
        SalesInvoiceLine.SetRange("Document No.", PostedInvoiceNo);
        SalesInvoiceLine.SetRange(Type, "Sales Line Type"::Item);
        SalesInvoiceLine.SetLoadFields("No.");
        if SalesInvoiceLine.FindSet() then
            repeat
                Item.Get(SalesInvoiceLine."No.");
                LibraryPOSMasterData.CreatePostingSetupForSaleItem(Item, POSUnit, POSStore);
            until SalesInvoiceLine.Next() = 0;
    end;
}