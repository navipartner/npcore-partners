codeunit 85462 "NPR RS Retail Counting Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;

    [Test]
    procedure PositiveCountAdjustment_EstablishesRetailWithVATAndRUCSplit()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Retail: Record Location;
        CountNo: Code[20];
    begin
        // [SCENARIO] COM-1220: a counted surplus (visak) at a retail location must establish 134 at the full
        // retail price and credit the ukalkulisani PDV and RUC contra-accounts - not post at cost only.
        // Per the RS chart of accounts, 134 = acquisition cost + 1349 (RUC) + 1344 (PDV), so a count that
        // moves only the cost portion breaks that identity permanently: retail locations are excluded from
        // Adjust Cost - Item Entries, so no later batch job repairs it.
        // [GIVEN] Retail stock (cost 600 / retail 1200 incl 20% VAT), 10 pcs on hand
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 10, 600);

        // [WHEN] A count finds 12 pcs against a calculated 10, i.e. a surplus of 2
        CountNo := Lib.PostRetailCountAdjustment(Item."No.", Retail.Code, 10, 12);

        // [THEN] Markup leg (1200-600)*2 = 1200 debits 134; PDV = 1200*2*20/120 = 400; RUC = 1200-400 = 800
        Lib.AssertCalcGL(CountNo, Lib.RetailInvAcc(Retail.Code), Lib.GlobalVATAcc(), Lib.GlobalMarginAcc(), 1200, 400, 800);

        // [THEN] Together with the standard cost leg, 134 carries the surplus at full retail: 2 * 1200 = 2400
        Lib.AssertGLNetChange(CountNo, Lib.RetailInvAcc(Retail.Code), 2400, 'Counted surplus established on 134 at full retail');
        Lib.AssertDocGLBalanced(CountNo);
    end;

    [Test]
    procedure NegativeCountAdjustment_RelievesRetailAndReversesMarkup()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Retail: Record Location;
        CountNo: Code[20];
    begin
        // [SCENARIO] COM-1220: a counted shortage (manjak) must relieve 134 at the full retail price and
        // debit back the ukalkulisani PDV and RUC that were established when the goods were received.
        // [GIVEN] Retail stock (cost 600 / retail 1200 incl 20% VAT), 10 pcs on hand
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 10, 600);

        // [WHEN] A count finds 8 pcs against a calculated 10, i.e. a shortage of 2
        CountNo := Lib.PostRetailCountAdjustment(Item."No.", Retail.Code, 10, 8);

        // [THEN] Razduzenje: 134 relieved at full retail 2 * 1200 = 2400; PDV and RUC reversed (debit)
        Lib.AssertGLNetChange(CountNo, Lib.RetailInvAcc(Retail.Code), -2400, 'Counted shortage relieved from 134 at full retail');
        Lib.AssertGLNetChange(CountNo, Lib.GlobalVATAcc(), 400, 'ukalkulisani PDV reversed (debit) on the shortage');
        Lib.AssertGLNetChange(CountNo, Lib.GlobalMarginAcc(), 800, 'RUC reversed (debit) on the shortage');
        Lib.AssertDocGLBalanced(CountNo);
    end;

    [Test]
    procedure POSAdjustInventoryPath_GetsTheSameVATAndRUCSplit()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Retail: Record Location;
        CountNo: Code[20];
    begin
        // [SCENARIO] COM-1220: the POS "Adjust Inventory" action posts straight through Item Jnl.-Post
        // Line instead of Item Jnl.-Post Batch, so it must get the same treatment as a journal count.
        // This is the path a store employee uses to correct stock at the till, and it is easy to miss -
        // a subscriber placed on the batch codeunit would never fire for it.
        // [GIVEN] Retail stock (cost 600 / retail 1200 incl 20% VAT), 10 pcs on hand
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 10, 600);

        // [WHEN] Adjusting inventory up by 2 pcs without a journal batch
        CountNo := Lib.PostRetailCountAdjustmentDirect(Item."No.", Retail.Code, 10, 12);

        // [THEN] Same split as the journal path: markup 1200 on 134, PDV 400, RUC 800
        Lib.AssertCalcGL(CountNo, Lib.RetailInvAcc(Retail.Code), Lib.GlobalVATAcc(), Lib.GlobalMarginAcc(), 1200, 400, 800);
        Lib.AssertDocGLBalanced(CountNo);
    end;

    [Test]
    procedure MultiLineCount_ValuesEveryLineAtItsOwnRetailPrice()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        ItemA: Record Item;
        ItemB: Record Item;
        Retail: Record Location;
        CountNo: Code[20];
    begin
        // [SCENARIO] COM-1220: a real count posts one line per item under a single document no. Each
        // line must be valued at its OWN retail price. Posting logic that locates its work by document
        // no. alone can attach one line's amounts to another line's entries, so two items with
        // deliberately different prices are the case that catches it.
        // [GIVEN] Two retail items on hand, 10 pcs each: A cost 600 / retail 1200, B cost 300 / retail 500
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(ItemA, 600, 1200, false, Retail.Code);
        Lib.CreateRetailItem(ItemB, 300, 500, false, Retail.Code);
        Lib.PostRetailPurchaseInvoice(ItemA."No.", Retail.Code, 10, 600);
        Lib.PostRetailPurchaseInvoice(ItemB."No.", Retail.Code, 10, 300);

        // [WHEN] One count finds a surplus of 2 pcs of A and a shortage of 2 pcs of B
        CountNo := Lib.PostRetailCountAdjustmentTwoItems(ItemA."No.", ItemB."No.", Retail.Code, 10, 12, 8);

        // [THEN] A surplus: +2*1200 = +2400 on 134. B shortage: -2*500 = -1000. Net on 134 = +1400
        Lib.AssertGLNetChange(CountNo, Lib.RetailInvAcc(Retail.Code), 1400, '134 net of the A surplus at 1200 and the B shortage at 500');

        // [THEN] PDV: A credits 1200*2*20/120 = 400, B debits 500*2*20/120 = 166.67 -> net credit 233.33
        Lib.AssertGLNetChange(CountNo, Lib.GlobalVATAcc(), -233.33, 'ukalkulisani PDV net of both lines');

        // [THEN] RUC: A credits 1200-400 = 800, B debits 400-166.67 = 233.33 -> net credit 566.67
        Lib.AssertGLNetChange(CountNo, Lib.GlobalMarginAcc(), -566.67, 'RUC net of both lines');
        Lib.AssertDocGLBalanced(CountNo);
    end;

    [Test]
    procedure JournalCount_RegistersCOGSCorrectionMapping()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Retail: Record Location;
        CountNo: Code[20];
    begin
        // [SCENARIO] Baseline for the POS path below, and the guard against double-insertion.
        // On the journal path the mapping is NOT this feature's doing: the pre-existing subscriber in
        // RSRetailCostAdjustment (Item Jnl.-Post Batch::OnPostLinesOnAfterPostLine) already inserts one per
        // retail-location line, and it fires per line before OnAfterPostLines. Measured by disabling
        // EnsureCOGSCorrectionMapping: this test still passed while the POS test below went red, so an
        // "at least one" assertion here proves nothing about the new code.
        // What this test does pin is that the new code adds no SECOND row.
        // InsertCOGSCorrectionValueEntryMappingEntry does a plain Insert(), so if the Get guard in
        // EnsureCOGSCorrectionMapping were dropped, every journal count would fail on a duplicate primary
        // key. Hence exactly one, not "at least one".
        // [GIVEN] Retail stock (cost 600 / retail 1200 incl 20% VAT), 10 pcs on hand
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 10, 600);

        // [WHEN] A count finds a surplus of 2 pcs
        CountNo := Lib.PostRetailCountAdjustment(Item."No.", Retail.Code, 10, 12);

        // [THEN] Exactly one mapping - the pre-existing one, not duplicated by the new code
        _Assert.AreEqual(1, Lib.CountCOGSCorrectionMappings(Item."No.", CountNo), 'A journal count must end with exactly one COGS-correction mapping: the new code must not add a second alongside the one RSRetailCostAdjustment already inserted.');
    end;

    [Test]
    procedure POSAdjustInventoryPath_RegistersCOGSCorrectionMappingLikeJournal()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Retail: Record Location;
        CountNo: Code[20];
    begin
        // [SCENARIO] The POS action posts through Item Jnl.-Post Line with no batch, so the batch-level
        // subscriber that registers the COGS-correction mapping never fires for it. Without that row a
        // later POS sale of the counted-in units finds no mapping, falls through to the unmapped path and
        // posts no COGS correction - while the identical quantity counted in through a journal does.
        // [GIVEN] Retail stock (cost 600 / retail 1200 incl 20% VAT), 10 pcs on hand
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 10, 600);

        // [WHEN] Adjusting inventory up by 2 pcs through the POS action
        CountNo := Lib.PostRetailCountAdjustmentDirect(Item."No.", Retail.Code, 10, 12);

        // [THEN] It is registered for COGS correction exactly as the journal path registers it
        _Assert.IsTrue(Lib.CountCOGSCorrectionMappings(Item."No.", CountNo) > 0, 'The POS adjust-inventory path must register a COGS-correction mapping, as a journal count does.');
    end;

    [Test]
    procedure CountCalculationEntries_BelongToAGLRegister()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Retail: Record Location;
        CountNo: Code[20];
    begin
        // [SCENARIO] The markup, PDV and RUC legs are statutory entries, so they have to sit inside a G/L
        // Register like every other posting. Entries outside every register are invisible in General Ledger
        // Registers, unreachable from register Navigate and skipped by Reverse Register. Every sibling
        // calculation path closes by registering its entries, and the host posting cannot do it for us -
        // the shared poster writes the entry by hand, after the Item Register is closed. Note the order on
        // the G/L side: our legs are written first, during OnAfterPostLines, and the automatic cost posting
        // adds its own entries and its own G/L Register afterwards. So the document-no. sweep that builds
        // our register sees only our own legs, and the two registers do not overlap.
        // [GIVEN] Retail stock (cost 600 / retail 1200 incl 20% VAT), 10 pcs on hand
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 10, 600);

        // [WHEN] A count finds a surplus of 2 pcs
        CountNo := Lib.PostRetailCountAdjustment(Item."No.", Retail.Code, 10, 12);

        // [THEN] The count actually posted its calculation legs. This has to be asserted first:
        // CountGLEntriesOutsideAnyRegister returns 0 for a document with no G/L entries at all, so on its
        // own the assertion below passes under exactly the regression this test exists to catch - the legs
        // never being produced.
        _Assert.AreNotEqual(0, Lib.GetRSCalcNetChange(Lib.GlobalMarginAcc(), CountNo), 'The count must have posted its RS calculation legs for the register assertion to mean anything.');

        // [THEN] Every G/L entry the count produced is covered by a register
        _Assert.AreEqual(0, Lib.CountGLEntriesOutsideAnyRegister(CountNo), 'Every G/L entry of a count must belong to a G/L Register.');
    end;

    [Test]
    procedure MultiLineCountCalculationEntries_BelongToAGLRegister()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        ItemA: Record Item;
        ItemB: Record Item;
        Retail: Record Location;
        CountNo: Code[20];
    begin
        // [SCENARIO] A real count is multi-line, and the register must cover every line's legs - not one
        // register per line, and not only the first line.
        // [GIVEN] Two retail items on hand, 10 pcs each, at different retail prices
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(ItemA, 600, 1200, false, Retail.Code);
        Lib.CreateRetailItem(ItemB, 300, 500, false, Retail.Code);
        Lib.PostRetailPurchaseInvoice(ItemA."No.", Retail.Code, 10, 600);
        Lib.PostRetailPurchaseInvoice(ItemB."No.", Retail.Code, 10, 300);

        // [WHEN] One count finds a surplus of 2 pcs of A and a shortage of 2 pcs of B
        CountNo := Lib.PostRetailCountAdjustmentTwoItems(ItemA."No.", ItemB."No.", Retail.Code, 10, 12, 8);

        // [THEN] The count actually posted its calculation legs - without this the register assertion
        // below is satisfied by an empty result set. Net RUC over both lines is 800 - 233.33 credited.
        _Assert.AreNotEqual(0, Lib.GetRSCalcNetChange(Lib.GlobalMarginAcc(), CountNo), 'The multi-line count must have posted its RS calculation legs for the register assertion to mean anything.');

        // [THEN] Every G/L entry of the count is covered by a register
        _Assert.AreEqual(0, Lib.CountGLEntriesOutsideAnyRegister(CountNo), 'Every G/L entry of a multi-line count must belong to a G/L Register.');
    end;
}
