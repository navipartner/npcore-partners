codeunit 85338 "NPR Retail Report Test Lib"
{
    Access = Internal;

    var
        _NextItemLedgerEntryNo: Integer;
        _NextValueEntryNo: Integer;
        _Prefix: Code[10];

    #region Fixture primitives

    procedure Initialize()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
    begin
        if ItemLedgerEntry.FindLast() then
            _NextItemLedgerEntryNo := ItemLedgerEntry."Entry No." + 1
        else
            _NextItemLedgerEntryNo := 1;

        if ValueEntry.FindLast() then
            _NextValueEntryNo := ValueEntry."Entry No." + 1
        else
            _NextValueEntryNo := 1;

        _Prefix := CopyStr('T' + Format(_NextItemLedgerEntryNo), 1, MaxStrLen(_Prefix));
    end;

    procedure MakeCode(Suffix: Text): Code[20]
    begin
        exit(CopyStr(_Prefix + '-' + Suffix, 1, 20));
    end;

    procedure DateRangeFilter(FromDate: Date; ToDate: Date): Text
    begin
        exit(Format(FromDate) + '..' + Format(ToDate));
    end;

    procedure CreateItem(Suffix: Text; Description: Text; LastDirectCost: Decimal; IndirectCostPct: Decimal): Code[20]
    var
        Item: Record Item;
    begin
        Item.Init();
        Item."No." := MakeCode(Suffix);
        Item.Description := CopyStr(Description, 1, MaxStrLen(Item.Description));
        Item."Last Direct Cost" := LastDirectCost;
        Item."Indirect Cost %" := IndirectCostPct;
        Item.Insert();
        exit(Item."No.");
    end;

    procedure SetItemCategory(ItemNo: Code[20]; ItemCategoryCode: Code[20])
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        Item."Item Category Code" := ItemCategoryCode;
        Item.Modify();
    end;

    procedure CreateDepartment(Suffix: Text; Name: Text): Code[20]
    var
        DimensionValue: Record "Dimension Value";
    begin
        DimensionValue.Init();
        DimensionValue."Dimension Code" := GlobalDimension1Code();
        DimensionValue.Code := MakeCode(Suffix);
        DimensionValue.Name := CopyStr(Name, 1, MaxStrLen(DimensionValue.Name));
        DimensionValue."Global Dimension No." := 1;
        DimensionValue.Insert();
        exit(DimensionValue.Code);
    end;

    procedure CreateItemCategory(Suffix: Text; ParentCategoryCode: Code[20]; Indentation: Integer): Code[20]
    var
        ItemCategory: Record "Item Category";
    begin
        ItemCategory.Init();
        ItemCategory.Code := MakeCode(Suffix);
        ItemCategory.Description := ItemCategory.Code;
        ItemCategory."Parent Category" := ParentCategoryCode;
        ItemCategory.Indentation := Indentation;
        ItemCategory.Insert();
        exit(ItemCategory.Code);
    end;

    procedure DeleteItemCategory(ItemCategoryCode: Code[20])
    var
        ItemCategory: Record "Item Category";
    begin
        ItemCategory.Get(ItemCategoryCode);
        ItemCategory.Delete();
    end;

    procedure InsertSale(ItemNo: Code[20]; PostingDate: Date; DepartmentCode: Code[20]; ItemCategoryCode: Code[20]; LedgerQuantity: Decimal; InvoicedQuantity: Decimal; SalesAmountActual: Decimal; CostAmountActual: Decimal): Integer
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
    begin
        ItemLedgerEntry.Init();
        ItemLedgerEntry."Entry No." := NextItemLedgerEntryNo();
        ItemLedgerEntry."Entry Type" := ItemLedgerEntry."Entry Type"::Sale;
        ItemLedgerEntry."Item No." := ItemNo;
        ItemLedgerEntry."Posting Date" := PostingDate;
        ItemLedgerEntry."Global Dimension 1 Code" := DepartmentCode;
        ItemLedgerEntry."Item Category Code" := ItemCategoryCode;
        ItemLedgerEntry.Quantity := LedgerQuantity;
        ItemLedgerEntry."Invoiced Quantity" := InvoicedQuantity;
        ItemLedgerEntry.Insert();

        ValueEntry.Init();
        ValueEntry."Entry No." := NextValueEntryNo();
        ValueEntry."Item Ledger Entry No." := ItemLedgerEntry."Entry No.";
        ValueEntry."Item Ledger Entry Type" := ValueEntry."Item Ledger Entry Type"::Sale;
        ValueEntry."Entry Type" := ValueEntry."Entry Type"::"Direct Cost";
        ValueEntry."Posting Date" := PostingDate;
        ValueEntry."Item No." := ItemNo;
        ValueEntry."Global Dimension 1 Code" := DepartmentCode;
        ValueEntry."Valued Quantity" := InvoicedQuantity;
        ValueEntry."Item Ledger Entry Quantity" := LedgerQuantity;
        ValueEntry."Invoiced Quantity" := InvoicedQuantity;
        ValueEntry."Sales Amount (Actual)" := SalesAmountActual;
        ValueEntry."Cost Amount (Actual)" := CostAmountActual;
        ValueEntry.Insert();

        exit(ItemLedgerEntry."Entry No.");
    end;

    procedure InsertPurchase(ItemNo: Code[20]; PostingDate: Date; DepartmentCode: Code[20]; Quantity: Decimal; PurchaseAmountActual: Decimal): Integer
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
    begin
        ItemLedgerEntry.Init();
        ItemLedgerEntry."Entry No." := NextItemLedgerEntryNo();
        ItemLedgerEntry."Entry Type" := ItemLedgerEntry."Entry Type"::Purchase;
        ItemLedgerEntry."Item No." := ItemNo;
        ItemLedgerEntry."Posting Date" := PostingDate;
        ItemLedgerEntry."Global Dimension 1 Code" := DepartmentCode;
        ItemLedgerEntry.Quantity := Quantity;
        ItemLedgerEntry."Invoiced Quantity" := Quantity;
        ItemLedgerEntry.Insert();

        ValueEntry.Init();
        ValueEntry."Entry No." := NextValueEntryNo();
        ValueEntry."Item Ledger Entry No." := ItemLedgerEntry."Entry No.";
        ValueEntry."Item Ledger Entry Type" := ValueEntry."Item Ledger Entry Type"::Purchase;
        ValueEntry."Entry Type" := ValueEntry."Entry Type"::"Direct Cost";
        ValueEntry."Posting Date" := PostingDate;
        ValueEntry."Item No." := ItemNo;
        ValueEntry."Global Dimension 1 Code" := DepartmentCode;
        ValueEntry."Valued Quantity" := Quantity;
        ValueEntry."Item Ledger Entry Quantity" := Quantity;
        ValueEntry."Invoiced Quantity" := Quantity;
        ValueEntry."Purchase Amount (Actual)" := PurchaseAmountActual;
        ValueEntry.Insert();

        exit(ItemLedgerEntry."Entry No.");
    end;

    procedure InsertSaleCostAdjustment(ItemLedgerEntryNo: Integer; ItemNo: Code[20]; PostingDate: Date; DepartmentCode: Code[20]; CostAmountActual: Decimal)
    var
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.Init();
        ValueEntry."Entry No." := NextValueEntryNo();
        ValueEntry."Item Ledger Entry No." := ItemLedgerEntryNo;
        ValueEntry."Item Ledger Entry Type" := ValueEntry."Item Ledger Entry Type"::Sale;
        ValueEntry."Entry Type" := ValueEntry."Entry Type"::"Direct Cost";
        ValueEntry."Posting Date" := PostingDate;
        ValueEntry."Item No." := ItemNo;
        ValueEntry."Global Dimension 1 Code" := DepartmentCode;
        ValueEntry."Cost Amount (Actual)" := CostAmountActual;
        ValueEntry.Insert();
    end;

    procedure InsertSaleValueEntry(ItemLedgerEntryNo: Integer; ItemNo: Code[20]; PostingDate: Date; DepartmentCode: Code[20]; ItemLedgerEntryQuantity: Decimal; SalesAmountActual: Decimal; CostAmountActual: Decimal)
    var
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.Init();
        ValueEntry."Entry No." := NextValueEntryNo();
        ValueEntry."Item Ledger Entry No." := ItemLedgerEntryNo;
        ValueEntry."Item Ledger Entry Type" := ValueEntry."Item Ledger Entry Type"::Sale;
        ValueEntry."Entry Type" := ValueEntry."Entry Type"::"Direct Cost";
        ValueEntry."Posting Date" := PostingDate;
        ValueEntry."Item No." := ItemNo;
        ValueEntry."Global Dimension 1 Code" := DepartmentCode;
        ValueEntry."Item Ledger Entry Quantity" := ItemLedgerEntryQuantity;
        ValueEntry."Sales Amount (Actual)" := SalesAmountActual;
        ValueEntry."Cost Amount (Actual)" := CostAmountActual;
        ValueEntry.Insert();
    end;

    procedure SetLocationCode(ItemLedgerEntryNo: Integer; LocationCode: Code[10])
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
    begin
        ItemLedgerEntry.Get(ItemLedgerEntryNo);
        ItemLedgerEntry."Location Code" := LocationCode;
        ItemLedgerEntry.Modify();

        ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntryNo);
        if ValueEntry.FindSet() then
            repeat
                ValueEntry."Location Code" := LocationCode;
                ValueEntry.Modify();
            until ValueEntry.Next() = 0;
    end;

    procedure FindSaleEntryNo(ItemNo: Code[20]; PostingDate: Date; ItemCategoryCode: Code[20]): Integer
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Sale);
        ItemLedgerEntry.SetRange("Posting Date", PostingDate);
        ItemLedgerEntry.SetRange("Item Category Code", ItemCategoryCode);
        ItemLedgerEntry.FindFirst();
        exit(ItemLedgerEntry."Entry No.");
    end;

    local procedure GlobalDimension1Code(): Code[20]
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        Dimension: Record Dimension;
    begin
        if not GeneralLedgerSetup.Get() then
            GeneralLedgerSetup.Insert();

        if GeneralLedgerSetup."Global Dimension 1 Code" <> '' then
            exit(GeneralLedgerSetup."Global Dimension 1 Code");

        Dimension.Init();
        Dimension.Code := MakeCode('DIM1');
        Dimension.Name := Dimension.Code;
        Dimension.Insert();

        GeneralLedgerSetup."Global Dimension 1 Code" := Dimension.Code;
        GeneralLedgerSetup.Modify();
        exit(Dimension.Code);
    end;

    local procedure NextItemLedgerEntryNo(): Integer
    begin
        _NextItemLedgerEntryNo += 1;
        exit(_NextItemLedgerEntryNo - 1);
    end;

    local procedure NextValueEntryNo(): Integer
    begin
        _NextValueEntryNo += 1;
        exit(_NextValueEntryNo - 1);
    end;

    #endregion

    #region Fixture A - report 6014427

    procedure CreateFixtureA(var Codes: Dictionary of [Text, Code[20]])
    var
        Rest1: Code[20];
        Rest2: Code[20];
        Burger: Code[20];
        Cola: Code[20];
        Napkin: Code[20];
        Souvenir: Code[20];
        Sundae: Code[20];
        Water: Code[20];
    begin
        Initialize();
        Clear(Codes);

        Rest1 := CreateDepartment('R1', 'Food Court');
        Rest2 := CreateDepartment('R2', 'Harbor Grill');

        Burger := CreateItem('10010', 'BURGER', 10.0, 10);
        Cola := CreateItem('10020', 'COLA', 5.0, 0);
        Napkin := CreateItem('10040', 'NAPKIN', 2.0, 0);
        Souvenir := CreateItem('10050', 'SOUVENIR', 3.0, 0);
        Sundae := CreateItem('10060', 'SUNDAE', 6.0, 0);
        Water := CreateItem('10070', 'WATER', 4.0, 0);

        InsertPurchase(Burger, 20251201D, Rest1, 100, 1000.0);
        InsertPurchase(Burger, 20260215D, Rest1, 100, 1000.0);
        InsertSale(Burger, 20260110D, Rest1, '', -20, -20, 500.0, -200.0);
        InsertSale(Burger, 20260605D, Rest1, '', -60, -60, 1500.0, -600.0);

        InsertPurchase(Cola, 20251201D, Rest1, 100, 500.0);
        InsertPurchase(Cola, 20251201D, Rest2, 100, 500.0);
        InsertSale(Cola, 20260608D, Rest1, '', -40, -40, 600.0, -200.0);
        InsertSale(Cola, 20260608D, Rest2, '', -10, -10, 150.0, -50.0);

        InsertPurchase(Napkin, 20251201D, Rest1, 50, 100.0);
        InsertSale(Napkin, 20260612D, Rest1, '', -5, -5, 0.0, -10.0);

        InsertSale(Souvenir, 20260609D, Rest1, '', -10, -10, 150.0, 0.0);

        InsertPurchase(Sundae, 20251201D, Rest1, 40, 240.0);
        InsertSale(Sundae, 20260620D, Rest1, '', 15, 15, -225.0, 90.0);

        InsertPurchase(Water, 20251201D, Rest1, 30, 120.0);

        Codes.Set('REST1', Rest1);
        Codes.Set('REST2', Rest2);
        Codes.Set('BURGER', Burger);
        Codes.Set('COLA', Cola);
        Codes.Set('NAPKIN', Napkin);
        Codes.Set('SOUVENIR', Souvenir);
        Codes.Set('SUNDAE', Sundae);
        Codes.Set('WATER', Water);
    end;

    procedure CreatePerfItems(Suffix: Text; ItemCount: Integer; DepartmentCode: Code[20]) ItemNoFilter: Text
    var
        ItemNo: Code[20];
        Index: Integer;
    begin
        for Index := 1 to ItemCount do begin
            ItemNo := CreateItem(Suffix + '-' + Format(Index), 'PERF', 10.0, 0);
            InsertPurchase(ItemNo, 20251201D, DepartmentCode, 100, 1000.0);
            InsertSale(ItemNo, 20260615D, DepartmentCode, '', -10, -10, 250.0, -100.0);
        end;
        exit(MakeCode(Suffix) + '*');
    end;

    #endregion

    #region Fixture B - report 6014420

    procedure CreateFixtureB(var Codes: Dictionary of [Text, Code[20]])
    var
        Rest1: Code[20];
        Rest2: Code[20];
        Rest3: Code[20];
        Food: Code[20];
        HotFood: Code[20];
        Burgers: Code[20];
        HotDogs: Code[20];
        Drinks: Code[20];
        Snacks: Code[20];
        Sides: Code[20];
        IceCream: Code[20];
        ItemNo: Code[20];
    begin
        Initialize();
        Clear(Codes);

        Rest1 := CreateDepartment('R1', 'Food Court');
        Rest2 := CreateDepartment('R2', 'Harbor Grill');
        Rest3 := CreateDepartment('R3', 'Winter Bar');

        Food := CreateItemCategory('FOOD', '', 0);
        HotFood := CreateItemCategory('HOTFOOD', Food, 1);
        Burgers := CreateItemCategory('BURGERS', HotFood, 2);
        HotDogs := CreateItemCategory('HOTDOGS', HotFood, 2);
        Drinks := CreateItemCategory('DRINKS', '', 0);
        Snacks := CreateItemCategory('SNACKS', '', 0);
        Sides := CreateItemCategory('SIDES', '', 0);
        IceCream := CreateItemCategory('ICECREAM', '', 0);

        ItemNo := CreateItem('ITEM', 'FIXTURE B', 10.0, 0);

        InsertSale(ItemNo, 20260610D, Rest1, Burgers, -100, -100, 2000.0, -1200.0);
        InsertSale(ItemNo, 20260610D, Rest1, HotDogs, -50, -50, 1000.0, -400.0);
        InsertSale(ItemNo, 20260610D, Rest1, Drinks, -200, -200, 3100.0, -930.0);
        InsertSale(ItemNo, 20260610D, Rest1, Snacks, -25, -25, 500.0, -250.0);
        InsertSale(ItemNo, 20260610D, Rest1, '', -10, -10, 150.0, -60.0);
        InsertSale(ItemNo, 20260610D, Rest1, Sides, -20, -20, 0.0, -80.0);
        InsertSale(ItemNo, 20260610D, Rest1, IceCream, -5, -5, 100.0, -40.0);
        InsertSale(ItemNo, 20260620D, Rest1, IceCream, 10, 10, -250.0, 80.0);

        InsertSale(ItemNo, 20260610D, Rest2, Drinks, -30, -30, 450.0, -150.0);

        InsertSale(ItemNo, 20260512D, Rest3, Drinks, -40, -40, 600.0, -200.0);

        Codes.Set('REST1', Rest1);
        Codes.Set('REST2', Rest2);
        Codes.Set('REST3', Rest3);
        Codes.Set('FOOD', Food);
        Codes.Set('HOTFOOD', HotFood);
        Codes.Set('BURGERS', Burgers);
        Codes.Set('HOTDOGS', HotDogs);
        Codes.Set('DRINKS', Drinks);
        Codes.Set('SNACKS', Snacks);
        Codes.Set('SIDES', Sides);
        Codes.Set('ICECREAM', IceCream);
        Codes.Set('ITEM', ItemNo);
    end;

    procedure CreatePerfSections(Suffix: Text; DepartmentCount: Integer; GroupsPerDepartment: Integer; ItemNo: Code[20]; ItemCategoryCodes: List of [Code[20]]) DepartmentFilter: Text
    var
        DepartmentCode: Code[20];
        DepartmentIndex: Integer;
        GroupIndex: Integer;
    begin
        for DepartmentIndex := 1 to DepartmentCount do begin
            DepartmentCode := CreateDepartment(Suffix + '-' + Format(DepartmentIndex), 'PERF');
            for GroupIndex := 1 to GroupsPerDepartment do
                InsertSale(ItemNo, 20260615D, DepartmentCode, ItemCategoryCodes.Get(GroupIndex), -10, -10, 250.0, -100.0);
        end;
        exit(MakeCode(Suffix) + '*');
    end;

    #endregion

    #region Dataset readers

    procedure RunReportAndLoad(ReportId: Integer; var LibraryReportDataset: Codeunit "Library - Report Dataset")
    var
        TempBlob: Codeunit "Temp Blob";
        DataSetInStream: InStream;
        DataSetOutStream: OutStream;
        XmlParameters: Text;
    begin
        Commit();
        XmlParameters := Report.RunRequestPage(ReportId);
        TempBlob.CreateOutStream(DataSetOutStream, TextEncoding::UTF8);
        Report.SaveAs(ReportId, XmlParameters, ReportFormat::Xml, DataSetOutStream);
        TempBlob.CreateInStream(DataSetInStream, TextEncoding::UTF8);
        LibraryReportDataset.LoadFromInStream(DataSetInStream);
    end;

    procedure RowText(var LibraryReportDataset: Codeunit "Library - Report Dataset"; ElementName: Text): Text
    var
        Value: Variant;
    begin
        if not LibraryReportDataset.CurrentRowHasElement(ElementName) then
            exit('');
        LibraryReportDataset.FindCurrentRowValue(ElementName, Value);
        exit(Format(Value));
    end;

    procedure RowDecimal(var LibraryReportDataset: Codeunit "Library - Report Dataset"; ElementName: Text) Result: Decimal
    var
        ValueText: Text;
    begin
        ValueText := RowText(LibraryReportDataset, ElementName);
        if ValueText = '' then
            exit(0);
        if Evaluate(Result, ValueText, 9) then
            exit(Result);
        Evaluate(Result, ValueText);
    end;

    procedure RowInteger(var LibraryReportDataset: Codeunit "Library - Report Dataset"; ElementName: Text) Result: Integer
    var
        ValueText: Text;
    begin
        ValueText := RowText(LibraryReportDataset, ElementName);
        if ValueText = '' then
            exit(0);
        if Evaluate(Result, ValueText) then;
    end;

    procedure RowBoolean(var LibraryReportDataset: Codeunit "Library - Report Dataset"; ElementName: Text): Boolean
    var
        ValueText: Text;
    begin
        ValueText := LowerCase(RowText(LibraryReportDataset, ElementName));
        exit((ValueText = 'true') or (ValueText = 'yes') or (ValueText = '1'));
    end;

    procedure MoveToRowWithValue(var LibraryReportDataset: Codeunit "Library - Report Dataset"; ElementName: Text; ElementValue: Text): Boolean
    begin
        LibraryReportDataset.Reset();
        while LibraryReportDataset.GetNextRow() do
            if RowText(LibraryReportDataset, ElementName) = ElementValue then
                exit(true);
        exit(false);
    end;

    procedure DatasetSum(var LibraryReportDataset: Codeunit "Library - Report Dataset"; ElementName: Text) Total: Decimal
    begin
        LibraryReportDataset.Reset();
        while LibraryReportDataset.GetNextRow() do
            Total += RowDecimal(LibraryReportDataset, ElementName);
    end;

    procedure VisibleItemNos(var LibraryReportDataset: Codeunit "Library - Report Dataset") ItemNos: Text
    begin
        LibraryReportDataset.Reset();
        while LibraryReportDataset.GetNextRow() do
            if RowBoolean(LibraryReportDataset, 'ShowSection1') then begin
                if ItemNos <> '' then
                    ItemNos += '|';
                ItemNos += RowText(LibraryReportDataset, 'No_Item');
            end;
    end;

    procedure SectionCodes(var LibraryReportDataset: Codeunit "Library - Report Dataset") DepartmentCodes: Text
    var
        DepartmentCode: Text;
    begin
        LibraryReportDataset.Reset();
        while LibraryReportDataset.GetNextRow() do begin
            DepartmentCode := RowText(LibraryReportDataset, 'Code_DimensionValue');
            if (DepartmentCode <> '') and (RowText(LibraryReportDataset, 'Code') <> '') and (not DepartmentCodes.Contains(DepartmentCode)) then begin
                if DepartmentCodes <> '' then
                    DepartmentCodes += '|';
                DepartmentCodes += DepartmentCode;
            end;
        end;
    end;

    procedure SectionTotal(var LibraryReportDataset: Codeunit "Library - Report Dataset"; DepartmentCode: Code[20]; ElementName: Text): Decimal
    begin
        if MoveToRowWithValue(LibraryReportDataset, 'Code_DimensionValue', DepartmentCode) then
            exit(RowDecimal(LibraryReportDataset, ElementName));
        exit(0);
    end;

    procedure LoadSectionLines(var LibraryReportDataset: Codeunit "Library - Report Dataset"; DepartmentCode: Code[20]; var TempItemCategoryBuffer: Record "NPR Item Category Buffer" temporary)
    begin
        TempItemCategoryBuffer.Reset();
        TempItemCategoryBuffer.DeleteAll();

        LibraryReportDataset.Reset();
        while LibraryReportDataset.GetNextRow() do
            if (RowText(LibraryReportDataset, 'Code_DimensionValue') = DepartmentCode) and (RowText(LibraryReportDataset, 'Code') <> '') then begin
                TempItemCategoryBuffer.Init();
                TempItemCategoryBuffer."Entry No." := RowInteger(LibraryReportDataset, 'Presentation_Order');
                TempItemCategoryBuffer.Code := CopyStr(RowText(LibraryReportDataset, 'Code'), 1, MaxStrLen(TempItemCategoryBuffer.Code));
                TempItemCategoryBuffer."Code with Indentation" := CopyStr(RowText(LibraryReportDataset, 'CodeWithIndentation'), 1, MaxStrLen(TempItemCategoryBuffer."Code with Indentation"));
                TempItemCategoryBuffer.Description := CopyStr(RowText(LibraryReportDataset, 'Description'), 1, MaxStrLen(TempItemCategoryBuffer.Description));
                TempItemCategoryBuffer."Parent Category" := CopyStr(RowText(LibraryReportDataset, 'ParentCategory'), 1, MaxStrLen(TempItemCategoryBuffer."Parent Category"));
                TempItemCategoryBuffer.Indentation := RowInteger(LibraryReportDataset, 'Indentation');
                TempItemCategoryBuffer."Order No." := RowInteger(LibraryReportDataset, 'OrderNo');
                TempItemCategoryBuffer."Calc Field 1" := RowDecimal(LibraryReportDataset, 'Quantity');
                TempItemCategoryBuffer."Calc Field 2" := RowDecimal(LibraryReportDataset, 'SalesLCY');
                TempItemCategoryBuffer."Calc Field 3" := RowDecimal(LibraryReportDataset, 'ProfitLCY');
                TempItemCategoryBuffer."Calc Field 4" := RowDecimal(LibraryReportDataset, 'ProfitPerc');
                TempItemCategoryBuffer.Insert();
            end;
    end;

    procedure PrintedLineOrder(var TempItemCategoryBuffer: Record "NPR Item Category Buffer" temporary) LineOrder: Text
    begin
        TempItemCategoryBuffer.Reset();
        if not TempItemCategoryBuffer.FindSet() then
            exit('');

        repeat
            if LineOrder <> '' then
                LineOrder += ' ';
            LineOrder += TempItemCategoryBuffer.Code;
            if TempItemCategoryBuffer."Order No." <> 0 then
                LineOrder += '(' + Format(TempItemCategoryBuffer."Order No.") + ')';
        until TempItemCategoryBuffer.Next() = 0;
    end;

    procedure Indented(ItemCategoryCode: Code[20]; Indentation: Integer): Text
    begin
        exit(PadStr('', Indentation * 4, ' ') + ItemCategoryCode);
    end;

    #endregion
}
