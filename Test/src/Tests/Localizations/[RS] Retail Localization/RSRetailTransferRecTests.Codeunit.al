codeunit 85304 "NPR RS Retail Trans. Rec Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure TransferReceipt_PostsVATAndRUCSplit()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Retail: Record Location;
        Whse: Record Location;
        Transit: Record Location;
        ShptNo: Code[20];
        RcptNo: Code[20];
    begin
        // [SCENARIO] Wholesale -> retail transfer receipt must split the markup into PDV and RUC
        // [GIVEN] Retail + wholesale + in-transit locations, item cost 600 / retail 1200 incl 20% VAT
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateWholesaleLocation(Whse);
        Lib.CreateInTransitLocation(Transit);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);

        // [GIVEN] Stock in the wholesale location (non-retail -> no RS calc on this purchase)
        Lib.PostRetailPurchaseInvoice(Item."No.", Whse.Code, 10, 600);

        // [WHEN] Transferring 10 pcs wholesale -> retail
        Lib.PostRetailTransfer(Whse.Code, Retail.Code, Transit.Code, Item."No.", 10, ShptNo, RcptNo);

        // [THEN] The receipt adds markup with the correct split at the retail location
        Lib.AssertCalcGL(RcptNo, Lib.RetailInvAcc(Retail.Code), Lib.GlobalVATAcc(), Lib.GlobalMarginAcc(), 6000, 2000, 4000);
    end;

    [Test]
    procedure TransferReceipt_WholesaleToRetail_FullGL()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Retail: Record Location;
        Whse: Record Location;
        Transit: Record Location;
        ShptNo: Code[20];
        RcptNo: Code[20];
    begin
        // [SCENARIO] Full G/L of a wholesale -> retail transfer: wholesale relieved at cost, retail established at full retail (cost + markup)
        // [GIVEN] Retail + wholesale + in-transit, item cost 600 / retail 1200 incl 20% VAT, 10 pcs in wholesale
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateWholesaleLocation(Whse);
        Lib.CreateInTransitLocation(Transit);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        Lib.PostRetailPurchaseInvoice(Item."No.", Whse.Code, 10, 600);

        // [WHEN] Transferring all 10 pcs wholesale -> retail
        Lib.PostRetailTransfer(Whse.Code, Retail.Code, Transit.Code, Item."No.", 10, ShptNo, RcptNo);

        // [THEN] Net across shipment+receipt: wholesale relieved at cost (-6000); retail lands at full retail (+12000 = cost 6000 + markup 6000)
        Lib.AssertGLNetForTransfer(ShptNo, RcptNo, Lib.RetailInvAcc(Whse.Code), -6000, 'Wholesale source relieved at cost');
        Lib.AssertGLNetForTransfer(ShptNo, RcptNo, Lib.RetailInvAcc(Retail.Code), 12000, 'Retail destination established at full retail');
        // [THEN] ukalkulisani PDV + RUC established at the retail location (credit)
        Lib.AssertGLNetForTransfer(ShptNo, RcptNo, Lib.GlobalVATAcc(), -2000, 'ukalkulisani PDV established (credit)');
        Lib.AssertGLNetForTransfer(ShptNo, RcptNo, Lib.GlobalMarginAcc(), -4000, 'RUC established (credit)');
    end;
}
