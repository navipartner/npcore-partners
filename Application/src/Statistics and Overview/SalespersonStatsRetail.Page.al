page 6014586 "NPR Salesperson Stats Retail"
{
    Extensible = False;
    Caption = 'Salesperson Statistics';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = None;
    SourceTable = "Salesperson/Purchaser";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("-Sale Quantity"; -"Sale Quantity")
                {

                    Caption = 'Sale (QTY)';
                    ToolTip = 'Specifies the value of the Sale (QTY) field';
                    ApplicationArea = NPRRetail;
                }
                field("-LastYear Sale Quantity"; -"LastYear Sale Quantity")
                {

                    Caption = '-> Last year';
                    Visible = LSQTY;
                    ToolTip = 'Specifies the value of the -> Last year field';
                    ApplicationArea = NPRRetail;
                }
                field("Sale Amount"; "Sale Amount")
                {

                    Caption = 'Sale (LCY)';
                    ToolTip = 'Specifies the value of the Sale (LCY) field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        ValueEntry: Record "Value Entry";
                        ValueEntries: Page "Value Entries";
                    begin
                        SetValueEntryFilter(ValueEntry);
                        ValueEntries.SetTableView(ValueEntry);
                        ValueEntries.Editable(false);
                        ValueEntries.RunModal();
                    end;
                }
                field("<Control61506191>"; -"LastYear Sale Amount")
                {

                    Caption = '-> Last year';
                    Visible = LSAmount;
                    ToolTip = 'Specifies the value of the -> Last year field';
                    ApplicationArea = NPRRetail;
                }
                field("Profit Amount"; "Profit Amount")
                {

                    Caption = 'Profit (LCY)';
                    ToolTip = 'Specifies the value of the Profit (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("-LastYear Profit Amount"; -"LastYear Profit Amount")
                {

                    Caption = '-> Last year';
                    Visible = LPA;
                    ToolTip = 'Specifies the value of the -> Last year field';
                    ApplicationArea = NPRRetail;
                }
                field("<Control61506221>"; "Profit %")
                {

                    Caption = 'Profit %';
                    ToolTip = 'Specifies the value of the Profit % field';
                    ApplicationArea = NPRRetail;
                }
                field("LastYear Profit %"; "LastYear Profit %")
                {

                    Caption = 'Code';
                    Visible = "LP%";
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Calc();
    end;

    trigger OnOpenPage()
    begin
        if (Periodestart = 0D) then
            Periodestart := Today();
        if (Periodeslut = 0D) then
            Periodeslut := Today();
    end;

    var
        "Sale Quantity": Decimal;
        "LastYear Sale Quantity": Decimal;
        "Sale Amount": Decimal;
        "LastYear Sale Amount": Decimal;
        "Profit Amount": Decimal;
        "LastYear Profit Amount": Decimal;
        "Profit %": Decimal;
        "LastYear Profit %": Decimal;
        "Global Dimension 2 Filter": Code[20];
        ItemCategoryFilter: Code[20];
        Periodestart: Date;
        Periodeslut: Date;
        LastYear: Boolean;
        CalcLastYear: Text[50];
        ItemNoFilter: Code[20];
        HideEmpty: Boolean;
        LSQty: Boolean;
        LSAmount: Boolean;
        LPA: Boolean;
        "LP%": Boolean;

    internal procedure SetFilter(GlobalDim1: Code[20]; GlobalDim2: Code[20]; DatoStart: Date; DatoEnd: Date; ItemCategory: Code[20]; LastYearCalc: Text[50]; ItemFilter: Code[20])
    begin
        Rec."NPR Global Dimension 1 Filter" := GlobalDim1;
        "Global Dimension 2 Filter" := GlobalDim2;
        Periodestart := DatoStart;
        Periodeslut := DatoEnd;
        ItemCategoryFilter := ItemCategory;
        CalcLastYear := LastYearCalc;
        ItemNoFilter := ItemFilter;

        CurrPage.Update(false);
    end;

    internal procedure Calc()
    var
        CostAmount: Decimal;
        SalesAmount: Decimal;
        Quantity: Decimal;
    begin
        CalcCostAndSalesAmountFromVE(CostAmount, SalesAmount);

        GetQuantityFromILEQuery(Quantity, '');

        "Sale Quantity" := Quantity;
        "Sale Amount" := SalesAmount;
        "Profit Amount" := SalesAmount + CostAmount;
        if "Sale Amount" <> 0 then
            "Profit %" := "Profit Amount" / "Sale Amount" * 100
        else
            "Profit %" := 0;

        // Calc last year
        LastYear := true;

        CalcCostAndSalesAmountFromVE(CostAmount, SalesAmount);

        GetQuantityFromILEQuery(Quantity, '');

        "LastYear Sale Quantity" := Quantity;
        "LastYear Sale Amount" := SalesAmount;
        "LastYear Profit Amount" := SalesAmount + CostAmount;
        if "LastYear Sale Amount" <> 0 then
            "LastYear Profit %" := "LastYear Profit Amount" / "LastYear Sale Amount" * 100
        else
            "LastYear Profit %" := 0;

        LastYear := false;
    end;

    internal procedure GetQuantityFromILEQuery(var Quantity: Decimal; SalesPersonCodeFilter: Code[20])
    var
        SalesStatisticsByPerson: Query "NPR Sales Statistics By Person";
    begin
        Quantity := 0;
        if SalesPersonCodeFilter <> '' then
            SalesStatisticsByPerson.SetRange(Filter_SalesPers_Purch_Code, SalesPersonCodeFilter)
        else
            SalesStatisticsByPerson.SetRange(Filter_SalesPers_Purch_Code, Rec.Code);
        if not LastYear then
            SalesStatisticsByPerson.SetFilter(Filter_Posting_Date, '%1..%2', Periodestart, Periodeslut)
        else
            SalesStatisticsByPerson.SetFilter(Filter_Posting_Date, '%1..%2', CalcDate(CalcLastYear, Periodestart), CalcDate(CalcLastYear, Periodeslut));

        if ItemCategoryFilter <> '' then
            SalesStatisticsByPerson.SetRange(Filter_Item_Category_Code, ItemCategoryFilter)
        else
            SalesStatisticsByPerson.SetRange(Filter_Item_Category_Code);

        if ItemNoFilter <> '' then
            SalesStatisticsByPerson.SetRange(Filter_Item_No_, ItemNoFilter)
        else
            SalesStatisticsByPerson.SetRange(Filter_Item_No_);

        if Rec."NPR Global Dimension 1 Filter" <> '' then
            SalesStatisticsByPerson.SetRange(Filter_Global_Dimension_1_Code, Rec."NPR Global Dimension 1 Filter")
        else
            SalesStatisticsByPerson.SetRange(Filter_Global_Dimension_1_Code);

        if "Global Dimension 2 Filter" <> '' then
            SalesStatisticsByPerson.SetRange(Filter_Global_Dimension_2_Code, "Global Dimension 2 Filter")
        else
            SalesStatisticsByPerson.SetRange(Filter_Global_Dimension_2_Code);
        SalesStatisticsByPerson.Open();
        while SalesStatisticsByPerson.Read() do
            Quantity := SalesStatisticsByPerson.Quantity;
    end;

    internal procedure SetValueEntryFilter(var ValueEntry: Record "Value Entry")
    begin
        ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
        ValueEntry.SetRange("Salespers./Purch. Code", Rec.Code);
        if not LastYear then
            ValueEntry.SetFilter("Posting Date", '%1..%2', Periodestart, Periodeslut)
        else
            ValueEntry.SetFilter("Posting Date", '%1..%2', CalcDate(CalcLastYear, Periodestart), CalcDate(CalcLastYear, Periodeslut));

        if ItemNoFilter <> '' then
            ValueEntry.SetRange("Item No.", ItemNoFilter)
        else
            ValueEntry.SetRange("Item No.");

        if Rec."NPR Global Dimension 1 Filter" <> '' then
            ValueEntry.SetRange("Global Dimension 1 Code", Rec."NPR Global Dimension 1 Filter")
        else
            ValueEntry.SetRange("Global Dimension 1 Code");

        if "Global Dimension 2 Filter" <> '' then
            ValueEntry.SetRange("Global Dimension 2 Code", "Global Dimension 2 Filter")
        else
            ValueEntry.SetRange("Global Dimension 2 Code");
    end;

    internal procedure CalcCostAndSalesAmountFromVE(var CostAmount: Decimal; var SalesAmount: Decimal)
    var
        ValueEntry: Record "Value Entry";
        ValueEntryWithItemCat: Query "NPR Value Entry With Item Cat";
    begin
        Clear(CostAmount);
        Clear(SalesAmount);
        case ItemCategoryFilter <> '' of
            true:
                begin
                    ValueEntryWithItemCat.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
                    ValueEntryWithItemCat.SetRange(Filter_Sales_Person, Rec.Code);
                    if not LastYear then
                        ValueEntryWithItemCat.SetFilter(Filter_DateTime, '%1..%2', Periodestart, Periodeslut)
                    else
                        ValueEntryWithItemCat.SetFilter(Filter_DateTime, '%1..%2', CalcDate(CalcLastYear, Periodestart), CalcDate(CalcLastYear, Periodeslut));

                    if ItemNoFilter <> '' then
                        ValueEntryWithItemCat.SetRange(Filter_Item_No, ItemNoFilter)
                    else
                        ValueEntryWithItemCat.SetRange(Filter_Item_No);

                    if ItemCategoryFilter <> '' then
                        ValueEntryWithItemCat.SetRange(Filter_Item_Category_Code, ItemCategoryFilter)
                    else
                        ValueEntryWithItemCat.SetRange(Filter_Item_Category_Code);

                    if Rec."NPR Global Dimension 1 Filter" <> '' then
                        ValueEntryWithItemCat.SetRange(Filter_Dim_1_Code, Rec."NPR Global Dimension 1 Filter")
                    else
                        ValueEntryWithItemCat.SetRange(Filter_Dim_1_Code);

                    if "Global Dimension 2 Filter" <> '' then
                        ValueEntryWithItemCat.SetRange(Filter_Dim_2_Code, "Global Dimension 2 Filter")
                    else
                        ValueEntryWithItemCat.SetRange(Filter_Dim_2_Code);
                    ValueEntryWithItemCat.Open();
                    while ValueEntryWithItemCat.Read() do begin
                        SalesAmount += ValueEntryWithItemCat.Sum_Sales_Amount_Actual;
                        CostAmount += ValueEntryWithItemCat.Sum_Cost_Amount_Actual;
                    end;
                end;
            false:
                begin
                    ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
                    ValueEntry.SetRange("Salespers./Purch. Code", Rec.Code);
                    if not LastYear then
                        ValueEntry.SetFilter("Posting Date", '%1..%2', Periodestart, Periodeslut)
                    else
                        ValueEntry.SetFilter("Posting Date", '%1..%2', CalcDate(CalcLastYear, Periodestart), CalcDate(CalcLastYear, Periodeslut));

                    if ItemNoFilter <> '' then
                        ValueEntry.SetRange("Item No.", ItemNoFilter)
                    else
                        ValueEntry.SetRange("Item No.");

                    if Rec."NPR Global Dimension 1 Filter" <> '' then
                        ValueEntry.SetRange("Global Dimension 1 Code", Rec."NPR Global Dimension 1 Filter")
                    else
                        ValueEntry.SetRange("Global Dimension 1 Code");

                    if "Global Dimension 2 Filter" <> '' then
                        ValueEntry.SetRange("Global Dimension 2 Code", "Global Dimension 2 Filter")
                    else
                        ValueEntry.SetRange("Global Dimension 2 Code");
                    ValueEntry.CalcSums("Cost Amount (Actual)", "Sales Amount (Actual)");
                    CostAmount := ValueEntry."Cost Amount (Actual)";
                    SalesAmount := ValueEntry."Sales Amount (Actual)";
                end;
        end;
    end;

    internal procedure InitForm()
    begin
        Rec.Reset();
        Rec."NPR Global Dimension 1 Filter" := '';
        "Global Dimension 2 Filter" := '';
        Periodestart := Today();
        Periodeslut := Today();
        ItemCategoryFilter := '';
    end;

    internal procedure ShowLastYear(Show: Boolean)
    begin
        LSQty := Show;
        LSAmount := Show;
        LPA := Show;
        "LP%" := Show;
    end;

    internal procedure ChangeEmptyFilter(): Boolean
    var
        Current: Record "Salesperson/Purchaser";
        "Count": Integer;
        Dlg: Dialog;
        SalesPerson: Record "Salesperson/Purchaser";
        txtDlg: Label 'Processing SalesPerson #1######## @2@@@@@@@@';
        Quantity: Decimal;
    begin
        HideEmpty := not HideEmpty;

        Rec.ClearMarks();
        if HideEmpty then begin
            Current := Rec;
            Dlg.Open(txtDlg);
            if SalesPerson.FindSet() then
                repeat
                    Count += 1;

                    Dlg.Update(1, SalesPerson.Name);
                    Dlg.Update(2, Round(Count / SalesPerson.Count() * 10000, 1, '='));
                    GetQuantityFromILEQuery(Quantity, SalesPerson.Code);
                    if Quantity <> 0 then begin
                        Rec.Get(SalesPerson.Code);
                        Rec.Mark(true);
                    end;
                until SalesPerson.Next() = 0;
            Dlg.Close();

            Rec.MarkedOnly(true);
            Rec := Current;
        end else begin
            Rec.MarkedOnly(false);
        end;

        CurrPage.Update(false);

        exit(HideEmpty);
    end;
}

