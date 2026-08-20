codeunit 85140 "NPR POS Act. RunItemAddOnTests"
{
    // [FEATURE] Item add-on lines on a POS sale

    Subtype = Test;

    var
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _POSStore: Record "NPR POS Store";
        _POSUnit: Record "NPR POS Unit";
        _Assert: Codeunit "Assert";
        _LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        _LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        _POSSession: Codeunit "NPR POS Session";
        _Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RunItemAddOn_FixedQuantityAddOn_InsertsTheChildLineOnTheSale()
    var
        ChildItem: Record Item;
        ChildSaleLine: Record "NPR POS Sale Line";
        ParentItem: Record Item;
        ParentSaleLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        AddOnNo: Code[20];
    begin
        // [SCENARIO] Running an item add-on adds its child item to the sale, below and indented under the parent line

        // [GIVEN] A sale with a parent item line, and a fixed-quantity add-on of 2 attached to that item
        InitializeSale(SalePOS);
        CreateSaleItem(ParentItem, 10);
        CreateSaleItem(ChildItem, 4);
        AddParentItemLine(ParentItem, 1, SalePOS, ParentSaleLine);
        AddOnNo := CreateQuantityAddOn(ParentItem, ChildItem, 2, false);

        // [WHEN] The item add-on is run for the parent line
        RunItemAddOn(ParentSaleLine, AddOnNo);

        // [THEN] The child item is on the sale with the configured quantity, indented under its parent
        FindSaleLine(SalePOS, ChildItem."No.", ChildSaleLine);
        _Assert.AreEqual(2, ChildSaleLine.Quantity, 'The add-on child line must carry the configured fixed quantity.');
        _Assert.AreEqual(ChildItem."Unit Price", ChildSaleLine."Unit Price", 'The add-on child line must carry the configured unit price.');
        _Assert.AreEqual(ParentSaleLine.Indentation + 1, ChildSaleLine.Indentation, 'The add-on child line must be indented under its parent line.');
        _Assert.IsTrue(ChildSaleLine."Line No." > ParentSaleLine."Line No.", 'The add-on child line must be placed below its parent line.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EndSale_ItemAddOnSale_PostsBothTheParentAndTheChildLine()
    var
        ChildItem: Record Item;
        ChildPOSEntryLine: Record "NPR POS Entry Sales Line";
        ChildSaleLine: Record "NPR POS Sale Line";
        ParentItem: Record Item;
        ParentPOSEntryLine: Record "NPR POS Entry Sales Line";
        ParentSaleLine: Record "NPR POS Sale Line";
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        SalePOS: Record "NPR POS Sale";
    begin
        // [SCENARIO] Ending a sale that contains an item add-on posts the parent line and the child line together

        // [GIVEN] A completed sale with a parent item and its fixed-quantity add-on child
        CreateAndCompleteItemAddOnSale(false, '', ParentItem, ChildItem, SalePOS, ParentSaleLine, ChildSaleLine);

        // [WHEN] The resulting POS entry is inspected
        POSEntry.GetBySystemId(SalePOS.SystemId);

        // [THEN] Exactly the parent and the child line are posted, keeping quantity, price and indentation
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        _Assert.AreEqual(2, POSEntrySalesLine.Count(), 'The POS entry must contain exactly one parent and one child sales line.');
        ParentPOSEntryLine.GetBySystemId(ParentSaleLine.SystemId);
        ChildPOSEntryLine.GetBySystemId(ChildSaleLine.SystemId);
        _Assert.AreEqual(POSEntry."Entry No.", ParentPOSEntryLine."POS Entry No.", 'The parent line belongs to another POS entry.');
        _Assert.AreEqual(POSEntry."Entry No.", ChildPOSEntryLine."POS Entry No.", 'The child line belongs to another POS entry.');
        _Assert.AreEqual(ParentItem."No.", ParentPOSEntryLine."No.", 'The parent item was not posted.');
        _Assert.AreEqual(ChildItem."No.", ChildPOSEntryLine."No.", 'The child item was not posted.');
        _Assert.AreEqual(2, ChildPOSEntryLine.Quantity, 'The child quantity was not posted.');
        _Assert.AreEqual(4, ChildPOSEntryLine."Unit Price", 'The child unit price was not posted.');
        _Assert.AreEqual(ParentPOSEntryLine.Indentation + 1, ChildPOSEntryLine.Indentation, 'The child indentation was not posted.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EndSale_AddOnCopiesSerialNo_PostsTheParentSerialNoOnTheChildLine()
    var
        ChildItem: Record Item;
        ChildPOSEntryLine: Record "NPR POS Entry Sales Line";
        ChildSaleLine: Record "NPR POS Sale Line";
        ParentItem: Record Item;
        ParentSaleLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        ParentSerialNo: Code[50];
    begin
        // [SCENARIO] An add-on line configured to copy the serial number inherits it from the parent line when posted

        // [GIVEN] A completed sale whose parent line has a serial number and whose add-on copies it
        ParentSerialNo := 'PARENT-SERIAL';
        CreateAndCompleteItemAddOnSale(true, ParentSerialNo, ParentItem, ChildItem, SalePOS, ParentSaleLine, ChildSaleLine);

        // [WHEN] The posted child line is inspected
        ChildPOSEntryLine.GetBySystemId(ChildSaleLine.SystemId);

        // [THEN] The child line carries the serial number of its parent
        _Assert.AreEqual(ParentSerialNo, ChildPOSEntryLine."Serial No.", 'The parent serial number was not copied to the posted child line.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EndSale_ItemAddOnSale_ClearsTheTransientAddOnRelations()
    var
        ChildItem: Record Item;
        ChildSaleLine: Record "NPR POS Sale Line";
        ParentItem: Record Item;
        ParentSaleLine: Record "NPR POS Sale Line";
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
        SalePOS: Record "NPR POS Sale";
    begin
        // [SCENARIO] The sale-scoped add-on relations do not outlive the sale they belong to

        // [GIVEN] A completed sale that contained an item add-on
        CreateAndCompleteItemAddOnSale(false, '', ParentItem, ChildItem, SalePOS, ParentSaleLine, ChildSaleLine);

        // [WHEN] The add-on relations of that sale are looked up
        SaleLinePOSAddOn.SetRange("Register No.", ChildSaleLine."Register No.");
        SaleLinePOSAddOn.SetRange("Sales Ticket No.", ChildSaleLine."Sales Ticket No.");

        // [THEN] None are left behind
        _Assert.IsTrue(SaleLinePOSAddOn.IsEmpty(), 'Transient item add-on relations remain after end of sale.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DeleteParentSaleLine_DuringTheSale_AlsoDeletesTheChildAddOnLine()
    var
        ChildItem: Record Item;
        ChildSaleLine: Record "NPR POS Sale Line";
        ParentItem: Record Item;
        ParentSaleLine: Record "NPR POS Sale Line";
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
        SalePOS: Record "NPR POS Sale";
        AddOnNo: Code[20];
    begin
        // [SCENARIO] Removing a parent line mid-sale takes its add-on child line and their relation with it

        // [GIVEN] A sale with a parent item line and the add-on child line it produced
        InitializeSale(SalePOS);
        CreateSaleItem(ParentItem, 10);
        CreateSaleItem(ChildItem, 4);
        AddParentItemLine(ParentItem, 1, SalePOS, ParentSaleLine);
        AddOnNo := CreateQuantityAddOn(ParentItem, ChildItem, 2, false);
        RunItemAddOn(ParentSaleLine, AddOnNo);
        FindSaleLine(SalePOS, ChildItem."No.", ChildSaleLine);

        // [WHEN] The parent line is deleted from the sale
        ParentSaleLine.Find();
        ParentSaleLine.Delete(true);

        // [THEN] The child line is gone as well, and so is the relation between them
        _Assert.IsFalse(ChildSaleLine.Find(), 'The add-on child line must be deleted together with its parent line.');
        SaleLinePOSAddOn.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOSAddOn.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        _Assert.IsTrue(SaleLinePOSAddOn.IsEmpty(), 'The item add-on relation must be deleted together with its parent line.');
    end;

    local procedure CreateAndCompleteItemAddOnSale(CopySerialNo: Boolean; ParentSerialNo: Code[50]; var ParentItem: Record Item; var ChildItem: Record Item; var SalePOS: Record "NPR POS Sale"; var ParentSaleLine: Record "NPR POS Sale Line"; var ChildSaleLine: Record "NPR POS Sale Line")
    var
        AddOnNo: Code[20];
    begin
        InitializeSale(SalePOS);
        CreateSaleItem(ParentItem, 10);
        CreateSaleItem(ChildItem, 4);
        AddParentItemLine(ParentItem, 1, SalePOS, ParentSaleLine);
        AddOnNo := CreateQuantityAddOn(ParentItem, ChildItem, 2, CopySerialNo);

        if ParentSerialNo <> '' then begin
            ParentSaleLine."Serial No." := ParentSerialNo;
            ParentSaleLine.Modify();
        end;

        RunItemAddOn(ParentSaleLine, AddOnNo);
        FindSaleLine(SalePOS, ChildItem."No.", ChildSaleLine);
        EndSale();
    end;

    local procedure InitializeSale(var SalePOS: Record "NPR POS Sale")
    var
        POSSale: Codeunit "NPR POS Sale";
    begin
        _LibraryPOSMock.InitializeData(_Initialized, _POSUnit, _POSStore, _POSPaymentMethod);
        _LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
    end;

    local procedure CreateSaleItem(var Item: Record Item; UnitPrice: Decimal)
    begin
        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := UnitPrice;
        Item.Modify();
    end;

    local procedure AddParentItemLine(ParentItem: Record Item; Quantity: Decimal; SalePOS: Record "NPR POS Sale"; var ParentSaleLine: Record "NPR POS Sale Line")
    var
        ItemReference: Record "Item Reference";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSActionInsertItem: Codeunit "NPR POS Action: Insert Item B";
    begin
        POSActionInsertItem.AddItemLine(ParentItem, ItemReference, 0, Quantity, 0, '', '', '', _POSSession, FrontEnd, '');
        ParentSaleLine.Get(SalePOS."Register No.", SalePOS."Sales Ticket No.", SalePOS.Date, ParentSaleLine."Sale Type"::Sale, POSActionInsertItem.GetLineNo());
    end;

    local procedure RunItemAddOn(ParentSaleLine: Record "NPR POS Sale Line"; AddOnNo: Code[20])
    var
        POSActionRunItemAddOn: Codeunit "NPR POS Action: RunItemAddOn B";
        UserSelectionJToken: JsonToken;
    begin
        POSActionRunItemAddOn.RunItemAddOns(ParentSaleLine."Line No.", AddOnNo, false, true, false, UserSelectionJToken);
    end;

    local procedure CreateQuantityAddOn(var ParentItem: Record Item; ChildItem: Record Item; Quantity: Decimal; CopySerialNo: Boolean) AddOnNo: Code[20]
    var
        ItemAddOn: Record "NPR NpIa Item AddOn";
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        LibraryRandom: Codeunit "Library - Random";
    begin
        ItemAddOn.Init();
        ItemAddOn.Validate("No.", LibraryRandom.RandText(20));
        ItemAddOn.Enabled := true;
        ItemAddOn.Insert(true);

        ItemAddOnLine.Init();
        ItemAddOnLine.Validate("AddOn No.", ItemAddOn."No.");
        ItemAddOnLine.Validate("Line No.", 10000);
        ItemAddOnLine.Validate(Type, ItemAddOnLine.Type::Quantity);
        ItemAddOnLine.Validate("Item No.", ChildItem."No.");
        ItemAddOnLine.Validate(Quantity, Quantity);
        ItemAddOnLine.Validate("Fixed Quantity", true);
        ItemAddOnLine.Validate(Mandatory, true);
        ItemAddOnLine."Use Unit Price" := ItemAddOnLine."Use Unit Price"::Always;
        ItemAddOnLine."Unit Price" := ChildItem."Unit Price";
        ItemAddOnLine."Copy Serial No." := CopySerialNo;
        ItemAddOnLine.Insert(true);

        ParentItem.Validate("NPR Item AddOn No.", ItemAddOn."No.");
        ParentItem.Modify();

        exit(ItemAddOn."No.");
    end;

    local procedure FindSaleLine(SalePOS: Record "NPR POS Sale"; ItemNo: Code[20]; var SaleLine: Record "NPR POS Sale Line")
    begin
        SaleLine.Reset();
        SaleLine.SetRange("Register No.", SalePOS."Register No.");
        SaleLine.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLine.SetRange("Line Type", SaleLine."Line Type"::Item);
        SaleLine.SetRange("No.", ItemNo);
        SaleLine.FindFirst();
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
          'The item add-on sale did not end.');
    end;
}
