page 6014590 "NPR Vendor Statistics Subpage"
{
    Extensible = False;
    Caption = 'Vendor Statistics Subform';
    Editable = false;
    PageType = List;
    UsageCategory = None;
    SourceTable = Vendor;

    layout
    {
        area(content)
        {
            repeater(Control6150622)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
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

                    trigger OnDrillDown()
                    var
                        ItemLedgEntryStat: Page "NPR Item Ledg Entry Stat.";
                    begin
                        ItemLedgEntryStat.InitFilters(Dim1Filter, Dim2Filter, Periodestart, Periodeslut, LastYear, ItemCategoryFilter, Rec."No.");

                        ItemLedgEntryStat.RunModal();
                    end;
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
                        ValueEntries: Page "NPR Value Entries Sales";
                    begin
                        ValueEntries.InitFilters(Dim1Filter, Dim2Filter, Periodestart, Periodeslut, LastYear, ItemCategoryFilter, Rec."No.");
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
        "Profit %": Decimal;
        "LastYear Profit %": Decimal;
        Dim1Filter: Code[20];
        Dim2Filter: Code[20];
        ItemCategoryFilter: Code[20];
        HideEmpty: Boolean;
        Periodestart: Date;
        Periodeslut: Date;
        LastYear: Boolean;
        CalcLastYear: Text[50];

    internal procedure SetFilter(GlobalDim1: Code[20]; GlobalDim2: Code[20]; DatoStart: Date; DatoEnd: Date; ItemGroup: Code[20]; LastYearCalc: Text[50])
    begin
        //SetFilter()
        if (Dim1Filter <> GlobalDim1) or (Dim2Filter <> GlobalDim2) or (Periodestart <> DatoStart) or
           (Periodeslut <> DatoEnd) or (ItemCategoryFilter <> ItemGroup) then
            ReleaseLock();
        Dim1Filter := GlobalDim1;
        Dim2Filter := GlobalDim2;
        Periodestart := DatoStart;
        Periodeslut := DatoEnd;
        CalcLastYear := LastYearCalc;

        if (ItemGroup = '') and (ItemCategoryFilter <> '') and HideEmpty then begin
            ItemCategoryFilter := ItemGroup;
            HideEmpty := false;
            ChangeEmptyFilter();
        end else begin
            ItemCategoryFilter := ItemGroup;
        end;

        CurrPage.Update();
    end;

    internal procedure Calc()
    var
        ILEByDeptQuery: Query "NPR Sales Statistics By Dept";
        CostAmount: Decimal;
        SalesAmount: Decimal;
    begin
        //Calc()
        SetValueEntryFilter(CostAmount, SalesAmount);
        "Sale Quantity" := 0;
        SetItemLedgerEntryFilter(ILEByDeptQuery, "Sale Quantity", Rec."No.");

        "Sale Amount" := SalesAmount;
        "Profit Amount" := SalesAmount + CostAmount;
        if "Sale Amount" <> 0 then
            "Profit %" := "Profit Amount" / "Sale Amount" * 100
        else
            "Profit %" := 0;

        // Calc last year
        LastYear := true;

        SetValueEntryFilter(CostAmount, SalesAmount);
        "LastYear Sale Quantity" := 0;

        SetItemLedgerEntryFilter(ILEByDeptQuery, "LastYear Sale Quantity", Rec."No.");

        "LastYear Sale Amount" := SalesAmount;
        "LastYear Profit Amount" := SalesAmount + CostAmount;
        if "LastYear Sale Amount" <> 0 then
            "LastYear Profit %" := "LastYear Profit Amount" / "LastYear Sale Amount" * 100
        else
            "LastYear Profit %" := 0;

        LastYear := false;
    end;

    internal procedure SetItemLedgerEntryFilter(var ILEByDeptQuery: Query "NPR Sales Statistics By Dept"; var TotalQuantity: Decimal; VendorFilter: Code[20])
    begin
        //SetItemLedgerEntryFilter
        ILEByDeptQuery.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
        ILEByDeptQuery.SetRange(Filter_Vendor_No, VendorFilter);

        if not LastYear then
            ILEByDeptQuery.SetFilter(Filter_Posting_Date, '%1..%2', Periodestart, Periodeslut)
        else
            ILEByDeptQuery.SetFilter(Filter_Posting_Date, '%1..%2', CalcDate(CalcLastYear, Periodestart), CalcDate(CalcLastYear, Periodeslut));


        if ItemCategoryFilter <> '' then
            ILEByDeptQuery.SetRange(Filter_Item_Category_Code, ItemCategoryFilter)
        else
            ILEByDeptQuery.SetRange(Filter_Item_Category_Code);

        if Dim1Filter <> '' then
            ILEByDeptQuery.SetRange(Filter_Global_Dimension_1_Code, Dim1Filter)
        else
            ILEByDeptQuery.SetRange(Filter_Global_Dimension_1_Code);

        if Dim2Filter <> '' then
            ILEByDeptQuery.SetRange(Filter_Global_Dimension_2_Code, Dim2Filter)
        else
            ILEByDeptQuery.SetRange(Filter_Global_Dimension_2_Code);
        if ILEByDeptQuery.Open() then begin
            while ILEByDeptQuery.Read() do
                TotalQuantity += -ILEByDeptQuery.Quantity;
            ILEByDeptQuery.Close();
        end;
    end;

    internal procedure SetValueEntryFilter(var CostAmount: Decimal; var SalesAmount: Decimal)
    var
        ValueEntryWithVendor: Query "NPR Value Entry With Vendor";
    begin
        ValueEntryWithVendor.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);

        ValueEntryWithVendor.SetRange(Filter_Vendor_No, Rec."No.");
        if not LastYear then
            ValueEntryWithVendor.SetFilter(Filter_DateTime, '%1..%2', Periodestart, Periodeslut)
        else
            ValueEntryWithVendor.SetFilter(Filter_DateTime, '%1..%2', CalcDate(CalcLastYear, Periodestart), CalcDate(CalcLastYear, Periodeslut));

        if ItemCategoryFilter <> '' then
            ValueEntryWithVendor.SetRange(Filter_Item_Category_Code, ItemCategoryFilter)
        else
            ValueEntryWithVendor.SetRange(Filter_Item_Category_Code);

        if Dim1Filter <> '' then
            ValueEntryWithVendor.SetRange(Filter_Dim_1_Code, Dim1Filter)
        else
            ValueEntryWithVendor.SetRange(Filter_Dim_1_Code);

        if Dim2Filter <> '' then
            ValueEntryWithVendor.SetRange(Filter_Dim_2_Code, Dim2Filter)
        else
            ValueEntryWithVendor.SetRange(Filter_Dim_2_Code);

        ValueEntryWithVendor.Open();
        while ValueEntryWithVendor.Read() do begin
            CostAmount += ValueEntryWithVendor.Sum_Cost_Amount_Actual;
            SalesAmount += ValueEntryWithVendor.Sum_Sales_Amount_Actual;
        end;
    end;

    internal procedure ChangeEmptyFilter(): Boolean
    var
        Vendor: Record Vendor;
        ILEByDeptQuery: Query "NPR Sales Statistics By Dept";
        Current: Record Vendor;
        TotalQuantity: Decimal;
        "Count": Integer;
        txtDlg: Label 'Processing Vendor #1######## @2@@@@@@@@';
        Dlg: Dialog;
    begin
        //ChangeEmptyFilter()
        HideEmpty := true;
        Rec.ClearMarks();
        if HideEmpty then begin
            Current := Rec;

            Dlg.Open(txtDlg);
            if Vendor.Find('-') then
                repeat
                    TotalQuantity := 0;
                    Count += 1;
                    Dlg.Update(1, Vendor."No.");
                    Dlg.Update(2, Round(Count / Vendor.Count() * 10000, 1, '='));
                    SetItemLedgerEntryFilter(ILEByDeptQuery, TotalQuantity, Vendor."No.");

                    if TotalQuantity <> 0 then begin
                        Rec.Get(Vendor."No.");
                        Rec.Mark(true);
                    end;
                until Vendor.Next() = 0;
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
        //InitForm()
        Rec.Reset();
        Dim1Filter := '';
        Dim2Filter := '';
        Periodestart := Today();
        Periodeslut := Today();
        ItemCategoryFilter := '';
        HideEmpty := true;
    end;

    internal procedure UpdateHidden()
    begin
        //UpdateHidden()
        if HideEmpty then begin
            HideEmpty := false;
            ChangeEmptyFilter();
            CurrPage.Update();
        end;
    end;

    internal procedure ReleaseLock()
    begin
        //ReleaseLock()
        if Rec.Count() = 0 then begin
            Rec.MarkedOnly(false);
            Rec.ClearMarks();
        end;
    end;

    internal procedure ShowLastYear(Show: Boolean)
    begin
        //CurrPage."LastYear Sale Quantity".VISIBLE( Show );
        //CurrPage."LastYear Sale Amount".VISIBLE( Show );
        //CurrPage."LastYear Profit Amount".VISIBLE( Show );
        //CurrPage."LastYear Profit %".VISIBLE( Show );
        LSQty := Show;
        LSAmount := Show;
        LPA := Show;
        "LP%" := Show;
    end;
}

