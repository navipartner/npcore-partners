codeunit 85307 "NPR RS Retail CrMemo Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure SalesCreditMemo_ReAddsRetailAndMarkup()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Retail: Record Location;
        PostedNo: Code[20];
    begin
        // [SCENARIO] A retail sales credit memo (return) puts goods back into retail at retail value and re-adds RUC + ukalkulisani PDV
        // [GIVEN] A retail item (cost 600 / retail 1200 incl 20% VAT) with some stock so cost is established
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 10, 600);

        // [WHEN] Posting a sales credit memo (return) of 10 pcs at retail 1200 incl VAT
        PostedNo := Lib.PostRetailSalesCreditMemo(Item."No.", Retail.Code, 10, 1200);

        // [THEN] 134 increases at full retail; RUC + ukalkulisani PDV re-added (credit) - the reverse of a sale
        Lib.AssertGLNetChange(PostedNo, Lib.RetailInvAcc(Retail.Code), 12000, 'Retail inventory increased at full retail');
        Lib.AssertGLNetChange(PostedNo, Lib.GlobalMarginAcc(), -4000, 'RUC re-added (credit)');
        Lib.AssertGLNetChange(PostedNo, Lib.GlobalVATAcc(), -2000, 'ukalkulisani PDV re-added (credit)');
    end;
}
