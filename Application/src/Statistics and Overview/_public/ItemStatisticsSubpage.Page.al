page 6014588 "NPR Item Statistics Subpage"
{
    Caption = 'Item Statistics Subform';
    Editable = false;
    PageType = List;
    UsageCategory = None;
    SourceTable = Item;

    layout
    {
        area(content)
        {
            repeater(Control6150623)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("-Sale Quantity"; -"Sale Quantity")
                {
                    Caption = 'Sale (QTY)';
                    ToolTip = 'Specifies the value of the Sale (QTY) field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    var
                        ItemledgerEntry: Record "Item Ledger Entry";
                        ItemledgerEntryForm: Page "Item Ledger Entries";
                    begin
                        SetItemLedgerEntryFilter(ItemledgerEntry);
                        ItemledgerEntryForm.SetTableView(ItemledgerEntry);
                        ItemledgerEntryForm.Editable(false);
                        ItemledgerEntryForm.RunModal();
                    end;
                }
                field("-LastYear Sale Quantity"; -"LastYear Sale Quantity")
                {
                    Caption = 'No.';
                    Visible = LSQTY;
                    ToolTip = 'Specifies the value of the No. field';
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
                field("LastYear Sale Amount"; "LastYear Sale Amount")
                {
                    Caption = 'No.';
                    Visible = LSAmount;
                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field("-CostAmt"; -CostAmt)
                {
                    Caption = 'Cost (LCY)';
                    ToolTip = 'Specifies the value of the Cost (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("-Last Year CostAmt"; -"Last Year CostAmt")
                {
                    Caption = 'Last year Cost Amount';
                    Visible = LSAmount;
                    ToolTip = 'Specifies the value of the Last year Cost Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Profit Amount"; "Profit Amount")
                {
                    Caption = 'Profit (LCY)';
                    ToolTip = 'Specifies the value of the Profit (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("LastYear Profit Amount"; "LastYear Profit Amount")
                {
                    Caption = 'Last Year Proifit Amount';
                    Visible = LPA;
                    ToolTip = 'Specifies the value of the Last Year Proifit Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Profit %"; Rec."Profit %")
                {
                    Caption = 'Profit %';
                    ToolTip = 'Specifies the value of the Profit % field';
                    ApplicationArea = NPRRetail;
                }
                field("LastYear Profit %"; "LastYear Profit %")
                {
                    Caption = '-> Last year';
                    Visible = "LP%";
                    ToolTip = 'Specifies the value of the -> Last year field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        Calc();
    end;

    trigger OnOpenPage()
    begin
        if (Periodestart = 0D) then Periodestart := Today();
        if (Periodeslut = 0D) then Periodeslut := Today();
    end;

    var
        LSQty: Boolean;
        LSAmount: Boolean;
        LPA: Boolean;
        "LP%": Boolean;
        "Sale Quantity": Decimal;
        "LastYear Sale Quantity": Decimal;
        "Sale Amount": Decimal;
        "LastYear Sale Amount": Decimal;
        "Profit Amount": Decimal;
        "LastYear Profit Amount": Decimal;
        "LastYear Profit %": Decimal;
        Dim1Filter: Code[20];
        Dim2Filter: Code[20];
        HideEmpty: Boolean;
        Periodestart: Date;
        Periodeslut: Date;
        LastYear: Boolean;
        CalcLastYear: Text[50];
        CostAmt: Decimal;
        "Last Year CostAmt": Decimal;
        ItemCatCodeFilter: Code[20];

    internal procedure SetFilter(GlobalDim1: Code[20]; GlobalDim2: Code[20]; DatoStart: Date; DatoEnd: Date; LastYearCalc: Text[50]; ItemCatCode: Code[20])
    begin
        if (Dim1Filter <> GlobalDim1) or (Dim2Filter <> GlobalDim2) or (Periodestart <> DatoStart) or
             (Periodeslut <> DatoEnd) or (ItemCatCodeFilter <> ItemCatCode) then
            ReleaseLock();
        Dim1Filter := GlobalDim1;
        Dim2Filter := GlobalDim2;
        Periodestart := DatoStart;
        Periodeslut := DatoEnd;
        CalcLastYear := LastYearCalc;
        ItemCatCodeFilter := ItemCatCode;

        if (ItemCatCode = '') and (ItemCatCodeFilter <> '') and HideEmpty then begin
            ItemCatCodeFilter := ItemCatCode;
            HideEmpty := false;
            ChangeEmptyFilter();
        end else begin
            ItemCatCodeFilter := ItemCatCode;
        end;

        CurrPage.Update();
    end;

    internal procedure Calc()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        CostAmount: Decimal;
        SalesAmount: Decimal;
    begin
        CalcCostAndSalesAmountFromVE(CostAmount, SalesAmount);

        SetItemLedgerEntryFilter(ItemLedgerEntry);
        ItemLedgerEntry.CalcSums(Quantity);

        "Sale Quantity" := ItemLedgerEntry.Quantity;
        "Sale Amount" := SalesAmount;
        "Profit Amount" := SalesAmount + CostAmount;
        CostAmt := CostAmount;

        if "Sale Amount" <> 0 then
            Rec."Profit %" := "Profit Amount" / "Sale Amount" * 100
        else
            Rec."Profit %" := 0;

        LastYear := true;

        CalcCostAndSalesAmountFromVE(CostAmount, SalesAmount);

        SetItemLedgerEntryFilter(ItemLedgerEntry);
        ItemLedgerEntry.CalcSums(Quantity);

        "LastYear Sale Quantity" := ItemLedgerEntry.Quantity;
        "LastYear Sale Amount" := SalesAmount;
        "LastYear Profit Amount" := SalesAmount + CostAmount;
        "Last Year CostAmt" := CostAmount;

        if "LastYear Sale Amount" <> 0 then
            "LastYear Profit %" := "LastYear Profit Amount" / "LastYear Sale Amount" * 100
        else
            "LastYear Profit %" := 0;

        LastYear := false;
    end;

    procedure SetItemLedgerEntryFilter(var ItemLedgerEntry: Record "Item Ledger Entry")
    begin
        ItemLedgerEntry.SetCurrentKey("Entry Type", "Posting Date", "Global Dimension 1 Code", "Global Dimension 2 Code");
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Sale);
        ItemLedgerEntry.SetRange("Item No.", Rec."No.");
        if not LastYear then
            ItemLedgerEntry.SetFilter("Posting Date", '%1..%2', Periodestart, Periodeslut)
        else
            ItemLedgerEntry.SetFilter("Posting Date", '%1..%2', CalcDate(CalcLastYear, Periodestart), CalcDate(CalcLastYear, Periodeslut));

        if ItemCatCodeFilter <> '' then
            ItemLedgerEntry.SetRange("Item Category Code", ItemCatCodeFilter)
        else
            ItemLedgerEntry.SetRange("Item Category Code");

        if Dim1Filter <> '' then
            ItemLedgerEntry.SetRange("Global Dimension 1 Code", Dim1Filter)
        else
            ItemLedgerEntry.SetRange("Global Dimension 1 Code");

        if Dim2Filter <> '' then
            ItemLedgerEntry.SetRange("Global Dimension 2 Code", Dim2Filter)
        else
            ItemLedgerEntry.SetRange("Global Dimension 2 Code");
    end;

    internal procedure SetValueEntryFilter(var ValueEntry: Record "Value Entry")
    begin
        ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
        ValueEntry.SetRange("Item No.", Rec."No.");
        if not LastYear then
            ValueEntry.SetFilter("Posting Date", '%1..%2', Periodestart, Periodeslut)
        else
            ValueEntry.SetFilter("Posting Date", '%1..%2', CalcDate(CalcLastYear, Periodestart), CalcDate(CalcLastYear, Periodeslut));

        if Dim1Filter <> '' then
            ValueEntry.SetRange("Global Dimension 1 Code", Dim1Filter)
        else
            ValueEntry.SetRange("Global Dimension 1 Code");

        if Dim2Filter <> '' then
            ValueEntry.SetRange("Global Dimension 2 Code", Dim2Filter)
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
        case ItemCatCodeFilter <> '' of
            true:
                begin
                    ValueEntryWithItemCat.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
                    ValueEntryWithItemCat.SetRange(Filter_Item_No, Rec."No.");
                    if not LastYear then
                        ValueEntryWithItemCat.SetFilter(Filter_DateTime, '%1..%2', Periodestart, Periodeslut)
                    else
                        ValueEntryWithItemCat.SetFilter(Filter_DateTime, '%1..%2', CalcDate(CalcLastYear, Periodestart), CalcDate(CalcLastYear, Periodeslut));

                    ValueEntryWithItemCat.SetRange(Filter_Item_Category_Code, ItemCatCodeFilter);

                    if Dim1Filter <> '' then
                        ValueEntryWithItemCat.SetRange(Filter_Dim_1_Code, Dim1Filter)
                    else
                        ValueEntryWithItemCat.SetRange(Filter_Dim_1_Code);

                    if Dim2Filter <> '' then
                        ValueEntryWithItemCat.SetRange(Filter_Dim_2_Code, Dim2Filter)
                    else
                        ValueEntryWithItemCat.SetRange(Filter_Dim_2_Code);
                    ValueEntryWithItemCat.Open();
                    while ValueEntryWithItemCat.Read() do begin
                        CostAmount += ValueEntryWithItemCat.Sum_Cost_Amount_Actual;
                        SalesAmount += ValueEntryWithItemCat.Sum_Sales_Amount_Actual;
                    end;
                end;
            false:
                begin
                    ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
                    ValueEntry.SetRange("Item No.", Rec."No.");
                    if not LastYear then
                        ValueEntry.SetFilter("Posting Date", '%1..%2', Periodestart, Periodeslut)
                    else
                        ValueEntry.SetFilter("Posting Date", '%1..%2', CalcDate(CalcLastYear, Periodestart), CalcDate(CalcLastYear, Periodeslut));

                    if Dim1Filter <> '' then
                        ValueEntry.SetRange("Global Dimension 1 Code", Dim1Filter)
                    else
                        ValueEntry.SetRange("Global Dimension 1 Code");

                    if Dim2Filter <> '' then
                        ValueEntry.SetRange("Global Dimension 2 Code", Dim2Filter)
                    else
                        ValueEntry.SetRange("Global Dimension 2 Code");
                    ValueEntry.CalcSums("Cost Amount (Actual)", "Sales Amount (Actual)");
                    CostAmount := ValueEntry."Cost Amount (Actual)";
                    SalesAmount := ValueEntry."Sales Amount (Actual)";
                end;
        end;
    end;

    internal procedure ChangeEmptyFilter(): Boolean
    var
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        Current: Record Item;
        "Count": Integer;
        txtDlg: Label 'Processing Item No. #1######## @2@@@@@@@@';
        Dlg: Dialog;
    begin
        HideEmpty := true;

        Rec.ClearMarks();
        if HideEmpty then begin
            Current := Rec;
            Dlg.Open(txtDlg);
            if Item.Find('-') then
                repeat
                    Count += 1;
                    Dlg.Update(1, Item."No.");
                    Dlg.Update(2, Round(Count / Item.Count() * 10000, 1, '='));
                    SetItemLedgerEntryFilter(ItemLedgerEntry);
                    ItemLedgerEntry.SetRange("Item No.", Item."No.");
                    ItemLedgerEntry.CalcSums(Quantity);
                    if ItemLedgerEntry.Quantity <> 0 then begin
                        Rec.Get(Item."No.");
                        Rec.Mark(true);
                    end;
                until Item.Next() = 0;
            Dlg.Close();

            Rec.MarkedOnly(true);
            Rec := Current;
        end else begin
            Rec.MarkedOnly(false);
        end;

        CurrPage.Update();
        exit(HideEmpty);
    end;

    internal procedure InitForm()
    begin
        Rec.Reset();
        Dim1Filter := '';
        Dim2Filter := '';
        Periodestart := Today();
        Periodeslut := Today();
        ItemCatCodeFilter := '';
        HideEmpty := true;
    end;

    internal procedure UpdateHidden()
    begin
        if HideEmpty then begin
            HideEmpty := false;
            ChangeEmptyFilter();
            CurrPage.Update();
        end;
    end;

    internal procedure ReleaseLock()
    begin
        if Rec.Count() = 0 then begin
            Rec.MarkedOnly(false);
            Rec.ClearMarks();
        end;
    end;

    internal procedure ShowLastYear(Show: Boolean)
    begin
        LSQty := Show;
        LSAmount := Show;
        LPA := Show;
        "LP%" := Show;
    end;

    procedure GetGlobals(var InDim1Filter: Code[20]; var InDim2Filter: Code[20]; var InPeriodestart: Date; var InPeriodeslut: Date)
    begin
        InDim1Filter := Dim1Filter;
        InDim2Filter := Dim2Filter;
        InPeriodestart := Periodestart;
        InPeriodeslut := Periodeslut;
    end;
}

