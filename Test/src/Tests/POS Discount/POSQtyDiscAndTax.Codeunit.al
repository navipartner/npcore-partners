codeunit 85034 "NPR POS Qty. Disc. and Tax"
{
    // [Feature] POS Quantity Discount
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, LibraryRandom.RandDecInRange(1, 100, 5), QuantityDiscountLine);

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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 9, QuantityDiscountLine);

        //Item price includes tax and active sale line include tax
        Qty := 2;
        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtInclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Quantity, 'Quantity Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Qty * Item."Unit Price" * LineDiscPct / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * LineDiscPct / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Qty * Item."Unit Price" - (Qty * Item."Unit Price" * LineDiscPct / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine."Amount Including VAT"');
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 7, QuantityDiscountLine);

        //Item price includes tax and active sale line excludes tax
        Item."Unit Price" := Item."Unit Price" / (1 + VATPostingSetup."VAT %" / 100);
        Qty := 2;
        LineDiscPct := 100 - (QuantityDiscountLine."Unit Price" / (Item."Unit Price" * (100 + VATPostingSetup."VAT %") / 100) * 100);
        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtExclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax * (1 + VATPostingSetup."VAT %" / 100);

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
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Quantity, 'Quantity Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(Round(LineDiscPct), Round(POSSaleLine."Discount %"), 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), Round(POSSaleLine."Discount Amount"), '((Qty * Item."Unit Price" * LineDiscPct / 100) / (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), Round(POSSaleLine."Amount Including VAT"), '((Qty * Item."Unit Price" - (Qty * Item."Unit Price" * LineDiscPct / 100)) * (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), Round(POSSaleLine.Amount), '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * LineDiscPct / 100))  <> POSSaleLine."Amount Including VAT"');
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 7, QuantityDiscountLine);

        //Item price includes tax and active sale line price includes tax
        Qty := 2;
        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtInclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

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
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Quantity, 'Quantity Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Item."Unit Price" * LineDiscPct / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * LineDiscPct / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Qty * Item."Unit Price" - (Qty * Item."Unit Price" * LineDiscPct / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine."Amount Including VAT"');
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 9, QuantityDiscountLine);

        //Item price includes tax and active sale line price includes tax
        Qty := 2;
        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtInclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

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
        Assert.AreEqual(Qty * Item."Unit Price", -(GLEntry.Amount + GLEntry."VAT Amount"), '(Qty * Item."Unit Price") <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Qty * Item."Unit Price" * LineDiscPct / 100) <> GLEntry.Amount');
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 9, QuantityDiscountLine);

        //Item price includes tax and active sale line price includes tax
        Qty := Round(2 + 2 / 3, 0.00001);
        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;
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
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Qty * Item."Unit Price" * LineDiscPct / 100) <> GLEntry.Amount');
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 7, QuantityDiscountLine);

        //Item price includes tax and active sale line price excludes tax
        Qty := 2;
        Item."Unit Price" := Item."Unit Price" / (1 + VATPostingSetup."VAT %" / 100);
        LineDiscPct := 100 - (QuantityDiscountLine."Unit Price" / (Item."Unit Price" * (100 + VATPostingSetup."VAT %") / 100) * 100);
        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtExclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax * (1 + VATPostingSetup."VAT %" / 100);

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
        Assert.AreEqual(Round(Qty * Item."Unit Price" * (1 + VATPostingSetup."VAT %" / 100)), -(GLEntry.Amount + GLEntry."VAT Amount"), '(Qty * Item."Unit Price") <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(Round(LineDiscAmt * (1 + VATPostingSetup."VAT %" / 100)), GLEntry.Amount + GLEntry."VAT Amount", '(Qty * Item."Unit Price" * LineDiscPct / 100) <> (GLEntry.Amount + GLEntry."VAT Amount")');
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 7, QuantityDiscountLine);

        //Item price includes tax and active sale line price excludes tax
        Qty := Round(2 + 3 / 8, 0.00001);
        Item."Unit Price" := Item."Unit Price" / (1 + VATPostingSetup."VAT %" / 100);
        LineDiscPct := 100 - (QuantityDiscountLine."Unit Price" / (Item."Unit Price" * (100 + VATPostingSetup."VAT %") / 100) * 100);
        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtExclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax * (1 + VATPostingSetup."VAT %" / 100);

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
        Assert.AreEqual(Round(Qty * Item."Unit Price" * (1 + VATPostingSetup."VAT %" / 100), 0.01, '<'), -(GLEntry.Amount + GLEntry."VAT Amount"), '(Qty * Item."Unit Price") <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(Round(LineDiscAmt * (1 + VATPostingSetup."VAT %" / 100)), GLEntry.Amount + GLEntry."VAT Amount", '(Qty * Item."Unit Price" * LineDiscPct / 100) <> (GLEntry.Amount + GLEntry."VAT Amount")');
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 7, QuantityDiscountLine);

        //Item price includes tax and active sale line price excludes tax
        Qty := 2;
        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtInclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

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
        Assert.AreEqual(POSSaleLine."Discount Amount", POSEntrySalesLine."Line Discount Amount Incl. VAT", 'POSSaleLine."Discount Amount" <> POSEntrySalesLine."Line Discount Amount Incl. VAT"');
        Assert.AreEqual(POSSaleLine.Amount, POSEntrySalesLine."Amount Excl. VAT", 'POSSaleLine.Amount <> POSEntrySalesLine."Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", POSEntrySalesLine."Amount Incl. VAT", 'POSSaleLine."Amount Including VAT" <> POSEntrySalesLine."Amount Incl. VAT"');
        Assert.IsTrue(GeneralPostingSetup.Get(POSSaleLine."Gen. Bus. Posting Group", POSSaleLine."Gen. Prod. Posting Group"), 'General Posting Setup not found');

        //Verify G/L Entry
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        GLEntry.SetRange("Posting Date", POSEntry."Posting Date");
        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Account');
        Assert.AreEqual(Qty * Item."Unit Price", -(GLEntry.Amount + GLEntry."VAT Amount"), '(Qty * Item."Unit Price") <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Qty * Item."Unit Price" * LineDiscPct / 100) <> GLEntry.Amount');
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 7, QuantityDiscountLine);

        //Item price includes tax and active sale line price excludes tax
        Qty := Round(2 + 1 / 3, 0.00001);
        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;
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
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Qty * Item."Unit Price" * LineDiscPct / 100) <> GLEntry.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForRevChrgTaxInDirectSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 9, QuantityDiscountLine);

        //Item price includes tax and active sale line price includes tax
        Qty := 2;
        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtInclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Quantity, 'Quantity Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Qty * Item."Unit Price" * LineDiscPct / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * LineDiscPct / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Qty * Item."Unit Price" - (Qty * Item."Unit Price" * LineDiscPct / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine."Amount Including VAT"');
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 7, QuantityDiscountLine);

        //Item price includes tax and active sale line price excludes tax
        Item."Unit Price" := Item."Unit Price" / (1 + VATPostingSetup."VAT %" / 100);
        Qty := 2;
        LineDiscPct := 100 - (QuantityDiscountLine."Unit Price" / (Item."Unit Price" * (100 + VATPostingSetup."VAT %") / 100) * 100);
        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtExclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax * (1 + VATPostingSetup."VAT %" / 100);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        POSSaleUnit.GetCurrentSale(POSSale);
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Quantity, 'Quantity Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(Round(LineDiscPct), Round(POSSaleLine."Discount %"), 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), Round(POSSaleLine."Discount Amount"), '((Qty * Item."Unit Price" * LineDiscPct / 100) / (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), Round(POSSaleLine."Amount Including VAT"), '((Qty * Item."Unit Price" - (Qty * Item."Unit Price" * LineDiscPct / 100)) * (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), Round(POSSaleLine.Amount), '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * LineDiscPct / 100))  <> POSSaleLine."Amount Including VAT"');
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 7, QuantityDiscountLine);

        //Item price includes tax and active sale line price includes tax
        Qty := 2;
        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtInclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

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
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Quantity, 'Quantity Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Qty * Item."Unit Price" * LineDiscPct / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * LineDiscPct / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Qty * Item."Unit Price" - (Qty * Item."Unit Price" * LineDiscPct / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine."Amount Including VAT"');
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 9, QuantityDiscountLine);

        //Item price includes tax and active sale line price includes tax
        Qty := 2;
        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtInclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

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
        Assert.AreEqual(Qty * Item."Unit Price", -(GLEntry.Amount + GLEntry."VAT Amount"), '(Qty * Item."Unit Price") <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * LineDiscPct / 100) <> GLEntry.Amount');
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 7, QuantityDiscountLine);

        //Item price includes tax and active sale line price excludes tax
        Qty := 2;
        LineDiscPct := 100 - (QuantityDiscountLine."Unit Price" / (Item."Unit Price" * (100 + VATPostingSetup."VAT %") / 100) * 100);
        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtExclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtInclTax := LineAmtInclTax * (1 + VATPostingSetup."VAT %" / 100);

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
        Assert.AreEqual(Qty * Item."Unit Price", -(GLEntry.Amount + GLEntry."VAT Amount"), '(Qty * Item."Unit Price") <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * LineDiscPct / 100) <> GLEntry.Amount');
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 7, QuantityDiscountLine);

        //Item price includes tax and active sale line price includes tax
        Qty := 2;
        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtInclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

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
        Assert.AreEqual(POSSaleLine."Discount Amount", POSEntrySalesLine."Line Discount Amount Incl. VAT", 'POSSaleLine."Discount Amount" <> POSEntrySalesLine."Line Discount Amount Incl. VAT"');
        Assert.AreEqual(POSSaleLine.Amount, POSEntrySalesLine."Amount Excl. VAT", 'POSSaleLine.Amount <> POSEntrySalesLine."Amount Excl. VAT"');
        Assert.AreEqual(POSSaleLine."Amount Including VAT", POSEntrySalesLine."Amount Incl. VAT", 'POSSaleLine."Amount Including VAT" <> POSEntrySalesLine."Amount Incl. VAT"');
        Assert.IsTrue(GeneralPostingSetup.Get(POSSaleLine."Gen. Bus. Posting Group", POSSaleLine."Gen. Prod. Posting Group"), 'General Posting Setup not found');

        //Verify G/L Entry
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        GLEntry.SetRange("Posting Date", POSEntry."Posting Date");
        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Account');
        Assert.AreEqual(Qty * Item."Unit Price", -(GLEntry.Amount + GLEntry."VAT Amount"), '(Qty * Item."Unit Price") <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * LineDiscPct / 100) <> GLEntry.Amount');
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        UnitPriceTaxable: Decimal;
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
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignTaxDetailToPOSPostingProfile(TaxArea.Code, true);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Discount
        CreateDiscount(Item, 9, QuantityDiscountLine);

        //Item price excludes tax and active sale line price excludes tax
        Qty := 2;
        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;

        UnitPriceTaxable := Item."Unit Price" * (1 - LineDiscPct / 100);
        TotalTax := Qty * (Round(UnitPriceTaxable * CityTaxRate / 100) +
                           Round(UnitPriceTaxable * CountyTaxRate / 100) +
                           Round(UnitPriceTaxable * StateTaxRate / 100));

        LineAmtExclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax + TotalTax;

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Quantity, 'Quantity Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Item."Unit Price" * LineDiscPct / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * LineDiscPct / 100)) <> POSSaleLine.Amount');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * LineDiscPct / 100)) + TotalTax <> POSSaleLine."Amount Including VAT"');
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        UnitPriceTaxable: Decimal;
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
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignTaxDetailToPOSPostingProfile(TaxArea.Code, true);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Discount
        CreateDiscount(Item, 9, QuantityDiscountLine);

        //Item price excludes tax and active sale line price excludes tax
        Qty := Round(2 + 7 / 8, 0.00001);
        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;

        UnitPriceTaxable := Item."Unit Price" * (1 - LineDiscPct / 100);
        TotalTax := Round(Qty * UnitPriceTaxable * CityTaxRate / 100) +
                           Round(Qty * UnitPriceTaxable * CountyTaxRate / 100) +
                           Round(Qty * UnitPriceTaxable * StateTaxRate / 100);

        LineAmtExclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax + TotalTax;

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Quantity, 'Quantity Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Item."Unit Price" * LineDiscPct / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * LineDiscPct / 100)) <> POSSaleLine.Amount');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * LineDiscPct / 100)) + TotalTax <> POSSaleLine."Amount Including VAT"');
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 7, QuantityDiscountLine);

        //Item price excludes tax and active sale line price excludes tax
        Qty := 2;
        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;

        UnitPriceTaxable := Item."Unit Price" * (1 - LineDiscPct / 100);
        TotalTax := Qty * (Round(UnitPriceTaxable * CityTaxRate / 100) +
                           Round(UnitPriceTaxable * CountyTaxRate / 100) +
                           Round(UnitPriceTaxable * StateTaxRate / 100));
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
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Quantity, 'Quantity Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Qty * Item."Unit Price" * LineDiscPct / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * LineDiscPct / 100))  <> POSSaleLine.Amount');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * LineDiscPct / 100)) + TotalTax <> POSSaleLine."Amount Including VAT"');
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 7, QuantityDiscountLine);

        //Item price excludes tax and active sale line price excludes tax
        Qty := Round(2 + 3 / 8, 0.00001);
        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;

        UnitPriceTaxable := Item."Unit Price" * (1 - LineDiscPct / 100);
        TotalTax := Round(Qty * UnitPriceTaxable * CityTaxRate / 100) +
                           Round(Qty * UnitPriceTaxable * CountyTaxRate / 100) +
                           Round(Qty * UnitPriceTaxable * StateTaxRate / 100);
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
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Quantity, 'Quantity Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Qty * Item."Unit Price" * LineDiscPct / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * LineDiscPct / 100))  <> POSSaleLine.Amount');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * LineDiscPct / 100)) + TotalTax <> POSSaleLine."Amount Including VAT"');
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 9, QuantityDiscountLine);

        //Item price excludes tax and active sale line price excludes tax
        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;
        Qty := 2;
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 9, QuantityDiscountLine);

        //Item price excludes tax and active sale line price excludes tax
        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;
        Qty := Round(2 + 7 / 8, 0.00001);
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 7, QuantityDiscountLine);

        //Item price excludes tax and active sale line price excludes tax
        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;
        Qty := 2;
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 7, QuantityDiscountLine);

        //Item price excludes tax and active sale line price excludes tax
        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;
        Qty := Round(2 + 3 / 8, 0.00001);
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, LibraryRandom.RandDecInRange(1, 100, 5), QuantityDiscountLine);

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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 9, QuantityDiscountLine);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);


        // [GIVEN] Add Item to active sale
        Qty := 2;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [WHEN] Quantity changed
        Qty := 3;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        //Item price includes tax and active sale line price includes tax
        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtInclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Quantity, 'Quantity Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Item."Unit Price" * LineDiscPct / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine.Amount');
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 7, QuantityDiscountLine);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 2;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [WHEN] Quantity changed
        Qty := 3;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        //Item price includes tax and active sale line price excludes tax
        Item."Unit Price" := Item."Unit Price" / (1 + VATPostingSetup."VAT %" / 100);
        LineDiscPct := 100 - (QuantityDiscountLine."Unit Price" / (Item."Unit Price" * (100 + VATPostingSetup."VAT %") / 100) * 100);
        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtExclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax * (1 + VATPostingSetup."VAT %" / 100);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Quantity, 'Quantity Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(Round(LineDiscPct), Round(POSSaleLine."Discount %"), 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), Round(POSSaleLine."Discount Amount"), '((Item."Unit Price" * LineDiscPct / 100) / (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), Round(POSSaleLine."Amount Including VAT"), '((Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100)) * (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), Round(POSSaleLine.Amount), '(Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100))  <> POSSaleLine.Amount');
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 7, QuantityDiscountLine);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 2;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [WHEN] Quantity changed
        Qty := 3;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        //Item price includes tax and active sale line price includes tax
        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtInclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Quantity, 'Quantity Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Item."Unit Price" * LineDiscPct / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine.Amount');
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 7, QuantityDiscountLine);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Add Item to active sale
        Qty := 2;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Quantity changed
        Qty := 3;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        //Item price includes tax and active sale line price includes tax
        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;
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
        Assert.AreEqual(Qty * Item."Unit Price", -(GLEntry.Amount + GLEntry."VAT Amount"), '(Qty * Item."Unit Price") <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * LineDiscPct / 100) <> GLEntry.Amount');
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 7, QuantityDiscountLine);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 2;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Quantity changed
        Qty := 3;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        //Item price includes tax and active sale line price excludes tax
        Item."Unit Price" := Item."Unit Price" / (1 + VATPostingSetup."VAT %" / 100);
        LineDiscPct := 100 - (QuantityDiscountLine."Unit Price" / (Item."Unit Price" * (100 + VATPostingSetup."VAT %") / 100) * 100);
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
        Assert.AreEqual(Round(Qty * Item."Unit Price" * (1 + VATPostingSetup."VAT %" / 100)), -(GLEntry.Amount + GLEntry."VAT Amount"), '(Qty * Item."Unit Price") <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(Round(LineDiscAmt * (1 + VATPostingSetup."VAT %" / 100)), GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * LineDiscPct / 100) <> (GLEntry.Amount + GLEntry."VAT Amount"))');
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 7, QuantityDiscountLine);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 2;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Quantity changed
        Qty := 3;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        //Item price includes tax and active sale line price includes tax
        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;
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
        Assert.AreEqual(Qty * Item."Unit Price", -(GLEntry.Amount + GLEntry."VAT Amount"), '(Qty * Item."Unit Price") <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * LineDiscPct / 100) <> GLEntry.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ApplyDiscountWhenPOSSaleLineUpdatedQtyForRevChrgTaxInDirectSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 9, QuantityDiscountLine);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Add Item to active sale
        Qty := 2;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [WHEN] Quantity changed
        Qty := 3;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        //Item price includes tax and active sale line price includes tax
        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtInclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Quantity, 'Quantity Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Item."Unit Price" * LineDiscPct / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine.Amount');
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 7, QuantityDiscountLine);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 2;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [WHEN] Quantity changed
        Qty := 3;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        //Item price includes tax and active sale line price excludes tax
        LineDiscPct := 100 - (QuantityDiscountLine."Unit Price" / (Item."Unit Price" * (100 + VATPostingSetup."VAT %") / 100) * 100);
        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtExclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax * (1 + VATPostingSetup."VAT %" / 100);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Quantity, 'Quantity Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '((Item."Unit Price" * LineDiscPct / 100) / (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '((Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100)) * (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '(Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100))  <> POSSaleLine.Amount');
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 7, QuantityDiscountLine);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 2;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [WHEN] Quantity changed
        Qty := 3;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        //Item price includes tax and active sale line price includes tax
        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtInclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Quantity, 'Quantity Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Item."Unit Price" * LineDiscPct / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Item."Unit Price" - (Item."Unit Price" * LineDiscPct / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine.Amount');
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 9, QuantityDiscountLine);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Add Item to active sale
        Qty := 2;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Quantity changed
        Qty := 3;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        //Item price includes tax and active sale line price includes tax
        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;
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
        Assert.AreEqual(Qty * Item."Unit Price", -(GLEntry.Amount + GLEntry."VAT Amount"), '(Qty * Item."Unit Price") <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * LineDiscPct / 100) <> GLEntry.Amount');
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 7, QuantityDiscountLine);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 2;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Quantity changed
        Qty := 3;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        //Item price includes tax and active sale line price excludes tax
        LineDiscPct := 100 - (QuantityDiscountLine."Unit Price" / (Item."Unit Price" * (100 + VATPostingSetup."VAT %") / 100) * 100);
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
        Assert.AreEqual(Qty * Item."Unit Price", -(GLEntry.Amount + GLEntry."VAT Amount"), '(Qty * Item."Unit Price") <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * LineDiscPct / 100) <> GLEntry.Amount');
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 7, QuantityDiscountLine);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 2;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Quantity changed
        Qty := 3;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        //Item price includes tax and active sale line price includes tax
        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;
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
        Assert.AreEqual(Qty * Item."Unit Price", -(GLEntry.Amount + GLEntry."VAT Amount"), '(Qty * Item."Unit Price") <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * LineDiscPct / 100) <> GLEntry.Amount');
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 9, QuantityDiscountLine);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Add Item to active sale
        Qty := 2;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [WHEN] Quantity changed
        Qty := 3;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        //Item price excludes tax and active sale line price excludes tax
        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;

        UnitPriceTaxable := Item."Unit Price" * (1 - LineDiscPct / 100);
        TotalTax := Qty * (Round(UnitPriceTaxable * CityTaxRate / 100) +
                   Round(UnitPriceTaxable * CountyTaxRate / 100) +
                   Round(UnitPriceTaxable * StateTaxRate / 100));
        LineAmtExclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax + TotalTax;

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Quantity, 'Quantity Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Qty * Item."Unit Price" * LineDiscPct / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * LineDiscPct / 100)) <> POSSaleLine.Amount');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * LineDiscPct / 100)) + TotalTax <> POSSaleLine."Amount Including VAT"');
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 7, QuantityDiscountLine);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 2;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [WHEN] Quantity changed
        Qty := 3;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        //Item price excludes tax and active sale line price excludes tax
        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;

        UnitPriceTaxable := Item."Unit Price" * (1 - LineDiscPct / 100);
        TotalTax := Qty * (UnitPriceTaxable * CityTaxRate / 100 +
                           UnitPriceTaxable * CountyTaxRate / 100 +
                           UnitPriceTaxable * StateTaxRate / 100);

        LineAmtExclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax + TotalTax;

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Quantity, 'Quantity Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(Round(LineDiscPct), Round(POSSaleLine."Discount %"), 'LineDiscPct <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), Round(POSSaleLine."Discount Amount"), '(Qty * Item."Unit Price" * LineDiscPct / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtExclTax), Round(POSSaleLine.Amount), '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * LineDiscPct / 100))  <> POSSaleLine.Amount');
        Assert.AreEqual(Round(LineAmtInclTax), Round(POSSaleLine."Amount Including VAT"), '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * LineDiscPct / 100)) + TotalTax <> POSSaleLine."Amount Including VAT"');
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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 9, QuantityDiscountLine);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Add Item to active sale
        Qty := 2;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Quantity changed
        Qty := 3;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        //Item price excludes tax and active sale line price excludes tax
        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;

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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 7, QuantityDiscountLine);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSale, '', 0, Customer."No.", false);

        // [GIVEN] Add Item to active sale
        Qty := 2;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Quantity changed
        Qty := 3;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        //Item price excludes tax and active sale line price excludes tax
        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;

        UnitPriceTaxable := Item."Unit Price" * (1 - LineDiscPct / 100);
        TotalTax := Qty * (UnitPriceTaxable * CityTaxRate / 100 +
                           UnitPriceTaxable * CountyTaxRate / 100 +
                           UnitPriceTaxable * StateTaxRate / 100);

        LineAmtInclTax := UnitPriceTaxable * Qty + TotalTax;

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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, LibraryRandom.RandDecInRange(1, 100, 5), QuantityDiscountLine);

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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 9, QuantityDiscountLine);

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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 7, QuantityDiscountLine);

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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 7, QuantityDiscountLine);

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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 9, QuantityDiscountLine);

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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 7, QuantityDiscountLine);

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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 7, QuantityDiscountLine);

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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 9, QuantityDiscountLine);

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
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
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
        CreateDiscount(Item, 7, QuantityDiscountLine);

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
        exit(DATABASE::"NPR Quantity Discount Header");
    end;

    internal procedure CreateDiscount(Item: Record Item; DiscPct: Decimal; var QuantityDiscountLine: Record "NPR Quantity Discount Line")
    var
        QuantityDiscountHeader: Record "NPR Quantity Discount Header";
    begin
        CreateDiscountHeader(QuantityDiscountHeader, Item);
        CreateDiscountLine(QuantityDiscountHeader, (100 - DiscPct) / 100 * Item."Unit Price", QuantityDiscountLine);
    end;

    local procedure CreateDiscountHeader(var QuantityDiscountHeader: Record "NPR Quantity Discount Header"; Item: Record Item)
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        QuantityDiscountHeader."Item No." := Item."No.";
        QuantityDiscountHeader."Main No." := LibraryUtility.GenerateRandomCode(QuantityDiscountHeader.FieldNo("Main No."), DiscSourceTableId());
        QuantityDiscountHeader.Init();
        QuantityDiscountHeader.Status := QuantityDiscountHeader.Status::Active;
        QuantityDiscountHeader."Starting date" := Today() - 7;
        QuantityDiscountHeader."Closing date" := Today() + 7;
        QuantityDiscountHeader.Insert();
    end;

    local procedure CreateDiscountLine(QuantityDiscountHeader: Record "NPR Quantity Discount Header"; UnitPrice: Decimal; var QuantityDiscountLine: Record "NPR Quantity Discount Line")
    begin
        QuantityDiscountLine."Item No." := QuantityDiscountHeader."Item No.";
        QuantityDiscountLine."Main no." := QuantityDiscountHeader."Main No.";
        QuantityDiscountLine.Quantity := 2;
        QuantityDiscountLine.Init();
        QuantityDiscountLine.Validate("Unit Price", UnitPrice);
        QuantityDiscountLine.Insert();
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
}