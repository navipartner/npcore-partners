codeunit 85032 "NPR POS Mix. Disc. and Tax"
{
    // [Feature] POS Mixed Discount
    Subtype = Test;
    EventSubscriberInstance = Manual;
    Permissions = TableData "G/L Entry" = rimd,
                  TableData "VAT Entry" = rimd;

    trigger OnRun()
    begin
        Initialized := false;
    end;


    var
        POSUnit: Record "NPR POS Unit";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSStore: Record "NPR POS Store";
        POSSetup: Record "NPR POS Setup";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        TaxGroup: Record "Tax Group";
        POSSession: Codeunit "NPR POS Session";
        Assert: Codeunit Assert;
        LibraryApplicationArea: Codeunit "Library - Application Area";
        LibraryRandom: Codeunit "Library - Random";
        LibraryTaxCalc: Codeunit "NPR POS Lib. - Tax Calc.";
        Initialized: Boolean;
        DayDirection: Option Today,Future,Past;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VerifyDiscountEnabled()
    var
        DiscountPriority: Record "NPR Discount Priority";
        DiscountPriorityList: TestPage "NPR Discount Priority List";
    begin
        // [SCENARIO] Exercise & verify discount is enabled

        // [GIVEN] Clear discounts priority
        DiscountPriority.DeleteAll();

        // [WHEN] Discount Priority List is opened
        DiscountPriorityList.OpenView();
        DiscountPriorityList.Close();

        // [THEN] Verify discount is enabled
        Assert.IsTrue(DiscountPriority.Get(DiscSourceTableId()), 'Discount not created');
        Assert.IsFalse(DiscountPriority.Disabled, 'Discount is disabled');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RelevantDiscountsFoundForDMLInsert()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        xPOSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        TempDiscountPriority: Record "NPR Discount Priority" temporary;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SalesDiscCalcMgt: codeunit "NPR POS Sales Disc. Calc. Mgt.";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
    begin
        // [SCENARIO] Exersice & verify. Discount is prioritized when POS Sale Line is created

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountPct(Item, LibraryRandom.RandDecInRange(1, 100, 5), false);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);
        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Active Sales Line for Item
        CreatePOSSaleLine(Item, POSSale, POSSaleLine);

        // [WHEN] Insert operation is perfromed
        SalesDiscCalcMgt.OnFindActiveSaleLineDiscounts(TempDiscountPriority, POSSale, POSSaleLine, xPOSSaleLine, 0);

        // [THEN] Verify Discount Priority enabled
        Assert.IsTrue(TempDiscountPriority.Get(DiscSourceTableId()), 'Discount not created');
        Assert.IsFalse(TempDiscountPriority.Disabled, 'Discount is disabled');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForNormalTaxInDirectSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is created

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();
        LibraryApplicationArea.EnableVATSetup();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 9, false);

        LineDiscAmt := Item."Unit Price" * LineDiscPct / 100;
        LineAmtInclTax := Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100))) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForNormalTaxInDirectSaleQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        Qty: Decimal;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is created

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();
        LibraryApplicationArea.EnableVATSetup();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 9, false);

        Qty := Round(1 + 2 / 3, 0.00001);
        LineDiscAmt := Round(Qty * Item."Unit Price" * LineDiscPct / 100);
        LineAmtInclTax := Round(Qty * Item."Unit Price") - LineDiscAmt;
        LineAmtExclTax := Round(LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100));

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(LineDiscAmt, POSSaleLine."Discount Amount", '(Qty * Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(LineAmtInclTax, POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100))) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(LineAmtExclTax, POSSaleLine.Amount, '((Qty * Item."Unit Price" - (Qty * Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForNormalTaxInDebitSaleForward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is created

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, false, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 7, false);

        // TransferAppliedDiscountToSale
        Item."Unit Price" := Item."Unit Price" / (1 + VATPostingSetup."VAT %" / 100);
        LineDiscAmt := Item."Unit Price" * LineDiscPct / 100;
        LineAmtExclTax := Item."Unit Price" - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax * (1 + VATPostingSetup."VAT %" / 100);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '((Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) / (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '((Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100))) * (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '(Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)))  <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForNormalTaxInDebitSaleForwardQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        Qty: Decimal;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is created

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, false, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 7, false);

        // TransferAppliedDiscountToSale
        Qty := Round(1 + 1 / 3, 0.00001);
        Item."Unit Price" := Item."Unit Price" / (1 + VATPostingSetup."VAT %" / 100);
        LineDiscAmt := Round(Qty * Item."Unit Price" * LineDiscPct / 100);
        LineAmtExclTax := Round(Qty * Item."Unit Price") - LineDiscAmt;
        LineAmtInclTax := Round(LineAmtExclTax * (1 + VATPostingSetup."VAT %" / 100));

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscAmt, POSSaleLine."Discount Amount", '((Qty * Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) / (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(LineAmtInclTax, POSSaleLine."Amount Including VAT", '((Qty * Item."Unit Price" - (Qty * Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100))) * (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(LineAmtExclTax, POSSaleLine.Amount, '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)))  <> POSSaleLine.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForNormalTaxInDebitSaleBackward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is created

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, true, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 7, false);

        LineDiscAmt := Item."Unit Price" * LineDiscPct / 100;
        LineAmtInclTax := Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100))) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForNormalTaxInDebitSaleBackwardQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        Qty: Decimal;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is created

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, true, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 7, false);

        Qty := 1 + 1 / 2;
        LineDiscAmt := Round(Qty * Item."Unit Price" * LineDiscPct / 100);
        LineAmtInclTax := Round(Qty * Item."Unit Price") - LineDiscAmt;
        LineAmtExclTax := Round(LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100));

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, Round(POSSaleLine."Discount %", 0.1), 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(LineDiscAmt, POSSaleLine."Discount Amount", '(Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(LineAmtInclTax, POSSaleLine."Amount Including VAT", '(Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100))) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(LineAmtExclTax, POSSaleLine.Amount, '((Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenEndSaleForNormalTaxInDirectSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        GLEntry: Record "G/L Entry";
        GeneralPostingSetup: Record "General Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        AmountToPay: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale ended

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();
        LibraryApplicationArea.EnableVATSetup();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 9, false);

        LineDiscAmt := Item."Unit Price" * LineDiscPct / 100;
        LineAmtInclTax := Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        // Get Amount to Pay
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        AmountToPay := GetAmountToPay(POSSaleLine);
        AmountToPay := Round(AmountToPay, 1, '>');

        POSSession.GetSale(POSSaleUnit);
        POSSaleUnit.GetCurrentSale(POSSale);

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify Discount applied
        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();

        POSEntrySalesLine."POS Entry No." := POSEntry."Entry No.";
        POSEntrySalesLine."Line No." := POSSaleLine."Line No.";

        //Verify POS Entry Sales Line
        Assert.IsTrue(POSEntrySalesLine.Find(), 'Sale Line not created');
        Assert.AreEqual(POSSaleLine."Discount %", POSEntrySalesLine."Line Discount %", 'POSSaleLine."Discount %" <>POSEntrySalesLine."Line Discount %"');
        Assert.AreEqual(POSSaleLine."Discount Amount", POSEntrySalesLine."Line Discount Amount Incl. VAT", 'POSSaleLine."Discount Amount" <> POSEntrySalesLine."Line Discount Amount Incl. VAT"');
        Assert.AreEqual(POSSaleLine.Amount, POSEntrySalesLine."Amount Excl. VAT", 'POSSaleLine.Amount <> POSEntrySalesLine."Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", POSEntrySalesLine."Amount Incl. VAT", 'POSSaleLine."Amount Including VAT" <> POSEntrySalesLine."Amount Incl. VAT"');
        Assert.IsTrue(GeneralPostingSetup.Get(POSSaleLine."Gen. Bus. Posting Group", POSSaleLine."Gen. Prod. Posting Group"), 'General Posting Setup not found');

        //Verify G/L Entry
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        GLEntry.SetRange("Posting Date", POSEntry."Posting Date");
        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Account');
        Assert.AreEqual(Item."Unit Price", -(GLEntry.Amount + GLEntry."VAT Amount"), '(Item."Unit Price" * 1) <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) <> GLEntry.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenEndSaleForNormalTaxInDirectSaleQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        GLEntry: Record "G/L Entry";
        GeneralPostingSetup: Record "General Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        AmountToPay: Decimal;
        Qty: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale ended

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();
        LibraryApplicationArea.EnableVATSetup();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 9, false);

        Qty := Round(1 + 2 / 3, 0.00001);
        LineDiscAmt := Round(Qty * Item."Unit Price" * LineDiscPct / 100);
        LineAmtInclTax := Round(Qty * Item."Unit Price") - LineDiscAmt;
        LineAmtExclTax := Round(LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100));

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // Get Amount to Pay
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        AmountToPay := GetAmountToPay(POSSaleLine);
        AmountToPay := Round(AmountToPay, 1, '>');

        POSSession.GetSale(POSSaleUnit);
        POSSaleUnit.GetCurrentSale(POSSale);

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify Discount applied
        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();

        POSEntrySalesLine."POS Entry No." := POSEntry."Entry No.";
        POSEntrySalesLine."Line No." := POSSaleLine."Line No.";

        //Verify POS Entry Sales Line
        Assert.IsTrue(POSEntrySalesLine.Find(), 'Sale Line not created');
        Assert.AreEqual(POSSaleLine."Discount %", POSEntrySalesLine."Line Discount %", 'POSSaleLine."Discount %" <>POSEntrySalesLine."Line Discount %"');
        Assert.AreEqual(POSSaleLine."Discount Amount", POSEntrySalesLine."Line Discount Amount Incl. VAT", 'POSSaleLine."Discount Amount" <> POSEntrySalesLine."Line Discount Amount Incl. VAT"');
        Assert.AreEqual(POSSaleLine.Amount, POSEntrySalesLine."Amount Excl. VAT", 'POSSaleLine.Amount <> POSEntrySalesLine."Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", POSEntrySalesLine."Amount Incl. VAT", 'POSSaleLine."Amount Including VAT" <> POSEntrySalesLine."Amount Incl. VAT"');
        Assert.IsTrue(GeneralPostingSetup.Get(POSSaleLine."Gen. Bus. Posting Group", POSSaleLine."Gen. Prod. Posting Group"), 'General Posting Setup not found');

        //Verify G/L Entry
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        GLEntry.SetRange("Posting Date", POSEntry."Posting Date");
        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Account');
        Assert.AreEqual(Round(Qty * Item."Unit Price"), -(GLEntry.Amount + GLEntry."VAT Amount"), '(Qty * Item."Unit Price") <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Qty * Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) <> GLEntry.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenEndSaleForNormalTaxInDebitSaleForward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        POSEntry: Record "NPR POS Entry";
        GLEntry: Record "G/L Entry";
        GeneralPostingSetup: Record "General Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        AmountToPay: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is created

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, false, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 7, false);

        LineDiscAmt := Item."Unit Price" * LineDiscPct / 100;
        LineAmtExclTax := Item."Unit Price" - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax * (1 + VATPostingSetup."VAT %" / 100);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        // Get Amount to Pay
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        AmountToPay := GetAmountToPay(POSSaleLine);
        AmountToPay := Round(AmountToPay, 1, '>');

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify Discount applied
        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();

        POSEntrySalesLine."POS Entry No." := POSEntry."Entry No.";
        POSEntrySalesLine."Line No." := POSSaleLine."Line No.";

        //Verify POS Entry Sales Line
        Assert.IsTrue(POSEntrySalesLine.Find(), 'Sale Line not created');
        Assert.AreEqual(POSSaleLine."Discount %", POSEntrySalesLine."Line Discount %", 'POSSaleLine."Discount %" <>POSEntrySalesLine."Line Discount %"');
        Assert.AreEqual(POSSaleLine."Discount Amount", POSEntrySalesLine."Line Discount Amount Excl. VAT", 'POSSaleLine."Discount Amount" <> POSEntrySalesLine."Line Discount Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine.Amount, POSEntrySalesLine."Amount Excl. VAT", 'POSSaleLine.Amount <> POSEntrySalesLine."Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", POSEntrySalesLine."Amount Incl. VAT", 'POSSaleLine."Amount Including VAT" <> POSEntrySalesLine."Amount Incl. VAT"');
        Assert.IsTrue(GeneralPostingSetup.Get(POSSaleLine."Gen. Bus. Posting Group", POSSaleLine."Gen. Prod. Posting Group"), 'General Posting Setup not found');

        //Verify G/L Entry
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        GLEntry.SetRange("Posting Date", POSEntry."Posting Date");
        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Account');
        Assert.AreEqual(Item."Unit Price", -(GLEntry.Amount + GLEntry."VAT Amount"), '(Item."Unit Price" * 1) <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) <> GLEntry.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenEndSaleForNormalTaxInDebitSaleForwardQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        POSEntry: Record "NPR POS Entry";
        GLEntry: Record "G/L Entry";
        GeneralPostingSetup: Record "General Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        AmountToPay: Decimal;
        Qty: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is created

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, false, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 7, false);

        Qty := Round(1 + 1 / 3, 0.00001);
        LineDiscAmt := Round(Qty * Item."Unit Price" * LineDiscPct / 100);
        LineAmtExclTax := Round(Qty * Item."Unit Price") - LineDiscAmt;
        LineAmtInclTax := Round(LineAmtExclTax * (1 + VATPostingSetup."VAT %" / 100));

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // Get Amount to Pay
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        AmountToPay := GetAmountToPay(POSSaleLine);
        AmountToPay := Round(AmountToPay, 1, '>');

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify Discount applied
        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();

        POSEntrySalesLine."POS Entry No." := POSEntry."Entry No.";
        POSEntrySalesLine."Line No." := POSSaleLine."Line No.";

        //Verify POS Entry Sales Line
        Assert.IsTrue(POSEntrySalesLine.Find(), 'Sale Line not created');
        Assert.AreEqual(POSSaleLine."Discount %", POSEntrySalesLine."Line Discount %", 'POSSaleLine."Discount %" <>POSEntrySalesLine."Line Discount %"');
        Assert.AreEqual(POSSaleLine."Discount Amount", POSEntrySalesLine."Line Discount Amount Excl. VAT", 'POSSaleLine."Discount Amount" <> POSEntrySalesLine."Line Discount Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine.Amount, POSEntrySalesLine."Amount Excl. VAT", 'POSSaleLine.Amount <> POSEntrySalesLine."Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", POSEntrySalesLine."Amount Incl. VAT", 'POSSaleLine."Amount Including VAT" <> POSEntrySalesLine."Amount Incl. VAT"');
        Assert.IsTrue(GeneralPostingSetup.Get(POSSaleLine."Gen. Bus. Posting Group", POSSaleLine."Gen. Prod. Posting Group"), 'General Posting Setup not found');

        //Verify G/L Entry
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        GLEntry.SetRange("Posting Date", POSEntry."Posting Date");
        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Account');
        Assert.AreEqual(Round(Qty * Item."Unit Price"), -(GLEntry.Amount + GLEntry."VAT Amount"), '(Qty * Item."Unit Price") <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Qty * Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) <> GLEntry.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenEndSaleForNormalTaxInDebitSaleBackward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        POSEntry: Record "NPR POS Entry";
        GLEntry: Record "G/L Entry";
        GeneralPostingSetup: Record "General Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        AmountToPay: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is created

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, true, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 7, false);

        LineDiscAmt := Item."Unit Price" * LineDiscPct / 100;
        LineAmtInclTax := Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        // Get Amount to Pay
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        AmountToPay := GetAmountToPay(POSSaleLine);
        AmountToPay := Round(AmountToPay, 1, '>');

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify Discount applied
        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();

        POSEntrySalesLine."POS Entry No." := POSEntry."Entry No.";
        POSEntrySalesLine."Line No." := POSSaleLine."Line No.";

        //Verify POS Entry Sales Line
        Assert.IsTrue(POSEntrySalesLine.Find(), 'Sale Line not created');
        Assert.AreEqual(POSSaleLine."Discount %", POSEntrySalesLine."Line Discount %", 'POSSaleLine."Discount %" <>POSEntrySalesLine."Line Discount %"');
        Assert.AreEqual(POSSaleLine."Discount Amount", POSEntrySalesLine."Line Discount Amount Incl. VAT", 'POSSaleLine."Discount Amount" <> POSEntrySalesLine."Line Discount Amount Incl. VAT"');
        Assert.AreEqual(POSSaleLine.Amount, POSEntrySalesLine."Amount Excl. VAT", 'POSSaleLine.Amount <> POSEntrySalesLine."Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", POSEntrySalesLine."Amount Incl. VAT", 'POSSaleLine."Amount Including VAT" <> POSEntrySalesLine."Amount Incl. VAT"');
        Assert.IsTrue(GeneralPostingSetup.Get(POSSaleLine."Gen. Bus. Posting Group", POSSaleLine."Gen. Prod. Posting Group"), 'General Posting Setup not found');

        //Verify G/L Entry
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        GLEntry.SetRange("Posting Date", POSEntry."Posting Date");
        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Account');
        Assert.AreEqual(Item."Unit Price", -(GLEntry.Amount + GLEntry."VAT Amount"), '(Item."Unit Price" * 1) <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) <> GLEntry.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenEndSaleForNormalTaxInDebitSaleBackwardQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        POSEntry: Record "NPR POS Entry";
        GLEntry: Record "G/L Entry";
        GeneralPostingSetup: Record "General Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        AmountToPay: Decimal;
        Qty: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is created

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, true, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 7, false);

        Qty := Round(1 + 2 / 3, 0.00001);
        LineDiscAmt := Round(Qty * Item."Unit Price" * LineDiscPct / 100);
        LineAmtInclTax := Round(Qty * Item."Unit Price") - LineDiscAmt;
        LineAmtExclTax := Round(LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100));

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // Get Amount to Pay
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        AmountToPay := GetAmountToPay(POSSaleLine);
        AmountToPay := Round(AmountToPay, 1, '>');

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify Discount applied
        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();

        POSEntrySalesLine."POS Entry No." := POSEntry."Entry No.";
        POSEntrySalesLine."Line No." := POSSaleLine."Line No.";

        //Verify POS Entry Sales Line
        Assert.IsTrue(POSEntrySalesLine.Find(), 'Sale Line not created');
        Assert.AreEqual(POSSaleLine."Discount %", POSEntrySalesLine."Line Discount %", 'POSSaleLine."Discount %" <>POSEntrySalesLine."Line Discount %"');
        Assert.AreEqual(POSSaleLine."Discount Amount", POSEntrySalesLine."Line Discount Amount Incl. VAT", 'POSSaleLine."Discount Amount" <> POSEntrySalesLine."Line Discount Amount Incl. VAT"');
        Assert.AreEqual(POSSaleLine.Amount, POSEntrySalesLine."Amount Excl. VAT", 'POSSaleLine.Amount <> POSEntrySalesLine."Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", POSEntrySalesLine."Amount Incl. VAT", 'POSSaleLine."Amount Including VAT" <> POSEntrySalesLine."Amount Incl. VAT"');
        Assert.IsTrue(GeneralPostingSetup.Get(POSSaleLine."Gen. Bus. Posting Group", POSSaleLine."Gen. Prod. Posting Group"), 'General Posting Setup not found');

        //Verify G/L Entry
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        GLEntry.SetRange("Posting Date", POSEntry."Posting Date");
        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Account');
        Assert.AreEqual(Round(Qty * Item."Unit Price"), -(GLEntry.Amount + GLEntry."VAT Amount"), '(Qty * Item."Unit Price") <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Qty * Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) <> GLEntry.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForRevChrgTaxInDirectSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is created

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();
        LibraryApplicationArea.EnableVATSetup();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 9, false);

        LineDiscAmt := Item."Unit Price" * LineDiscPct / 100;
        LineAmtInclTax := Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100))) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForRevChrgTaxInDirectSaleQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        Qty: Decimal;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is created

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();
        LibraryApplicationArea.EnableVATSetup();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 9, false);

        Qty := Round(1 + 2 / 3, 0.00001);
        LineDiscAmt := Round(Qty * Item."Unit Price" * LineDiscPct / 100);
        LineAmtInclTax := Round(Qty * Item."Unit Price") - LineDiscAmt;
        LineAmtExclTax := Round(LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100));

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(LineDiscAmt, POSSaleLine."Discount Amount", '(Qty * Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(LineAmtInclTax, POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100))) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(LineAmtExclTax, POSSaleLine.Amount, '((Qty * Item."Unit Price" - (Qty * Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForRevChrgTaxInDebitSaleForward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        UnitPrice: Decimal;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is created

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, false, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 7, false);

        UnitPrice := Item."Unit Price" / (1 + VATPostingSetup."VAT %" / 100);
        LineDiscAmt := (Item."Unit Price" * LineDiscPct / 100) / (1 + VATPostingSetup."VAT %" / 100);
        LineAmtExclTax := UnitPrice - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax * (1 + VATPostingSetup."VAT %" / 100);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '((Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) / (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '((Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100))) * (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '(Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)))  <> POSSaleLine.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForRevChrgTaxInDebitSaleForwardQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        UnitPrice: Decimal;
        Qty: Decimal;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is created

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, false, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 7, false);

        Qty := Round(1 + 1 / 3, 0.00001);
        UnitPrice := Item."Unit Price" / (1 + VATPostingSetup."VAT %" / 100);
        LineDiscAmt := Round((Qty * Item."Unit Price" * LineDiscPct / 100) / (1 + VATPostingSetup."VAT %" / 100));
        LineAmtExclTax := Round(Qty * UnitPrice) - LineDiscAmt;
        LineAmtInclTax := Round(LineAmtExclTax * (1 + VATPostingSetup."VAT %" / 100));

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, Round(POSSaleLine."Discount %", 0.1), 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(LineDiscAmt, POSSaleLine."Discount Amount", '((Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) / (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(LineAmtInclTax, POSSaleLine."Amount Including VAT", '((Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100))) * (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(LineAmtExclTax, POSSaleLine.Amount, '(Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)))  <> POSSaleLine.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForRevChrgTaxInDebitSaleBackward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is created

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, true, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 7, false);

        LineDiscAmt := Item."Unit Price" * LineDiscPct / 100;
        LineAmtInclTax := Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100))) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForRevChrgTaxInDebitSaleBackwardQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        Qty: Decimal;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is created

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, true, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 7, false);

        Qty := Round(1 + 1 / 3, 0.00001);
        LineDiscAmt := Round(Qty * Item."Unit Price" * LineDiscPct / 100);
        LineAmtInclTax := Round(Qty * Item."Unit Price") - LineDiscAmt;
        LineAmtExclTax := Round(LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100));

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, Round(POSSaleLine."Discount %", 0.1), 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(LineDiscAmt, POSSaleLine."Discount Amount", '(Qty * Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(LineAmtInclTax, POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100))) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(LineAmtExclTax, POSSaleLine.Amount, '((Qty * Item."Unit Price" - (Qty * Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenEndSaleForRevChrgTaxInDirectSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        GLEntry: Record "G/L Entry";
        GeneralPostingSetup: Record "General Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        AmountToPay: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale ended

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();
        LibraryApplicationArea.EnableVATSetup();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 9, false);

        LineDiscAmt := Item."Unit Price" * LineDiscPct / 100;
        LineAmtInclTax := Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        // Get Amount to Pay
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        AmountToPay := GetAmountToPay(POSSaleLine);
        AmountToPay := Round(AmountToPay, 1, '>');

        POSSession.GetSale(POSSaleUnit);
        POSSaleUnit.GetCurrentSale(POSSale);

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify Discount applied
        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();

        POSEntrySalesLine."POS Entry No." := POSEntry."Entry No.";
        POSEntrySalesLine."Line No." := POSSaleLine."Line No.";

        //Verify POS Entry Sales Line
        Assert.IsTrue(POSEntrySalesLine.Find(), 'Sale Line not created');
        Assert.AreEqual(POSSaleLine."Discount %", POSEntrySalesLine."Line Discount %", 'POSSaleLine."Discount %" <>POSEntrySalesLine."Line Discount %"');
        Assert.AreEqual(POSSaleLine."Discount Amount", POSEntrySalesLine."Line Discount Amount Incl. VAT", 'POSSaleLine."Discount Amount" <> POSEntrySalesLine."Line Discount Amount Incl. VAT"');
        Assert.AreEqual(POSSaleLine.Amount, POSEntrySalesLine."Amount Excl. VAT", 'POSSaleLine.Amount <> POSEntrySalesLine."Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", POSEntrySalesLine."Amount Incl. VAT", 'POSSaleLine."Amount Including VAT" <> POSEntrySalesLine."Amount Incl. VAT"');
        Assert.IsTrue(GeneralPostingSetup.Get(POSSaleLine."Gen. Bus. Posting Group", POSSaleLine."Gen. Prod. Posting Group"), 'General Posting Setup not found');

        //Verify G/L Entry
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        GLEntry.SetRange("Posting Date", POSEntry."Posting Date");
        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Account');
        Assert.AreEqual(Item."Unit Price", -(GLEntry.Amount + GLEntry."VAT Amount"), '(Item."Unit Price" * 1) <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) <> GLEntry.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenEndSaleForRevChrgTaxInDirectSaleQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        GLEntry: Record "G/L Entry";
        GeneralPostingSetup: Record "General Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        AmountToPay: Decimal;
        Qty: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale ended

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();
        LibraryApplicationArea.EnableVATSetup();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 9, false);

        Qty := Round(1 + 2 / 3, 0.00001);
        LineDiscAmt := Round(Qty * Item."Unit Price" * LineDiscPct / 100);
        LineAmtInclTax := Round(Qty * Item."Unit Price") - LineDiscAmt;
        LineAmtExclTax := Round(LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100));

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // Get Amount to Pay
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        AmountToPay := GetAmountToPay(POSSaleLine);
        AmountToPay := Round(AmountToPay, 1, '>');

        POSSession.GetSale(POSSaleUnit);
        POSSaleUnit.GetCurrentSale(POSSale);

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify Discount applied
        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();

        POSEntrySalesLine."POS Entry No." := POSEntry."Entry No.";
        POSEntrySalesLine."Line No." := POSSaleLine."Line No.";

        //Verify POS Entry Sales Line
        Assert.IsTrue(POSEntrySalesLine.Find(), 'Sale Line not created');
        Assert.AreEqual(POSSaleLine."Discount %", POSEntrySalesLine."Line Discount %", 'POSSaleLine."Discount %" <>POSEntrySalesLine."Line Discount %"');
        Assert.AreEqual(POSSaleLine."Discount Amount", POSEntrySalesLine."Line Discount Amount Incl. VAT", 'POSSaleLine."Discount Amount" <> POSEntrySalesLine."Line Discount Amount Incl. VAT"');
        Assert.AreEqual(POSSaleLine.Amount, POSEntrySalesLine."Amount Excl. VAT", 'POSSaleLine.Amount <> POSEntrySalesLine."Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", POSEntrySalesLine."Amount Incl. VAT", 'POSSaleLine."Amount Including VAT" <> POSEntrySalesLine."Amount Incl. VAT"');
        Assert.IsTrue(GeneralPostingSetup.Get(POSSaleLine."Gen. Bus. Posting Group", POSSaleLine."Gen. Prod. Posting Group"), 'General Posting Setup not found');

        //Verify G/L Entry
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        GLEntry.SetRange("Posting Date", POSEntry."Posting Date");
        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Account');
        Assert.AreEqual(Round(Qty * Item."Unit Price"), -(GLEntry.Amount + GLEntry."VAT Amount"), '(Qty * Item."Unit Price") <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Qty * Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) <> GLEntry.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenEndSaleForRevChrgTaxInDebitSaleForward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        POSEntry: Record "NPR POS Entry";
        GLEntry: Record "G/L Entry";
        GeneralPostingSetup: Record "General Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        AmountToPay: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is created

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, false, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 7, false);

        LineDiscAmt := Item."Unit Price" * LineDiscPct / 100;
        LineAmtExclTax := Item."Unit Price" - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax * (1 + VATPostingSetup."VAT %" / 100);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        // Get Amount to Pay
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        AmountToPay := GetAmountToPay(POSSaleLine);
        AmountToPay := Round(AmountToPay, 1, '>');

        POSSession.GetSale(POSSaleUnit);
        POSSaleUnit.GetCurrentSale(POSSale);

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify Discount applied
        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();

        POSEntrySalesLine."POS Entry No." := POSEntry."Entry No.";
        POSEntrySalesLine."Line No." := POSSaleLine."Line No.";

        //Verify POS Entry Sales Line
        Assert.IsTrue(POSEntrySalesLine.Find(), 'Sale Line not created');
        Assert.AreEqual(POSSaleLine."Discount %", POSEntrySalesLine."Line Discount %", 'POSSaleLine."Discount %" <>POSEntrySalesLine."Line Discount %"');
        Assert.AreEqual(POSSaleLine."Discount Amount", POSEntrySalesLine."Line Discount Amount Excl. VAT", 'POSSaleLine."Discount Amount" <> POSEntrySalesLine."Line Discount Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine.Amount, POSEntrySalesLine."Amount Excl. VAT", 'POSSaleLine.Amount <> POSEntrySalesLine."Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", POSEntrySalesLine."Amount Incl. VAT", 'POSSaleLine."Amount Including VAT" <> POSEntrySalesLine."Amount Incl. VAT"');
        Assert.IsTrue(GeneralPostingSetup.Get(POSSaleLine."Gen. Bus. Posting Group", POSSaleLine."Gen. Prod. Posting Group"), 'General Posting Setup not found');

        //Verify G/L Entry
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        GLEntry.SetRange("Posting Date", POSEntry."Posting Date");
        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Account');
        Assert.AreEqual(Item."Unit Price", -(GLEntry.Amount + GLEntry."VAT Amount"), '(Item."Unit Price" * 1) <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) <> GLEntry.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenEndSaleForRevChrgTaxInDebitSaleForwardQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        POSEntry: Record "NPR POS Entry";
        GLEntry: Record "G/L Entry";
        GeneralPostingSetup: Record "General Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        AmountToPay: Decimal;
        Qty: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is created

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, false, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 7, false);

        Qty := Round(1 + 1 / 3, 0.00001);
        LineDiscAmt := Round(Qty * Item."Unit Price" * LineDiscPct / 100);
        LineAmtExclTax := Round(Qty * Item."Unit Price") - LineDiscAmt;
        LineAmtInclTax := Round(LineAmtExclTax * (1 + VATPostingSetup."VAT %" / 100));

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // Get Amount to Pay
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        AmountToPay := GetAmountToPay(POSSaleLine);
        AmountToPay := Round(AmountToPay, 1, '>');

        POSSession.GetSale(POSSaleUnit);
        POSSaleUnit.GetCurrentSale(POSSale);

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify Discount applied
        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();

        POSEntrySalesLine."POS Entry No." := POSEntry."Entry No.";
        POSEntrySalesLine."Line No." := POSSaleLine."Line No.";

        //Verify POS Entry Sales Line
        Assert.IsTrue(POSEntrySalesLine.Find(), 'Sale Line not created');
        Assert.AreEqual(POSSaleLine."Discount %", POSEntrySalesLine."Line Discount %", 'POSSaleLine."Discount %" <>POSEntrySalesLine."Line Discount %"');
        Assert.AreEqual(POSSaleLine."Discount Amount", POSEntrySalesLine."Line Discount Amount Excl. VAT", 'POSSaleLine."Discount Amount" <> POSEntrySalesLine."Line Discount Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine.Amount, POSEntrySalesLine."Amount Excl. VAT", 'POSSaleLine.Amount <> POSEntrySalesLine."Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", POSEntrySalesLine."Amount Incl. VAT", 'POSSaleLine."Amount Including VAT" <> POSEntrySalesLine."Amount Incl. VAT"');
        Assert.IsTrue(GeneralPostingSetup.Get(POSSaleLine."Gen. Bus. Posting Group", POSSaleLine."Gen. Prod. Posting Group"), 'General Posting Setup not found');

        //Verify G/L Entry
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        GLEntry.SetRange("Posting Date", POSEntry."Posting Date");
        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Account');
        Assert.AreEqual(Round(Qty * Item."Unit Price"), -(GLEntry.Amount + GLEntry."VAT Amount"), '(Qty * Item."Unit Price") <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Qty * Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) <> GLEntry.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenEndSaleForRevChrgTaxInDebitSaleBackward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        POSEntry: Record "NPR POS Entry";
        GLEntry: Record "G/L Entry";
        GeneralPostingSetup: Record "General Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        AmountToPay: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is created

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, true, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 7, false);

        LineDiscAmt := Item."Unit Price" * LineDiscPct / 100;
        LineAmtInclTax := Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        // Get Amount to Pay
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        AmountToPay := GetAmountToPay(POSSaleLine);
        AmountToPay := Round(AmountToPay, 1, '>');

        POSSession.GetSale(POSSaleUnit);
        POSSaleUnit.GetCurrentSale(POSSale);

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify Discount applied
        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();

        POSEntrySalesLine."POS Entry No." := POSEntry."Entry No.";
        POSEntrySalesLine."Line No." := POSSaleLine."Line No.";

        //Verify POS Entry Sales Line
        Assert.IsTrue(POSEntrySalesLine.Find(), 'Sale Line not created');
        Assert.AreEqual(POSSaleLine."Discount %", POSEntrySalesLine."Line Discount %", 'POSSaleLine."Discount %" <>POSEntrySalesLine."Line Discount %"');
        Assert.AreEqual(POSSaleLine."Discount Amount", POSEntrySalesLine."Line Discount Amount Incl. VAT", 'POSSaleLine."Discount Amount" <> POSEntrySalesLine."Line Discount Amount Incl. VAT"');
        Assert.AreEqual(POSSaleLine.Amount, POSEntrySalesLine."Amount Excl. VAT", 'POSSaleLine.Amount <> POSEntrySalesLine."Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", POSEntrySalesLine."Amount Incl. VAT", 'POSSaleLine."Amount Including VAT" <> POSEntrySalesLine."Amount Incl. VAT"');
        Assert.IsTrue(GeneralPostingSetup.Get(POSSaleLine."Gen. Bus. Posting Group", POSSaleLine."Gen. Prod. Posting Group"), 'General Posting Setup not found');

        //Verify G/L Entry
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        GLEntry.SetRange("Posting Date", POSEntry."Posting Date");
        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Account');
        Assert.AreEqual(Item."Unit Price", -(GLEntry.Amount + GLEntry."VAT Amount"), '(Item."Unit Price" * 1) <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) <> GLEntry.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenEndSaleForRevChrgTaxInDebitSaleBackwardQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        POSEntry: Record "NPR POS Entry";
        GLEntry: Record "G/L Entry";
        GeneralPostingSetup: Record "General Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        AmountToPay: Decimal;
        Qty: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is created

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, true, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 7, false);

        Qty := Round(1 + 1 / 3, 0.00001);
        LineDiscAmt := Round(Qty * Item."Unit Price" * LineDiscPct / 100);
        LineAmtInclTax := Round(Qty * Item."Unit Price") - LineDiscAmt;
        LineAmtExclTax := Round(LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100));

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // Get Amount to Pay
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        AmountToPay := GetAmountToPay(POSSaleLine);
        AmountToPay := Round(AmountToPay, 1, '>');

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify Discount applied
        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();

        POSEntrySalesLine."POS Entry No." := POSEntry."Entry No.";
        POSEntrySalesLine."Line No." := POSSaleLine."Line No.";

        //Verify POS Entry Sales Line
        Assert.IsTrue(POSEntrySalesLine.Find(), 'Sale Line not created');
        Assert.AreEqual(POSSaleLine."Discount %", POSEntrySalesLine."Line Discount %", 'POSSaleLine."Discount %" <>POSEntrySalesLine."Line Discount %"');
        Assert.AreEqual(POSSaleLine."Discount Amount", POSEntrySalesLine."Line Discount Amount Incl. VAT", 'POSSaleLine."Discount Amount" <> POSEntrySalesLine."Line Discount Amount Incl. VAT"');
        Assert.AreEqual(POSSaleLine.Amount, POSEntrySalesLine."Amount Excl. VAT", 'POSSaleLine.Amount <> POSEntrySalesLine."Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", POSEntrySalesLine."Amount Incl. VAT", 'POSSaleLine."Amount Including VAT" <> POSEntrySalesLine."Amount Incl. VAT"');
        Assert.IsTrue(GeneralPostingSetup.Get(POSSaleLine."Gen. Bus. Posting Group", POSSaleLine."Gen. Prod. Posting Group"), 'General Posting Setup not found');

        //Verify G/L Entry
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        GLEntry.SetRange("Posting Date", POSEntry."Posting Date");
        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Account');
        Assert.AreEqual(Round(Qty * Item."Unit Price"), -(GLEntry.Amount + GLEntry."VAT Amount"), '(Qty * Item."Unit Price") <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Qty * Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) <> GLEntry.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForSaleTaxInDirectSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        TaxArea: Record "Tax Area";
        TaxDetail: Record "Tax Detail";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        CityTaxRate: Decimal;
        CountyTaxRate: Decimal;
        StateTaxRate: Decimal;
        TotalTax: Decimal;
        Qty: Decimal;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is created

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();
        LibraryApplicationArea.EnableSalesTaxSetup();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        CityTaxRate := 1.5;
        CountyTaxRate := 3.5;
        StateTaxRate := 5.5;
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, CityTaxRate, CountyTaxRate, StateTaxRate);

        //If it's set, reset maximum amount on Tax Details
        TaxDetail.SetRange("Tax Jurisdiction Code");
        TaxDetail.ModifyAll("Maximum Amount/Qty.", 0);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignTaxDetailToPOSPostingProfile(TaxArea.Code, true);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 9, false);

        Qty := 1;
        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        Item."Unit Price" := Item."Unit Price" * (1 - LineDiscPct / 100);
        TotalTax := Qty * (Round(Item."Unit Price" * CityTaxRate / 100) +
                           Round(Item."Unit Price" * CountyTaxRate / 100) +
                           Round(Item."Unit Price" * StateTaxRate / 100));
        LineAmtExclTax := Qty * Item."Unit Price";
        LineAmtInclTax := LineAmtExclTax + TotalTax;

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(Round(LineDiscPct), POSSaleLine."Discount %", 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", 'LineDiscAmt <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '(Qty * Item."Unit Price" - LineDiscAmt) <> POSSaleLine.Amount');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - LineDiscAmt) + TotalTax <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForSaleTaxInDirectSaleQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        TaxArea: Record "Tax Area";
        TaxDetail: Record "Tax Detail";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        CityTaxRate: Decimal;
        CountyTaxRate: Decimal;
        StateTaxRate: Decimal;
        TotalTax: Decimal;
        Qty: Decimal;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is created

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();
        LibraryApplicationArea.EnableSalesTaxSetup();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        CityTaxRate := 1.5;
        CountyTaxRate := 3.5;
        StateTaxRate := 5.5;
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, CityTaxRate, CountyTaxRate, StateTaxRate);

        //If it's set, reset maximum amount on Tax Details
        TaxDetail.SetRange("Tax Jurisdiction Code");
        TaxDetail.ModifyAll("Maximum Amount/Qty.", 0);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignTaxDetailToPOSPostingProfile(TaxArea.Code, true);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 9, false);

        Qty := Round(1 + 1 / 3, 0.00001);
        LineDiscAmt := Round(Qty * Item."Unit Price" * LineDiscPct / 100);
        Item."Unit Price" := Item."Unit Price" * (1 - LineDiscPct / 100);
        TotalTax := Round(Qty * (Round(Item."Unit Price" * CityTaxRate / 100) +
                           Round(Item."Unit Price" * CountyTaxRate / 100) +
                           Round(Item."Unit Price" * StateTaxRate / 100)));
        LineAmtExclTax := Round(Qty * Item."Unit Price");
        LineAmtInclTax := LineAmtExclTax + TotalTax;

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(LineDiscAmt, POSSaleLine."Discount Amount", 'LineDiscAmt <> POSSaleLine."Discount %"');
        Assert.AreEqual(LineAmtExclTax, POSSaleLine.Amount, '(Qty * Item."Unit Price" - LineDiscAmt) <> POSSaleLine.Amount');
        Assert.AreEqual(LineAmtInclTax, POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - LineDiscAmt) + TotalTax <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForSaleTaxInDebitSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        POSPostingProfile: Record "NPR POS Posting Profile";
        TaxArea: Record "Tax Area";
        TaxDetail: Record "Tax Detail";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        CityTaxRate: Decimal;
        CountyTaxRate: Decimal;
        StateTaxRate: Decimal;
        TotalTax: Decimal;
        UnitPriceTaxable: Decimal;
        Qty: Decimal;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is created

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        CityTaxRate := 1.5;
        CountyTaxRate := 3.5;
        StateTaxRate := 5.5;
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, CityTaxRate, CountyTaxRate, StateTaxRate);

        //If it's set, reset maximum amount on Tax Details
        TaxDetail.SetRange("Tax Jurisdiction Code");
        TaxDetail.ModifyAll("Maximum Amount/Qty.", 0);

        // [GIVEN] Customer
        CreateCustomer(Customer, false, true, TaxArea.Code, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        POSStore.GetProfile(POSPostingProfile);
        POSPostingProfile."Default POS Posting Setup" := POSPostingProfile."Default POS Posting Setup"::Customer;
        POSPostingProfile.Modify();

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 7, false);

        Qty := 1;
        UnitPriceTaxable := Item."Unit Price" * (1 - LineDiscPct / 100);
        TotalTax := Qty * (Round(UnitPriceTaxable * CityTaxRate / 100) +
                           Round(UnitPriceTaxable * CountyTaxRate / 100) +
                           Round(UnitPriceTaxable * StateTaxRate / 100));
        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtExclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax + TotalTax;

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", 'LineDiscAmt <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '(Qty * Item."Unit Price" - LineDiscAmt)  <> POSSaleLine.Amount');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - LineDiscAmt) + TotalTax <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForSaleTaxInDebitSaleQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        POSPostingProfile: Record "NPR POS Posting Profile";
        TaxArea: Record "Tax Area";
        TaxDetail: Record "Tax Detail";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        CityTaxRate: Decimal;
        CountyTaxRate: Decimal;
        StateTaxRate: Decimal;
        TotalTax: Decimal;
        UnitPriceTaxable: Decimal;
        Qty: Decimal;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is created

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        CityTaxRate := 1.5;
        CountyTaxRate := 3.5;
        StateTaxRate := 5.5;
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, CityTaxRate, CountyTaxRate, StateTaxRate);

        //If it's set, reset maximum amount on Tax Details
        TaxDetail.SetRange("Tax Jurisdiction Code");
        TaxDetail.ModifyAll("Maximum Amount/Qty.", 0);

        // [GIVEN] Customer
        CreateCustomer(Customer, false, true, TaxArea.Code, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        POSStore.GetProfile(POSPostingProfile);
        POSPostingProfile."Default POS Posting Setup" := POSPostingProfile."Default POS Posting Setup"::Customer;
        POSPostingProfile.Modify();

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 7, false);

        Qty := Round(1 + 1 / 3, 0.00001);
        UnitPriceTaxable := Item."Unit Price" * (1 - LineDiscPct / 100);
        TotalTax := Round(Qty * UnitPriceTaxable * CityTaxRate / 100) +
                           Round(Qty * UnitPriceTaxable * CountyTaxRate / 100) +
                           Round(Qty * UnitPriceTaxable * StateTaxRate / 100);
        LineDiscAmt := Round(Qty * Item."Unit Price" * LineDiscPct / 100);
        LineAmtExclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax + TotalTax;

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, Round(POSSaleLine."Discount %", 0.1), 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", 'LineDiscAmt <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '(Qty * Item."Unit Price" - LineDiscAmt)  <> POSSaleLine.Amount');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - LineDiscAmt) + TotalTax <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenEndSaleForSaleTaxInDirectSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        TaxJurisdiction: Record "Tax Jurisdiction";
        TaxDetail: Record "Tax Detail";
        TaxArea: Record "Tax Area";
        POSPostingProfile: Record "NPR POS Posting Profile";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineAmtInclTax: Decimal;
        AmountToPay: Decimal;
        CityTaxRate: Decimal;
        CountyTaxRate: Decimal;
        StateTaxRate: Decimal;
        Qty: Decimal;
        TotalTax: Decimal;
        UnitPriceTaxable: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale ended

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();
        LibraryApplicationArea.EnableSalesTaxSetup();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        TaxJurisdiction.DeleteAll();
        CityTaxRate := 1.5;
        CountyTaxRate := 3.5;
        StateTaxRate := 5.5;
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, CityTaxRate, CountyTaxRate, StateTaxRate);

        //If it's set, reset maximum amount on Tax Details
        TaxDetail.SetRange("Tax Jurisdiction Code");
        TaxDetail.ModifyAll("Maximum Amount/Qty.", 0);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignTaxDetailToPOSPostingProfile(TaxArea.Code, true);

        // [GIVEN] Update rounding amount account
        UpdatePOSSalesRoundingAcc();

        // [GIVEN] Update Tax account (sales)
        LibraryTaxCalc.UpdateTaxJurisdictionSalesAccounts();

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 9, false);

        Qty := 1;
        UnitPriceTaxable := Item."Unit Price" * (1 - LineDiscPct / 100);
        TotalTax := Qty * (Round(UnitPriceTaxable * CityTaxRate / 100) +
                   Round(UnitPriceTaxable * CountyTaxRate / 100) +
                   Round(UnitPriceTaxable * StateTaxRate / 100));

        LineAmtInclTax := UnitPriceTaxable * Qty + TotalTax;

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // Get Amount to Pay
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        AmountToPay := GetAmountToPay(POSSaleLine);
        AmountToPay := Round(AmountToPay, 1, '>');

        POSSession.GetSale(POSSaleUnit);
        POSSaleUnit.GetCurrentSale(POSSale);

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify Discount applied
        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();

        POSEntrySalesLine."POS Entry No." := POSEntry."Entry No.";
        POSEntrySalesLine."Line No." := POSSaleLine."Line No.";

        //Verify POS Entry Sales Line
        Assert.IsTrue(POSEntrySalesLine.Find(), 'Sale Line not created');
        Assert.AreEqual(POSSaleLine."Discount %", POSEntrySalesLine."Line Discount %", 'POSSaleLine."Discount %" <>POSEntrySalesLine."Line Discount %"');
        Assert.AreEqual(POSSaleLine."Discount Amount", POSEntrySalesLine."Line Discount Amount Incl. VAT", 'POSSaleLine."Discount Amount" <> POSEntrySalesLine."Line Discount Amount Incl. VAT"');
        Assert.AreEqual(POSSaleLine.Amount, POSEntrySalesLine."Amount Excl. VAT", 'POSSaleLine.Amount <> POSEntrySalesLine."Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", POSEntrySalesLine."Amount Incl. VAT", 'POSSaleLine."Amount Including VAT" <> POSEntrySalesLine."Amount Incl. VAT"');
        Assert.IsFalse(TaxJurisdiction.IsEmpty(), 'Tax Jurisdiction not found');

        VerifyVATforGLEntry(POSEntry, TaxArea);

        POSStore.GetProfile(POSPostingProfile);
        VerifySalesforGLEntry(POSEntry, POSPostingProfile."Gen. Bus. Posting Group");
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenEndSaleForSaleTaxInDirectSaleQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        TaxJurisdiction: Record "Tax Jurisdiction";
        TaxDetail: Record "Tax Detail";
        TaxArea: Record "Tax Area";
        POSPostingProfile: Record "NPR POS Posting Profile";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineAmtInclTax: Decimal;
        AmountToPay: Decimal;
        CityTaxRate: Decimal;
        CountyTaxRate: Decimal;
        StateTaxRate: Decimal;
        Qty: Decimal;
        TotalTax: Decimal;
        UnitPriceTaxable: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale ended

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();
        LibraryApplicationArea.EnableSalesTaxSetup();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        TaxJurisdiction.DeleteAll();
        CityTaxRate := 1.5;
        CountyTaxRate := 3.5;
        StateTaxRate := 5.5;
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, CityTaxRate, CountyTaxRate, StateTaxRate);

        //If it's set, reset maximum amount on Tax Details
        TaxDetail.SetRange("Tax Jurisdiction Code");
        TaxDetail.ModifyAll("Maximum Amount/Qty.", 0);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignTaxDetailToPOSPostingProfile(TaxArea.Code, true);

        // [GIVEN] Update rounding amount account
        UpdatePOSSalesRoundingAcc();

        // [GIVEN] Update Tax account (sales)
        LibraryTaxCalc.UpdateTaxJurisdictionSalesAccounts();

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 9, false);

        Qty := Round(1 + 2 / 3, 0.00001);
        UnitPriceTaxable := Item."Unit Price" * (1 - LineDiscPct / 100);
        TotalTax := Round(Qty * UnitPriceTaxable * CityTaxRate / 100) +
                   Round(Qty * UnitPriceTaxable * CountyTaxRate / 100) +
                   Round(Qty * UnitPriceTaxable * StateTaxRate / 100);

        LineAmtInclTax := Round(UnitPriceTaxable * Qty + TotalTax);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // Get Amount to Pay
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        AmountToPay := GetAmountToPay(POSSaleLine);
        AmountToPay := Round(AmountToPay, 1, '>');

        POSSession.GetSale(POSSaleUnit);
        POSSaleUnit.GetCurrentSale(POSSale);

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify Discount applied
        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();

        POSEntrySalesLine."POS Entry No." := POSEntry."Entry No.";
        POSEntrySalesLine."Line No." := POSSaleLine."Line No.";

        //Verify POS Entry Sales Line
        Assert.IsTrue(POSEntrySalesLine.Find(), 'Sale Line not created');
        Assert.AreEqual(POSSaleLine."Discount %", POSEntrySalesLine."Line Discount %", 'POSSaleLine."Discount %" <>POSEntrySalesLine."Line Discount %"');
        Assert.AreEqual(POSSaleLine."Discount Amount", POSEntrySalesLine."Line Discount Amount Incl. VAT", 'POSSaleLine."Discount Amount" <> POSEntrySalesLine."Line Discount Amount Incl. VAT"');
        Assert.AreEqual(POSSaleLine.Amount, POSEntrySalesLine."Amount Excl. VAT", 'POSSaleLine.Amount <> POSEntrySalesLine."Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", POSEntrySalesLine."Amount Incl. VAT", 'POSSaleLine."Amount Including VAT" <> POSEntrySalesLine."Amount Incl. VAT"');
        Assert.IsFalse(TaxJurisdiction.IsEmpty(), 'Tax Jurisdiction not found');

        VerifyVATforGLEntry(POSEntry, TaxArea);

        POSStore.GetProfile(POSPostingProfile);
        VerifySalesforGLEntry(POSEntry, POSPostingProfile."Gen. Bus. Posting Group");
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenEndSaleForSaleTaxInDebitSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        POSEntry: Record "NPR POS Entry";
        TaxJurisdiction: Record "Tax Jurisdiction";
        TaxDetail: Record "Tax Detail";
        TaxArea: Record "Tax Area";
        POSPostingProfile: Record "NPR POS Posting Profile";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineAmtInclTax: Decimal;
        AmountToPay: Decimal;
        CityTaxRate: Decimal;
        CountyTaxRate: Decimal;
        StateTaxRate: Decimal;
        Qty: Decimal;
        TotalTax: Decimal;
        UnitPriceTaxable: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is created

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        TaxJurisdiction.DeleteAll();
        CityTaxRate := 1.5;
        CountyTaxRate := 3.5;
        StateTaxRate := 5.5;
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, CityTaxRate, CountyTaxRate, StateTaxRate);

        //If it's set, reset maximum amount on Tax Details
        TaxDetail.SetRange("Tax Jurisdiction Code");
        TaxDetail.ModifyAll("Maximum Amount/Qty.", 0);

        // [GIVEN] Customer
        CreateCustomer(Customer, false, true, TaxArea.Code, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        POSStore.GetProfile(POSPostingProfile);
        POSPostingProfile."Default POS Posting Setup" := POSPostingProfile."Default POS Posting Setup"::Customer;
        POSPostingProfile.Modify();

        // [GIVEN] Update rounding amount account
        UpdatePOSSalesRoundingAcc();

        // [GIVEN] Update Tax account (sales)
        LibraryTaxCalc.UpdateTaxJurisdictionSalesAccounts();

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 7, false);

        Qty := 1;
        UnitPriceTaxable := Item."Unit Price" * (1 - LineDiscPct / 100);
        TotalTax := Qty * (Round(UnitPriceTaxable * CityTaxRate / 100) +
                   Round(UnitPriceTaxable * CountyTaxRate / 100) +
                   Round(UnitPriceTaxable * StateTaxRate / 100));

        LineAmtInclTax := UnitPriceTaxable * Qty + TotalTax;

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // Get Amount to Pay
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        AmountToPay := GetAmountToPay(POSSaleLine);
        AmountToPay := Round(AmountToPay, 1, '>');

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify Discount applied
        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();

        POSEntrySalesLine."POS Entry No." := POSEntry."Entry No.";
        POSEntrySalesLine."Line No." := POSSaleLine."Line No.";

        //Verify POS Entry Sales Line
        Assert.IsTrue(POSEntrySalesLine.Find(), 'Sale Line not created');
        Assert.AreEqual(POSSaleLine."Discount %", POSEntrySalesLine."Line Discount %", 'POSSaleLine."Discount %" <>POSEntrySalesLine."Line Discount %"');
        Assert.AreEqual(POSSaleLine."Discount Amount", POSEntrySalesLine."Line Discount Amount Excl. VAT", 'POSSaleLine."Discount Amount" <> POSEntrySalesLine."Line Discount Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine.Amount, POSEntrySalesLine."Amount Excl. VAT", 'POSSaleLine.Amount <> POSEntrySalesLine."Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", POSEntrySalesLine."Amount Incl. VAT", 'POSSaleLine."Amount Including VAT" <> POSEntrySalesLine."Amount Incl. VAT"');
        Assert.IsFalse(TaxJurisdiction.IsEmpty(), 'Tax Jurisdiction not found');

        VerifyVATforGLEntry(POSEntry, TaxArea);

        VerifySalesforGLEntry(POSEntry, Customer."Gen. Bus. Posting Group");
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenEndSaleForSaleTaxInDebitSaleQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        POSEntry: Record "NPR POS Entry";
        TaxJurisdiction: Record "Tax Jurisdiction";
        TaxDetail: Record "Tax Detail";
        TaxArea: Record "Tax Area";
        POSPostingProfile: Record "NPR POS Posting Profile";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineAmtInclTax: Decimal;
        AmountToPay: Decimal;
        CityTaxRate: Decimal;
        CountyTaxRate: Decimal;
        StateTaxRate: Decimal;
        Qty: Decimal;
        TotalTax: Decimal;
        UnitPriceTaxable: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is created

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        TaxJurisdiction.DeleteAll();
        CityTaxRate := 1.5;
        CountyTaxRate := 3.5;
        StateTaxRate := 5.5;
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, CityTaxRate, CountyTaxRate, StateTaxRate);

        //If it's set, reset maximum amount on Tax Details
        TaxDetail.SetRange("Tax Jurisdiction Code");
        TaxDetail.ModifyAll("Maximum Amount/Qty.", 0);

        // [GIVEN] Customer
        CreateCustomer(Customer, false, true, TaxArea.Code, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        POSStore.GetProfile(POSPostingProfile);
        POSPostingProfile."Default POS Posting Setup" := POSPostingProfile."Default POS Posting Setup"::Customer;
        POSPostingProfile.Modify();

        // [GIVEN] Update rounding amount account
        UpdatePOSSalesRoundingAcc();

        // [GIVEN] Update Tax account (sales)
        LibraryTaxCalc.UpdateTaxJurisdictionSalesAccounts();

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 7, false);

        Qty := Round(1 + 1 / 3, 0.00001);
        UnitPriceTaxable := Item."Unit Price" * (1 - LineDiscPct / 100);
        TotalTax := Round(Qty * UnitPriceTaxable * CityTaxRate / 100) +
                   Round(Qty * UnitPriceTaxable * CountyTaxRate / 100) +
                   Round(Qty * UnitPriceTaxable * StateTaxRate / 100);

        LineAmtInclTax := Round(UnitPriceTaxable * Qty + TotalTax);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // Get Amount to Pay
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        AmountToPay := GetAmountToPay(POSSaleLine);
        AmountToPay := Round(AmountToPay, 1, '>');

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify Discount applied
        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();

        POSEntrySalesLine."POS Entry No." := POSEntry."Entry No.";
        POSEntrySalesLine."Line No." := POSSaleLine."Line No.";

        //Verify POS Entry Sales Line
        Assert.IsTrue(POSEntrySalesLine.Find(), 'Sale Line not created');
        Assert.AreEqual(POSSaleLine."Discount %", POSEntrySalesLine."Line Discount %", 'POSSaleLine."Discount %" <>POSEntrySalesLine."Line Discount %"');
        Assert.AreEqual(POSSaleLine."Discount Amount", POSEntrySalesLine."Line Discount Amount Excl. VAT", 'POSSaleLine."Discount Amount" <> POSEntrySalesLine."Line Discount Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine.Amount, POSEntrySalesLine."Amount Excl. VAT", 'POSSaleLine.Amount <> POSEntrySalesLine."Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", POSEntrySalesLine."Amount Incl. VAT", 'POSSaleLine."Amount Including VAT" <> POSEntrySalesLine."Amount Incl. VAT"');
        Assert.IsFalse(TaxJurisdiction.IsEmpty(), 'Tax Jurisdiction not found');

        VerifyVATforGLEntry(POSEntry, TaxArea);

        VerifySalesforGLEntry(POSEntry, Customer."Gen. Bus. Posting Group");
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RelevantDiscountsFoundForDMLModify()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        xPOSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        TempDiscountPriority: Record "NPR Discount Priority" temporary;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SalesDiscCalcMgt: codeunit "NPR POS Sales Disc. Calc. Mgt.";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
    begin
        // [SCENARIO] Exersice & verify. Discount is prioritized when POS Sale Line has veeb exist for modify operation

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountPct(Item, LibraryRandom.RandDecInRange(1, 100, 5), false);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);
        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Active Sales Line for Item
        CreatePOSSaleLine(Item, POSSale, POSSaleLine);

        // [WHEN] Modify operation performed
        SalesDiscCalcMgt.OnFindActiveSaleLineDiscounts(TempDiscountPriority, POSSale, POSSaleLine, xPOSSaleLine, 1);

        // [THEN] Verify Discount Priority enabled
        Assert.IsTrue(TempDiscountPriority.Get(DiscSourceTableId()), 'Discount not created');
        Assert.IsFalse(TempDiscountPriority.Disabled, 'Discount is disabled');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenPOSSaleLineUpdatedQtyForNormalTaxInDirectSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        Qty: Decimal;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is modified

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();
        LibraryApplicationArea.EnableVATSetup();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 9, false);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [WHEN] Quantity changed
        Qty := 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtInclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100))) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenPOSSaleLineUpdatedQtyForNormalTaxInDebitSaleForward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        Qty: Decimal;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is modified

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, false, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 7, false);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [WHEN] Quantity changed
        Qty := 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100);
        Item."Unit Price" := Item."Unit Price" / (1 + VATPostingSetup."VAT %" / 100);
        LineAmtExclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax * (1 + VATPostingSetup."VAT %" / 100);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '((Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) / (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '((Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100))) * (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '(Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)))  <> POSSaleLine.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenPOSSaleLineUpdatedQtyForNormalTaxInDebitSaleBackward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        Qty: Decimal;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is modified

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, true, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 7, false);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [WHEN] Quantity changed
        Qty := 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtInclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100))) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenEndSaleForNormalTaxInDirectSaleUpdatedQty()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        GLEntry: Record "G/L Entry";
        GeneralPostingSetup: Record "General Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        AmountToPay: Decimal;
        Qty: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale ended after updating quantity on an active sale

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();
        LibraryApplicationArea.EnableVATSetup();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 7, false);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Quantity changed
        Qty := 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtInclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

        // Get Amount to Pay
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        AmountToPay := GetAmountToPay(POSSaleLine);
        AmountToPay := Round(AmountToPay, 1, '>');

        POSSession.GetSale(POSSaleUnit);
        POSSaleUnit.GetCurrentSale(POSSale);

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify Discount applied
        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();

        POSEntrySalesLine."POS Entry No." := POSEntry."Entry No.";
        POSEntrySalesLine."Line No." := POSSaleLine."Line No.";

        //Verify POS Entry Sales Line
        Assert.IsTrue(POSEntrySalesLine.Find(), 'Sale Line not created');
        Assert.AreEqual(POSSaleLine."Discount %", POSEntrySalesLine."Line Discount %", 'POSSaleLine."Discount %" <>POSEntrySalesLine."Line Discount %"');
        Assert.AreEqual(POSSaleLine."Discount Amount", POSEntrySalesLine."Line Discount Amount Incl. VAT", 'POSSaleLine."Discount Amount" <> POSEntrySalesLine."Line Discount Amount Incl. VAT"');
        Assert.AreEqual(POSSaleLine.Amount, POSEntrySalesLine."Amount Excl. VAT", 'POSSaleLine.Amount <> POSEntrySalesLine."Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", POSEntrySalesLine."Amount Incl. VAT", 'POSSaleLine."Amount Including VAT" <> POSEntrySalesLine."Amount Incl. VAT"');
        Assert.IsTrue(GeneralPostingSetup.Get(POSSaleLine."Gen. Bus. Posting Group", POSSaleLine."Gen. Prod. Posting Group"), 'General Posting Setup not found');

        //Verify G/L Entry
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        GLEntry.SetRange("Posting Date", POSEntry."Posting Date");
        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Account');
        Assert.AreEqual(Qty * Item."Unit Price", -(GLEntry.Amount + GLEntry."VAT Amount"), '(Item."Unit Price" * 1) <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) <> GLEntry.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenEndSaleForNormalTaxInDebitSaleForwardUpdatedQty()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        POSEntry: Record "NPR POS Entry";
        GLEntry: Record "G/L Entry";
        GeneralPostingSetup: Record "General Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        AmountToPay: Decimal;
        Qty: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale ended after updating quantity on an active sale

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, false, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 7, false);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Quantity changed
        Qty := 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtExclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax * (1 + VATPostingSetup."VAT %" / 100);

        // Get Amount to Pay
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        AmountToPay := GetAmountToPay(POSSaleLine);
        AmountToPay := Round(AmountToPay, 1, '>');

        POSSession.GetSale(POSSaleUnit);
        POSSaleUnit.GetCurrentSale(POSSale);

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify Discount applied
        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();

        POSEntrySalesLine."POS Entry No." := POSEntry."Entry No.";
        POSEntrySalesLine."Line No." := POSSaleLine."Line No.";

        //Verify POS Entry Sales Line
        Assert.IsTrue(POSEntrySalesLine.Find(), 'Sale Line not created');
        Assert.AreEqual(POSSaleLine."Discount %", POSEntrySalesLine."Line Discount %", 'POSSaleLine."Discount %" <>POSEntrySalesLine."Line Discount %"');
        Assert.AreEqual(POSSaleLine."Discount Amount", POSEntrySalesLine."Line Discount Amount Excl. VAT", 'POSSaleLine."Discount Amount" <> POSEntrySalesLine."Line Discount Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine.Amount, POSEntrySalesLine."Amount Excl. VAT", 'POSSaleLine.Amount <> POSEntrySalesLine."Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", POSEntrySalesLine."Amount Incl. VAT", 'POSSaleLine."Amount Including VAT" <> POSEntrySalesLine."Amount Incl. VAT"');
        Assert.IsTrue(GeneralPostingSetup.Get(POSSaleLine."Gen. Bus. Posting Group", POSSaleLine."Gen. Prod. Posting Group"), 'General Posting Setup not found');

        //Verify G/L Entry
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        GLEntry.SetRange("Posting Date", POSEntry."Posting Date");
        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Account');
        Assert.AreEqual(Qty * Item."Unit Price", -(GLEntry.Amount + GLEntry."VAT Amount"), '(Item."Unit Price" * 1) <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) <> GLEntry.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenEndSaleForNormalTaxInDebitSaleBackwardUpdatedQty()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        POSEntry: Record "NPR POS Entry";
        GLEntry: Record "G/L Entry";
        GeneralPostingSetup: Record "General Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        AmountToPay: Decimal;
        Qty: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale ended after updating quantity on an active sale

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, true, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 7, false);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Quantity changed
        Qty := 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtInclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

        // Get Amount to Pay
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        AmountToPay := GetAmountToPay(POSSaleLine);
        AmountToPay := Round(AmountToPay, 1, '>');

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify Discount applied
        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();

        POSEntrySalesLine."POS Entry No." := POSEntry."Entry No.";
        POSEntrySalesLine."Line No." := POSSaleLine."Line No.";

        //Verify POS Entry Sales Line
        Assert.IsTrue(POSEntrySalesLine.Find(), 'Sale Line not created');
        Assert.AreEqual(POSSaleLine."Discount %", POSEntrySalesLine."Line Discount %", 'POSSaleLine."Discount %" <>POSEntrySalesLine."Line Discount %"');
        Assert.AreEqual(POSSaleLine."Discount Amount", POSEntrySalesLine."Line Discount Amount Incl. VAT", 'POSSaleLine."Discount Amount" <> POSEntrySalesLine."Line Discount Amount Incl. VAT"');
        Assert.AreEqual(POSSaleLine.Amount, POSEntrySalesLine."Amount Excl. VAT", 'POSSaleLine.Amount <> POSEntrySalesLine."Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", POSEntrySalesLine."Amount Incl. VAT", 'POSSaleLine."Amount Including VAT" <> POSEntrySalesLine."Amount Incl. VAT"');
        Assert.IsTrue(GeneralPostingSetup.Get(POSSaleLine."Gen. Bus. Posting Group", POSSaleLine."Gen. Prod. Posting Group"), 'General Posting Setup not found');

        //Verify G/L Entry
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        GLEntry.SetRange("Posting Date", POSEntry."Posting Date");
        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Account');
        Assert.AreEqual(Qty * Item."Unit Price", -(GLEntry.Amount + GLEntry."VAT Amount"), '(Item."Unit Price" * 1) <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) <> GLEntry.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenPOSSaleLineUpdatedQtyForRevChrgTaxInDirectSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        Qty: Decimal;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is modified

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();
        LibraryApplicationArea.EnableVATSetup();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 9, false);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [WHEN] Quantity changed
        Qty := 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtInclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100))) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenPOSSaleLineUpdatedQtyForRevChrgTaxInDebitSaleForward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        UnitPrice: Decimal;
        Qty: Decimal;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is modified

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, false, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 7, false);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [WHEN] Quantity changed
        Qty := 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        UnitPrice := Item."Unit Price" / (1 + VATPostingSetup."VAT %" / 100);
        LineDiscAmt := (Qty * Item."Unit Price" * LineDiscPct / 100) / (1 + VATPostingSetup."VAT %" / 100);
        LineAmtExclTax := Qty * UnitPrice - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax * (1 + VATPostingSetup."VAT %" / 100);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '((Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) / (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '((Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100))) * (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '(Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)))  <> POSSaleLine.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenPOSSaleLineUpdatedQtyForRevChrgTaxInDebitSaleBackward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        Qty: Decimal;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is modified

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, true, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 7, false);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [WHEN] Quantity changed
        Qty := 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtInclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100))) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenEndSaleForRevChrgTaxInDirectSaleUpdatedQty()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        GLEntry: Record "G/L Entry";
        GeneralPostingSetup: Record "General Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        AmountToPay: Decimal;
        Qty: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale ended after updating quantity on an active sale

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();
        LibraryApplicationArea.EnableSalesTaxSetup();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 9, false);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Quantity changed
        Qty := 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtInclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

        // Get Amount to Pay
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        AmountToPay := GetAmountToPay(POSSaleLine);
        AmountToPay := Round(AmountToPay, 1, '>');

        POSSession.GetSale(POSSaleUnit);
        POSSaleUnit.GetCurrentSale(POSSale);

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify Discount applied
        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();

        POSEntrySalesLine."POS Entry No." := POSEntry."Entry No.";
        POSEntrySalesLine."Line No." := POSSaleLine."Line No.";

        //Verify POS Entry Sales Line
        Assert.IsTrue(POSEntrySalesLine.Find(), 'Sale Line not created');
        Assert.AreEqual(POSSaleLine."Discount %", POSEntrySalesLine."Line Discount %", 'POSSaleLine."Discount %" <>POSEntrySalesLine."Line Discount %"');
        Assert.AreEqual(POSSaleLine."Discount Amount", POSEntrySalesLine."Line Discount Amount Incl. VAT", 'POSSaleLine."Discount Amount" <> POSEntrySalesLine."Line Discount Amount Incl. VAT"');
        Assert.AreEqual(POSSaleLine.Amount, POSEntrySalesLine."Amount Excl. VAT", 'POSSaleLine.Amount <> POSEntrySalesLine."Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", POSEntrySalesLine."Amount Incl. VAT", 'POSSaleLine."Amount Including VAT" <> POSEntrySalesLine."Amount Incl. VAT"');
        Assert.IsTrue(GeneralPostingSetup.Get(POSSaleLine."Gen. Bus. Posting Group", POSSaleLine."Gen. Prod. Posting Group"), 'General Posting Setup not found');

        //Verify G/L Entry
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        GLEntry.SetRange("Posting Date", POSEntry."Posting Date");
        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Account');
        Assert.AreEqual(Qty * Item."Unit Price", -(GLEntry.Amount + GLEntry."VAT Amount"), '(Item."Unit Price" * 1) <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) <> GLEntry.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenEndSaleForRevChrgTaxInDebitSaleForwardUpdatedQty()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        POSEntry: Record "NPR POS Entry";
        GLEntry: Record "G/L Entry";
        GeneralPostingSetup: Record "General Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        AmountToPay: Decimal;
        Qty: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale ended after updating quantity on an active sale

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, false, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 7, false);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Quantity changed
        Qty := 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtExclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax * (1 + VATPostingSetup."VAT %" / 100);

        // Get Amount to Pay
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        AmountToPay := GetAmountToPay(POSSaleLine);
        AmountToPay := Round(AmountToPay, 1, '>');

        POSSession.GetSale(POSSaleUnit);
        POSSaleUnit.GetCurrentSale(POSSale);

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify Discount applied
        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();

        POSEntrySalesLine."POS Entry No." := POSEntry."Entry No.";
        POSEntrySalesLine."Line No." := POSSaleLine."Line No.";

        //Verify POS Entry Sales Line
        Assert.IsTrue(POSEntrySalesLine.Find(), 'Sale Line not created');
        Assert.AreEqual(POSSaleLine."Discount %", POSEntrySalesLine."Line Discount %", 'POSSaleLine."Discount %" <>POSEntrySalesLine."Line Discount %"');
        Assert.AreEqual(POSSaleLine."Discount Amount", POSEntrySalesLine."Line Discount Amount Excl. VAT", 'POSSaleLine."Discount Amount" <> POSEntrySalesLine."Line Discount Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine.Amount, POSEntrySalesLine."Amount Excl. VAT", 'POSSaleLine.Amount <> POSEntrySalesLine."Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", POSEntrySalesLine."Amount Incl. VAT", 'POSSaleLine."Amount Including VAT" <> POSEntrySalesLine."Amount Incl. VAT"');
        Assert.IsTrue(GeneralPostingSetup.Get(POSSaleLine."Gen. Bus. Posting Group", POSSaleLine."Gen. Prod. Posting Group"), 'General Posting Setup not found');

        //Verify G/L Entry
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        GLEntry.SetRange("Posting Date", POSEntry."Posting Date");
        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Account');
        Assert.AreEqual(Qty * Item."Unit Price", -(GLEntry.Amount + GLEntry."VAT Amount"), '(Item."Unit Price" * 1) <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) <> GLEntry.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenEndSaleForRevChrgTaxInDebitSaleBackwardUpdatedQty()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        POSEntry: Record "NPR POS Entry";
        GLEntry: Record "G/L Entry";
        GeneralPostingSetup: Record "General Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        AmountToPay: Decimal;
        Qty: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale ended after updating quantity on an active sale

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, true, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 7, false);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Quantity changed
        Qty := 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtInclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

        // Get Amount to Pay
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        AmountToPay := GetAmountToPay(POSSaleLine);
        AmountToPay := Round(AmountToPay, 1, '>');

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify Discount applied
        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();

        POSEntrySalesLine."POS Entry No." := POSEntry."Entry No.";
        POSEntrySalesLine."Line No." := POSSaleLine."Line No.";

        //Verify POS Entry Sales Line
        Assert.IsTrue(POSEntrySalesLine.Find(), 'Sale Line not created');
        Assert.AreEqual(POSSaleLine."Discount %", POSEntrySalesLine."Line Discount %", 'POSSaleLine."Discount %" <>POSEntrySalesLine."Line Discount %"');
        Assert.AreEqual(POSSaleLine."Discount Amount", POSEntrySalesLine."Line Discount Amount Incl. VAT", 'POSSaleLine."Discount Amount" <> POSEntrySalesLine."Line Discount Amount Incl. VAT"');
        Assert.AreEqual(POSSaleLine.Amount, POSEntrySalesLine."Amount Excl. VAT", 'POSSaleLine.Amount <> POSEntrySalesLine."Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", POSEntrySalesLine."Amount Incl. VAT", 'POSSaleLine."Amount Including VAT" <> POSEntrySalesLine."Amount Incl. VAT"');
        Assert.IsTrue(GeneralPostingSetup.Get(POSSaleLine."Gen. Bus. Posting Group", POSSaleLine."Gen. Prod. Posting Group"), 'General Posting Setup not found');

        //Verify G/L Entry
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        GLEntry.SetRange("Posting Date", POSEntry."Posting Date");
        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Account');
        Assert.AreEqual(Qty * Item."Unit Price", -(GLEntry.Amount + GLEntry."VAT Amount"), '(Item."Unit Price" * 1) <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) <> GLEntry.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenPOSSaleLineUpdatedForSaleTaxInDirectSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        TaxArea: Record "Tax Area";
        TaxDetail: Record "Tax Detail";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        CityTaxRate: Decimal;
        CountyTaxRate: Decimal;
        StateTaxRate: Decimal;
        TotalTax: Decimal;
        Qty: Decimal;
        UnitPriceTaxable: Decimal;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is created

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();
        LibraryApplicationArea.EnableSalesTaxSetup();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        CityTaxRate := 1.5;
        CountyTaxRate := 3.5;
        StateTaxRate := 5.5;
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, CityTaxRate, CountyTaxRate, StateTaxRate);

        //If it's set, reset maximum amount on Tax Details
        TaxDetail.SetRange("Tax Jurisdiction Code");
        TaxDetail.ModifyAll("Maximum Amount/Qty.", 0);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignTaxDetailToPOSPostingProfile(TaxArea.Code, true);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 9, false);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [WHEN] Quantity changed
        Qty := 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        UnitPriceTaxable := Item."Unit Price" * (1 - LineDiscPct / 100);
        TotalTax := Qty * (Round(UnitPriceTaxable * CityTaxRate / 100) +
                   Round(UnitPriceTaxable * CountyTaxRate / 100) +
                   Round(UnitPriceTaxable * StateTaxRate / 100));
        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtExclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax + TotalTax;

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", 'LineDiscAmt <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '(Qty * Item."Unit Price" - LineDiscAmt) <> POSSaleLine.Amount');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - LineDiscAmt) + TotalTax <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenPOSSaleLineUpdatedForSaleTaxInDebitSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        POSPostingProfile: Record "NPR POS Posting Profile";
        TaxArea: Record "Tax Area";
        TaxDetail: Record "Tax Detail";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
        CityTaxRate: Decimal;
        CountyTaxRate: Decimal;
        StateTaxRate: Decimal;
        TotalTax: Decimal;
        Qty: Decimal;
        UnitPriceTaxable: Decimal;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is created

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        CityTaxRate := 1.5;
        CountyTaxRate := 3.5;
        StateTaxRate := 5.5;
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, CityTaxRate, CountyTaxRate, StateTaxRate);

        //If it's set, reset maximum amount on Tax Details
        TaxDetail.SetRange("Tax Jurisdiction Code");
        TaxDetail.ModifyAll("Maximum Amount/Qty.", 0);

        // [GIVEN] Customer
        CreateCustomer(Customer, false, true, TaxArea.Code, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        POSStore.GetProfile(POSPostingProfile);
        POSPostingProfile."Default POS Posting Setup" := POSPostingProfile."Default POS Posting Setup"::Customer;
        POSPostingProfile.Modify();

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 7, false);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [WHEN] Quantity changed
        Qty := 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        UnitPriceTaxable := Item."Unit Price" * (1 - LineDiscPct / 100);
        TotalTax := Qty * (Round(UnitPriceTaxable * CityTaxRate / 100) +
                           Round(UnitPriceTaxable * CountyTaxRate / 100) +
                           Round(UnitPriceTaxable * StateTaxRate / 100));
        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtExclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax + TotalTax;

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", 'LineDiscAmt <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '(Qty * Item."Unit Price" - LineDiscAmt)  <> POSSaleLine.Amount');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - LineDiscAmt) + TotalTax <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenEndSaleForSaleTaxInDirectSaleUpdatedQty()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        TaxJurisdiction: Record "Tax Jurisdiction";
        TaxDetail: Record "Tax Detail";
        TaxArea: Record "Tax Area";
        POSPostingProfile: Record "NPR POS Posting Profile";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineAmtInclTax: Decimal;
        AmountToPay: Decimal;
        CityTaxRate: Decimal;
        CountyTaxRate: Decimal;
        StateTaxRate: Decimal;
        Qty: Decimal;
        TotalTax: Decimal;
        UnitPriceTaxable: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale ended

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();
        LibraryApplicationArea.EnableSalesTaxSetup();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        TaxJurisdiction.DeleteAll();
        CityTaxRate := 1.5;
        CountyTaxRate := 3.5;
        StateTaxRate := 5.5;
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, CityTaxRate, CountyTaxRate, StateTaxRate);

        //If it's set, reset maximum amount on Tax Details
        TaxDetail.SetRange("Tax Jurisdiction Code");
        TaxDetail.ModifyAll("Maximum Amount/Qty.", 0);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignTaxDetailToPOSPostingProfile(TaxArea.Code, true);

        // [GIVEN] Update rounding amount account
        UpdatePOSSalesRoundingAcc();

        // [GIVEN] Update Tax account (sales)
        LibraryTaxCalc.UpdateTaxJurisdictionSalesAccounts();

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 9, false);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Quantity changed
        Qty := 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        UnitPriceTaxable := Item."Unit Price" * (1 - LineDiscPct / 100);
        TotalTax := Qty * (Round(UnitPriceTaxable * CityTaxRate / 100) +
                   Round(UnitPriceTaxable * CountyTaxRate / 100) +
                   Round(UnitPriceTaxable * StateTaxRate / 100));

        LineAmtInclTax := Qty * UnitPriceTaxable + TotalTax;

        // Get Amount to Pay
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        AmountToPay := GetAmountToPay(POSSaleLine);
        AmountToPay := Round(AmountToPay, 1, '>');

        POSSession.GetSale(POSSaleUnit);
        POSSaleUnit.GetCurrentSale(POSSale);

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify Discount applied
        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();

        POSEntrySalesLine."POS Entry No." := POSEntry."Entry No.";
        POSEntrySalesLine."Line No." := POSSaleLine."Line No.";

        //Verify POS Entry Sales Line
        Assert.IsTrue(POSEntrySalesLine.Find(), 'Sale Line not created');
        Assert.AreEqual(POSSaleLine."Discount %", POSEntrySalesLine."Line Discount %", 'POSSaleLine."Discount %" <>POSEntrySalesLine."Line Discount %"');
        Assert.AreEqual(POSSaleLine."Discount Amount", POSEntrySalesLine."Line Discount Amount Incl. VAT", 'POSSaleLine."Discount Amount" <> POSEntrySalesLine."Line Discount Amount Incl. VAT"');
        Assert.AreEqual(POSSaleLine.Amount, POSEntrySalesLine."Amount Excl. VAT", 'POSSaleLine.Amount <> POSEntrySalesLine."Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", POSEntrySalesLine."Amount Incl. VAT", 'POSSaleLine."Amount Including VAT" <> POSEntrySalesLine."Amount Incl. VAT"');
        Assert.IsFalse(TaxJurisdiction.IsEmpty(), 'Tax Jurisdiction not found');

        VerifyVATforGLEntry(POSEntry, TaxArea);

        POSStore.GetProfile(POSPostingProfile);
        VerifySalesforGLEntry(POSEntry, POSPostingProfile."Gen. Bus. Posting Group");
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenEndSaleForSaleTaxInDebitSaleUpdatedQty()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        POSEntry: Record "NPR POS Entry";
        TaxJurisdiction: Record "Tax Jurisdiction";
        TaxDetail: Record "Tax Detail";
        TaxArea: Record "Tax Area";
        POSPostingProfile: Record "NPR POS Posting Profile";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineAmtInclTax: Decimal;
        AmountToPay: Decimal;
        CityTaxRate: Decimal;
        CountyTaxRate: Decimal;
        StateTaxRate: Decimal;
        Qty: Decimal;
        TotalTax: Decimal;
        UnitPriceTaxable: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is created

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        TaxJurisdiction.DeleteAll();
        CityTaxRate := 1.5;
        CountyTaxRate := 3.5;
        StateTaxRate := 5.5;
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, CityTaxRate, CountyTaxRate, StateTaxRate);

        //If it's set, reset maximum amount on Tax Details
        TaxDetail.SetRange("Tax Jurisdiction Code");
        TaxDetail.ModifyAll("Maximum Amount/Qty.", 0);

        // [GIVEN] Customer
        CreateCustomer(Customer, false, true, TaxArea.Code, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        POSStore.GetProfile(POSPostingProfile);
        POSPostingProfile."Default POS Posting Setup" := POSPostingProfile."Default POS Posting Setup"::Customer;
        POSPostingProfile.Modify();

        // [GIVEN] Update rounding amount account
        UpdatePOSSalesRoundingAcc();

        // [GIVEN] Update Tax account (sales)
        LibraryTaxCalc.UpdateTaxJurisdictionSalesAccounts();

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        LineDiscPct := CreateTotalDiscountPct(Item, 7, false);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Quantity changed
        Qty := 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        UnitPriceTaxable := Item."Unit Price" * (1 - LineDiscPct / 100);
        TotalTax := Qty * (Round(UnitPriceTaxable * CityTaxRate / 100) +
                   Round(UnitPriceTaxable * CountyTaxRate / 100) +
                   Round(UnitPriceTaxable * StateTaxRate / 100));

        LineAmtInclTax := UnitPriceTaxable * Qty + TotalTax;

        // Get Amount to Pay
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        AmountToPay := GetAmountToPay(POSSaleLine);
        AmountToPay := Round(AmountToPay, 1, '>');

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify Discount applied
        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();

        POSEntrySalesLine."POS Entry No." := POSEntry."Entry No.";
        POSEntrySalesLine."Line No." := POSSaleLine."Line No.";

        //Verify POS Entry Sales Line
        Assert.IsTrue(POSEntrySalesLine.Find(), 'Sale Line not created');
        Assert.AreEqual(POSSaleLine."Discount %", POSEntrySalesLine."Line Discount %", 'POSSaleLine."Discount %" <>POSEntrySalesLine."Line Discount %"');
        Assert.AreEqual(POSSaleLine."Discount Amount", POSEntrySalesLine."Line Discount Amount Excl. VAT", 'POSSaleLine."Discount Amount" <> POSEntrySalesLine."Line Discount Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine.Amount, POSEntrySalesLine."Amount Excl. VAT", 'POSSaleLine.Amount <> POSEntrySalesLine."Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", POSEntrySalesLine."Amount Incl. VAT", 'POSSaleLine."Amount Including VAT" <> POSEntrySalesLine."Amount Incl. VAT"');
        Assert.IsFalse(TaxJurisdiction.IsEmpty(), 'Tax Jurisdiction not found');

        VerifyVATforGLEntry(POSEntry, TaxArea);
        VerifySalesforGLEntry(POSEntry, Customer."Gen. Bus. Posting Group");
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RelevantDiscountsFoundForDMLDelete()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        xPOSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        TempDiscountPriority: Record "NPR Discount Priority" temporary;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SalesDiscCalcMgt: codeunit "NPR POS Sales Disc. Calc. Mgt.";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
    begin
        // [SCENARIO] Exersice & verify. Discount is prioritized when POS Sale Line has been deleted

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountPct(Item, LibraryRandom.RandDecInRange(1, 100, 5), false);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);
        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Active Sales Line for Item
        CreatePOSSaleLine(Item, POSSale, POSSaleLine);

        // [WHEN] Delete operation performed
        SalesDiscCalcMgt.OnFindActiveSaleLineDiscounts(TempDiscountPriority, POSSale, POSSaleLine, xPOSSaleLine, 2);

        // [THEN] Verify Discount Priority enabled
        Assert.IsTrue(TempDiscountPriority.Get(DiscSourceTableId()), 'Discount not created');
        Assert.IsFalse(TempDiscountPriority.Disabled, 'Discount is disabled');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenPOSSaleLineDeletedForNormalTaxInDirectSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is deleted

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();
        LibraryApplicationArea.EnableVATSetup();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountPct(Item, 9, false);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Quantity changed
        Qty := 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [WHEN] Delete POS Sale Line
        POSSaleLineUnit.DeleteLine();

        // [THEN] Verify Discount not applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        Assert.IsFalse(POSSaleLineUnit.RefreshCurrent(), 'POS Sale Line has not been deleted');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenPOSSaleLineDeletedForNormalTaxInDebitSaleForward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is deleted

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, false, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountPct(Item, 7, false);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Quantity changed
        Qty := 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [WHEN] Delete POS Sale Line
        POSSaleLineUnit.DeleteLine();

        // [THEN] Verify Discount not applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        Assert.IsFalse(POSSaleLineUnit.RefreshCurrent(), 'POS Sale Line has not been deleted');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenPOSSaleLineDeletedForNormalTaxInDebitSaleBackward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is deleted

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, true, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountPct(Item, 7, false);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Quantity changed
        Qty := 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [WHEN] Delete POS Sale Line
        POSSaleLineUnit.DeleteLine();

        // [THEN] Verify Discount not applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        Assert.IsFalse(POSSaleLineUnit.RefreshCurrent(), 'POS Sale Line has not been deleted');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenPOSSaleLineDeletedForRevChrgTaxInDirectSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is deleted

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();
        LibraryApplicationArea.EnableVATSetup();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountPct(Item, 9, false);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Quantity changed
        Qty := 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [WHEN] Delete POS Sale Line
        POSSaleLineUnit.DeleteLine();

        // [THEN] Verify Discount not applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        Assert.IsFalse(POSSaleLineUnit.RefreshCurrent(), 'POS Sale Line has not been deleted');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenPOSSaleLineDeletedForRevChrgTaxInDebitSaleForward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is deleted

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, false, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountPct(Item, 7, false);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Quantity changed
        Qty := 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [WHEN] Delete POS Sale Line
        POSSaleLineUnit.DeleteLine();

        // [THEN] Verify Discount not applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        Assert.IsFalse(POSSaleLineUnit.RefreshCurrent(), 'POS Sale Line has not been deleted');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenPOSSaleLineDeletedForRevChrgTaxInDebitSaleBackward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is deleted

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, true, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountPct(Item, 7, false);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Quantity changed
        Qty := 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [WHEN] Delete POS Sale Line
        POSSaleLineUnit.DeleteLine();

        // [THEN] Verify Discount not applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        Assert.IsFalse(POSSaleLineUnit.RefreshCurrent(), 'POS Sale Line has not been deleted');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenPOSSaleLineDeletedForSaleTaxInDirectSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        TaxArea: Record "Tax Area";
        TaxDetail: Record "Tax Detail";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        CityTaxRate: Decimal;
        CountyTaxRate: Decimal;
        StateTaxRate: Decimal;
        Qty: Decimal;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is deleted

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();
        LibraryApplicationArea.EnableSalesTaxSetup();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        CityTaxRate := 1.5;
        CountyTaxRate := 3.5;
        StateTaxRate := 5.5;
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, CityTaxRate, CountyTaxRate, StateTaxRate);

        //If it's set, reset maximum amount on Tax Details
        TaxDetail.SetRange("Tax Jurisdiction Code");
        TaxDetail.ModifyAll("Maximum Amount/Qty.", 0);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignTaxDetailToPOSPostingProfile(TaxArea.Code, true);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountPct(Item, 9, false);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [WHEN] Quantity changed
        Qty := 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [WHEN] Delete POS Sale Line
        POSSaleLineUnit.DeleteLine();

        // [THEN] Verify Discount not applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        Assert.IsFalse(POSSaleLineUnit.RefreshCurrent(), 'POS Sale Line has not been deleted');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenPOSSaleLineDeletedForSaleTaxInDebitSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        POSPostingProfile: Record "NPR POS Posting Profile";
        TaxArea: Record "Tax Area";
        TaxDetail: Record "Tax Detail";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        CityTaxRate: Decimal;
        CountyTaxRate: Decimal;
        StateTaxRate: Decimal;
        Qty: Decimal;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is deleted

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        CityTaxRate := 1.5;
        CountyTaxRate := 3.5;
        StateTaxRate := 5.5;
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, CityTaxRate, CountyTaxRate, StateTaxRate);

        //If it's set, reset maximum amount on Tax Details
        TaxDetail.SetRange("Tax Jurisdiction Code");
        TaxDetail.ModifyAll("Maximum Amount/Qty.", 0);

        // [GIVEN] Customer
        CreateCustomer(Customer, false, true, TaxArea.Code, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        POSStore.GetProfile(POSPostingProfile);
        POSPostingProfile."Default POS Posting Setup" := POSPostingProfile."Default POS Posting Setup"::Customer;
        POSPostingProfile.Modify();

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountPct(Item, 7, false);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [WHEN] Quantity changed
        Qty := 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [WHEN] Delete POS Sale Line
        POSSaleLineUnit.DeleteLine();

        // [THEN] Verify Discount not applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        Assert.IsFalse(POSSaleLineUnit.RefreshCurrent(), 'POS Sale Line has not been deleted');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyMixedDiscountTotalDiscountAmountWithVATPerMinQtyWhenLineAmountLowerThanTotalDiscountAmount()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
    begin
        // [SCENARIO] Mixed Discount applied Total Discount Amount per Min. Qty. with VAT when line amount is lower than Total Discount Amount

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountAmountTotalDiscountAmtPerMinQty(Item, 2000, false);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", 0, 'Total Discount not applied according to scenario.');
        Assert.AreNearlyEqual(POSSaleLine."Discount Amount", POSSaleLine.Quantity * POSSaleLine."Unit Price", 0.1, 'Discount Amount not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyMixedDiscountTotalDiscountAmountWithoutVATPerMinQtyWhenLineAmountLowerThanTotalDiscountAmount()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        Item: Record Item;
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        Qty: Decimal;
    begin
        // [SCENARIO] Mixed Discount applied Total Discount Amount per Min. Qty. without VAT when line amount is lower than Total Discount Amount

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Customer
        CreateCustomer(Customer, false, true);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountAmountTotalDiscountAmtPerMinQty(Item, 2000, false);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(POSSaleLine."Amount", 0, 'Total Discount not applied according to scenario.');
        Assert.AreNearlyEqual(POSSaleLine."Unit Price", Item."Unit Price" / (1 + POSSaleLine."VAT %" / 100), 0.1, 'Unit Price not calculated according to scenario.');
        Assert.AreNearlyEqual(POSSaleLine."Discount Amount", POSSaleLine.Quantity * POSSaleLine."Unit Price", 0.1, 'Discount Amount not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyMixedDiscountTotalAmountPerMinQtyWithVATWhenLineAmountLowerThanTotalDiscountAmount()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
    begin
        // [SCENARIO] Mixed Discount applied Total Amount per Min. Qty. with VAT when line amount is lower than Total Discount Amount

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountAmountTotalAmtPerMinQty(Item, 2000, false);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount is not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(POSSaleLine."Discount Amount", 0, 'Discount Amount not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyMixedDiscountTotalAmountWithoutVATPerMinQtyWhenLineAmountLowerThanTotalDiscountAmount()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        Item: Record Item;
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        Qty: Decimal;
    begin
        // [SCENARIO] Mixed Discount applied Total Amount per Min. Qty. without VAT when line amount is lower than Total Discount Amount

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Customer
        CreateCustomer(Customer, false, true);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, Customer."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountAmountTotalAmtPerMinQty(Item, 2000, false);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount is not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreNearlyEqual(POSSaleLine."Unit Price", Item."Unit Price" / (1 + POSSaleLine."VAT %" / 100), 0.1, 'Unit Price not calculated according to scenario.');
        Assert.AreEqual(POSSaleLine."Discount Amount", 0, 'Discount Amount not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DisabledMixDiscountApplication()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
    begin
        // [SCENARIO] Pending mix discount to be applied on item

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountAmountHeader(MixedDiscount, 2000, false);
        MixedDiscount.Status := MixedDiscount.Status::Pending;
        MixedDiscount.Modify(true);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::" ", 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = '', 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreNotEqual(POSSaleLine."Amount Including VAT", 0, 'Total Discount not applied according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ActiveMixDiscountInTheFutureApplication()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        DiscountAmount: Decimal;
    begin
        // [SCENARIO] Active mix discount to be applied on item but with start date set in the future

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountAmountHeader(MixedDiscount, 2000, false);
        MixedDiscount."Starting date" := Today() + 2;
        MixedDiscount.Modify(true);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::" ", 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = '', 'Total Discount not applied according to scenario.');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreNotEqual(POSSaleLine."Amount Including VAT", 0, 'Total Discount not applied according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DisabledMixDiscountInTheFutureApplication()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        DiscountAmount: Decimal;
    begin
        // [SCENARIO] Pending mix discount to be applied on item but with start date set in the future

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountAmountHeader(MixedDiscount, 2000, false);
        MixedDiscount.Status := MixedDiscount.Status::Pending;
        MixedDiscount."Starting date" := Today() + 2;
        MixedDiscount.Modify(true);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::" ", 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = '', 'Total Discount not applied according to scenario.');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreNotEqual(POSSaleLine."Amount Including VAT", 0, 'Total Discount not applied according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DisabledMixDiscountInThePastApplication()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        DiscountAmount: Decimal;
    begin
        // [SCENARIO] Pending mix discount to be applied on item but with end date set in the past

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountAmountHeader(MixedDiscount, 2000, false);
        MixedDiscount.Status := MixedDiscount.Status::Pending;
        MixedDiscount."Ending date" := Today() - 2;
        MixedDiscount.Modify(true);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::" ", 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = '', 'Total Discount not applied according to scenario.');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreNotEqual(POSSaleLine."Amount Including VAT", 0, 'Total Discount not applied according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ActiveMixDiscountInThePastApplication()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        DiscountAmount: Decimal;
    begin
        // [SCENARIO] Active mix discount to be applied on item but with end date set in the past

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountAmountHeader(MixedDiscount, 2000, false);
        MixedDiscount."Ending date" := Today() - 2;
        MixedDiscount.Modify(true);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::" ", 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = '', 'Total Discount not applied according to scenario.');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreNotEqual(POSSaleLine."Amount Including VAT", 0, 'Total Discount not applied according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ActiveMixDiscountInTheFutureSpecificTimeIntervalApplication()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        MixedDiscTimeInterv: Record "NPR Mixed Disc. Time Interv.";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        DiscountAmount: Decimal;
    begin
        // [SCENARIO] Active mix discount to be applied on item but with start date set in the future with specific time interval

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountAmountHeader(MixedDiscount, 2000, false);
        CreateMixDiscountTimeInterval(MixedDiscount, MixedDiscTimeInterv, Time() + 3600000, Time() + 7200000);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::" ", 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = '', 'Total Discount not applied according to scenario.');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreNotEqual(POSSaleLine."Amount Including VAT", 0, 'Total Discount not applied according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DisabledMixDiscountInTheFutureSpecificTimeIntervalApplication()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        MixedDiscTimeInterv: Record "NPR Mixed Disc. Time Interv.";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        DiscountAmount: Decimal;
    begin
        // [SCENARIO] Pedning mix discount to be applied on item but with start date set in the future with specific time interval

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountAmountHeader(MixedDiscount, 2000, false);
        MixedDiscount.Status := MixedDiscount.Status::Pending;
        CreateMixDiscountTimeInterval(MixedDiscount, MixedDiscTimeInterv, Time() + 3600000, Time() + 7200000);
        MixedDiscount.Modify(true);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::" ", 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = '', 'Total Discount not applied according to scenario.');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreNotEqual(POSSaleLine."Amount Including VAT", 0, 'Total Discount not applied according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ActiveMixDiscountInThePastSpecificTimeIntervalApplication()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        MixedDiscTimeInterv: Record "NPR Mixed Disc. Time Interv.";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        DiscountAmount: Decimal;
    begin
        // [SCENARIO] Active mix discount to be applied on item but with end date set in the past with specific time interval set

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountAmountHeader(MixedDiscount, 2000, false);
        CreateMixDiscountTimeInterval(MixedDiscount, MixedDiscTimeInterv, Time() - 7200000, Time() - 3600000);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::" ", 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = '', 'Total Discount not applied according to scenario.');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreNotEqual(POSSaleLine."Amount Including VAT", 0, 'Total Discount not applied according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DisabledMixDiscountInThePastSpecificTimeIntervalApplication()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        MixedDiscTimeInterv: Record "NPR Mixed Disc. Time Interv.";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        DiscountAmount: Decimal;
    begin
        // [SCENARIO] Pending mix discount to be applied on item but with end date set in the past with specific time interval set

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountAmountHeader(MixedDiscount, 2000, false);
        MixedDiscount.Status := MixedDiscount.Status::Pending;
        CreateMixDiscountTimeInterval(MixedDiscount, MixedDiscTimeInterv, Time() - 7200000, Time() - 3600000);
        MixedDiscount.Modify(true);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::" ", 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = '', 'Total Discount not applied according to scenario.');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreNotEqual(POSSaleLine."Amount Including VAT", 0, 'Total Discount not applied according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ActiveMixDiscountSpecificTimeIntervalApplication()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        MixedDiscTimeInterv: Record "NPR Mixed Disc. Time Interv.";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        DiscountAmount: Decimal;
    begin
        // [SCENARIO] Active mix discount to be applied on item with specific time interval set

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountAmountHeader(MixedDiscount, 2000, false);
        CreateMixDiscountTimeInterval(MixedDiscount, MixedDiscTimeInterv, Time() - 3600000, Time() + 3600000);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = MixedDiscount.Code, 'Mixed Discount not applied to POS Sale Line');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", 0, 'Total Discount not applied according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DisabledMixDiscountSpecificTimeIntervalApplication()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        MixedDiscTimeInterv: Record "NPR Mixed Disc. Time Interv.";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        DiscountAmount: Decimal;
    begin
        // [SCENARIO] Pending mix discount to be applied on item with specific time interval set

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountAmountHeader(MixedDiscount, 2000, false);
        MixedDiscount.Status := MixedDiscount.Status::Pending;
        MixedDiscount.Modify(true);
        CreateMixDiscountTimeInterval(MixedDiscount, MixedDiscTimeInterv, Time() - 3600000, Time() + 3600000);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::" ", 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = '', 'Total Discount not applied according to scenario.');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreNotEqual(POSSaleLine."Amount Including VAT", 0, 'Total Discount not applied according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ActiveMixDiscountInTheFutureSpecificTimeIntervalSpecificDayApplication()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        MixedDiscTimeInterv: Record "NPR Mixed Disc. Time Interv.";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        DiscountAmount: Decimal;
    begin
        // [SCENARIO] Active mix discount to be applied on item in the future with specific time interval set with specific day

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountAmountHeader(MixedDiscount, 2000, false);
        CreateMixDiscountTimeInterval(MixedDiscount, MixedDiscTimeInterv, Time() - 3600000, Time() + 3600000);
        GetDayAndSetToMixedDiscTimeInterval(MixedDiscTimeInterv, DayDirection::Future);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::" ", 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = '', 'Total Discount not applied according to scenario.');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreNotEqual(POSSaleLine."Amount Including VAT", 0, 'Total Discount not applied according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ActiveMixDiscountInTheFutureSpecificTimeIntervalSpecificDayTimeEmptyApplication()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        MixedDiscTimeInterv: Record "NPR Mixed Disc. Time Interv.";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        DiscountAmount: Decimal;
    begin
        // [SCENARIO] Active mix discount to be applied on item in the future with specific time interval set with specific day

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountAmountHeader(MixedDiscount, 2000, false);
        CreateMixDiscountTimeInterval(MixedDiscount, MixedDiscTimeInterv, 0T, 0T);
        GetDayAndSetToMixedDiscTimeInterval(MixedDiscTimeInterv, DayDirection::Future);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::" ", 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = '', 'Total Discount not applied according to scenario.');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreNotEqual(POSSaleLine."Amount Including VAT", 0, 'Total Discount not applied according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DisabledMixDiscountInTheFutureSpecificTimeIntervalSpecificDayApplication()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        MixedDiscTimeInterv: Record "NPR Mixed Disc. Time Interv.";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        DiscountAmount: Decimal;
    begin
        // [SCENARIO] Pending mix discount to be applied on item in the future with specific time interval set with specific day

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountAmountHeader(MixedDiscount, 2000, false);
        MixedDiscount.Status := MixedDiscount.Status::Pending;
        CreateMixDiscountTimeInterval(MixedDiscount, MixedDiscTimeInterv, Time() - 3600000, Time() + 3600000);
        GetDayAndSetToMixedDiscTimeInterval(MixedDiscTimeInterv, DayDirection::Future);
        MixedDiscount.Modify(true);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::" ", 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = '', 'Total Discount not applied according to scenario.');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreNotEqual(POSSaleLine."Amount Including VAT", 0, 'Total Discount not applied according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DisabledMixDiscountInTheFutureSpecificTimeIntervalSpecificDayTimeEmptyApplication()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        MixedDiscTimeInterv: Record "NPR Mixed Disc. Time Interv.";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        DiscountAmount: Decimal;
    begin
        // [SCENARIO] Pending mix discount to be applied on item in the future with specific time interval set with specific day

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountAmountHeader(MixedDiscount, 2000, false);
        MixedDiscount.Status := MixedDiscount.Status::Pending;
        CreateMixDiscountTimeInterval(MixedDiscount, MixedDiscTimeInterv, 0T, 0T);
        GetDayAndSetToMixedDiscTimeInterval(MixedDiscTimeInterv, DayDirection::Future);
        MixedDiscount.Modify(true);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::" ", 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = '', 'Total Discount not applied according to scenario.');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreNotEqual(POSSaleLine."Amount Including VAT", 0, 'Total Discount not applied according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ActiveMixDiscountInThePastSpecificTimeIntervalSpecificDayApplication()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        MixedDiscTimeInterv: Record "NPR Mixed Disc. Time Interv.";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        DiscountAmount: Decimal;
    begin
        // [SCENARIO] Active mix discount to be applied on item in the past with specific time interval set with specific day

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountAmountHeader(MixedDiscount, 2000, false);
        CreateMixDiscountTimeInterval(MixedDiscount, MixedDiscTimeInterv, Time() - 3600000, Time() + 3600000);
        GetDayAndSetToMixedDiscTimeInterval(MixedDiscTimeInterv, DayDirection::Past);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::" ", 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = '', 'Total Discount not applied according to scenario.');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreNotEqual(POSSaleLine."Amount Including VAT", 0, 'Total Discount not applied according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ActiveMixDiscountInThePastSpecificTimeIntervalSpecificDayTimeEmptyApplication()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        MixedDiscTimeInterv: Record "NPR Mixed Disc. Time Interv.";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        DiscountAmount: Decimal;
    begin
        // [SCENARIO] Active mix discount to be applied on item in the past with specific time interval set with specific day

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountAmountHeader(MixedDiscount, 2000, false);
        CreateMixDiscountTimeInterval(MixedDiscount, MixedDiscTimeInterv, 0T, 0T);
        GetDayAndSetToMixedDiscTimeInterval(MixedDiscTimeInterv, DayDirection::Past);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::" ", 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = '', 'Total Discount not applied according to scenario.');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreNotEqual(POSSaleLine."Amount Including VAT", 0, 'Total Discount not applied according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DisabledMixDiscountInThePastSpecificTimeIntervalSpecificDayApplication()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        MixedDiscTimeInterv: Record "NPR Mixed Disc. Time Interv.";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        DiscountAmount: Decimal;
    begin
        // [SCENARIO] Pending mix discount to be applied on item in the past with specific time interval set with specific day

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountAmountHeader(MixedDiscount, 2000, false);
        MixedDiscount.Status := MixedDiscount.Status::Pending;
        CreateMixDiscountTimeInterval(MixedDiscount, MixedDiscTimeInterv, Time() - 3600000, Time() + 3600000);
        GetDayAndSetToMixedDiscTimeInterval(MixedDiscTimeInterv, DayDirection::Past);
        MixedDiscount.Modify(true);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::" ", 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = '', 'Total Discount not applied according to scenario.');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreNotEqual(POSSaleLine."Amount Including VAT", 0, 'Total Discount not applied according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DisabledMixDiscountInThePastSpecificTimeIntervalSpecificDayTimeEmptyApplication()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        MixedDiscTimeInterv: Record "NPR Mixed Disc. Time Interv.";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        DiscountAmount: Decimal;
    begin
        // [SCENARIO] Pending mix discount to be applied on item in the past with specific time interval set with specific day

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountAmountHeader(MixedDiscount, 2000, false);
        MixedDiscount.Status := MixedDiscount.Status::Pending;
        CreateMixDiscountTimeInterval(MixedDiscount, MixedDiscTimeInterv, 0T, 0T);
        GetDayAndSetToMixedDiscTimeInterval(MixedDiscTimeInterv, DayDirection::Past);
        MixedDiscount.Modify(true);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::" ", 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = '', 'Total Discount not applied according to scenario.');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreNotEqual(POSSaleLine."Amount Including VAT", 0, 'Total Discount not applied according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ActiveMixDiscountSpecificTimeIntervalSpecificDayApplication()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        MixedDiscTimeInterv: Record "NPR Mixed Disc. Time Interv.";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        DiscountAmount: Decimal;
    begin
        // [SCENARIO] Active mix discount to be applied on item with specific time interval set with specific day

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountAmountHeader(MixedDiscount, 2000, false);
        CreateMixDiscountTimeInterval(MixedDiscount, MixedDiscTimeInterv, Time() - 3600000, Time() + 3600000);
        GetDayAndSetToMixedDiscTimeInterval(MixedDiscTimeInterv, DayDirection::Today);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = MixedDiscount.Code, 'Mixed Discount not applied to POS Sale Line');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", 0, 'Total Discount not applied according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ActiveMixDiscountSpecificTimeIntervalSpecificDayTimeEmptyApplication()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        MixedDiscTimeInterv: Record "NPR Mixed Disc. Time Interv.";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        DiscountAmount: Decimal;
    begin
        // [SCENARIO] Active mix discount to be applied on item with specific time interval set with specific day

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountAmountHeader(MixedDiscount, 2000, false);
        CreateMixDiscountTimeInterval(MixedDiscount, MixedDiscTimeInterv, 0T, 0T);
        GetDayAndSetToMixedDiscTimeInterval(MixedDiscTimeInterv, DayDirection::Today);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = MixedDiscount.Code, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", 0, 'Total Discount not applied according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DisabledMixDiscountSpecificTimeIntervalSpecificDayApplication()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        MixedDiscTimeInterv: Record "NPR Mixed Disc. Time Interv.";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        DiscountAmount: Decimal;
    begin
        // [SCENARIO] Active mix discount to be applied on item with specific time interval set with specific day

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountAmountHeader(MixedDiscount, 2000, false);
        MixedDiscount.Status := MixedDiscount.Status::Pending;
        CreateMixDiscountTimeInterval(MixedDiscount, MixedDiscTimeInterv, Time() - 3600000, Time() + 3600000);
        GetDayAndSetToMixedDiscTimeInterval(MixedDiscTimeInterv, DayDirection::Today);
        MixedDiscount.Modify(true);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::" ", 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = '', 'Mixed Discount not applied to POS Sale Line');
        Assert.AreNotEqual(POSSaleLine."Amount Including VAT", 0, 'Total Discount not applied according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DisabledMixDiscountSpecificTimeIntervalSpecificDayTimeEmptyApplication()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        MixedDiscTimeInterv: Record "NPR Mixed Disc. Time Interv.";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        DiscountAmount: Decimal;
    begin
        // [SCENARIO] Active mix discount to be applied on item with specific time interval set with specific day

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountAmountHeader(MixedDiscount, 2000, false);
        MixedDiscount.Status := MixedDiscount.Status::Pending;
        CreateMixDiscountTimeInterval(MixedDiscount, MixedDiscTimeInterv, 0T, 0T);
        GetDayAndSetToMixedDiscTimeInterval(MixedDiscTimeInterv, DayDirection::Today);
        MixedDiscount.Modify(true);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::" ", 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = '', 'Mixed Discount not applied to POS Sale Line');
        Assert.AreNotEqual(POSSaleLine."Amount Including VAT", 0, 'Total Discount not applied according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ActiveMixDiscountWithCustomerDiscountGroupApplication()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        MixedDiscTimeInterv: Record "NPR Mixed Disc. Time Interv.";
        Customer: Record Customer;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        CustomerDiscountGroupCode: Code[10];
        Qty: Decimal;
        DiscountAmount: Decimal;
    begin
        // [SCENARIO] Active mix discount with one customer discount group and a customer that has the same discount group

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        CreateCustomer(Customer, false, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount with Customer Discount Group 
        CustomerDiscountGroupCode := CreateDiscountGroup();
        CreateTotalDiscountAmountHeader(MixedDiscount, 2000, false);
        MixedDiscount."Customer Disc. Group Filter" := CustomerDiscountGroupCode;
        MixedDiscount.Modify(true);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);

        // [GIVEN] Customer with same customer group that set on discount
        Customer."Customer Disc. Group" := CustomerDiscountGroupCode;
        Customer.Modify(true);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = MixedDiscount.Code, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", 0, 'Total Discount not applied according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ActiveMixDiscountWithCustomerDiscountGroupButCustomerNotAddedToSaleApplication()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        MixedDiscTimeInterv: Record "NPR Mixed Disc. Time Interv.";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        CustomerDiscountGroupCode: Code[10];
        Qty: Decimal;
        DiscountAmount: Decimal;
    begin
        // [SCENARIO] Active mix discount with one customer discount group and a customer that has the same discount group

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount with Customer Discount Group 
        CustomerDiscountGroupCode := CreateDiscountGroup();
        CreateTotalDiscountAmountHeader(MixedDiscount, 2000, false);
        MixedDiscount."Customer Disc. Group Filter" := CustomerDiscountGroupCode;
        MixedDiscount.Modify(true);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::" ", 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = '', 'Total Discount not applied according to scenario.');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreNotEqual(POSSaleLine."Amount Including VAT", 0, 'Total Discount not applied according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ActiveMixDiscountWithCustomerDiscountGroupAndDifferentCustomerApplication()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        MixedDiscTimeInterv: Record "NPR Mixed Disc. Time Interv.";
        Customer: Record Customer;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        Qty: Decimal;
        DiscountAmount: Decimal;
    begin
        // [SCENARIO] Enabled mix discount with one customer discount group and a customer that doesn't have the same discount group

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        CreateCustomer(Customer, false, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount with Customer Discount Group 
        CreateTotalDiscountAmountHeader(MixedDiscount, 2000, false);
        MixedDiscount."Customer Disc. Group Filter" := CreateDiscountGroup();
        MixedDiscount.Modify(true);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);

        // [GIVEN] Customer with different customer group that set on discount
        Customer."Customer Disc. Group" := CreateDiscountGroup();
        Customer.Modify(true);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::" ", 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = '', 'Total Discount not applied according to scenario.');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreNotEqual(POSSaleLine."Amount Including VAT", 0, 'Total Discount not applied according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ActiveMixDiscountWithCustomerDiscountGroupsApplication()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        MixedDiscTimeInterv: Record "NPR Mixed Disc. Time Interv.";
        Customer: Record Customer;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        CustomerDiscountGroupCode: Code[10];
        Qty: Decimal;
        DiscountAmount: Decimal;
    begin
        // [SCENARIO] Active mix discount with mutliple customer discount groups and a customer that has the same discount group

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        CreateCustomer(Customer, false, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount with Customer Discount Group 
        CustomerDiscountGroupCode := CreateDiscountGroup();
        CreateTotalDiscountAmountHeader(MixedDiscount, 2000, false);
        MixedDiscount."Customer Disc. Group Filter" := CustomerDiscountGroupCode + '|' + CreateDiscountGroup();
        MixedDiscount.Modify(true);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);

        // [GIVEN] Customer with same customer group that set on discount
        Customer."Customer Disc. Group" := CustomerDiscountGroupCode;
        Customer.Modify(true);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = MixedDiscount.Code, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", 0, 'Total Discount not applied according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ActiveMixDiscountWithCustomerDiscountGroupsAndCustomerWithDifferentOneApplication()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        MixedDiscTimeInterv: Record "NPR Mixed Disc. Time Interv.";
        Customer: Record Customer;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        CustomerDiscountGroupCode: Code[10];
        Qty: Decimal;
        DiscountAmount: Decimal;
    begin
        // [SCENARIO] Enabled mix discount with multuiple customer discount groups and a customer that doesn't have the same discount group

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        CreateCustomer(Customer, false, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount with Customer Discount Group 
        CustomerDiscountGroupCode := CreateDiscountGroup();
        CreateTotalDiscountAmountHeader(MixedDiscount, 2000, false);
        MixedDiscount."Customer Disc. Group Filter" := CustomerDiscountGroupCode + '|' + CreateDiscountGroup();
        MixedDiscount.Modify(true);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);

        // [GIVEN] Customer with different customer group that set on discount
        Customer."Customer Disc. Group" := CreateDiscountGroup();
        Customer.Modify(true);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::" ", 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = '', 'Total Discount not applied according to scenario.');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreNotEqual(POSSaleLine."Amount Including VAT", 0, 'Total Discount not applied according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DisabledMixDiscountWithCustomerDiscountGroupApplication()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        MixedDiscTimeInterv: Record "NPR Mixed Disc. Time Interv.";
        Customer: Record Customer;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        CustomerDiscountGroupCode: Code[10];
        Qty: Decimal;
        DiscountAmount: Decimal;
    begin
        // [SCENARIO] Pending mix discount with one customer discount group and a customer that has the same discount group

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        CreateCustomer(Customer, false, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount with Customer Discount Group 
        CustomerDiscountGroupCode := CreateDiscountGroup();
        CreateTotalDiscountAmountHeader(MixedDiscount, 2000, false);
        MixedDiscount."Customer Disc. Group Filter" := CustomerDiscountGroupCode;
        MixedDiscount.Status := MixedDiscount.Status::Pending;
        MixedDiscount.Modify(true);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);

        // [GIVEN] Customer with same customer group that set on discount
        Customer."Customer Disc. Group" := CustomerDiscountGroupCode;
        Customer.Modify(true);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::" ", 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = '', 'Total Discount not applied according to scenario.');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreNotEqual(POSSaleLine."Amount Including VAT", 0, 'Total Discount not applied according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DisabledMixDiscountWithCustomerDiscountGroupButCustomerNotAddedToSaleApplication()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        MixedDiscTimeInterv: Record "NPR Mixed Disc. Time Interv.";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        CustomerDiscountGroupCode: Code[10];
        Qty: Decimal;
        DiscountAmount: Decimal;
    begin
        // [SCENARIO] Pending mix discount with one customer discount group and a customer that has the same discount group

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount with Customer Discount Group 
        CustomerDiscountGroupCode := CreateDiscountGroup();
        CreateTotalDiscountAmountHeader(MixedDiscount, 2000, false);
        MixedDiscount."Customer Disc. Group Filter" := CustomerDiscountGroupCode;
        MixedDiscount.Status := MixedDiscount.Status::Pending;
        MixedDiscount.Modify(true);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::" ", 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = '', 'Total Discount not applied according to scenario.');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreNotEqual(POSSaleLine."Amount Including VAT", 0, 'Total Discount not applied according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DisabledMixDiscountWithCustomerDiscountGroupAndCustomerWithDifferentGroupApplication()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        MixedDiscTimeInterv: Record "NPR Mixed Disc. Time Interv.";
        Customer: Record Customer;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        CustomerDiscountGroupCode: Code[10];
        Qty: Decimal;
        DiscountAmount: Decimal;
    begin
        // [SCENARIO] Pending mix discount with one customer discount group and a customer that has different discount group

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        CreateCustomer(Customer, false, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount with Customer Discount Group 
        CustomerDiscountGroupCode := CreateDiscountGroup();
        CreateTotalDiscountAmountHeader(MixedDiscount, 2000, false);
        MixedDiscount."Customer Disc. Group Filter" := CustomerDiscountGroupCode;
        MixedDiscount.Status := MixedDiscount.Status::Pending;
        MixedDiscount.Modify(true);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);

        // [GIVEN] Customer with different customer group that set on discount
        Customer."Customer Disc. Group" := CreateDiscountGroup();
        Customer.Modify(true);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::" ", 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = '', 'Total Discount not applied according to scenario.');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreNotEqual(POSSaleLine."Amount Including VAT", 0, 'Total Discount not applied according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DisabledMixDiscountWithCustomerDiscountGroupsApplication()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        MixedDiscTimeInterv: Record "NPR Mixed Disc. Time Interv.";
        Customer: Record Customer;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        CustomeDiscountGroup: Code[10];
        Qty: Decimal;
        DiscountAmount: Decimal;
    begin
        // [SCENARIO] Pending mix discount with mutliple customer discount groups and a customer that has the same discount group

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        CreateCustomer(Customer, false, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount with Customer Discount Group 
        CustomeDiscountGroup := CreateDiscountGroup();
        CreateTotalDiscountAmountHeader(MixedDiscount, 2000, false);
        MixedDiscount.Status := MixedDiscount.Status::Pending;
        MixedDiscount."Customer Disc. Group Filter" := CustomeDiscountGroup + '|' + CreateDiscountGroup();
        MixedDiscount.Modify(true);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);

        // [GIVEN] Customer with same customer group that set on discount
        Customer."Customer Disc. Group" := CustomeDiscountGroup;
        Customer.Modify(true);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::" ", 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = '', 'Total Discount not applied according to scenario.');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreNotEqual(POSSaleLine."Amount Including VAT", 0, 'Total Discount not applied according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DisabledMixDiscountWithCustomerDiscountGroupsAndCustomerWithDifferentGroupApplication()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        MixedDiscTimeInterv: Record "NPR Mixed Disc. Time Interv.";
        Customer: Record Customer;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        Qty: Decimal;
        DiscountAmount: Decimal;
    begin
        // [SCENARIO] Pending mix discount with mutliple customer discount groups and a customer that has different discount group

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        CreateCustomer(Customer, false, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount with Customer Discount Group 
        CreateTotalDiscountAmountHeader(MixedDiscount, 2000, false);
        MixedDiscount.Status := MixedDiscount.Status::Pending;
        MixedDiscount."Customer Disc. Group Filter" := CreateDiscountGroup() + '|' + CreateDiscountGroup();
        MixedDiscount.Modify(true);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);

        // [GIVEN] Customer with same customer group that set on discount
        Customer."Customer Disc. Group" := CreateDiscountGroup();
        Customer.Modify(true);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::" ", 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = '', 'Total Discount not applied according to scenario.');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreNotEqual(POSSaleLine."Amount Including VAT", 0, 'Total Discount not applied according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyMixDiscountTotalAmountPerMinQtyUOMSameOnItemAndDiscount()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        UnitOfMeasure: Record "Unit of Measure";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        TotalAmount: Decimal;
        Qty: Decimal;
        DiscountCode: Code[20];
    begin
        // [SCENARIO] Apply mix discount total amount per min. qty. with same UOM as item on POS Sale

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Item with unit price and UOM
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        LibraryInventory.CreateItemUnitOfMeasure(ItemUnitOfMeasure, Item."No.", UnitOfMeasure.Code, 1);
        Item."Base Unit of Measure" := UnitOfMeasure.Code;
        Item."Unit Price" := 2000;
        Item.Modify();

        // [GIVEN] Discount with item and UOM
        TotalAmount := CreateTotalDiscountAmountTotalAmtPerMinQtyWithUOM(Item, 500, false, UnitOfMeasure.Code, DiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount is applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", TotalAmount, 'Discount Amount not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyMixDiscountTotalAmountPerMinQtyUOMDifferentOnItemAndDiscount()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        UnitOfMeasure: Record "Unit of Measure";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        SecondUnitOfMeasure: Record "Unit of Measure";
        SecondItemUnitOfMeasure: Record "Item Unit of Measure";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        DiscountCode: Code[20];
    begin
        // [SCENARIO] Apply mix discount total amount per min. qty. with different UOM than on Item on POS Sale

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Item with unit price and UOM
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        LibraryInventory.CreateUnitOfMeasureCode(SecondUnitOfMeasure);
        LibraryInventory.CreateItemUnitOfMeasure(ItemUnitOfMeasure, Item."No.", UnitOfMeasure.Code, 1);
        LibraryInventory.CreateItemUnitOfMeasure(SecondItemUnitOfMeasure, Item."No.", SecondUnitOfMeasure.Code, 1);
        Item."Base Unit of Measure" := UnitOfMeasure.Code;
        Item."Unit Price" := 2000;
        Item.Modify();

        // [GIVEN] Discount with item and UOM
        CreateTotalDiscountAmountTotalAmtPerMinQtyWithUOM(Item, 500, false, SecondUnitOfMeasure.Code, DiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount is not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsFalse(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount applied to POS Sale Line');
        Assert.AreEqual(POSSaleLine."Discount Amount", 0, 'Discount Amount not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyMixDiscountTotalAmountPerMinQtyUOMDiscountWithItemATwoItemsOnPOSSecondNoDiscount()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        SecondPOSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SecondItem: Record Item;
        UnitOfMeasure: Record "Unit of Measure";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        TotalAmount: Decimal;
        Qty: Decimal;
        DiscountCode: Code[20];
    begin
        // [SCENARIO] Apply mix discount total amount per min. qty. for item A with X UOM, 2 different items on POS Sale with same UOM

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Items with unit price and UOM
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryInventory.CreateItemUnitOfMeasure(ItemUnitOfMeasure, Item."No.", UnitOfMeasure.Code, 1);
        Item."Base Unit of Measure" := UnitOfMeasure.Code;
        Item."Unit Price" := 2000;
        Item.Modify();
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(SecondItem, POSUnit, POSStore);
        SecondItem."Base Unit of Measure" := UnitOfMeasure.Code;
        SecondItem."Unit Price" := 2000;
        SecondItem.Modify();

        // [GIVEN] Discount with item and UOM
        TotalAmount := CreateTotalDiscountAmountTotalAmtPerMinQtyWithUOM(Item, 500, false, UnitOfMeasure.Code, DiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Items to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);
        LibraryPOSMock.CreateItemLine(POSSession, SecondItem."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetLast();
        POSSaleLineUnit.GetCurrentSaleLine(SecondPOSSaleLine);

        // [THEN] Verify Discount is applied correctly
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", TotalAmount, 'Discount Amount not calculated according to scenario.');
        Assert.IsTrue(SecondPOSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsFalse(SecondPOSSaleLine."Discount Type" = SecondPOSSaleLine."Discount Type"::Mix, 'Mixed Discount applied to POS Sale Line');
        Assert.IsFalse(SecondPOSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsFalse(SecondPOSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount applied to POS Sale Line');
        Assert.AreEqual(SecondPOSSaleLine."Discount Amount", 0, 'Discount Amount not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyMixDiscountTotalAmountPerMinQtyUOMTwoItemsOnPOSBothOnDiscount()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        SecondPOSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SecondItem: Record Item;
        UnitOfMeasure: Record "Unit of Measure";
        SecondUnitOfMeasure: Record "Unit of Measure";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        SecondItemUnitOfMeasure: Record "Item Unit of Measure";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        TotalAmount: Decimal;
        Qty: Decimal;
        DiscountCode: Code[20];
    begin
        // [SCENARIO] Apply mix discount total amount per min. qty. for Item A with X UOM and Item B with Y UOM

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Items with unit price and UOM
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        LibraryInventory.CreateItemUnitOfMeasure(ItemUnitOfMeasure, Item."No.", UnitOfMeasure.Code, 1);
        Item."Base Unit of Measure" := UnitOfMeasure.Code;
        Item."Unit Price" := 1000;
        Item.Modify();
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(SecondItem, POSUnit, POSStore);
        LibraryInventory.CreateUnitOfMeasureCode(SecondUnitOfMeasure);
        LibraryInventory.CreateItemUnitOfMeasure(SecondItemUnitOfMeasure, SecondItem."No.", SecondUnitOfMeasure.Code, 1);
        SecondItem."Base Unit of Measure" := SecondUnitOfMeasure.Code;
        SecondItem."Unit Price" := 2000;
        SecondItem.Modify();

        // [GIVEN] Discount with item and UOM
        TotalAmount := CreateTotalDiscountAmountTotalAmtPerMinQtyWithUOMTwoItems(Item, SecondItem, 500, false, UnitOfMeasure.Code, SecondUnitOfMeasure.Code, DiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Items to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);
        LibraryPOSMock.CreateItemLine(POSSession, SecondItem."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetLast();
        POSSaleLineUnit.GetCurrentSaleLine(SecondPOSSaleLine);

        // [THEN] Verify Discount is applied correctly
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(SecondPOSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(SecondPOSSaleLine."Discount Type" = SecondPOSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(SecondPOSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(SecondPOSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.AreNearlyEqual(Round(POSSaleLine."Amount Including VAT" + SecondPOSSaleLine."Amount Including VAT"), Round(TotalAmount * (POSSaleLine.Quantity + SecondPOSSaleLine.Quantity)), 0.1, 'Discount Amount not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyMixDiscountTotalAmountPerMinQtyUOMTwoDiscountsTwoItemsDifferentUOMsSameAsOnDiscounts()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        SecondPOSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SecondItem: Record Item;
        UnitOfMeasure: Record "Unit of Measure";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        SecondUnitOfMeasure: Record "Unit of Measure";
        SecondItemUnitOfMeasure: Record "Item Unit of Measure";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        FirstTotalAmount: Decimal;
        SecondTotalAmount: Decimal;
        Qty: Decimal;
        FirstDiscountCode: Code[20];
        SecondDiscountCode: Code[20];
    begin
        // [SCENARIO] Apply 2 total amount per min. qty. mix discounts applied on 2 items

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Items with unit price and UOM
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        LibraryInventory.CreateItemUnitOfMeasure(ItemUnitOfMeasure, Item."No.", UnitOfMeasure.Code, 1);
        Item."Base Unit of Measure" := UnitOfMeasure.Code;
        Item."Unit Price" := 2000;
        Item.Modify();
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(SecondItem, POSUnit, POSStore);
        LibraryInventory.CreateUnitOfMeasureCode(SecondUnitOfMeasure);
        LibraryInventory.CreateItemUnitOfMeasure(SecondItemUnitOfMeasure, SecondItem."No.", SecondUnitOfMeasure.Code, 1);
        SecondItem."Base Unit of Measure" := SecondUnitOfMeasure.Code;
        SecondItem."Unit Price" := 2000;
        SecondItem.Modify();

        // [GIVEN] Discount with item and UOM
        FirstTotalAmount := CreateTotalDiscountAmountTotalAmtPerMinQtyWithUOM(Item, 500, false, UnitOfMeasure.Code, FirstDiscountCode);
        SecondTotalAmount := CreateTotalDiscountAmountTotalAmtPerMinQtyWithUOM(SecondItem, 1000, false, SecondUnitOfMeasure.Code, SecondDiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Items to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);
        LibraryPOSMock.CreateItemLine(POSSession, SecondItem."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetLast();
        POSSaleLineUnit.GetCurrentSaleLine(SecondPOSSaleLine);

        // [THEN] Verify Discount is applied correctly
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = FirstDiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", FirstTotalAmount, 'Discount Amount not calculated according to scenario.');
        Assert.IsTrue(SecondPOSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(SecondPOSSaleLine."Discount Type" = SecondPOSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(SecondPOSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(SecondPOSSaleLine."Discount Code" = SecondDiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.AreEqual(SecondPOSSaleLine."Amount Including VAT", SecondTotalAmount, 'Discount Amount not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyMixDiscountTotalDiscountAmountPerMinQtyUOMSameOnItemAndDiscount()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        UnitOfMeasure: Record "Unit of Measure";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        GeneralLedgerSetup: Record "General Ledger Setup";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        TotalDiscountAmount: Decimal;
        TotalDiscountAmountForCheck: Decimal;
        Qty: Decimal;
        DiscountCode: Code[20];
        UOM: Code[10];
    begin
        // [SCENARIO] Apply mix discount total discount amount per min. qty. with same UOM as item on POS Sale

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Item with unit price and UOM
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        LibraryInventory.CreateItemUnitOfMeasure(ItemUnitOfMeasure, Item."No.", UnitOfMeasure.Code, 1);
        Item."Base Unit of Measure" := UnitOfMeasure.Code;
        Item."Unit Price" := 2000;
        Item.Modify();

        // [GIVEN] Discount with item and UOM
        TotalDiscountAmount := CreateTotalDiscountAmountTotalDiscountAmtPerMinQtyWithUOM(Item, 500, false, UnitOfMeasure.Code, DiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        TotalDiscountAmountForCheck := TotalDiscountAmount;
        if not POSSaleLine."Price Includes VAT" then
            TotalDiscountAmountForCheck := POSSaleTaxCalc.CalcAmountWithoutVAT(TotalDiscountAmount, POSSaleLine."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Verify Discount is applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.AreEqual(POSSaleLine."Discount Amount", TotalDiscountAmountForCheck, 'Discount Amount not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyMixDiscountTotalDiscountAmountPerMinQtyUOMDifferentOnItemAndDiscount()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        UnitOfMeasure: Record "Unit of Measure";
        SecondUnitOfMeasure: Record "Unit of Measure";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        SecondItemUnitOfMeasure: Record "Item Unit of Measure";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        DiscountCode: Code[20];
    begin
        // [SCENARIO] Apply mix discount total discount amount per min. qty. with different UOM than Item on POS Sale

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Item with unit price and UOM
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        LibraryInventory.CreateUnitOfMeasureCode(SecondUnitOfMeasure);
        LibraryInventory.CreateItemUnitOfMeasure(ItemUnitOfMeasure, Item."No.", UnitOfMeasure.Code, 1);
        LibraryInventory.CreateItemUnitOfMeasure(SecondItemUnitOfMeasure, Item."No.", SecondUnitOfMeasure.Code, 1);
        Item."Base Unit of Measure" := UnitOfMeasure.Code;
        Item."Unit Price" := 2000;
        Item.Modify();

        // [GIVEN] Discount with item and UOM
        CreateTotalDiscountAmountTotalDiscountAmtPerMinQtyWithUOM(Item, 500, false, SecondUnitOfMeasure.Code, DiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount is not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsFalse(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount applied to POS Sale Line');
        Assert.AreEqual(POSSaleLine."Discount Amount", 0, 'Discount Amount not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyMixDiscountTotalDiscountAmountPerMinQtyUOMDiscountWithItemATwoItemsOnPOSSecondNoDiscount()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        SecondPOSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SecondItem: Record Item;
        UnitOfMeasure: Record "Unit of Measure";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        GeneralLedgerSetup: Record "General Ledger Setup";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        TotalDiscountAmount: Decimal;
        TotalDiscountAmountForCheck: Decimal;
        Qty: Decimal;
        DiscountCode: Code[20];
    begin
        // [SCENARIO] Apply mix discount total discount amount per min. qty. for item A X with UOM, 2 different items on POS Sale with same UOM

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Items with unit price and UOM
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        LibraryInventory.CreateItemUnitOfMeasure(ItemUnitOfMeasure, Item."No.", UnitOfMeasure.Code, 1);
        Item."Unit Price" := 2000;
        Item."Base Unit of Measure" := UnitOfMeasure.Code;
        Item.Modify();
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(SecondItem, POSUnit, POSStore);
        SecondItem."Unit Price" := 2000;
        SecondItem."Base Unit of Measure" := UnitOfMeasure.Code;
        SecondItem.Modify();

        // [GIVEN] Discount with item and UOM
        TotalDiscountAmount := CreateTotalDiscountAmountTotalDiscountAmtPerMinQtyWithUOM(Item, 500, false, UnitOfMeasure.Code, DiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Items to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);
        LibraryPOSMock.CreateItemLine(POSSession, SecondItem."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetLast();
        POSSaleLineUnit.GetCurrentSaleLine(SecondPOSSaleLine);
        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        TotalDiscountAmountForCheck := TotalDiscountAmount;
        if not POSSaleLine."Price Includes VAT" then
            TotalDiscountAmountForCheck := POSSaleTaxCalc.CalcAmountWithoutVAT(TotalDiscountAmount, POSSaleLine."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Verify Discount is applied correctly
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.AreEqual(POSSaleLine."Discount Amount", TotalDiscountAmountForCheck, 'Discount Amount not calculated according to scenario.');
        Assert.IsTrue(SecondPOSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsFalse(SecondPOSSaleLine."Discount Type" = SecondPOSSaleLine."Discount Type"::Mix, 'Mixed Discount applied to POS Sale Line');
        Assert.IsFalse(SecondPOSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsFalse(SecondPOSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount applied to POS Sale Line');
        Assert.AreEqual(SecondPOSSaleLine."Discount Amount", 0, 'Discount Amount not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyMixDiscountTotalDiscountAmountPerMinQtyUOMTwoItemsOnPOSBothOnDiscount()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        SecondPOSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SecondItem: Record Item;
        UnitOfMeasure: Record "Unit of Measure";
        SecondUnitOfMeasure: Record "Unit of Measure";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        SecondItemUnitOfMeasure: Record "Item Unit of Measure";
        GeneralLedgerSetup: Record "General Ledger Setup";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        TotalDiscountAmount: Decimal;
        TotalDiscountAmountForCheck: Decimal;
        Qty: Decimal;
        DiscountCode: Code[20];
    begin
        // [SCENARIO] Apply mix discount total discount amount per min. qty. for Item A with X UOM and Item B with Y UOM

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Items with unit price and UOM
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        LibraryInventory.CreateItemUnitOfMeasure(ItemUnitOfMeasure, Item."No.", UnitOfMeasure.Code, 1);
        Item."Unit Price" := 1000;
        Item."Base Unit of Measure" := UnitOfMeasure.Code;
        Item.Modify();
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(SecondItem, POSUnit, POSStore);
        LibraryInventory.CreateUnitOfMeasureCode(SecondUnitOfMeasure);
        LibraryInventory.CreateItemUnitOfMeasure(SecondItemUnitOfMeasure, SecondItem."No.", SecondUnitOfMeasure.Code, 1);
        SecondItem."Unit Price" := 2000;
        SecondItem."Base Unit of Measure" := SecondUnitOfMeasure.Code;
        SecondItem.Modify();

        // [GIVEN] Discount with item and UOM
        TotalDiscountAmount := CreateTotalDiscountAmountTotalDiscountAmtPerMinQtyWithUOMTwoItems(Item, SecondItem, 500, false, UnitOfMeasure.Code, SecondUnitOfMeasure.Code, DiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Items to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);
        LibraryPOSMock.CreateItemLine(POSSession, SecondItem."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetLast();
        POSSaleLineUnit.GetCurrentSaleLine(SecondPOSSaleLine);
        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        TotalDiscountAmountForCheck := TotalDiscountAmount;
        if not POSSaleLine."Price Includes VAT" then
            TotalDiscountAmountForCheck := POSSaleTaxCalc.CalcAmountWithoutVAT(TotalDiscountAmount, POSSaleLine."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Verify Discount is applied correctly
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(SecondPOSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(SecondPOSSaleLine."Discount Type" = SecondPOSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(SecondPOSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(SecondPOSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.AreEqual(Round(POSSaleLine."Discount Amount" + SecondPOSSaleLine."Discount Amount"), TotalDiscountAmountForCheck * (POSSaleLine.Quantity + SecondPOSSaleLine.Quantity), 'Discount Amount not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyMixDiscountTotalDiscountAmountPerMinQtyUOMTwoDiscountsTwoItemsDifferentUOMsSameAsOnDiscounts()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        SecondPOSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SecondItem: Record Item;
        UnitOfMeasure: Record "Unit of Measure";
        SecondUnitOfMeasure: Record "Unit of Measure";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        SecondItemUnitOfMeasure: Record "Item Unit of Measure";
        GeneralLedgerSetup: Record "General Ledger Setup";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        FirstTotalDiscountAmount: Decimal;
        SecondTotalDiscountAmount: Decimal;
        FirstTotalDiscountAmountForCheck: Decimal;
        SecondTotalDiscountAmountForCheck: Decimal;
        Qty: Decimal;
        FirstDiscountCode: Code[20];
        SecondDiscountCode: Code[20];
    begin
        // [SCENARIO] Apply 2 mix discounts total discount amount per min. qty, applied on 2 items

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Items with unit price and UOM
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        LibraryInventory.CreateItemUnitOfMeasure(ItemUnitOfMeasure, Item."No.", UnitOfMeasure.Code, 1);
        Item."Unit Price" := 2000;
        Item."Base Unit of Measure" := UnitOfMeasure.Code;
        Item.Modify();
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(SecondItem, POSUnit, POSStore);
        LibraryInventory.CreateUnitOfMeasureCode(SecondUnitOfMeasure);
        LibraryInventory.CreateItemUnitOfMeasure(SecondItemUnitOfMeasure, SecondItem."No.", SecondUnitOfMeasure.Code, 1);
        SecondItem."Unit Price" := 2000;
        SecondItem."Base Unit of Measure" := SecondUnitOfMeasure.Code;
        SecondItem.Modify();

        // [GIVEN] Discounts with items and UOMs
        FirstTotalDiscountAmount := CreateTotalDiscountAmountTotalDiscountAmtPerMinQtyWithUOM(Item, 500, false, UnitOfMeasure.Code, FirstDiscountCode);
        SecondTotalDiscountAmount := CreateTotalDiscountAmountTotalDiscountAmtPerMinQtyWithUOM(SecondItem, 1000, false, SecondUnitOfMeasure.Code, SecondDiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Items to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);
        LibraryPOSMock.CreateItemLine(POSSession, SecondItem."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetLast();
        POSSaleLineUnit.GetCurrentSaleLine(SecondPOSSaleLine);
        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        FirstTotalDiscountAmountForCheck := FirstTotalDiscountAmount;
        SecondTotalDiscountAmountForCheck := SecondTotalDiscountAmount;
        if not POSSaleLine."Price Includes VAT" then
            FirstTotalDiscountAmountForCheck := POSSaleTaxCalc.CalcAmountWithoutVAT(FirstTotalDiscountAmount, POSSaleLine."VAT %", GeneralLedgerSetup."Amount Rounding Precision");
        if not SecondPOSSaleLine."Price Includes VAT" then
            SecondTotalDiscountAmountForCheck := POSSaleTaxCalc.CalcAmountWithoutVAT(SecondTotalDiscountAmount, SecondPOSSaleLine."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Verify Discount is applied correctly
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = FirstDiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.AreEqual(POSSaleLine."Discount Amount", FirstTotalDiscountAmountForCheck, 'Discount Amount not calculated according to scenario.');
        Assert.IsTrue(SecondPOSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(SecondPOSSaleLine."Discount Type" = SecondPOSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(SecondPOSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(SecondPOSSaleLine."Discount Code" = SecondDiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.AreEqual(SecondPOSSaleLine."Discount Amount", SecondTotalDiscountAmountForCheck, 'Discount Amount not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyMixDiscountTotalDiscountPercentUOMSameOnItemAndDiscount()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        UnitOfMeasure: Record "Unit of Measure";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        DiscountPct: Decimal;
        Qty: Decimal;
        DiscountCode: Code[20];
    begin
        // [SCENARIO] Apply mix discount total discount % with same UOM as item on POS Sale

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Item with unit price and UOM
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        LibraryInventory.CreateItemUnitOfMeasure(ItemUnitOfMeasure, Item."No.", UnitOfMeasure.Code, 1);
        Item."Unit Price" := 2000;
        Item."Base Unit of Measure" := UnitOfMeasure.Code;
        Item.Modify();

        // [GIVEN] Discount with item and UOM
        DiscountPct := CreateTotalDiscountPctWithUOM(Item, 50, false, UnitOfMeasure.Code, DiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount is applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.AreEqual(POSSaleLine."Discount %", DiscountPct, 'Discount % not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyMixDiscountTotalDiscountPercentUOMDifferentOnItemAndDiscount()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        UnitOfMeasure: Record "Unit of Measure";
        SecondUnitOfMeasure: Record "Unit of Measure";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        SecondItemUnitOfMeasure: Record "Item Unit of Measure";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        DiscountCode: Code[20];
        UOM: Code[10];
        SecondUOM: Code[10];
    begin
        // [SCENARIO] Apply mix discount total discount % with different UOM than on Item on POS Sale

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Item with unit price and UOM
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        LibraryInventory.CreateItemUnitOfMeasure(ItemUnitOfMeasure, Item."No.", UnitOfMeasure.Code, 1);
        LibraryInventory.CreateUnitOfMeasureCode(SecondUnitOfMeasure);
        LibraryInventory.CreateItemUnitOfMeasure(SecondItemUnitOfMeasure, Item."No.", SecondUnitOfMeasure.Code, 1);
        Item."Unit Price" := 2000;
        Item."Base Unit of Measure" := UnitOfMeasure.Code;
        Item.Modify();

        // [GIVEN] Discount with item and UOM
        CreateTotalDiscountPctWithUOM(Item, 50, false, SecondUnitOfMeasure.Code, DiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount is not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsFalse(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount applied to POS Sale Line');
        Assert.AreEqual(POSSaleLine."Discount %", 0, 'Discount % not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyMixDiscountTotalDiscountPercentUOMDiscountWithItemATwoItemsOnPOSSecondNoDiscount()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        SecondPOSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SecondItem: Record Item;
        UnitOfMeasure: Record "Unit of Measure";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        DiscountPct: Decimal;
        Qty: Decimal;
        DiscountCode: Code[20];
    begin
        // [SCENARIO] Apply mix discount total discount % for item A with X UOM, 2 different items on POS Sale with same UOM

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Items with unit price and UOM
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        LibraryInventory.CreateItemUnitOfMeasure(ItemUnitOfMeasure, Item."No.", UnitOfMeasure.Code, 1);
        Item."Unit Price" := 2000;
        Item."Base Unit of Measure" := UnitOfMeasure.Code;
        Item.Modify();
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(SecondItem, POSUnit, POSStore);
        SecondItem."Unit Price" := 2000;
        SecondItem."Base Unit of Measure" := UnitOfMeasure.Code;
        SecondItem.Modify();

        // [GIVEN] Discount with item and UOM
        DiscountPct := CreateTotalDiscountPctWithUOM(Item, 50, false, UnitOfMeasure.Code, DiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Items to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);
        LibraryPOSMock.CreateItemLine(POSSession, SecondItem."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetLast();
        POSSaleLineUnit.GetCurrentSaleLine(SecondPOSSaleLine);

        // [THEN] Verify Discount is applied correctly
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.AreEqual(POSSaleLine."Discount %", DiscountPct, 'Discount % not calculated according to scenario.');
        Assert.IsTrue(SecondPOSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsFalse(SecondPOSSaleLine."Discount Type" = SecondPOSSaleLine."Discount Type"::Mix, 'Mixed Discount applied to POS Sale Line');
        Assert.IsFalse(SecondPOSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsFalse(SecondPOSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount applied to POS Sale Line');
        Assert.AreEqual(SecondPOSSaleLine."Discount %", 0, 'Discount % not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyMixDiscountTotalDiscountPercentUOMTwoItemsOnPOSBothOnDiscount()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        SecondPOSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SecondItem: Record Item;
        UnitOfMeasure: Record "Unit of Measure";
        SecondUnitOfMeasure: Record "Unit of Measure";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        SecondItemUnitOfMeasure: Record "Item Unit of Measure";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        DiscountPct: Decimal;
        Qty: Decimal;
        DiscountCode: Code[20];
    begin
        // [SCENARIO] Apply mix discount total discount % for Item A with X UOM and Item B with Y UOM

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Items with unit price and UOMs
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        LibraryInventory.CreateItemUnitOfMeasure(ItemUnitOfMeasure, Item."No.", UnitOfMeasure.Code, 1);
        Item."Unit Price" := 1000;
        Item."Base Unit of Measure" := UnitOfMeasure.Code;
        Item.Modify();
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(SecondItem, POSUnit, POSStore);
        LibraryInventory.CreateUnitOfMeasureCode(SecondUnitOfMeasure);
        LibraryInventory.CreateItemUnitOfMeasure(SecondItemUnitOfMeasure, SecondItem."No.", SecondUnitOfMeasure.Code, 1);
        SecondItem."Unit Price" := 2000;
        SecondItem."Base Unit of Measure" := SecondUnitOfMeasure.Code;
        SecondItem.Modify();

        // [GIVEN] Discount with item and UOM
        DiscountPct := CreateTotalDiscountPctWithUOMTwoItems(Item, SecondItem, 50, false, UnitOfMeasure.Code, SecondUnitOfMeasure.Code, DiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Items to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);
        LibraryPOSMock.CreateItemLine(POSSession, SecondItem."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetLast();
        POSSaleLineUnit.GetCurrentSaleLine(SecondPOSSaleLine);

        // [THEN] Verify Discount is applied correctly
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(SecondPOSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(SecondPOSSaleLine."Discount Type" = SecondPOSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(SecondPOSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(SecondPOSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.AreEqual(POSSaleLine."Discount %", DiscountPct, 'Discount % not calculated according to scenario.');
        Assert.AreEqual(SecondPOSSaleLine."Discount %", DiscountPct, 'Discount % not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyMixDiscountTotalDiscountPercentUOMTwoDiscountsTwoItemsDifferentUOMsSameAsOnDiscounts()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        SecondPOSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SecondItem: Record Item;
        UnitOfMeasure: Record "Unit of Measure";
        SecondUnitOfMeasure: Record "Unit of Measure";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        SecondItemUnitOfMeasure: Record "Item Unit of Measure";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        FirstDiscountPct: Decimal;
        SecondDiscountPct: Decimal;
        Qty: Decimal;
        FirstDiscountCode: Code[20];
        SecondDiscountCode: Code[20];
    begin
        // [SCENARIO] Apply 2 total discount % mix discounts which are applied on 2 items on POS

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Items with unit price and UOMs
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        LibraryInventory.CreateItemUnitOfMeasure(ItemUnitOfMeasure, Item."No.", UnitOfMeasure.Code, 1);
        Item."Unit Price" := 2000;
        Item."Base Unit of Measure" := UnitOfMeasure.Code;
        Item.Modify();
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(SecondItem, POSUnit, POSStore);
        LibraryInventory.CreateUnitOfMeasureCode(SecondUnitOfMeasure);
        LibraryInventory.CreateItemUnitOfMeasure(SecondItemUnitOfMeasure, SecondItem."No.", SecondUnitOfMeasure.Code, 1);
        SecondItem."Unit Price" := 2000;
        SecondItem."Base Unit of Measure" := SecondUnitOfMeasure.Code;
        SecondItem.Modify();

        // [GIVEN] Discounts with items and UOMs
        FirstDiscountPct := CreateTotalDiscountPctWithUOM(Item, 50, false, UnitOfMeasure.Code, FirstDiscountCode);
        SecondDiscountPct := CreateTotalDiscountPctWithUOM(SecondItem, 60, false, SecondUnitOfMeasure.Code, SecondDiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Items to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);
        LibraryPOSMock.CreateItemLine(POSSession, SecondItem."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetLast();
        POSSaleLineUnit.GetCurrentSaleLine(SecondPOSSaleLine);

        // [THEN] Verify Discount is applied correctly
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = FirstDiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.AreEqual(POSSaleLine."Discount %", FirstDiscountPct, 'Discount % not calculated according to scenario.');
        Assert.IsTrue(SecondPOSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(SecondPOSSaleLine."Discount Type" = SecondPOSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(SecondPOSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(SecondPOSSaleLine."Discount Code" = SecondDiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.AreEqual(SecondPOSSaleLine."Discount %", SecondDiscountPct, 'Discount % not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyMixDiscountLotTotalAmountPerMinQtyOneItemOneQty()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        TotalAmount: Decimal;
        Qty: Decimal;
        DiscountCode: Code[20];
    begin
        // [SCENARIO] Mixed Discount applied Total Amount per Min. Qty. with Lot enabled

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Item with unit price        
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Item."Unit Price" := 2000;
        Item.Modify();

        // [GIVEN] Discount
        TotalAmount := CreateTotalDiscountAmountTotalAmtPerMinQtyLotEnabled(Item, 500, false, 1, DiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount is applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", TotalAmount, 'Discount Amount not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyMixDiscountLotTotalAmountPerMinQtyTwoItemsOneQty()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSaleLineSecond: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SecondItem: Record Item;
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        TotalAmount: Decimal;
        Qty: Decimal;
        DiscountCode: Code[20];
    begin
        // [SCENARIO] Mixed Discount applied Total Amount per Min. Qty. with Lot enabled 2 items with 1 quantity

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Items with unit price        
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Item."Unit Price" := 3000;
        Item.Modify();
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(SecondItem, POSUnit, POSStore);
        SecondItem."Unit Price" := 4000;
        SecondItem.Modify();

        // [GIVEN] Discount with item quantity
        TotalAmount := CreateTotalDiscountAmountTotalAmtPerMinQtyLotEnabledTwoItems(Item, SecondItem, 500, false, 1, 1, DiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Items to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsFalse(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount not applied to POS Sale Line');
        LibraryPOSMock.CreateItemLine(POSSession, SecondItem."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetLast();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLineSecond);

        // [THEN] Verify Discount is applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLineSecond."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLineSecond."Discount Type" = POSSaleLineSecond."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLineSecond."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLineSecond."Discount Code" = DiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.AreEqual(POSSaleLine."Amount Including VAT" + POSSaleLineSecond."Amount Including VAT", TotalAmount, 'Discount Amount not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyMixDiscountLotTotalAmountPerMinQtyTwoItemsTwoQty()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSaleLineSecond: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SecondItem: Record Item;
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        TotalAmount: Decimal;
        Qty: Decimal;
        DiscountCode: Code[20];
    begin
        // [SCENARIO] Mixed Discount applied Total Amount per Min. Qty. with Lot enabled 2 items with 2 quantity

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Items with unit price        
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Item."Unit Price" := 3000;
        Item.Modify();
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(SecondItem, POSUnit, POSStore);
        SecondItem."Unit Price" := 4000;
        SecondItem.Modify();

        // [GIVEN] Discount with item quantity
        TotalAmount := CreateTotalDiscountAmountTotalAmtPerMinQtyLotEnabledTwoItems(Item, SecondItem, 500, false, 2, 2, DiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Items to active sale
        Qty := 2;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsFalse(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount not applied to POS Sale Line');
        LibraryPOSMock.CreateItemLine(POSSession, SecondItem."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetLast();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLineSecond);

        // [THEN] Verify Discount is applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLineSecond."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLineSecond."Discount Type" = POSSaleLineSecond."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLineSecond."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLineSecond."Discount Code" = DiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.AreEqual(POSSaleLine."Amount Including VAT" + POSSaleLineSecond."Amount Including VAT", TotalAmount, 'Discount Amount not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyTwoMixDiscountsLotTotalAmountPerMinQtyFirstDiscountSingleItemSecondDiscountBothItems()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSaleLineSecond: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SecondItem: Record Item;
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        FirstDiscountTotalAmount: Decimal;
        SecondDiscountTotalAmount: Decimal;
        Qty: Decimal;
        FirstDiscountCode: Code[20];
        SecondDiscountCode: Code[20];
    begin
        // [SCENARIO] 2 Mix discounts set as total amount per min quantity with lot enabled. The first discount has item A quantity 1. The second discount has item A quantity 1 and Item B quantity 1

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Items with unit price        
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Item."Unit Price" := 2000;
        Item.Modify();
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(SecondItem, POSUnit, POSStore);
        SecondItem."Unit Price" := 4000;
        SecondItem.Modify();

        // [GIVEN] Discount with item quantity
        FirstDiscountTotalAmount := CreateTotalDiscountAmountTotalAmtPerMinQtyLotEnabled(Item, 500, false, 1, FirstDiscountCode);
        SecondDiscountTotalAmount := CreateTotalDiscountAmountTotalAmtPerMinQtyLotEnabledTwoItems(Item, SecondItem, 1000, false, 1, 1, SecondDiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Items to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = FirstDiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.AreNearlyEqual(POSSaleLine."Amount Including VAT", FirstDiscountTotalAmount, 0.1, 'Discount Amount not calculated according to scenario.');
        LibraryPOSMock.CreateItemLine(POSSession, SecondItem."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetLast();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLineSecond);

        // [THEN] Verify Discount is applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLineSecond."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLineSecond."Discount Type" = POSSaleLineSecond."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLineSecond."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = SecondDiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLineSecond."Discount Code" = SecondDiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.AreNearlyEqual(POSSaleLine."Amount Including VAT" + POSSaleLineSecond."Amount Including VAT", SecondDiscountTotalAmount, 0.1, 'Discount Amount not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyMixDiscountLotTotalDiscountAmountPerMinQtyOneItemOneQty()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        GeneralLedgerSetup: Record "General Ledger Setup";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        TotalDiscountAmount: Decimal;
        TotalDiscountAmountForCheck: Decimal;
        Qty: Decimal;
        DiscountCode: Code[20];
    begin
        // [SCENARIO] Mix discount Total discount amount per min quantity with lot enabled and 1 item x1 quantity

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Item with unit price        
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Item."Unit Price" := 2000;
        Item.Modify();

        // [GIVEN] Discount
        TotalDiscountAmount := CreateTotalDiscountAmountTotalDiscountAmtPerMinQtyLotEnabled(Item, 500, false, 1, DiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        TotalDiscountAmountForCheck := TotalDiscountAmount;
        if not POSSaleLine."Price Includes VAT" then
            TotalDiscountAmountForCheck := POSSaleTaxCalc.CalcAmountWithoutVAT(TotalDiscountAmount, POSSaleLine."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Verify Discount is applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.AreEqual(POSSaleLine."Discount Amount", TotalDiscountAmountForCheck, 'Discount Amount not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyMixDiscountLotTotalDiscountAmountPerMinQtyTwoItemsOneQty()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSaleLineSecond: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SecondItem: Record Item;
        GeneralLedgerSetup: Record "General Ledger Setup";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        TotalDiscountAmount: Decimal;
        TotalDiscountAmountForCheck: Decimal;
        Qty: Decimal;
        DiscountCode: Code[20];
    begin
        // [SCENARIO] Mix discount Total discount amount per min quantity with  lot enabled and 2 items x1 quantity.

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Item with unit price        
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Item."Unit Price" := 2000;
        Item.Modify();
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(SecondItem, POSUnit, POSStore);
        SecondItem."Unit Price" := 2000;
        SecondItem.Modify();

        // [GIVEN] Discount
        TotalDiscountAmount := CreateTotalDiscountAmountTotalDiscountAmtPerMinQtyLotEnabledTwoItems(Item, SecondItem, 500, false, 1, 1, DiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsFalse(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount not applied to POS Sale Line');
        LibraryPOSMock.CreateItemLine(POSSession, SecondItem."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetLast();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLineSecond);
        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        TotalDiscountAmountForCheck := TotalDiscountAmount;
        if not POSSaleLine."Price Includes VAT" then
            TotalDiscountAmountForCheck := POSSaleTaxCalc.CalcAmountWithoutVAT(TotalDiscountAmount, POSSaleLine."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Verify Discount is applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLineSecond."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLineSecond."Discount Type" = POSSaleLineSecond."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLineSecond."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLineSecond."Discount Code" = DiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.AreEqual(POSSaleLine."Discount Amount" + POSSaleLineSecond."Discount Amount", TotalDiscountAmountForCheck, 'Discount Amount not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyMixDiscountLotTotalDiscountAmountPerMinQtyTwoItemsTwoQty()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSaleLineSecond: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SecondItem: Record Item;
        GeneralLedgerSetup: Record "General Ledger Setup";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        TotalDiscountAmount: Decimal;
        TotalDiscountAmountForCheck: Decimal;
        Qty: Decimal;
        DiscountCode: Code[20];
    begin
        // [SCENARIO] Mix discount Total discount amount per min quantity with  lot enabled and 2 items x2 quantity.

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Item with unit price        
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Item."Unit Price" := 2000;
        Item.Modify();
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(SecondItem, POSUnit, POSStore);
        SecondItem."Unit Price" := 2000;
        SecondItem.Modify();

        // [GIVEN] Discount
        TotalDiscountAmount := CreateTotalDiscountAmountTotalDiscountAmtPerMinQtyLotEnabledTwoItems(Item, SecondItem, 500, false, 2, 2, DiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 2;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsFalse(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount not applied to POS Sale Line');
        LibraryPOSMock.CreateItemLine(POSSession, SecondItem."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetLast();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLineSecond);
        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        TotalDiscountAmountForCheck := TotalDiscountAmount;
        if not POSSaleLine."Price Includes VAT" then
            TotalDiscountAmountForCheck := POSSaleTaxCalc.CalcAmountWithoutVAT(TotalDiscountAmount, POSSaleLine."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Verify Discount is applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLineSecond."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLineSecond."Discount Type" = POSSaleLineSecond."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLineSecond."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLineSecond."Discount Code" = DiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.AreEqual(POSSaleLine."Discount Amount" + POSSaleLineSecond."Discount Amount", TotalDiscountAmountForCheck, 'Discount Amount not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyTwoMixDiscountsLotTotalDiscountAmountPerMinQtyFirstDiscountSingleItemSecondDiscountBothItems()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSaleLineSecond: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SecondItem: Record Item;
        GeneralLedgerSetup: Record "General Ledger Setup";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        FirstTotalDiscountAmount: Decimal;
        SecondTotalDiscountAmount: Decimal;
        FirstTotalDiscountAmountForCheck: Decimal;
        SecondTotalDiscountAmountForCheck: Decimal;
        Qty: Decimal;
        FirstDiscountCode: Code[20];
        SecondDiscountCode: Code[20];
    begin
        // [SCENARIO] 2 Mix discounts set as total discount amount per min quantity with lot enabled. The first discount has item A quantity 1. The second discount has item A quantity 1 and Item B quantity 1

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Item with unit price        
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Item."Unit Price" := 2000;
        Item.Modify();
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(SecondItem, POSUnit, POSStore);
        SecondItem."Unit Price" := 2000;
        SecondItem.Modify();

        // [GIVEN] Discount
        FirstTotalDiscountAmount := CreateTotalDiscountAmountTotalDiscountAmtPerMinQtyLotEnabled(Item, 500, false, 1, FirstDiscountCode);
        SecondTotalDiscountAmount := CreateTotalDiscountAmountTotalDiscountAmtPerMinQtyLotEnabledTwoItems(Item, SecondItem, 1000, false, 1, 1, SecondDiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        FirstTotalDiscountAmountForCheck := FirstTotalDiscountAmount;
        if not POSSaleLine."Price Includes VAT" then
            FirstTotalDiscountAmountForCheck := POSSaleTaxCalc.CalcAmountWithoutVAT(FirstTotalDiscountAmount, POSSaleLine."VAT %", GeneralLedgerSetup."Amount Rounding Precision");
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = FirstDiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.AreEqual(POSSaleLine."Discount Amount", FirstTotalDiscountAmountForCheck, 'Discount Amount not calculated according to scenario.');
        LibraryPOSMock.CreateItemLine(POSSession, SecondItem."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetLast();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLineSecond);
        SecondTotalDiscountAmountForCheck := SecondTotalDiscountAmount;
        if not POSSaleLineSecond."Price Includes VAT" then
            SecondTotalDiscountAmountForCheck := POSSaleTaxCalc.CalcAmountWithoutVAT(SecondTotalDiscountAmount, POSSaleLineSecond."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Verify Discount is applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = SecondDiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLineSecond."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLineSecond."Discount Type" = POSSaleLineSecond."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLineSecond."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLineSecond."Discount Code" = SecondDiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.AreEqual(POSSaleLine."Discount Amount" + POSSaleLineSecond."Discount Amount", SecondTotalDiscountAmountForCheck, 'Discount Amount not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyMixDiscountLotTotalDiscountPercentOneItemOneQty()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        DiscountPct: Decimal;
        Qty: Decimal;
        DiscountCode: Code[20];
    begin
        // [SCENARIO] Mix discount Total discount percent with lot enabled and 1 item x1 quantity

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Item with unit price        
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        DiscountPct := CreateTotalDiscountPctLotEnabled(Item, 50, false, 1, DiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount is applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.AreEqual(POSSaleLine."Discount %", DiscountPct, 'Discount Percent not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyMixDiscountLotTotalDiscountPercentTwoItemsOneQty()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSaleLineSecond: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SecondItem: Record Item;
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        DiscountPct: Decimal;
        Qty: Decimal;
        DiscountCode: Code[20];
    begin
        // [SCENARIO] Mix discount Total discount percent with  lot enabled and 2 items x1 quantity

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Items with unit price        
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Item."Unit Price" := 1000;
        Item.Modify();
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(SecondItem, POSUnit, POSStore);
        SecondItem."Unit Price" := 1000;
        SecondItem.Modify();

        // [GIVEN] Discount with item quantity
        DiscountPct := CreateTotalDiscountAmountTotalDiscountPctLotEnabledTwoItems(Item, SecondItem, 50, false, 1, 1, DiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Items to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsFalse(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount not applied to POS Sale Line');
        LibraryPOSMock.CreateItemLine(POSSession, SecondItem."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetLast();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLineSecond);

        // [THEN] Verify Discount is applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLineSecond."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLineSecond."Discount Type" = POSSaleLineSecond."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLineSecond."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLineSecond."Discount Code" = DiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.AreEqual(POSSaleLine."Discount %", DiscountPct, 'Discount Percent not calculated according to scenario.');
        Assert.AreEqual(POSSaleLineSecond."Discount %", DiscountPct, 'Discount Percent not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyMixDiscountLotTotalDiscountPercentTwoItemsTwoQty()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSaleLineSecond: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SecondItem: Record Item;
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        DiscountPct: Decimal;
        Qty: Decimal;
        DiscountCode: Code[20];
    begin
        // [SCENARIO] Mix discount Total discount percent with  lot enabled and 2 items x2 quantity.

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Items with unit price        
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Item."Unit Price" := 2000;
        Item.Modify();
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(SecondItem, POSUnit, POSStore);
        SecondItem."Unit Price" := 2000;
        SecondItem.Modify();

        // [GIVEN] Discount with item quantity
        DiscountPct := CreateTotalDiscountAmountTotalDiscountPctLotEnabledTwoItems(Item, SecondItem, 50, false, 2, 2, DiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Items to active sale
        Qty := 2;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsFalse(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount not applied to POS Sale Line');
        LibraryPOSMock.CreateItemLine(POSSession, SecondItem."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetLast();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLineSecond);

        // [THEN] Verify Discount is applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLineSecond."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLineSecond."Discount Type" = POSSaleLineSecond."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLineSecond."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLineSecond."Discount Code" = DiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.AreEqual(POSSaleLine."Discount %", DiscountPct, 'Discount Percent not calculated according to scenario.');
        Assert.AreEqual(POSSaleLineSecond."Discount %", DiscountPct, 'Discount Percent not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyTwoMixDiscountsLotTotalDiscountPercentFirstDiscountSingleItemSecondDiscountBothItems()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSaleLineSecond: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SecondItem: Record Item;
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        FirstDiscountPct: Decimal;
        SecondDiscountPct: Decimal;
        Qty: Decimal;
        FirstDiscountCode: Code[20];
        SecondDiscountCode: Code[20];
    begin
        // [SCENARIO] 2 Mix discounts set as total discount percent with lot enabled. The first discount has item A quantity 1. The second discount has item A quantity 1 and Item B quantity 1

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Items with unit price        
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Item."Unit Price" := 1000;
        Item.Modify();
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(SecondItem, POSUnit, POSStore);
        SecondItem."Unit Price" := 2000;
        SecondItem.Modify();

        // [GIVEN] Discount with item quantity
        FirstDiscountPct := CreateTotalDiscountPctLotEnabled(Item, 50, false, 1, FirstDiscountCode);
        SecondDiscountPct := CreateTotalDiscountAmountTotalDiscountPctLotEnabledTwoItems(Item, SecondItem, 60, false, 1, 1, SecondDiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Items to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = FirstDiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.AreEqual(POSSaleLine."Discount %", FirstDiscountPct, 'Discount Percent not calculated according to scenario.');
        LibraryPOSMock.CreateItemLine(POSSession, SecondItem."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetLast();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLineSecond);

        // [THEN] Verify Discount is applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLineSecond."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLineSecond."Discount Type" = POSSaleLineSecond."Discount Type"::Mix, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLineSecond."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLine."Discount Code" = SecondDiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.IsTrue(POSSaleLineSecond."Discount Code" = SecondDiscountCode, 'Mixed Discount not applied to POS Sale Line');
        Assert.AreEqual(POSSaleLine."Discount %", SecondDiscountPct, 'Discount Percent not calculated according to scenario.');
        Assert.AreEqual(POSSaleLineSecond."Discount %", SecondDiscountPct, 'Discount Percent not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyMixDiscountLotTotalAmountPerMinQtyOneItemOneQtyWrongQty()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        TotalAmount: Decimal;
        Qty: Decimal;
        DiscountCode: Code[20];
    begin
        // [SCENARIO] Mixed Discount applied Total Amount per Min. Qty. with Lot enabled wrong quantity set

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Item with unit price        
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        TotalAmount := CreateTotalDiscountAmountTotalAmtPerMinQtyLotEnabled(Item, 500, false, 2, DiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount is not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsFalse(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount applied to POS Sale Line which is not according to scenario');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount applied to POS Sale Line which is not according to scenario');
        Assert.AreNotEqual(POSSaleLine."Amount Including VAT", TotalAmount, 'Discount Amount not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyMixDiscountLotTotalAmountPerMinQtyTwoItemsOneQtyWrongQty()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSaleLineSecond: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SecondItem: Record Item;
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        TotalAmount: Decimal;
        Qty: Decimal;
        DiscountCode: Code[20];
    begin
        // [SCENARIO] Mixed Discount applied Total Amount per Min. Qty. with Lot enabled 2 items with 1 quantity and wrong quantity set

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Items with unit price        
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Item."Unit Price" := 1000;
        Item.Modify();
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(SecondItem, POSUnit, POSStore);
        SecondItem."Unit Price" := 1000;
        SecondItem.Modify();

        // [GIVEN] Discount with item quantity
        TotalAmount := CreateTotalDiscountAmountTotalAmtPerMinQtyLotEnabledTwoItems(Item, SecondItem, 500, false, 2, 2, DiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Items to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);
        LibraryPOSMock.CreateItemLine(POSSession, SecondItem."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetLast();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLineSecond);

        // [THEN] Verify Discount is not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsFalse(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount applied to POS Sale Line which is not according to scenario');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLineSecond."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsFalse(POSSaleLineSecond."Discount Type" = POSSaleLineSecond."Discount Type"::Mix, 'Mixed Discount applied to POS Sale Line which is not according to scenario');
        Assert.IsFalse(POSSaleLineSecond."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount applied to POS Sale Line which is not according to scenario');
        Assert.IsFalse(POSSaleLineSecond."Discount Code" = DiscountCode, 'Mixed Discount applied to POS Sale Line which is not according to scenario');
        Assert.AreNotEqual(POSSaleLine."Amount Including VAT" + POSSaleLineSecond."Amount Including VAT", TotalAmount, 'Discount Amount not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyTwoMixDiscountsLotTotalAmountPerMinQtyFirstDiscountSingleItemSecondDiscountBothItemsWrongQty()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSaleLineSecond: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SecondItem: Record Item;
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        FirstDiscountTotalAmount: Decimal;
        SecondDiscountTotalAmount: Decimal;
        Qty: Decimal;
        FirstDiscountCode: Code[20];
        SecondDiscountCode: Code[20];
    begin
        // [SCENARIO] 2 Mix discounts set as total amount per min quantity with lot enabled. The first discount has item A quantity 1. The second discount has item A quantity 1 and Item B quantity 1. Wrong quantity is set and discount should not be triggered

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Items with unit price        
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Item."Unit Price" := 1000;
        Item.Modify();
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(SecondItem, POSUnit, POSStore);
        SecondItem."Unit Price" := 1000;
        SecondItem.Modify();

        // [GIVEN] Discount with item quantity
        FirstDiscountTotalAmount := CreateTotalDiscountAmountTotalAmtPerMinQtyLotEnabled(Item, 500, false, 2, FirstDiscountCode);
        SecondDiscountTotalAmount := CreateTotalDiscountAmountTotalAmtPerMinQtyLotEnabledTwoItems(Item, SecondItem, 1000, false, 2, 2, SecondDiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Items to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);
        LibraryPOSMock.CreateItemLine(POSSession, SecondItem."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetLast();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLineSecond);

        // [THEN] Verify Discount is not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsFalse(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount applied to POS Sale Line which is not according to scenario');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLineSecond."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsFalse(POSSaleLineSecond."Discount Type" = POSSaleLineSecond."Discount Type"::Mix, 'Mixed Discount applied to POS Sale Line which is not according to scenario');
        Assert.IsFalse(POSSaleLineSecond."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Code" = SecondDiscountCode, 'Mixed Discount applied to POS Sale Line which is not according to scenario');
        Assert.IsFalse(POSSaleLineSecond."Discount Code" = SecondDiscountCode, 'Mixed Discount applied to POS Sale Line which is not according to scenario');
        Assert.AreNotEqual(POSSaleLine."Amount Including VAT" + POSSaleLineSecond."Amount Including VAT", SecondDiscountTotalAmount, 'Discount Amount not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyMixDiscountLotTotalDiscountAmountPerMinQtyOneItemOneQtyWrongQty()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        DiscountCode: Code[20];
    begin
        // [SCENARIO] Mix discount Total discount amount per min quantity with lot enabled and 1 item x1 quantity and wrong quantity set

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Item with unit price        
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Item."Unit Price" := 2000;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountAmountTotalDiscountAmtPerMinQtyLotEnabled(Item, 500, false, 2, DiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount is not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsFalse(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount applied to POS Sale Line which is not according to scenario');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount applied to POS Sale Line which is not according to scenario');
        Assert.AreEqual(POSSaleLine."Discount Amount", 0, 'Discount Amount not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyMixDiscountLotTotalDiscountAmountPerMinQtyTwoItemsTwoQtyWrongQty()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSaleLineSecond: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SecondItem: Record Item;
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        DiscountCode: Code[20];
    begin
        // [SCENARIO] Mix discount Total discount amount per min quantity with  lot enabled and 2 items x2 quantity and wrong quantity set

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Item with unit price        
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Item."Unit Price" := 2000;
        Item.Modify();
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(SecondItem, POSUnit, POSStore);
        SecondItem."Unit Price" := 2000;
        SecondItem.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountAmountTotalDiscountAmtPerMinQtyLotEnabledTwoItems(Item, SecondItem, 500, false, 2, 2, DiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);
        LibraryPOSMock.CreateItemLine(POSSession, SecondItem."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetLast();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLineSecond);

        // [THEN] Verify Discount is not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsFalse(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount applied to POS Sale Line which is not according to scenario');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount applied to POS Sale Line which is not according to scenario');
        Assert.IsTrue(POSSaleLineSecond."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsFalse(POSSaleLineSecond."Discount Type" = POSSaleLineSecond."Discount Type"::Mix, 'Mixed Discount applied to POS Sale Line which is not according to scenario');
        Assert.IsFalse(POSSaleLineSecond."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsFalse(POSSaleLineSecond."Discount Code" = DiscountCode, 'Mixed Discount applied to POS Sale Line which is not according to scenario');
        Assert.AreEqual(POSSaleLine."Discount Amount" + POSSaleLineSecond."Discount Amount", 0, 'Discount Amount not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyTwoMixDiscountsLotTotalDiscountAmountPerMinQtyFirstItemQtyOneSecondItemOneQty1ItemTwoQty1WrongQty()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSaleLineSecond: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SecondItem: Record Item;
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        FirstDiscountCode: Code[20];
        SecondDiscountCode: Code[20];
    begin
        // [SCENARIO] 2 Mix discounts set as total discount amount per min quantity with lot enabled. The first discount has item A quantity 1. The second discount has item A quantity 1 and Item B quantity 1. Wrong quantity is set and discount should not be triggered

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Item with unit price        
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Item."Unit Price" := 2000;
        Item.Modify();
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(SecondItem, POSUnit, POSStore);
        SecondItem."Unit Price" := 2000;
        SecondItem.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountAmountTotalDiscountAmtPerMinQtyLotEnabled(Item, 500, false, 2, FirstDiscountCode);
        CreateTotalDiscountAmountTotalDiscountAmtPerMinQtyLotEnabledTwoItems(Item, SecondItem, 1000, false, 2, 2, SecondDiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);
        LibraryPOSMock.CreateItemLine(POSSession, SecondItem."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetLast();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLineSecond);

        // [THEN] Verify Discount is not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsFalse(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount applied to POS Sale Line which is not according to scenario');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Code" = SecondDiscountCode, 'Mixed Discount applied to POS Sale Line which is not according to scenario');
        Assert.IsTrue(POSSaleLineSecond."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsFalse(POSSaleLineSecond."Discount Type" = POSSaleLineSecond."Discount Type"::Mix, 'Mixed Discount applied to POS Sale Line which is not according to scenario');
        Assert.IsFalse(POSSaleLineSecond."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsFalse(POSSaleLineSecond."Discount Code" = SecondDiscountCode, 'Mixed Discount applied to POS Sale Line which is not according to scenario');
        Assert.AreEqual(POSSaleLine."Discount Amount" + POSSaleLineSecond."Discount Amount", 0, 'Discount Amount not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyMixDiscountLotTotalDiscountPercentOneItemOneQtyWrongQty()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        DiscountPct: Decimal;
        Qty: Decimal;
        DiscountCode: Code[20];
    begin
        // [SCENARIO] Mix discount Total discount percent with lot enabled and 1 item x1 quantity and wrong quantity

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Item with unit price        
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        DiscountPct := CreateTotalDiscountPctLotEnabled(Item, 50, false, 2, DiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        // [THEN] Verify Discount is not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsFalse(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount applied to POS Sale Line which is not according to scenario');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount applied to POS Sale Line which is not according to scenario');
        Assert.AreEqual(POSSaleLine."Discount %", 0, 'Discount Percent not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyMixDiscountLotTotalDiscountPercentTwoItemsTwoQtyWrongQty()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSaleLineSecond: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SecondItem: Record Item;
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        DiscountPct: Decimal;
        Qty: Decimal;
        DiscountCode: Code[20];
    begin
        // [SCENARIO] Mix discount Total discount percent with  lot enabled and 2 items x2 quantity and wrong quantity

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Items with unit price        
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Item."Unit Price" := 2000;
        Item.Modify();
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(SecondItem, POSUnit, POSStore);
        SecondItem."Unit Price" := 2000;
        SecondItem.Modify();

        // [GIVEN] Discount with item quantity
        DiscountPct := CreateTotalDiscountAmountTotalDiscountPctLotEnabledTwoItems(Item, SecondItem, 50, false, 2, 2, DiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Items to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);
        LibraryPOSMock.CreateItemLine(POSSession, SecondItem."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetLast();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLineSecond);

        // [THEN] Verify Discount is not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsFalse(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount applied to POS Sale Line which is not according to scenario');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLineSecond."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsFalse(POSSaleLineSecond."Discount Type" = POSSaleLineSecond."Discount Type"::Mix, 'Mixed Discount applied to POS Sale Line which is not according to scenario');
        Assert.IsFalse(POSSaleLineSecond."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Code" = DiscountCode, 'Mixed Discount applied to POS Sale Line which is not according to scenario');
        Assert.IsFalse(POSSaleLineSecond."Discount Code" = DiscountCode, 'Mixed Discount applied to POS Sale Line which is not according to scenario');
        Assert.AreEqual(POSSaleLine."Discount %", 0, 'Discount Percent not calculated according to scenario.');
        Assert.AreEqual(POSSaleLineSecond."Discount %", 0, 'Discount Percent not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyTwoMixDiscountsLotTotalDiscountPercentFirstDiscountSingleItemSecondDiscountBothItemsWrongQty()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSaleLineSecond: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SecondItem: Record Item;
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        FirstDiscountPct: Decimal;
        SecondDiscountPct: Decimal;
        Qty: Decimal;
        FirstDiscountCode: Code[20];
        SecondDiscountCode: Code[20];
    begin
        // [SCENARIO] 2 Mix discounts set as total discount percent with lot enabled. The first discount has item A quantity 1. The second discount has item A quantity 1 and Item B quantity 1. Quantity is wrong so the discount should not be triggered

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Items with unit price        
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Item."Unit Price" := 1000;
        Item.Modify();
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(SecondItem, POSUnit, POSStore);
        SecondItem."Unit Price" := 2000;
        SecondItem.Modify();

        // [GIVEN] Discount with item quantity
        FirstDiscountPct := CreateTotalDiscountPctLotEnabled(Item, 50, false, 2, FirstDiscountCode);
        SecondDiscountPct := CreateTotalDiscountAmountTotalDiscountPctLotEnabledTwoItems(Item, SecondItem, 60, false, 2, 2, SecondDiscountCode);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Add Items to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);
        LibraryPOSMock.CreateItemLine(POSSession, SecondItem."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetLast();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLineSecond);

        // [THEN] Verify Discount is not applied
        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsFalse(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Mix, 'Mixed Discount applied to POS Sale Line which is not according to scenario');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsTrue(POSSaleLineSecond."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsFalse(POSSaleLineSecond."Discount Type" = POSSaleLineSecond."Discount Type"::Mix, 'Mixed Discount applied to POS Sale Line which is not according to scenario');
        Assert.IsFalse(POSSaleLineSecond."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Code" = SecondDiscountCode, 'Mixed Discount applied to POS Sale Line which is not according to scenario');
        Assert.IsFalse(POSSaleLineSecond."Discount Code" = SecondDiscountCode, 'Mixed Discount applied to POS Sale Line which is not according to scenario');
        Assert.AreEqual(POSSaleLine."Discount %", 0, 'Discount Percent not calculated according to scenario.');
        Assert.AreEqual(POSSaleLineSecond."Discount %", 0, 'Discount Percent not calculated according to scenario.');
    end;

    procedure InitializeData()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        SalesSetup: Record "Sales & Receivables Setup";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryERM: Codeunit "Library - ERM";
    begin
        if Initialized then begin
            //Clean any previous mock session
            POSSession.ClearAll();
            Clear(POSSession);
        end;

        if not Initialized then begin
            SalesSetup.Get();
            SalesSetup."Discount Posting" := SalesSetup."Discount Posting"::"Line Discounts";
            SalesSetup.Modify();
            LibraryERM.CreateVATBusinessPostingGroup(VATBusinessPostingGroup);
            LibraryPOSMasterData.CreatePOSSetup(POSSetup);
            LibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            POSPostingProfile."POS Period Register No. Series" := '';
            POSPostingProfile.Modify();
            LibraryPOSMasterData.CreatePOSStore(POSStore, POSPostingProfile.Code);
            LibraryPOSMasterData.CreatePOSUnit(POSUnit, POSStore.Code, POSPostingProfile.Code);
            LibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);

            LibraryTaxCalc.CreateTaxSetup();
            LibraryTaxCalc.CreateTaxGroup(TaxGroup);

            CreateEmptyTaxPostingSetup();

            DeletePOSPostedEntries();
            DeleteDiscounts();

            Initialized := true;
        end;

        Commit();
    end;

    local procedure DeletePOSPostedEntries()
    var
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        GLEntry: Record "G/L Entry";
        VATEntry: Record "VAT Entry";
    begin
        //Just in case if performance test is created and run on test company for POS test unit
        //then POS posting is terminated because POS entries are stored in database with sales tickect no.
        //defined in the Library POS Master Data 
        POSEntry.DeleteAll();
        POSEntrySalesLine.DeleteAll();
        POSEntryPaymentLine.DeleteAll();
        POSEntryTaxLine.DeleteAll();
        VATEntry.DeleteAll();
        GLEntry.DeleteAll();
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

    local procedure CreateItem(var Item: Record Item; VATBusPostingGroupCode: Code[20]; VATProdPostingGroupCode: Code[20]; TaxGroupCode: Code[20]; PricesIncludesVAT: Boolean)
    var
        LibraryTaxCalc2: codeunit "NPR POS Lib. - Tax Calc.";
    begin
        LibraryTaxCalc2.CreateItem(Item, VATProdPostingGroupCode, VATBusPostingGroupCode);
        Item."Price Includes VAT" := PricesIncludesVAT;
        Item."Tax Group Code" := TaxGroupCode;
        Item.Modify();
        CreateGeneralPostingSetupForItem(Item);
    end;

    local procedure CreateGeneralPostingSetupForItem(Item: Record Item)
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        LibraryPOSMasterData: codeunit "NPR Library - POS Master Data";
    begin
        POSStore.GetProfile(POSPostingProfile);
        LibraryPOSMasterData.CreateGeneralPostingSetupForSaleItem(
                                        POSPostingProfile."Gen. Bus. Posting Group",
                                        Item."Gen. Prod. Posting Group",
                                        POSStore."Location Code",
                                        Item."Inventory Posting Group");
    end;

    local procedure CreatePOSSaleLine(Item: Record Item; POSSale: Record "NPR POS Sale"; var POSSaleLine: Record "NPR POS Sale Line")
    begin
        POSSaleLine."Register No." := POSSale."Register No.";
        POSSaleLine."Sales Ticket No." := POSSale."Sales Ticket No.";
        POSSaleLine."Line No." := 10000;
        POSSaleLine.Date := Today();
        POSSaleLine.Init();
        POSSaleLine."Line Type" := POSSaleLine."Line Type"::Item;
        POSSaleLine."No." := Item."No.";
        POSSaleLine.Quantity := 1;
        POSSaleLine."Unit Price" := Item."Unit Price";
        POSSaleLine."Unit of Measure Code" := Item."Sales Unit of Measure";
        POSSaleLine.Insert();
    end;

    local procedure CreateCustomer(var Customer: Record Customer; PricesIncludingTax: Boolean; AllowLineDisc: Boolean)
    var
        LibrarySales: Codeunit "Library - Sales";
    begin
        LibrarySales.CreateCustomerWithAddress(Customer);
        Customer."Prices Including VAT" := PricesIncludingTax;
        Customer."Allow Line Disc." := AllowLineDisc;
        Customer.Modify();
    end;

    local procedure CreateCustomer(var Customer: Record Customer; PricesIncludingTax: Boolean; AllowLineDisc: Boolean; TaxAreCode: Code[20]; TaxLiable: Boolean)
    var
        LibrarySales: Codeunit "Library - Sales";
    begin
        LibrarySales.CreateCustomerWithAddress(Customer);
        Customer."Prices Including VAT" := PricesIncludingTax;
        Customer.validate("Tax Area Code", TaxAreCode);
        Customer."Tax Liable" := TaxLiable;
        Customer."Allow Line Disc." := AllowLineDisc;
        Customer.Modify();
    end;

    local procedure GetAmountToPay(POSSaleLine: Record "NPR POS Sale Line"): Decimal
    var
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        AmountToPay: Decimal;
    begin
        POSSaleTaxCalc.Find(POSSaleTax, POSSaleLine.SystemId);
        AmountToPay := POSSaleTax."Calculated Amount Incl. Tax";
        exit(AmountToPay);
    end;

    local procedure AssignTaxDetailToPOSPostingProfile(TaxAreaCode: Code[20]; TaxLiable: Boolean)
    var
        LibraryPOSMasterData: codeunit "NPR Library - POS Master Data";
    begin
        LibraryPOSMasterData.AssignTaxDetailToPOSPostingProfile(POSStore, TaxAreaCode, TaxLiable);
    end;

    procedure UpdatePOSSalesRoundingAcc()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        GLAcc: Record "G/L Account";
    begin
        POSStore.GetProfile(POSPostingProfile);
        GLAcc."No." := POSPostingProfile."POS Sales Rounding Account";
        GLAcc.Find();
        GLAcc."VAT Bus. Posting Group" := '';
        GLAcc."VAT Prod. Posting Group" := '';
        GLAcc."Gen. Bus. Posting Group" := '';
        GLAcc."Gen. Prod. Posting Group" := '';
        GLAcc."Gen. Posting Type" := GLAcc."Gen. Posting Type"::" ";
        GLAcc.Modify();
    end;

    local procedure EnableDiscount()
    var
        DiscountPriority: Record "NPR Discount Priority";
        DiscountPriorityList: TestPage "NPR Discount Priority List";
    begin
        DiscountPriority.DeleteAll();

        DiscountPriorityList.OpenView();
        DiscountPriorityList.Close();

        DiscountPriority.SetFilter("Table ID", '<>%1', DiscSourceTableId());
        DiscountPriority.ModifyAll(Disabled, true);
    end;

    local procedure DeleteDiscounts()
    var
        RecRef: RecordRef;
    begin
        RecRef.Open(DiscSourceTableId());
        RecRef.DeleteAll(true);
    end;

    local procedure DiscSourceTableId(): Integer
    begin
        exit(DATABASE::"NPR Mixed Discount");
    end;

    internal procedure CreateTotalDiscountPct(Item: Record Item; TotalDiscPct: Decimal; TotalAmtExclTax: Boolean): Decimal
    var
        MixedDiscount: Record "NPR Mixed Discount";
        DiscPct: Decimal;
    begin
        DiscPct := CreateTotalDiscountPctHeader(MixedDiscount, TotalDiscPct, TotalAmtExclTax);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);
        exit(DiscPct);
    end;

    local procedure CreateTotalDiscountPctWithUOM(Item: Record Item; TotalDiscPct: Decimal; TotalAmtExclTax: Boolean; UOM: Code[10]; var DiscountCode: Code[20]): Decimal
    var
        MixedDiscount: Record "NPR Mixed Discount";
        DiscPct: Decimal;
    begin
        DiscPct := CreateTotalDiscountPctHeader(MixedDiscount, TotalDiscPct, TotalAmtExclTax);
        CreateDiscountLineWithUOM(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item, UOM);
        DiscountCode := MixedDiscount.Code;
        MixedDiscount.Modify();
        exit(DiscPct);
    end;

    local procedure CreateTotalDiscountPctWithUOMTwoItems(Item: Record Item; SecondItem: Record Item; TotalDiscPct: Decimal; TotalAmtExclTax: Boolean; FirstUOM: Code[10]; SecondUOM: Code[10]; var DiscountCode: Code[20]): Decimal
    var
        MixedDiscount: Record "NPR Mixed Discount";
        DiscPct: Decimal;
    begin
        DiscPct := CreateTotalDiscountPctHeader(MixedDiscount, TotalDiscPct, TotalAmtExclTax);
        CreateDiscountLineWithUOM(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item, FirstUOM);
        CreateDiscountLineWithUOM(MixedDiscount, SecondItem, "NPR Disc. Grouping Type"::Item, SecondUOM);
        DiscountCode := MixedDiscount.Code;
        MixedDiscount.Modify();
        exit(DiscPct);
    end;

    internal procedure CreateTotalDiscountAmountTotalDiscountAmtPerMinQty(Item: Record Item; TotalDiscountAmount: Decimal; TotalAmountExclTax: Boolean): Decimal
    var
        MixedDiscount: Record "NPR Mixed Discount";
        DiscountAmount: Decimal;
    begin
        DiscountAmount := CreateTotalDiscountAmountHeader(MixedDiscount, TotalDiscountAmount, TotalAmountExclTax);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);
        exit(DiscountAmount);
    end;

    internal procedure CreateTotalDiscountAmountTotalAmtPerMinQty(Item: Record Item; TotalDiscountAmount: Decimal; TotalAmountExclTax: Boolean): Decimal
    var
        MixedDiscount: Record "NPR Mixed Discount";
        DiscountAmount: Decimal;
    begin
        DiscountAmount := CreateTotalAmountHeader(MixedDiscount, TotalDiscountAmount, TotalAmountExclTax);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);
        exit(DiscountAmount);
    end;

    internal procedure CreateMultipleDiscountLevels(Item: Record Item; FirstLevelQty: Integer; SecondLevelQty: Integer; FirstLevelAmount: Decimal; SecondLevelAmount: Decimal; TotalAmountExclTax: Boolean): Code[20]
    var
        MixedDiscount: Record "NPR Mixed Discount";
    begin
        CreateMultipleDiscountLevelsHeader(MixedDiscount, TotalAmountExclTax);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);
        CreateMixDiscountLevels(MixedDiscount, FirstLevelQty, SecondLevelQty, FirstLevelAmount, SecondLevelAmount);
        exit(MixedDiscount.Code);
    end;

    local procedure CreateTotalDiscountAmountTotalAmtPerMinQtyWithUOM(Item: Record Item; TotalDiscountAmount: Decimal; TotalAmountExclTax: Boolean; UOM: Code[10]; var DiscountCode: Code[20]): Decimal
    var
        MixedDiscount: Record "NPR Mixed Discount";
        DiscountAmount: Decimal;
    begin
        DiscountAmount := CreateTotalAmountHeader(MixedDiscount, TotalDiscountAmount, TotalAmountExclTax);
        CreateDiscountLineWithUOM(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item, UOM);
        DiscountCode := MixedDiscount.Code;
        exit(DiscountAmount);
    end;

    local procedure CreateTotalDiscountAmountTotalDiscountAmtPerMinQtyWithUOM(Item: Record Item; TotalDiscountAmount: Decimal; TotalAmountExclTax: Boolean; UOM: Code[10]; var DiscountCode: Code[20]): Decimal
    var
        MixedDiscount: Record "NPR Mixed Discount";
        DiscountAmount: Decimal;
    begin
        DiscountAmount := CreateTotalDiscountAmountHeader(MixedDiscount, TotalDiscountAmount, TotalAmountExclTax);
        CreateDiscountLineWithUOM(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item, UOM);
        DiscountCode := MixedDiscount.Code;
        exit(DiscountAmount);
    end;

    local procedure CreateTotalDiscountAmountTotalDiscountAmtPerMinQtyWithUOMTwoItems(Item: Record Item; SecondItem: Record Item; TotalDiscountAmount: Decimal; TotalAmountExclTax: Boolean; FirstUOM: Code[10]; SecondUOM: Code[10]; var DiscountCode: Code[20]): Decimal
    var
        MixedDiscount: Record "NPR Mixed Discount";
        DiscountAmount: Decimal;
    begin
        DiscountAmount := CreateTotalDiscountAmountHeader(MixedDiscount, TotalDiscountAmount, TotalAmountExclTax);
        CreateDiscountLineWithUOM(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item, FirstUOM);
        CreateDiscountLineWithUOM(MixedDiscount, SecondItem, "NPR Disc. Grouping Type"::Item, SecondUOM);
        DiscountCode := MixedDiscount.Code;
        exit(DiscountAmount);
    end;

    local procedure CreateTotalDiscountAmountTotalAmtPerMinQtyWithUOMTwoItems(Item: Record Item; SecondItem: Record Item; TotalDiscountAmount: Decimal; TotalAmountExclTax: Boolean; FirstUOM: Code[10]; SecondUOM: Code[10]; var DiscountCode: Code[20]): Decimal
    var
        MixedDiscount: Record "NPR Mixed Discount";
        DiscountAmount: Decimal;
    begin
        DiscountAmount := CreateTotalAmountHeader(MixedDiscount, TotalDiscountAmount, TotalAmountExclTax);
        CreateDiscountLineWithUOM(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item, FirstUOM);
        CreateDiscountLineWithUOM(MixedDiscount, SecondItem, "NPR Disc. Grouping Type"::Item, SecondUOM);
        DiscountCode := MixedDiscount.Code;
        exit(DiscountAmount);
    end;

    local procedure CreateTotalDiscountPctHeader(var MixedDiscount: Record "NPR Mixed Discount"; TotalDiscPct: Decimal; TotalAmtExclTax: Boolean): Decimal
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        MixedDiscount.Code := LibraryUtility.GenerateRandomCode(MixedDiscount.FieldNo(Code), DiscSourceTableId());
        MixedDiscount.Init();
        MixedDiscount.Status := MixedDiscount.Status::Active;
        MixedDiscount."Starting date" := Today() - 7;
        MixedDiscount."Ending date" := Today() + 7;
        MixedDiscount."Discount Type" := MixedDiscount."Discount Type"::"Total Discount %";
        MixedDiscount."Total Discount %" := TotalDiscPct;
        MixedDiscount."Total Amount Excl. VAT" := TotalAmtExclTax;
        MixedDiscount."Min. Quantity" := 1;
        MixedDiscount.Insert();
        exit(MixedDiscount."Total Discount %");
    end;

    local procedure CreateTotalDiscountAmountHeader(var MixedDiscount: Record "NPR Mixed Discount"; TotalDiscountAmount: Decimal; TotalAmtExclTax: Boolean): Decimal
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        MixedDiscount.Code := LibraryUtility.GenerateRandomCode(MixedDiscount.FieldNo(Code), DiscSourceTableId());
        MixedDiscount.Init();
        MixedDiscount.Status := MixedDiscount.Status::Active;
        MixedDiscount."Starting date" := Today() - 7;
        MixedDiscount."Ending date" := Today() + 7;
        MixedDiscount."Discount Type" := MixedDiscount."Discount Type"::"Total Discount Amt. per Min. Qty.";
        MixedDiscount."Total Discount Amount" := TotalDiscountAmount;
        MixedDiscount."Total Amount Excl. VAT" := TotalAmtExclTax;
        MixedDiscount."Min. Quantity" := 1;
        MixedDiscount.Insert();
        exit(MixedDiscount."Total Discount Amount");
    end;

    local procedure CreateTotalAmountHeader(var MixedDiscount: Record "NPR Mixed Discount"; TotalDiscountAmount: Decimal; TotalAmtExclTax: Boolean): Decimal
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        MixedDiscount.Code := LibraryUtility.GenerateRandomCode(MixedDiscount.FieldNo(Code), DiscSourceTableId());
        MixedDiscount.Init();
        MixedDiscount.Status := MixedDiscount.Status::Active;
        MixedDiscount."Starting date" := Today() - 7;
        MixedDiscount."Ending date" := Today() + 7;
        MixedDiscount."Discount Type" := MixedDiscount."Discount Type"::"Total Amount per Min. Qty.";
        MixedDiscount."Total Amount" := TotalDiscountAmount;
        MixedDiscount."Total Amount Excl. VAT" := TotalAmtExclTax;
        MixedDiscount."Min. Quantity" := 1;
        MixedDiscount.Insert();
        exit(MixedDiscount."Total Amount");
    end;

    local procedure CreateMultipleDiscountLevelsHeader(var MixedDiscount: Record "NPR Mixed Discount"; TotalAmtExclTax: Boolean)
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        MixedDiscount.Code := LibraryUtility.GenerateRandomCode(MixedDiscount.FieldNo(Code), DiscSourceTableId());
        MixedDiscount.Init();
        MixedDiscount.Status := MixedDiscount.Status::Active;
        MixedDiscount."Starting date" := Today() - 7;
        MixedDiscount."Ending date" := Today() + 7;
        MixedDiscount."Discount Type" := MixedDiscount."Discount Type"::"Multiple Discount Levels";
        MixedDiscount."Total Amount Excl. VAT" := TotalAmtExclTax;
        MixedDiscount."Min. Quantity" := 1;
        MixedDiscount.Insert();
    end;

    local procedure CreateMixDiscountLevels(MixedDiscount: Record "NPR Mixed Discount"; FirstLevelQty: Integer; SecondLevelQty: Integer; FirstLevelAmount: Decimal; SecondLevelAmount: Decimal)
    var
        MixedDiscountLevel: Record "NPR Mixed Discount Level";
    begin
        MixedDiscountLevel.Init();
        MixedDiscountLevel."Mixed Discount Code" := MixedDiscount.Code;
        MixedDiscountLevel.Quantity := FirstLevelQty;
        MixedDiscountLevel."Discount Amount" := FirstLevelAmount;
        MixedDiscountLevel.Insert();

        MixedDiscountLevel.Init();
        MixedDiscountLevel."Mixed Discount Code" := MixedDiscount.Code;
        MixedDiscountLevel.Quantity := SecondLevelQty;
        MixedDiscountLevel."Discount Amount" := SecondLevelAmount;
        MixedDiscountLevel.Insert();
    end;

    local procedure CreateDiscountLine(MixedDiscount: Record "NPR Mixed Discount"; Item: Record Item; DiscGroupType: Enum "NPR Disc. Grouping Type")
    var
        MixedDiscountLine: Record "NPR Mixed Discount Line";
    begin
        MixedDiscountLine.Code := MixedDiscount.Code;
        MixedDiscountLine."Disc. Grouping Type" := DiscGroupType;
        MixedDiscountLine."No." := Item."No.";
        MixedDiscountLine."Variant Code" := '';
        MixedDiscountLine.Init();
        MixedDiscountLine.Status := MixedDiscount.Status;
        MixedDiscountLine."Starting date" := MixedDiscount."Starting date";
        MixedDiscountLine."Ending Date" := MixedDiscount."Ending date";
        MixedDiscountLine.Insert();
    end;

    local procedure CreateDiscountLineWithUOM(MixedDiscount: Record "NPR Mixed Discount"; Item: Record Item; DiscGroupType: Enum "NPR Disc. Grouping Type"; UOM: Code[10])
    var
        MixedDiscountLine: Record "NPR Mixed Discount Line";
    begin
        MixedDiscountLine.Code := MixedDiscount.Code;
        MixedDiscountLine."Disc. Grouping Type" := DiscGroupType;
        MixedDiscountLine."No." := Item."No.";
        MixedDiscountLine."Variant Code" := '';
        MixedDiscountLine.Init();
        MixedDiscountLine.Status := MixedDiscount.Status;
        MixedDiscountLine."Unit of Measure Code" := UOM;
        MixedDiscountLine."Starting date" := MixedDiscount."Starting date";
        MixedDiscountLine."Ending Date" := MixedDiscount."Ending date";
        MixedDiscountLine.Insert();
    end;

    local procedure CreateTotalDiscountPctLotEnabled(Item: Record Item; TotalDiscPct: Decimal; TotalAmtExclTax: Boolean; ItemQty: Integer; var DiscountCode: Code[20]): Decimal
    var
        MixedDiscount: Record "NPR Mixed Discount";
        DiscPct: Decimal;
    begin
        DiscPct := CreateTotalDiscountPctHeader(MixedDiscount, TotalDiscPct, TotalAmtExclTax);
        CreateDiscountLineWithQty(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item, ItemQty);
        MixedDiscount.Lot := true;
        DiscountCode := MixedDiscount.Code;
        MixedDiscount.Modify();
        exit(DiscPct);
    end;

    local procedure CreateTotalDiscountAmountTotalDiscountPctLotEnabledTwoItems(Item: Record Item; Item2: Record Item; TotalDiscountAmount: Decimal; TotalAmountExclTax: Boolean; FirstItemQty: Integer; SecondItemQty: Integer; var DiscountCode: Code[20]) DiscountAmount: Decimal
    var
        MixedDiscount: Record "NPR Mixed Discount";
    begin
        DiscountAmount := CreateTotalDiscountPctHeader(MixedDiscount, TotalDiscountAmount, TotalAmountExclTax);
        MixedDiscount.Lot := true;
        CreateDiscountLineWithQty(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item, FirstItemQty);
        CreateDiscountLineWithQty(MixedDiscount, Item2, "NPR Disc. Grouping Type"::Item, SecondItemQty);
        DiscountCode := MixedDiscount.Code;
        MixedDiscount.Modify();
    end;

    local procedure CreateTotalDiscountAmountTotalAmtPerMinQtyLotEnabled(Item: Record Item; TotalDiscountAmount: Decimal; TotalAmountExclTax: Boolean; ItemQty: Integer; var DiscountCode: Code[20]) DiscountAmount: Decimal
    var
        MixedDiscount: Record "NPR Mixed Discount";
    begin
        DiscountAmount := CreateTotalAmountHeader(MixedDiscount, TotalDiscountAmount, TotalAmountExclTax);
        CreateDiscountLineWithQty(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item, ItemQty);
        MixedDiscount.Lot := true;
        DiscountCode := MixedDiscount.Code;
        MixedDiscount.Modify();
    end;

    local procedure CreateTotalDiscountAmountTotalDiscountAmtPerMinQtyLotEnabled(Item: Record Item; TotalDiscountAmount: Decimal; TotalAmountExclTax: Boolean; ItemQty: Integer; var DiscountCode: Code[20]) DiscountAmount: Decimal
    var
        MixedDiscount: Record "NPR Mixed Discount";
    begin
        CreateTotalDiscountAmountHeader(MixedDiscount, TotalDiscountAmount, TotalAmountExclTax);
        CreateDiscountLineWithQty(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item, ItemQty);
        MixedDiscount.Lot := true;
        DiscountCode := MixedDiscount.Code;
        MixedDiscount.Modify();
        DiscountAmount := MixedDiscount."Total Discount Amount";
    end;

    local procedure CreateTotalDiscountAmountTotalAmtPerMinQtyLotEnabledTwoItems(Item: Record Item; Item2: Record Item; TotalDiscountAmount: Decimal; TotalAmountExclTax: Boolean; FirstItemQty: Integer; SecondItemQty: Integer; var DiscountCode: Code[20]) DiscountAmount: Decimal
    var
        MixedDiscount: Record "NPR Mixed Discount";
    begin
        DiscountAmount := CreateTotalAmountHeader(MixedDiscount, TotalDiscountAmount, TotalAmountExclTax);
        MixedDiscount.Lot := true;
        CreateDiscountLineWithQty(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item, FirstItemQty);
        CreateDiscountLineWithQty(MixedDiscount, Item2, "NPR Disc. Grouping Type"::Item, SecondItemQty);
        DiscountCode := MixedDiscount.Code;
        MixedDiscount.Modify();
    end;

    local procedure CreateTotalDiscountAmountTotalDiscountAmtPerMinQtyLotEnabledTwoItems(Item: Record Item; Item2: Record Item; TotalDiscountAmount: Decimal; TotalAmountExclTax: Boolean; FirstItemQty: Integer; SecondItemQty: Integer; var DiscountCode: Code[20]) DiscountAmount: Decimal
    var
        MixedDiscount: Record "NPR Mixed Discount";
    begin
        CreateTotalDiscountAmountHeader(MixedDiscount, TotalDiscountAmount, TotalAmountExclTax);
        MixedDiscount.Lot := true;
        CreateDiscountLineWithQty(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item, FirstItemQty);
        CreateDiscountLineWithQty(MixedDiscount, Item2, "NPR Disc. Grouping Type"::Item, SecondItemQty);
        DiscountCode := MixedDiscount.Code;
        MixedDiscount.Modify();
        DiscountAmount := MixedDiscount."Total Discount Amount";
    end;

    local procedure CreateDiscountLineWithQty(MixedDiscount: Record "NPR Mixed Discount"; Item: Record Item; DiscGroupType: Enum "NPR Disc. Grouping Type"; Quantity: Integer)
    var
        MixedDiscountLine: Record "NPR Mixed Discount Line";
    begin
        MixedDiscountLine.Code := MixedDiscount.Code;
        MixedDiscountLine."Disc. Grouping Type" := DiscGroupType;
        MixedDiscountLine."No." := Item."No.";
        MixedDiscountLine."Variant Code" := '';
        MixedDiscountLine.Init();
        MixedDiscountLine.Status := MixedDiscount.Status;
        MixedDiscountLine."Starting date" := MixedDiscount."Starting date";
        MixedDiscountLine.Quantity := Quantity;
        MixedDiscountLine."Ending Date" := MixedDiscount."Ending date";
        MixedDiscountLine.Insert();
    end;

    local procedure CreateMixDiscountTimeInterval(MixedDiscount: Record "NPR Mixed Discount"; var MixedDiscTimeInterv: Record "NPR Mixed Disc. Time Interv."; StartTime: Time; EndTime: Time)
    begin
        MixedDiscTimeInterv.Init();
        MixedDiscTimeInterv."Mix Code" := MixedDiscount.Code;
        MixedDiscTimeInterv."Line No." := 10000;
        MixedDiscTimeInterv."Start Time" := StartTime;
        MixedDiscTimeInterv."End Time" := EndTime;
        MixedDiscTimeInterv."Period Type" := MixedDiscTimeInterv."Period Type"::"Every Day";
        MixedDiscTimeInterv.Insert();
    end;

    local procedure GetDayAndSetToMixedDiscTimeInterval(var MixedDiscTimeInterv: Record "NPR Mixed Disc. Time Interv."; DayDirection: Option Today,Future,Past)
    var
        DayInteger: Integer;
        DaysOfWeek: Option Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday;
    begin
        MixedDiscTimeInterv."Period Type" := MixedDiscTimeInterv."Period Type"::Weekly;
        DayInteger := Date2DWY(Today(), 1) - 1;
        case DayDirection of
            DayDirection::Future:
                DayInteger := (DayInteger + 1) mod 7;
            DayDirection::Past:
                DayInteger := ((DayInteger + 6) mod 7);
        end;

        DaysOfWeek := DayInteger;
        case DaysOfWeek of
            DaysOfWeek::Monday:
                MixedDiscTimeInterv.Monday := true;
            DaysOfWeek::Tuesday:
                MixedDiscTimeInterv.Tuesday := true;
            DaysOfWeek::Wednesday:
                MixedDiscTimeInterv.Wednesday := true;
            DaysOfWeek::Thursday:
                MixedDiscTimeInterv.Thursday := true;
            DaysOfWeek::Friday:
                MixedDiscTimeInterv.Friday := true;
            DaysOfWeek::Saturday:
                MixedDiscTimeInterv.Saturday := true;
            DaysOfWeek::Sunday:
                MixedDiscTimeInterv.Sunday := true;
        end;
        MixedDiscTimeInterv.Modify(true);
    end;

    local procedure VerifyVATforGLEntry(POSEntry: Record "NPR POS Entry"; TaxArea: Record "Tax Area")
    var
        GLEntry: Record "G/L Entry";
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        TaxJurisdiction: Record "Tax Jurisdiction";
        TaxAreaLine: Record "Tax Area Line";
        GLSetup: Record "General Ledger Setup";
        POSSalesTax: Codeunit "NPR POS Sales Tax";
    begin
        TaxAreaLine.SetRange("Tax Area", TaxArea.Code);
        TaxAreaLine.FindFirst();
        TaxJurisdiction.Get(TaxAreaLine."Tax Jurisdiction Code");
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        GLEntry.SetRange("Posting Date", POSEntry."Posting Date");
        GLEntry.SetRange("G/L Account No.", TaxJurisdiction.GetSalesAccount(false));
        GLENtry.CalcSums(Amount);
        GLSetup.get();
        if POSSalesTax.NALocalizationEnabled() then begin
            if GLSetup."Summarize G/L Entries" then
                Assert.AreEqual(4, GLEntry.Count(), 'G/L Entries for Tax Jurisdiction account has not been created')
            else
                Assert.AreEqual(3, GLEntry.Count(), 'G/L Entries for Tax Jurisdiction account has not been created');
        end else begin
            Assert.AreEqual(4, GLEntry.Count(), 'G/L Entries for Tax Jurisdiction account has not been created');
        end;
        POSEntryTaxLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntryTaxLine.CalcSums("Tax Amount");
        Assert.AreEqual(3, POSEntryTaxLine.Count(), 'More then 3 POS Entry Tax Line has been posted');
        Assert.IsTrue(ABS(GLEntry.Amount + POSEntryTaxLine."Tax Amount") <= 0.01, 'GLEntry.Amount <> POSEntryTaxLine."Tax Amount"');
    end;

    local procedure VerifySalesforGLEntry(POSEntry: Record "NPR POS Entry"; GenBusPostingGroup: Code[20])
    var
        GLEntry: Record "G/L Entry";
        GeneralPostingSetup: Record "General Posting Setup";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        GLEntry.SetRange("Posting Date", POSEntry."Posting Date");
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Item);
        POSEntrySalesLine.FindSet();
        repeat
            GeneralPostingSetup.Get(GenBusPostingGroup, POSEntrySalesLine."Gen. Prod. Posting Group");
            GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Account");
            Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry for Sales account has not been created');
            Assert.AreEqual(POSEntrySalesLine."Amount Excl. VAT (LCY)" + POSEntrySalesLine."Line Discount Amount Excl. VAT", Abs(GLEntry.Amount), '(POSEntrySalesLine."Amount Excl. VAT (LCY)" + POSEntrySalesLine."Line Discount Amount Excl. VAT") <> GLEntry.Amount');
            Assert.AreEqual(0, Abs(GLEntry."VAT Amount"), '0 <> GLEntry."VAT Amount"');

            GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
            Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry for Sales account has not been created');
            Assert.AreEqual(POSEntrySalesLine."Line Discount Amount Excl. VAT", Abs(GLEntry.Amount), 'POSEntrySalesLine."Line Discount Amount Excl. VAT" <> GLEntry.Amount');
            Assert.AreEqual(0, Abs(GLEntry."VAT Amount"), '0 <> GLEntry."VAT Amount"');
        until POSEntrySalesLine.Next() = 0;
    end;

    local procedure CreateEmptyTaxPostingSetup()
    var
        TaxPostingSetup: Record "VAT Posting Setup";
    begin
        //we need this to be able to post sale to G/L Entry for Automatic VAT Entry
        //with unknown VAT Amount. VAT Amount later will be posted from POS Entry Tax Lines
        if not TaxPostingSetup.get('', '') then begin
            TaxPostingSetup."VAT Bus. Posting Group" := '';
            TaxPostingSetup."VAT Prod. Posting Group" := '';
            TaxPostingSetup.Init();
            TaxPostingSetup.Insert();
        end;
        TaxPostingSetup."VAT Calculation Type" := TaxPostingSetup."VAT Calculation Type"::"Sales Tax";
        TaxPostingSetup."Tax Category" := 'E';
        TaxPostingSetup.Modify();
    end;

    local procedure CreateDiscountGroup(): Code[10];
    var
        CustomerDiscountGroup: Record "Customer Discount Group";
        LibraryUtility: Codeunit "Library - Utility";
        CustomerDiscountGroupCode: Code[10];
        CustomerDiscountGroupDescriptionLbl: Label 'MixDiscAndTaxTests Description', Locked = true;
    begin
        CustomerDiscountGroupCode := LibraryUtility.GenerateRandomCode(CustomerDiscountGroup.FieldNo(Code), Database::"Customer Discount Group");
        if (not CustomerDiscountGroup.Get(CustomerDiscountGroupCode)) then begin
            CustomerDiscountGroup.Init();
            CustomerDiscountGroup.Code := CustomerDiscountGroupCode;
            CustomerDiscountGroup.Description := CustomerDiscountGroupDescriptionLbl;
            CustomerDiscountGroup.Insert();
        end;
        exit(CustomerDiscountGroup.Code);
    end;
}