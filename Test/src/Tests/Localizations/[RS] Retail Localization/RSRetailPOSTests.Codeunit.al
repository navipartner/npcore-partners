codeunit 85267 "NPR RS Retail POS Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Assert";

    [Test]
    procedure POSSale_RelievesRetailAndReversesMarkup()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        POSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";
        PaymentMethod: Code[10];
        RetailLoc: Code[10];
        VATBefore: Decimal;
        VATAfter: Decimal;
        MarginBefore: Decimal;
        MarginAfter: Decimal;
        InvBefore: Decimal;
        InvAfter: Decimal;
    begin
        // [SCENARIO] A POS retail sale relieves 134 at retail and reverses RUC + ukalkulisani PDV (razduzenje), same as a sales invoice
        // [GIVEN] RS-active retail POS with an item cost 600 / retail 1200 incl 20% VAT and 10 pcs in stock
        Lib.InitializeSetup();
        Lib.SetupRetailPOS(POSUnit, POSStore, PaymentMethod, RetailLoc);
        Lib.CreateRetailItemForPOS(Item, 600, 1200, POSUnit, POSStore, RetailLoc);
        Lib.PostRetailPurchaseInvoice(Item."No.", RetailLoc, 10, 600);

        VATBefore := Lib.GetGLAccountBalance(Lib.GlobalVATAcc());
        MarginBefore := Lib.GetGLAccountBalance(Lib.GlobalMarginAcc());
        InvBefore := Lib.GetGLAccountBalance(Lib.RetailInvAcc(RetailLoc));

        // [WHEN] Selling all 10 pcs on the POS at retail 1200 incl VAT and posting the POS entry
        Lib.SellRetailPOSItemAndPost(POSUnit, PaymentMethod, Item."No.", 10, 12000, 0);

        VATAfter := Lib.GetGLAccountBalance(Lib.GlobalVATAcc());
        MarginAfter := Lib.GetGLAccountBalance(Lib.GlobalMarginAcc());
        InvAfter := Lib.GetGLAccountBalance(Lib.RetailInvAcc(RetailLoc));

        // [THEN] 134 relieved at full retail; RUC + ukalkulisani PDV reversed (debit)
        Assert.AreNearlyEqual(-12000, InvAfter - InvBefore, 0.01, '134 must be relieved at full retail on a POS sale');
        Assert.AreNearlyEqual(2000, VATAfter - VATBefore, 0.01, 'ukalkulisani PDV reversed on POS sale');
        Assert.AreNearlyEqual(4000, MarginAfter - MarginBefore, 0.01, 'RUC reversed on POS sale');
    end;

    [Test]
    procedure POSSale_UsesPerLocationCalcAccounts()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        POSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";
        PaymentMethod: Code[10];
        RetailLoc: Code[10];
        LocVATAcc: Code[20];
        LocMarginAcc: Code[20];
        VATBefore: Decimal;
        MarginBefore: Decimal;
        GlobalVATBefore: Decimal;
    begin
        // [SCENARIO] A POS sale from a location with its own Calc accounts posts the razduzenje there, not on the global accounts
        // [GIVEN] Retail POS whose location has per-location Calc accounts, item cost 600 / retail 1200, 10 pcs in stock
        Lib.InitializeSetup();
        Lib.SetupRetailPOS(POSUnit, POSStore, PaymentMethod, RetailLoc);
        Lib.SetLocationCalcAccounts(RetailLoc, LocVATAcc, LocMarginAcc);
        Lib.CreateRetailItemForPOS(Item, 600, 1200, POSUnit, POSStore, RetailLoc);
        Lib.PostRetailPurchaseInvoice(Item."No.", RetailLoc, 10, 600);

        VATBefore := Lib.GetGLAccountBalance(LocVATAcc);
        MarginBefore := Lib.GetGLAccountBalance(LocMarginAcc);
        GlobalVATBefore := Lib.GetGLAccountBalance(Lib.GlobalVATAcc());

        // [WHEN] Selling all 10 pcs on the POS
        Lib.SellRetailPOSItemAndPost(POSUnit, PaymentMethod, Item."No.", 10, 12000, 0);

        // [THEN] The razduzenje reverses PDV + RUC on the per-location accounts, leaving the global ones untouched
        Assert.AreNearlyEqual(2000, Lib.GetGLAccountBalance(LocVATAcc) - VATBefore, 0.01, 'PDV reversed on per-location account');
        Assert.AreNearlyEqual(4000, Lib.GetGLAccountBalance(LocMarginAcc) - MarginBefore, 0.01, 'RUC reversed on per-location account');
        Assert.AreNearlyEqual(0, Lib.GetGLAccountBalance(Lib.GlobalVATAcc()) - GlobalVATBefore, 0.01, 'Global PDV must be untouched by a per-location POS sale');
    end;

    [Test]
    procedure POSSale_MultipleFIFOCostLayers()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        POSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";
        PaymentMethod: Code[10];
        RetailLoc: Code[10];
        VATBefore: Decimal;
        MarginBefore: Decimal;
        InvBefore: Decimal;
    begin
        // [SCENARIO] A POS sale drawing across two FIFO cost layers (different cost, same retail) relieves 134 at retail
        // [GIVEN] 5 pcs @ cost 600 then 5 pcs @ cost 800, both retail 1200 incl 20% VAT
        Lib.InitializeSetup();
        Lib.SetupRetailPOS(POSUnit, POSStore, PaymentMethod, RetailLoc);
        Lib.CreateRetailItemForPOS(Item, 600, 1200, POSUnit, POSStore, RetailLoc);
        Lib.PostRetailPurchaseInvoice(Item."No.", RetailLoc, 5, 600);
        Lib.PostRetailPurchaseInvoice(Item."No.", RetailLoc, 5, 800);

        VATBefore := Lib.GetGLAccountBalance(Lib.GlobalVATAcc());
        MarginBefore := Lib.GetGLAccountBalance(Lib.GlobalMarginAcc());
        InvBefore := Lib.GetGLAccountBalance(Lib.RetailInvAcc(RetailLoc));

        // [WHEN] Selling 6 pcs on the POS (FIFO 5 @600 + 1 @800, COGS 3800) at retail 1200
        Lib.SellRetailPOSItemAndPost(POSUnit, PaymentMethod, Item."No.", 6, 7200, 0);

        // [THEN] 134 relieved at retail 7200 regardless of cost layers; PDV 1200; RUC = (7200-3800)-1200 = 2200
        Assert.AreNearlyEqual(-7200, Lib.GetGLAccountBalance(Lib.RetailInvAcc(RetailLoc)) - InvBefore, 0.01, '134 relieved at full retail across cost layers');
        Assert.AreNearlyEqual(1200, Lib.GetGLAccountBalance(Lib.GlobalVATAcc()) - VATBefore, 0.01, 'ukalkulisani PDV reversed');
        Assert.AreNearlyEqual(2200, Lib.GetGLAccountBalance(Lib.GlobalMarginAcc()) - MarginBefore, 0.01, 'RUC reversed (per-layer cost)');
    end;

    [Test]
    [HandlerFunctions('POSMessageHandler')]
    procedure POSSale_LineDiscountPostsNivelationAndRazduzenje()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        POSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";
        PaymentMethod: Code[10];
        RetailLoc: Code[10];
        VATBefore: Decimal;
        MarginBefore: Decimal;
        InvBefore: Decimal;
        NivBefore: Integer;
    begin
        // [SCENARIO] A POS line discount routes the price reduction through a nivelation, then relieves the cost basis via razduzenje (Serbian model)
        // [GIVEN] Retail POS, item cost 600 / retail 1200 incl 20% VAT, 10 pcs in stock
        Lib.InitializeSetup();
        Lib.SetupRetailPOS(POSUnit, POSStore, PaymentMethod, RetailLoc);
        Lib.CreateRetailItemForPOS(Item, 600, 1200, POSUnit, POSStore, RetailLoc);
        Lib.PostRetailPurchaseInvoice(Item."No.", RetailLoc, 10, 600);

        VATBefore := Lib.GetGLAccountBalance(Lib.GlobalVATAcc());
        MarginBefore := Lib.GetGLAccountBalance(Lib.GlobalMarginAcc());
        InvBefore := Lib.GetGLAccountBalance(Lib.RetailInvAcc(RetailLoc));
        NivBefore := Lib.PostedNivelationCount();

        // [WHEN] Selling 10 pcs with a 10% line discount (sells at 1080 incl VAT) and posting
        Lib.SellRetailPOSItemAndPost(POSUnit, PaymentMethod, Item."No.", 10, 10800, 10);

        // [THEN] A nivelation document was posted for the discount
        Assert.AreEqual(NivBefore + 1, Lib.PostedNivelationCount(), 'A nivelation must be posted for the POS line discount');
        // [THEN] The full cost basis still leaves 134; PDV + RUC net the same as an undiscounted sale (split across nivelation + razduzenje)
        Assert.AreNearlyEqual(-12000, Lib.GetGLAccountBalance(Lib.RetailInvAcc(RetailLoc)) - InvBefore, 0.01, '134 relieved at full retail value across nivelation + razduzenje');
        Assert.AreNearlyEqual(2000, Lib.GetGLAccountBalance(Lib.GlobalVATAcc()) - VATBefore, 0.01, 'ukalkulisani PDV net reversed');
        Assert.AreNearlyEqual(4000, Lib.GetGLAccountBalance(Lib.GlobalMarginAcc()) - MarginBefore, 0.01, 'RUC net reversed');
    end;

    [MessageHandler]
    procedure POSMessageHandler(Msg: Text[1024])
    begin
    end;
}
