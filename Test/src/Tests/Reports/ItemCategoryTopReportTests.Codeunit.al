codeunit 85340 "NPR ItemCategoryTopReportTests"
{
    Subtype = Test;

    var
        _Assert: Codeunit Assert;
        _LibraryReportDataset: Codeunit "Library - Report Dataset";
        _TestLib: Codeunit "NPR Retail Report Test Lib";
        _NumberOfCategories: Integer;
        _NumberOfLevels: Integer;
        _SortBy: Integer;
        _SortOrder: Integer;
        _DateFilter: Text;
        _DepartmentFilter: Text;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ItemCategoryTopRequestPageHandler')]
    procedure GivenThreeDepartmentsWhereOneHasNoSalesInThePeriod_WhenReportRuns_ThenOnlyDepartmentsWithSalesGetSections()
    var
        Codes: Dictionary of [Text, Code[20]];
    begin
        Initialize();
        _TestLib.CreateFixtureB(Codes);

        RunDefaultReport(Codes);

        _Assert.AreEqual(
            StrSubstNo('%1|%2', Codes.Get('REST1'), Codes.Get('REST2')),
            _TestLib.SectionCodes(_LibraryReportDataset),
            'Sections and their order.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ItemCategoryTopRequestPageHandler')]
    procedure GivenGroupWithZeroSummedSales_WhenReportRuns_ThenTheGroupIsExcludedEntirely()
    var
        TempItemCategoryBuffer: Record "NPR Item Category Buffer" temporary;
        Codes: Dictionary of [Text, Code[20]];
    begin
        Initialize();
        _TestLib.CreateFixtureB(Codes);

        RunDefaultReport(Codes);
        _TestLib.LoadSectionLines(_LibraryReportDataset, Codes.Get('REST1'), TempItemCategoryBuffer);

        AssertNoLine(TempItemCategoryBuffer, Codes.Get('SIDES'));
        _Assert.AreEqual(385.0, _TestLib.SectionTotal(_LibraryReportDataset, Codes.Get('REST1'), 'Quantity_DimensionValue'), 'The excluded quantity is in no total.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ItemCategoryTopRequestPageHandler')]
    procedure GivenGroupWithNegativeSummedSales_WhenReportRuns_ThenTheGroupIsExcludedEntirely()
    var
        TempItemCategoryBuffer: Record "NPR Item Category Buffer" temporary;
        Codes: Dictionary of [Text, Code[20]];
    begin
        Initialize();
        _TestLib.CreateFixtureB(Codes);

        RunDefaultReport(Codes);
        _TestLib.LoadSectionLines(_LibraryReportDataset, Codes.Get('REST1'), TempItemCategoryBuffer);

        AssertNoLine(TempItemCategoryBuffer, Codes.Get('ICECREAM'));
        _Assert.AreEqual(6750.0, _TestLib.SectionTotal(_LibraryReportDataset, Codes.Get('REST1'), 'SalesLCY_DimensionValue'), 'The excluded sales are in no total.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ItemCategoryTopRequestPageHandler')]
    procedure GivenLeafCategoryWithSales_WhenReportRuns_ThenQuantitySalesProfitAndPercentageArePrinted()
    var
        TempItemCategoryBuffer: Record "NPR Item Category Buffer" temporary;
        Codes: Dictionary of [Text, Code[20]];
    begin
        Initialize();
        _TestLib.CreateFixtureB(Codes);

        RunDefaultReport(Codes);
        _TestLib.LoadSectionLines(_LibraryReportDataset, Codes.Get('REST1'), TempItemCategoryBuffer);
        GetLine(TempItemCategoryBuffer, Codes.Get('BURGERS'));

        _Assert.AreEqual(100.0, TempItemCategoryBuffer."Calc Field 1", 'Quantity.');
        _Assert.AreEqual(2000.0, TempItemCategoryBuffer."Calc Field 2", 'Sales (LCY).');
        _Assert.AreEqual(800.0, TempItemCategoryBuffer."Calc Field 3", 'Profit (LCY).');
        _Assert.AreNearlyEqual(0.4, TempItemCategoryBuffer."Calc Field 4", 0.00001, 'Profit %.');
        _Assert.AreEqual(_TestLib.Indented(Codes.Get('BURGERS'), 2), TempItemCategoryBuffer."Code with Indentation", 'Row label indentation.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ItemCategoryTopRequestPageHandler')]
    procedure GivenItemRecategorisedAfterPosting_WhenReportRuns_ThenSalesStayUnderTheStampedCategory()
    var
        TempItemCategoryBuffer: Record "NPR Item Category Buffer" temporary;
        Codes: Dictionary of [Text, Code[20]];
    begin
        Initialize();
        _TestLib.CreateFixtureB(Codes);
        _TestLib.SetItemCategory(Codes.Get('ITEM'), Codes.Get('DRINKS'));

        RunDefaultReport(Codes);
        _TestLib.LoadSectionLines(_LibraryReportDataset, Codes.Get('REST1'), TempItemCategoryBuffer);
        GetLine(TempItemCategoryBuffer, Codes.Get('BURGERS'));

        _Assert.AreEqual(100.0, TempItemCategoryBuffer."Calc Field 1", 'Quantity.');
        _Assert.AreEqual(2000.0, TempItemCategoryBuffer."Calc Field 2", 'Sales (LCY).');
        _Assert.AreEqual(800.0, TempItemCategoryBuffer."Calc Field 3", 'Profit (LCY).');
        _Assert.AreNearlyEqual(0.4, TempItemCategoryBuffer."Calc Field 4", 0.00001, 'Profit %.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ItemCategoryTopRequestPageHandler')]
    procedure GivenSalesWithoutACategory_WhenReportRuns_ThenTheyPrintAsAWithoutCategoryRootLine()
    var
        TempItemCategoryBuffer: Record "NPR Item Category Buffer" temporary;
        Codes: Dictionary of [Text, Code[20]];
    begin
        Initialize();
        _TestLib.CreateFixtureB(Codes);

        RunDefaultReport(Codes);
        _TestLib.LoadSectionLines(_LibraryReportDataset, Codes.Get('REST1'), TempItemCategoryBuffer);
        GetLine(TempItemCategoryBuffer, '-');

        _Assert.AreEqual('Without category', TempItemCategoryBuffer.Description, 'Description.');
        _Assert.AreEqual(0, TempItemCategoryBuffer.Indentation, 'Indentation.');
        _Assert.AreEqual(10.0, TempItemCategoryBuffer."Calc Field 1", 'Quantity.');
        _Assert.AreEqual(150.0, TempItemCategoryBuffer."Calc Field 2", 'Sales (LCY).');
        _Assert.AreEqual(90.0, TempItemCategoryBuffer."Calc Field 3", 'Profit (LCY).');
        _Assert.AreNearlyEqual(0.6, TempItemCategoryBuffer."Calc Field 4", 0.00001, 'Profit %.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ItemCategoryTopRequestPageHandler')]
    procedure GivenSalesOnlyOnLeafCategories_WhenReportRuns_ThenParentLinesShowRolledUpTotals()
    var
        TempItemCategoryBuffer: Record "NPR Item Category Buffer" temporary;
        Codes: Dictionary of [Text, Code[20]];
    begin
        Initialize();
        _TestLib.CreateFixtureB(Codes);

        RunDefaultReport(Codes);
        _TestLib.LoadSectionLines(_LibraryReportDataset, Codes.Get('REST1'), TempItemCategoryBuffer);

        GetLine(TempItemCategoryBuffer, Codes.Get('HOTFOOD'));
        _Assert.AreEqual(150.0, TempItemCategoryBuffer."Calc Field 1", 'Mid level quantity.');
        _Assert.AreEqual(3000.0, TempItemCategoryBuffer."Calc Field 2", 'Mid level sales.');
        _Assert.AreEqual(1400.0, TempItemCategoryBuffer."Calc Field 3", 'Mid level profit.');

        GetLine(TempItemCategoryBuffer, Codes.Get('FOOD'));
        _Assert.AreEqual(150.0, TempItemCategoryBuffer."Calc Field 1", 'Root quantity.');
        _Assert.AreEqual(3000.0, TempItemCategoryBuffer."Calc Field 2", 'Root sales.');
        _Assert.AreEqual(1400.0, TempItemCategoryBuffer."Calc Field 3", 'Root profit.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ItemCategoryTopRequestPageHandler')]
    procedure GivenParentAndRootLines_WhenReportRuns_ThenParentPercentageSumsChildRatiosAndRootShowsBlendedRatio()
    var
        TempItemCategoryBuffer: Record "NPR Item Category Buffer" temporary;
        Codes: Dictionary of [Text, Code[20]];
    begin
        Initialize();
        _TestLib.CreateFixtureB(Codes);

        RunDefaultReport(Codes);
        _TestLib.LoadSectionLines(_LibraryReportDataset, Codes.Get('REST1'), TempItemCategoryBuffer);

        GetLine(TempItemCategoryBuffer, Codes.Get('HOTFOOD'));
        _Assert.AreNearlyEqual(1.0, TempItemCategoryBuffer."Calc Field 4", 0.00001, 'Mid level profit % is a sum of ratios.');

        GetLine(TempItemCategoryBuffer, Codes.Get('FOOD'));
        _Assert.AreNearlyEqual(0.46667, TempItemCategoryBuffer."Calc Field 4", 0.00001, 'Root profit % is the blended ratio.');

        GetLine(TempItemCategoryBuffer, Codes.Get('DRINKS'));
        _Assert.AreNearlyEqual(0.7, TempItemCategoryBuffer."Calc Field 4", 0.00001, 'Leaf root profit %.');

        GetLine(TempItemCategoryBuffer, Codes.Get('SNACKS'));
        _Assert.AreNearlyEqual(0.5, TempItemCategoryBuffer."Calc Field 4", 0.00001, 'Leaf root profit %.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ItemCategoryTopRequestPageHandler')]
    procedure GivenMoreRootsThanDisplayTop_WhenReportRuns_ThenLowestRankedRootsAndTheirSubtreesAreRemoved()
    var
        TempItemCategoryBuffer: Record "NPR Item Category Buffer" temporary;
        Codes: Dictionary of [Text, Code[20]];
    begin
        Initialize();
        _TestLib.CreateFixtureB(Codes);
        _NumberOfCategories := 2;

        RunDefaultReport(Codes);
        _TestLib.LoadSectionLines(_LibraryReportDataset, Codes.Get('REST1'), TempItemCategoryBuffer);

        AssertNoLine(TempItemCategoryBuffer, Codes.Get('SNACKS'));
        _Assert.AreEqual(
            StrSubstNo('%1(1) %2 %3 %4 %5(2)', Codes.Get('FOOD'), Codes.Get('HOTFOOD'), Codes.Get('HOTDOGS'), Codes.Get('BURGERS'), Codes.Get('DRINKS')),
            _TestLib.PrintedLineOrder(TempItemCategoryBuffer),
            'Printed lines and root sequence numbers.');

        GetLine(TempItemCategoryBuffer, Codes.Get('FOOD'));
        _Assert.AreNearlyEqual(1.0, TempItemCategoryBuffer."Calc Field 4", 0.00001, 'The root profit % correction is skipped when pruning ran.');

        _Assert.AreEqual(350.0, _TestLib.SectionTotal(_LibraryReportDataset, Codes.Get('REST1'), 'Quantity_DimensionValue'), 'Total quantity over surviving roots.');
        _Assert.AreEqual(6100.0, _TestLib.SectionTotal(_LibraryReportDataset, Codes.Get('REST1'), 'SalesLCY_DimensionValue'), 'Total sales over surviving roots.');
        _Assert.AreEqual(3570.0, _TestLib.SectionTotal(_LibraryReportDataset, Codes.Get('REST1'), 'ProfitLCY_DimensionValue'), 'Total profit over surviving roots.');
        _Assert.AreNearlyEqual(0.58525, _TestLib.SectionTotal(_LibraryReportDataset, Codes.Get('REST1'), 'ProfitPerc_DimensionValue'), 0.00001, 'Total profit %.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ItemCategoryTopRequestPageHandler')]
    procedure GivenNumberOfLevelsBelowTheTreeDepth_WhenReportRuns_ThenDeeperLinesGoButParentTotalsRemain()
    var
        TempItemCategoryBuffer: Record "NPR Item Category Buffer" temporary;
        Codes: Dictionary of [Text, Code[20]];
    begin
        Initialize();
        _TestLib.CreateFixtureB(Codes);
        _NumberOfLevels := 2;

        RunDefaultReport(Codes);
        _TestLib.LoadSectionLines(_LibraryReportDataset, Codes.Get('REST1'), TempItemCategoryBuffer);

        AssertNoLine(TempItemCategoryBuffer, Codes.Get('BURGERS'));
        AssertNoLine(TempItemCategoryBuffer, Codes.Get('HOTDOGS'));

        GetLine(TempItemCategoryBuffer, Codes.Get('HOTFOOD'));
        _Assert.AreEqual(150.0, TempItemCategoryBuffer."Calc Field 1", 'Surviving parent keeps pruned quantity.');
        _Assert.AreEqual(3000.0, TempItemCategoryBuffer."Calc Field 2", 'Surviving parent keeps pruned sales.');
        _Assert.AreEqual(1400.0, TempItemCategoryBuffer."Calc Field 3", 'Surviving parent keeps pruned profit.');
        _Assert.AreNearlyEqual(1.0, TempItemCategoryBuffer."Calc Field 4", 0.00001, 'Surviving parent profit %.');

        GetLine(TempItemCategoryBuffer, Codes.Get('FOOD'));
        _Assert.AreEqual(3000.0, TempItemCategoryBuffer."Calc Field 2", 'Root sales.');
        _Assert.AreNearlyEqual(0.46667, TempItemCategoryBuffer."Calc Field 4", 0.00001, 'Root profit %.');

        _Assert.AreEqual(6750.0, _TestLib.SectionTotal(_LibraryReportDataset, Codes.Get('REST1'), 'SalesLCY_DimensionValue'), 'Totals are unchanged by level pruning.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ItemCategoryTopRequestPageHandler')]
    procedure GivenAscendingSortBySales_WhenReportRuns_ThenSiblingsPrintSmallestFirstWithRootSequenceNumbers()
    var
        TempItemCategoryBuffer: Record "NPR Item Category Buffer" temporary;
        Codes: Dictionary of [Text, Code[20]];
    begin
        Initialize();
        _TestLib.CreateFixtureB(Codes);

        RunDefaultReport(Codes);
        _TestLib.LoadSectionLines(_LibraryReportDataset, Codes.Get('REST1'), TempItemCategoryBuffer);

        _Assert.AreEqual(
            StrSubstNo('-(1) %1(2) %2(3) %3 %4 %5 %6(4)', Codes.Get('SNACKS'), Codes.Get('FOOD'), Codes.Get('HOTFOOD'), Codes.Get('HOTDOGS'), Codes.Get('BURGERS'), Codes.Get('DRINKS')),
            _TestLib.PrintedLineOrder(TempItemCategoryBuffer),
            'Printed lines and root sequence numbers.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ItemCategoryTopRequestPageHandler')]
    procedure GivenDescendingSortBySales_WhenReportRuns_ThenSiblingsPrintLargestFirst()
    var
        TempItemCategoryBuffer: Record "NPR Item Category Buffer" temporary;
        Codes: Dictionary of [Text, Code[20]];
    begin
        Initialize();
        _TestLib.CreateFixtureB(Codes);
        _SortOrder := 1;

        RunDefaultReport(Codes);
        _TestLib.LoadSectionLines(_LibraryReportDataset, Codes.Get('REST1'), TempItemCategoryBuffer);

        _Assert.AreEqual(
            StrSubstNo('%1(1) %2(2) %3 %4 %5 %6(3) -(4)', Codes.Get('DRINKS'), Codes.Get('FOOD'), Codes.Get('HOTFOOD'), Codes.Get('BURGERS'), Codes.Get('HOTDOGS'), Codes.Get('SNACKS')),
            _TestLib.PrintedLineOrder(TempItemCategoryBuffer),
            'Printed lines and root sequence numbers.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ItemCategoryTopRequestPageHandler')]
    procedure GivenSeveralRootLines_WhenReportRuns_ThenTheDepartmentTotalSumsThem()
    var
        Codes: Dictionary of [Text, Code[20]];
    begin
        Initialize();
        _TestLib.CreateFixtureB(Codes);

        RunDefaultReport(Codes);

        _Assert.AreEqual(385.0, _TestLib.SectionTotal(_LibraryReportDataset, Codes.Get('REST1'), 'Quantity_DimensionValue'), 'Total quantity.');
        _Assert.AreEqual(6750.0, _TestLib.SectionTotal(_LibraryReportDataset, Codes.Get('REST1'), 'SalesLCY_DimensionValue'), 'Total sales.');
        _Assert.AreEqual(3910.0, _TestLib.SectionTotal(_LibraryReportDataset, Codes.Get('REST1'), 'ProfitLCY_DimensionValue'), 'Total profit.');
        _Assert.AreNearlyEqual(0.57926, _TestLib.SectionTotal(_LibraryReportDataset, Codes.Get('REST1'), 'ProfitPerc_DimensionValue'), 0.00001, 'Total profit %.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ItemCategoryTopRequestPageHandler')]
    procedure GivenDepartmentWithOneGroup_WhenReportRuns_ThenItsTotalMatchesThatGroup()
    var
        Codes: Dictionary of [Text, Code[20]];
    begin
        Initialize();
        _TestLib.CreateFixtureB(Codes);

        RunDefaultReport(Codes);

        _Assert.AreEqual(30.0, _TestLib.SectionTotal(_LibraryReportDataset, Codes.Get('REST2'), 'Quantity_DimensionValue'), 'Total quantity.');
        _Assert.AreEqual(450.0, _TestLib.SectionTotal(_LibraryReportDataset, Codes.Get('REST2'), 'SalesLCY_DimensionValue'), 'Total sales.');
        _Assert.AreEqual(300.0, _TestLib.SectionTotal(_LibraryReportDataset, Codes.Get('REST2'), 'ProfitLCY_DimensionValue'), 'Total profit.');
        _Assert.AreNearlyEqual(0.66667, _TestLib.SectionTotal(_LibraryReportDataset, Codes.Get('REST2'), 'ProfitPerc_DimensionValue'), 0.00001, 'Total profit %.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ItemCategoryTopRequestPageHandler')]
    procedure GivenDepartmentWithSalesOnlyOutsideTheDateFilter_WhenReportRuns_ThenItGetsNoSection()
    var
        Codes: Dictionary of [Text, Code[20]];
    begin
        Initialize();
        _TestLib.CreateFixtureB(Codes);

        RunDefaultReport(Codes);

        _Assert.IsFalse(_TestLib.SectionCodes(_LibraryReportDataset).Contains(Codes.Get('REST3')), 'The department must not get a section.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ItemCategoryTopRequestPageHandler')]
    procedure GivenDateFilterWidenedToCoverEarlierSales_WhenReportRuns_ThenTheDepartmentGetsItsSection()
    var
        TempItemCategoryBuffer: Record "NPR Item Category Buffer" temporary;
        Codes: Dictionary of [Text, Code[20]];
    begin
        Initialize();
        _TestLib.CreateFixtureB(Codes);
        _DateFilter := _TestLib.DateRangeFilter(20260501D, 20260630D);

        RunDefaultReport(Codes);
        _TestLib.LoadSectionLines(_LibraryReportDataset, Codes.Get('REST3'), TempItemCategoryBuffer);
        GetLine(TempItemCategoryBuffer, Codes.Get('DRINKS'));

        _Assert.AreEqual(40.0, TempItemCategoryBuffer."Calc Field 1", 'Quantity.');
        _Assert.AreEqual(600.0, TempItemCategoryBuffer."Calc Field 2", 'Sales (LCY).');
        _Assert.AreEqual(400.0, TempItemCategoryBuffer."Calc Field 3", 'Profit (LCY).');
        _Assert.AreNearlyEqual(0.66667, TempItemCategoryBuffer."Calc Field 4", 0.00001, 'Profit %.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ItemCategoryTopRequestPageHandler')]
    procedure GivenCostAdjustedAfterThePeriodEnd_WhenReportRuns_ThenProfitIncludesItAndQuantityCountsOnce()
    var
        TempItemCategoryBuffer: Record "NPR Item Category Buffer" temporary;
        Codes: Dictionary of [Text, Code[20]];
    begin
        Initialize();
        _TestLib.CreateFixtureB(Codes);
        _TestLib.InsertSaleCostAdjustment(
            _TestLib.FindSaleEntryNo(Codes.Get('ITEM'), 20260610D, Codes.Get('BURGERS')), Codes.Get('ITEM'), 20260715D, Codes.Get('REST1'), -100.0);

        RunDefaultReport(Codes);
        _TestLib.LoadSectionLines(_LibraryReportDataset, Codes.Get('REST1'), TempItemCategoryBuffer);

        TempItemCategoryBuffer.Reset();
        TempItemCategoryBuffer.SetRange(Code, Codes.Get('BURGERS'));
        _Assert.AreEqual(1, TempItemCategoryBuffer.Count(), 'The adjusted sale produces exactly one line.');

        GetLine(TempItemCategoryBuffer, Codes.Get('BURGERS'));
        _Assert.AreEqual(100.0, TempItemCategoryBuffer."Calc Field 1", 'Quantity counts once.');
        _Assert.AreEqual(2000.0, TempItemCategoryBuffer."Calc Field 2", 'Sales (LCY).');
        _Assert.AreEqual(700.0, TempItemCategoryBuffer."Calc Field 3", 'Profit includes the late adjustment.');
        _Assert.AreNearlyEqual(0.35, TempItemCategoryBuffer."Calc Field 4", 0.00001, 'Profit %.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ItemCategoryTopRequestPageHandler')]
    procedure GivenSalesWithACategoryDeletedAfterPosting_WhenReportRuns_ThenTheyAreDroppedFromLinesAndTotals()
    var
        TempItemCategoryBuffer: Record "NPR Item Category Buffer" temporary;
        DepartmentCode: Code[20];
        KeptCategory: Code[20];
        DeletedCategory: Code[20];
    begin
        Initialize();
        _TestLib.Initialize();
        DepartmentCode := _TestLib.CreateDepartment('R1', 'Food Court');
        KeptCategory := _TestLib.CreateItemCategory('KEPT', '', 0);
        DeletedCategory := _TestLib.CreateItemCategory('GONE', '', 0);
        _TestLib.InsertSale(_TestLib.CreateItem('ITEM', 'FIXTURE', 10.0, 0), 20260610D, DepartmentCode, KeptCategory, -20, -20, 400.0, -100.0);
        _TestLib.InsertSale(_TestLib.CreateItem('ITEM2', 'FIXTURE', 10.0, 0), 20260610D, DepartmentCode, DeletedCategory, -50, -50, 500.0, -200.0);
        _TestLib.DeleteItemCategory(DeletedCategory);

        RunReport(DepartmentCode);
        _TestLib.LoadSectionLines(_LibraryReportDataset, DepartmentCode, TempItemCategoryBuffer);

        AssertNoLine(TempItemCategoryBuffer, DeletedCategory);
        GetLine(TempItemCategoryBuffer, KeptCategory);
        _Assert.AreEqual(400.0, TempItemCategoryBuffer."Calc Field 2", 'Only the surviving category is printed.');
        _Assert.AreEqual(400.0, _TestLib.SectionTotal(_LibraryReportDataset, DepartmentCode, 'SalesLCY_DimensionValue'), 'The dropped sales are in no total.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ItemCategoryTopRequestPageHandler')]
    procedure GivenDepartmentWhoseOnlySalesUseADeletedCategory_WhenReportRuns_ThenItIsSkippedAndOtherSectionsPrint()
    var
        Codes: Dictionary of [Text, Code[20]];
        EmptyDepartment: Code[20];
        DeletedCategory: Code[20];
    begin
        Initialize();
        _TestLib.CreateFixtureB(Codes);
        EmptyDepartment := _TestLib.CreateDepartment('R4', 'Rooftop');
        DeletedCategory := _TestLib.CreateItemCategory('GONE', '', 0);
        _TestLib.InsertSale(Codes.Get('ITEM'), 20260610D, EmptyDepartment, DeletedCategory, -50, -50, 500.0, -200.0);
        _TestLib.DeleteItemCategory(DeletedCategory);

        RunReport(StrSubstNo('%1|%2', Codes.Get('REST1'), EmptyDepartment));

        _Assert.AreEqual(Codes.Get('REST1'), _TestLib.SectionCodes(_LibraryReportDataset), 'The department without printable lines gets no section.');
        _Assert.AreEqual(6750.0, _TestLib.SectionTotal(_LibraryReportDataset, Codes.Get('REST1'), 'SalesLCY_DimensionValue'), 'The remaining section still prints.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ItemCategoryTopRequestPageHandler')]
    procedure GivenAnIleWhoseValueEntriesCarryExtraQuantities_WhenReportRuns_ThenQuantityStillMatchesTheLedgerEntry()
    var
        TempItemCategoryBuffer: Record "NPR Item Category Buffer" temporary;
        DepartmentCode: Code[20];
        CategoryCode: Code[20];
        ItemNo: Code[20];
        SaleEntryNo: Integer;
    begin
        Initialize();
        _TestLib.Initialize();
        DepartmentCode := _TestLib.CreateDepartment('R1', 'Food Court');
        CategoryCode := _TestLib.CreateItemCategory('CAT', '', 0);
        ItemNo := _TestLib.CreateItem('ITEM', 'FIXTURE', 10.0, 0);
        SaleEntryNo := _TestLib.InsertSale(ItemNo, 20260610D, DepartmentCode, CategoryCode, -10, -10, 200.0, -100.0);
        _TestLib.InsertSaleValueEntry(SaleEntryNo, ItemNo, 20260610D, DepartmentCode, 10, 0.0, 0.0);

        RunReport(DepartmentCode);
        _TestLib.LoadSectionLines(_LibraryReportDataset, DepartmentCode, TempItemCategoryBuffer);
        GetLine(TempItemCategoryBuffer, CategoryCode);

        _Assert.AreEqual(10.0, TempItemCategoryBuffer."Calc Field 1", 'Quantity must match the ledger entry, not the value-entry quantity sum.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ItemCategoryTopRequestPageHandler')]
    procedure GivenTwoRunsDifferingOnlyInDepartmentCount_WhenReportRuns_ThenDatabaseRoundTripsAreEqual()
    var
        Categories: List of [Code[20]];
        ItemNo: Code[20];
        WarmupFilter: Text;
        FewDepartmentsFilter: Text;
        ManyDepartmentsFilter: Text;
        FewDepartmentsStatements: Integer;
        ManyDepartmentsStatements: Integer;
    begin
        Initialize();
        _TestLib.Initialize();
        ItemNo := _TestLib.CreateItem('ITEM', 'FIXTURE', 10.0, 0);
        Categories.Add(_TestLib.CreateItemCategory('C1', '', 0));
        Categories.Add(_TestLib.CreateItemCategory('C2', '', 0));
        Categories.Add(_TestLib.CreateItemCategory('C3', '', 0));
        Categories.Add(_TestLib.CreateItemCategory('C4', '', 0));
        WarmupFilter := _TestLib.CreatePerfSections('QW', 2, 4, ItemNo, Categories);
        FewDepartmentsFilter := _TestLib.CreatePerfSections('QA', 2, 4, ItemNo, Categories);
        ManyDepartmentsFilter := _TestLib.CreatePerfSections('QB', 8, 1, ItemNo, Categories);

        // Warming up on a third department set loads the report metadata without caching either measured set.
        RunReport(WarmupFilter);

        FewDepartmentsStatements := MeasureRun(FewDepartmentsFilter);
        ManyDepartmentsStatements := MeasureRun(ManyDepartmentsFilter);

        // 2026-07-30: before 10 stmts (2 depts) / 22 (8 depts); after 7 / 7
        // Error(StrSubstNo('2 departments: %1, 8 departments: %2', FewDepartmentsStatements, ManyDepartmentsStatements));
        _Assert.IsTrue((ManyDepartmentsStatements <= FewDepartmentsStatements + 2) and (FewDepartmentsStatements <= ManyDepartmentsStatements + 2),
            StrSubstNo('Database round trips must not depend on the department count (tolerance +/-2). 2 departments: %1, 8 departments: %2.', FewDepartmentsStatements, ManyDepartmentsStatements));
        _Assert.IsTrue(ManyDepartmentsStatements < 30, StrSubstNo('Database round trips must stay below the ceiling. 8 departments: %1.', ManyDepartmentsStatements));
    end;

    local procedure RunDefaultReport(Codes: Dictionary of [Text, Code[20]])
    begin
        RunReport(StrSubstNo('%1|%2|%3', Codes.Get('REST1'), Codes.Get('REST2'), Codes.Get('REST3')));
    end;

    local procedure Initialize()
    begin
        _DateFilter := _TestLib.DateRangeFilter(20260601D, 20260630D);
        _DepartmentFilter := '';
        _NumberOfCategories := 20;
        _NumberOfLevels := 5;
        _SortBy := 0;
        _SortOrder := 0;
    end;

    local procedure RunReport(DepartmentFilter: Text)
    begin
        _DepartmentFilter := DepartmentFilter;

        Commit();
        Report.Run(Report::"NPR Item Category Top", true, false);
        _LibraryReportDataset.LoadDataSetFile();
    end;

    local procedure MeasureRun(DepartmentFilter: Text) SqlStatements: Integer
    begin
        SqlStatements := SessionInformation.SqlStatementsExecuted();
        RunReport(DepartmentFilter);
        exit(SessionInformation.SqlStatementsExecuted() - SqlStatements);
    end;

    local procedure GetLine(var TempItemCategoryBuffer: Record "NPR Item Category Buffer" temporary; ItemCategoryCode: Code[20])
    begin
        TempItemCategoryBuffer.Reset();
        TempItemCategoryBuffer.SetRange(Code, ItemCategoryCode);
        _Assert.IsTrue(TempItemCategoryBuffer.FindFirst(), StrSubstNo('The section has no line for %1.', ItemCategoryCode));
    end;

    local procedure AssertNoLine(var TempItemCategoryBuffer: Record "NPR Item Category Buffer" temporary; ItemCategoryCode: Code[20])
    begin
        TempItemCategoryBuffer.Reset();
        TempItemCategoryBuffer.SetRange(Code, ItemCategoryCode);
        _Assert.IsTrue(TempItemCategoryBuffer.IsEmpty(), StrSubstNo('The section must have no line for %1.', ItemCategoryCode));
    end;

    [RequestPageHandler]
    procedure ItemCategoryTopRequestPageHandler(var ItemCategoryTop: TestRequestPage "NPR Item Category Top")
    begin
        ItemCategoryTop.ItemCategoryFilter.SetFilter("NPR Date Filter", _DateFilter);
        ItemCategoryTop.ItemCategoryFilter.SetFilter("NPR Global Dimension 1 Filter", _DepartmentFilter);
        ItemCategoryTop."Number Of Categories".SetValue(_NumberOfCategories);
        ItemCategoryTop."Number Of Levels".SetValue(_NumberOfLevels);
        ItemCategoryTop."Sort By".SetValue(_SortBy);
        ItemCategoryTop."Sort Order".SetValue(_SortOrder);
        ItemCategoryTop.SaveAsXml(_LibraryReportDataset.GetParametersFileName(), _LibraryReportDataset.GetFileName());
    end;
}
