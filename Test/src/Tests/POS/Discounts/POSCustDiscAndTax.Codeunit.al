codeunit 85031 "NPR POS Cust. Disc. and Tax"
{
    // [Feature] POS Customer Discount
    // NOTE: Replace Sales Line Discount with V16 implementation

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
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        // [GIVEN] Customer Discount
        CreateDiscount(Item, LibraryRandom.RandDecInRange(1, 100, 5));

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
        POSViewProfile: Record "NPR POS View Profile";
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

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Tax Type" := POSViewProfile."Tax Type"::VAT;
        POSViewProfile.Modify();
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 9);

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
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Customer, 'Customer Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Customer Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'SalesLineDiscount."Line Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Item."Unit Price" - (Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Item."Unit Price" - (Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForNormalTaxInDirectSaleQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSViewProfile: Record "NPR POS View Profile";
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

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Tax Type" := POSViewProfile."Tax Type"::VAT;
        POSViewProfile.Modify();
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 9);

        Qty := Round(1 / 3, 0.00001);
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
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Customer, 'Customer Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Customer Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'SalesLineDiscount."Line Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForNormalTaxInDebitSaleForward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
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
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

        UnitPrice := Item."Unit Price" / (1 + VATPostingSetup."VAT %" / 100);
        LineDiscAmt := (Item."Unit Price" * LineDiscPct / 100) / (1 + VATPostingSetup."VAT %" / 100);
        LineAmtExclTax := UnitPrice - LineDiscAmt;
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
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Customer, 'Customer Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Customer Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'SalesLineDiscount."Line Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '((Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) / (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '((Item."Unit Price" - (Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) * (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '(Item."Unit Price" - (Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100))  <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForNormalTaxInDebitSaleForwardQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
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
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

        Qty := Round(2 / 3, 0.00001);
        UnitPrice := Item."Unit Price" / (1 + VATPostingSetup."VAT %" / 100);
        LineDiscAmt := (Qty * Item."Unit Price" * LineDiscPct / 100) / (1 + VATPostingSetup."VAT %" / 100);
        LineAmtExclTax := Qty * UnitPrice - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax * (1 + VATPostingSetup."VAT %" / 100);

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
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Customer, 'Customer Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Customer Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'SalesLineDiscount."Line Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '((Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) / (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '((Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) * (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100))  <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForNormalTaxInDebitSaleBackward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
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
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

        LineDiscAmt := Item."Unit Price" * LineDiscPct / 100;
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
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Customer, 'Customer Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Customer Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'SalesLineDiscount."Line Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Item."Unit Price" - (Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Item."Unit Price" - (Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForNormalTaxInDebitSaleBackwardQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
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
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

        Qty := 1 / 2;
        LineDiscAmt := Round(Qty * Item."Unit Price" * LineDiscPct / 100);
        LineAmtInclTax := Round(Qty * Item."Unit Price") - LineDiscAmt;
        LineAmtExclTax := Round(LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100));

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
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Customer, 'Customer Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Customer Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'SalesLineDiscount."Line Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(LineDiscAmt, POSSaleLine."Discount Amount", '(Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(LineAmtInclTax, POSSaleLine."Amount Including VAT", '(Item."Unit Price" - (Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(LineAmtExclTax, POSSaleLine.Amount, '((Item."Unit Price" - (Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine.Amount');
    end;

    [Test]
    procedure ApplyDiscountWhenEndSaleForNormalTaxInDirectSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSViewProfile: Record "NPR POS View Profile";
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

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Tax Type" := POSViewProfile."Tax Type"::VAT;
        POSViewProfile.Modify();
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 9);

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
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> GLEntry.Amount + GLEntry."VAT Amount"');
    end;

    [Test]
    procedure ApplyDiscountWhenEndSaleForNormalTaxInDirectSaleQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSViewProfile: Record "NPR POS View Profile";
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

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Tax Type" := POSViewProfile."Tax Type"::VAT;
        POSViewProfile.Modify();
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 9);

        Qty := Round(1 / 3, 0.00001);
        LineDiscAmt := Round(Qty * Item."Unit Price" * LineDiscPct / 100);
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
        Assert.AreEqual(Round(Qty * Item."Unit Price"), -(GLEntry.Amount + GLEntry."VAT Amount"), '(Qty * Item."Unit Price") <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> GLEntry.Amount + GLEntry."VAT Amount"');
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
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

        LineDiscAmt := Item."Unit Price" * LineDiscPct / 100;
        LineAmtExclTax := Item."Unit Price" - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax * (1 + VATPostingSetup."VAT %" / 100);

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
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> GLEntry.Amount + GLEntry."VAT Amount"');
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
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

        Qty := Round(2 / 3, 0.00001);
        LineDiscAmt := Round(Qty * Item."Unit Price" * LineDiscPct / 100);
        LineAmtExclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax * (1 + VATPostingSetup."VAT %" / 100);

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
        Assert.AreEqual(Round(Qty * Item."Unit Price"), -(GLEntry.Amount + GLEntry."VAT Amount"), '(Qty * Item."Unit Price") <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> GLEntry.Amount + GLEntry."VAT Amount"');
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
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

        LineDiscAmt := Item."Unit Price" * LineDiscPct / 100;
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
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> GLEntry.Amount + GLEntry."VAT Amount"');
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
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

        Qty := 1 / 2;
        LineDiscAmt := Round(Qty * Item."Unit Price" * LineDiscPct / 100);
        LineAmtInclTax := Round(Qty * Item."Unit Price") - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

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
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> GLEntry.Amount + GLEntry."VAT Amount"');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForRevChrgTaxInDirectSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSViewProfile: Record "NPR POS View Profile";
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

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Tax Type" := POSViewProfile."Tax Type"::VAT;
        POSViewProfile.Modify();
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 9);

        //Reverse Charge VAT
        VATPostingSetup."VAT %" := 0;

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
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Customer, 'Customer Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Customer Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'SalesLineDiscount."Line Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Item."Unit Price" - (Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Item."Unit Price" - (Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForRevChrgTaxInDirectSaleQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSViewProfile: Record "NPR POS View Profile";
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

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Tax Type" := POSViewProfile."Tax Type"::VAT;
        POSViewProfile.Modify();
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 9);

        //Reverse Charge VAT
        VATPostingSetup."VAT %" := 0;

        Qty := Round(1 / 3, 0.00001);
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
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Customer, 'Customer Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Customer Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'SalesLineDiscount."Line Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForRevChrgTaxInDebitSaleForward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
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
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

        //Reverse Charge VAT
        VATPostingSetup."VAT %" := 0;

        UnitPrice := Item."Unit Price" / (1 + VATPostingSetup."VAT %" / 100);
        LineDiscAmt := (Item."Unit Price" * LineDiscPct / 100) / (1 + VATPostingSetup."VAT %" / 100);
        LineAmtExclTax := UnitPrice - LineDiscAmt;
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
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Customer, 'Customer Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Customer Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'SalesLineDiscount."Line Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '((Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) / (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '((Item."Unit Price" - (Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) * (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '(Item."Unit Price" - (Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100))  <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForRevChrgTaxInDebitSaleForwardQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
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
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is created

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, false, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

        //Reverse Charge VAT
        VATPostingSetup."VAT %" := 0;

        Qty := Round(2 / 3, 0.00001);
        UnitPrice := Item."Unit Price" / (1 + VATPostingSetup."VAT %" / 100);
        LineDiscAmt := (Qty * Item."Unit Price" * LineDiscPct / 100) / (1 + VATPostingSetup."VAT %" / 100);
        LineAmtExclTax := Qty * UnitPrice - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax * (1 + VATPostingSetup."VAT %" / 100);

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
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Customer, 'Customer Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Customer Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'SalesLineDiscount."Line Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '((Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) / (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '((Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) * (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100))  <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForRevChrgTaxInDebitSaleBackward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
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
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

        //Reverse Charge VAT
        VATPostingSetup."VAT %" := 0;

        LineDiscAmt := Item."Unit Price" * LineDiscPct / 100;
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
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Customer, 'Customer Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Customer Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'SalesLineDiscount."Line Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Item."Unit Price" - (Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Item."Unit Price" - (Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForRevChrgTaxInDebitSaleBackwardQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
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
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is created

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, true, true);

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

        //Reverse Charge VAT
        VATPostingSetup."VAT %" := 0;

        Qty := 1 / 2;
        LineDiscAmt := Round(Qty * Item."Unit Price" * LineDiscPct / 100);
        LineAmtInclTax := Round(Qty * Item."Unit Price") - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

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
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Customer, 'Customer Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Customer Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'SalesLineDiscount."Line Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(LineDiscAmt, POSSaleLine."Discount Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(LineAmtInclTax, POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(LineAmtExclTax, POSSaleLine.Amount, '((Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
    procedure ApplyDiscountWhenEndSaleForRevChrgTaxInDirectSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSViewProfile: Record "NPR POS View Profile";
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

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Tax Type" := POSViewProfile."Tax Type"::VAT;
        POSViewProfile.Modify();
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 9);

        //Reverse Charge VAT
        VATPostingSetup."VAT %" := 0;

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
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> GLEntry.Amount + GLEntry."VAT Amount"');
    end;

    [Test]
    procedure ApplyDiscountWhenEndSaleForRevChrgTaxInDirectSaleQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSViewProfile: Record "NPR POS View Profile";
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

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Tax Type" := POSViewProfile."Tax Type"::VAT;
        POSViewProfile.Modify();
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 9);

        //Reverse Charge VAT
        VATPostingSetup."VAT %" := 0;

        Qty := Round(1 / 3, 0.00001);
        LineDiscAmt := Round(Qty * Item."Unit Price" * LineDiscPct / 100);
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
        Assert.AreEqual(Round(Qty * Item."Unit Price"), -(GLEntry.Amount + GLEntry."VAT Amount"), '(Qty * Item."Unit Price" * 1) <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> GLEntry.Amount + GLEntry."VAT Amount"');
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
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

        //Reverse Charge VAT
        VATPostingSetup."VAT %" := 0;

        LineDiscAmt := Item."Unit Price" * LineDiscPct / 100;
        LineAmtExclTax := Item."Unit Price" - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax * (1 + VATPostingSetup."VAT %" / 100);

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
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> GLEntry.Amount + GLEntry."VAT Amount"');
    end;

    [Test]
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
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

        //Reverse Charge VAT
        VATPostingSetup."VAT %" := 0;

        Qty := Round(2 / 3, 0.00001);
        LineDiscAmt := Round(Qty * Item."Unit Price" * LineDiscPct / 100);
        LineAmtExclTax := ROund(Qty * Item."Unit Price") - LineDiscAmt;
        LineAmtInclTax := Round(LineAmtExclTax * (1 + VATPostingSetup."VAT %" / 100));

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
        Assert.AreEqual(Round(Qty * Item."Unit Price"), -(GLEntry.Amount + GLEntry."VAT Amount"), '(Qty * Item."Unit Price") <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> GLEntry.Amount + GLEntry."VAT Amount"');
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
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

        //Reverse Charge VAT
        VATPostingSetup."VAT %" := 0;

        LineDiscAmt := Item."Unit Price" * LineDiscPct / 100;
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
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> GLEntry.Amount + GLEntry."VAT Amount"');
    end;

    [Test]
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
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

        //Reverse Charge VAT
        VATPostingSetup."VAT %" := 0;

        Qty := 1 / 2;
        LineDiscAmt := Round(Qty * Item."Unit Price" * LineDiscPct / 100);
        LineAmtInclTax := Round(Qty * Item."Unit Price") - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

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
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> GLEntry.Amount + GLEntry."VAT Amount"');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForSaleTaxInDirectSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSViewProfile: Record "NPR POS View Profile";
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

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignTaxDetailToPOSPostingProfile(TaxArea.Code, true);

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Tax Type" := POSViewProfile."Tax Type"::"Sales Tax";
        POSViewProfile.Modify();
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 9);

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

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Customer, 'Customer Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Customer Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'SalesLineDiscount."Line Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) <> POSSaleLine.Amount');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) + TotalTax <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineCreatedForSaleTaxInDirectSaleQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSViewProfile: Record "NPR POS View Profile";
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

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignTaxDetailToPOSPostingProfile(TaxArea.Code, true);

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Tax Type" := POSViewProfile."Tax Type"::"Sales Tax";
        POSViewProfile.Modify();
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 9);

        Qty := Round(1 / 3, 0.00001);
        UnitPriceTaxable := Item."Unit Price" * (1 - LineDiscPct / 100);
        TotalTax := Round(Qty * UnitPriceTaxable * CityTaxRate / 100) +
                           Round(Qty * UnitPriceTaxable * CountyTaxRate / 100) +
                           Round(Qty * UnitPriceTaxable * StateTaxRate / 100);
        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
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
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Customer, 'Customer Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Customer Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'SalesLineDiscount."Line Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) <> POSSaleLine.Amount');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) + TotalTax <> POSSaleLine."Amount Including VAT"');
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
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        POSStore.GetProfile(POSPostingProfile);
        POSPostingProfile."Default POS Posting Setup" := POSPostingProfile."Default POS Posting Setup"::Customer;
        POSPostingProfile.Modify();

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

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

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Customer, 'Customer Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Customer Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'SalesLineDiscount."Line Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100))  <> POSSaleLine.Amount');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) + TotalTax <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
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
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        POSStore.GetProfile(POSPostingProfile);
        POSPostingProfile."Default POS Posting Setup" := POSPostingProfile."Default POS Posting Setup"::Customer;
        POSPostingProfile.Modify();

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

        Qty := Round(2 / 3, 0.00001);
        UnitPriceTaxable := Item."Unit Price" * (1 - LineDiscPct / 100);
        TotalTax := Round(Qty * UnitPriceTaxable * CityTaxRate / 100) +
                           Round(Qty * UnitPriceTaxable * CountyTaxRate / 100) +
                           Round(Qty * UnitPriceTaxable * StateTaxRate / 100);
        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
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
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Customer, 'Customer Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Customer Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'SalesLineDiscount."Line Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100))  <> POSSaleLine.Amount');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) + TotalTax <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
    procedure ApplyDiscountWhenEndSaleForSaleTaxInDirectSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSViewProfile: Record "NPR POS View Profile";
        POSEntry: Record "NPR POS Entry";
        GLEntry: Record "G/L Entry";
        TaxJurisdiction: Record "Tax Jurisdiction";
        TaxDetail: Record "Tax Detail";
        TaxArea: Record "Tax Area";
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

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Tax Type" := POSViewProfile."Tax Type"::"Sales Tax";
        POSViewProfile.Modify();
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Update rounding amount account
        UpdatePOSSalesRoundingAcc();

        // [GIVEN] Update Tax account (sales)
        UpdateTaxJurisdictionSalesAccounts(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 9);

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

        //Verify G/L Entry
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        GLEntry.SetRange("Posting Date", POSEntry."Posting Date");
        TaxJurisdiction.FindSet();
        repeat
            GLEntry.SetRange("G/L Account No.", TaxJurisdiction."Tax Account (Sales)");
            Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Account');
            Assert.AreEqual(LineAmtInclTax, -(GLEntry.Amount + GLEntry."VAT Amount"), 'Qty * Item."Unit Price" + TotalTax <> (GLEntry.Amount + GLEntry."VAT Amount")');
        until TaxJurisdiction.next() = 0;
    end;

    [Test]
    procedure ApplyDiscountWhenEndSaleForSaleTaxInDirectSaleQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSViewProfile: Record "NPR POS View Profile";
        POSEntry: Record "NPR POS Entry";
        GLEntry: Record "G/L Entry";
        TaxJurisdiction: Record "Tax Jurisdiction";
        TaxDetail: Record "Tax Detail";
        TaxArea: Record "Tax Area";
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

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Tax Type" := POSViewProfile."Tax Type"::"Sales Tax";
        POSViewProfile.Modify();
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Update rounding amount account
        UpdatePOSSalesRoundingAcc();

        // [GIVEN] Update Tax account (sales)
        UpdateTaxJurisdictionSalesAccounts(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 9);

        Qty := Round(2 / 3, 0.00001);
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

        //Verify G/L Entry
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        GLEntry.SetRange("Posting Date", POSEntry."Posting Date");
        TaxJurisdiction.FindSet();
        repeat
            GLEntry.SetRange("G/L Account No.", TaxJurisdiction."Tax Account (Sales)");
            Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Account');
            Assert.AreEqual(LineAmtInclTax, -(GLEntry.Amount + GLEntry."VAT Amount"), 'Qty * Item."Unit Price" + TotalTax <> (GLEntry.Amount + GLEntry."VAT Amount")');
        until TaxJurisdiction.next() = 0;
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
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        POSStore.GetProfile(POSPostingProfile);
        POSPostingProfile."Default POS Posting Setup" := POSPostingProfile."Default POS Posting Setup"::Customer;
        POSPostingProfile.Modify();

        // [GIVEN] Update rounding amount account
        UpdatePOSSalesRoundingAcc();

        // [GIVEN] Update Tax account (sales)
        UpdateTaxJurisdictionSalesAccounts(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

        Qty := 1;
        UnitPriceTaxable := Item."Unit Price" * (1 - LineDiscPct / 100);
        TotalTax := Qty * (Round(UnitPriceTaxable * CityTaxRate / 100) +
                   Round(UnitPriceTaxable * CountyTaxRate / 100) +
                   Round(UnitPriceTaxable * StateTaxRate / 100));

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

        //Verify G/L Entry
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        GLEntry.SetRange("Posting Date", POSEntry."Posting Date");
        TaxJurisdiction.FindSet();
        repeat
            GLEntry.SetRange("G/L Account No.", TaxJurisdiction."Tax Account (Sales)");
            Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Account');
            Assert.AreEqual(LineAmtInclTax, -(GLEntry.Amount + GLEntry."VAT Amount"), 'UnitPriceTaxable * Qty + TotalTax <> (GLEntry.Amount + GLEntry."VAT Amount")');
        until TaxJurisdiction.next() = 0;
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
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        POSStore.GetProfile(POSPostingProfile);
        POSPostingProfile."Default POS Posting Setup" := POSPostingProfile."Default POS Posting Setup"::Customer;
        POSPostingProfile.Modify();

        // [GIVEN] Update rounding amount account
        UpdatePOSSalesRoundingAcc();

        // [GIVEN] Update Tax account (sales)
        UpdateTaxJurisdictionSalesAccounts(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

        Qty := Round(1 / 3, 0.00001);
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

        //Verify G/L Entry
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        GLEntry.SetRange("Posting Date", POSEntry."Posting Date");
        TaxJurisdiction.FindSet();
        repeat
            GLEntry.SetRange("G/L Account No.", TaxJurisdiction."Tax Account (Sales)");
            Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Account');
            Assert.AreEqual(LineAmtInclTax, -(GLEntry.Amount + GLEntry."VAT Amount"), 'UnitPriceTaxable * Qty + TotalTax <> (GLEntry.Amount + GLEntry."VAT Amount")');
        until TaxJurisdiction.next() = 0;
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
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        // [GIVEN] Customer Discount
        CreateDiscount(Item, LibraryRandom.RandDecInRange(1, 100, 5));

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
        POSViewProfile: Record "NPR POS View Profile";
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

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Tax Type" := POSViewProfile."Tax Type"::VAT;
        POSViewProfile.Modify();
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 9);

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
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Customer, 'Customer Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Customer Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'SalesLineDiscount."Line Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine.Amount');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineUpdatedQtyForNormalTaxInDirectSaleQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSViewProfile: Record "NPR POS View Profile";
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

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Tax Type" := POSViewProfile."Tax Type"::VAT;
        POSViewProfile.Modify();
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 9);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [WHEN] Quantity changed
        Qty := 2 + Round(2 / 3, 0.00001);
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
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Customer, 'Customer Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Customer Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'SalesLineDiscount."Line Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine.Amount');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineUpdatedQtyForNormalTaxInDebitSaleForward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
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
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

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
        LineDiscAmt := (Qty * Item."Unit Price" * LineDiscPct / 100) / (1 + VATPostingSetup."VAT %" / 100);
        LineAmtExclTax := Qty * UnitPrice - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax * (1 + VATPostingSetup."VAT %" / 100);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Customer, 'Customer Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Customer Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'SalesLineDiscount."Line Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '((Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) / (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '((Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) * (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100))  <> POSSaleLine.Amount');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineUpdatedQtyForNormalTaxInDebitSaleForwardQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
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
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [WHEN] Quantity changed
        Qty := 2 + 1 / 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        UnitPrice := Item."Unit Price" / (1 + VATPostingSetup."VAT %" / 100);
        LineDiscAmt := Round((Qty * Item."Unit Price" * LineDiscPct / 100) / (1 + VATPostingSetup."VAT %" / 100));
        LineAmtExclTax := Round(Qty * UnitPrice) - LineDiscAmt;
        LineAmtInclTax := Round(LineAmtExclTax * (1 + VATPostingSetup."VAT %" / 100));

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Customer, 'Customer Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Customer Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'SalesLineDiscount."Line Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(LineDiscAmt, POSSaleLine."Discount Amount", '((Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) / (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(LineAmtInclTax, POSSaleLine."Amount Including VAT", '((Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) * (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(LineAmtExclTax, POSSaleLine.Amount, '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100))  <> POSSaleLine.Amount');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineUpdatedQtyForNormalTaxInDebitSaleBackward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
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
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

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

        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtInclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Customer, 'Customer Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Customer Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'SalesLineDiscount."Line Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine.Amount');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineUpdatedQtyForNormalTaxInDebitSaleBackwardQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
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
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [WHEN] Quantity changed
        Qty := 2 + Round(1 / 3, 0.00001);
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        LineDiscAmt := Round(Qty * Item."Unit Price" * LineDiscPct / 100);
        LineAmtInclTax := Round(Qty * Item."Unit Price") - LineDiscAmt;
        LineAmtExclTax := Round(LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100));

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Customer, 'Customer Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Customer Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'SalesLineDiscount."Line Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(LineDiscAmt, POSSaleLine."Discount Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(LineAmtInclTax, POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(LineAmtExclTax, POSSaleLine.Amount, '((Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine.Amount');
    end;

    [Test]
    procedure ApplyDiscountWhenEndSaleForNormalTaxInDirectSaleUpdatedQty()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSViewProfile: Record "NPR POS View Profile";
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

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Tax Type" := POSViewProfile."Tax Type"::VAT;
        POSViewProfile.Modify();
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 9);

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
        Assert.AreEqual(Qty * Item."Unit Price", -(GLEntry.Amount + GLEntry."VAT Amount"), '(Qty * Item."Unit Price") <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> GLEntry.Amount + GLEntry."VAT Amount"');
    end;

    [Test]
    procedure ApplyDiscountWhenEndSaleForNormalTaxInDirectSaleUpdatedQtyQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSViewProfile: Record "NPR POS View Profile";
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

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Tax Type" := POSViewProfile."Tax Type"::VAT;
        POSViewProfile.Modify();
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 9);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Quantity changed
        Qty := 2 + Round(2 / 3, 0.00001);
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        LineDiscAmt := Round(Qty * Item."Unit Price" * LineDiscPct / 100);
        LineAmtInclTax := Round(Qty * Item."Unit Price") - LineDiscAmt;
        LineAmtExclTax := Round(LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100));

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
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> GLEntry.Amount + GLEntry."VAT Amount"');
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
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

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
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> GLEntry.Amount + GLEntry."VAT Amount"');
    end;

    [Test]
    procedure ApplyDiscountWhenEndSaleForNormalTaxInDebitSaleForwardUpdatedQtyFraction()
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
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Quantity changed
        Qty := 2 + 1 / 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        LineDiscAmt := Round(Qty * Item."Unit Price" * LineDiscPct / 100);
        LineAmtExclTax := Round(Qty * Item."Unit Price") - LineDiscAmt;
        LineAmtInclTax := Round(LineAmtExclTax * (1 + VATPostingSetup."VAT %" / 100));

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
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> GLEntry.Amount + GLEntry."VAT Amount"');
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
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

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
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> GLEntry.Amount + GLEntry."VAT Amount"');
    end;

    [Test]
    procedure ApplyDiscountWhenEndSaleForNormalTaxInDebitSaleBackwardUpdatedQtyFraction()
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
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Quantity changed
        Qty := 2 + Round(1 / 3, 0.00001);
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        LineDiscAmt := Round(Qty * Item."Unit Price" * LineDiscPct / 100);
        LineAmtInclTax := Round(Qty * Item."Unit Price") - LineDiscAmt;
        LineAmtExclTax := Round(LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100));

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
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> GLEntry.Amount + GLEntry."VAT Amount"');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineUpdatedQtyForRevChrgTaxInDirectSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSViewProfile: Record "NPR POS View Profile";
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

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Tax Type" := POSViewProfile."Tax Type"::VAt;
        POSViewProfile.Modify();
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 9);

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

        //Reverse Charge VAT
        VATPostingSetup."VAT %" := 0;

        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtInclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Customer, 'Customer Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Customer Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'SalesLineDiscount."Line Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine.Amount');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineUpdatedQtyForRevChrgTaxInDirectSaleQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSViewProfile: Record "NPR POS View Profile";
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

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Tax Type" := POSViewProfile."Tax Type"::VAt;
        POSViewProfile.Modify();
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 9);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [WHEN] Quantity changed
        Qty := 2 + Round(2 / 3, 0.00001);
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        //Reverse Charge VAT
        VATPostingSetup."VAT %" := 0;

        LineDiscAmt := Round(Qty * Item."Unit Price" * LineDiscPct / 100);
        LineAmtInclTax := Round(Qty * Item."Unit Price") - LineDiscAmt;
        LineAmtExclTax := Round(LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100));

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Customer, 'Customer Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Customer Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'SalesLineDiscount."Line Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(LineDiscAmt, POSSaleLine."Discount Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(LineAmtInclTax, POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(LineAmtExclTax, POSSaleLine.Amount, '((Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine.Amount');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineUpdatedQtyForRevChrgTaxInDebitSaleForward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
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
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

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

        //Reverse Charge VAT
        VATPostingSetup."VAT %" := 0;

        UnitPrice := Item."Unit Price" / (1 + VATPostingSetup."VAT %" / 100);
        LineDiscAmt := (Qty * Item."Unit Price" * LineDiscPct / 100) / (1 + VATPostingSetup."VAT %" / 100);
        LineAmtExclTax := Qty * UnitPrice - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax * (1 + VATPostingSetup."VAT %" / 100);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Customer, 'Customer Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Customer Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'SalesLineDiscount."Line Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '((Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) / (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '((Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) * (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100))  <> POSSaleLine.Amount');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineUpdatedQtyForRevChrgTaxInDebitSaleForwardQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
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
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [WHEN] Quantity changed
        Qty := 2 + 1 / 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        //Reverse Charge VAT
        VATPostingSetup."VAT %" := 0;

        UnitPrice := Item."Unit Price" / (1 + VATPostingSetup."VAT %" / 100);
        LineDiscAmt := Round((Qty * Item."Unit Price" * LineDiscPct / 100) / (1 + VATPostingSetup."VAT %" / 100));
        LineAmtExclTax := Round(Qty * UnitPrice) - LineDiscAmt;
        LineAmtInclTax := Round(LineAmtExclTax * (1 + VATPostingSetup."VAT %" / 100));

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Customer, 'Customer Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Customer Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'SalesLineDiscount."Line Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(LineDiscAmt, POSSaleLine."Discount Amount", '((Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) / (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(LineAmtInclTax, POSSaleLine."Amount Including VAT", '((Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) * (1 + VATPostingSetup."VAT %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(LineAmtExclTax, POSSaleLine.Amount, '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100))  <> POSSaleLine.Amount');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineUpdatedQtyForRevChrgTaxInDebitSaleBackward()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
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
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

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

        //Reverse Charge VAT
        VATPostingSetup."VAT %" := 0;

        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtInclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtExclTax := LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Customer, 'Customer Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Customer Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'SalesLineDiscount."Line Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '((Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine.Amount');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineUpdatedQtyForRevChrgTaxInDebitSaleBackwardQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
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
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [WHEN] Quantity changed
        Qty := 2 + Round(1 / 3, 0.00001);
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        //Reverse Charge VAT
        VATPostingSetup."VAT %" := 0;

        LineDiscAmt := Round(Qty * Item."Unit Price" * LineDiscPct / 100);
        LineAmtInclTax := Round(Qty * Item."Unit Price") - LineDiscAmt;
        LineAmtExclTax := Round(LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100));

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Customer, 'Customer Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Customer Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'SalesLineDiscount."Line Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(LineDiscAmt, POSSaleLine."Discount Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(LineAmtInclTax, POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) <> POSSaleLine."Amount Including VAT"');
        Assert.AreEqual(LineAmtExclTax, POSSaleLine.Amount, '((Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100))) / (1 + VATPostingSetup."VAT %" / 100) <> POSSaleLine.Amount');
    end;

    [Test]
    procedure ApplyDiscountWhenEndSaleForRevChrgTaxInDirectSaleUpdatedQty()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSViewProfile: Record "NPR POS View Profile";
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

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Tax Type" := POSViewProfile."Tax Type"::"Sales Tax";
        POSViewProfile.Modify();
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 9);

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

        //Reverse Charge VAT
        VATPostingSetup."VAT %" := 0;

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
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> GLEntry.Amount + GLEntry."VAT Amount"');
    end;

    [Test]
    procedure ApplyDiscountWhenEndSaleForRevChrgTaxInDirectSaleUpdatedQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSViewProfile: Record "NPR POS View Profile";
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

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Tax Type" := POSViewProfile."Tax Type"::"Sales Tax";
        POSViewProfile.Modify();
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 9);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Quantity changed
        Qty := 2 + Round(2 / 3, 0.00001);
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        //Reverse Charge VAT
        VATPostingSetup."VAT %" := 0;

        LineDiscAmt := Round(Qty * Item."Unit Price" * LineDiscPct / 100);
        LineAmtInclTax := Round(Qty * Item."Unit Price") - LineDiscAmt;
        LineAmtExclTax := Round(LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100));

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
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> GLEntry.Amount + GLEntry."VAT Amount"');
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
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

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

        //Reverse Charge VAT
        VATPostingSetup."VAT %" := 0;

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
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", 'Qty * (Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> GLEntry.Amount + GLEntry."VAT Amount"');
    end;

    [Test]
    procedure ApplyDiscountWhenEndSaleForRevChrgTaxInDebitSaleForwardUpdatedQtyQtyFraction()
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
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Quantity changed
        Qty := 2 + 1 / 2;
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        //Reverse Charge VAT
        VATPostingSetup."VAT %" := 0;

        LineDiscAmt := Round(Qty * Item."Unit Price" * LineDiscPct / 100);
        LineAmtExclTax := Round(Qty * Item."Unit Price") - LineDiscAmt;
        LineAmtInclTax := Round(LineAmtExclTax * (1 + VATPostingSetup."VAT %" / 100));

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
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", 'Qty * (Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> GLEntry.Amount + GLEntry."VAT Amount"');
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
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

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

        //Reverse Charge VAT
        VATPostingSetup."VAT %" := 0;

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
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> GLEntry.Amount + GLEntry."VAT Amount"');
    end;

    [Test]
    procedure ApplyDiscountWhenEndSaleForRevChrgTaxInDebitSaleBackwardUpdatedQtyFraction()
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
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Quantity changed
        Qty := 2 + Round(1 / 3, 0.00001);
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        //Reverse Charge VAT
        VATPostingSetup."VAT %" := 0;

        LineDiscAmt := Round(Qty * Item."Unit Price" * LineDiscPct / 100);
        LineAmtInclTax := Round(Qty * Item."Unit Price") - LineDiscAmt;
        LineAmtExclTax := Round(LineAmtInclTax / (1 + VATPostingSetup."VAT %" / 100));

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
        Assert.AreEqual(LineDiscAmt, GLEntry.Amount + GLEntry."VAT Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> GLEntry.Amount + GLEntry."VAT Amount"');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineUpdatedForSaleTaxInDirectSale()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSViewProfile: Record "NPR POS View Profile";
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

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Tax Type" := POSViewProfile."Tax Type"::"Sales Tax";
        POSViewProfile.Modify();
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 9);

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
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Customer, 'Customer Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Customer Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'SalesLineDiscount."Line Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) <> POSSaleLine.Amount');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) + TotalTax <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineUpdatedForSaleTaxInDirectSaleQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSViewProfile: Record "NPR POS View Profile";
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

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Tax Type" := POSViewProfile."Tax Type"::"Sales Tax";
        POSViewProfile.Modify();
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 9);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [WHEN] Quantity changed
        Qty := 2 + Round(2 / 3, 0.00001);
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        UnitPriceTaxable := Item."Unit Price" * (1 - LineDiscPct / 100);
        TotalTax := Round(Qty * UnitPriceTaxable * CityTaxRate / 100) +
                   Round(Qty * UnitPriceTaxable * CountyTaxRate / 100) +
                   Round(Qty * UnitPriceTaxable * StateTaxRate / 100);
        LineDiscAmt := Round(Qty * Item."Unit Price" * LineDiscPct / 100);
        LineAmtExclTax := Round(Qty * Item."Unit Price") - LineDiscAmt;
        LineAmtInclTax := Round(LineAmtExclTax + TotalTax);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Customer, 'Customer Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Customer Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'SalesLineDiscount."Line Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(LineDiscAmt, POSSaleLine."Discount Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(LineAmtExclTax, POSSaleLine.Amount, '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) <> POSSaleLine.Amount');
        Assert.AreEqual(LineAmtInclTax, POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) + TotalTax <> POSSaleLine."Amount Including VAT"');
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
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        POSStore.GetProfile(POSPostingProfile);
        POSPostingProfile."Default POS Posting Setup" := POSPostingProfile."Default POS Posting Setup"::Customer;
        POSPostingProfile.Modify();

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

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
        LineDiscAmt := Qty * Item."Unit Price" * LineDiscPct / 100;
        LineAmtExclTax := Qty * Item."Unit Price" - LineDiscAmt;
        LineAmtInclTax := LineAmtExclTax + TotalTax;

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Customer, 'Customer Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Customer Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'SalesLineDiscount."Line Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100))  <> POSSaleLine.Amount');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) + TotalTax <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
    procedure ApplyDiscountWhenPOSSaleLineUpdatedForSaleTaxInDebitSaleQtyFraction()
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
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        POSStore.GetProfile(POSPostingProfile);
        POSPostingProfile."Default POS Posting Setup" := POSPostingProfile."Default POS Posting Setup"::Customer;
        POSPostingProfile.Modify();

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [WHEN] Quantity changed
        Qty := 2 + Round(1 / 3, 0.00001);
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        UnitPriceTaxable := Item."Unit Price" * (1 - LineDiscPct / 100);
        TotalTax := Round(Qty * UnitPriceTaxable * CityTaxRate / 100) +
                           Round(Qty * UnitPriceTaxable * CountyTaxRate / 100) +
                           Round(Qty * UnitPriceTaxable * StateTaxRate / 100);
        LineDiscAmt := Round(Qty * Item."Unit Price" * LineDiscPct / 100);
        LineAmtExclTax := Round(Qty * Item."Unit Price") - LineDiscAmt;
        LineAmtInclTax := Round(LineAmtExclTax + TotalTax);

        // [THEN] Verify Discount applied
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);

        Assert.IsTrue(POSSaleLine."Allow Line Discount", 'Line Discount not allowed');
        Assert.IsTrue(POSSaleLine."Discount Type" = POSSaleLine."Discount Type"::Customer, 'Customer Discount not applied to POS Sale Line');
        Assert.IsFalse(POSSaleLine."Discount Calculated", 'Customer Discount calculated on POS Sale Line');
        Assert.AreEqual(LineDiscPct, POSSaleLine."Discount %", 'SalesLineDiscount."Line Discount %" <> POSSaleLine."Discount %"');
        Assert.AreEqual(Round(LineDiscAmt), POSSaleLine."Discount Amount", '(Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100) <> POSSaleLine."Discount Amount"');
        Assert.AreEqual(Round(LineAmtExclTax), POSSaleLine.Amount, '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100))  <> POSSaleLine.Amount');
        Assert.AreEqual(Round(LineAmtInclTax), POSSaleLine."Amount Including VAT", '(Qty * Item."Unit Price" - (Qty * Item."Unit Price" * SalesLineDiscount."Line Discount %" / 100)) + TotalTax <> POSSaleLine."Amount Including VAT"');
    end;

    [Test]
    procedure ApplyDiscountWhenEndSaleForSaleTaxInDirectSaleUpdatedQty()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSViewProfile: Record "NPR POS View Profile";
        POSEntry: Record "NPR POS Entry";
        GLEntry: Record "G/L Entry";
        TaxJurisdiction: Record "Tax Jurisdiction";
        TaxDetail: Record "Tax Detail";
        TaxArea: Record "Tax Area";
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

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Tax Type" := POSViewProfile."Tax Type"::"Sales Tax";
        POSViewProfile.Modify();
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Update rounding amount account
        UpdatePOSSalesRoundingAcc();

        // [GIVEN] Update Tax account (sales)
        UpdateTaxJurisdictionSalesAccounts(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 9);

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

        //Verify G/L Entry
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        GLEntry.SetRange("Posting Date", POSEntry."Posting Date");
        TaxJurisdiction.FindSet();
        repeat
            GLEntry.SetRange("G/L Account No.", TaxJurisdiction."Tax Account (Sales)");
            Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Account');
            Assert.AreEqual(LineAmtInclTax, -(GLEntry.Amount + GLEntry."VAT Amount"), 'UnitPriceTaxable * Qty + TotalTax <> (GLEntry.Amount + GLEntry."VAT Amount")');
        until TaxJurisdiction.next() = 0;
    end;

    [Test]
    procedure ApplyDiscountWhenEndSaleForSaleTaxInDirectSaleUpdatedQtyFraction()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSViewProfile: Record "NPR POS View Profile";
        POSEntry: Record "NPR POS Entry";
        GLEntry: Record "G/L Entry";
        TaxJurisdiction: Record "Tax Jurisdiction";
        TaxDetail: Record "Tax Detail";
        TaxArea: Record "Tax Area";
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

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Tax Type" := POSViewProfile."Tax Type"::"Sales Tax";
        POSViewProfile.Modify();
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Update rounding amount account
        UpdatePOSSalesRoundingAcc();

        // [GIVEN] Update Tax account (sales)
        UpdateTaxJurisdictionSalesAccounts(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 9);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Quantity changed
        Qty := 2 + Round(2 / 3, 0.00001);
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        UnitPriceTaxable := Item."Unit Price" * (1 - LineDiscPct / 100);
        TotalTax := Round(Qty * UnitPriceTaxable * CityTaxRate / 100) +
                   Round(Qty * UnitPriceTaxable * CountyTaxRate / 100) +
                   Round(Qty * UnitPriceTaxable * StateTaxRate / 100);

        LineAmtInclTax := Round(Qty * UnitPriceTaxable + TotalTax);

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

        //Verify G/L Entry
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        GLEntry.SetRange("Posting Date", POSEntry."Posting Date");
        TaxJurisdiction.FindSet();
        repeat
            GLEntry.SetRange("G/L Account No.", TaxJurisdiction."Tax Account (Sales)");
            Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Account');
            Assert.AreEqual(LineAmtInclTax, -(GLEntry.Amount + GLEntry."VAT Amount"), 'UnitPriceTaxable * Qty + TotalTax <> (GLEntry.Amount + GLEntry."VAT Amount")');
        until TaxJurisdiction.next() = 0;
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
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        POSStore.GetProfile(POSPostingProfile);
        POSPostingProfile."Default POS Posting Setup" := POSPostingProfile."Default POS Posting Setup"::Customer;
        POSPostingProfile.Modify();

        // [GIVEN] Update rounding amount account
        UpdatePOSSalesRoundingAcc();

        // [GIVEN] Update Tax account (sales)
        UpdateTaxJurisdictionSalesAccounts(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

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

        LineAmtInclTax := Round(UnitPriceTaxable * Qty + TotalTax);

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

        //Verify G/L Entry
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        GLEntry.SetRange("Posting Date", POSEntry."Posting Date");
        TaxJurisdiction.FindSet();
        repeat
            GLEntry.SetRange("G/L Account No.", TaxJurisdiction."Tax Account (Sales)");
            Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Account');
            Assert.AreEqual(LineAmtInclTax, -(GLEntry.Amount + GLEntry."VAT Amount"), 'UnitPriceTaxable * Qty <> (GLEntry.Amount + GLEntry."VAT Amount")');
        until TaxJurisdiction.next() = 0;
    end;

    [Test]
    procedure ApplyDiscountWhenEndSaleForSaleTaxInDebitSaleUpdatedQtyFraction()
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
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        POSStore.GetProfile(POSPostingProfile);
        POSPostingProfile."Default POS Posting Setup" := POSPostingProfile."Default POS Posting Setup"::Customer;
        POSPostingProfile.Modify();

        // [GIVEN] Update rounding amount account
        UpdatePOSSalesRoundingAcc();

        // [GIVEN] Update Tax account (sales)
        UpdateTaxJurisdictionSalesAccounts(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        LineDiscPct := CreateDiscount(Item, 7);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Quantity changed
        Qty := 2 + Round(1 / 3, 0.00001);
        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(Qty);

        UnitPriceTaxable := Item."Unit Price" * (1 - LineDiscPct / 100);
        TotalTax := Round(Qty * UnitPriceTaxable * CityTaxRate / 100) +
                   Round(Qty * UnitPriceTaxable * CountyTaxRate / 100) +
                   Round(Qty * UnitPriceTaxable * StateTaxRate / 100);

        LineAmtInclTax := Round(UnitPriceTaxable * Qty + TotalTax);

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

        //Verify G/L Entry
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        GLEntry.SetRange("Posting Date", POSEntry."Posting Date");
        TaxJurisdiction.FindSet();
        repeat
            GLEntry.SetRange("G/L Account No.", TaxJurisdiction."Tax Account (Sales)");
            Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Account');
            Assert.AreEqual(LineAmtInclTax, -(GLEntry.Amount + GLEntry."VAT Amount"), 'UnitPriceTaxable * Qty <> (GLEntry.Amount + GLEntry."VAT Amount")');
        until TaxJurisdiction.next() = 0;
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
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        // [GIVEN] Customer Discount
        CreateDiscount(Item, LibraryRandom.RandDecInRange(1, 100, 5));

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
        POSViewProfile: Record "NPR POS View Profile";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is deleted

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Tax Type" := POSViewProfile."Tax Type"::VAT;
        POSViewProfile.Modify();
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Customer Discount
        CreateDiscount(Item, 9);

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
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        CreateDiscount(Item, 7);

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
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        CreateDiscount(Item, 7);

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
        POSViewProfile: Record "NPR POS View Profile";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
    begin
        // [SCENARIO] Discount is prioritized and applied when POS Sale Line is deleted

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Enable discount
        EnableDiscount();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Tax Type" := POSViewProfile."Tax Type"::VAT;
        POSViewProfile.Modify();
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Customer Discount
        CreateDiscount(Item, 9);

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
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        CreateDiscount(Item, 7);

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
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        CreateDiscount(Item, 7);

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
        POSViewProfile: Record "NPR POS View Profile";
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

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Tax Type" := POSViewProfile."Tax Type"::"Sales Tax";
        POSViewProfile.Modify();
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 90;
        Item.Modify();

        // [GIVEN] Customer Discount
        CreateDiscount(Item, 9);

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
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        POSStore.GetProfile(POSPostingProfile);
        POSPostingProfile."Default POS Posting Setup" := POSPostingProfile."Default POS Posting Setup"::Customer;
        POSPostingProfile.Modify();

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 41;
        Item.Modify();

        // [GIVEN] Customer Discount
        CreateDiscount(Item, 7);

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
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryERM: Codeunit "Library - ERM";
    begin
        if Initialized then begin
            //Clean any previous mock session
            POSSession.Destructor();
            Clear(POSSession);
        end;

        if not Initialized then begin
            LibraryERM.CreateVATBusinessPostingGroup(VATBusinessPostingGroup);
            LibraryPOSMasterData.CreatePOSSetup(POSSetup);
            LibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            LibraryPOSMasterData.CreatePOSStore(POSStore, POSPostingProfile.Code);
            LibraryPOSMasterData.CreatePOSUnit(POSUnit, POSStore.Code, POSPostingProfile.Code);
            LibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);

            LibraryTaxCalc.CreateTaxSetup();
            LibraryTaxCalc.CreateTaxGroup(TaxGroup);

            DeletePOSPostedEntries();
            DeleteDiscounts();

            Initialized := true;
        end;



        Commit();
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

    local procedure AssignVATProdPostGroupToPOSSalesRoundingAcc(VATProdPostingGroupCode: Code[20])
    var
        LibraryPOSMasterData: codeunit "NPR Library - POS Master Data";
    begin
        LibraryPOSMasterData.AssignVATProdPostGroupToPOSSalesRoundingAcc(POSStore, VATProdPostingGroupCode);
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

    local procedure CreatePOSViewProfile(var POSViewProfile: Record "NPR POS View Profile")
    var
        LibraryPOSMasterData: codeunit "NPR Library - POS Master Data";
    begin
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
    end;

    local procedure AssignPOSViewProfileToPOSUnit(POSViewProfileCode: Code[20])
    var
        LibraryPOSMasterData: codeunit "NPR Library - POS Master Data";
    begin
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(POSUnit, POSViewProfileCode);
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

    local procedure UpdateTaxJurisdictionSalesAccounts(VATPostingSetup: Record "VAT Posting Setup")
    var
        GLAcc: Record "G/L Account";
        TaxJurisdiction: Record "Tax Jurisdiction";
    begin
        TaxJurisdiction.SetFilter("Tax Account (Sales)", '<>%1', '');
        if TaxJurisdiction.FindSet() then
            repeat
                GLAcc.Get(TaxJurisdiction."Tax Account (Sales)");
                GLAcc."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
                GLAcc."VAT Prod. Posting Group" := VATPostingSetup."VAT Prod. Posting Group";
                GLAcc.Modify();
            until TaxJurisdiction.Next() = 0;
        TaxJurisdiction.Reset();
        TaxJurisdiction.SetFilter("Unreal. Tax Acc. (Sales)", '<>%1', '');
        if TaxJurisdiction.FindSet() then
            repeat
                GLAcc.Get(TaxJurisdiction."Unreal. Tax Acc. (Sales)");
                GLAcc."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
                GLAcc."VAT Prod. Posting Group" := VATPostingSetup."VAT Prod. Posting Group";
                GLAcc.Modify();
            until TaxJurisdiction.Next() = 0;
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

    local procedure DiscSourceTableId(): Integer
    begin
        exit(DATABASE::"Price List Line");
    end;

    local procedure DeleteDiscounts()
    var
        RecRef: RecordRef;
    begin
        RecRef.Open(DiscSourceTableId());
        RecRef.DeleteAll();
    end;

    local procedure DeletePOSPostedEntries()
    var
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
    begin
        //Just in case if performance test is created and run on test company for POS test unit
        //then POS posting is terminated because POS entries are stored in database with sales tickect no.
        //defined in the Library POS Master Data 
        POSEntry.DeleteAll();
        POSEntrySalesLine.DeleteAll();
        POSEntryPaymentLine.DeleteAll();
    end;

    local procedure CreateDiscount(Item: Record Item; LineDiscPct: Decimal): Decimal
    var
        PriceListLine: Record "Price List Line";
    begin
        PriceListLine."Price Type" := PriceListLine."Price Type"::Sale;
        PriceListLine."Amount Type" := PriceListLine."Amount Type"::Discount;
        PriceListLine."Source Type" := PriceListLine."Source Type"::"All Customers";
        PriceListLine."Source No." := '';
        PriceListLine.Validate("Asset Type", PriceListLine."Asset Type"::Item);
        PriceListLine.Validate("Asset No.", Item."No.");
        PriceListLine."Line Discount %" := LineDiscPct;
        PriceListLine."Starting Date" := Today() - 7;
        PriceListLine.Status := PriceListLine.Status::Active;
        PriceListLine.Insert();
        exit(PriceListLine."Line Discount %");
    end;
}