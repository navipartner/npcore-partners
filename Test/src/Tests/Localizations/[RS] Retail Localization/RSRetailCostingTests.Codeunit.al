codeunit 85428 "NPR RS Retail Costing Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;

    [Test]
    procedure RetailPurchaseCost_ReachesItemUnitCost()
    var
        Item: Record Item;
        Location: Record Location;
        LibraryRSRetailLoc: Codeunit "NPR Library - RS Retail Loc.";
    begin
        // [SCENARIO] Genuine acquisition cost posted at a retail location must reach the item's Unit Cost.
        // Previously every retail location was excluded from ItemCostManagement, so an item stocked
        // only at retail locations had its Unit Cost computed from an empty set and never moved.

        // [GIVEN] RS localization active, a retail location, and an item created with Unit Cost 600
        LibraryRSRetailLoc.InitializeSetup();
        LibraryRSRetailLoc.CreateRetailLocation(Location);
        LibraryRSRetailLoc.CreateRetailItem(Item, 600, 1200, false, Location.Code);

        // [WHEN] Buying it into the retail location at a different cost, 750, and adjusting cost
        LibraryRSRetailLoc.PostRetailPurchaseInvoice(Item."No.", Location.Code, 10, 750);
        LibraryRSRetailLoc.RunAdjustCostItemEntries(Item."No.");

        // [THEN] Unit Cost follows the purchase, rather than staying at the item's original 600
        _Assert.AreEqual(750, LibraryRSRetailLoc.GetItemUnitCost(Item."No."), 'Retail-location purchase cost must reach Item Unit Cost.');
    end;

    [Test]
    procedure RetailMarkup_ExcludedFromItemUnitCost()
    var
        Item: Record Item;
        Location: Record Location;
        LibraryRSRetailLoc: Codeunit "NPR Library - RS Retail Loc.";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] The retail markup layer must stay invisible to standard costing. Counting the
        // markup would drag the item's cost towards its retail selling price. The entries are excluded
        // because they are synthesised by the localization, NOT because they are quantity-less - the
        // purchase markup entry happens to carry zero quantity, but the Standard and COGS Correction
        // entries share the same entry type and deliberately do carry quantities.

        // [GIVEN] RS localization active, retail location, item with a retail price of 1200 incl VAT
        LibraryRSRetailLoc.InitializeSetup();
        LibraryRSRetailLoc.CreateRetailLocation(Location);
        LibraryRSRetailLoc.CreateRetailItem(Item, 600, 1200, false, Location.Code);

        // [WHEN] Posting the purchase, which also creates the markup entry, and adjusting cost
        PostedDocumentNo := LibraryRSRetailLoc.PostRetailPurchaseInvoice(Item."No.", Location.Code, 10, 750);
        LibraryRSRetailLoc.RunAdjustCostItemEntries(Item."No.");

        // [THEN] The markup entry exists but Unit Cost is the acquisition cost, not the retail price
        _Assert.IsTrue(LibraryRSRetailLoc.CountRSCalcValueEntries(PostedDocumentNo, true) > 0, 'The purchase must have produced at least one marked RS retail calculation entry.');
        _Assert.AreEqual(750, LibraryRSRetailLoc.GetItemUnitCost(Item."No."), 'The retail markup must not inflate Item Unit Cost.');
    end;

    [Test]
    procedure StandardPurchaseValueEntry_IsNotMarked()
    var
        Item: Record Item;
        Location: Record Location;
        LibraryRSRetailLoc: Codeunit "NPR Library - RS Retail Loc.";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] The purchase addition maps the STANDARD value entry into the value entry mapping
        // table purely to track remaining quantity as an inbound cost source. That entry must not be
        // marked as an RS retail calculation entry - marking it would hide genuine acquisition cost
        // from the item's Unit Cost, which is the exact failure this work exists to fix.

        // [GIVEN] RS localization active, retail location, item created with Unit Cost 600 and a
        // retail price of 1200 incl 20% VAT
        LibraryRSRetailLoc.InitializeSetup();
        LibraryRSRetailLoc.CreateRetailLocation(Location);
        LibraryRSRetailLoc.CreateRetailItem(Item, 600, 1200, false, Location.Code);

        // [WHEN] Posting a purchase invoice of qty 10 at cost 750 into the retail location
        PostedDocumentNo := LibraryRSRetailLoc.PostRetailPurchaseInvoice(Item."No.", Location.Code, 10, 750);

        // [THEN] The unmarked entries still carry the full acquisition cost of 7500
        _Assert.AreEqual(7500, LibraryRSRetailLoc.GetUnmarkedCostAmount(PostedDocumentNo), 'The standard purchase value entry must stay unmarked and keep its acquisition cost.');
    end;

    [Test]
    procedure NonRetailTransfer_IsCostAdjusted()
    var
        Item: Record Item;
        FromLocation: Record Location;
        ToLocation: Record Location;
        InTransitLocation: Record Location;
        LibraryRSRetailLoc: Codeunit "NPR Library - RS Retail Loc.";
        OrderNo: Code[20];
        ShipmentNo: Code[20];
        ReceiptNo: Code[20];
    begin
        // [SCENARIO] Enabling RS retail localization must not stop cost adjustment for transfers that
        // have nothing to do with retail. The guard previously short-circuited on entry type before it
        // looked at the location, so every transfer in the company lost cost adjustment.

        // [GIVEN] RS localization active and two NON-retail locations plus an in-transit location
        LibraryRSRetailLoc.InitializeSetup();
        LibraryRSRetailLoc.CreateWholesaleLocation(FromLocation);
        LibraryRSRetailLoc.CreateWholesaleLocation(ToLocation);
        LibraryRSRetailLoc.CreateInTransitLocation(InTransitLocation);
        LibraryRSRetailLoc.CreateRetailItem(Item, 100, 200, false, FromLocation.Code);

        // [GIVEN] Goods received at an expected cost of 100 and transferred on before invoicing
        OrderNo := LibraryRSRetailLoc.ReceivePurchaseOrderOnly(Item."No.", FromLocation.Code, 10, 100);
        LibraryRSRetailLoc.PostRetailTransfer(FromLocation.Code, ToLocation.Code, InTransitLocation.Code, Item."No.", 10, ShipmentNo, ReceiptNo);

        // [WHEN] The purchase is then invoiced at 150, so there is a real cost change to propagate
        LibraryRSRetailLoc.InvoiceReceivedPurchaseAtCost(OrderNo, 150);
        LibraryRSRetailLoc.RunAdjustCostItemEntries(Item."No.");

        // [THEN] The transfer was cost-adjusted
        _Assert.IsTrue(LibraryRSRetailLoc.CountAdjustmentValueEntriesForTransfer(ShipmentNo) > 0, 'A transfer between two non-retail locations must still be cost adjusted.');
    end;

    [Test]
    procedure RetailTransfer_StaysSuppressed()
    var
        Item: Record Item;
        FromLocation: Record Location;
        RetailLocation: Record Location;
        InTransitLocation: Record Location;
        LibraryRSRetailLoc: Codeunit "NPR Library - RS Retail Loc.";
        OrderNo: Code[20];
        ShipmentNo: Code[20];
        ReceiptNo: Code[20];
    begin
        // [SCENARIO] Where the transfer does touch a retail location the localization still owns the
        // valuation, so standard cost adjustment must remain suppressed - but only for that leg. A
        // transfer spans three legs: from-location, in-transit and to-location. Only the leg sitting
        // at the retail location is suppressed; the wholesale and in-transit legs are adjusted as
        // normal, which is the whole point of no longer suppressing transfers wholesale.

        // [GIVEN] RS localization active, a non-retail source and a retail destination
        LibraryRSRetailLoc.InitializeSetup();
        LibraryRSRetailLoc.CreateWholesaleLocation(FromLocation);
        LibraryRSRetailLoc.CreateRetailLocation(RetailLocation);
        LibraryRSRetailLoc.CreateInTransitLocation(InTransitLocation);
        LibraryRSRetailLoc.CreateRetailItem(Item, 100, 200, false, RetailLocation.Code);

        // [GIVEN] Goods received at an expected cost of 100 and transferred into the retail location
        OrderNo := LibraryRSRetailLoc.ReceivePurchaseOrderOnly(Item."No.", FromLocation.Code, 10, 100);
        LibraryRSRetailLoc.PostRetailTransfer(FromLocation.Code, RetailLocation.Code, InTransitLocation.Code, Item."No.", 10, ShipmentNo, ReceiptNo);

        // [WHEN] The purchase is invoiced at 150 and cost adjustment runs
        LibraryRSRetailLoc.InvoiceReceivedPurchaseAtCost(OrderNo, 150);
        LibraryRSRetailLoc.RunAdjustCostItemEntries(Item."No.");

        // [THEN] The receipt leg sitting at the retail location was left alone, while the wholesale
        // source leg on the shipment was adjusted normally
        _Assert.AreEqual(0, LibraryRSRetailLoc.CountAdjustmentValueEntriesAtLocation(ReceiptNo, RetailLocation.Code), 'The transfer leg at the retail location must stay suppressed.');
        _Assert.IsTrue(LibraryRSRetailLoc.CountAdjustmentValueEntriesAtLocation(ShipmentNo, FromLocation.Code) > 0, 'The non-retail source leg of the same transfer must still be cost adjusted.');
    end;

    [Test]
    procedure TransferIntoRetail_CostAdjustmentLeavesRetailCalcUntouched()
    var
        Item: Record Item;
        FromLocation: Record Location;
        RetailLocation: Record Location;
        InTransitLocation: Record Location;
        LibraryRSRetailLoc: Codeunit "NPR Library - RS Retail Loc.";
        LocationVATAccountNo: Code[20];
        LocationMarginAccountNo: Code[20];
        OrderNo: Code[20];
        ShipmentNo: Code[20];
        ReceiptNo: Code[20];
        InventoryBalanceBefore: Decimal;
        VATBalanceBefore: Decimal;
        MarginBalanceBefore: Decimal;
    begin
        // [SCENARIO] Scoping the transfer guard to retail locations means the non-retail legs of a
        // transfer are cost adjusted again, where previously no transfer anywhere was. For a transfer
        // INTO a retail location that means the shipment legs move while the retail receipt leg stays
        // suppressed. This must not disturb the retail location's 134 / ukalkulisani PDV / RUC, which
        // are carried at retail price and owned by the localization, not by standard costing.

        // [GIVEN] A non-retail source, a retail destination with its own Calc accounts, and stock
        // received at an expected cost of 100 then transferred into the retail location
        LibraryRSRetailLoc.InitializeSetup();
        LibraryRSRetailLoc.CreateWholesaleLocation(FromLocation);
        LibraryRSRetailLoc.CreateRetailLocationWithCalcAccounts(RetailLocation, LocationVATAccountNo, LocationMarginAccountNo);
        LibraryRSRetailLoc.CreateInTransitLocation(InTransitLocation);
        LibraryRSRetailLoc.CreateRetailItem(Item, 100, 200, false, RetailLocation.Code);

        OrderNo := LibraryRSRetailLoc.ReceivePurchaseOrderOnly(Item."No.", FromLocation.Code, 10, 100);
        LibraryRSRetailLoc.PostRetailTransfer(FromLocation.Code, RetailLocation.Code, InTransitLocation.Code, Item."No.", 10, ShipmentNo, ReceiptNo);

        InventoryBalanceBefore := LibraryRSRetailLoc.GetGLAccountBalance(LibraryRSRetailLoc.RetailInvAcc(RetailLocation.Code));
        VATBalanceBefore := LibraryRSRetailLoc.GetGLAccountBalance(LocationVATAccountNo);
        MarginBalanceBefore := LibraryRSRetailLoc.GetGLAccountBalance(LocationMarginAccountNo);

        // [WHEN] The purchase is invoiced at 150, giving cost adjustment real work, and it runs
        LibraryRSRetailLoc.InvoiceReceivedPurchaseAtCost(OrderNo, 150);
        LibraryRSRetailLoc.RunAdjustCostItemEntries(Item."No.");

        // [THEN] Cost adjustment demonstrably did reach the non-retail source leg - without this the
        // assertions below would pass vacuously
        _Assert.IsTrue(LibraryRSRetailLoc.CountAdjustmentValueEntriesAtLocation(ShipmentNo, FromLocation.Code) > 0, 'The non-retail source leg must have been cost adjusted, otherwise this test proves nothing.');

        // [THEN] The transfer receipt's own markup entry was stamped, so it is excluded from standard
        // costing by entry type rather than by location. This is the RSTransRecGLAddition stamp site -
        // the sibling transfer suites assert only G/L balances, which the stamp does not move.
        _Assert.IsTrue(LibraryRSRetailLoc.CountRSCalcValueEntries(ReceiptNo, true) > 0, 'The transfer receipt into the retail location must have produced a marked RS retail calculation entry.');

        // [THEN] ...and yet the retail leg and the retail calc accounts are untouched
        _Assert.AreEqual(0, LibraryRSRetailLoc.CountAdjustmentValueEntriesAtLocation(ReceiptNo, RetailLocation.Code), 'The retail receipt leg must stay suppressed.');
        LibraryRSRetailLoc.AssertGLAccountBalance(LibraryRSRetailLoc.RetailInvAcc(RetailLocation.Code), InventoryBalanceBefore, '134 must be unchanged by cost adjustment');
        LibraryRSRetailLoc.AssertGLAccountBalance(LocationVATAccountNo, VATBalanceBefore, 'ukalkulisani PDV must be unchanged by cost adjustment');
        LibraryRSRetailLoc.AssertGLAccountBalance(LocationMarginAccountNo, MarginBalanceBefore, 'RUC must be unchanged by cost adjustment');
    end;

    [Test]
    procedure TransferOutOfRetail_CostAdjustmentLeavesTransitCorrectionIntact()
    var
        Item: Record Item;
        RetailLocation: Record Location;
        ToLocation: Record Location;
        InTransitLocation: Record Location;
        LibraryRSRetailLoc: Codeunit "NPR Library - RS Retail Loc.";
        LocationVATAccountNo: Code[20];
        LocationMarginAccountNo: Code[20];
        OrderNo: Code[20];
        ShipmentNo: Code[20];
        ReceiptNo: Code[20];
        RetailInventoryBalanceBefore: Decimal;
        TransitInventoryBalanceBefore: Decimal;
        VATBalanceBefore: Decimal;
        MarginBalanceBefore: Decimal;
    begin
        // [SCENARIO] Transfers OUT of a retail location are the direction the other transfer tests do
        // not cover, and they are the risky one. RSTransShGLAddition posts a transit correction that
        // pushes the in-transit cost back DOWN from the retail-inflated cost to the true cost. The
        // in-transit location is not a retail location, so scoping the guard to retail locations
        // leaves both in-transit legs adjustable where previously no transfer leg anywhere was. If
        // standard cost adjustment recomputed the in-transit cost from the retail-side entry - whose
        // cost amount carries the markup layer - it would re-inflate exactly what the transit
        // correction removed, and move the G/L.

        // [GIVEN] Automatic cost adjustment off, so adjustment runs only when this test says so
        LibraryRSRetailLoc.InitializeSetup();
        LibraryRSRetailLoc.SetAutomaticCostAdjustment(false);
        LibraryRSRetailLoc.CreateRetailLocationWithCalcAccounts(RetailLocation, LocationVATAccountNo, LocationMarginAccountNo);
        LibraryRSRetailLoc.CreateWholesaleLocation(ToLocation);
        LibraryRSRetailLoc.CreateInTransitLocation(InTransitLocation);
        LibraryRSRetailLoc.CreateRetailItem(Item, 600, 1200, false, RetailLocation.Code);

        // [GIVEN] Two lots into the retail location, because this scenario needs two things that a
        // single lot cannot provide at once. Lot 1 is a posted purchase INVOICE, which is what builds
        // the markup layer - RSPurhcGLAddition runs on Purch.-Post OnRunOnAfterPostInvoice, so a
        // receipt alone leaves nothing for the transfer shipment to correct. Lot 2 is received only,
        // so its cost is still open and can be changed after the transfer to give cost adjustment
        // real work to propagate.
        LibraryRSRetailLoc.PostRetailPurchaseInvoice(Item."No.", RetailLocation.Code, 10, 600);
        OrderNo := LibraryRSRetailLoc.ReceivePurchaseOrderOnly(Item."No.", RetailLocation.Code, 10, 600);

        // [GIVEN] Both lots transferred out through in-transit, where RSTransShGLAddition compares the
        // retail-inflated transit cost against the true acquisition cost and posts the correction
        LibraryRSRetailLoc.PostRetailTransfer(RetailLocation.Code, ToLocation.Code, InTransitLocation.Code, Item."No.", 20, ShipmentNo, ReceiptNo);

        // [GIVEN] The transit correction this test is named after actually exists. It is created at
        // shipment time, and only when the transit cost differs from the true cost - so without this
        // the four balance assertions below cannot fail for the stated reason. On a transfer shipment
        // the transit correction is the only synthesised entry RSTransShGLAddition produces, so
        // counting marked entries on the shipment is specific to it.
        _Assert.IsTrue(LibraryRSRetailLoc.CountRSCalcValueEntries(ShipmentNo, true) > 0, 'The transfer out of the retail location must have produced a transit correction entry, otherwise this test asserts nothing about it.');

        // [GIVEN] ...and lot 2 then invoiced at 900, leaving a real cost change to propagate onwards
        // through the in-transit legs
        LibraryRSRetailLoc.InvoiceReceivedPurchaseAtCost(OrderNo, 900);

        RetailInventoryBalanceBefore := LibraryRSRetailLoc.GetGLAccountBalance(LibraryRSRetailLoc.RetailInvAcc(RetailLocation.Code));
        TransitInventoryBalanceBefore := LibraryRSRetailLoc.GetGLAccountBalance(LibraryRSRetailLoc.RetailInvAcc(InTransitLocation.Code));
        VATBalanceBefore := LibraryRSRetailLoc.GetGLAccountBalance(LocationVATAccountNo);
        MarginBalanceBefore := LibraryRSRetailLoc.GetGLAccountBalance(LocationMarginAccountNo);

        // [WHEN] Cost adjustment runs, which it now does for the non-retail in-transit legs
        LibraryRSRetailLoc.RunAdjustCostItemEntries(Item."No.");

        // [THEN] Cost adjustment demonstrably reached the in-transit legs. Without this the balance
        // assertions below would pass for the trivial reason that adjustment had no work to do, which
        // is precisely the scenario under test.
        _Assert.IsTrue(LibraryRSRetailLoc.CountAdjustmentValueEntriesAtLocation(ShipmentNo, InTransitLocation.Code) +
                      LibraryRSRetailLoc.CountAdjustmentValueEntriesAtLocation(ReceiptNo, InTransitLocation.Code) > 0,
                      'Cost adjustment must have reached the in-transit legs, otherwise this test proves nothing.');

        // [THEN] The transit correction stands and neither the retail nor the transit accounts move
        LibraryRSRetailLoc.AssertGLAccountBalance(LibraryRSRetailLoc.RetailInvAcc(InTransitLocation.Code), TransitInventoryBalanceBefore, 'The in-transit inventory account must not be re-inflated by cost adjustment.');
        LibraryRSRetailLoc.AssertGLAccountBalance(LibraryRSRetailLoc.RetailInvAcc(RetailLocation.Code), RetailInventoryBalanceBefore, '134 must be unchanged by cost adjustment.');
        LibraryRSRetailLoc.AssertGLAccountBalance(LocationVATAccountNo, VATBalanceBefore, 'ukalkulisani PDV must be unchanged by cost adjustment.');
        LibraryRSRetailLoc.AssertGLAccountBalance(LocationMarginAccountNo, MarginBalanceBefore, 'RUC must be unchanged by cost adjustment.');
    end;

    [Test]
    procedure SoldOutItem_UnitCostStaysAcquisitionCost()
    var
        Item: Record Item;
        Location: Record Location;
        LibraryRSRetailLoc: Codeunit "NPR Library - RS Retail Loc.";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] An item sold down to zero inventory must keep the acquisition cost as its Unit
        // Cost. At zero quantity BC falls back to CalcLastAdjEntryAvgCost, which is the one path the
        // OnAfterSetFilters exclusion only half covers: it does call SetFilters, so the filter decides
        // which value entries get ITERATED, but the cost it then reads is Item Ledger Entry."Cost
        // Amount (Actual)" - a flowfield summing every value entry on that entry, synthesised ones
        // included. So the markup can only stay out of Unit Cost because the Standard and COGS
        // Correction entries net it back off the ledger entry, not because the filter hid it.

        // [GIVEN] RS localization active, retail location, item bought at 750 and sold at 1200 incl VAT
        LibraryRSRetailLoc.InitializeSetup();
        LibraryRSRetailLoc.CreateRetailLocation(Location);
        LibraryRSRetailLoc.CreateRetailItem(Item, 600, 1200, false, Location.Code);
        LibraryRSRetailLoc.PostRetailPurchaseInvoice(Item."No.", Location.Code, 10, 750);

        // [WHEN] Selling the whole quantity, leaving zero inventory, and adjusting cost
        PostedDocumentNo := LibraryRSRetailLoc.PostRetailSalesInvoice(Item."No.", Location.Code, 10, 1200);
        LibraryRSRetailLoc.RunAdjustCostItemEntries(Item."No.");

        // [THEN] The sale's own synthesised entries were stamped - these are the RSSalesGLAddition
        // stamp sites (Retail Calculation, Standard Correction, COGS Correction). The sales suites
        // assert only G/L balances, and the stamp does not move the G/L, so nothing else covers them.
        _Assert.IsTrue(LibraryRSRetailLoc.CountRSCalcValueEntries(PostedDocumentNo, true) > 0, 'The retail sale must have produced marked RS retail calculation entries.');

        // [THEN] Unit Cost is still the acquisition cost, not the retail selling price
        _Assert.AreEqual(750, LibraryRSRetailLoc.GetItemUnitCost(Item."No."), 'Unit Cost of a sold-out item must stay at acquisition cost.');
    end;

    [Test]
    procedure POSSale_MarkupStaysOutOfItemUnitCost()
    var
        Item: Record Item;
        POSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";
        LibraryRSRetailLoc: Codeunit "NPR Library - RS Retail Loc.";
        PaymentMethod: Code[10];
        RetailLocationCode: Code[10];
    begin
        // [SCENARIO] The POS is the highest-traffic posting path in RS retail, and it has three of the
        // sixteen stamp sites (Retail Calculation, Standard Correction, COGS Correction). The POS
        // suites assert only G/L balances, and the entry type stamp does not move the G/L - so a
        // dropped stamp there would be invisible while silently corrupting the item's Unit Cost.

        // [GIVEN] RS-active retail POS, item created with Unit Cost 600 and a retail price of 1200
        // incl VAT, bought in at a different cost of 750 so Unit Cost has somewhere to move
        LibraryRSRetailLoc.InitializeSetup();
        LibraryRSRetailLoc.SetupRetailPOS(POSUnit, POSStore, PaymentMethod, RetailLocationCode);
        LibraryRSRetailLoc.CreateRetailItemForPOS(Item, 600, 1200, POSUnit, POSStore, RetailLocationCode);
        LibraryRSRetailLoc.PostRetailPurchaseInvoice(Item."No.", RetailLocationCode, 10, 750);

        // [WHEN] Selling all 10 pcs on the POS at retail and adjusting cost
        LibraryRSRetailLoc.SellRetailPOSItemAndPost(POSUnit, PaymentMethod, Item."No.", 10, 12000, 0);
        LibraryRSRetailLoc.RunAdjustCostItemEntries(Item."No.");

        // [THEN] The POS sale produced marked entries, and the retail markup stayed out of Unit Cost
        _Assert.IsTrue(LibraryRSRetailLoc.CountRSCalcValueEntriesForItem(Item."No.", true) > 0, 'The POS sale must have produced marked RS retail calculation entries.');
        _Assert.AreEqual(750, LibraryRSRetailLoc.GetItemUnitCost(Item."No."), 'The POS retail markup must not inflate Item Unit Cost.');
    end;
}
