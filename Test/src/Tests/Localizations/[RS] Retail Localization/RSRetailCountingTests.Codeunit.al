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

        // [THEN] A surplus and a shortage under one document, same location and posting group, land on
        // their own accounts rather than being netted together: A's cost 2*600 to the surplus account,
        // B's cost 2*300 to the shortage account.
        Lib.AssertGLNetChange(CountNo, Lib.GlobalSurplusAcc(), -1200, 'The surplus line must reach the surplus account');
        Lib.AssertGLNetChange(CountNo, Lib.GlobalShortageAcc(), 600, 'The shortage line must reach the shortage account');
        Lib.AssertDocGLBalanced(CountNo);
    end;

    [Test]
    procedure CountedSurplus_PostsCounterpartToSurplusAccount()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Retail: Record Location;
        CountNo: Code[20];
    begin
        // [SCENARIO] Serbian law puts a counted surplus on 674 (viskovi, income) and a shortage on 574
        // (manjkovi, expense) - different accounts in different parts of the P&L. Business Central posts
        // the cost leg of both directions to the Inventory Adjmt. Account of the general posting setup,
        // resolved from the gen. bus. and gen. prod. posting groups on the line. Those are editable per
        // line, so an operator can split the two by hand - but nothing in the standard app derives them
        // from the direction, item or location, so the split cannot happen automatically and can never
        // be keyed by item and location the way the RS accounts are.
        // [GIVEN] Retail stock (cost 600 / retail 1200 incl 20% VAT), 10 pcs on hand
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 10, 600);

        // [WHEN] A count finds a surplus of 2 pcs
        CountNo := Lib.PostRetailCountAdjustment(Item."No.", Retail.Code, 10, 12);

        // [THEN] The cost of the surplus, 2 * 600, is credited to the surplus account
        Lib.AssertGLNetChange(CountNo, Lib.GlobalSurplusAcc(), -1200, 'Counted surplus must land on the surplus account (674)');

        // [THEN] and the standard Inventory Adjmt. Account is left out of it entirely
        Lib.AssertGLNetChange(CountNo, Lib.InvtAdjmtAcc(), 0, 'Inventory Adjmt. Account must not carry a retail count surplus');
        Lib.AssertDocGLBalanced(CountNo);
    end;

    [Test]
    procedure CountedShortage_PostsCounterpartToShortageAccount()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Retail: Record Location;
        CountNo: Code[20];
    begin
        // [SCENARIO] The mirror of the surplus case - a shortage is an expense on 574, not income on 674,
        // so the two directions must not share an account.
        // [GIVEN] Retail stock (cost 600 / retail 1200 incl 20% VAT), 10 pcs on hand
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 10, 600);

        // [WHEN] A count finds a shortage of 2 pcs
        CountNo := Lib.PostRetailCountAdjustment(Item."No.", Retail.Code, 10, 8);

        // [THEN] The cost of the shortage, 2 * 600, is debited to the shortage account
        Lib.AssertGLNetChange(CountNo, Lib.GlobalShortageAcc(), 1200, 'Counted shortage must land on the shortage account (574)');
        Lib.AssertGLNetChange(CountNo, Lib.InvtAdjmtAcc(), 0, 'Inventory Adjmt. Account must not carry a retail count shortage');
        Lib.AssertDocGLBalanced(CountNo);
    end;

    [Test]
    procedure CountAccounts_PerLocationOverrideWinsOverGlobal()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Retail: Record Location;
        CountNo: Code[20];
        ShortageCountNo: Code[20];
        LocSurplusAcc: Code[20];
        LocShortageAcc: Code[20];
    begin
        // [SCENARIO] A chain running several stores books counts per location, so the accounts follow the
        // same override-then-global shape as the ukalkulisani PDV and RUC accounts already do.
        // [GIVEN] A retail location pointed at its own surplus and shortage accounts
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        Lib.SetLocationCountAccounts(Retail.Code, Item."No.", LocSurplusAcc, LocShortageAcc);
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 10, 600);

        // [WHEN] A count finds a surplus of 2 pcs, and a second count a shortage of 2 pcs
        CountNo := Lib.PostRetailCountAdjustment(Item."No.", Retail.Code, 10, 12);
        ShortageCountNo := Lib.PostRetailCountAdjustment(Item."No.", Retail.Code, 12, 10);

        // [THEN] The location's own accounts are used, and the global ones are left untouched. Both
        // directions are asserted: the getters are two near-identical procedures, so a shortage getter
        // reading the surplus field is the likeliest defect and a surplus-only test would not see it.
        Lib.AssertGLNetChange(CountNo, LocSurplusAcc, -1200, 'The location override must win over the global surplus account');
        Lib.AssertGLNetChange(CountNo, Lib.GlobalSurplusAcc(), 0, 'The global surplus account must not be used when the location overrides it');
        Lib.AssertGLNetChange(ShortageCountNo, LocShortageAcc, 1200, 'The location override must win over the global shortage account');
        Lib.AssertGLNetChange(ShortageCountNo, Lib.GlobalShortageAcc(), 0, 'The global shortage account must not be used when the location overrides it');
        Lib.AssertDocGLBalanced(CountNo);
        Lib.AssertDocGLBalanced(ShortageCountNo);
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

        // [THEN] Exactly one mapping - the pre-existing one, not duplicated by the new code. Scoped to the
        // count document: the purchase registers one of its own, so an item-wide count would see two.
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

    [Test]
    procedure ReasonCodeAccount_DirectsAWriteOffAwayFromTheShortageAccount()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Retail: Record Location;
        CountNo: Code[20];
        ReasonCode: Code[10];
        ReasonSurplusAcc: Code[20];
        ReasonShortageAcc: Code[20];
    begin
        // [SCENARIO] Serbian law separates a counted shortage (574 manjkovi) from wastage written off
        // within the allowed norms (577 rashodi) - different lines of the P&L. The surplus and shortage
        // accounts are keyed by location and posting group, which describe where and what, never why, so
        // the same item at the same store cannot reach two accounts through them. The reason code is
        // what carries the why, and it is already on both adjustment paths.
        // [GIVEN] Retail stock, and a write-off reason code with its own accounts
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 10, 600);
        ReasonCode := Lib.CreateCountReasonCode(true, ReasonSurplusAcc, ReasonShortageAcc);

        // [WHEN] Writing off 2 pcs under that reason
        CountNo := Lib.PostRetailCountAdjustmentWithReason(Item."No.", Retail.Code, 10, 8, ReasonCode);

        // [THEN] The cost lands on the reason's own account, and the default shortage account is untouched
        Lib.AssertGLNetChange(CountNo, ReasonShortageAcc, 1200, 'A write-off must land on the account set up for its reason code');
        Lib.AssertGLNetChange(CountNo, Lib.GlobalShortageAcc(), 0, 'The default shortage account must not carry a reason-coded write-off');
        Lib.AssertDocGLBalanced(CountNo);
    end;

    [Test]
    procedure ReasonCodeWithoutAccounts_FallsBackToTheDefaults()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Retail: Record Location;
        CountNo: Code[20];
        ReasonCode: Code[10];
        UnusedSurplusAcc: Code[20];
        UnusedShortageAcc: Code[20];
    begin
        // [SCENARIO] A reason code with no accounts of its own is the normal case - a plain count reason
        // means nothing more than "counted shortage", which is what the default account already is. It
        // must fall straight through, so adopting reason codes never becomes mandatory setup.
        // [GIVEN] Retail stock and a reason code carrying no accounts
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 10, 600);
        ReasonCode := Lib.CreateCountReasonCode(false, UnusedSurplusAcc, UnusedShortageAcc);

        // [WHEN] A shortage of 2 pcs is counted under that reason
        CountNo := Lib.PostRetailCountAdjustmentWithReason(Item."No.", Retail.Code, 10, 8, ReasonCode);

        // [THEN] It lands on the default shortage account exactly as an unreasoned count does
        Lib.AssertGLNetChange(CountNo, Lib.GlobalShortageAcc(), 1200, 'A reason code with no account of its own must fall back to the default shortage account');
        Lib.AssertDocGLBalanced(CountNo);
    end;

    [Test]
    procedure ReasonCodeAccount_WinsOverTheLocationOverride()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Retail: Record Location;
        CountNo: Code[20];
        ReasonCode: Code[10];
        ReasonSurplusAcc: Code[20];
        ReasonShortageAcc: Code[20];
        LocSurplusAcc: Code[20];
        LocShortageAcc: Code[20];
    begin
        // [SCENARIO] Both levels can be configured at once, so the order has to be deliberate. The reason
        // decides which line of the P&L the amount belongs on, while the location override only splits one
        // line for analysis - so the reason wins.
        // [GIVEN] A location with its own accounts, and a reason code with its own accounts
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        Lib.SetLocationCountAccounts(Retail.Code, Item."No.", LocSurplusAcc, LocShortageAcc);
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 10, 600);
        ReasonCode := Lib.CreateCountReasonCode(true, ReasonSurplusAcc, ReasonShortageAcc);

        // [WHEN] A shortage of 2 pcs is written off under that reason at that location
        CountNo := Lib.PostRetailCountAdjustmentWithReason(Item."No.", Retail.Code, 10, 8, ReasonCode);

        // [THEN] The reason's account is used and the location's is left untouched
        Lib.AssertGLNetChange(CountNo, ReasonShortageAcc, 1200, 'The reason code account must win over the location override');
        Lib.AssertGLNetChange(CountNo, LocShortageAcc, 0, 'The location override must not be used when the reason code sets an account');
        Lib.AssertDocGLBalanced(CountNo);
    end;

    [Test]
    procedure POSReturnReason_DirectsAWriteOffAwayFromTheShortageAccount()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Retail: Record Location;
        CountNo: Code[20];
        ReturnReasonCode: Code[10];
        ReasonSurplusAcc: Code[20];
        ReasonShortageAcc: Code[20];
    begin
        // [SCENARIO] The journal path carries its reason in "Reason Code", but the POS "Adjust Inventory"
        // action carries it in "Return Reason Code": POSActionAdjustInv looks the cashier's choice up in
        // table "Return Reason" and POSActionAdjustInvB validates it onto the item journal line, leaving
        // "Reason Code" blank. Those are two independent tables with independent code namespaces, so a
        // Return Reason has to be mapped as a Return Reason. A cashier writing off breakage at the till is
        // the ordinary way this feature gets used, so the POS path needs the routing as much as a counting
        // report does - and it is the path with no reason-code coverage at all today.
        // [GIVEN] Retail stock, and a POS write-off return reason with its own accounts
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 10, 600);
        ReturnReasonCode := Lib.CreateCountReturnReason(true, ReasonSurplusAcc, ReasonShortageAcc);

        // [WHEN] The cashier writes off 2 pcs at the POS under that return reason
        CountNo := Lib.PostRetailCountAdjustmentDirectWithReturnReason(Item."No.", Retail.Code, 10, 8, ReturnReasonCode);

        // [THEN] The cost lands on the return reason's own account, and the default shortage account is untouched
        Lib.AssertGLNetChange(CountNo, ReasonShortageAcc, 1200, 'A POS write-off must land on the account set up for its return reason');
        Lib.AssertGLNetChange(CountNo, Lib.GlobalShortageAcc(), 0, 'The default shortage account must not carry a return-reason write-off');
        Lib.AssertDocGLBalanced(CountNo);
    end;

    [Test]
    procedure AReturnReasonAndAReasonCodeSharingACode_DoNotCrossOver()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Retail: Record Location;
        CountNo: Code[20];
        SharedCode: Code[10];
        JournalShortageAcc: Code[20];
        POSShortageAcc: Code[20];
    begin
        // [SCENARIO] "Reason Code" and "Return Reason" are separate tables, so nothing stops a company
        // from having BREAKAGE in both - and a chain that writes off breakage at the till and again on the
        // counting report is exactly the company that would. The two must resolve independently. Without a
        // type on the mapping, a lookup that takes whichever code the value entry happens to carry finds
        // the other table's row and posts the write-off to the wrong account, silently and with a
        // plausible-looking result - the failure mode a fallback across two namespaces always has.
        // [GIVEN] One code value existing as both a Reason Code and a Return Reason, each mapped to its own account
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 10, 600);
        Lib.CreateCollidingCountReasons(SharedCode, JournalShortageAcc, POSShortageAcc);

        // [WHEN] 2 pcs are written off at the POS, which carries the code as a Return Reason
        CountNo := Lib.PostRetailCountAdjustmentDirectWithReturnReason(Item."No.", Retail.Code, 10, 8, SharedCode);

        // [THEN] The Return Reason's account is used and the identically coded Reason Code's is not
        Lib.AssertGLNetChange(CountNo, POSShortageAcc, 1200, 'A POS write-off must resolve against the Return Reason list');
        Lib.AssertGLNetChange(CountNo, JournalShortageAcc, 0, 'A POS write-off must not pick up the account of a Reason Code that merely shares its code');
        Lib.AssertDocGLBalanced(CountNo);
    end;

    [Test]
    procedure RenamingAReasonCode_CarriesItsAccountMappingAlong()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Retail: Record Location;
        CountNo: Code[20];
        ReasonCode: Code[10];
        RenamedTo: Code[10];
        ReasonSurplusAcc: Code[20];
        ReasonShortageAcc: Code[20];
    begin
        // [SCENARIO] Tidying up a code list is ordinary accounting housekeeping, and a mapping left behind
        // under the old code would not error - it would quietly stop applying, sending later write-offs to
        // the default shortage account. Business Central is documented to carry a rename into every table
        // that relates to the renamed one ("renaming a record changes the primary key and updates the
        // primary key value in all related tables"), and the mapping's Reason Code field does relate to
        // "Reason Code" - but it relates CONDITIONALLY, on the reason type, which is the part worth
        // pinning: if the platform ever skipped conditional relations the mapping would silently orphan.
        // Asserted by posting rather than by reading the table, so it is the routing that is proven, not
        // just a row's key.
        // [GIVEN] Retail stock and a write-off reason code with its own accounts
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 10, 600);
        ReasonCode := Lib.CreateCountReasonCode(true, ReasonSurplusAcc, ReasonShortageAcc);

        // [WHEN] The reason code is renamed, and 2 pcs are then written off under the new code
        RenamedTo := CopyStr(ReasonCode + 'R', 1, 10);
        Lib.RenameReasonCode(ReasonCode, RenamedTo);
        CountNo := Lib.PostRetailCountAdjustmentWithReason(Item."No.", Retail.Code, 10, 8, RenamedTo);

        // [THEN] The mapping followed the rename, so the write-off still reaches the reason's own account
        Lib.AssertGLNetChange(CountNo, ReasonShortageAcc, 1200, 'A renamed reason code must keep its account mapping');
        Lib.AssertGLNetChange(CountNo, Lib.GlobalShortageAcc(), 0, 'A renamed reason code must not fall back to the default shortage account');
        Lib.AssertDocGLBalanced(CountNo);
    end;

    [Test]
    procedure RSAccountFields_RejectABlockedGLAccount()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Retail: Record Location;
        ReasonCode: Code[10];
        UnusedSurplusAcc: Code[20];
        UnusedShortageAcc: Code[20];
        BlockedAcc: Code[20];
    begin
        // [SCENARIO] TableRelation = "G/L Account" on its own offers every account in the chart, blocked
        // ones included. A blocked account picked here does not fail at setup time - it fails much later,
        // inside Gen. Jnl.-Post Line, when a count is being posted, which is the worst moment to find out
        // and the hardest place to trace back to a setup page. All six RS account fields are checked in
        // one go because the likeliest defect is a field left out, and a per-field test would not say
        // which one.
        // [GIVEN] Retail stock, a reason code mapping, and a blocked G/L account
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        ReasonCode := Lib.CreateCountReasonCode(true, UnusedSurplusAcc, UnusedShortageAcc);
        BlockedAcc := Lib.CreateBlockedGLAccount();

        // [WHEN] The blocked account is offered to every RS account field
        // [THEN] Every one of them refuses it
        _Assert.AreEqual('', Lib.RSAccountFieldsAccepting(Retail.Code, Item."No.", ReasonCode, BlockedAcc), 'No RS account field may accept a blocked G/L account.');
    end;

    [Test]
    procedure RSAccountFields_RejectANonPostingGLAccount()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Retail: Record Location;
        ReasonCode: Code[10];
        UnusedSurplusAcc: Code[20];
        UnusedShortageAcc: Code[20];
        HeadingAcc: Code[20];
    begin
        // [SCENARIO] The same hole as the blocked account, but through the other door: a chart of accounts
        // contains Heading, Total, Begin-Total and End-Total rows for presentation, and a plain
        // TableRelation offers those too. They can never receive a posting at all, so choosing one is
        // always a mistake and never a preference.
        // [GIVEN] Retail stock, a reason code mapping, and a Heading account
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        ReasonCode := Lib.CreateCountReasonCode(true, UnusedSurplusAcc, UnusedShortageAcc);
        HeadingAcc := Lib.CreateHeadingGLAccount();

        // [WHEN] The heading account is offered to every RS account field
        // [THEN] Every one of them refuses it
        _Assert.AreEqual('', Lib.RSAccountFieldsAccepting(Retail.Code, Item."No.", ReasonCode, HeadingAcc), 'No RS account field may accept a non-posting G/L account.');
    end;

    [Test]
    procedure RSAccountFields_AcceptAnOrdinaryPostingAccount()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Retail: Record Location;
        ReasonCode: Code[10];
        UnusedSurplusAcc: Code[20];
        UnusedShortageAcc: Code[20];
        PlainAcc: Code[20];
    begin
        // [SCENARIO] The boundary on the two tests above: the guards must refuse what can never be posted
        // to, and nothing else. This matters more than it looks, because Business Central ships the G/L
        // account category mapping for the United States only and derives a category for every other
        // account from whichever account sits above it in the chart - so the category an account carries
        // is often inherited rather than chosen. Any guard that demanded a particular category would
        // therefore reject a customer's real 674 or 574 sooner or later and make the feature
        // unconfigurable, which is worse than the problem being fixed. An ordinary posting account must
        // pass every one of the six fields whatever category it happens to carry, so the account used
        // here deliberately carries one that none of the six asks for.
        // [GIVEN] Retail stock, a reason code mapping, and an ordinary posting account
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        ReasonCode := Lib.CreateCountReasonCode(true, UnusedSurplusAcc, UnusedShortageAcc);
        PlainAcc := Lib.CreatePlainPostingGLAccount();

        // [WHEN] It is offered to every RS account field
        // [THEN] None of them refuses it
        _Assert.AreEqual('', Lib.RSAccountFieldsRejecting(Retail.Code, Item."No.", ReasonCode, PlainAcc), 'Every RS account field must accept an ordinary posting account. Its account category was: ' + Lib.GLAccountCategoryOf(PlainAcc));
    end;

    [Test]
    procedure PerPostingGroupPosting_IsBlockedAtARetailLocation()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        Retail: Record Location;
        CountNo: Code[20];
    begin
        // [SCENARIO] The per-posting-group method summarises a location's cost into one buffer row with no
        // item behind it, so the surplus and shortage accounts - resolved per item and location - cannot be
        // derived. The code refuses that method rather than post to the wrong account. This is the branch
        // that stops a customer operation outright, and it is also what the standard
        // "Post Inventory Cost to G/L" report does at its default Posting Method, so it must be pinned:
        // an inverted guard or a wrong Account Type test would otherwise ship green.
        // [GIVEN] Retail stock counted while Automatic Cost Posting is off, so the cost is still unposted
        Lib.InitializeSetup();
        Lib.SetAutomaticCostPosting(false);
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 10, 600);
        CountNo := Lib.PostRetailCountAdjustment(Item."No.", Retail.Code, 10, 8);

        // [WHEN] The deferred cost posting runs per posting group
        asserterror Lib.PostInventoryCostPerPostingGroup(Item."No.", CountNo);

        // [THEN] It is refused, and on the posting method rather than on something incidental
        _Assert.ExpectedError('per posting group');

        Lib.SetAutomaticCostPosting(true);
    end;
}
