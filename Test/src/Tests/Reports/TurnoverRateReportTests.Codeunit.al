codeunit 85339 "NPR TurnoverRate Report Tests"
{
    Subtype = Test;

    var
        _Assert: Codeunit Assert;
        _LibraryReportDataset: Codeunit "Library - Report Dataset";
        _TestLib: Codeunit "NPR Retail Report Test Lib";
        _DateFilter: Text;
        _DepartmentFilter: Text;
        _ItemNoFilter: Text;
        _LocationFilter: Text;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('TurnoverRateRequestPageHandler')]
    procedure GivenItemWithSalesAndItemWithStockButNoSales_WhenReportRuns_ThenOnlyTheItemWithSalesIsVisible()
    var
        Codes: Dictionary of [Text, Code[20]];
    begin
        _TestLib.CreateFixtureA(Codes);

        RunReport(FirstHalfOf2026(), StrSubstNo('%1|%2', Codes.Get('BURGER'), Codes.Get('WATER')), '');

        _Assert.AreEqual(Codes.Get('BURGER'), _TestLib.VisibleItemNos(_LibraryReportDataset), 'Only the item with sales in the period should produce a visible row.');
        _Assert.AreEqual(2000.0, ItemRowDecimal(Codes.Get('BURGER'), 'SalesPeriod_Item'), 'Sales during the period for the item with sales.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('TurnoverRateRequestPageHandler')]
    procedure GivenItemWithStockAndIndirectCostPercentage_WhenReportRuns_ThenStockValueColumnIsZero()
    var
        Codes: Dictionary of [Text, Code[20]];
    begin
        _TestLib.CreateFixtureA(Codes);

        RunReport(FirstHalfOf2026(), Codes.Get('BURGER'), '');

        _Assert.AreEqual(0.0, ItemRowDecimal(Codes.Get('BURGER'), 'InventoryAmt_Item'), 'Stock value column.');
        _Assert.AreEqual(0.0, _TestLib.DatasetSum(_LibraryReportDataset, 'InventoryAmt_Item'), 'Stock value total.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('TurnoverRateRequestPageHandler')]
    procedure GivenSalesInTwoDepartments_WhenReportRunsWithoutDepartmentFilter_ThenSalesColumnCoversBothDepartments()
    var
        Codes: Dictionary of [Text, Code[20]];
    begin
        _TestLib.CreateFixtureA(Codes);

        RunReport(June2026(), Codes.Get('COLA'), '');

        _Assert.AreEqual(750.0, ItemRowDecimal(Codes.Get('COLA'), 'SalesPeriod_Item'), 'Sales during the period across both departments.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('TurnoverRateRequestPageHandler')]
    procedure GivenSalesInTwoDepartments_WhenReportRunsForOneDepartment_ThenSalesColumnCoversOnlyThatDepartment()
    var
        Codes: Dictionary of [Text, Code[20]];
    begin
        _TestLib.CreateFixtureA(Codes);

        RunReport(June2026(), Codes.Get('COLA'), Codes.Get('REST1'));

        _Assert.AreEqual(600.0, ItemRowDecimal(Codes.Get('COLA'), 'SalesPeriod_Item'), 'Sales during the period for one department.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('TurnoverRateRequestPageHandler')]
    procedure GivenNetSalesInThePeriod_WhenReportRuns_ThenSalesQuantityIsPositive()
    var
        Codes: Dictionary of [Text, Code[20]];
    begin
        _TestLib.CreateFixtureA(Codes);

        RunReport(June2026(), Codes.Get('COLA'), Codes.Get('REST1'));

        _Assert.AreEqual(40.0, ItemRowDecimal(Codes.Get('COLA'), 'SalesQty_Item'), 'Sales quantity for net sales.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('TurnoverRateRequestPageHandler')]
    procedure GivenOnlyARefundInThePeriod_WhenReportRuns_ThenRowIsVisibleWithNegativeQuantityAmountAndRate()
    var
        Codes: Dictionary of [Text, Code[20]];
    begin
        _TestLib.CreateFixtureA(Codes);

        RunReport(June2026(), Codes.Get('SUNDAE'), '');

        _Assert.AreEqual(Codes.Get('SUNDAE'), _TestLib.VisibleItemNos(_LibraryReportDataset), 'A net negative row is still visible.');
        _Assert.AreEqual(-15.0, ItemRowDecimal(Codes.Get('SUNDAE'), 'SalesQty_Item'), 'Sales quantity for a refund.');
        _Assert.AreEqual(-225.0, ItemRowDecimal(Codes.Get('SUNDAE'), 'SalesPeriod_Item'), 'Sales during the period for a refund.');
        _Assert.AreNearlyEqual(-3.27273, ItemRowDecimal(Codes.Get('SUNDAE'), 'TurnoverRate_Item'), 0.00001, 'Turnover rate for a refund.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('TurnoverRateRequestPageHandler')]
    procedure GivenPurchasesAndSalesAcrossThePeriod_WhenReportRuns_ThenTurnoverRateUsesTheAverageInventoryBalance()
    var
        Codes: Dictionary of [Text, Code[20]];
    begin
        _TestLib.CreateFixtureA(Codes);

        RunReport(FirstHalfOf2026(), Codes.Get('BURGER'), '');

        _Assert.AreEqual(2000.0, ItemRowDecimal(Codes.Get('BURGER'), 'SalesPeriod_Item'), 'Sales during the period.');
        _Assert.AreEqual(80.0, ItemRowDecimal(Codes.Get('BURGER'), 'SalesQty_Item'), 'Sales quantity.');
        _Assert.AreNearlyEqual(1.04348, ItemRowDecimal(Codes.Get('BURGER'), 'TurnoverRate_Item'), 0.00001, 'Turnover rate.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('TurnoverRateRequestPageHandler')]
    procedure GivenPeriodEndingMidMonth_WhenReportRuns_ThenMeasurementPointsAnchorToTheEndDayOfMonth()
    var
        Codes: Dictionary of [Text, Code[20]];
    begin
        _TestLib.CreateFixtureA(Codes);

        RunReport(_TestLib.DateRangeFilter(20260115D, 20260614D), Codes.Get('BURGER'), '');

        _Assert.AreEqual(1500.0, ItemRowDecimal(Codes.Get('BURGER'), 'SalesPeriod_Item'), 'Sales during the period.');
        _Assert.AreEqual(60.0, ItemRowDecimal(Codes.Get('BURGER'), 'SalesQty_Item'), 'Sales quantity.');
        _Assert.AreNearlyEqual(0.87805, ItemRowDecimal(Codes.Get('BURGER'), 'TurnoverRate_Item'), 0.00001, 'Turnover rate.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('TurnoverRateRequestPageHandler')]
    procedure GivenDepartmentFilter_WhenReportRuns_ThenTurnoverRateDenominatorHonoursTheDepartmentFilter()
    var
        Codes: Dictionary of [Text, Code[20]];
    begin
        _TestLib.CreateFixtureA(Codes);

        RunReport(June2026(), Codes.Get('COLA'), Codes.Get('REST1'));

        _Assert.AreNearlyEqual(8.0, ItemRowDecimal(Codes.Get('COLA'), 'TurnoverRate_Item'), 0.00001, 'Turnover rate with a department filter.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('TurnoverRateRequestPageHandler')]
    procedure GivenItemThatWasNeverPurchased_WhenReportRuns_ThenTurnoverRateIsZero()
    var
        Codes: Dictionary of [Text, Code[20]];
    begin
        _TestLib.CreateFixtureA(Codes);

        RunReport(June2026(), Codes.Get('SOUVENIR'), '');

        _Assert.AreEqual(Codes.Get('SOUVENIR'), _TestLib.VisibleItemNos(_LibraryReportDataset), 'The row is visible.');
        _Assert.AreEqual(150.0, ItemRowDecimal(Codes.Get('SOUVENIR'), 'SalesPeriod_Item'), 'Sales during the period.');
        _Assert.AreEqual(0.0, ItemRowDecimal(Codes.Get('SOUVENIR'), 'TurnoverRate_Item'), 'Turnover rate with a zero average balance.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('TurnoverRateRequestPageHandler')]
    procedure GivenSeveralItemsWithSales_WhenReportRuns_ThenVisibleRowsAreOrderedByItemNo()
    var
        Codes: Dictionary of [Text, Code[20]];
    begin
        _TestLib.CreateFixtureA(Codes);

        RunReport(June2026(), _TestLib.MakeCode('*'), '');

        _Assert.AreEqual(
            StrSubstNo('%1|%2|%3|%4', Codes.Get('BURGER'), Codes.Get('COLA'), Codes.Get('SOUVENIR'), Codes.Get('SUNDAE')),
            _TestLib.VisibleItemNos(_LibraryReportDataset),
            'Visible rows and their order.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('TurnoverRateRequestPageHandler')]
    procedure GivenHiddenRowWithQuantityButNoSalesAmount_WhenReportRuns_ThenTotalsStillIncludeIt()
    var
        Codes: Dictionary of [Text, Code[20]];
    begin
        _TestLib.CreateFixtureA(Codes);

        RunReport(FirstHalfOf2026(), StrSubstNo('%1|%2', Codes.Get('BURGER'), Codes.Get('NAPKIN')), '');

        _Assert.AreEqual(Codes.Get('BURGER'), _TestLib.VisibleItemNos(_LibraryReportDataset), 'The fully discounted sale produces no visible row.');
        _Assert.AreEqual(2000.0, _TestLib.DatasetSum(_LibraryReportDataset, 'SalesPeriod_Item'), 'Total sales during the period.');
        _Assert.AreEqual(85.0, _TestLib.DatasetSum(_LibraryReportDataset, 'SalesQty_Item'), 'Total sales quantity includes the hidden row.');
        _Assert.AreEqual(0.0, _TestLib.DatasetSum(_LibraryReportDataset, 'InventoryAmt_Item'), 'Total stock value.');
        _Assert.AreNearlyEqual(1.24687, _TestLib.DatasetSum(_LibraryReportDataset, 'TurnoverRate_Item'), 0.00001, 'Total turnover rate includes the hidden row.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('TurnoverRateRequestPageHandler')]
    procedure GivenItemWithNoSalesAndNoStockValue_WhenReportRuns_ThenVisibleOutputAndTotalsAreUnaffected()
    var
        Codes: Dictionary of [Text, Code[20]];
    begin
        _TestLib.CreateFixtureA(Codes);

        RunReport(FirstHalfOf2026(), StrSubstNo('%1|%2', Codes.Get('BURGER'), Codes.Get('WATER')), '');

        _Assert.AreEqual(Codes.Get('BURGER'), _TestLib.VisibleItemNos(_LibraryReportDataset), 'Visible rows.');
        _Assert.AreEqual(2000.0, _TestLib.DatasetSum(_LibraryReportDataset, 'SalesPeriod_Item'), 'Total sales during the period.');
        _Assert.AreEqual(80.0, _TestLib.DatasetSum(_LibraryReportDataset, 'SalesQty_Item'), 'Total sales quantity.');
        _Assert.AreEqual(0.0, _TestLib.DatasetSum(_LibraryReportDataset, 'InventoryAmt_Item'), 'Total stock value.');
        _Assert.AreNearlyEqual(1.04348, _TestLib.DatasetSum(_LibraryReportDataset, 'TurnoverRate_Item'), 0.00001, 'Total turnover rate.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('TurnoverRateRequestPageHandler')]
    procedure GivenAnyRun_WhenReportRuns_ThenHeaderShowsValuationMethodAndBlankPeriodAndValuationDates()
    var
        Codes: Dictionary of [Text, Code[20]];
        ItemNoFilter: Text;
    begin
        _TestLib.CreateFixtureA(Codes);
        ItemNoFilter := StrSubstNo('%1|%2', Codes.Get('BURGER'), Codes.Get('NAPKIN'));

        RunReport(FirstHalfOf2026(), ItemNoFilter, '');

        _Assert.IsTrue(_TestLib.MoveToRowWithValue(_LibraryReportDataset, 'No_Item', Codes.Get('BURGER')), 'The item row is in the dataset.');
        _Assert.AreEqual('Inv.value is based on sidste koebspris', _TestLib.RowText(_LibraryReportDataset, 'Heading2_Item'), 'Valuation method heading.');
        _Assert.AreEqual('Sales during the period', _TestLib.RowText(_LibraryReportDataset, 'Column3_Item').TrimEnd(), 'The period label is followed by nothing.');
        _Assert.AreEqual('Stock Value on Date', _TestLib.RowText(_LibraryReportDataset, 'Column5_Item').TrimEnd(), 'The valuation date label is followed by nothing.');
        _Assert.IsTrue(_TestLib.RowText(_LibraryReportDataset, 'GETFILTERS_Item').Contains(ItemNoFilter), 'The filter string contains the item filter.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('TurnoverRateRequestPageHandler')]
    procedure GivenTwoRunsDifferingOnlyInItemCount_WhenReportRuns_ThenDatabaseRoundTripsAreEqualAndBounded()
    var
        Codes: Dictionary of [Text, Code[20]];
        WarmupFilter: Text;
        FewItemsFilter: Text;
        ManyItemsFilter: Text;
        FewItemsStatements: Integer;
        ManyItemsStatements: Integer;
    begin
        _TestLib.CreateFixtureA(Codes);
        WarmupFilter := _TestLib.CreatePerfItems('PW', 5, Codes.Get('REST1'));
        FewItemsFilter := _TestLib.CreatePerfItems('PA', 5, Codes.Get('REST1'));
        ManyItemsFilter := _TestLib.CreatePerfItems('PB', 50, Codes.Get('REST1'));

        // Warming up on a third item set loads the report metadata without caching either measured set.
        RunReport(FullYear2026(), WarmupFilter, '');

        FewItemsStatements := MeasureRun(FullYear2026(), FewItemsFilter);
        ManyItemsStatements := MeasureRun(FullYear2026(), ManyItemsFilter);

        // 2026-07-30: before 133 stmts (5 items) / 1,303 (50 items); after 16 / 16
        // Error(StrSubstNo('5 items: %1, 50 items: %2', FewItemsStatements, ManyItemsStatements));
        _Assert.IsTrue((ManyItemsStatements <= FewItemsStatements + 2) and (FewItemsStatements <= ManyItemsStatements + 2),
            StrSubstNo('Database round trips must not depend on the item count (tolerance +/-2). 5 items: %1, 50 items: %2.', FewItemsStatements, ManyItemsStatements));
        _Assert.IsTrue(ManyItemsStatements < 100, StrSubstNo('Database round trips must stay below the ceiling. 50 items: %1.', ManyItemsStatements));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('TurnoverRateRequestPageHandler')]
    procedure GivenDateFilterWithoutAClosedRange_WhenReportRuns_ThenTheRunFails()
    var
        Codes: Dictionary of [Text, Code[20]];
    begin
        _TestLib.CreateFixtureA(Codes);

        asserterror RunReport('', Codes.Get('BURGER'), '');

        _Assert.ExpectedError('Date Filter');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('TurnoverRateRequestPageHandler')]
    procedure GivenItemWithZeroLastDirectCost_WhenReportRuns_ThenTurnoverRateIsZeroAndRowIsVisible()
    var
        Codes: Dictionary of [Text, Code[20]];
        ItemNo: Code[20];
    begin
        _TestLib.CreateFixtureA(Codes);
        ItemNo := _TestLib.CreateItem('10080', 'FREEBIE', 0, 0);
        _TestLib.InsertPurchase(ItemNo, 20251201D, Codes.Get('REST1'), 20, 100.0);
        _TestLib.InsertSale(ItemNo, 20260610D, Codes.Get('REST1'), '', -4, -4, 120.0, -20.0);

        RunReport(June2026(), ItemNo, '');

        _Assert.AreEqual(ItemNo, _TestLib.VisibleItemNos(_LibraryReportDataset), 'The row is visible.');
        _Assert.AreEqual(120.0, ItemRowDecimal(ItemNo, 'SalesPeriod_Item'), 'Sales during the period.');
        _Assert.AreEqual(0.0, ItemRowDecimal(ItemNo, 'TurnoverRate_Item'), 'Turnover rate without a last direct cost.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('TurnoverRateRequestPageHandler')]
    procedure GivenCostAdjustmentPostedAfterThePeriodEnd_WhenReportRuns_ThenItDoesNotChangeTheTurnoverRate()
    var
        Codes: Dictionary of [Text, Code[20]];
    begin
        _TestLib.CreateFixtureA(Codes);
        _TestLib.InsertSaleCostAdjustment(
            _TestLib.FindSaleEntryNo(Codes.Get('BURGER'), 20260605D, ''), Codes.Get('BURGER'), 20260715D, Codes.Get('REST1'), -100.0);

        RunReport(FirstHalfOf2026(), Codes.Get('BURGER'), '');

        _Assert.AreEqual(2000.0, ItemRowDecimal(Codes.Get('BURGER'), 'SalesPeriod_Item'), 'Sales during the period.');
        _Assert.AreNearlyEqual(1.04348, ItemRowDecimal(Codes.Get('BURGER'), 'TurnoverRate_Item'), 0.00001, 'Turnover rate.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('TurnoverRateRequestPageHandler')]
    procedure GivenPurchaseDatedExactlyOnAnInteriorMeasurementPoint_WhenReportRuns_ThenItCountsFromThatPointOnwardExactlyOnce()
    var
        Codes: Dictionary of [Text, Code[20]];
        ItemNo: Code[20];
    begin
        _TestLib.CreateFixtureA(Codes);
        ItemNo := _TestLib.CreateItem('10090', 'PIN', 10.0, 0);
        _TestLib.InsertPurchase(ItemNo, 20260430D, Codes.Get('REST1'), 30, 300.0);
        _TestLib.InsertSale(ItemNo, 20260610D, Codes.Get('REST1'), '', -20, -20, 500.0, -50.0);

        RunReport(FirstHalfOf2026(), ItemNo, '');

        _Assert.AreNearlyEqual(2.82353, ItemRowDecimal(ItemNo, 'TurnoverRate_Item'), 0.00001, 'Turnover rate with a purchase dated exactly on an interior measurement point.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('TurnoverRateRequestPageHandler')]
    procedure GivenALocationFilter_WhenReportRuns_ThenOnlyThatLocationsEntriesCount()
    var
        Codes: Dictionary of [Text, Code[20]];
        ItemNo: Code[20];
        LocAEntryNo: Integer;
    begin
        _TestLib.CreateFixtureA(Codes);
        ItemNo := _TestLib.CreateItem('10095', 'LOCPIN', 10.0, 0);

        LocAEntryNo := _TestLib.InsertPurchase(ItemNo, 20251201D, Codes.Get('REST1'), 100, 100.0);
        _TestLib.SetLocationCode(LocAEntryNo, 'LOC-A');
        LocAEntryNo := _TestLib.InsertSale(ItemNo, 20260610D, Codes.Get('REST1'), '', -10, -10, 200.0, -40.0);
        _TestLib.SetLocationCode(LocAEntryNo, 'LOC-A');

        _TestLib.SetLocationCode(_TestLib.InsertPurchase(ItemNo, 20251201D, Codes.Get('REST1'), 400, 400.0), 'LOC-B');
        _TestLib.SetLocationCode(_TestLib.InsertSale(ItemNo, 20260610D, Codes.Get('REST1'), '', -30, -30, 900.0, -120.0), 'LOC-B');

        RunReport(FirstHalfOf2026(), ItemNo, '', 'LOC-A');

        _Assert.AreEqual(200.0, ItemRowDecimal(ItemNo, 'SalesPeriod_Item'), 'Sales during the period must only include the filtered location.');
        _Assert.AreNearlyEqual(2.14286, ItemRowDecimal(ItemNo, 'TurnoverRate_Item'), 0.00001, 'Turnover rate must only include the filtered location.');
    end;

    local procedure RunReport(DateFilter: Text; ItemNoFilter: Text; DepartmentFilter: Text)
    begin
        RunReport(DateFilter, ItemNoFilter, DepartmentFilter, '');
    end;

    local procedure RunReport(DateFilter: Text; ItemNoFilter: Text; DepartmentFilter: Text; LocationFilter: Text)
    begin
        _DateFilter := DateFilter;
        _ItemNoFilter := ItemNoFilter;
        _DepartmentFilter := DepartmentFilter;
        _LocationFilter := LocationFilter;

        _TestLib.RunReportAndLoad(Report::"NPR Turnover Rate", _LibraryReportDataset);
    end;

    local procedure MeasureRun(DateFilter: Text; ItemNoFilter: Text) SqlStatements: Integer
    begin
        SqlStatements := SessionInformation.SqlStatementsExecuted();
        RunReport(DateFilter, ItemNoFilter, '');
        exit(SessionInformation.SqlStatementsExecuted() - SqlStatements);
    end;

    local procedure ItemRowDecimal(ItemNo: Code[20]; ElementName: Text): Decimal
    begin
        _Assert.IsTrue(_TestLib.MoveToRowWithValue(_LibraryReportDataset, 'No_Item', ItemNo), StrSubstNo('The dataset has no row for item %1.', ItemNo));
        exit(_TestLib.RowDecimal(_LibraryReportDataset, ElementName));
    end;

    local procedure FirstHalfOf2026(): Text
    begin
        exit(_TestLib.DateRangeFilter(20260101D, 20260630D));
    end;

    local procedure June2026(): Text
    begin
        exit(_TestLib.DateRangeFilter(20260601D, 20260630D));
    end;

    local procedure FullYear2026(): Text
    begin
        exit(_TestLib.DateRangeFilter(20260101D, 20261231D));
    end;

    [RequestPageHandler]
    procedure TurnoverRateRequestPageHandler(var TurnoverRate: TestRequestPage "NPR Turnover Rate")
    begin
        TurnoverRate.Item.SetFilter("No.", _ItemNoFilter);
        TurnoverRate.Item.SetFilter("Date Filter", _DateFilter);
        TurnoverRate.Item.SetFilter("Global Dimension 1 Filter", _DepartmentFilter);
        TurnoverRate.Item.SetFilter("Location Filter", _LocationFilter);
        TurnoverRate.OK().Invoke();
    end;
}
