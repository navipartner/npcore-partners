codeunit 85271 "NPR RS Retail Nivelation Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    [HandlerFunctions('NivelationMessageHandler')]
    procedure Nivelation_PriceIncreaseAdjusts134RUCAndPDV()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Retail: Record Location;
        PostedNivNo: Code[20];
    begin
        // [SCENARIO] A retail price increase posts a nivelation that storno-adjusts 134, RUC and ukalkulisani PDV for stock on hand
        // [GIVEN] Retail item cost 600 / retail 1200 incl 20% VAT, 10 pcs in stock
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 10, 600);

        // [WHEN] Raising the retail price to 1500 incl VAT and posting the price-change nivelation
        PostedNivNo := Lib.PostNivelationPriceChange(Item."No.", Retail.Code, 1500);

        // [THEN] Value difference (1500-1200)*10 = 3000 splits: PDV 3000*20/120 = 500; RUC = 2500; 134 up 3000
        Lib.AssertGLNetChange(PostedNivNo, Lib.RetailInvAcc(Retail.Code), 3000, 'Retail inventory raised by the value difference');
        Lib.AssertGLNetChange(PostedNivNo, Lib.GlobalVATAcc(), -500, 'ukalkulisani PDV increased (credit)');
        Lib.AssertGLNetChange(PostedNivNo, Lib.GlobalMarginAcc(), -2500, 'RUC increased (credit)');
        Lib.AssertDocGLBalanced(PostedNivNo);
    end;

    [Test]
    [HandlerFunctions('NivelationMessageHandler')]
    procedure Nivelation_PriceDecreaseAdjusts134RUCAndPDV()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Retail: Record Location;
        PostedNivNo: Code[20];
    begin
        // [SCENARIO] A retail price decrease posts a nivelation that reduces 134, RUC and ukalkulisani PDV (storno) for stock on hand
        // [GIVEN] Retail item cost 600 / retail 1200 incl 20% VAT, 10 pcs in stock
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 10, 600);

        // [WHEN] Lowering the retail price to 900 incl VAT and posting the price-change nivelation
        PostedNivNo := Lib.PostNivelationPriceChange(Item."No.", Retail.Code, 900);

        // [THEN] Value difference (900-1200)*10 = -3000: PDV -500 (debit), RUC -2500 (debit), 134 down 3000
        Lib.AssertGLNetChange(PostedNivNo, Lib.RetailInvAcc(Retail.Code), -3000, 'Retail inventory reduced by the value difference');
        Lib.AssertGLNetChange(PostedNivNo, Lib.GlobalVATAcc(), 500, 'ukalkulisani PDV reduced (debit)');
        Lib.AssertGLNetChange(PostedNivNo, Lib.GlobalMarginAcc(), 2500, 'RUC reduced (debit)');
        Lib.AssertDocGLBalanced(PostedNivNo);
    end;

    [Test]
    [HandlerFunctions('NivelationMessageHandler')]
    procedure Nivelation_UsesPerLocationCalcAccounts()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Loc: Record Location;
        LocVATAcc: Code[20];
        LocMarginAcc: Code[20];
        PostedNivNo: Code[20];
    begin
        // [SCENARIO] A nivelation for a location with its own Calc accounts must adjust RUC + PDV on those accounts, not the global ones
        // [GIVEN] Retail location with per-location Calc accounts, item cost 600 / retail 1200 incl 20% VAT, 10 pcs in stock
        Lib.InitializeSetup();
        Lib.CreateRetailLocationWithCalcAccounts(Loc, LocVATAcc, LocMarginAcc);
        Lib.CreateRetailItem(Item, 600, 1200, false, Loc.Code);
        Lib.PostRetailPurchaseInvoice(Item."No.", Loc.Code, 10, 600);

        // [WHEN] Raising the retail price to 1500 incl VAT and posting the nivelation
        PostedNivNo := Lib.PostNivelationPriceChange(Item."No.", Loc.Code, 1500);

        // [THEN] Value diff (1500-1200)*10 = 3000: PDV 500 and RUC 2500 land on the per-location accounts (credit)
        Lib.AssertGLNetChange(PostedNivNo, LocVATAcc, -500, 'ukalkulisani PDV increased on per-location account');
        Lib.AssertGLNetChange(PostedNivNo, LocMarginAcc, -2500, 'RUC increased on per-location account');
        // [THEN] The global accounts are untouched by this nivelation
        Lib.AssertGLNetChange(PostedNivNo, Lib.GlobalVATAcc(), 0, 'Global PDV must be untouched');
        Lib.AssertGLNetChange(PostedNivNo, Lib.GlobalMarginAcc(), 0, 'Global RUC must be untouched');
        Lib.AssertDocGLBalanced(PostedNivNo);
    end;

    [MessageHandler]
    procedure NivelationMessageHandler(Msg: Text[1024])
    begin
        // swallow the "Successfully posted a Nivelation Document" confirmation
    end;
}
