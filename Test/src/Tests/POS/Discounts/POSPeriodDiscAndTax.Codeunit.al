codeunit 85033 "NPR POS Period Disc. and Tax"
{
    // [Feature] POS Periodic Discount
    Subtype = Test;
    EventSubscriberInstance = Manual;

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
    procedure RelevantDiscountsFoundForDMLInsert()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        xPOSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        TempDiscountPriority: Record "NPR Discount Priority" temporary;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        PeriodDiscountLine: Record "NPR Period Discount Line";
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
        CreateDiscount(Item, LibraryRandom.RandDecInRange(1, 100, 5), PeriodDiscountLine);

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
    procedure ApplyDiscountWhenPOSSaleLineCreatedForNormalTaxInDirectSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        PeriodDiscountLine: Record "NPR Period Discount Line";
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        POSActiveTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
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
        CreateDiscount(Item, 9, PeriodDiscountLine);

        LineDiscPct := 100 - PeriodDiscountLine."Campaign Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := PeriodDiscountLine."Discount Amount";
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
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Campaign, 'Campaign Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'PeriodLineDiscountLine."Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine."Amount Including VAT"');

        POSActiveTaxCalc.Find(POSSaleTax, POSSaleLine.SystemId);
        POSActiveTaxCalc.FilterLines(POSSaleTax, POSSaleTaxLine);
        Assert.IsTrue(POSSaleTaxLine.FindFirst(), 'Active Sale Tax Line not created');

        Assert.AreEqual(Round(LineAmtInclTax), POSSaleTaxLine."Amount Incl. Tax", '(Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100)) <> POSSaleTaxLine."Amount Incl. Tax" for sale line %1');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleTaxLine."Amount Excl. Tax", '((Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleTaxLine."Amount Incl. Tax" for sale line %1');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForNormalTaxInDirectSaleMultiLinesSameItem()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        PeriodDiscountLine: Record "NPR Period Discount Line";
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        POSActiveTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        COD: codeunit "NPR POS Normal Tax Backward";
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
        Item."Unit Price" := 250;
        Item.Modify();

        // [GIVEN] Discount
        CreateDiscount(Item, 22.02, PeriodDiscountLine);

        LineDiscPct := 100 - PeriodDiscountLine."Campaign Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := PeriodDiscountLine."Discount Amount";
        LineAmtInclTax := Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        POSSaleUnit.GetCurrentSale(POSSale);
        POSSaleLine.SetRange("Register No.", POSSale."Register No.");
        POSSaleLine.SetRange("Sales Ticket No.", POSSale."Sales Ticket No.");
        POSSaleLine.SetRange("Sale Type", POSSaleLine."Sale Type"::Sale);
        Assert.IsTrue(POSSaleLine.FindSet(), 'Active Sale Line not created');
        repeat
            Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
            Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Campaign, 'Campaign Discount not applied to POS Sale Line');
            Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
            Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'PeriodLineDiscountLine."Discount %" <> POSSaleLine."Discount %"');
            Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100) <> POSSaleLine."Discount Amount"');
            Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100)) <> POSSaleLine."Amount Including VAT"');
            Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine."Amount Including VAT"');

            POSActiveTaxCalc.Find(POSSaleTax, POSSaleLine.SystemId);
            POSActiveTaxCalc.FilterLines(POSSaleTax, POSSaleTaxLine);
            Assert.AreEqual(1, POSSaleTaxLine.Count(), 'Multiple tax line attached to one active sale line for Normal VAT Calculation');
            Assert.IsTrue(POSSaleTaxLine.FindFirst(), 'Active Sale Tax Line not created');

            Assert.AreEqual(Round(LineAmtInclTax), POSSaleTaxLine."Amount Incl. Tax", StrSubstNo('(Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100)) <> POSSaleTaxLine."Amount Incl. Tax" for sale line %1', POSSAleLine."Line No."));
            Assert.AreEqual(Round(LineAmtExclTax), POSSaleTaxLine."Amount Excl. Tax", StrSubstNo('((Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleTaxLine."Amount Incl. Tax" for sale line %1', POSSaleLine."Line No."));
        until POSSaleLine.Next() = 0;
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForNormalTaxInDirectSaleMultiLinesDiffItem()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Array[2] of Record Item;
        PeriodDiscountLine: Record "NPR Period Discount Line";
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        POSActiveTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        COD: codeunit "NPR POS Normal Tax Backward";
        LineDiscPct: Array[2] of Decimal;
        LineDiscAmt: Array[2] of Decimal;
        LineAmtInclTax: Array[2] of Decimal;
        LineAmtExclTax: Array[2] of Decimal;
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
        CreateItem(Item[1], VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item[1]."Unit Price" := 250;
        Item[1].Modify();

        CreateItem(Item[2], VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item[2]."Unit Price" := 250;
        Item[2].Modify();

        // [GIVEN] Discount
        CreateDiscount(Item[1], 22.02, PeriodDiscountLine);
        CreateDiscount(Item[2], 22.02, PeriodDiscountLine);

        LineDiscPct[1] := 100 - PeriodDiscountLine."Campaign Unit Price" / Item[1]."Unit Price" * 100;
        LineDiscAmt[1] := PeriodDiscountLine."Discount Amount";
        LineAmtInclTax[1] := Item[1]."Unit Price" - LineDiscAmt[1];
        LineAmtExclTax[1] := LineAmtInclTax[1] / (1 + VATPostingSetup."VAT %" / 100);

        LineDiscPct[2] := 100 - PeriodDiscountLine."Campaign Unit Price" / Item[2]."Unit Price" * 100;
        LineDiscAmt[2] := PeriodDiscountLine."Discount Amount";
        LineAmtInclTax[2] := Item[2]."Unit Price" - LineDiscAmt[2];
        LineAmtExclTax[2] := LineAmtInclTax[2] / (1 + VATPostingSetup."VAT %" / 100);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item[1]."No.", 1);
        LibraryPOSMock.CreateItemLine(POSSession, Item[2]."No.", 1);

        // [THEN] Verify Discount applied
        POSSaleUnit.GetCurrentSale(POSSale);

        POSSaleLine.SetRange("Register No.", POSSale."Register No.");
        POSSaleLine.SetRange("Sales Ticket No.", POSSale."Sales Ticket No.");
        POSSaleLine.SetRange("Sale Type", POSSaleLine."Sale Type"::Sale);
        Assert.IsTrue(POSSaleLine.FindFirst(), 'Active Sale Line not created');

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed to first active sale line');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Campaign, 'Campaign Discount not applied to POS Sale Line to first active sale line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line to first active sale line');
        Assert.AreEqual(LineDiscPct[1], POSSaleLine."Discount %", 'PeriodLineDiscountLine."Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt[1]), POSSaleLine."Discount Amount", '(Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax[1]), POSSaleLine."Amount Including VAT", '(Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax[1]), POSSaleLine.Amount, '((Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine."Amount Including VAT"');

        POSActiveTaxCalc.Find(POSSaleTax, POSSaleLine.SystemId);
        POSActiveTaxCalc.FilterLines(POSSaleTax, POSSaleTaxLine);
        Assert.AreEqual(1, POSSaleTaxLine.Count(), 'Multiple tax line attached to first active sale line for Normal VAT Calculation');
        Assert.IsTrue(POSSaleTaxLine.FindFirst(), 'Active Sale Tax Line not created');

        Assert.AreEqual(Round(LineAmtInclTax[1]), POSSaleTaxLine."Amount Incl. Tax", StrSubstNo('(Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100)) <> POSSaleTaxLine."Amount Incl. Tax" for sale line %1', POSSAleLine."Line No."));
        Assert.AreEqual(Round(LineAmtExclTax[1]), POSSaleTaxLine."Amount Excl. Tax", StrSubstNo('((Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleTaxLine."Amount Incl. Tax" for sale line %1', POSSaleLine."Line No."));

        Assert.IsTrue(POSSaleLine.FindLast(), 'Active Sale Line not created');

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed to first active sale line');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Campaign, 'Campaign Discount not applied to POS Sale Line to first active sale line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line to first active sale line');
        Assert.AreEqual(LineDiscPct[2], POSSaleLine."Discount %", 'PeriodLineDiscountLine."Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt[2]), POSSaleLine."Discount Amount", '(Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax[2]), POSSaleLine."Amount Including VAT", '(Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax[2]), POSSaleLine.Amount, '((Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine."Amount Including VAT"');

        POSActiveTaxCalc.Find(POSSaleTax, POSSaleLine.SystemId);
        POSActiveTaxCalc.FilterLines(POSSaleTax, POSSaleTaxLine);
        Assert.AreEqual(1, POSSaleTaxLine.Count(), 'Multiple tax line attached to second active sale line for Normal VAT Calculation');
        Assert.IsTrue(POSSaleTaxLine.FindFirst(), 'Active Sale Tax Line not created');

        Assert.AreEqual(Round(LineAmtInclTax[2]), POSSaleTaxLine."Amount Incl. Tax", StrSubstNo('(Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100)) <> POSSaleTaxLine."Amount Incl. Tax" for sale line %1', POSSAleLine."Line No."));
        Assert.AreEqual(Round(LineAmtExclTax[2]), POSSaleTaxLine."Amount Excl. Tax", StrSubstNo('((Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleTaxLine."Amount Incl. Tax" for sale line %1', POSSaleLine."Line No."));
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForNormalTaxInDebitSaleForward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        PeriodDiscountLine: Record "NPR Period Discount Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
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
        CreateDiscount(Item, 7, PeriodDiscountLine);

        Item."Unit Price" := Item."Unit Price" / (1 + VATPostingSetup."VAT %" / 100);
        PeriodDiscountLine."Campaign Unit Price" := PeriodDiscountLine."Campaign Unit Price" / (1 + VATPostingSetup."VAT %" / 100);
        LineDiscPct := 100 - PeriodDiscountLine."Campaign Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := Item."Unit Price" * LineDiscPct / 100;
        LineAmtExclTax := Item."Unit Price" - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax * (1 + VATPostingSetup."VAT %" / 100);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Campaign, 'Campaign Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(Round(LineDiscPct), Round(POSSaleLine."Discount %"), '100 - PeriodDiscountLine."Campaign Unit Price" / Item."Unit Price" * 100 <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), Round(POSSaleLine."Discount Amount"), 'PeriodDiscountLine."Discount Amount" <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), Round(POSSaleLine."Amount Including VAT"), '((Item."Unit Price" - (Item."Unit Price" * (100 - PeriodDiscountLine."Campaign Unit Price" / Item."Unit Price" * 100) / 100)) * (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), Round(POSSaleLine.Amount), '(Item."Unit Price" - (Item."Unit Price" * (100 - PeriodDiscountLine."Campaign Unit Price" / Item."Unit Price" * 100) / 100))  <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForNormalTaxInDebitSaleBackward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        PeriodDiscountLine: Record "NPR Period Discount Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
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
        CreateDiscount(Item, 7, PeriodDiscountLine);

        LineDiscPct := 100 - PeriodDiscountLine."Campaign Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := PeriodDiscountLine."Discount Amount";
        LineAmtInclTax := Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Campaign, 'Campaign Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'PeriodLineDiscountLine."Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
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
        PeriodDiscountLine: Record "NPR Period Discount Line";
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
        CreateDiscount(Item, 9, PeriodDiscountLine);

        LineDiscPct := 100 - PeriodDiscountLine."Campaign Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := PeriodDiscountLine."Discount Amount";
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
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100) <> GLEntry.Amount');
    end;

    [Test]
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
        PeriodDiscountLine: Record "NPR Period Discount Line";
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
        CreateDiscount(Item, 9, PeriodDiscountLine);

        Qty := Round(1 + 1 / 3, 0.00001);
        LineDiscPct := 100 - PeriodDiscountLine."Campaign Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := Round(Qty * PeriodDiscountLine."Discount Amount");
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
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Qty * Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100) <> GLEntry.Amount');
    end;

    [Test]
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
        PeriodDiscountLine: Record "NPR Period Discount Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
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
        CreateDiscount(Item, 7, PeriodDiscountLine);

        LineDiscPct := 100 - PeriodDiscountLine."Campaign Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := PeriodDiscountLine."Discount Amount";
        LineAmtExclTax := Item."Unit Price" - LineDiscAmt;
        LineAmtInclTax := LineAmtInclTax * (1 + VATPostingSetup."VAT %" / 100);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

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
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100) <> GLEntry.Amount');
    end;

    [Test]
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
        PeriodDiscountLine: Record "NPR Period Discount Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
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
        CreateDiscount(Item, 7, PeriodDiscountLine);

        Qty := Round(1 + 1 / 3, 0.00001);
        LineDiscPct := 100 - PeriodDiscountLine."Campaign Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := Round(Qty * PeriodDiscountLine."Discount Amount");
        LineAmtExclTax := Round(Qty * Item."Unit Price") - LineDiscAmt;
        LineAmtInclTax := Round(LineAmtInclTax * (1 + VATPostingSetup."VAT %" / 100));

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

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
        Assert.AreEqual(Round(Qty * Item."Unit Price"), -(GLEntry.Amount + GLEntry."VAT Amount"), '(Qty * Item."Unit Price" * 1) <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Qty * Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100) <> GLEntry.Amount');
    end;

    [Test]
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
        PeriodDiscountLine: Record "NPR Period Discount Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
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
        CreateDiscount(Item, 7, PeriodDiscountLine);

        LineDiscPct := 100 - PeriodDiscountLine."Campaign Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := PeriodDiscountLine."Discount Amount";
        LineAmtInclTax := Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

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
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100) <> GLEntry.Amount');
    end;

    [Test]
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
        PeriodDiscountLine: Record "NPR Period Discount Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
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
        CreateDiscount(Item, 7, PeriodDiscountLine);

        Qty := 1 / 2;
        LineDiscPct := 100 - PeriodDiscountLine."Campaign Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := Round(Qty * PeriodDiscountLine."Discount Amount");
        LineAmtInclTax := Round(Qty * Item."Unit Price") - LineDiscAmt;
        LineAmtExclTax := Round(LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100));

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

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
        Assert.AreEqual(Round(Qty * Item."Unit Price"), -(GLEntry.Amount + GLEntry."VAT Amount"), '(Qty * Item."Unit Price" * 1) <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Qty * Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100) <> GLEntry.Amount');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForRevChrgTaxInDirectSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        PeriodDiscountLine: Record "NPR Period Discount Line";
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
        CreateDiscount(Item, 9, PeriodDiscountLine);

        LineDiscPct := 100 - PeriodDiscountLine."Campaign Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := PeriodDiscountLine."Discount Amount";
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
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Campaign, 'Campaign Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'PeriodLineDiscountLine."Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForRevChrgTaxInDebitSaleForward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        PeriodDiscountLine: Record "NPR Period Discount Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
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
        CreateDiscount(Item, 7, PeriodDiscountLine);

        LineDiscPct := 100 - PeriodDiscountLine."Campaign Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := PeriodDiscountLine."Discount Amount";
        LineAmtExclTax := Item."Unit Price" - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax * (1 + VATPostingSetup."VAT %" / 100);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Campaign, 'Campaign Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'PeriodLineDiscountLine."Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '((Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100) / (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '((Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100)) * (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '(Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100))  <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForRevChrgTaxInDebitSaleBackward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        PeriodDiscountLine: Record "NPR Period Discount Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
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
        CreateDiscount(Item, 7, PeriodDiscountLine);

        LineDiscPct := 100 - PeriodDiscountLine."Campaign Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := PeriodDiscountLine."Discount Amount";
        LineAmtInclTax := Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Campaign, 'Campaign Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'PeriodLineDiscountLine."Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
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
        PeriodDiscountLine: Record "NPR Period Discount Line";
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
        CreateDiscount(Item, 9, PeriodDiscountLine);

        LineDiscPct := 100 - PeriodDiscountLine."Campaign Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := PeriodDiscountLine."Discount Amount";
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
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100) <> GLEntry.Amount');
    end;

    [Test]
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
        PeriodDiscountLine: Record "NPR Period Discount Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
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
        CreateDiscount(Item, 7, PeriodDiscountLine);

        LineDiscPct := 100 - PeriodDiscountLine."Campaign Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := PeriodDiscountLine."Discount Amount";
        LineAmtExclTax := Item."Unit Price" - LineDiscAmt;
        LineAmtInclTax := LineAmtInclTax * (1 + VATPostingSetup."VAT %" / 100);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

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
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100) <> GLEntry.Amount');
    end;

    [Test]
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
        PeriodDiscountLine: Record "NPR Period Discount Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
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
        CreateDiscount(Item, 7, PeriodDiscountLine);

        LineDiscPct := 100 - PeriodDiscountLine."Campaign Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := PeriodDiscountLine."Discount Amount";
        LineAmtInclTax := Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

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
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100) <> GLEntry.Amount');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForSaleTaxInDirectSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        TaxArea: Record "Tax Area";
        TaxDetail: Record "Tax Detail";
        PeriodDiscountLine: Record "NPR Period Discount Line";
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
        CreateDiscount(Item, 9, PeriodDiscountLine);

        LineDiscPct := PeriodDiscountLine."Discount %";
        Qty := 1;
        UnitPriceTaxable := Item."Unit Price" * (1 - LineDiscPct / 100);
        TotalTax := Qty * (Round(UnitPriceTaxable * CityTaxRate / 100) +
                           Round(UnitPriceTaxable * CountyTaxRate / 100) +
                           Round(UnitPriceTaxable * StateTaxRate / 100));
        LineDiscAmt := PeriodDiscountLine."Discount Amount";
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
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Campaign, 'Campaign Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'PeriodLineDiscountLine."Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100)) <> POSSaleLine.Amount');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100)) + TotalTax <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
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
        PeriodDiscountLine: Record "NPR Period Discount Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
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
        CreateDiscount(Item, 7, PeriodDiscountLine);

        LineDiscPct := PeriodDiscountLine."Discount %";
        LineDiscAmt := PeriodDiscountLine."Discount Amount";
        Qty := 1;
        UnitPriceTaxable := Item."Unit Price" * (1 - LineDiscPct / 100);
        TotalTax := Qty * (Round(UnitPriceTaxable * CityTaxRate / 100) +
                           Round(UnitPriceTaxable * CountyTaxRate / 100) +
                           Round(UnitPriceTaxable * StateTaxRate / 100));
        LineAmtExclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax + TotalTax;

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Campaign, 'Campaign Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'PeriodLineDiscountLine."Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Qty * Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100))  <> POSSaleLine.Amount');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100)) + TotalTax <> POSSaleLine."Amount Including VAT"');
    end;


    [Test]
    procedure ApplyDiscountWhenEndSaleForSaleTaxInDirectSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        GLEntry: Record "G/L Entry";
        TaxJurisdiction: Record "Tax Jurisdiction";
        TaxDetail: Record "Tax Detail";
        TaxArea: Record "Tax Area";
        PeriodDiscountLine: Record "NPR Period Discount Line";
        POSPostingProfile: Record "NPR POS Posting Profile";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
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
        CreateDiscount(Item, 9, PeriodDiscountLine);

        LineDiscPct := PeriodDiscountLine."Discount %";
        LineDiscAmt := PeriodDiscountLine."Discount Amount";

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
        VerifySalesforGLEntry(POSEntry, Item, POSPostingProfile."Gen. Bus. Posting Group");
    end;

    [Test]
    procedure ApplyDiscountWhenEndSaleForSaleTaxInDirectSaleQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        GLEntry: Record "G/L Entry";
        TaxJurisdiction: Record "Tax Jurisdiction";
        TaxDetail: Record "Tax Detail";
        TaxArea: Record "Tax Area";
        PeriodDiscountLine: Record "NPR Period Discount Line";
        POSPostingProfile: Record "NPR POS Posting Profile";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
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
        CreateDiscount(Item, 9, PeriodDiscountLine);

        LineDiscPct := PeriodDiscountLine."Discount %";
        LineDiscAmt := PeriodDiscountLine."Discount Amount";

        Qty := Round(1 + 1 / 3, 0.00001);
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
        VerifySalesforGLEntry(POSEntry, Item, POSPostingProfile."Gen. Bus. Posting Group");
    end;

    [Test]
    procedure ApplyDiscountWhenEndSaleForSaleTaxInDebitSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        POSEntry: Record "NPR POS Entry";
        GLEntry: Record "G/L Entry";
        TaxJurisdiction: Record "Tax Jurisdiction";
        TaxDetail: Record "Tax Detail";
        TaxArea: Record "Tax Area";
        POSPostingProfile: Record "NPR POS Posting Profile";
        PeriodDiscountLine: Record "NPR Period Discount Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
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
        CreateDiscount(Item, 7, PeriodDiscountLine);

        LineDiscPct := PeriodDiscountLine."Discount %";

        Qty := 1;
        UnitPriceTaxable := Item."Unit Price" * (1 - LineDiscPct / 100);
        TotalTax := Qty * (Round(UnitPriceTaxable * CityTaxRate / 100) +
                   Round(UnitPriceTaxable * CountyTaxRate / 100) +
                   Round(UnitPriceTaxable * StateTaxRate / 100));

        LineAmtInclTax := UnitPriceTaxable * Qty + TotalTax;

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

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
        Assert.IsFalse(TaxJurisdiction.IsEmpty(), 'Tax Jurisdiction not found');

        VerifyVATforGLEntry(POSEntry, TaxArea);

        VerifySalesforGLEntry(POSEntry, Item, Customer."Gen. Bus. Posting Group");
    end;

    [Test]
    procedure ApplyDiscountWhenEndSaleForSaleTaxInDebitSaleQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        POSEntry: Record "NPR POS Entry";
        GLEntry: Record "G/L Entry";
        TaxJurisdiction: Record "Tax Jurisdiction";
        TaxDetail: Record "Tax Detail";
        TaxArea: Record "Tax Area";
        POSPostingProfile: Record "NPR POS Posting Profile";
        PeriodDiscountLine: Record "NPR Period Discount Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
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
        CreateDiscount(Item, 7, PeriodDiscountLine);

        LineDiscPct := PeriodDiscountLine."Discount %";

        Qty := Round(2 + 2 / 3, 0.00001);
        UnitPriceTaxable := Item."Unit Price" * (1 - LineDiscPct / 100);
        TotalTax := Round(Qty * UnitPriceTaxable * CityTaxRate / 100) +
                   Round(Qty * UnitPriceTaxable * CountyTaxRate / 100) +
                   Round(Qty * UnitPriceTaxable * StateTaxRate / 100);

        LineAmtInclTax := Round(UnitPriceTaxable * Qty + TotalTax);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

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
        Assert.IsFalse(TaxJurisdiction.IsEmpty(), 'Tax Jurisdiction not found');

        VerifyVATforGLEntry(POSEntry, TaxArea);

        VerifySalesforGLEntry(POSEntry, Item, Customer."Gen. Bus. Posting Group");
    end;

    [Test]
    procedure RelevantDiscountsFoundForDMLModify()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        xPOSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        TempDiscountPriority: Record "NPR Discount Priority" temporary;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        PeriodDiscountLine: Record "NPR Period Discount Line";
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
        CreateDiscount(Item, LibraryRandom.RandDecInRange(1, 100, 5), PeriodDiscountLine);

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
    procedure ApplyDiscountWhenPOSSaleLineUpdatedQtyForNormalTaxInDirectSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        PeriodDiscountLine: Record "NPR Period Discount Line";
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
        CreateDiscount(Item, 9, PeriodDiscountLine);
        LineDiscPct := PeriodDiscountLine."Discount %";

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

        LineDiscAmt := Qty * PeriodDiscountLine."Discount Amount";
        LineAmtInclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Campaign, 'Campaign Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'PeriodLineDiscountLine."Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine.Amount');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineUpdatedQtyForNormalTaxInDebitSaleForward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        PeriodDiscountLine: Record "NPR Period Discount Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
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
        CreateDiscount(Item, 7, PeriodDiscountLine);
        LineDiscPct := PeriodDiscountLine."Discount %";

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [WHEN] Quantity changed
        Qty := 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        Item."Unit Price" := Item."Unit Price" / (1 + VATPostingSetup."VAT %" / 100);
        PeriodDiscountLine."Campaign Unit Price" := PeriodDiscountLine."Campaign Unit Price" / (1 + VATPostingSetup."VAT %" / 100);
        LineDiscPct := 100 - PeriodDiscountLine."Campaign Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtExclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax * (1 + VATPostingSetup."VAT %" / 100);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Campaign, 'Campaign Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(Round(LineDiscPct), Round(POSSaleLine."Discount %"), 'PeriodLineDiscountLine."Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), Round(POSSaleLine."Discount Amount"), '((Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100) / (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), Round(POSSaleLine."Amount Including VAT"), '((Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100)) * (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), Round(POSSaleLine.Amount), '(Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100))  <> POSSaleLine.Amount');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineUpdatedQtyForNormalTaxInDebitSaleBackward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        PeriodDiscountLine: Record "NPR Period Discount Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
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
        CreateDiscount(Item, 7, PeriodDiscountLine);
        LineDiscPct := PeriodDiscountLine."Discount %";

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [WHEN] Quantity changed
        Qty := 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        LineDiscAmt := Qty * PeriodDiscountLine."Discount Amount";
        LineAmtInclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Campaign, 'Campaign Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'PeriodLineDiscountLine."Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine.Amount');
    end;

    [Test]
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
        PeriodDiscountLine: Record "NPR Period Discount Line";
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
        CreateDiscount(Item, 7, PeriodDiscountLine);
        LineDiscPct := PeriodDiscountLine."Discount %";

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

        LineDiscAmt := Qty * PeriodDiscountLine."Discount Amount";
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
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100) <> GLEntry.Amount');
    end;

    [Test]
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
        PeriodDiscountLine: Record "NPR Period Discount Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
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
        CreateDiscount(Item, 7, PeriodDiscountLine);
        LineDiscPct := PeriodDiscountLine."Discount %";

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Quantity changed
        Qty := 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        LineDiscAmt := Qty * PeriodDiscountLine."Discount Amount";
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
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100) <> GLEntry.Amount');
    end;

    [Test]
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
        PeriodDiscountLine: Record "NPR Period Discount Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
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
        CreateDiscount(Item, 7, PeriodDiscountLine);
        LineDiscPct := PeriodDiscountLine."Discount %";

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Quantity changed
        Qty := 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        LineDiscAmt := Qty * PeriodDiscountLine."Discount Amount";
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
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100) <> GLEntry.Amount');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineUpdatedQtyForRevChrgTaxInDirectSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        PeriodDiscountLine: Record "NPR Period Discount Line";
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
        CreateDiscount(Item, 9, PeriodDiscountLine);
        LineDiscPct := PeriodDiscountLine."Discount %";

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

        LineDiscAmt := Qty * PeriodDiscountLine."Discount Amount";
        LineAmtInclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Campaign, 'Campaign Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'PeriodLineDiscountLine."Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine.Amount');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineUpdatedQtyForRevChrgTaxInDebitSaleForward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        PeriodDiscountLine: Record "NPR Period Discount Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
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
        CreateDiscount(Item, 7, PeriodDiscountLine);
        LineDiscPct := PeriodDiscountLine."Discount %";

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [WHEN] Quantity changed
        Qty := 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        UnitPrice := Item."Unit Price" / (1 + VATPostingSetup."VAT %" / 100);
        LineDiscAmt := Qty * PeriodDiscountLine."Discount Amount";
        LineAmtExclTax := Qty * UnitPrice - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax * (1 + VATPostingSetup."VAT %" / 100);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Campaign, 'Campaign Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'PeriodLineDiscountLine."Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '((Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100) / (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '((Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100)) * (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '(Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100))  <> POSSaleLine.Amount');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineUpdatedQtyForRevChrgTaxInDebitSaleBackward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        PeriodDiscountLine: Record "NPR Period Discount Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
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
        CreateDiscount(Item, 7, PeriodDiscountLine);
        LineDiscPct := PeriodDiscountLine."Discount %";

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [WHEN] Quantity changed
        Qty := 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        LineDiscAmt := Qty * PeriodDiscountLine."Discount Amount";
        LineAmtInclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Campaign, 'Campaign Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'PeriodLineDiscountLine."Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Item."Unit Price" - (Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine.Amount');
    end;

    [Test]
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
        PeriodDiscountLine: Record "NPR Period Discount Line";
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
        CreateDiscount(Item, 9, PeriodDiscountLine);
        LineDiscPct := PeriodDiscountLine."Discount %";

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

        LineDiscAmt := Qty * PeriodDiscountLine."Discount Amount";
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
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100) <> GLEntry.Amount');
    end;

    [Test]
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
        PeriodDiscountLine: Record "NPR Period Discount Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
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
        CreateDiscount(Item, 7, PeriodDiscountLine);
        LineDiscPct := PeriodDiscountLine."Discount %";

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Quantity changed
        Qty := 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        LineDiscAmt := Qty * PeriodDiscountLine."Discount Amount";
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
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100) <> GLEntry.Amount');
    end;

    [Test]
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
        PeriodDiscountLine: Record "NPR Period Discount Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
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
        CreateDiscount(Item, 7, PeriodDiscountLine);
        LineDiscPct := PeriodDiscountLine."Discount %";

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Quantity changed
        Qty := 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        LineDiscAmt := Qty * PeriodDiscountLine."Discount Amount";
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
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100) <> GLEntry.Amount');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineUpdatedForSaleTaxInDirectSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        TaxArea: Record "Tax Area";
        TaxDetail: Record "Tax Detail";
        PeriodDiscountLine: Record "NPR Period Discount Line";
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
        CreateDiscount(Item, 9, PeriodDiscountLine);
        LineDiscPct := PeriodDiscountLine."Discount %";

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
        LineDiscAmt := Qty * PeriodDiscountLine."Discount Amount";
        LineAmtExclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax + TotalTax;

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Campaign, 'Campaign Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'PeriodLineDiscountLine."Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Qty * Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100)) <> POSSaleLine.Amount');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100)) + TotalTax <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
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
        PeriodDiscountLine: Record "NPR Period Discount Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
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
        CreateDiscount(Item, 7, PeriodDiscountLine);
        LineDiscPct := PeriodDiscountLine."Discount %";

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

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
        LineDiscAmt := Qty * PeriodDiscountLine."Discount Amount";
        LineAmtExclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax + TotalTax;

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Campaign, 'Campaign Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'PeriodLineDiscountLine."Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Qty * Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100))  <> POSSaleLine.Amount');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * PeriodLineDiscountLine."Discount %" / 100)) + TotalTax <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
    procedure ApplyDiscountWhenEndSaleForSaleTaxInDirectSaleUpdatedQty()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        GLEntry: Record "G/L Entry";
        TaxJurisdiction: Record "Tax Jurisdiction";
        TaxDetail: Record "Tax Detail";
        TaxArea: Record "Tax Area";
        PeriodDiscountLine: Record "NPR Period Discount Line";
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
        CreateDiscount(Item, 9, PeriodDiscountLine);
        LineDiscPct := PeriodDiscountLine."Discount %";

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
        VerifySalesforGLEntry(POSEntry, Item, POSPostingProfile."Gen. Bus. Posting Group");
    end;

    [Test]
    procedure ApplyDiscountWhenEndSaleForSaleTaxInDebitSaleUpdatedQty()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        POSEntry: Record "NPR POS Entry";
        GLEntry: Record "G/L Entry";
        TaxJurisdiction: Record "Tax Jurisdiction";
        TaxDetail: Record "Tax Detail";
        TaxArea: Record "Tax Area";
        PeriodDiscountLine: Record "NPR Period Discount Line";
        POSPostingProfile: Record "NPR POS Posting Profile";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
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
        CreateDiscount(Item, 7, PeriodDiscountLine);
        LineDiscPct := PeriodDiscountLine."Discount %";

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

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
        VerifySalesforGLEntry(POSEntry, Item, Customer."Gen. Bus. Posting Group");
    end;

    [Test]
    procedure RelevantDiscountsNotFoundForDMLDelete()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        xPOSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        TempDiscountPriority: Record "NPR Discount Priority" temporary;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        PeriodDiscountLine: Record "NPR Period Discount Line";
        SalesDiscCalcMgt: codeunit "NPR POS Sales Disc. Calc. Mgt.";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
    begin
        // [SCENARIO] Exersice & verify. Discount is not prioritized when POS Sale Line has been deleted

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
        CreateDiscount(Item, LibraryRandom.RandDecInRange(1, 100, 5), PeriodDiscountLine);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);
        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Active Sales Line for Item
        CreatePOSSaleLine(Item, POSSale, POSSaleLine);

        // [WHEN] Delete operation performed
        SalesDiscCalcMgt.OnFindActiveSaleLineDiscounts(TempDiscountPriority, POSSale, POSSaleLine, xPOSSaleLine, 2);

        // [THEN] Verify Discount Priority not found
        Assert.IsFalse(TempDiscountPriority.Get(DiscSourceTableId()), 'Discount created');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineDeletedForNormalTaxInDirectSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        PeriodDiscountLine: Record "NPR Period Discount Line";
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
        CreateDiscount(Item, 9, PeriodDiscountLine);

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
    procedure ApplyDiscountWhenPOSSaleLineDeletedForNormalTaxInDebitSaleForward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        PeriodDiscountLine: Record "NPR Period Discount Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
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
        CreateDiscount(Item, 7, PeriodDiscountLine);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

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
    procedure ApplyDiscountWhenPOSSaleLineDeletedForNormalTaxInDebitSaleBackward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        PeriodDiscountLine: Record "NPR Period Discount Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
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
        CreateDiscount(Item, 7, PeriodDiscountLine);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

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
    procedure ApplyDiscountWhenPOSSaleLineDeletedForRevChrgTaxInDirectSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        PeriodDiscountLine: Record "NPR Period Discount Line";
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
        CreateDiscount(Item, 9, PeriodDiscountLine);

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
    procedure ApplyDiscountWhenPOSSaleLineDeletedForRevChrgTaxInDebitSaleForward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        PeriodDiscountLine: Record "NPR Period Discount Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
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
        CreateDiscount(Item, 7, PeriodDiscountLine);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

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
    procedure ApplyDiscountWhenPOSSaleLineDeletedForRevChrgTaxInDebitSaleBackward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
        PeriodDiscountLine: Record "NPR Period Discount Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
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
        CreateDiscount(Item, 7, PeriodDiscountLine);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

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
    procedure ApplyDiscountWhenPOSSaleLineDeletedForSaleTaxInDirectSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        TaxArea: Record "Tax Area";
        TaxDetail: Record "Tax Detail";
        PeriodDiscountLine: Record "NPR Period Discount Line";
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
        CreateDiscount(Item, 9, PeriodDiscountLine);

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
        PeriodDiscountLine: Record "NPR Period Discount Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
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
        CreateDiscount(Item, 7, PeriodDiscountLine);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

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
        POSSaleLine."Sale Type" := POSSaleLine."Sale Type"::Sale;
        POSSaleLine."Line No." := 10000;
        POSSaleLine.Date := Today();
        POSSaleLine.Init();
        POSSaleLine.Type := POSSaleLine.Type::Item;
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
        exit(DATABASE::"NPR Period Discount");
    end;

    local procedure CreateDiscount(Item: Record Item; DiscPct: Decimal; var PeriodDiscountLine: Record "NPR Period Discount Line")
    var
        PeriodDiscount: Record "NPR Period Discount";
    begin
        CreateDiscountHeader(PeriodDiscount);
        CreateDiscountLine(PeriodDiscount, Item, DiscPct, PeriodDiscountLine);
    end;

    local procedure CreateDiscountHeader(var PeriodDiscount: Record "NPR Period Discount")
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        PeriodDiscount.Code := LibraryUtility.GenerateRandomCode(PeriodDiscount.FieldNo(Code), DiscSourceTableId());
        PeriodDiscount.Init();
        PeriodDiscount.Status := PeriodDiscount.Status::Active;
        PeriodDiscount."Starting date" := Today() - 7;
        PeriodDiscount."Ending date" := Today() + 7;
        PeriodDiscount."Location Code" := POSStore."Location Code";
        PeriodDiscount."Period Type" := PeriodDiscount."Period Type"::"Every Day";
        PeriodDiscount.Insert();
    end;

    local procedure CreateDiscountLine(PeriodDiscount: Record "NPR Period Discount"; Item: Record Item; DiscPct: Decimal; var PeriodDiscountLine: Record "NPR Period Discount Line")
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        PeriodDiscountLine.Code := PeriodDiscount.Code;
        PeriodDiscountLine."Item No." := Item."No.";
        PeriodDiscountLine."Variant Code" := '';
        PeriodDiscountLine.Init();
        PeriodDiscountLine.Status := PeriodDiscount.Status;
        PeriodDiscountLine."Starting date" := PeriodDiscount."Starting date";
        PeriodDiscountLine."Ending Date" := PeriodDiscount."Ending date";
        PeriodDiscountLine.Validate("Discount %", DiscPct);
        PeriodDiscountLine.Insert();
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

    local procedure VerifySalesforGLEntry(POSEntry: Record "NPR POS Entry"; Item: Record Item; GenBusPostingGroup: Code[20])
    var
        GLEntry: Record "G/L Entry";
        GeneralPostingSetup: Record "General Posting Setup";
        POSPostingProfile: Record "NPR POS Posting Profile";
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