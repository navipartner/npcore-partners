codeunit 85057 "NPR POS Act. Sale Dim. Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";
        DimSetLbl: Label 'Dimension code %1 set to %2.';

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AdjustHeaderDim()
    var
        LibraryDim: Codeunit "Library - Dimension";
        Dimension: Record Dimension;
        DimensionValue: Record "Dimension Value";
        POSActSaleDimB: Codeunit "NPR POS Action: Sale Dim. B";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        DimSetEntry: Record "Dimension Set Entry";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        TextMsg: Text;

    begin
        NPRLibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        LibraryDim.CreateDimension(Dimension);
        LibraryDim.CreateDimensionValue(DimensionValue, Dimension.Code);

        TextMsg := POSActSaleDimB.AdjustHeaderDimensions(POSSession, Dimension.Code, DimensionValue.Code, true);

        POSSale.GetCurrentSale(SalePOS);

        DimSetEntry.SetRange("Dimension Set ID", SalePOS."Dimension Set ID");
        DimSetEntry.SetRange("Dimension Code", Dimension.Code);
        DimSetEntry.SetRange("Dimension Value Code", DimensionValue.Code);

        Assert.IsTrue(DimSetEntry.FindFirst(), 'Dimension inserted');
        Assert.IsTrue(TextMsg = StrSubstNo(DimSetLbl, Dimension.Code, DimensionValue.Code), 'Dimension inserted Msg generated');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AdjustLineDim()
    var
        LibraryDim: Codeunit "Library - Dimension";
        Dimension: Record Dimension;
        DimSetEntry: Record "Dimension Set Entry";
        DimensionValue: Record "Dimension Value";
        POSActSaleDimB: Codeunit "NPR POS Action: Sale Dim. B";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        TextMsg: Text;
        ApplyDimTo: Option Sale,CurrentLine,LinesOfTypeSale;
        Item: Record Item;

    begin
        NPRLibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);

        NPRLibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        LibraryDim.CreateDimension(Dimension);
        LibraryDim.CreateDimensionValue(DimensionValue, Dimension.Code);
        ApplyDimTo := ApplyDimTo::CurrentLine;

        TextMsg := POSActSaleDimB.AdjustLineDimensions(POSSession, Dimension.Code, DimensionValue.Code, ApplyDimTo, true);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        DimSetEntry.SetRange("Dimension Set ID", SaleLinePOS."Dimension Set ID");
        DimSetEntry.SetRange("Dimension Code", Dimension.Code);
        DimSetEntry.SetRange("Dimension Value Code", DimensionValue.Code);


        Assert.IsTrue(DimSetEntry.FindFirst(), 'Dimension inserted');
        Assert.IsTrue(TextMsg = StrSubstNo(DimSetLbl, Dimension.Code, DimensionValue.Code), 'Dimension inserted Msg generated');
    end;
}