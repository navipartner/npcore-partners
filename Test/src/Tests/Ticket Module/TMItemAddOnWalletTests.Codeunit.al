codeunit 85375 "NPR TM Item AddOn Wallet Tests"
{
    // [FEATURE] Wallet bundles for ticket item add-ons

    Subtype = Test;

    var
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _POSStore: Record "NPR POS Store";
        _POSUnit: Record "NPR POS Unit";
        _Assert: Codeunit "Assert";
        _LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        _LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        _LibraryTicketModule: Codeunit "NPR Library - Ticket Module";
        _POSSession: Codeunit "NPR POS Session";
        _Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RunItemAddOn_PerUnitWalletAddOn_ScalesTheChildQuantityWithTheParent()
    var
        ChildItem: Record Item;
        ChildSaleLine: Record "NPR POS Sale Line";
        ParentItem: Record Item;
        ParentSaleLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
    begin
        // [SCENARIO] A per-unit wallet add-on mints one child unit for every unit of the parent line

        // [GIVEN] A sale of two units of a parent item carrying a per-unit wallet add-on of a ticket item
        // [WHEN] The wallet item add-on is run for the parent line
        CreateWalletAddOnSale(2, ParentItem, ChildItem, SalePOS, ParentSaleLine, ChildSaleLine);

        // [THEN] The ticket child line quantity follows the parent quantity
        _Assert.AreEqual(2, ChildSaleLine.Quantity, 'The per-unit item add-on quantity was not calculated from the parent quantity.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EndSale_WalletAddOn_CreatesOneBundlePerSoldParentUnit()
    var
        BundleReference: Record "NPR NpIa POSEntryLineBundleId";
        ChildItem: Record Item;
        ChildPOSEntryLine: Record "NPR POS Entry Sales Line";
        ChildSaleLine: Record "NPR POS Sale Line";
        ParentItem: Record Item;
        ParentPOSEntryLine: Record "NPR POS Entry Sales Line";
        ParentSaleLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        FirstBundleReference: Text[50];
    begin
        // [SCENARIO] Ending a wallet add-on sale creates one uniquely referenced wallet bundle per sold parent unit

        // [GIVEN] A completed sale of two units of a parent item with a per-unit wallet ticket add-on
        CreateWalletAddOnSale(2, ParentItem, ChildItem, SalePOS, ParentSaleLine, ChildSaleLine);
        EndSale();

        // [WHEN] The posted lines and their wallet bundles are inspected
        ParentPOSEntryLine.GetBySystemId(ParentSaleLine.SystemId);
        ChildPOSEntryLine.GetBySystemId(ChildSaleLine.SystemId);
        BundleReference.SetRange(POSEntrySaleLineId, ParentSaleLine.SystemId);

        // [THEN] Both lines are posted and the parent line carries two distinct, non-blank bundle references
        _Assert.AreEqual(2, ParentPOSEntryLine.Quantity, 'The parent quantity was not posted.');
        _Assert.AreEqual(2, ChildPOSEntryLine.Quantity, 'The ticket child quantity was not posted.');
        _Assert.AreEqual(2, BundleReference.Count(), 'The parent POS entry line must have exactly two wallet bundles.');
        BundleReference.Get(ParentSaleLine.SystemId, 1);
        _Assert.AreNotEqual('', BundleReference.ReferenceNumber, 'The first wallet bundle reference is blank.');
        FirstBundleReference := BundleReference.ReferenceNumber;
        BundleReference.Get(ParentSaleLine.SystemId, 2);
        _Assert.AreNotEqual('', BundleReference.ReferenceNumber, 'The second wallet bundle reference is blank.');
        _Assert.AreNotEqual(FirstBundleReference, BundleReference.ReferenceNumber, 'Wallet bundle references must be distinct.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EndSale_WalletAddOn_KeepsThePostedAddOnRelationAfterTheSaleIsCleared()
    var
        ChildItem: Record Item;
        ChildSaleLine: Record "NPR POS Sale Line";
        ParentItem: Record Item;
        ParentSaleLine: Record "NPR POS Sale Line";
        POSEntrySaleLineAddOn: Record "NPR NpIa POSEntrySaleLineAddOn";
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
        SalePOS: Record "NPR POS Sale";
        AddOnNo: Code[20];
    begin
        // [SCENARIO] Clearing the sale-scoped add-on relations at end of sale leaves the posted add-on relation intact

        // [GIVEN] A completed sale of two units of a parent item with a per-unit wallet ticket add-on
        AddOnNo := CreateWalletAddOnSale(2, ParentItem, ChildItem, SalePOS, ParentSaleLine, ChildSaleLine);
        EndSale();

        // [WHEN] The add-on relations are looked up after the sale has been cleared
        SaleLinePOSAddOn.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOSAddOn.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");

        // [THEN] The sale-scoped relation is gone but the posted relation survives with its add-on details
        _Assert.IsTrue(SaleLinePOSAddOn.IsEmpty(), 'Transient item add-on relations remain after end of sale.');
        POSEntrySaleLineAddOn.Get(ChildSaleLine.SystemId);
        _Assert.AreEqual(ParentSaleLine.SystemId, POSEntrySaleLineAddOn.AppliesToSaleLineId, 'The child relation points to another parent line.');
        _Assert.AreEqual(AddOnNo, POSEntrySaleLineAddOn.AddOnNo, 'The child relation lost the item add-on number.');
        _Assert.AreEqual(10000, POSEntrySaleLineAddOn.AddOnLineNo, 'The child relation lost the item add-on line number.');
        _Assert.AreEqual(ChildItem."No.", POSEntrySaleLineAddOn.AddOnItemNo, 'The child relation lost the item add-on item number.');
        _Assert.IsTrue(POSEntrySaleLineAddOn.AddToWallet, 'The child relation is not marked for the wallet.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EndSale_WalletTicketAddOn_AssignsADistinctTicketToEachBundle()
    var
        BundleAsset: Record "NPR NpIa POSEntryLineBndlAsset";
        ChildItem: Record Item;
        ChildSaleLine: Record "NPR POS Sale Line";
        ParentItem: Record Item;
        ParentSaleLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        TicketSystemIds: List of [Guid];
        FirstTicketSystemId: Guid;
    begin
        // [SCENARIO] The tickets minted by a wallet ticket add-on are spread one per wallet bundle

        // [GIVEN] A completed sale of two units of a parent item with a per-unit wallet ticket add-on
        CreateWalletAddOnSale(2, ParentItem, ChildItem, SalePOS, ParentSaleLine, ChildSaleLine);
        EndSale();

        // [WHEN] The tickets minted for the child line and the wallet bundle assets are collected
        CollectTicketsOfSaleLine(SalePOS, ChildSaleLine, TicketSystemIds);
        BundleAsset.SetRange(POSEntrySaleLineId, ChildSaleLine.SystemId);
        BundleAsset.SetRange(AppliesToSaleLineId, ParentSaleLine.SystemId);
        BundleAsset.SetRange(AssetTableId, Database::"NPR TM Ticket");

        // [THEN] Two tickets were minted and each bundle holds a different one of them
        _Assert.AreEqual(2, TicketSystemIds.Count(), 'The ticket child line must mint exactly two tickets.');
        _Assert.AreEqual(2, BundleAsset.Count(), 'The ticket child line must have exactly two wallet bundle assets.');
        BundleAsset.SetRange(Bundle, 1);
        BundleAsset.FindFirst();
        _Assert.IsTrue(TicketSystemIds.Contains(BundleAsset.AssetSystemId), 'The first wallet bundle does not contain a ticket from the child line.');
        FirstTicketSystemId := BundleAsset.AssetSystemId;
        BundleAsset.SetRange(Bundle, 2);
        BundleAsset.FindFirst();
        _Assert.IsTrue(TicketSystemIds.Contains(BundleAsset.AssetSystemId), 'The second wallet bundle does not contain a ticket from the child line.');
        _Assert.AreNotEqual(FirstTicketSystemId, BundleAsset.AssetSystemId, 'The same ticket was assigned to both wallet bundles.');
    end;

    local procedure CreateWalletAddOnSale(ParentQuantity: Decimal; var ParentItem: Record Item; var ChildItem: Record Item; var SalePOS: Record "NPR POS Sale"; var ParentSaleLine: Record "NPR POS Sale Line"; var ChildSaleLine: Record "NPR POS Sale Line") AddOnNo: Code[20]
    var
        ItemReference: Record "Item Reference";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSActionInsertItem: Codeunit "NPR POS Action: Insert Item B";
        POSActionRunItemAddOn: Codeunit "NPR POS Action: RunItemAddOn B";
        POSSale: Codeunit "NPR POS Sale";
        UserSelectionJToken: JsonToken;
    begin
        _LibraryPOSMock.InitializeData(_Initialized, _POSUnit, _POSStore, _POSPaymentMethod);

        ChildItem.Get(_LibraryTicketModule.CreateScenario_SmokeTest());
        UpdateItemForPOSSaleUsage(ChildItem, 4);
        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(ParentItem, _POSUnit, _POSStore);
        ParentItem."Unit Price" := 10;
        ParentItem.Modify();

        _LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSActionInsertItem.AddItemLine(ParentItem, ItemReference, 0, ParentQuantity, 0, '', '', '', _POSSession, FrontEnd, '');

        POSSale.GetCurrentSale(SalePOS);
        ParentSaleLine.Get(SalePOS."Register No.", SalePOS."Sales Ticket No.", SalePOS.Date, ParentSaleLine."Sale Type"::Sale, POSActionInsertItem.GetLineNo());

        AddOnNo := CreateWalletItemAddOn(ParentItem, ChildItem);
        POSActionRunItemAddOn.RunItemAddOns(ParentSaleLine."Line No.", AddOnNo, false, true, false, UserSelectionJToken);

        ChildSaleLine.Reset();
        ChildSaleLine.SetRange("Register No.", SalePOS."Register No.");
        ChildSaleLine.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        ChildSaleLine.SetRange("No.", ChildItem."No.");
        ChildSaleLine.FindFirst();
    end;

    local procedure EndSale()
    var
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SalesAmount: Decimal;
        SubTotal: Decimal;
    begin
        _POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.CalculateBalance(SalesAmount, PaidAmount, ReturnAmount, SubTotal);
        _Assert.IsTrue(
          _LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, SalesAmount, ''),
          'The wallet item add-on sale did not end.');
    end;

    local procedure CollectTicketsOfSaleLine(SalePOS: Record "NPR POS Sale"; ChildSaleLine: Record "NPR POS Sale Line"; var TicketSystemIds: List of [Guid])
    var
        Ticket: Record "NPR TM Ticket";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        Clear(TicketSystemIds);
        TicketReservationRequest.SetRange("Receipt No.", SalePOS."Sales Ticket No.");
        TicketReservationRequest.SetRange("Line No.", ChildSaleLine."Line No.");
        if not TicketReservationRequest.FindSet() then
            exit;
        repeat
            Ticket.Reset();
            Ticket.SetRange("Ticket Reservation Entry No.", TicketReservationRequest."Entry No.");
            if Ticket.FindSet() then
                repeat
                    TicketSystemIds.Add(Ticket.SystemId);
                until Ticket.Next() = 0;
        until TicketReservationRequest.Next() = 0;
    end;

    local procedure CreateWalletItemAddOn(var ParentItem: Record Item; ChildItem: Record Item) AddOnNo: Code[20]
    var
        ItemAddOn: Record "NPR NpIa Item AddOn";
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        LibraryRandom: Codeunit "Library - Random";
    begin
        ItemAddOn.Init();
        ItemAddOn.Validate("No.", LibraryRandom.RandText(20));
        ItemAddOn.Enabled := true;
        ItemAddOn.WalletTemplate := true;
        ItemAddOn.Insert(true);

        ItemAddOnLine.Init();
        ItemAddOnLine.Validate("AddOn No.", ItemAddOn."No.");
        ItemAddOnLine.Validate("Line No.", 10000);
        ItemAddOnLine.Validate(Type, ItemAddOnLine.Type::Quantity);
        ItemAddOnLine.Validate("Item No.", ChildItem."No.");
        ItemAddOnLine.Validate(Quantity, 1);
        ItemAddOnLine.Validate("Per Unit", true);
        ItemAddOnLine.Validate(Mandatory, true);
        ItemAddOnLine."Use Unit Price" := ItemAddOnLine."Use Unit Price"::Always;
        ItemAddOnLine."Unit Price" := ChildItem."Unit Price";
        ItemAddOnLine.AddToWallet := true;
        ItemAddOnLine.Insert(true);

        ParentItem.Validate("NPR Item AddOn No.", ItemAddOn."No.");
        ParentItem.Modify();

        exit(ItemAddOn."No.");
    end;

    local procedure UpdateItemForPOSSaleUsage(var Item: Record Item; UnitPrice: Decimal)
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        _POSStore.GetProfile(POSPostingProfile);
        Item.Validate("VAT Bus. Posting Gr. (Price)", POSPostingProfile."VAT Bus. Posting Group");
        Item."Price Includes VAT" := true;
        Item."Unit Price" := UnitPrice;
        Item.Modify();
        _LibraryPOSMasterData.CreatePostingSetupForSaleItem(Item, _POSUnit, _POSStore);
    end;
}
