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
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
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
        Assert.IsTrue(RetailJournalLine."Unit Price" = Item."Unit Price", 'Unit Price not calculated according to scenario');
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
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
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
        Assert.IsTrue(RetailJournalLine."Unit Price" = Item."Unit Price", 'Unit Price not calculated according to scenario');
        Assert.IsTrue(RetailJournalLine."Discount Type" = RetailJournalLine."Discount Type"::Campaign, 'Discount not calculated according to scenario');
        Assert.IsTrue(RetailJournalLine."Discount Code" = PeriodDiscountLine.Code, 'Discount not calculated according to scenario');
        Assert.IsTrue(RetailJournalLine."Discount Pct." = PeriodDiscountLine."Discount %", 'Discount not calculated according to scenario');
        Assert.IsTrue(RetailJournalLine."Discount Price Incl. Vat" = LineAmtInclTax, 'Unit price after discount application not calculated according to scenario.');
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
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
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
        Assert.IsTrue(RetailJournalLine."Unit Price" = Item."Unit Price", 'Unit Price not calculated according to scenario');
        Assert.IsTrue(RetailJournalLine."Discount Type" = RetailJournalLine."Discount Type"::Quantity, 'Discount not calculated according to scenario');
        Assert.IsTrue(RetailJournalLine."Discount Code" = QuantityDiscountLine."Main no.", 'Discount not calculated according to scenario');
        Assert.IsTrue(RetailJournalLine."Discount Pct." = LineDiscPct, 'Discount not calculated according to scenario');
        Assert.IsTrue(RetailJournalLine."Discount Price Incl. Vat" = LineAmtInclTax, 'Discount not calculated according to scenario');
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
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
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
        LineDiscPct := POSMixDiscandTax.CreateTotalDiscountPct(Item, 60, false);

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
        Assert.IsTrue(RetailJournalLine."Unit Price" = Item."Unit Price", 'Unit Price not calculated according to scenario');
        Assert.IsTrue(RetailJournalLine."Discount Type" = RetailJournalLine."Discount Type"::Mix, 'Discount not calculated according to scenario');
        Assert.IsTrue(RetailJournalLine."Discount Code" <> '', 'Discount not calculated according to scenario');
        Assert.IsTrue(RetailJournalLine."Discount Pct." = LineDiscPct, 'Discount not calculated according to scenario');
        Assert.IsTrue(RetailJournalLine."Discount Price Excl. VAT" = LineAmtExclTax, 'Discount not calculated according to scenario');
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
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
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
        Assert.IsTrue(RetailJournalLine."Unit Price" = Item."Unit Price", 'Unit Price not calculated according to scenario');
        Assert.IsTrue(RetailJournalLine."Discount Type" = RetailJournalLine."Discount Type"::Customer, 'Discount not calculated according to scenario');
        Assert.IsTrue(RetailJournalLine."Discount Pct." = LineDiscPct, 'Discount not calculated according to scenario');
        Assert.IsTrue(RetailJournalLine."Discount Price Incl. Vat" = LineAmtInclTax, 'Discount not calculated according to scenario');
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
        POSMixDiscandTax: Codeunit "NPR POS Mix. Disc. and Tax";
        Assert: Codeunit Assert;
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
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
        LineMixDiscPct := POSMixDiscandTax.CreateTotalDiscountPct(Item, 40, false);

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
        Assert.IsTrue(RetailJournalLine."Unit Price" = Item."Unit Price", 'Unit Price not calculated according to scenario');
        Assert.IsTrue(RetailJournalLine."Discount Type" = RetailJournalLine."Discount Type"::Mix, 'Discount not calculated according to scenario');
        Assert.IsTrue(RetailJournalLine."Discount Code" <> '', 'Discount not calculated according to scenario');
        Assert.IsTrue(RetailJournalLine."Discount Pct." = LineMixDiscPct, 'Discount not calculated according to scenario');
        Assert.IsTrue(RetailJournalLine."Discount Price Excl. VAT" = LineAmtExclTax, 'Unit price after discount application not calculated according to scenario.');
    end;

    local procedure Initialize()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        //Clean any previous mock session
        POSSession.ClearAll();
        Clear(POSSession);

        if not Initialized then begin
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
