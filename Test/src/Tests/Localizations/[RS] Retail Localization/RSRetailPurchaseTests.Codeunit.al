codeunit 85373 "NPR RS Retail Purchase Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure PurchaseInvoice_PostsVATAndRUCSplit()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Loc: Record Location;
        PostedNo: Code[20];
    begin
        // [SCENARIO] Purchasing retail goods must split the markup into ukalkulisani PDV and RUC
        // [GIVEN] RS localization active, retail location, item cost 600 / retail 1200 incl 20% VAT
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Loc);
        Lib.CreateRetailItem(Item, 600, 1200, false, Loc.Code);

        // [WHEN] Posting a purchase invoice of qty 10 at cost 600 into the retail location
        PostedNo := Lib.PostRetailPurchaseInvoice(Item."No.", Loc.Code, 10, 600);

        // [THEN] Inventory markup leg 6000; ukalkulisani PDV 2000; RUC 4000; document balanced
        Lib.AssertCalcGL(PostedNo, Lib.RetailInvAcc(Loc.Code), Lib.GlobalVATAcc(), Lib.GlobalMarginAcc(), 6000, 2000, 4000);
        Lib.AssertDocGLBalanced(PostedNo);
    end;

    [Test]
    procedure PurchaseInvoice_ReducedVATRate()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Loc: Record Location;
        PostedNo: Code[20];
    begin
        // [SCENARIO] The VAT breakdown must use the item's actual rate - here a 10% reduced-rate item
        // [GIVEN] Reduced-VAT item cost 600 / retail 1100 incl 10% VAT
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Loc);
        Lib.CreateRetailItem(Item, 600, 1100, true, Loc.Code);

        // [WHEN] Posting a purchase invoice of qty 10 at cost 600
        PostedNo := Lib.PostRetailPurchaseInvoice(Item."No.", Loc.Code, 10, 600);

        // [THEN] PDV = 1100*10*10/110 = 1000; markup = (1100-600)*10 = 5000; RUC = 5000-1000 = 4000
        Lib.AssertCalcGL(PostedNo, Lib.RetailInvAcc(Loc.Code), Lib.GlobalVATAcc(), Lib.GlobalMarginAcc(), 5000, 1000, 4000);
        Lib.AssertDocGLBalanced(PostedNo);
    end;

    [Test]
    procedure PurchaseInvoice_FractionalVATRounds()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Loc: Record Location;
        PostedNo: Code[20];
    begin
        // [SCENARIO] A retail price that yields a fractional ukalkulisani PDV must round cleanly and still balance
        // [GIVEN] Item cost 600 / retail 1000 incl 20% VAT (VAT = 1000*20/120 = 166.6667 -> 166.67)
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Loc);
        Lib.CreateRetailItem(Item, 600, 1000, false, Loc.Code);

        // [WHEN] Posting a purchase invoice of qty 1 at cost 600
        PostedNo := Lib.PostRetailPurchaseInvoice(Item."No.", Loc.Code, 1, 600);

        // [THEN] PDV 166.67, RUC 233.33, inventory markup 400; and the document balances despite the rounding
        Lib.AssertCalcGL(PostedNo, Lib.RetailInvAcc(Loc.Code), Lib.GlobalVATAcc(), Lib.GlobalMarginAcc(), 400, 166.67, 233.33);
        Lib.AssertDocGLBalanced(PostedNo);
    end;

    [Test]
    procedure PurchaseInvoice_SubCentUnitCostStaysBalanced()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Loc: Record Location;
        PostedNo: Code[20];
    begin
        // [SCENARIO] COM-1297: the three calculation legs must tie out even when the markup carries sub-cent digits.
        // Cost per Unit holds 5 decimals, so a delivery whose cost does not divide evenly into cents makes the
        // markup sub-cent. Rounding the ukalkulisani PDV and the RUC separately from the same raw figures then
        // drifts by a para and the balance guard blocks the whole posting.
        // [GIVEN] 700 pcs for 100,000.00 (= 142.85714 per unit) with retail 1000.00 incl 20% VAT
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Loc);
        Lib.CreateRetailItem(Item, 142.85714, 1000, false, Loc.Code);

        // [WHEN] Posting the purchase invoice
        PostedNo := Lib.PostRetailPurchaseInvoice(Item."No.", Loc.Code, 700, 142.85714);

        // [THEN] Markup = (1000 - 142.85714) * 700 = 600,000.002 -> inventory 600,000.00; PDV = 700,000/6 -> 116,666.67;
        // RUC takes the remainder 483,333.33 (NOT 483,333.34, which is what rounding the raw margin separately gives)
        Lib.AssertCalcGLExact(PostedNo, Lib.RetailInvAcc(Loc.Code), Lib.GlobalVATAcc(), Lib.GlobalMarginAcc(), 600000.00, 116666.67, 483333.33);
        Lib.AssertDocGLBalanced(PostedNo);
    end;

    [Test]
    procedure PurchaseInvoice_WithAddReportingCurrency()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Loc: Record Location;
        PostedNo: Code[20];
    begin
        // [SCENARIO] The calculation entries must post in a company that has an Additional Reporting Currency.
        // The additions post standalone entries on their own Gen. Jnl.-Post Line instance, so that codeunit's
        // add.-currency residual handling must stay out of it: it balances a whole journal document against its own
        // Currency record, which our instance never loaded, so it would fail on a blank residual account.
        // [GIVEN] ACY configured, item cost 600 / retail 1000 incl 20% VAT - the fractional PDV leaves an ACY remainder
        Lib.InitializeSetup();
        Lib.SetAdditionalReportingCurrency();
        Lib.CreateRetailLocation(Loc);
        Lib.CreateRetailItem(Item, 600, 1000, false, Loc.Code);

        // [WHEN] Posting a purchase invoice of qty 1 at cost 600
        PostedNo := Lib.PostRetailPurchaseInvoice(Item."No.", Loc.Code, 1, 600);

        // [THEN] The same split as without ACY - PDV 166.67, RUC 233.33, markup 400 - and the document balances
        Lib.AssertCalcGL(PostedNo, Lib.RetailInvAcc(Loc.Code), Lib.GlobalVATAcc(), Lib.GlobalMarginAcc(), 400, 166.67, 233.33);
        Lib.AssertDocGLBalanced(PostedNo);
    end;

    [Test]
    procedure PurchaseInvoice_MixedVATRatesInOneDocument()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        ItemStd: Record Item;
        ItemRed: Record Item;
        Loc: Record Location;
        PostedNo: Code[20];
    begin
        // [SCENARIO] A purchase with a 20% and a 10% line must split each line by its own rate and aggregate correctly
        // [GIVEN] Std item cost 600 / retail 1200 (20%) and reduced item cost 500 / retail 1100 (10%)
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Loc);
        Lib.CreateRetailItem(ItemStd, 600, 1200, false, Loc.Code);
        Lib.CreateRetailItem(ItemRed, 500, 1100, true, Loc.Code);

        // [WHEN] Posting one purchase invoice with both items, qty 1 each
        PostedNo := Lib.PostRetailPurchase2Lines(ItemStd."No.", ItemRed."No.", Loc.Code, 1, 600, 500);

        // [THEN] Aggregated: inventory 600+600=1200; PDV 200+100=300; RUC 400+500=900
        Lib.AssertCalcGL(PostedNo, Lib.RetailInvAcc(Loc.Code), Lib.GlobalVATAcc(), Lib.GlobalMarginAcc(), 1200, 300, 900);
        Lib.AssertDocGLBalanced(PostedNo);
    end;

    [Test]
    procedure PurchaseInvoice_ItemChargeIncreasesCostReducesRUC()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Loc: Record Location;
        PostedNo: Code[20];
    begin
        // [SCENARIO] An assigned item charge (zavisni troskovi) raises the item cost, so RUC shrinks by the charge while PDV stays on the retail price
        // [GIVEN] Item cost 600 / retail 1200 incl 20% VAT, 10 pcs, plus a 1000 item charge (=100/pc) assigned to the receipt
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Loc);
        Lib.CreateRetailItem(Item, 600, 1200, false, Loc.Code);

        // [WHEN] Posting the purchase with the charge assigned to the item line
        PostedNo := Lib.PostRetailPurchaseWithItemCharge(Item."No.", Loc.Code, 10, 600, 1000);

        // [THEN] True cost = (600+100)*10 = 7000; markup leg = (1200-700)*10 = 5000; PDV still 2000; RUC = 5000-2000 = 3000
        Lib.AssertCalcGL(PostedNo, Lib.RetailInvAcc(Loc.Code), Lib.GlobalVATAcc(), Lib.GlobalMarginAcc(), 5000, 2000, 3000);
        Lib.AssertDocGLBalanced(PostedNo);
    end;

    [Test]
    procedure CostAdjustment_LeavesRetailCalcIntact()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Retail: Record Location;
        InvBefore: Decimal;
        VATBefore: Decimal;
        MarginBefore: Decimal;
    begin
        // [SCENARIO] Adjust Cost - Item Entries must not disturb a retail location's 134 / RUC / PDV - retail is carried at
        // price, so the RS cost-adjustment subscriber excludes retail locations from standard cost adjustment.
        // [GIVEN] Retail stock across two cost layers (5 @600, 5 @800, retail 1200 incl 20% VAT) with a sale drawn from both
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 5, 600);
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 5, 800);
        Lib.PostRetailSalesInvoice(Item."No.", Retail.Code, 6, 1200);

        InvBefore := Lib.GetGLAccountBalance(Lib.RetailInvAcc(Retail.Code));
        VATBefore := Lib.GetGLAccountBalance(Lib.GlobalVATAcc());
        MarginBefore := Lib.GetGLAccountBalance(Lib.GlobalMarginAcc());

        // [WHEN] Running Adjust Cost - Item Entries for the item
        Lib.RunAdjustCostItemEntries(Item."No.");

        // [THEN] The retail calc accounts are untouched - cost adjustment is excluded for retail locations
        Lib.AssertGLAccountBalance(Lib.RetailInvAcc(Retail.Code), InvBefore, '134 must be unchanged by cost adjustment');
        Lib.AssertGLAccountBalance(Lib.GlobalVATAcc(), VATBefore, 'ukalkulisani PDV must be unchanged by cost adjustment');
        Lib.AssertGLAccountBalance(Lib.GlobalMarginAcc(), MarginBefore, 'RUC must be unchanged by cost adjustment');
    end;

    [Test]
    procedure PurchaseInvoice_NonRetailLocation_NoRSCalc()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Whse: Record Location;
        PostedNo: Code[20];
    begin
        // [SCENARIO] A purchase into a non-retail (wholesale) location must NOT create any RS retail calc entries - the
        // localization only touches retail locations, even for an item that has a retail price list.
        // [GIVEN] A wholesale (non-retail) location and an item with a retail price for it
        Lib.InitializeSetup();
        Lib.CreateWholesaleLocation(Whse);
        Lib.CreateRetailItem(Item, 600, 1200, false, Whse.Code);

        // [WHEN] Posting a purchase invoice of qty 10 into the wholesale location
        PostedNo := Lib.PostRetailPurchaseInvoice(Item."No.", Whse.Code, 10, 600);

        // [THEN] No RS calc entries at all; the global PDV/RUC accounts are untouched; the document still balances
        Lib.AssertNoRSCalcEntries(PostedNo);
        Lib.AssertGLNetChange(PostedNo, Lib.GlobalVATAcc(), 0, 'No ukalkulisani PDV on a non-retail purchase');
        Lib.AssertGLNetChange(PostedNo, Lib.GlobalMarginAcc(), 0, 'No RUC on a non-retail purchase');
        Lib.AssertDocGLBalanced(PostedNo);
    end;
}
