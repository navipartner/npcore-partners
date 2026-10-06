codeunit 85505 "NPR POS Rev. Credit Sale Tests"
{
    // [Feature] REVERSE_CREDIT_SALE: import a posted invoice into POS with negative quantities and export it as a credit memo

    Subtype = Test;

    var
        _POSUnit: Record "NPR POS Unit";
        _POSStore: Record "NPR POS Store";
        _Salesperson: Record "Salesperson/Purchaser";
        _POSSession: Codeunit "NPR POS Session";
        _Assert: Codeunit Assert;
        _Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure LotItem_ExactCostReversingMandatory_CreditMemoPosts()
    var
        Item: Record Item;
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SaleItemLedgerEntry: Record "Item Ledger Entry";
        LotNo: Code[50];
        PostedCrMemoNo: Code[20];
    begin
        // [Scenario] With Exact Cost Reversing Mandatory, the credit memo created by reversing a posted invoice of a lot tracked item can be posted and is cost-applied to the original sale

        // [Given] Exact Cost Reversing Mandatory
        InitializeData();
        SetExactCostReversingMandatory(true);

        // [Given] A posted invoice for a lot tracked item
        CreateLotItemWithInventory(Item, LotNo);
        CreateCustomer(Customer);
        PostSalesInvoice(Customer, Item, LotNo, 2);
        FindSaleItemLedgerEntry(Item, SaleItemLedgerEntry);

        // [When] Reversing the invoice in POS into a credit memo and posting the credit memo
        ReverseInvoiceToCreditMemo(Customer, SalesHeader);
        PostedCrMemoNo := PostCreditMemo(SalesHeader);

        // [Then] The credit memo is posted and its return is cost-applied to the original sale entry
        VerifyReturnAppliedToSale(Item, SaleItemLedgerEntry);
        _Assert.AreNotEqual('', PostedCrMemoNo, 'Credit memo must be posted');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure LotItem_CreditMemoTrackingIsInboundAndAppliedFromSale()
    var
        Item: Record Item;
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SaleItemLedgerEntry: Record "Item Ledger Entry";
        ReservationEntry: Record "Reservation Entry";
        LotNo: Code[50];
    begin
        // [Scenario] The item tracking created on the credit memo line is an inbound lot entry pointing back at the original sale entry

        // [Given] A posted invoice for a lot tracked item
        InitializeData();
        SetExactCostReversingMandatory(false);
        CreateLotItemWithInventory(Item, LotNo);
        CreateCustomer(Customer);
        PostSalesInvoice(Customer, Item, LotNo, 2);
        FindSaleItemLedgerEntry(Item, SaleItemLedgerEntry);

        // [When] Reversing the invoice in POS into a credit memo
        ReverseInvoiceToCreditMemo(Customer, SalesHeader);

        // [Then] The credit memo line has a positive quantity and an inbound lot tracking entry applied from the sale
        FindItemSalesLine(SalesHeader, Item, SalesLine);
        _Assert.AreEqual(2, SalesLine.Quantity, 'Credit memo line quantity');

        ReservationEntry.SetRange("Source Type", Database::"Sales Line");
        ReservationEntry.SetRange("Source Subtype", SalesLine."Document Type".AsInteger());
        ReservationEntry.SetRange("Source ID", SalesLine."Document No.");
        ReservationEntry.SetRange("Source Ref. No.", SalesLine."Line No.");
        _Assert.IsTrue(ReservationEntry.FindFirst(), 'Item tracking must exist on the credit memo line');
        _Assert.AreEqual(LotNo, ReservationEntry."Lot No.", 'Lot No. on credit memo tracking');
        _Assert.AreEqual(2, ReservationEntry."Quantity (Base)", 'Credit memo tracking quantity must be positive (inbound)');
        _Assert.IsTrue(ReservationEntry.Positive, 'Credit memo tracking must be inbound');
        _Assert.AreEqual(ReservationEntry."Item Tracking"::"Lot No.", ReservationEntry."Item Tracking", 'Item Tracking type on credit memo tracking');
        _Assert.AreEqual(SaleItemLedgerEntry."Entry No.", ReservationEntry."Appl.-from Item Entry", 'Appl.-from Item Entry on credit memo tracking');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UntrackedItem_ExactCostReversingMandatory_CreditMemoPosts()
    var
        Item: Record Item;
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SaleItemLedgerEntry: Record "Item Ledger Entry";
        PostedCrMemoNo: Code[20];
    begin
        // [Scenario] With Exact Cost Reversing Mandatory, the credit memo created by reversing a posted invoice of an untracked item can be posted and is cost-applied to the original sale

        // [Given] Exact Cost Reversing Mandatory
        InitializeData();
        SetExactCostReversingMandatory(true);

        // [Given] A posted invoice for an untracked item
        CreateItemWithInventory(Item);
        CreateCustomer(Customer);
        PostSalesInvoice(Customer, Item, '', 2);
        FindSaleItemLedgerEntry(Item, SaleItemLedgerEntry);

        // [When] Reversing the invoice in POS into a credit memo
        ReverseInvoiceToCreditMemo(Customer, SalesHeader);

        // [Then] The credit memo posts and is cost-applied to the original sale entry
        PostedCrMemoNo := PostCreditMemo(SalesHeader);
        VerifyReturnAppliedToSale(Item, SaleItemLedgerEntry);
        _Assert.AreNotEqual('', PostedCrMemoNo, 'Credit memo must be posted');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure LotItem_ExactCostReversingNotMandatory_CreditMemoPosts()
    var
        Item: Record Item;
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        ReturnItemLedgerEntry: Record "Item Ledger Entry";
        LotNo: Code[50];
        PostedCrMemoNo: Code[20];
    begin
        // [Scenario] Without Exact Cost Reversing Mandatory, the reversed credit memo for a lot tracked item posts and returns the sold lot to inventory

        // [Given] Exact Cost Reversing not mandatory
        InitializeData();
        SetExactCostReversingMandatory(false);

        // [Given] A posted invoice for a lot tracked item
        CreateLotItemWithInventory(Item, LotNo);
        CreateCustomer(Customer);
        PostSalesInvoice(Customer, Item, LotNo, 2);

        // [When] Reversing the invoice in POS into a credit memo and posting the credit memo
        ReverseInvoiceToCreditMemo(Customer, SalesHeader);
        PostedCrMemoNo := PostCreditMemo(SalesHeader);

        // [Then] The credit memo is posted and the sold lot is returned to inventory
        _Assert.AreNotEqual('', PostedCrMemoNo, 'Credit memo must be posted');
        ReturnItemLedgerEntry.SetRange("Item No.", Item."No.");
        ReturnItemLedgerEntry.SetRange("Entry Type", ReturnItemLedgerEntry."Entry Type"::Sale);
        ReturnItemLedgerEntry.SetRange(Positive, true);
        _Assert.IsTrue(ReturnItemLedgerEntry.FindFirst(), 'Return item ledger entry must exist');
        _Assert.AreEqual(LotNo, ReturnItemLedgerEntry."Lot No.", 'Lot No. on return');
        _Assert.AreEqual(2, ReturnItemLedgerEntry.Quantity, 'Returned quantity');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure UntrackedItem_AlreadyReturnedInvoice_CreditMemoCreatedWithoutApplication()
    var
        Item: Record Item;
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [Scenario] Reversing an invoice that was already fully returned still creates the credit memo, without applying it to the sale entry

        // [Given] Exact Cost Reversing not mandatory
        InitializeData();
        SetExactCostReversingMandatory(false);

        // [Given] A posted invoice for an untracked item that was already fully returned
        CreateItemWithInventory(Item);
        CreateCustomer(Customer);
        PostSalesInvoice(Customer, Item, '', 2);
        ReverseInvoiceToCreditMemo(Customer, SalesHeader);
        PostCreditMemo(SalesHeader);

        // [When] Reversing the same invoice again
        ReverseInvoice(Customer, SalesHeader);

        // [Then] The credit memo is created and its line is not applied to the fully returned sale entry
        FindItemSalesLine(SalesHeader, Item, SalesLine);
        _Assert.AreEqual(2, SalesLine.Quantity, 'Credit memo line quantity');
        _Assert.AreEqual(0, SalesLine."Appl.-from Item Entry", 'Appl.-from Item Entry on credit memo line');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UntrackedItem_InvoiceWithNegativeLine_CreditMemoExportsAndPosts()
    var
        SoldItem: Record Item;
        ReturnedItem: Record Item;
        Customer: Record Customer;
        InvoiceSalesHeader: Record "Sales Header";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SaleItemLedgerEntry: Record "Item Ledger Entry";
        PostedCrMemoNo: Code[20];
    begin
        // [Scenario] Reversing an exchange invoice (one item sold, another taken back on a negative line) exports and posts, and only the sold item is cost-applied

        // [Given] Exact Cost Reversing not mandatory
        InitializeData();
        SetExactCostReversingMandatory(false);

        // [Given] A posted invoice with a sold item and a negative line for a returned item
        CreateItemWithInventory(SoldItem);
        CreateItemWithInventory(ReturnedItem);
        SoldItem.Find();
        SoldItem.Validate("Unit Price", 100);
        SoldItem.Modify(true);
        ReturnedItem.Find();
        ReturnedItem.Validate("Unit Price", 10);
        ReturnedItem.Modify(true);
        CreateCustomer(Customer);
        CreateSalesInvoice(Customer, InvoiceSalesHeader);
        AddSalesInvoiceLine(InvoiceSalesHeader, SoldItem, '', 1);
        AddSalesInvoiceLine(InvoiceSalesHeader, ReturnedItem, '', -1);
        PostSalesInvoice(InvoiceSalesHeader);
        FindSaleItemLedgerEntry(SoldItem, SaleItemLedgerEntry);

        // [When] Reversing the invoice in POS into a credit memo
        ReverseInvoiceToCreditMemo(Customer, SalesHeader);

        // [Then] The negative line is not applied and the sold item line is applied to its sale entry
        FindItemSalesLine(SalesHeader, ReturnedItem, SalesLine);
        _Assert.AreEqual(-1, SalesLine.Quantity, 'Credit memo line quantity for the item taken back');
        _Assert.AreEqual(0, SalesLine."Appl.-from Item Entry", 'Appl.-from Item Entry for the item taken back');
        FindItemSalesLine(SalesHeader, SoldItem, SalesLine);
        _Assert.AreEqual(SaleItemLedgerEntry."Entry No.", SalesLine."Appl.-from Item Entry", 'Appl.-from Item Entry for the sold item');

        // [Then] The credit memo posts
        PostedCrMemoNo := PostCreditMemo(SalesHeader);
        _Assert.AreNotEqual('', PostedCrMemoNo, 'Credit memo must be posted');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UntrackedItem_TwoInvoiceLines_ExactCostReversingMandatory_CreditMemoPosts()
    var
        Item: Record Item;
        Customer: Record Customer;
        InvoiceSalesHeader: Record "Sales Header";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        FirstApplFromItemEntry: Integer;
        PostedCrMemoNo: Code[20];
    begin
        // [Scenario] With Exact Cost Reversing Mandatory, an invoice with the same untracked item on two lines reverses into a credit memo where each line is applied to its own sale entry

        // [Given] Exact Cost Reversing Mandatory
        InitializeData();
        SetExactCostReversingMandatory(true);

        // [Given] A posted invoice with the same untracked item on two lines
        CreateItemWithInventory(Item);
        CreateCustomer(Customer);
        CreateSalesInvoice(Customer, InvoiceSalesHeader);
        AddSalesInvoiceLine(InvoiceSalesHeader, Item, '', 1);
        AddSalesInvoiceLine(InvoiceSalesHeader, Item, '', 1);
        PostSalesInvoice(InvoiceSalesHeader);

        // [When] Reversing the invoice in POS into a credit memo
        ReverseInvoiceToCreditMemo(Customer, SalesHeader);

        // [Then] Each credit memo line is applied to a different sale entry
        FindItemSalesLine(SalesHeader, Item, SalesLine);
        _Assert.AreEqual(2, SalesLine.Count(), 'Credit memo item lines');
        _Assert.AreNotEqual(0, SalesLine."Appl.-from Item Entry", 'Appl.-from Item Entry on first credit memo line');
        FirstApplFromItemEntry := SalesLine."Appl.-from Item Entry";
        SalesLine.Next();
        _Assert.AreNotEqual(0, SalesLine."Appl.-from Item Entry", 'Appl.-from Item Entry on second credit memo line');
        _Assert.AreNotEqual(FirstApplFromItemEntry, SalesLine."Appl.-from Item Entry", 'Credit memo lines must be applied to different sale entries');

        // [Then] The credit memo posts and every sale entry is cost-applied
        PostedCrMemoNo := PostCreditMemo(SalesHeader);
        _Assert.AreNotEqual('', PostedCrMemoNo, 'Credit memo must be posted');
        VerifyEverySaleCostApplied(Item);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure LotItem_TwoInvoiceLinesSameLot_ExactCostReversingMandatory_CreditMemoPosts()
    var
        Item: Record Item;
        Customer: Record Customer;
        InvoiceSalesHeader: Record "Sales Header";
        SalesHeader: Record "Sales Header";
        LotNo: Code[50];
        PostedCrMemoNo: Code[20];
    begin
        // [Scenario] With Exact Cost Reversing Mandatory, an invoice with the same lot on two lines reverses into a credit memo that posts and is cost-applied to both sale entries

        // [Given] Exact Cost Reversing Mandatory
        InitializeData();
        SetExactCostReversingMandatory(true);

        // [Given] A posted invoice with the same lot on two lines
        CreateLotItemWithInventory(Item, LotNo);
        CreateCustomer(Customer);
        CreateSalesInvoice(Customer, InvoiceSalesHeader);
        AddSalesInvoiceLine(InvoiceSalesHeader, Item, LotNo, 1);
        AddSalesInvoiceLine(InvoiceSalesHeader, Item, LotNo, 1);
        PostSalesInvoice(InvoiceSalesHeader);

        // [When] Reversing the invoice in POS into a credit memo and posting the credit memo
        ReverseInvoiceToCreditMemo(Customer, SalesHeader);
        PostedCrMemoNo := PostCreditMemo(SalesHeader);

        // [Then] The credit memo is posted and every sale entry is cost-applied
        _Assert.AreNotEqual('', PostedCrMemoNo, 'Credit memo must be posted');
        VerifyEverySaleCostApplied(Item);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure LotItem_NotImportedFromInvoice_ReturnOrderTrackingIsInboundWithoutApplication()
    var
        Item: Record Item;
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ReservationEntry: Record "Reservation Entry";
        LibrarySales: Codeunit "Library - Sales";
        LotNo: Code[50];
    begin
        // [Scenario] A lot tracked POS return without a source invoice, exported as a return order, gets one inbound tracking entry without application and posts

        // [Given] Exact Cost Reversing not mandatory
        InitializeData();
        SetExactCostReversingMandatory(false);

        // [Given] A POS return of a lot tracked item that does not remember its source invoice
        CreateLotItemWithInventory(Item, LotNo);
        CreateCustomer(Customer);
        PostSalesInvoice(Customer, Item, LotNo, 2);

        // [When] Exporting the POS return as a return order
        ReverseInvoiceToDocument(Customer, false, SalesHeader."Document Type"::"Return Order", SalesHeader);

        // [Then] The return order line has exactly one inbound lot tracking entry without application
        FindItemSalesLine(SalesHeader, Item, SalesLine);
        _Assert.AreEqual(2, SalesLine.Quantity, 'Return order line quantity');
        _Assert.AreEqual(0, SalesLine."Appl.-from Item Entry", 'Appl.-from Item Entry on return order line');

        ReservationEntry.SetRange("Source Type", Database::"Sales Line");
        ReservationEntry.SetRange("Source Subtype", SalesLine."Document Type".AsInteger());
        ReservationEntry.SetRange("Source ID", SalesLine."Document No.");
        ReservationEntry.SetRange("Source Ref. No.", SalesLine."Line No.");
        _Assert.AreEqual(1, ReservationEntry.Count(), 'Item tracking entries on the return order line');
        ReservationEntry.FindFirst();
        _Assert.AreEqual(LotNo, ReservationEntry."Lot No.", 'Lot No. on return order tracking');
        _Assert.AreEqual(2, ReservationEntry."Quantity (Base)", 'Return order tracking quantity must be positive (inbound)');
        _Assert.IsTrue(ReservationEntry.Positive, 'Return order tracking must be inbound');
        _Assert.AreEqual(0, ReservationEntry."Appl.-from Item Entry", 'Appl.-from Item Entry on return order tracking');

        // [Then] The return order posts
        _Assert.AreNotEqual('', LibrarySales.PostSalesDocument(SalesHeader, true, true), 'Return order must be posted');
    end;

    local procedure InitializeData()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSSetup: Record "NPR POS Setup";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        _POSSession.ClearAll();
        Clear(_POSSession);

        if not _Initialized then begin
            NPRLibraryPOSMasterData.CreatePOSSetup(POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            NPRLibraryPOSMasterData.CreatePOSStore(_POSStore, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(_POSUnit, _POSStore.Code, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreateSalespersonForPOSUsage(_Salesperson);
            _Initialized := true;
        end;

        Commit();
    end;

    local procedure SetExactCostReversingMandatory(Mandatory: Boolean)
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup."Credit Memo Nos." := LibraryUtility.GetGlobalNoSeriesCode();
        SalesReceivablesSetup."Return Order Nos." := LibraryUtility.GetGlobalNoSeriesCode();
        SalesReceivablesSetup."Posted Credit Memo Nos." := LibraryUtility.GetGlobalNoSeriesCode();
        SalesReceivablesSetup."Posted Return Receipt Nos." := LibraryUtility.GetGlobalNoSeriesCode();
        SalesReceivablesSetup.Validate("Exact Cost Reversing Mandatory", Mandatory);
        SalesReceivablesSetup.Modify(true);
        Commit();
    end;

    local procedure CreateItemWithInventory(var Item: Record Item)
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        PostPositiveAdjustment(Item, '', 10);
    end;

    local procedure CreateLotItemWithInventory(var Item: Record Item; var LotNo: Code[50])
    var
        ItemTrackingCode: Record "Item Tracking Code";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryItemTracking: Codeunit "Library - Item Tracking";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        LibraryItemTracking.CreateItemTrackingCode(ItemTrackingCode, false, true);
        Item.Validate("Item Tracking Code", ItemTrackingCode.Code);
        Item.Modify(true);

        LotNo := LibraryUtility.GenerateGUID();
        PostPositiveAdjustment(Item, LotNo, 10);
    end;

    local procedure PostPositiveAdjustment(Item: Record Item; LotNo: Code[50]; Quantity: Decimal)
    var
        ItemJournalLine: Record "Item Journal Line";
        ReservationEntry: Record "Reservation Entry";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryItemTracking: Codeunit "Library - Item Tracking";
    begin
        LibraryInventory.CreateItemJournalLineInItemTemplate(ItemJournalLine, Item."No.", _POSStore."Location Code", '', Quantity);
        ItemJournalLine.Validate("Unit Amount", 10);
        ItemJournalLine.Modify(true);
        if LotNo <> '' then
            LibraryItemTracking.CreateItemJournalLineItemTracking(ReservationEntry, ItemJournalLine, '', LotNo, Quantity);
        LibraryInventory.PostItemJournalLine(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");
    end;

    local procedure CreateCustomer(var Customer: Record Customer)
    var
        LibrarySales: Codeunit "Library - Sales";
    begin
        LibrarySales.CreateCustomerWithAddress(Customer);
    end;

    local procedure PostSalesInvoice(Customer: Record Customer; Item: Record Item; LotNo: Code[50]; Quantity: Decimal)
    var
        SalesHeader: Record "Sales Header";
    begin
        CreateSalesInvoice(Customer, SalesHeader);
        AddSalesInvoiceLine(SalesHeader, Item, LotNo, Quantity);
        PostSalesInvoice(SalesHeader);
    end;

    local procedure PostSalesInvoice(var SalesHeader: Record "Sales Header")
    var
        LibrarySales: Codeunit "Library - Sales";
    begin
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
    end;

    local procedure CreateSalesInvoice(Customer: Record Customer; var SalesHeader: Record "Sales Header")
    var
        LibrarySales: Codeunit "Library - Sales";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
        SalesHeader.Validate("Location Code", _POSStore."Location Code");
        SalesHeader.Modify(true);
    end;

    local procedure AddSalesInvoiceLine(SalesHeader: Record "Sales Header"; Item: Record Item; LotNo: Code[50]; Quantity: Decimal)
    var
        SalesLine: Record "Sales Line";
        ReservationEntry: Record "Reservation Entry";
        LibrarySales: Codeunit "Library - Sales";
        LibraryItemTracking: Codeunit "Library - Item Tracking";
    begin
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", Quantity);
        if LotNo <> '' then
            LibraryItemTracking.CreateSalesOrderItemTracking(ReservationEntry, SalesLine, '', LotNo, Quantity);
    end;

    local procedure FindSaleItemLedgerEntry(Item: Record Item; var ItemLedgerEntry: Record "Item Ledger Entry")
    begin
        ItemLedgerEntry.SetRange("Item No.", Item."No.");
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Sale);
        ItemLedgerEntry.FindFirst();
    end;

    local procedure ReverseInvoiceToCreditMemo(Customer: Record Customer; var SalesHeader: Record "Sales Header")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        ReverseInvoice(Customer, SalesHeader);
        SalesInvoiceHeader.SetRange("Sell-to Customer No.", Customer."No.");
        SalesInvoiceHeader.FindFirst();
        SalesHeader.TestField("Applies-to Doc. No.", SalesInvoiceHeader."No.");
    end;

    local procedure ReverseInvoice(Customer: Record Customer; var SalesHeader: Record "Sales Header")
    begin
        ReverseInvoiceToDocument(Customer, true, SalesHeader."Document Type"::"Credit Memo", SalesHeader);
    end;

    local procedure ReverseInvoiceToDocument(Customer: Record Customer; AppliesToInvoice: Boolean; DocumentType: Enum "Sales Document Type"; var SalesHeader: Record "Sales Header")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        POSSale: Codeunit "NPR POS Sale";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSActImpPstdInvB: Codeunit "NPR POS Action: Imp. PstdInv B";
        SalesDocExpMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
    begin
        SalesInvoiceHeader.SetRange("Sell-to Customer No.", Customer."No.");
        SalesInvoiceHeader.FindFirst();

        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSale);
        POSActImpPstdInvB.SetPosSaleCustomer(POSSale, SalesInvoiceHeader."Bill-to Customer No.");
        POSActImpPstdInvB.PostedInvToPOS(_POSSession, SalesInvoiceHeader, true, false, AppliesToInvoice, true, '');

        _POSSession.GetSale(POSSale);
        if DocumentType = SalesHeader."Document Type"::"Return Order" then
            SalesDocExpMgt.SetDocumentTypeReturnOrder()
        else
            SalesDocExpMgt.SetDocumentTypeCreditMemo();
        SalesDocExpMgt.ProcessPOSSale(POSSale);

        SalesHeader.SetRange("Document Type", DocumentType);
        SalesHeader.SetRange("Sell-to Customer No.", Customer."No.");
        SalesHeader.FindFirst();
    end;

    local procedure FindItemSalesLine(SalesHeader: Record "Sales Header"; Item: Record Item; var SalesLine: Record "Sales Line")
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetRange("No.", Item."No.");
        SalesLine.FindFirst();
    end;

    local procedure PostCreditMemo(var SalesHeader: Record "Sales Header"): Code[20]
    var
        LibrarySales: Codeunit "Library - Sales";
    begin
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure VerifyReturnAppliedToSale(Item: Record Item; SaleItemLedgerEntry: Record "Item Ledger Entry")
    var
        ReturnItemLedgerEntry: Record "Item Ledger Entry";
        ItemApplicationEntry: Record "Item Application Entry";
    begin
        ReturnItemLedgerEntry.SetRange("Item No.", Item."No.");
        ReturnItemLedgerEntry.SetRange("Entry Type", ReturnItemLedgerEntry."Entry Type"::Sale);
        ReturnItemLedgerEntry.SetRange(Positive, true);
        _Assert.IsTrue(ReturnItemLedgerEntry.FindFirst(), 'Return item ledger entry must exist');
        _Assert.AreEqual(SaleItemLedgerEntry."Lot No.", ReturnItemLedgerEntry."Lot No.", 'Lot No. on return');

        ItemApplicationEntry.SetRange("Inbound Item Entry No.", ReturnItemLedgerEntry."Entry No.");
        ItemApplicationEntry.SetRange("Outbound Item Entry No.", SaleItemLedgerEntry."Entry No.");
        ItemApplicationEntry.SetRange("Cost Application", true);
        _Assert.IsFalse(ItemApplicationEntry.IsEmpty(), 'Return must be cost-applied to the original sale entry');
    end;

    local procedure VerifyEverySaleCostApplied(Item: Record Item)
    var
        SaleItemLedgerEntry: Record "Item Ledger Entry";
        ItemApplicationEntry: Record "Item Application Entry";
    begin
        SaleItemLedgerEntry.SetRange("Item No.", Item."No.");
        SaleItemLedgerEntry.SetRange("Entry Type", SaleItemLedgerEntry."Entry Type"::Sale);
        SaleItemLedgerEntry.SetRange(Positive, false);
        _Assert.IsTrue(SaleItemLedgerEntry.FindSet(), 'Sale item ledger entries must exist');
        repeat
            ItemApplicationEntry.SetRange("Outbound Item Entry No.", SaleItemLedgerEntry."Entry No.");
            ItemApplicationEntry.SetRange("Cost Application", true);
            _Assert.IsFalse(ItemApplicationEntry.IsEmpty(), StrSubstNo('Sale entry %1 must be cost-applied to a return', SaleItemLedgerEntry."Entry No."));
        until SaleItemLedgerEntry.Next() = 0;
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerYes(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;
}
