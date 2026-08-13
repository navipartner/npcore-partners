codeunit 85305 "NPR RS Retail Trans. Sh Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure TransferShipment_RelievesRetailNotTransit()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Retail: Record Location;
        Whse: Record Location;
        Transit: Record Location;
        ShptNo: Code[20];
        RcptNo: Code[20];
    begin
        // [SCENARIO] Retail -> wholesale shipment must relieve the retail account of the markup, not the transit account9
        // [GIVEN] Retail stock (cost 600 / retail 1200 incl 20% VAT) established via a retail purchase
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateWholesaleLocation(Whse);
        Lib.CreateInTransitLocation(Transit);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 10, 600);

        // [WHEN] Transferring 10 pcs retail -> wholesale
        Lib.PostRetailTransfer(Retail.Code, Whse.Code, Transit.Code, Item."No.", 10, ShptNo, RcptNo);

        // [THEN] Net G/L across the transfer (Serbian model): retail source relieved at retail; wholesale dest at cost; RUC/PDV reversed (debit)
        Lib.AssertGLNetForTransfer(ShptNo, RcptNo, Lib.RetailInvAcc(Retail.Code), -12000, 'Retail source must be relieved at full retail (cost+markup)');
        Lib.AssertGLNetForTransfer(ShptNo, RcptNo, Lib.RetailInvAcc(Whse.Code), 6000, 'Wholesale destination must land at cost');
        Lib.AssertGLNetForTransfer(ShptNo, RcptNo, Lib.GlobalMarginAcc(), 4000, 'RUC must be reversed (debit)');
        Lib.AssertGLNetForTransfer(ShptNo, RcptNo, Lib.GlobalVATAcc(), 2000, 'ukalkulisani PDV must be reversed (debit)');
    end;

    [Test]
    procedure TransferShipment_MultipleFIFOCostLayers()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Retail: Record Location;
        Whse: Record Location;
        Transit: Record Location;
        ShptNo: Code[20];
        RcptNo: Code[20];
    begin
        // [SCENARIO] Retail -> wholesale shipment across two FIFO cost layers relieves source at retail, lands wholesale at true FIFO cost, corrects once
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateWholesaleLocation(Whse);
        Lib.CreateInTransitLocation(Transit);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 5, 600);
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 5, 800);

        // [WHEN] Transferring 6 pcs retail -> wholesale (FIFO 5 @600 + 1 @800, true cost 3800)
        Lib.PostRetailTransfer(Retail.Code, Whse.Code, Transit.Code, Item."No.", 6, ShptNo, RcptNo);

        // [THEN] retail relieved at retail 7200; wholesale at true cost 3800; markup 3400 reversed once -> PDV 1200, RUC 2200
        Lib.AssertGLNetForTransfer(ShptNo, RcptNo, Lib.RetailInvAcc(Retail.Code), -7200, 'Retail source relieved at full retail across cost layers');
        Lib.AssertGLNetForTransfer(ShptNo, RcptNo, Lib.RetailInvAcc(Whse.Code), 3800, 'Wholesale destination lands at true FIFO cost');
        Lib.AssertGLNetForTransfer(ShptNo, RcptNo, Lib.GlobalVATAcc(), 1200, 'ukalkulisani PDV reversed once');
        Lib.AssertGLNetForTransfer(ShptNo, RcptNo, Lib.GlobalMarginAcc(), 2200, 'RUC reversed once');
    end;

    // The RS undo-transfer-shipment addition only exists on BC23+, so guard the undo test to match.
    var
        Assert: Codeunit "Assert";

    [Test]
    procedure UndoTransferShipment_ReAddsRetailVATAndMarkup()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Retail: Record Location;
        Whse: Record Location;
        Transit: Record Location;
        ShptNo: Code[20];
        VATBefore: Decimal;
        VATAfter: Decimal;
        MarginBefore: Decimal;
        MarginAfter: Decimal;
    begin
        // [SCENARIO] Undoing a retail -> wholesale shipment re-adds 134 / RUC / ukalkulisani PDV on the retail location, using the item's real VAT rate
        // [GIVEN] Retail stock (cost 600 / retail 1200 incl 20% VAT) shipped out to wholesale but not yet received (so it is undoable)
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateWholesaleLocation(Whse);
        Lib.CreateInTransitLocation(Transit);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 10, 600);
        ShptNo := Lib.ShipRetailTransferOnly(Retail.Code, Whse.Code, Transit.Code, Item."No.", 10);

        VATBefore := Lib.GetGLAccountBalance(Lib.GlobalVATAcc());
        MarginBefore := Lib.GetGLAccountBalance(Lib.GlobalMarginAcc());

        // [WHEN] Undoing the transfer shipment
        Lib.UndoRetailTransferShipment(ShptNo);

        VATAfter := Lib.GetGLAccountBalance(Lib.GlobalVATAcc());
        MarginAfter := Lib.GetGLAccountBalance(Lib.GlobalMarginAcc());

        // [THEN] Undo re-adds ukalkulisani PDV at the item's real 20% (credit): 1200*10*20/120 = 2000.
        Assert.AreNearlyEqual(-2000, VATAfter - VATBefore, 0.01, 'Undo must re-add PDV at the item VAT rate');
        // [THEN] Undo re-adds RUC (credit): markup 6000 - PDV 2000 = 4000
        Assert.AreNearlyEqual(-4000, MarginAfter - MarginBefore, 0.01, 'Undo must re-add RUC');
    end;

    [Test]
    procedure UndoTransferShipment_RetailToRetail_ReAddsMarkup()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Retail: Record Location;
        Retail2: Record Location;
        Transit: Record Location;
        ShptNo: Code[20];
        VATBefore: Decimal;
        MarginBefore: Decimal;
    begin
        // [SCENARIO] Undoing a retail -> retail shipment must re-add the source markup too (undo guard mirrors the COM-1218 shipment guard)
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailLocation(Retail2);
        Lib.CreateInTransitLocation(Transit);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 10, 600);
        ShptNo := Lib.ShipRetailTransferOnly(Retail.Code, Retail2.Code, Transit.Code, Item."No.", 10);

        VATBefore := Lib.GetGLAccountBalance(Lib.GlobalVATAcc());
        MarginBefore := Lib.GetGLAccountBalance(Lib.GlobalMarginAcc());

        // [WHEN] Undoing the retail -> retail shipment
        Lib.UndoRetailTransferShipment(ShptNo);

        // [THEN] The undo re-adds PDV + RUC on the source retail location (credit) - not skipped as before
        Assert.AreNearlyEqual(-2000, Lib.GetGLAccountBalance(Lib.GlobalVATAcc()) - VATBefore, 0.01, 'Undo must re-add PDV for a retail->retail shipment');
        Assert.AreNearlyEqual(-4000, Lib.GetGLAccountBalance(Lib.GlobalMarginAcc()) - MarginBefore, 0.01, 'Undo must re-add RUC for a retail->retail shipment');
    end;
}
