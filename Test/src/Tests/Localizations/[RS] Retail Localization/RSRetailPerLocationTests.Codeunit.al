codeunit 85266 "NPR RS Retail Per-Loc. Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Assert";

    [Test]
    procedure Purchase_UsesPerLocationCalcAccounts()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Loc: Record Location;
        LocVATAcc: Code[20];
        LocMarginAcc: Code[20];
        PostedNo: Code[20];
    begin
        // [SCENARIO] Per-location Calc accounts on Inventory Posting Setup must be used instead of the global ones
        // [GIVEN] Retail location with its own Calc VAT/Margin accounts
        Lib.InitializeSetup();
        Lib.CreateRetailLocationWithCalcAccounts(Loc, LocVATAcc, LocMarginAcc);
        Lib.CreateRetailItem(Item, 600, 1200, false, Loc.Code);

        // [WHEN] Posting a purchase invoice into that location
        PostedNo := Lib.PostRetailPurchaseInvoice(Item."No.", Loc.Code, 10, 600);

        // [THEN] Markup routes to the per-location accounts (fix also corrects the split)
        Lib.AssertCalcGL(PostedNo, Lib.RetailInvAcc(Loc.Code), LocVATAcc, LocMarginAcc, 6000, 2000, 4000);
        // [THEN] The global accounts are untouched by this document
        Assert.AreEqual(0, Lib.GetGLNetChange(Lib.GlobalVATAcc(), PostedNo), 'Global PDV should be untouched');
        Assert.AreEqual(0, Lib.GetGLNetChange(Lib.GlobalMarginAcc(), PostedNo), 'Global RUC should be untouched');
    end;

    [Test]
    procedure SalesInvoice_UsesPerLocationCalcAccounts()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Loc: Record Location;
        LocVATAcc: Code[20];
        LocMarginAcc: Code[20];
        PostedNo: Code[20];
    begin
        // [SCENARIO] Selling from a location with its own Calc accounts reverses RUC + PDV on those accounts, not the global ones
        // [GIVEN] Retail location with per-location Calc accounts, item cost 600 / retail 1200 incl 20% VAT, 10 pcs stock
        Lib.InitializeSetup();
        Lib.CreateRetailLocationWithCalcAccounts(Loc, LocVATAcc, LocMarginAcc);
        Lib.CreateRetailItem(Item, 600, 1200, false, Loc.Code);
        Lib.PostRetailPurchaseInvoice(Item."No.", Loc.Code, 10, 600);

        // [WHEN] Selling all 10 pcs at retail 1200 incl VAT
        PostedNo := Lib.PostRetailSalesInvoice(Item."No.", Loc.Code, 10, 1200);

        // [THEN] 134 relieved at retail; RUC + PDV reversed on the per-location accounts
        Lib.AssertGLNetChange(PostedNo, Lib.RetailInvAcc(Loc.Code), -12000, 'Retail inventory relieved at full retail');
        Lib.AssertGLNetChange(PostedNo, LocVATAcc, 2000, 'ukalkulisani PDV reversed on per-location account');
        Lib.AssertGLNetChange(PostedNo, LocMarginAcc, 4000, 'RUC reversed on per-location account');
        // [THEN] The global accounts are untouched by this document
        Assert.AreEqual(0, Lib.GetGLNetChange(Lib.GlobalVATAcc(), PostedNo), 'Global PDV should be untouched');
        Assert.AreEqual(0, Lib.GetGLNetChange(Lib.GlobalMarginAcc(), PostedNo), 'Global RUC should be untouched');
    end;

    [Test]
    procedure SalesCreditMemo_UsesPerLocationCalcAccounts()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Loc: Record Location;
        LocVATAcc: Code[20];
        LocMarginAcc: Code[20];
        PostedNo: Code[20];
    begin
        // [SCENARIO] A credit memo (return) into a per-location-accounts location re-adds RUC + PDV on those accounts
        // [GIVEN] Retail location with per-location Calc accounts, item cost 600 / retail 1200 incl 20% VAT, 10 pcs stock
        Lib.InitializeSetup();
        Lib.CreateRetailLocationWithCalcAccounts(Loc, LocVATAcc, LocMarginAcc);
        Lib.CreateRetailItem(Item, 600, 1200, false, Loc.Code);
        Lib.PostRetailPurchaseInvoice(Item."No.", Loc.Code, 10, 600);

        // [WHEN] Posting a credit memo (return) of 10 pcs at retail 1200 incl VAT
        PostedNo := Lib.PostRetailSalesCreditMemo(Item."No.", Loc.Code, 10, 1200);

        // [THEN] 134 increased at retail; RUC + PDV re-added (credit) on the per-location accounts
        Lib.AssertGLNetChange(PostedNo, Lib.RetailInvAcc(Loc.Code), 12000, 'Retail inventory increased at full retail');
        Lib.AssertGLNetChange(PostedNo, LocVATAcc, -2000, 'ukalkulisani PDV re-added on per-location account');
        Lib.AssertGLNetChange(PostedNo, LocMarginAcc, -4000, 'RUC re-added on per-location account');
        // [THEN] The global accounts are untouched by this document
        Assert.AreEqual(0, Lib.GetGLNetChange(Lib.GlobalVATAcc(), PostedNo), 'Global PDV should be untouched');
        Assert.AreEqual(0, Lib.GetGLNetChange(Lib.GlobalMarginAcc(), PostedNo), 'Global RUC should be untouched');
    end;
}
