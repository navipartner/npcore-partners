codeunit 85486 "NPR RS Retail Sales Rpt Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _LibraryReportDataset: Codeunit "Library - Report Dataset";
        _ReportTestLib: Codeunit "NPR Retail Report Test Lib";
        _ItemNoFilter: Text;
        _VendorNoFilter: Text;
        _StatsFor: Text;
        _ItemCategoryFilter: Text;
        _ExpectedMessage: Text;
        _MessagesHandled: Integer;

    [Test]
    procedure RSActive_SalesReportsAreSubstitutedWithRSVersions()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
    begin
        // [SCENARIO] With RS retail localization enabled, the generic sales statistics reports run their RS versions
        // [GIVEN] RS retail localization is enabled
        Lib.InitializeSetup();

        // [THEN] Each generic report resolves to its RS substitute
        _Assert.AreEqual(Report::"NPR RS Sales Stats Per Variety", Report.GetSubstituteReportId(Report::"NPR Sales Stats Per Variety"), 'Sales Stats Per Variety must run the RS version');
        _Assert.AreEqual(Report::"NPR RS Advanced Sales Stat.", Report.GetSubstituteReportId(Report::"NPR Advanced Sales Stat."), 'Advanced Sales Stat. must run the RS version');
        _Assert.AreEqual(Report::"NPR RS Retail Sales Statistics", Report.GetSubstituteReportId(Report::"NPR Sales Stat/Analysis"), 'Sales Stat/Analysis must run the RS version');
    end;

    [Test]
    procedure RSInactive_SalesReportsAreNotSubstituted()
    var
        RSSetup: Record "NPR RS R Localization Setup";
        Lib: Codeunit "NPR Library - RS Retail Loc.";
    begin
        // [SCENARIO] Without RS retail localization the generic sales statistics reports run unchanged
        // [GIVEN] RS retail localization is disabled
        Lib.InitializeSetup();
        RSSetup.Get();
        RSSetup."Enable RS Retail Localization" := false;
        RSSetup.Modify();

        // [THEN] No substitution happens
        _Assert.AreEqual(Report::"NPR Sales Stats Per Variety", Report.GetSubstituteReportId(Report::"NPR Sales Stats Per Variety"), 'Sales Stats Per Variety must not be substituted');
        _Assert.AreEqual(Report::"NPR Advanced Sales Stat.", Report.GetSubstituteReportId(Report::"NPR Advanced Sales Stat."), 'Advanced Sales Stat. must not be substituted');
        _Assert.AreEqual(Report::"NPR Sales Stat/Analysis", Report.GetSubstituteReportId(Report::"NPR Sales Stat/Analysis"), 'Sales Stat/Analysis must not be substituted');
    end;

    [Test]
    [HandlerFunctions('RSAdvancedSalesStatRequestPageHandler,POSMessageHandler')]
    procedure AdvancedSalesStat_POSSaleWithDiscount_ShowsNetSalesAndPostedCOGS()
    var
        Item: Record Item;
        POSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        PaymentMethod: Code[10];
        RetailLoc: Code[10];
        NivelationPostedMsg: Label 'Successfully posted a Nivelation Document', Locked = true;
    begin
        // [SCENARIO] A discounted POS sale posts RS calculation and nivelation entries; the report must show only net sales and the posted COGS
        // [GIVEN] Retail POS, item cost 600 / retail 1200 incl 20% VAT, 10 pcs in stock
        Lib.InitializeSetup();
        Lib.SetupRetailPOS(POSUnit, POSStore, PaymentMethod, RetailLoc);
        Lib.CreateRetailItemForPOS(Item, 600, 1200, POSUnit, POSStore, RetailLoc);
        Lib.PostRetailPurchaseInvoice(Item."No.", RetailLoc, 10, 600);

        // [GIVEN] 3 pcs sold on the POS with a 10% line discount (1080 incl VAT each), which also posts a nivelation
        _ExpectedMessage := NivelationPostedMsg;
        _MessagesHandled := 0;
        Lib.SellRetailPOSItemAndPost(POSUnit, PaymentMethod, Item."No.", 3, 3240, 10);

        // [WHEN] Running the generic Advanced Sales Stat. report per item (substituted by the RS version)
        _StatsFor := 'Item';
        _ItemNoFilter := Item."No.";
        _ReportTestLib.RunReportAndLoad(Report::"NPR Advanced Sales Stat.", _LibraryReportDataset);

        // [THEN] Sales = 3 * 1080 / 1.2 = 2700 excl VAT, cost = 3 * 600 = 1800, so profit = 900; quantity 3
        _Assert.IsTrue(_ReportTestLib.MoveToRowWithValue(_LibraryReportDataset, 'No_Buffer', Item."No."), 'Item row must be printed');
        _Assert.AreNearlyEqual(3, _ReportTestLib.RowDecimal(_LibraryReportDataset, 'Sales_Qty_Buffer'), 0.001, 'Sales quantity');
        _Assert.AreNearlyEqual(2700, _ReportTestLib.RowDecimal(_LibraryReportDataset, 'Sales_LCY_Buffer'), 0.01, 'Sales must be net of VAT and exclude RS calculation entries');
        _Assert.AreNearlyEqual(900, _ReportTestLib.RowDecimal(_LibraryReportDataset, 'Profit_LCY_Buffer'), 0.01, 'Profit must use the posted COGS, not RS retail or nivelation amounts');
        _Assert.AreEqual(1, _MessagesHandled, 'Only the nivelation posting confirmation is expected');
    end;

    [Test]
    [HandlerFunctions('RSSalesStatsPerVarietyRequestPageHandler')]
    procedure SalesStatsPerVariety_InvoiceAndCreditMemo_ShowsNetSalesAndPostedCOGS()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        Retail: Record Location;
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        LibraryInventory: Codeunit "Library - Inventory";
    begin
        // [SCENARIO] RS calculation entries on a variant's sale and return must not reach the variety report
        // [GIVEN] Retail item variant cost 600 / retail 1200 incl 20% VAT, 10 pcs in stock
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        LibraryInventory.CreateItemVariant(ItemVariant, Item."No.");
        Lib.SetDocumentVariantCode(ItemVariant.Code);
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 10, 600);

        // [GIVEN] 5 pcs invoiced and 2 pcs returned by credit memo at retail 1200 incl VAT
        Lib.PostRetailSalesInvoice(Item."No.", Retail.Code, 5, 1200);
        Lib.PostRetailSalesCreditMemo(Item."No.", Retail.Code, 2, 1200);
        Lib.SetDocumentVariantCode('');

        // [WHEN] Running the generic Sales Stats Per Variety report (substituted by the RS version)
        _ItemNoFilter := Item."No.";
        _ReportTestLib.RunReportAndLoad(Report::"NPR Sales Stats Per Variety", _LibraryReportDataset);

        // [THEN] Net 3 pcs: sales 3 * 1000 = 3000, COGS -3 * 600 = -1800, profit 1200
        _Assert.IsTrue(_ReportTestLib.MoveToRowWithValue(_LibraryReportDataset, 'Code_ItemVariant', ItemVariant.Code), 'Variant row must be printed');
        _Assert.AreNearlyEqual(3, _ReportTestLib.RowDecimal(_LibraryReportDataset, 'SalesQty'), 0.001, 'Sales quantity');
        _Assert.AreNearlyEqual(3000, _ReportTestLib.RowDecimal(_LibraryReportDataset, 'SalesAmount'), 0.01, 'Sales must be net of VAT and exclude RS calculation entries');
        _Assert.AreNearlyEqual(-1800, _ReportTestLib.RowDecimal(_LibraryReportDataset, 'COGSAmount'), 0.01, 'COGS must be the posted COGS, not RS retail amounts');
        _Assert.AreNearlyEqual(1200, _ReportTestLib.RowDecimal(_LibraryReportDataset, 'ItemProfit'), 0.01, 'Profit');
    end;

    [Test]
    [HandlerFunctions('RSRetailSalesStatisticsRequestPageHandler')]
    procedure RetailSalesStatistics_InvoiceAndCreditMemo_DeductsReturnedQuantity()
    var
        Item: Record Item;
        ItemCategory: Record "Item Category";
        Retail: Record Location;
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        LibraryInventory: Codeunit "Library - Inventory";
    begin
        // [SCENARIO] A credit memo return must reduce the sold quantity, and sales/COGS must be the BC figures
        // [GIVEN] Categorized retail item cost 600 / retail 1200 incl 20% VAT, 10 pcs in stock
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        LibraryInventory.CreateItemCategory(ItemCategory);
        Item.Validate("Item Category Code", ItemCategory.Code);
        Item.Modify(true);
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 10, 600);

        // [GIVEN] 5 pcs invoiced and 2 pcs returned by credit memo at retail 1200 incl VAT
        Lib.PostRetailSalesInvoice(Item."No.", Retail.Code, 5, 1200);
        Lib.PostRetailSalesCreditMemo(Item."No.", Retail.Code, 2, 1200);

        // [WHEN] Running the generic Sales Stat/Analysis report for the item's category (substituted by the RS version)
        _ItemCategoryFilter := ItemCategory.Code;
        _ReportTestLib.RunReportAndLoad(Report::"NPR Sales Stat/Analysis", _LibraryReportDataset);

        // [THEN] Net 3 pcs: sales 3000 excl VAT, COGS 1800, profit 1200, 7 pcs left in stock
        _Assert.IsTrue(_ReportTestLib.MoveToRowWithValue(_LibraryReportDataset, 'Item_No', Item."No."), 'Item row must be printed');
        _Assert.AreNearlyEqual(3, _ReportTestLib.RowDecimal(_LibraryReportDataset, 'Item_SalesQty'), 0.001, 'Returned quantity must be deducted from sales quantity');
        _Assert.AreNearlyEqual(3000, _ReportTestLib.RowDecimal(_LibraryReportDataset, 'Item_SalesLCY'), 0.01, 'Sales excl VAT');
        _Assert.AreNearlyEqual(1800, _ReportTestLib.RowDecimal(_LibraryReportDataset, 'Item_COGSLCY'), 0.01, 'COGS as posted');
        _Assert.AreNearlyEqual(1200, _ReportTestLib.RowDecimal(_LibraryReportDataset, 'Item_Profit'), 0.01, 'Profit');
        _Assert.AreNearlyEqual(7, _ReportTestLib.RowDecimal(_LibraryReportDataset, 'Item_InventoryQty'), 0.001, 'Inventory');
    end;

    [Test]
    [HandlerFunctions('RSRetailSalesStatisticsRequestPageHandler')]
    procedure RetailSalesStatistics_UncategorizedItem_ShowsItsOwnFigures()
    var
        Item: Record Item;
        ItemCategory: Record "Item Category";
        Retail: Record Location;
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        LibraryInventory: Codeunit "Library - Inventory";
        ReportXml: XmlDocument;
    begin
        // [SCENARIO] Items without a category are printed with their own figures, not those of the last categorized item
        // [GIVEN] Retail item without a category, cost 600 / retail 1200 incl 20% VAT, 10 pcs in stock, 4 pcs invoiced
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        Item.Validate("Item Category Code", '');
        Item.Modify(true);
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 10, 600);
        Lib.PostRetailSalesInvoice(Item."No.", Retail.Code, 4, 1200);

        // [WHEN] Running the generic Sales Stat/Analysis report (substituted by the RS version), limiting the categorized section to an empty category
        LibraryInventory.CreateItemCategory(ItemCategory);
        _ItemCategoryFilter := ItemCategory.Code;
        LoadReportXml(Report::"NPR Sales Stat/Analysis", ReportXml);

        // [THEN] 4 pcs: sales 4000 excl VAT, COGS 2400, profit 1600, 6 pcs left in stock
        _Assert.AreNearlyEqual(4, Item2Column(ReportXml, Item."No.", 'Item2_SalesQty'), 0.001, 'Sales quantity');
        _Assert.AreNearlyEqual(4000, Item2Column(ReportXml, Item."No.", 'Item2_SalesLCY'), 0.01, 'Sales excl VAT');
        _Assert.AreNearlyEqual(2400, Item2Column(ReportXml, Item."No.", 'Item2_COGSLCY'), 0.01, 'COGS as posted');
        _Assert.AreNearlyEqual(1600, Item2Column(ReportXml, Item."No.", 'Item2_Profit'), 0.01, 'Profit');
        _Assert.AreNearlyEqual(6, Item2Column(ReportXml, Item."No.", 'Item2_InventoryQty'), 0.001, 'Inventory');
    end;

    [Test]
    [HandlerFunctions('RSAdvancedSalesStatRequestPageHandler')]
    procedure AdvancedSalesStat_StatsPerVendor_CountsEachSoldUnitOnce()
    var
        Item: Record Item;
        POSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        LibraryPurchase: Codeunit "Library - Purchase";
        PaymentMethod: Code[10];
        RetailLoc: Code[10];
    begin
        // [SCENARIO] Statistics per vendor must count each sold unit once, although RS adds correction and calculation value entries to every sale
        // [GIVEN] Retail POS item of a vendor, cost 600 / retail 1200 incl 20% VAT, 10 pcs in stock
        Lib.InitializeSetup();
        Lib.SetupRetailPOS(POSUnit, POSStore, PaymentMethod, RetailLoc);
        Lib.CreateRetailItemForPOS(Item, 600, 1200, POSUnit, POSStore, RetailLoc);
        Item.Validate("Vendor No.", LibraryPurchase.CreateVendorNo());
        Item.Modify(true);
        Lib.PostRetailPurchaseInvoice(Item."No.", RetailLoc, 10, 600);

        // [GIVEN] 3 pcs sold on the POS at retail 1200 incl VAT
        Lib.SellRetailPOSItemAndPost(POSUnit, PaymentMethod, Item."No.", 3, 3600, 0);

        // [WHEN] Running the generic Advanced Sales Stat. report per vendor (substituted by the RS version)
        _StatsFor := 'Vendor';
        _ItemNoFilter := Item."No.";
        _VendorNoFilter := Item."Vendor No.";
        _ReportTestLib.RunReportAndLoad(Report::"NPR Advanced Sales Stat.", _LibraryReportDataset);

        // [THEN] Quantity 3 (not multiplied by the RS value entries), sales 3000 excl VAT, profit 1200
        _Assert.IsTrue(_ReportTestLib.MoveToRowWithValue(_LibraryReportDataset, 'No_Buffer', Item."Vendor No."), 'Vendor row must be printed');
        _Assert.AreNearlyEqual(3, _ReportTestLib.RowDecimal(_LibraryReportDataset, 'Sales_Qty_Buffer'), 0.001, 'Each sold unit must be counted once');
        _Assert.AreNearlyEqual(3000, _ReportTestLib.RowDecimal(_LibraryReportDataset, 'Sales_LCY_Buffer'), 0.01, 'Sales excl VAT');
        _Assert.AreNearlyEqual(1200, _ReportTestLib.RowDecimal(_LibraryReportDataset, 'Profit_LCY_Buffer'), 0.01, 'Profit');
    end;

    [Test]
    [HandlerFunctions('RSRetailSalesStatisticsRequestPageHandler,RSAdvancedSalesStatRequestPageHandler')]
    procedure AverageCostItem_ReportCOGSMatchesPostedCOGS()
    var
        GeneralPostingSetup: Record "General Posting Setup";
        Item: Record Item;
        ItemCategory: Record "Item Category";
        Retail: Record Location;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        LibraryInventory: Codeunit "Library - Inventory";
        PostedCOGS: Decimal;
        PostedNo: Code[20];
    begin
        // [SCENARIO] COGS in the reports is the COGS posted to the G/L, not BC's average cost that RS reverses at retail locations
        // [GIVEN] Categorized retail item with Average costing, retail 1200 incl 20% VAT
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(Retail);
        Lib.CreateRetailItem(Item, 600, 1200, false, Retail.Code);
        LibraryInventory.CreateItemCategory(ItemCategory);
        Item.Validate("Item Category Code", ItemCategory.Code);
        Item.Validate("Costing Method", Item."Costing Method"::Average);
        Item.Modify(true);

        // [GIVEN] Two purchase layers, 5 pcs @ 600 and 5 pcs @ 700 (BC average cost 650)
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 5, 600);
        Lib.PostRetailPurchaseInvoice(Item."No.", Retail.Code, 5, 700);

        // [GIVEN] 3 pcs invoiced at retail 1200 incl VAT; RS books COGS from the first layer (3 * 600 = 1800)
        PostedNo := Lib.PostRetailSalesInvoice(Item."No.", Retail.Code, 3, 1200);
        SalesInvoiceHeader.Get(PostedNo);
        GeneralPostingSetup.Get(SalesInvoiceHeader."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group");
        PostedCOGS := Lib.GetGLNetChange(GeneralPostingSetup."COGS Account", PostedNo);
        _Assert.AreNearlyEqual(1800, PostedCOGS, 0.01, 'RS must post the first purchase layer as COGS');

        // [WHEN] Running the generic Sales Stat/Analysis report (substituted by the RS version)
        _ItemCategoryFilter := ItemCategory.Code;
        _ReportTestLib.RunReportAndLoad(Report::"NPR Sales Stat/Analysis", _LibraryReportDataset);

        // [THEN] Its COGS equals the posted COGS
        _Assert.IsTrue(_ReportTestLib.MoveToRowWithValue(_LibraryReportDataset, 'Item_No', Item."No."), 'Item row must be printed');
        _Assert.AreNearlyEqual(PostedCOGS, _ReportTestLib.RowDecimal(_LibraryReportDataset, 'Item_COGSLCY'), 0.01, 'Sales Stat/Analysis COGS must equal the posted COGS');

        // [WHEN] Running the generic Advanced Sales Stat. report per item (substituted by the RS version)
        _StatsFor := 'Item';
        _ItemNoFilter := Item."No.";
        _VendorNoFilter := '';
        _ReportTestLib.RunReportAndLoad(Report::"NPR Advanced Sales Stat.", _LibraryReportDataset);

        // [THEN] Its profit is sales 3000 excl VAT minus the posted COGS
        _Assert.IsTrue(_ReportTestLib.MoveToRowWithValue(_LibraryReportDataset, 'No_Buffer', Item."No."), 'Item row must be printed');
        _Assert.AreNearlyEqual(3000 - PostedCOGS, _ReportTestLib.RowDecimal(_LibraryReportDataset, 'Profit_LCY_Buffer'), 0.01, 'Advanced Sales Stat. profit must use the posted COGS');
    end;

    // Library - Report Dataset flattens only the first nested record per parent, so the uncategorized items are read from the raw XML.
    local procedure LoadReportXml(ReportId: Integer; var ReportXml: XmlDocument)
    var
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
        XmlParameters: Text;
    begin
        Commit();
        XmlParameters := Report.RunRequestPage(ReportId);
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        Report.SaveAs(ReportId, XmlParameters, ReportFormat::Xml, OutStr);
        TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
        XmlDocument.ReadFrom(InStr, ReportXml);
    end;

    local procedure Item2Column(ReportXml: XmlDocument; ItemNo: Code[20]; ColumnName: Text) Result: Decimal
    var
        Node: XmlNode;
    begin
        _Assert.IsTrue(
            ReportXml.SelectSingleNode(StrSubstNo('//DataItem[@name=''Item2''][Columns/Column[@name=''Item2_No'']=''%1'']/Columns/Column[@name=''%2'']', ItemNo, ColumnName), Node),
            StrSubstNo('Uncategorized item %1 must print column %2', ItemNo, ColumnName));
        Evaluate(Result, Node.AsXmlElement().InnerText(), 9);
    end;

    [RequestPageHandler]
    procedure RSAdvancedSalesStatRequestPageHandler(var RSAdvancedSalesStat: TestRequestPage "NPR RS Advanced Sales Stat.")
    begin
        RSAdvancedSalesStat."Stats for".SetValue(_StatsFor);
        RSAdvancedSalesStat."Sort By".SetValue('No.');
        RSAdvancedSalesStat."Periode start".SetValue(20000101D);
        RSAdvancedSalesStat."Period end".SetValue(20991231D);
        RSAdvancedSalesStat."Item No.".SetValue(_ItemNoFilter);
        RSAdvancedSalesStat."Vendor No.".SetValue(_VendorNoFilter);
        RSAdvancedSalesStat.OK().Invoke();
    end;

    [RequestPageHandler]
    procedure RSSalesStatsPerVarietyRequestPageHandler(var RSSalesStatsPerVariety: TestRequestPage "NPR RS Sales Stats Per Variety")
    begin
        RSSalesStatsPerVariety."Print Also Without Sale".SetValue(false);
        RSSalesStatsPerVariety.Item.SetFilter("No.", _ItemNoFilter);
        RSSalesStatsPerVariety.OK().Invoke();
    end;

    [RequestPageHandler]
    procedure RSRetailSalesStatisticsRequestPageHandler(var RSRetailSalesStatistics: TestRequestPage "NPR RS Retail Sales Statistics")
    begin
        RSRetailSalesStatistics."Show Items".SetValue(true);
        RSRetailSalesStatistics."Start Date".SetValue(0D);
        RSRetailSalesStatistics."End Date".SetValue(0D);
        RSRetailSalesStatistics."Location Code".SetValue('');
        RSRetailSalesStatistics.Item.SetFilter("Item Category Code", _ItemCategoryFilter);
        RSRetailSalesStatistics.OK().Invoke();
    end;

    [MessageHandler]
    procedure POSMessageHandler(Msg: Text[1024])
    begin
        _Assert.ExpectedMessage(_ExpectedMessage, Msg);
        _MessagesHandled += 1;
    end;
}
