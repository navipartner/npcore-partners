codeunit 85137 "NPR Retail Journal Tests"
{
    Subtype = Test;

    var
        Item: Record Item;
        POSSetup: Record "NPR POS Setup";
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        POSPaymentMethodCash: Record "NPR POS Payment Method";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        POSSession: Codeunit "NPR POS Session";
        Initialized: Boolean;
        LibraryPOSDiscount: Codeunit "NPR Library - POS Discount";

    trigger OnRun()
    begin
        Initialized := false;
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfUnitPriceIsCorrectOnRJLItemNotPartOfAnyDiscount()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
    begin
        // [SCENARIO] Test if the price is populated correctly when an item that is not part of any discount is added to the retail journal line.

        Initialize();

        // [GIVEN] VAT Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify(true);
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);
        Item."Unit Price" := 150;
        Item.Modify();

        // [GIVEN] Item added to retail journal
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();

        // [THEN] Check if price is calculated correctly
        Assert.AreEqual(RetailJournalLine."Unit Price", Item."Unit Price", 'Unit Price not calculated according to scenario');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfDiscountAppliedOnRJLItemPartOfPeriodDiscount()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        PeriodDiscountLine: Record "NPR Period Discount Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        POSPeriodDiscandTax: Codeunit "NPR POS Period Disc. and Tax";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
        LineAmtInclTax: Decimal;
    begin
        // [SCENARIO] Test if the price and discount are populated correctly when an item is part of a period discount and is added to the retail journal.

        Initialize();

        // [GIVEN] VAT Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify(true);
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);
        Item."Unit Price" := 150;
        Item.Modify();

        // [GIVEN] Period discount
        POSPeriodDiscandTax.CreateDiscount(Item, 50, PeriodDiscountLine);

        // [GIVEN] Item added to retail journal
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();
        LineAmtInclTax := Item."Unit Price" - PeriodDiscountLine."Discount Amount";

        // [THEN] Check if discount and price are calculated correctly
        Assert.AreEqual(RetailJournalLine."Unit Price", Item."Unit Price", 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Campaign, 'Discount not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Code", PeriodDiscountLine.Code, 'Discount not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Pct.", PeriodDiscountLine."Discount %", 'Discount not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Price Incl. Vat", LineAmtInclTax, 'Unit price after discount application not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfDiscountAppliedOnRJLItemPartOfQuantityDiscount()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        POSQtyDiscandTax: Codeunit "NPR POS Qty. Disc. and Tax";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
        QtyForDiscCalc: Integer;
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        LineAmtInclTax: Decimal;
    begin
        // [SCENARIO] Test if the price and discount are populated correctly when an item is part of a quantity discount and is added to the retail journal.

        Initialize();

        // [GIVEN] VAT Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify(true);
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);
        Item."Unit Price" := 100;
        Item.Modify();

        // [GIVEN] Quantity discount
        POSQtyDiscandTax.CreateDiscount(Item, 80, QuantityDiscountLine);

        // [GIVEN] Item added to retail journal
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        QtyForDiscCalc := 2;
        RetailJournalLine.Validate("Quantity for Discount Calc", QtyForDiscCalc);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();

        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := QtyForDiscCalc * Item."Unit Price" * LineDiscPct / 100;
        LineAmtInclTax := QtyForDiscCalc * Item."Unit Price" - LineDiscAmt;

        // [THEN] Check if discount and price are calculated correctly
        Assert.AreEqual(RetailJournalLine."Unit Price", Item."Unit Price", 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Quantity, 'Discount not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Code", QuantityDiscountLine."Main no.", 'Discount not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Pct.", LineDiscPct, 'Discount not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Price Incl. Vat", LineAmtInclTax, 'Discount not calculated according to scenario');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfDiscountAppliedOnRJLItemPartOfMixedDiscount()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        POSMixDiscandTax: Codeunit "NPR POS Mix. Disc. and Tax";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
        LineDiscAmt: Decimal;
        LineDiscPct: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
    begin
        // [SCENARIO] Test if the price and discount are populated correctly when an item is part of a mix discount and is added to the retail journal.

        Initialize();

        // [GIVEN] VAT Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify(true);
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);
        Item."Unit Price" := 150;
        Item.Modify();

        // [GIVEN] Mixed discount
        LineDiscPct := LibraryPOSDiscount.CreateTotalDiscountPct(Item, 60, false);

        // [GIVEN] Item added to retail journal
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();
        LineDiscAmt := Item."Unit Price" * LineDiscPct / 100;
        LineAmtInclTax := Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + RetailJournalLine."VAT %" / 100);

        // [THEN] Check if discount and price are calculated correctly
        Assert.AreEqual(RetailJournalLine."Unit Price", Item."Unit Price", 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Mix, 'Discount not calculated according to scenario');
        Assert.AreNotEqual(RetailJournalLine."Discount Code", '', 'Discount not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Pct.", LineDiscPct, 'Discount not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Price Excl. VAT", LineAmtExclTax, 'Discount not calculated according to scenario');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfDiscountAppliedOnRJLItemPartOfPriceListDiscount()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        POSCustoDiscandTax: Codeunit "NPR POS Cust. Disc. and Tax";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
        LineDiscAmt: Decimal;
        LineDiscPct: Decimal;
        LineAmtInclTax: Decimal;
    begin
        // [SCENARIO] Test if the price and discount are populated correctly when an item is part of a price list discount and is added to the retail journal.

        Initialize();

        // [GIVEN] VAT Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify(true);
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);
        Item."Unit Price" := 200;
        Item.Modify();

        // [GIVEN] Mixed discount
        LineDiscPct := POSCustoDiscandTax.CreateDiscount(Item, 50);

        // [GIVEN] Item added to retail journal
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();
        LineDiscAmt := Item."Unit Price" * LineDiscPct / 100;
        LineAmtInclTax := Item."Unit Price" - LineDiscAmt;

        // [THEN] Check if discount and price are calculated correctly
        Assert.AreEqual(RetailJournalLine."Unit Price", Item."Unit Price", 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Customer, 'Discount not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Pct.", LineDiscPct, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Incl. Vat", LineAmtInclTax, 0.1, 'Discount not calculated according to scenario');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfDiscountAppliedOnRJLItemPartOfPeriodAndMixDiscount()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        PeriodDiscountLine: Record "NPR Period Discount Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        TempDiscountPriority: Record "NPR Discount Priority" temporary;
        POSPeriodDiscandTax: Codeunit "NPR POS Period Disc. and Tax";
        Assert: Codeunit Assert;
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        RetailJournalNo: Text;
        LineDiscAmt: Decimal;
        LineMixDiscPct: Decimal;
        LineAmtInclTax: Decimal;
        LineAmtExclTax: Decimal;
    begin
        // [SCENARIO] Test if the price and discount are populated correctly when an item is part of both a period and mix discount and is added to the retail journal.

        Initialize();

        // [GIVEN] VAT Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify(true);
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);
        Item."Unit Price" := 150;
        Item.Modify();


        // [GIVEN] Discount priority, period and mix discount
        POSSalesDiscountCalcMgt.InitDiscountPriority(TempDiscountPriority);
        POSPeriodDiscandTax.CreateDiscount(Item, 60, PeriodDiscountLine);
        LineMixDiscPct := LibraryPOSDiscount.CreateTotalDiscountPct(Item, 40, false);

        // [GIVEN] Item added to retail journal
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();
        LineDiscAmt := Item."Unit Price" * LineMixDiscPct / 100;
        LineAmtInclTax := Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + RetailJournalLine."VAT %" / 100);

        // [THEN] Check if discount and price are calculated correctly
        Assert.AreEqual(RetailJournalLine."Unit Price", Item."Unit Price", 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Mix, 'Discount not calculated according to scenario');
        Assert.AreNotEqual(RetailJournalLine."Discount Code", '', 'Discount not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Pct.", LineMixDiscPct, 'Discount not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Price Excl. VAT", LineAmtExclTax, 'Unit price after discount application not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckPricesItemPriceNotIncludesVATItemWithoutVATMixDiscountTotalAmountPerMinQty()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
        TotalAmount: Decimal;
    begin
        // [SCENARIO] Check prices when having item on retail journal which has mix discount total amount per min qty. Item price includes vat = false + item without VAT

        Initialize();

        // [GIVEN] VAT Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify(true);
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price, price includes vat = false, item without VAT
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);
        Item."Unit Price" := 2000;
        Item.Modify();

        // [GIVEN] Mixed discount total amount per min qty.
        TotalAmount := LibraryPOSDiscount.CreateTotalDiscountAmountTotalAmtPerMinQty(Item, 500, false);

        // [GIVEN] Item added to retail journal
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();

        // [THEN] Check if discount and prices are calculated correctly
        Assert.AreNearlyEqual(RetailJournalLine."Unit Price", Item."Unit Price", 0.1, 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Mix, 'Discount not calculated according to scenario');
        Assert.AreNotEqual(RetailJournalLine."Discount Code", '', 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Excl. VAT", TotalAmount, 0.1, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Incl. VAT", TotalAmount, 0.1, 'Discount not calculated according to scenario');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckPricesItemPriceNotIncludesVATItemWithVATMixDiscountTotalAmountPerMinQty()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
        TotalAmount: Decimal;
        UnitPriceInclTax: Decimal;
        DiscountPriceExclTax: Decimal;
    begin
        // [SCENARIO] Check prices when having item on retail journal which has mix discount total amount per min qty. Item price includes vat = false + item with VAT

        Initialize();

        // [GIVEN] VAT Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price, price includes vat = false, item with VAT
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);
        Item."Unit Price" := 2000;
        Item.Modify();

        // [GIVEN] Mixed discount total amount per min qty.
        TotalAmount := LibraryPOSDiscount.CreateTotalDiscountAmountTotalAmtPerMinQty(Item, 500, false);

        // [GIVEN] Item added to retail journal
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        UnitPriceInclTax := POSSaleTaxCalc.CalcAmountWithVAT(Item."Unit Price", VATPostingSetup."VAT %", GeneralLedgerSetup."Amount Rounding Precision");
        DiscountPriceExclTax := POSSaleTaxCalc.CalcAmountWithoutVAT(TotalAmount, VATPostingSetup."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if discount and prices are calculated correctly
        Assert.AreNearlyEqual(RetailJournalLine."Unit Price", UnitPriceInclTax, 0.1, 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Mix, 'Discount not calculated according to scenario');
        Assert.AreNotEqual(RetailJournalLine."Discount Code", '', 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Excl. VAT", DiscountPriceExclTax, 0.1, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Incl. VAT", TotalAmount, 0.1, 'Discount not calculated according to scenario');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckPricesItemPriceIncludesVATItemWithoutVATMixDiscountTotalAmountPerMinQty()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
        TotalAmount: Decimal;
    begin
        // [SCENARIO] Check prices when having item on retail journal which has mix discount total amount per min qty. Item price includes vat = true + item without VAT

        Initialize();

        // [GIVEN] VAT Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify(true);
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price, price includes vat = true, item without VAT
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 2000;
        Item.Modify();

        // [GIVEN] Mixed discount total amount per min qty.
        TotalAmount := LibraryPOSDiscount.CreateTotalDiscountAmountTotalAmtPerMinQty(Item, 500, false);

        // [GIVEN] Item added to retail journal
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();

        // [THEN] Check if discount and prices are calculated correctly
        Assert.AreNearlyEqual(RetailJournalLine."Unit Price", Item."Unit Price", 0.1, 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Mix, 'Discount not calculated according to scenario');
        Assert.AreNotEqual(RetailJournalLine."Discount Code", '', 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Excl. VAT", TotalAmount, 0.1, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Incl. VAT", TotalAmount, 0.1, 'Discount not calculated according to scenario');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckPricesItemPriceIncludesVATItemWithVATMixDiscountTotalAmountPerMinQty()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
        TotalAmount: Decimal;
        DiscountPriceExclTax: Decimal;
    begin
        // [SCENARIO] Check prices when having item on retail journal which has mix discount total amount per min qty. Item price includes vat = true + item with VAT

        Initialize();

        // [GIVEN] VAT Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price, price includes vat = true, item with VAT
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 2000;
        Item.Modify();

        // [GIVEN] Mixed discount total amount per min qty.
        TotalAmount := LibraryPOSDiscount.CreateTotalDiscountAmountTotalAmtPerMinQty(Item, 500, false);

        // [GIVEN] Item added to retail journal
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        DiscountPriceExclTax := POSSaleTaxCalc.CalcAmountWithoutVAT(TotalAmount, VATPostingSetup."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if discount and prices are calculated correctly
        Assert.AreNearlyEqual(RetailJournalLine."Unit Price", Item."Unit Price", 0.1, 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Mix, 'Discount not calculated according to scenario');
        Assert.AreNotEqual(RetailJournalLine."Discount Code", '', 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Excl. VAT", DiscountPriceExclTax, 0.1, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Incl. VAT", TotalAmount, 0.1, 'Discount not calculated according to scenario');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckPricesItemPriceNotIncludesVATItemWithoutVATMixDiscountTotalDiscountAmountPerMinQty()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
        DiscountAmount: Decimal;
    begin
        // [SCENARIO] Check prices when having item on retail journal which has mix discount total discount amount per min qty. Item price includes vat = false + item without VAT

        Initialize();

        // [GIVEN] VAT Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify(true);
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price, price includes vat = false, item without VAT
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);
        Item."Unit Price" := 2000;
        Item.Modify();

        // [GIVEN] Mixed discount total discount amount per min qty.
        DiscountAmount := LibraryPOSDiscount.CreateTotalDiscountAmountTotalDiscountAmtPerMinQty(Item, 500, false);

        // [GIVEN] Item added to retail journal
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();

        // [THEN] Check if discount and prices are calculated correctly
        Assert.AreNearlyEqual(RetailJournalLine."Unit Price", Item."Unit Price", 0.1, 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Mix, 'Discount not calculated according to scenario');
        Assert.AreNotEqual(RetailJournalLine."Discount Code", '', 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Excl. VAT", Item."Unit Price" - DiscountAmount, 0.1, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Incl. VAT", Item."Unit Price" - DiscountAmount, 0.1, 'Discount not calculated according to scenario');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckPricesItemPriceNotIncludesVATItemWithVATMixDiscountTotalDiscountAmountPerMinQty()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
        DiscountAmount: Decimal;
        UnitPriceInclTax: Decimal;
        DiscountAmountExclTax: Decimal;
    begin
        // [SCENARIO] Check prices when having item on retail journal which has mix discount total discount amount per min qty. Item price includes vat = false + item with VAT

        Initialize();

        // [GIVEN] VAT Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price, price includes vat = false, item with VAT
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);
        Item."Unit Price" := 2000;
        Item.Modify();

        // [GIVEN] Mixed discount total discount amount per min qty.
        DiscountAmount := LibraryPOSDiscount.CreateTotalDiscountAmountTotalDiscountAmtPerMinQty(Item, 500, false);

        // [GIVEN] Item added to retail journal
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        UnitPriceInclTax := POSSaleTaxCalc.CalcAmountWithVAT(Item."Unit Price", VATPostingSetup."VAT %", GeneralLedgerSetup."Amount Rounding Precision");
        DiscountAmountExclTax := POSSaleTaxCalc.CalcAmountWithoutVAT(UnitPriceInclTax - DiscountAmount, VATPostingSetup."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if discount and prices are calculated correctly
        Assert.AreNearlyEqual(RetailJournalLine."Unit Price", UnitPriceInclTax, 0.1, 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Mix, 'Discount not calculated according to scenario');
        Assert.AreNotEqual(RetailJournalLine."Discount Code", '', 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Excl. VAT", DiscountAmountExclTax, 0.1, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Incl. VAT", UnitPriceInclTax - DiscountAmount, 0.1, 'Discount not calculated according to scenario');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckPricesItemPriceIncludesVATItemWithoutVATMixDiscountTotalDiscountAmountPerMinQty()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
        DiscountAmount: Decimal;
    begin
        // [SCENARIO] Check prices when having item on retail journal which has mix discount total discount amount per min qty. Item price includes vat = true + item without VAT

        Initialize();

        // [GIVEN] VAT Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify(true);
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price, price includes vat = true, item without VAT
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 2000;
        Item.Modify();

        // [GIVEN] Mixed discount total discount amount per min qty.
        DiscountAmount := LibraryPOSDiscount.CreateTotalDiscountAmountTotalDiscountAmtPerMinQty(Item, 500, false);

        // [GIVEN] Item added to retail journal
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();

        // [THEN] Check if discount and prices are calculated correctly
        Assert.AreNearlyEqual(RetailJournalLine."Unit Price", Item."Unit Price", 0.1, 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Mix, 'Discount not calculated according to scenario');
        Assert.AreNotEqual(RetailJournalLine."Discount Code", '', 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Excl. VAT", Item."Unit Price" - DiscountAmount, 0.1, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Incl. VAT", Item."Unit Price" - DiscountAmount, 0.1, 'Discount not calculated according to scenario');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckPricesItemPriceIncludesVATItemWithVATMixDiscountTotalDiscountAmountPerMinQty()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
        DiscountAmount: Decimal;
        DiscountPriceExclTax: Decimal;
    begin
        // [SCENARIO] Check prices when having item on retail journal which has mix discount total discount amount per min qty. Item price includes vat = true + item with VAT

        Initialize();

        // [GIVEN] VAT Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price, price includes vat = true, item with VAT
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 2000;
        Item.Modify();

        // [GIVEN] Mixed discount total discount amount per min qty.
        DiscountAmount := LibraryPOSDiscount.CreateTotalDiscountAmountTotalDiscountAmtPerMinQty(Item, 500, false);

        // [GIVEN] Item added to retail journal
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        DiscountPriceExclTax := POSSaleTaxCalc.CalcAmountWithoutVAT(Item."Unit Price" - DiscountAmount, VATPostingSetup."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if discount and prices are calculated correctly
        Assert.AreNearlyEqual(RetailJournalLine."Unit Price", Item."Unit Price", 0.1, 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Mix, 'Discount not calculated according to scenario');
        Assert.AreNotEqual(RetailJournalLine."Discount Code", '', 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Excl. VAT", DiscountPriceExclTax, 0.1, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Incl. VAT", Item."Unit Price" - DiscountAmount, 0.1, 'Discount not calculated according to scenario');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckPricesItemPriceNotIncludesVATItemWithoutVATMixDiscountTotalDiscountPercent()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
        DiscountPct: Decimal;
    begin
        // [SCENARIO] Check prices when having item on retail journal which has mix discount total discount %. Item price includes vat = false + item without VAT

        Initialize();

        // [GIVEN] VAT Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify(true);
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price, price includes vat = false, item without VAT
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);
        Item."Unit Price" := 2000;
        Item.Modify();

        // [GIVEN] Mixed discount total discount %
        DiscountPct := LibraryPOSDiscount.CreateTotalDiscountPct(Item, 20, false);

        // [GIVEN] Item added to retail journal
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();

        // [THEN] Check if discount and prices are calculated correctly
        Assert.AreNearlyEqual(RetailJournalLine."Unit Price", Item."Unit Price", 0.1, 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Mix, 'Discount not calculated according to scenario');
        Assert.AreNotEqual(RetailJournalLine."Discount Code", '', 'Discount not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Pct.", DiscountPct, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Excl. VAT", Item."Unit Price" * (1 - DiscountPct / 100), 0.1, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Incl. VAT", Item."Unit Price" * (1 - DiscountPct / 100), 0.1, 'Discount not calculated according to scenario');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckPricesItemPriceNotIncludesVATItemWithVATMixDiscountTotalDiscountPercent()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
        DiscountPct: Decimal;
        UnitPriceInclTax: Decimal;
    begin
        // [SCENARIO] Check prices when having item on retail journal which has mix discount total discount %. Item price includes vat = false + item with VAT

        Initialize();

        // [GIVEN] VAT Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price, price includes vat = false, item with VAT
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);
        Item."Unit Price" := 2000;
        Item.Modify();

        // [GIVEN] Mixed discount total discount %
        DiscountPct := LibraryPOSDiscount.CreateTotalDiscountPct(Item, 20, false);

        // [GIVEN] Item added to retail journal
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        UnitPriceInclTax := POSSaleTaxCalc.CalcAmountWithVAT(Item."Unit Price", VATPostingSetup."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if discount and prices are calculated correctly
        Assert.AreNearlyEqual(RetailJournalLine."Unit Price", UnitPriceInclTax, 0.1, 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Mix, 'Discount not calculated according to scenario');
        Assert.AreNotEqual(RetailJournalLine."Discount Code", '', 'Discount not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Pct.", DiscountPct, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Excl. VAT", Item."Unit Price" * (1 - DiscountPct / 100), 0.1, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Incl. VAT", UnitPriceInclTax * (1 - DiscountPct / 100), 0.1, 'Discount not calculated according to scenario');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckPricesItemPriceIncludesVATItemWithoutVATMixDiscountTotalDiscountPercent()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
        DiscountPct: Decimal;
    begin
        // [SCENARIO] Check prices when having item on retail journal which has mix discount total discount %. Item price includes vat = true + item without VAT

        Initialize();

        // [GIVEN] VAT Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify(true);
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price, price includes vat = true, item without VAT
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 2000;
        Item.Modify();

        // [GIVEN] Mixed discount total discount %
        DiscountPct := LibraryPOSDiscount.CreateTotalDiscountPct(Item, 20, false);

        // [GIVEN] Item added to retail journal
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();

        // [THEN] Check if discount and prices are calculated correctly
        Assert.AreNearlyEqual(RetailJournalLine."Unit Price", Item."Unit Price", 0.1, 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Mix, 'Discount not calculated according to scenario');
        Assert.AreNotEqual(RetailJournalLine."Discount Code", '', 'Discount not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Pct.", DiscountPct, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Excl. VAT", Item."Unit Price" * (1 - DiscountPct / 100), 0.1, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Incl. VAT", Item."Unit Price" * (1 - DiscountPct / 100), 0.1, 'Discount not calculated according to scenario');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckPricesItemPriceIncludesVATItemWithVATMixDiscountTotalDiscountPercent()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
        DiscountPct: Decimal;
        DiscountPriceExclTax: Decimal;
    begin
        // [SCENARIO] Check prices when having item on retail journal which has mix discount total discount %. Item price includes vat = true + item with VAT

        Initialize();

        // [GIVEN] VAT Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price, price includes vat = true, item with VAT
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 2000;
        Item.Modify();

        // [GIVEN] Mixed discount total discount %
        DiscountPct := LibraryPOSDiscount.CreateTotalDiscountPct(Item, 20, false);

        // [GIVEN] Item added to retail journal
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        DiscountPriceExclTax := POSSaleTaxCalc.CalcAmountWithoutVAT(Item."Unit Price" * (1 - DiscountPct / 100), VATPostingSetup."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if discount and prices are calculated correctly
        Assert.AreNearlyEqual(RetailJournalLine."Unit Price", Item."Unit Price", 0.1, 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Mix, 'Discount not calculated according to scenario');
        Assert.AreNotEqual(RetailJournalLine."Discount Code", '', 'Discount not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Pct.", DiscountPct, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Excl. VAT", DiscountPriceExclTax, 0.1, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Incl. VAT", Item."Unit Price" * (1 - DiscountPct / 100), 0.1, 'Discount not calculated according to scenario');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckPricesItemPriceNotIncludesVATItemWithoutVATMixDiscountMutlipleDiscountLevels()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
        DiscountCode: Code[20];
        FirstLevelQty: Integer;
        SecondLevelQty: Integer;
        FirstLevelAmount: Decimal;
        SecondLevelAmount: Decimal;
    begin
        // [SCENARIO] Check prices when having item on retail journal which has mix discount multiple discount levels. Item price includes vat = false + item without VAT

        Initialize();

        // [GIVEN] VAT Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify(true);
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price, price includes vat = false, item without VAT
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);
        Item."Unit Price" := 2000;
        Item.Modify();

        // [GIVEN] Mixed discount multiple discount levels
        FirstLevelQty := 2;
        FirstLevelAmount := 100;
        SecondLevelQty := 3;
        SecondLevelAmount := 400;
        DiscountCode := LibraryPOSDiscount.CreateMultipleDiscountLevels(Item, FirstLevelQty, SecondLevelQty, FirstLevelAmount, SecondLevelAmount, false);

        // [GIVEN] Item added to retail journal
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        RetailJournalLine.Insert();

        // [GIVEN] First level discount quantity on retail journal line
        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();
        RetailJournalLine.Validate("Quantity for Discount Calc", FirstLevelQty);
        // [THEN] Check if discount and prices are calculated correctly
        Assert.AreNearlyEqual(RetailJournalLine."Unit Price", Item."Unit Price", 0.1, 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Mix, 'Discount not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Code", DiscountCode, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Excl. VAT", Item."Unit Price" * FirstLevelQty - FirstLevelAmount, 0.1, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Incl. VAT", Item."Unit Price" * FirstLevelQty - FirstLevelAmount, 0.1, 'Discount not calculated according to scenario');

        // [GIVEN] Second level discount quantity on retail journal line
        RetailJournalLine.Validate("Quantity for Discount Calc", SecondLevelQty);
        // [THEN] Check if discount and prices are calculated correctly
        Assert.AreNearlyEqual(RetailJournalLine."Unit Price", Item."Unit Price", 0.1, 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Mix, 'Discount not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Code", DiscountCode, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Excl. VAT", Item."Unit Price" * SecondLevelQty - SecondLevelAmount, 0.1, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Incl. VAT", Item."Unit Price" * SecondLevelQty - SecondLevelAmount, 0.1, 'Discount not calculated according to scenario');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckPricesItemPriceNotIncludesVATItemWithVATMixDiscountMultipleDiscountLevels()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
        DiscountCode: Code[20];
        FirstLevelQty: Integer;
        SecondLevelQty: Integer;
        FirstLevelAmount: Decimal;
        SecondLevelAmount: Decimal;
        UnitPriceInclTax: Decimal;
        FirstDiscountPriceExclTax: Decimal;
        SecondDiscountPriceExclTax: Decimal;
    begin
        // [SCENARIO] Check prices when having item on retail journal which has mix discount multiple discount levels. Item price includes vat = false + item with VAT

        Initialize();

        // [GIVEN] VAT Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price, price includes vat = false, item with VAT
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);
        Item."Unit Price" := 2000;
        Item.Modify();

        // [GIVEN] Mixed discount mutltiple discount levels
        FirstLevelQty := 2;
        FirstLevelAmount := 100;
        SecondLevelQty := 3;
        SecondLevelAmount := 400;
        DiscountCode := LibraryPOSDiscount.CreateMultipleDiscountLevels(Item, FirstLevelQty, SecondLevelQty, FirstLevelAmount, SecondLevelAmount, false);

        // [GIVEN] Item added to retail journal
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        RetailJournalLine.Insert();

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        UnitPriceInclTax := POSSaleTaxCalc.CalcAmountWithVAT(Item."Unit Price", VATPostingSetup."VAT %", GeneralLedgerSetup."Amount Rounding Precision");
        FirstDiscountPriceExclTax := POSSaleTaxCalc.CalcAmountWithoutVAT(UnitPriceInclTax * FirstLevelQty - FirstLevelAmount, VATPostingSetup."VAT %", GeneralLedgerSetup."Amount Rounding Precision");
        SecondDiscountPriceExclTax := POSSaleTaxCalc.CalcAmountWithoutVAT(UnitPriceInclTax * SecondLevelQty - SecondLevelAmount, VATPostingSetup."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [GIVEN] First level discount quantity on retail journal line
        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();
        RetailJournalLine.Validate("Quantity for Discount Calc", FirstLevelQty);
        // [THEN] Check if discount and prices are calculated correctly
        Assert.AreNearlyEqual(RetailJournalLine."Unit Price", UnitPriceInclTax, 0.1, 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Mix, 'Discount not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Code", DiscountCode, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Excl. VAT", FirstDiscountPriceExclTax, 0.1, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Incl. VAT", UnitPriceInclTax * FirstLevelQty - FirstLevelAmount, 0.1, 'Discount not calculated according to scenario');

        // [GIVEN] Second level discount quantity on retail journal line
        RetailJournalLine.Validate("Quantity for Discount Calc", SecondLevelQty);
        // [THEN] Check if discount and prices are calculated correctly
        Assert.AreNearlyEqual(RetailJournalLine."Unit Price", UnitPriceInclTax, 0.1, 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Mix, 'Discount not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Code", DiscountCode, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Excl. VAT", SecondDiscountPriceExclTax, 0.1, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Incl. VAT", UnitPriceInclTax * SecondLevelQty - SecondLevelAmount, 0.1, 'Discount not calculated according to scenario');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckPricesItemPriceIncludesVATItemWithoutVATMixDiscountMultipleDiscountLevels()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
        DiscountCode: Code[20];
        FirstLevelQty: Integer;
        SecondLevelQty: Integer;
        FirstLevelAmount: Decimal;
        SecondLevelAmount: Decimal;
    begin
        // [SCENARIO] Check prices when having item on retail journal which has mix discount multiple discount levels. Item price includes vat = true + item without VAT

        Initialize();

        // [GIVEN] VAT Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify(true);
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price, price includes vat = true, item without VAT
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 2000;
        Item.Modify();

        // [GIVEN] Mixed discount multiple discount levels
        FirstLevelQty := 2;
        FirstLevelAmount := 100;
        SecondLevelQty := 3;
        SecondLevelAmount := 400;
        DiscountCode := LibraryPOSDiscount.CreateMultipleDiscountLevels(Item, FirstLevelQty, SecondLevelQty, FirstLevelAmount, SecondLevelAmount, false);

        // [GIVEN] Item added to retail journal
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        RetailJournalLine.Insert();

        // [GIVEN] First level discount quantity on retail journal line
        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();
        RetailJournalLine.Validate("Quantity for Discount Calc", FirstLevelQty);
        // [THEN] Check if discount and prices are calculated correctly
        Assert.AreNearlyEqual(RetailJournalLine."Unit Price", Item."Unit Price", 0.1, 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Mix, 'Discount not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Code", DiscountCode, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Excl. VAT", Item."Unit Price" * FirstLevelQty - FirstLevelAmount, 0.1, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Incl. VAT", Item."Unit Price" * FirstLevelQty - FirstLevelAmount, 0.1, 'Discount not calculated according to scenario');

        // [GIVEN] Second level discount quantity on retail journal line
        RetailJournalLine.Validate("Quantity for Discount Calc", SecondLevelQty);
        // [THEN] Check if discount and prices are calculated correctly
        Assert.AreNearlyEqual(RetailJournalLine."Unit Price", Item."Unit Price", 0.1, 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Mix, 'Discount not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Code", DiscountCode, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Excl. VAT", Item."Unit Price" * SecondLevelQty - SecondLevelAmount, 0.1, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Incl. VAT", Item."Unit Price" * SecondLevelQty - SecondLevelAmount, 0.1, 'Discount not calculated according to scenario');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckPricesItemPriceIncludesVATItemWithVATMixDiscountMultipleDiscountLevels()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
        DiscountCode: Code[20];
        FirstLevelQty: Integer;
        SecondLevelQty: Integer;
        FirstLevelAmount: Decimal;
        SecondLevelAmount: Decimal;
        FirstDiscountPriceExclTax: Decimal;
        SecondDiscountPriceExclTax: Decimal;
    begin
        // [SCENARIO] Check prices when having item on retail journal which has mix discount multiple discount levels. Item price includes vat = true + item with VAT

        Initialize();

        // [GIVEN] VAT Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price, price includes vat = true, item with VAT
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 2000;
        Item.Modify();

        // [GIVEN] Mixed discount multiple discount levels
        FirstLevelQty := 2;
        FirstLevelAmount := 100;
        SecondLevelQty := 3;
        SecondLevelAmount := 400;
        DiscountCode := LibraryPOSDiscount.CreateMultipleDiscountLevels(Item, FirstLevelQty, SecondLevelQty, FirstLevelAmount, SecondLevelAmount, false);

        // [GIVEN] Item added to retail journal
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        FirstDiscountPriceExclTax := POSSaleTaxCalc.CalcAmountWithoutVAT(Item."Unit Price" * FirstLevelQty - FirstLevelAmount, VATPostingSetup."VAT %", GeneralLedgerSetup."Amount Rounding Precision");
        SecondDiscountPriceExclTax := POSSaleTaxCalc.CalcAmountWithoutVAT(Item."Unit Price" * SecondLevelQty - SecondLevelAmount, VATPostingSetup."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [GIVEN] First level discount quantity on retail journal line
        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();
        RetailJournalLine.Validate("Quantity for Discount Calc", FirstLevelQty);
        // [THEN] Check if discount and prices are calculated correctly
        Assert.AreNearlyEqual(RetailJournalLine."Unit Price", Item."Unit Price", 0.1, 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Mix, 'Discount not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Code", DiscountCode, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Excl. VAT", FirstDiscountPriceExclTax, 0.1, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Incl. VAT", Item."Unit Price" * FirstLevelQty - FirstLevelAmount, 0.1, 'Discount not calculated according to scenario');

        // [GIVEN] Second level discount quantity on retail journal line
        RetailJournalLine.Validate("Quantity for Discount Calc", SecondLevelQty);
        // [THEN] Check if discount and prices are calculated correctly
        Assert.AreNearlyEqual(RetailJournalLine."Unit Price", Item."Unit Price", 0.1, 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Mix, 'Discount not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Code", DiscountCode, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Excl. VAT", SecondDiscountPriceExclTax, 0.1, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Incl. VAT", Item."Unit Price" * SecondLevelQty - SecondLevelAmount, 0.1, 'Discount not calculated according to scenario');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckPricesItemPriceNotIncludesVATItemWithoutVATPeriodDiscount()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        PeriodDiscountLine: Record "NPR Period Discount Line";
        POSPeriodDiscandTax: Codeunit "NPR POS Period Disc. and Tax";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
    begin
        // [SCENARIO] Check prices when having item on retail journal which has period discount. Item price includes vat = false + item without VAT

        Initialize();

        // [GIVEN] VAT Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify(true);
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price, price includes vat = false, item without VAT
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);
        Item."Unit Price" := 2000;
        Item.Modify();

        // [GIVEN] Period discount
        POSPeriodDiscandTax.CreateDiscount(Item, 30, PeriodDiscountLine);

        // [GIVEN] Item added to retail journal
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();

        // [THEN] Check if discount and prices are calculated correctly
        Assert.AreNearlyEqual(RetailJournalLine."Unit Price", Item."Unit Price", 0.1, 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Campaign, 'Discount not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Code", PeriodDiscountLine.Code, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Excl. VAT", Item."Unit Price" - PeriodDiscountLine."Discount Amount", 0.1, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Incl. VAT", Item."Unit Price" - PeriodDiscountLine."Discount Amount", 0.1, 'Discount not calculated according to scenario');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckPricesItemPriceNotIncludesVATItemWithVATPeriodDiscount()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        PeriodDiscountLine: Record "NPR Period Discount Line";
        POSPeriodDiscandTax: Codeunit "NPR POS Period Disc. and Tax";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
        UnitPriceInclTax: Decimal;
    begin
        // [SCENARIO] Check prices when having item on retail journal which has period discount. Item price includes vat = false + item with VAT

        Initialize();

        // [GIVEN] VAT Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price, price includes vat = false, item with VAT
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);
        Item."Unit Price" := 2000;
        Item.Modify();

        // [GIVEN] Period discount
        POSPeriodDiscandTax.CreateDiscount(Item, 30, PeriodDiscountLine);

        // [GIVEN] Item added to retail journal
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        UnitPriceInclTax := POSSaleTaxCalc.CalcAmountWithVAT(Item."Unit Price", VATPostingSetup."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if discount and prices are calculated correctly
        Assert.AreNearlyEqual(RetailJournalLine."Unit Price", UnitPriceInclTax, 0.1, 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Campaign, 'Discount not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Code", PeriodDiscountLine.Code, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Excl. VAT", Item."Unit Price" - PeriodDiscountLine."Discount Amount", 0.1, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Incl. VAT", UnitPriceInclTax * (1 - PeriodDiscountLine."Discount %" / 100), 0.1, 'Discount not calculated according to scenario');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckPricesItemPriceIncludesVATItemWithoutVATPeriodDiscount()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        PeriodDiscountLine: Record "NPR Period Discount Line";
        POSPeriodDiscandTax: Codeunit "NPR POS Period Disc. and Tax";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
    begin
        // [SCENARIO] Check prices when having item on retail journal which has period discount. Item price includes vat = true + item without VAT

        Initialize();

        // [GIVEN] VAT Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify(true);
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price, price includes vat = true, item without VAT
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 2000;
        Item.Modify();

        // [GIVEN] Period discount
        POSPeriodDiscandTax.CreateDiscount(Item, 30, PeriodDiscountLine);

        // [GIVEN] Item added to retail journal
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();

        // [THEN] Check if discount and prices are calculated correctly
        Assert.AreNearlyEqual(RetailJournalLine."Unit Price", Item."Unit Price", 0.1, 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Campaign, 'Discount not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Code", PeriodDiscountLine.Code, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Excl. VAT", Item."Unit Price" - PeriodDiscountLine."Discount Amount", 0.1, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Incl. VAT", Item."Unit Price" - PeriodDiscountLine."Discount Amount", 0.1, 'Discount not calculated according to scenario');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckPricesItemPriceIncludesVATItemWithVATPeriodDiscount()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        PeriodDiscountLine: Record "NPR Period Discount Line";
        POSPeriodDiscandTax: Codeunit "NPR POS Period Disc. and Tax";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
        DiscountPriceExclTax: Decimal;
    begin
        // [SCENARIO] Check prices when having item on retail journal which has period discount. Item price includes vat = true + item with VAT

        Initialize();

        // [GIVEN] VAT Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price, price includes vat = true, item with VAT
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 2000;
        Item.Modify();

        // [GIVEN] Period discount
        POSPeriodDiscandTax.CreateDiscount(Item, 30, PeriodDiscountLine);

        // [GIVEN] Item added to retail journal
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        DiscountPriceExclTax := POSSaleTaxCalc.CalcAmountWithoutVAT(Item."Unit Price" - PeriodDiscountLine."Discount Amount", VATPostingSetup."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if discount and prices are calculated correctly
        Assert.AreNearlyEqual(RetailJournalLine."Unit Price", Item."Unit Price", 0.1, 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Campaign, 'Discount not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Code", PeriodDiscountLine.Code, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Excl. VAT", DiscountPriceExclTax, 0.1, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Incl. VAT", Item."Unit Price" - PeriodDiscountLine."Discount Amount", 0.1, 'Discount not calculated according to scenario');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckPricesItemPriceNotIncludesVATItemWithoutVATQuantityDiscount()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
        POSQtyDiscandTax: Codeunit "NPR POS Qty. Disc. and Tax";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
        QtyForDiscCalc: Integer;
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        DiscountPriceExclTax: Decimal;
    begin
        // [SCENARIO] Check prices above when having item on retail journal which has quantity discount. Item price includes vat = false + item without VAT

        Initialize();

        // [GIVEN] VAT Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify(true);
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price, price includes vat = false, item without VAT
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);
        Item."Unit Price" := 2000;
        Item.Modify();

        // [GIVEN] Quantity discount
        POSQtyDiscandTax.CreateDiscount(Item, 30, QuantityDiscountLine);

        // [GIVEN] Item added to retail journal
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        QtyForDiscCalc := 2;
        RetailJournalLine.Validate("Quantity for Discount Calc", QtyForDiscCalc);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();
        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := QtyForDiscCalc * Item."Unit Price" * LineDiscPct / 100;
        DiscountPriceExclTax := QtyForDiscCalc * Item."Unit Price" - LineDiscAmt;

        // [THEN] Check if discount and prices are calculated correctly
        Assert.AreNearlyEqual(RetailJournalLine."Unit Price", Item."Unit Price", 0.1, 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Quantity, 'Discount not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Code", QuantityDiscountLine."Main no.", 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Excl. VAT", DiscountPriceExclTax, 0.1, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Incl. VAT", DiscountPriceExclTax, 0.1, 'Discount not calculated according to scenario');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckPricesItemPriceNotIncludesVATItemWithVATQuantityDiscount()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
        POSQtyDiscandTax: Codeunit "NPR POS Qty. Disc. and Tax";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
        QtyForDiscCalc: Integer;
        UnitPriceInclTax: Decimal;
        DiscountPriceExclTax: Decimal;
        DiscountPriceInclTax: Decimal;
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
    begin
        // [SCENARIO] Check prices when having item on retail journal which has quantity discount. Item price includes vat = false + item with VAT

        Initialize();

        // [GIVEN] VAT Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price, price includes vat = false, item with VAT
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);
        Item."Unit Price" := 2000;
        Item.Modify();

        //[GIVEN] Quantity discount
        POSQtyDiscandTax.CreateDiscount(Item, 30, QuantityDiscountLine);

        // [GIVEN] Item added to retail journal
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        QtyForDiscCalc := 2;
        RetailJournalLine.Validate("Quantity for Discount Calc", QtyForDiscCalc);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        UnitPriceInclTax := POSSaleTaxCalc.CalcAmountWithVAT(Item."Unit Price", VATPostingSetup."VAT %", GeneralLedgerSetup."Amount Rounding Precision");
        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := QtyForDiscCalc * Item."Unit Price" * LineDiscPct / 100;
        DiscountPriceExclTax := QtyForDiscCalc * Item."Unit Price" - LineDiscAmt;
        DiscountPriceInclTax := POSSaleTaxCalc.CalcAmountWithVAT(DiscountPriceExclTax, VATPostingSetup."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if discount and prices are calculated correctly
        Assert.AreNearlyEqual(RetailJournalLine."Unit Price", UnitPriceInclTax, 0.1, 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Quantity, 'Discount not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Code", QuantityDiscountLine."Main no.", 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Excl. VAT", DiscountPriceExclTax, 0.1, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Incl. VAT", DiscountPriceInclTax, 0.1, 'Discount not calculated according to scenario');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckPricesItemPriceIncludesVATItemWithoutVATQuantityDiscount()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
        POSQtyDiscandTax: Codeunit "NPR POS Qty. Disc. and Tax";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
        QtyForDiscCalc: Integer;
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        DiscountPriceInclTax: Decimal;
    begin
        // [SCENARIO] Check prices when having item on retail journal which has quantity discount. Item price includes vat = true + item without VAT

        Initialize();

        // [GIVEN] VAT Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify(true);
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price, price includes vat = true, item without VAT
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 2000;
        Item.Modify();

        // [GIVEN] Quantity discount
        POSQtyDiscandTax.CreateDiscount(Item, 30, QuantityDiscountLine);

        // [GIVEN] Item added to retail journal
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        QtyForDiscCalc := 2;
        RetailJournalLine.Validate("Quantity for Discount Calc", QtyForDiscCalc);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();
        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := QtyForDiscCalc * Item."Unit Price" * LineDiscPct / 100;
        DiscountPriceInclTax := QtyForDiscCalc * Item."Unit Price" - LineDiscAmt;

        // [THEN] Check if discount and prices are calculated correctly
        Assert.AreNearlyEqual(RetailJournalLine."Unit Price", Item."Unit Price", 0.1, 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Quantity, 'Discount not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Code", QuantityDiscountLine."Main no.", 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Excl. VAT", DiscountPriceInclTax, 0.1, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Incl. VAT", DiscountPriceInclTax, 0.1, 'Discount not calculated according to scenario');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckPricesItemPriceIncludesVATItemWithVATQuantityDiscount()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
        POSQtyDiscandTax: Codeunit "NPR POS Qty. Disc. and Tax";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
        QtyForDiscCalc: Integer;
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        DiscountPriceExclTax: Decimal;
        DiscountPriceInclTax: Decimal;
    begin
        // [SCENARIO] Check prices when having item on retail journal which has quantity discount. Item price includes vat = true + item with VAT

        Initialize();

        // [GIVEN] VAT Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price, price includes vat = true, item with VAT
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 2000;
        Item.Modify();

        // [GIVEN] Quantity discount
        POSQtyDiscandTax.CreateDiscount(Item, 30, QuantityDiscountLine);

        // [GIVEN] Item added to retail journal
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        QtyForDiscCalc := 2;
        RetailJournalLine.Validate("Quantity for Discount Calc", QtyForDiscCalc);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        LineDiscPct := 100 - QuantityDiscountLine."Unit Price" / Item."Unit Price" * 100;
        LineDiscAmt := QtyForDiscCalc * Item."Unit Price" * LineDiscPct / 100;
        DiscountPriceInclTax := QtyForDiscCalc * Item."Unit Price" - LineDiscAmt;
        DiscountPriceExclTax := POSSaleTaxCalc.CalcAmountWithoutVAT(DiscountPriceInclTax, VATPostingSetup."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if discount and prices are calculated correctly
        Assert.AreNearlyEqual(RetailJournalLine."Unit Price", Item."Unit Price", 0.1, 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Quantity, 'Discount not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Code", QuantityDiscountLine."Main no.", 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Excl. VAT", DiscountPriceExclTax, 0.1, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Incl. VAT", DiscountPriceInclTax, 0.1, 'Discount not calculated according to scenario');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckPricesItemPriceNotIncludesVATItemWithoutVATPriceListDiscount()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        POSCustoDiscandTax: Codeunit "NPR POS Cust. Disc. and Tax";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        DiscountPriceInclTax: Decimal;
    begin
        // [SCENARIO] Check prices when having item on retail journal which has price list line discount. Item price includes vat = false + item without VAT

        Initialize();

        // [GIVEN] VAT Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify(true);
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price, price includes vat = false, item without VAT
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);
        Item."Unit Price" := 2000;
        Item.Modify();

        // [GIVEN] Price List discount
        LineDiscPct := POSCustoDiscandTax.CreateDiscount(Item, 60);

        // [GIVEN] Item added to retail journal
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();
        LineDiscAmt := Item."Unit Price" * LineDiscPct / 100;
        DiscountPriceInclTax := Item."Unit Price" - LineDiscAmt;

        // [THEN] Check if discount and prices are calculated correctly
        Assert.AreNearlyEqual(RetailJournalLine."Unit Price", Item."Unit Price", 0.1, 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Customer, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Excl. VAT", DiscountPriceInclTax, 0.1, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Incl. VAT", DiscountPriceInclTax, 0.1, 'Discount not calculated according to scenario');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckPricesItemPriceNotIncludesVATItemWithVATPriceListDiscount()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        POSCustoDiscandTax: Codeunit "NPR POS Cust. Disc. and Tax";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
        UnitPriceInclTax: Decimal;
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        DiscountPriceExclTax: Decimal;
        DiscountPriceInclTax: Decimal;
    begin
        // [SCENARIO] Check prices when having item on retail journal which has price list line discount. Item price includes vat = false + item with VAT

        Initialize();

        // [GIVEN] VAT Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price, price includes vat = false, item with VAT
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);
        Item."Unit Price" := 2000;
        Item.Modify();

        // [GIVEN] Price List discount
        LineDiscPct := POSCustoDiscandTax.CreateDiscount(Item, 60);

        // [GIVEN] Item added to retail journal
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        UnitPriceInclTax := POSSaleTaxCalc.CalcAmountWithVAT(Item."Unit Price", VATPostingSetup."VAT %", GeneralLedgerSetup."Amount Rounding Precision");
        LineDiscAmt := Item."Unit Price" * LineDiscPct / 100;
        DiscountPriceExclTax := Item."Unit Price" - LineDiscAmt;
        DiscountPriceInclTax := POSSaleTaxCalc.CalcAmountWithVAT(DiscountPriceExclTax, VATPostingSetup."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if discount and prices are calculated correctly
        Assert.AreNearlyEqual(RetailJournalLine."Unit Price", UnitPriceInclTax, 0.1, 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Customer, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Excl. VAT", DiscountPriceExclTax, 0.1, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Incl. VAT", DiscountPriceInclTax, 0.1, 'Discount not calculated according to scenario');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckPricesItemPriceIncludesVATItemWithoutVATPriceListDiscount()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        POSCustoDiscandTax: Codeunit "NPR POS Cust. Disc. and Tax";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        DiscountPriceInclTax: Decimal;
    begin
        // [SCENARIO] Check prices when having item on retail journal which has price list line discount. Item price includes vat = true + item without VAT

        Initialize();

        // [GIVEN] VAT Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 0;
        VATPostingSetup.Modify(true);
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price, price includes vat = true, item without VAT
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 2000;
        Item.Modify();

        // [GIVEN] Price List discount
        LineDiscPct := POSCustoDiscandTax.CreateDiscount(Item, 60);

        // [GIVEN] Item added to retail journal
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();
        LineDiscAmt := Item."Unit Price" * LineDiscPct / 100;
        DiscountPriceInclTax := Item."Unit Price" - LineDiscAmt;

        // [THEN] Check if discount and prices are calculated correctly
        Assert.AreNearlyEqual(RetailJournalLine."Unit Price", Item."Unit Price", 0.1, 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Customer, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Excl. VAT", DiscountPriceInclTax, 0.1, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Incl. VAT", DiscountPriceInclTax, 0.1, 'Discount not calculated according to scenario');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckPricesItemPriceIncludesVATItemWithVATPriceListDiscount()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        POSCustoDiscandTax: Codeunit "NPR POS Cust. Disc. and Tax";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
        LineDiscPct: Decimal;
        LineDiscAmt: Decimal;
        DiscountPriceExclTax: Decimal;
        DiscountPriceInclTax: Decimal;
    begin
        // [SCENARIO] Check prices when having item on retail journal which has price list line discount. Item price includes vat = true + item with VAT

        Initialize();

        // [GIVEN] VAT Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price, price includes vat = true, item with VAT
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 2000;
        Item.Modify();

        // [GIVEN] Price List discount
        LineDiscPct := POSCustoDiscandTax.CreateDiscount(Item, 60);

        // [GIVEN] Item added to retail journal
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        LineDiscAmt := Item."Unit Price" * LineDiscPct / 100;
        DiscountPriceInclTax := Item."Unit Price" - LineDiscAmt;
        DiscountPriceExclTax := POSSaleTaxCalc.CalcAmountWithoutVAT(DiscountPriceInclTax, VATPostingSetup."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if discount and prices are calculated correctly
        Assert.AreNearlyEqual(RetailJournalLine."Unit Price", Item."Unit Price", 0.1, 'Unit Price not calculated according to scenario');
        Assert.AreEqual(RetailJournalLine."Discount Type", RetailJournalLine."Discount Type"::Customer, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Excl. VAT", DiscountPriceExclTax, 0.1, 'Discount not calculated according to scenario');
        Assert.AreNearlyEqual(RetailJournalLine."Discount Price Incl. VAT", DiscountPriceInclTax, 0.1, 'Discount not calculated according to scenario');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UnitPriceDoesNotDriftFromInclVATItemUnderWholeUnitRounding()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
    begin
        // [SCENARIO] CORE-339: A 172 NOK item entered incl. VAT @ 15% must yield Unit Price 172 on the retail journal line
        // (matching the live POS sale line and the item card), not 173 as the menu API previously returned because it
        // round-tripped through an excl. VAT base (172 -> 149.57 -> round to 150 -> *1.15 = 172.5 -> round to 173) when
        // "Unit-Amount Rounding Precision" is whole units.

        Initialize();

        // [GIVEN] Whole-unit Unit-Amount/Amount Rounding Precision (Norwegian setup that surfaces the bug)
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Unit-Amount Rounding Precision" := 1;
        GeneralLedgerSetup."Amount Rounding Precision" := 0.01;
        GeneralLedgerSetup.Modify();

        // [GIVEN] VAT Posting Setup with 15% VAT
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 15;
        VATPostingSetup.Modify(true);
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with "Price Includes VAT" = true and Unit Price 172
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 172;
        Item.Modify();

        // [WHEN] Item is added to a retail journal line
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();

        // [THEN] The stored Unit Price matches the item card (172), no rounding drift to 173
        Assert.AreEqual(172, RetailJournalLine."Unit Price", 'Unit Price drifted from incl. VAT item price - rounding round-trip through excl. VAT base regressed (CORE-339).');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UnitPriceDoesNotDriftFromInclVATItemAtDefaultRounding()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
    begin
        // [SCENARIO] CORE-339: Even without configuring "Unit-Amount Rounding Precision" (i.e. whatever the standard BC
        // default is), an incl. VAT item priced 172 @ 15% VAT must yield Unit Price 172 on the retail journal line.
        // Before the fix, stripping VAT to 149.5652..., rounding, then re-adding VAT introduced a small (0.01) drift
        // that this exact-equality assertion would catch.

        Initialize();

        // [GIVEN] VAT Posting Setup with 15% VAT - "Unit-Amount Rounding Precision" left at whatever GLSetup default is
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 15;
        VATPostingSetup.Modify(true);
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with "Price Includes VAT" = true and Unit Price 172
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 172;
        Item.Modify();

        // [WHEN] Item is added to a retail journal line
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();

        // [THEN] The stored Unit Price exactly equals the item card price (no drift, even sub-NOK)
        Assert.AreEqual(172, RetailJournalLine."Unit Price", 'Unit Price drifted from incl. VAT item price at default rounding precision (CORE-339).');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure InclVATItemWithDiscountDoesNotDriftUnderWholeUnitRounding()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        POSCustoDiscandTax: Codeunit "NPR POS Cust. Disc. and Tax";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
        LineDiscPct: Decimal;
        ExpectedDiscountPriceInclTax: Decimal;
        ExpectedDiscountPriceExclTax: Decimal;
    begin
        // [SCENARIO] CORE-339 (discounted variant): With whole-unit "Unit-Amount Rounding Precision", an incl. VAT item that
        // also has a customer line discount must keep the Unit Price aligned with the item card and derive both
        // Discount Price Incl. VAT and Discount Price Excl. VAT consistently from the same incl. VAT base.

        Initialize();

        // [GIVEN] Whole-unit Unit-Amount Rounding Precision (Norwegian setup that surfaces the bug)
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Unit-Amount Rounding Precision" := 1;
        GeneralLedgerSetup."Amount Rounding Precision" := 0.01;
        GeneralLedgerSetup.Modify();

        // [GIVEN] VAT Posting Setup with 15% VAT
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 15;
        VATPostingSetup.Modify(true);
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with "Price Includes VAT" = true and Unit Price 172
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 172;
        Item.Modify();

        // [GIVEN] 25% customer line discount on the item
        LineDiscPct := POSCustoDiscandTax.CreateDiscount(Item, 25);

        // [WHEN] Item is added to a retail journal line
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();

        ExpectedDiscountPriceInclTax := Item."Unit Price" * (1 - LineDiscPct / 100);
        ExpectedDiscountPriceExclTax := POSSaleTaxCalc.CalcAmountWithoutVAT(ExpectedDiscountPriceInclTax, VATPostingSetup."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] The unit price and discount fields stay aligned with the item card incl. VAT base
        Assert.AreEqual(172, RetailJournalLine."Unit Price", 'Unit Price drifted under whole-unit rounding for discounted incl. VAT item (CORE-339).');
        Assert.AreEqual(VATPostingSetup."VAT %", RetailJournalLine."VAT %", 'VAT % not propagated from posting setup.');
        Assert.AreEqual(RetailJournalLine."Discount Type"::Customer, RetailJournalLine."Discount Type", 'Discount Type not Customer.');
        Assert.AreEqual(LineDiscPct, RetailJournalLine."Discount Pct.", 'Discount % not propagated.');
        Assert.AreNearlyEqual(ExpectedDiscountPriceInclTax, RetailJournalLine."Discount Price Incl. Vat", 0.01, 'Discount Price Incl. VAT drifted under whole-unit rounding (CORE-339).');
        Assert.AreNearlyEqual(ExpectedDiscountPriceExclTax, RetailJournalLine."Discount Price Excl. VAT", 0.01, 'Discount Price Excl. VAT drifted under whole-unit rounding (CORE-339).');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExclVATItemUnderWholeUnitRoundingProducesInclVATUnitPrice()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
    begin
        // [SCENARIO] CORE-339 regression guard for the excl. VAT branch: when the item is stored without VAT, the retail
        // journal must still expose the incl. VAT Unit Price (excl + VAT) under whole-unit rounding. The fix's new
        // conditional must not regress this path - it should continue to call CalcAmountWithVAT.

        Initialize();

        // [GIVEN] Whole-unit Unit-Amount Rounding Precision (Norwegian setup)
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Unit-Amount Rounding Precision" := 1;
        GeneralLedgerSetup."Amount Rounding Precision" := 0.01;
        GeneralLedgerSetup.Modify();

        // [GIVEN] VAT Posting Setup with 15% VAT
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 15;
        VATPostingSetup.Modify(true);
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with "Price Includes VAT" = false and Unit Price 100 excl. VAT
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);
        Item."Unit Price" := 100;
        Item.Modify();

        // [WHEN] Item is added to a retail journal line
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();

        // [THEN] The stored Unit Price equals item price + 15% VAT, rounded to whole units (100 * 1.15 = 115)
        Assert.AreEqual(115, RetailJournalLine."Unit Price", 'Excl. VAT path regressed - Unit Price did not equal Item.Unit Price * (1 + VAT/100) under whole-unit rounding (CORE-339).');
        Assert.AreEqual(VATPostingSetup."VAT %", RetailJournalLine."VAT %", 'VAT % not propagated from posting setup.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExclVATItemWithDiscountUnderWholeUnitRounding()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        POSCustoDiscandTax: Codeunit "NPR POS Cust. Disc. and Tax";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Assert: Codeunit Assert;
        RetailJournalNo: Text;
        LineDiscPct: Decimal;
        ExpectedDiscountPriceExclTax: Decimal;
        ExpectedDiscountPriceInclTax: Decimal;
    begin
        // [SCENARIO] CORE-339 regression guard for the excl. VAT + discount branch: when the item is stored without VAT
        // and has a customer line discount, the retail journal must still expose the correct incl. and excl. VAT prices
        // after discount under whole-unit rounding. The fix must not regress this path.

        Initialize();

        // [GIVEN] Whole-unit Unit-Amount Rounding Precision (Norwegian setup)
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Unit-Amount Rounding Precision" := 1;
        GeneralLedgerSetup."Amount Rounding Precision" := 0.01;
        GeneralLedgerSetup.Modify();

        // [GIVEN] VAT Posting Setup with 15% VAT
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 15;
        VATPostingSetup.Modify(true);
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with "Price Includes VAT" = false and Unit Price 100 excl. VAT
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);
        Item."Unit Price" := 100;
        Item.Modify();

        // [GIVEN] 25% customer line discount on the item
        LineDiscPct := POSCustoDiscandTax.CreateDiscount(Item, 25);

        // [WHEN] Item is added to a retail journal line
        RetailJournalNo := Format(CreateGuid());
        RetailJournalLine.SelectRetailJournal(RetailJournalNo);
        RetailJournalLine.InitLine();
        RetailJournalLine.SetItem(Item."No.", '', '');
        RetailJournalLine.Validate("Quantity to Print", 1);
        RetailJournalLine.Insert();

        RetailJournalLine.SetRange("No.", RetailJournalNo);
        RetailJournalLine.FindFirst();

        ExpectedDiscountPriceExclTax := Item."Unit Price" * (1 - LineDiscPct / 100);
        ExpectedDiscountPriceInclTax := POSSaleTaxCalc.CalcAmountWithVAT(ExpectedDiscountPriceExclTax, VATPostingSetup."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Unit price equals Item.Unit Price * (1 + VAT/100), discount fields are consistent excl/incl pair
        Assert.AreEqual(115, RetailJournalLine."Unit Price", 'Excl. VAT path regressed - Unit Price did not equal Item.Unit Price * (1 + VAT/100) under whole-unit rounding (CORE-339).');
        Assert.AreEqual(VATPostingSetup."VAT %", RetailJournalLine."VAT %", 'VAT % not propagated from posting setup.');
        Assert.AreEqual(RetailJournalLine."Discount Type"::Customer, RetailJournalLine."Discount Type", 'Discount Type not Customer.');
        Assert.AreEqual(LineDiscPct, RetailJournalLine."Discount Pct.", 'Discount % not propagated.');
        Assert.AreNearlyEqual(ExpectedDiscountPriceExclTax, RetailJournalLine."Discount Price Excl. VAT", 0.01, 'Discount Price Excl. VAT drifted on excl. VAT discounted path (CORE-339).');
        Assert.AreNearlyEqual(ExpectedDiscountPriceInclTax, RetailJournalLine."Discount Price Incl. Vat", 0.01, 'Discount Price Incl. VAT drifted on excl. VAT discounted path (CORE-339).');
    end;

    local procedure Initialize()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryERM: Codeunit "Library - ERM";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        //Clean any previous mock session
        POSSession.ClearAll();
        Clear(POSSession);

        if not Initialized then begin
            WorkDate(Today);

            LibraryERM.CreateVATBusinessPostingGroup(VATBusinessPostingGroup);
            NPRLibraryPOSMasterData.CreatePOSSetup(POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            NPRLibraryPOSMasterData.CreatePOSStore(POSStore, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(POSUnit, POSStore.Code, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
            NPRLibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethodCash, POSPaymentMethodCash."Processing Type"::CASH, '', false);

            Initialized := true;
        end;
        Commit();
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
}