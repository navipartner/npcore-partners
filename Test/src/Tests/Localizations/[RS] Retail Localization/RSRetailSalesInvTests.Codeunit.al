codeunit 85268 "NPR RS Retail Sales Inv Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure SalesInvoice_RelievesRetailAndReversesMarkup()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Retail: Record Location;
        PostedNo: Code[20];
    begin
        // [SCENARIO] Selling retail goods relieves 134 at retail and reverses RUC + ukalkulisani PDV (razduzenje)
        // [GIVEN] Retail stock (cost 600 / retail 1200 incl 20% VAT), 10 pcs
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 10, 600);

        // [WHEN] Selling all 10 pcs at retail 1200 incl VAT
        PostedNo := Lib.PostRetailSalesInvoice(Item."No.", Retail.Code, 10, 1200);

        // [THEN] Razduzenje: 134 relieved at retail; RUC + ukalkulisani PDV reversed (debit)
        Lib.AssertGLNetChange(PostedNo, Lib.RetailInvAcc(Retail.Code), -12000, 'Retail inventory relieved at full retail');
        Lib.AssertGLNetChange(PostedNo, Lib.GlobalMarginAcc(), 4000, 'RUC reversed (debit)');
        Lib.AssertGLNetChange(PostedNo, Lib.GlobalVATAcc(), 2000, 'ukalkulisani PDV reversed (debit)');
    end;

    [Test]
    procedure SalesInvoice_PartialQuantity()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Retail: Record Location;
        PostedNo: Code[20];
    begin
        // [SCENARIO] Selling a partial quantity relieves 134 at retail and reverses the markup proportionally
        // [GIVEN] 10 pcs in stock at cost 600 / retail 1200 incl 20% VAT
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 10, 600);

        // [WHEN] Selling only 6 of the 10 pcs at retail 1200 incl VAT
        PostedNo := Lib.PostRetailSalesInvoice(Item."No.", Retail.Code, 6, 1200);

        // [THEN] 134 relieved 1200*6 = 7200; markup (1200-600)*6 = 3600 -> PDV 1200, RUC 2400
        Lib.AssertGLNetChange(PostedNo, Lib.RetailInvAcc(Retail.Code), -7200, 'Retail relieved at retail for 6 of 10 pcs');
        Lib.AssertGLNetChange(PostedNo, Lib.GlobalVATAcc(), 1200, 'ukalkulisani PDV reversed on 6 pcs');
        Lib.AssertGLNetChange(PostedNo, Lib.GlobalMarginAcc(), 2400, 'RUC reversed on 6 pcs');
    end;

    [Test]
    procedure SalesInvoice_MultipleFIFOCostLayers()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Retail: Record Location;
        PostedNo: Code[20];
    begin
        // [SCENARIO] Selling across two FIFO cost layers (different cost, same retail) must relieve 134 at retail regardless of cost
        // [GIVEN] 5 pcs @ cost 600 then 5 pcs @ cost 800, both retail 1200 incl 20% VAT
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 5, 600);
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 5, 800);

        // [WHEN] Selling 6 pcs (FIFO draws 5 @600 + 1 @800, COGS 3800) at retail 1200
        PostedNo := Lib.PostRetailSalesInvoice(Item."No.", Retail.Code, 6, 1200);

        // [THEN] 134 relieved at retail 1200*6 = 7200; PDV = 7200*20/120 = 1200; RUC = (7200-3800) - 1200 = 2200
        Lib.AssertGLNetChange(PostedNo, Lib.RetailInvAcc(Retail.Code), -7200, '134 relieved at full retail across cost layers');
        Lib.AssertGLNetChange(PostedNo, Lib.GlobalVATAcc(), 1200, 'ukalkulisani PDV reversed');
        Lib.AssertGLNetChange(PostedNo, Lib.GlobalMarginAcc(), 2200, 'RUC reversed (per-layer cost)');
    end;
}
