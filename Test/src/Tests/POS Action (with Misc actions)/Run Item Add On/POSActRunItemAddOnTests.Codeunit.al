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
    procedure RunItemAddOn_SelectOptionsOnSameItem_StoresTheChosenOption()
    var
        OptionItem: Record Item;
        ParentItem: Record Item;
        ParentSaleLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
        AddOnNo: Code[20];
    begin
        // [SCENARIO] The cashier dialog tells apart two options on the same item and variant, and the link row follows an option change

        // [GIVEN] A sale with a parent item line, and a Select add-on whose two options share one item; only option 20000 is Per Unit
        InitializeSale(SalePOS);
        CreateSaleItem(ParentItem, 10);
        CreateSaleItem(OptionItem, 4);
        AddOnNo := CreateSelectAddOn(ParentItem, OptionItem);
        AddParentItemLine(ParentItem, 1, SalePOS, ParentSaleLine);

        // [WHEN] The cashier picks option 20000
        RunItemAddOnWithOption(ParentSaleLine, AddOnNo, OptionItem, 20000);

        // [THEN] The link row stores option 20000 and its Per Unit flag
        FindAddOnLink(ParentSaleLine, SaleLinePOSAddOn);
        _Assert.AreEqual(20000, SaleLinePOSAddOn."Selected Option Line No.", 'The link row must store the chosen option.');
        _Assert.IsTrue(SaleLinePOSAddOn."Per Unit", 'The link row must carry the chosen option''s Per Unit flag.');

        // [WHEN] The cashier changes the same group to option 10000
        RunItemAddOnWithOption(ParentSaleLine, AddOnNo, OptionItem, 10000);

        // [THEN] The existing link row follows the change
        FindAddOnLink(ParentSaleLine, SaleLinePOSAddOn);
        _Assert.AreEqual(10000, SaleLinePOSAddOn."Selected Option Line No.", 'The link row must follow the option change.');
        _Assert.IsFalse(SaleLinePOSAddOn."Per Unit", 'The link row must follow the new option''s Per Unit flag.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AddOnDialog_SelectOptionsOnSameItem_PreSelectsTheStoredOption()
    var
        ItemAddOn: Record "NPR NpIa Item AddOn";
        OptionItem: Record Item;
        ParentItem: Record Item;
        ParentSaleLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        ItemAddOnMgt: Codeunit "NPR NpIa Item AddOn Mgt.";
        ConfigJObject: JsonObject;
        JToken: JsonToken;
        Options: JsonArray;
        SelectedValue: Text;
        AddOnNo: Code[20];
    begin
        // [SCENARIO] Reopening the cashier dialog marks the stored option, also when two options share one item and variant

        // [GIVEN] A sale where the cashier picked option 20000 of a Select add-on whose two options share one item
        InitializeSale(SalePOS);
        CreateSaleItem(ParentItem, 10);
        CreateSaleItem(OptionItem, 4);
        AddOnNo := CreateSelectAddOn(ParentItem, OptionItem);
        AddParentItemLine(ParentItem, 1, SalePOS, ParentSaleLine);
        RunItemAddOnWithOption(ParentSaleLine, AddOnNo, OptionItem, 20000);

        // [WHEN] The dialog for the parent line is built again
        ItemAddOn.Get(AddOnNo);
        ConfigJObject := ItemAddOnMgt.GenerateItemAddOnConfigJson(SalePOS, ParentSaleLine, ItemAddOn);

        // [THEN] The Select group's value is option 20000's value, not option 10000's
        ConfigJObject.SelectToken('settings[0].value', JToken);
        SelectedValue := JToken.AsValue().AsText();
        ConfigJObject.SelectToken('settings[0].options', JToken);
        Options := JToken.AsArray();
        Options.Get(1, JToken);
        JToken.SelectToken('value', JToken);
        _Assert.AreEqual(JToken.AsValue().AsText(), SelectedValue, 'The dialog must pre-select the stored option 20000.');
        Options.Get(0, JToken);
        JToken.SelectToken('value', JToken);
        _Assert.AreNotEqual(JToken.AsValue().AsText(), SelectedValue, 'Option 10000 shares the item, so it must not be pre-selected.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RunItemAddOn_MandatorySelectLine_RequiresAChoice()
    var
        ItemAddOn: Record "NPR NpIa Item AddOn";
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        OptionItem: Record Item;
        ParentItem: Record Item;
        ParentSaleLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
        ItemAddOnMgt: Codeunit "NPR NpIa Item AddOn Mgt.";
        POSActionRunItemAddOn: Codeunit "NPR POS Action: RunItemAddOn B";
        ConfigJObject: JsonObject;
        NoSelection: JsonObject;
        JToken: JsonToken;
        AddOnNo: Code[20];
    begin
        // [SCENARIO] A Mandatory Select line makes the cashier choose an option, and the chosen line stays removable

        // [GIVEN] A sale with a parent item line, and a Select add-on line set to Mandatory
        InitializeSale(SalePOS);
        CreateSaleItem(ParentItem, 10);
        CreateSaleItem(OptionItem, 4);
        AddOnNo := CreateSelectAddOn(ParentItem, OptionItem);
        ItemAddOnLine.Get(AddOnNo, 10000);
        ItemAddOnLine.Validate(Mandatory, true);
        ItemAddOnLine.Validate(Quantity, 0);
        ItemAddOnLine.Modify();
        _Assert.IsTrue(ItemAddOnLine.Mandatory, 'A zero Quantity must not clear Mandatory on a Select line.');
        AddParentItemLine(ParentItem, 1, SalePOS, ParentSaleLine);

        // [WHEN] The cashier dialog is built
        ItemAddOn.Get(AddOnNo);
        ConfigJObject := ItemAddOnMgt.GenerateItemAddOnConfigJson(SalePOS, ParentSaleLine, ItemAddOn);

        // [THEN] The Select group is required
        ConfigJObject.SelectToken('settings[0].required', JToken);
        _Assert.IsTrue(JToken.AsValue().AsBoolean(), 'A Mandatory Select group must be required in the dialog.');

        // [WHEN] The cashier picks option 10000
        RunItemAddOnWithOption(ParentSaleLine, AddOnNo, OptionItem, 10000);

        // [THEN] The chosen line is not locked as mandatory
        FindAddOnLink(ParentSaleLine, SaleLinePOSAddOn);
        _Assert.IsFalse(SaleLinePOSAddOn.Mandatory, 'The chosen option line must stay removable.');

        // [WHEN/THEN] Confirming the dialog without a choice is refused
        asserterror POSActionRunItemAddOn.RunItemAddOns(ParentSaleLine."Line No.", AddOnNo, false, true, true, NoSelection.AsToken());
        _Assert.ExpectedError('You must choose an option for');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RunItemAddOn_CompulsoryDialogCancelledWithMandatorySelect_RemovesTheItem()
    var
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        OptionItem: Record Item;
        ParentItem: Record Item;
        ParentSaleLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        POSActionRunItemAddOn: Codeunit "NPR POS Action: RunItemAddOn B";
        Cancelled: JsonValue;
        AddOnNo: Code[20];
    begin
        // [SCENARIO] Cancelling the add-on dialog that opened with the item removes the item, so it can't be sold without a mandatory choice

        // [GIVEN] A sale with a parent item line, and a Select add-on line set to Mandatory
        InitializeSale(SalePOS);
        CreateSaleItem(ParentItem, 10);
        CreateSaleItem(OptionItem, 4);
        AddOnNo := CreateSelectAddOn(ParentItem, OptionItem);
        ItemAddOnLine.Get(AddOnNo, 10000);
        ItemAddOnLine.Validate(Mandatory, true);
        ItemAddOnLine.Modify();
        AddParentItemLine(ParentItem, 1, SalePOS, ParentSaleLine);

        // [WHEN] The cashier cancels the dialog that opened when the item was added
        Cancelled.SetValueToNull();
        POSActionRunItemAddOn.SetOpenedOnItemInsert(true);
        POSActionRunItemAddOn.RunItemAddOns(ParentSaleLine."Line No.", AddOnNo, true, true, true, Cancelled.AsToken());

        // [THEN] The item is removed from the sale
        _Assert.IsFalse(ParentSaleLine.Find(), 'The item must be removed when its mandatory choice is cancelled.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RunItemAddOn_CompulsoryDialogConfirmedWithoutMandatoryChoice_RemovesTheItem()
    var
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        OptionItem: Record Item;
        ParentItem: Record Item;
        ParentSaleLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        POSActionRunItemAddOn: Codeunit "NPR POS Action: RunItemAddOn B";
        EmptyRadio: JsonObject;
        AddOnNo: Code[20];
    begin
        // [SCENARIO] Confirming the add-on dialog that opened with the item, without the mandatory choice, removes the item

        // [GIVEN] A sale with a parent item line, and a Select add-on line set to Mandatory
        InitializeSale(SalePOS);
        CreateSaleItem(ParentItem, 10);
        CreateSaleItem(OptionItem, 4);
        AddOnNo := CreateSelectAddOn(ParentItem, OptionItem);
        ItemAddOnLine.Get(AddOnNo, 10000);
        ItemAddOnLine.Validate(Mandatory, true);
        ItemAddOnLine.Modify();
        AddParentItemLine(ParentItem, 1, SalePOS, ParentSaleLine);

        // [WHEN] The cashier confirms the dialog with the radio left empty
        EmptyRadio.Add('10000', '{}');
        POSActionRunItemAddOn.SetOpenedOnItemInsert(true);
        asserterror POSActionRunItemAddOn.RunItemAddOns(ParentSaleLine."Line No.", AddOnNo, true, true, true, EmptyRadio.AsToken());

        // [THEN] The choice is refused and the item is removed from the sale
        _Assert.ExpectedError('You must choose an option for');
        _Assert.IsFalse(ParentSaleLine.Find(), 'The item must be removed when its mandatory choice is missing.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RunItemAddOn_ReopenedDialogCancelledWithMandatorySelect_KeepsTheItem()
    var
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        OptionItem: Record Item;
        ParentItem: Record Item;
        ParentSaleLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        POSActionRunItemAddOn: Codeunit "NPR POS Action: RunItemAddOn B";
        Cancelled: JsonValue;
        AddOnNo: Code[20];
    begin
        // [SCENARIO] Cancelling the add-on dialog the cashier opened on an item already in the sale keeps the item

        // [GIVEN] A sale with a parent item line without add-on lines, and a Select add-on line set to Mandatory
        InitializeSale(SalePOS);
        CreateSaleItem(ParentItem, 10);
        CreateSaleItem(OptionItem, 4);
        AddOnNo := CreateSelectAddOn(ParentItem, OptionItem);
        ItemAddOnLine.Get(AddOnNo, 10000);
        ItemAddOnLine.Validate(Mandatory, true);
        ItemAddOnLine.Modify();
        AddParentItemLine(ParentItem, 1, SalePOS, ParentSaleLine);

        // [WHEN] The cashier opens the dialog from the add-on button and cancels it
        Cancelled.SetValueToNull();
        POSActionRunItemAddOn.RunItemAddOns(ParentSaleLine."Line No.", AddOnNo, true, true, true, Cancelled.AsToken());

        // [THEN] The item stays in the sale
        _Assert.IsTrue(ParentSaleLine.Find(), 'The item must stay when a reopened dialog is cancelled.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RunItemAddOn_MandatorySelectZeroQuantityOptionChosen_IsAccepted()
    var
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        ItemAddOnLineOpt: Record "NPR NpIa ItemAddOn Line Opt.";
        OptionItem: Record Item;
        ParentItem: Record Item;
        ParentSaleLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        AddOnNo: Code[20];
    begin
        // [SCENARIO] Choosing an option with zero quantity (a "None" choice) satisfies a Mandatory Select line

        // [GIVEN] A Mandatory Select add-on line whose option 10000 has Quantity 0
        InitializeSale(SalePOS);
        CreateSaleItem(ParentItem, 10);
        CreateSaleItem(OptionItem, 4);
        AddOnNo := CreateSelectAddOn(ParentItem, OptionItem);
        ItemAddOnLine.Get(AddOnNo, 10000);
        ItemAddOnLine.Validate(Mandatory, true);
        ItemAddOnLine.Modify();
        ItemAddOnLineOpt.Get(AddOnNo, 10000, 10000);
        ItemAddOnLineOpt.Quantity := 0;
        ItemAddOnLineOpt.Modify();
        AddParentItemLine(ParentItem, 1, SalePOS, ParentSaleLine);

        // [WHEN/THEN] The cashier picks that option and no missing-choice error is raised
        RunItemAddOnWithOption(ParentSaleLine, AddOnNo, OptionItem, 10000);
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

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UseUnitPriceRelative_WhereTheAmountWouldBeReadAsAPrice_IsRefused()
    var
        ChildItem: Record Item;
        ParentItem: Record Item;
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        AddOnNo: Code[20];
    begin
        // [SCENARIO] A relative unit price is an amount added to the normal price, so it is refused where it would be read as the price itself

        // [GIVEN] An add-on quantity line with an absolute unit price
        _LibraryPOSMock.InitializeData(_Initialized, _POSUnit, _POSStore, _POSPaymentMethod);
        CreateSaleItem(ParentItem, 10);
        CreateSaleItem(ChildItem, 4);
        AddOnNo := CreateQuantityAddOn(ParentItem, ChildItem, 1, false);
        ItemAddOnLine.Get(AddOnNo, 10000);

        // [WHEN] The line is made relative
        ItemAddOnLine.Validate("Use Unit Price", ItemAddOnLine."Use Unit Price"::Relative);

        // [THEN] The absolute unit price does not carry over as the amount
        _Assert.AreEqual(0, ItemAddOnLine."Unit Price", 'Switching to a relative unit price must clear the absolute unit price.');

        // [WHEN/THEN] A line priced by UnitPriceFromMaster, which sets an absolute unit price, cannot be made relative
        ItemAddOnLine.Validate("Use Unit Price", ItemAddOnLine."Use Unit Price"::"Non-Zero");
        ItemAddOnLine.Validate("Before Insert Function", 'UnitPriceFromMaster');
        asserterror ItemAddOnLine.Validate("Use Unit Price", ItemAddOnLine."Use Unit Price"::Relative);

        // [WHEN/THEN] Nor can a Select line, whose options carry the price
        ItemAddOnLine.Validate("Before Insert Function", '');
        ItemAddOnLine.Validate(Type, ItemAddOnLine.Type::Select);
        asserterror ItemAddOnLine.Validate("Use Unit Price", ItemAddOnLine."Use Unit Price"::Relative);
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

    local procedure CreateSelectAddOn(var ParentItem: Record Item; OptionItem: Record Item): Code[20]
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
        ItemAddOnLine.Validate(Type, ItemAddOnLine.Type::Select);
        ItemAddOnLine.Insert(true);

        CreateSelectOption(ItemAddOnLine, 10000, OptionItem, false);
        CreateSelectOption(ItemAddOnLine, 20000, OptionItem, true);

        ParentItem.Validate("NPR Item AddOn No.", ItemAddOn."No.");
        ParentItem.Modify();

        exit(ItemAddOn."No.");
    end;

    local procedure CreateSelectOption(ItemAddOnLine: Record "NPR NpIa Item AddOn Line"; LineNo: Integer; OptionItem: Record Item; PerUnit: Boolean)
    var
        ItemAddOnLineOpt: Record "NPR NpIa ItemAddOn Line Opt.";
    begin
        ItemAddOnLineOpt.Init();
        ItemAddOnLineOpt."AddOn No." := ItemAddOnLine."AddOn No.";
        ItemAddOnLineOpt."AddOn Line No." := ItemAddOnLine."Line No.";
        ItemAddOnLineOpt."Line No." := LineNo;
        ItemAddOnLineOpt."Item No." := OptionItem."No.";
        ItemAddOnLineOpt.Quantity := 1;
        ItemAddOnLineOpt."Per Unit" := PerUnit;
        ItemAddOnLineOpt.Insert(true);
    end;

    local procedure RunItemAddOnWithOption(ParentSaleLine: Record "NPR POS Sale Line"; AddOnNo: Code[20]; OptionItem: Record Item; OptionLineNo: Integer)
    var
        POSActionRunItemAddOn: Codeunit "NPR POS Action: RunItemAddOn B";
        OptionValue: JsonObject;
        UserSelection: JsonObject;
        OptionValueText: Text;
    begin
        // Same shape as the cashier dialog's radio value
        OptionValue.Add('item', OptionItem."No.");
        OptionValue.Add('variant', '');
        OptionValue.Add('optionLineNo', OptionLineNo);
        OptionValue.WriteTo(OptionValueText);
        UserSelection.Add('10000', OptionValueText);
        POSActionRunItemAddOn.RunItemAddOns(ParentSaleLine."Line No.", AddOnNo, false, true, true, UserSelection.AsToken());
    end;

    local procedure FindAddOnLink(ParentSaleLine: Record "NPR POS Sale Line"; var SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn")
    begin
        SaleLinePOSAddOn.Reset();
        SaleLinePOSAddOn.SetRange("Register No.", ParentSaleLine."Register No.");
        SaleLinePOSAddOn.SetRange("Sales Ticket No.", ParentSaleLine."Sales Ticket No.");
        SaleLinePOSAddOn.SetRange("Applies-to Line No.", ParentSaleLine."Line No.");
        _Assert.AreEqual(1, SaleLinePOSAddOn.Count(), 'The Select group must have exactly one add-on line.');
        SaleLinePOSAddOn.FindFirst();
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
