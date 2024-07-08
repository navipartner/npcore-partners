report 6014490 "NPR Advanced Sales Stat."
{
#IF NOT BC17
    Extensible = False;
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Advanced Sales Statistics.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'Advanced Sales Statistics';
    UseSystemPrinter = true;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number) ORDER(Ascending) WHERE(Number = FILTER(0 ..));
            column(COMPANYNAME; CompanyName)
            {
            }
            column(Title; Title)
            {
            }
            column(Dim1Filter; Dim1Filter)
            {
            }
            column(Dim2Filter; Dim2Filter)
            {
            }
            column(ItemCategoryFilter; ItemCategoryFilter)
            {
            }
            column(PeriodeFilter; PeriodeFilter)
            {
            }
            column(PeriodFilters; PeriodFilters)
            {
            }
            column(Periodestart; PeriodStart)
            {
            }
            column(Periodeslut; PeriodEnd)
            {
            }
            column(FiltersTextLbl; FiltersTextLbl)
            {
            }
            column(FiltersText; FiltersText)
            {
            }
            column(Periodstart; PeriodStart)
            {
            }
            column(Periodend; PeriodEnd)
            {
            }
            column(Number_Integer; Integer.Number)
            {
            }
            column(No_Buffer; TempBuffer."No.")
            {
            }
            column(Description_Buffer; TempBuffer.Description)
            {
            }
            column(Sales_Qty_Buffer; TempBuffer."Sales qty." * -1)
            {
            }
            column(Sales_Qty_LastYr_Buffer; TempBuffer."Sales qty. last year" * -1)
            {
            }
            column(Sales_LCY_Buffer; TempBuffer."Sales LCY")
            {
            }
            column(Sales_LCY_LastYr_Buffer; TempBuffer."Sales LCY last year")
            {
            }
            column(Profit_LCY_Buffer; TempBuffer."Profit LCY")
            {
            }
            column(Profit_LCY_LastYr_Buffer; TempBuffer."Profit LCY last year")
            {
            }
            column(Profit_Pct_Buffer; TempBuffer."Profit %")
            {
            }
            column(Profit_Pct_LastYr_Buffer; TempBuffer."Profit % last year")
            {
            }
            column(Totals_1; Totals[1] * -1)
            {
            }
            column(Totals_2; Totals[2] * -1)
            {
            }
            column(Totals_3; Totals[3])
            {
            }
            column(Totals_4; Totals[4])
            {
            }
            column(Totals_5; Totals[5])
            {
            }
            column(Totals_6; Totals[6])
            {
            }
            column(Totals_7; Totals[7])
            {
            }
            column(Totals_8; Totals[8])
            {
            }

            trigger OnAfterGetRecord()
            begin
                if Integer.Number = 0 then
                    exit;

                Totals[1] += TempBuffer."Sales qty.";
                Totals[2] += TempBuffer."Sales qty. last year";
                Totals[3] += TempBuffer."Sales LCY";
                Totals[4] += TempBuffer."Sales LCY last year";
                Totals[5] += TempBuffer."Profit LCY";
                Totals[6] += TempBuffer."Profit LCY last year";
                if Totals[3] <> 0 then
                    Totals[7] := Totals[5] / Totals[3] * 100
                else
                    Totals[7] := 0;
                if Totals[4] <> 0 then
                    Totals[8] := Totals[6] / Totals[4] * 100
                else
                    Totals[8] := 0;
                if Integer.Number = TempBuffer.Count() then
                    CurrReport.Break();
                if Integer.Number > 0 then
                    TempBuffer.Next();
            end;

            trigger OnPostDataItem()
            begin
                TotalAmt[1] := Totals[1];
                TotalAmt[2] := Totals[2];
                TotalAmt[3] := Totals[3];
                TotalAmt[4] := Totals[4];
                TotalAmt[5] := Totals[5];
                TotalAmt[6] := Totals[6];
                TotalAmt[7] := Totals[7];
                TotalAmt[8] := Totals[8];
            end;

            trigger OnPreDataItem()
            var
                EmptyLinesDeErr: Label 'Der er kun tomme linjer på rapporten.';
                EmptyLinesEngErr: Label 'There is only empty lines on the report.';
            begin
                CheckDateFilters();

                fillTable();

                UpdateSortKey();
                if not TempBuffer.Find('-') then
                    if CurrReport.Language = 1030 then
                        Error(EmptyLinesDeErr)
                    else
                        Error(EmptyLinesEngErr);
            end;
        }
        dataitem(Totalling; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
            MaxIteration = 1;
            column(Number_Totalling; Totalling.Number)
            {
            }
            column(TotalAmt_1_Totalling; TotalAmt[1] * -1)
            {
            }
            column(TotalAmt_2_Totalling; TotalAmt[2] * -1)
            {
            }
            column(TotalAmt_3_Totalling; TotalAmt[3])
            {
            }
            column(TotalAmt_4_Totalling; TotalAmt[4])
            {
            }
            column(TotalAmt_5_Totalling; TotalAmt[5])
            {
            }
            column(TotalAmt_6_Totalling; TotalAmt[6])
            {
            }
            column(TotalAmt_7_Totalling; TotalAmt[7])
            {
            }
            column(TotalAmt_8_Totalling; TotalAmt[8])
            {
            }
        }
    }

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(content)
            {
                group(Statistics)
                {
                    field("Stats for"; Type)
                    {
                        Caption = 'Statistics for';
                        Tooltip = 'Specifies the value of the Stats for field';
                        OptionCaption = 'Period,Salesperson,ItemCategory,Item,Customer,Vendor,Project Code';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sort By"; SortBy)
                    {
                        Caption = 'Sort By';
                        OptionCaption = 'No.,Description,Period Start,Sales qty.,Sales qty. last year,Sales LCY,Sales LCY last year,Profit LCY,Profit LCY last year,Profit %,Profit % last year';
                        ToolTip = 'Specifies the value of the Sort by field';
                        ApplicationArea = NPRRetail;
                    }
                }

                group(Period)
                {
                    field("Periode start"; PeriodStart)
                    {
                        Caption = 'Period Start';
                        ToolTip = 'Specifies the value of the Period Start field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Period end"; PeriodEnd)
                    {
                        Caption = 'Period End';
                        ToolTip = 'Specifies the value of the Period Start field';
                        ApplicationArea = NPRRetail;
                    }
                }

                group(Filters)
                {
                    field("Salesperson Filter"; SalespersonFilter)
                    {
                        Caption = 'Salesperson Code';
                        ToolTip = 'Specifies the value of the Salesperson Code field.';
                        TableRelation = "Salesperson/Purchaser".Code;
                        ApplicationArea = NPRRetail;
                    }
                    field("Item Category"; ItemCategoryFilter)
                    {
                        Caption = 'Item Category';
                        ToolTip = 'Specifies the default Item Category';
                        TableRelation = "Item Category".Code;
                        ApplicationArea = NPRRetail;
                    }
                    field("Item No."; ItemNoFilter)
                    {
                        Caption = 'Item No.';
                        ToolTip = 'Specifies the value of the Item No. field.';
                        TableRelation = Item."No.";
                        ApplicationArea = NPRRetail;
                    }
                    field("Customer No."; CustomerNoFilter)
                    {
                        Caption = 'Customer No.';
                        ToolTip = 'Specifies the value of the Customer No. field.';
                        TableRelation = Customer."No.";
                        ApplicationArea = NPRRetail;
                    }
                    field("Vendor No."; VendorNoFilter)
                    {
                        Caption = 'Vendor No.';
                        ToolTip = 'Specifies the value of the Vendor No. field.';
                        TableRelation = Vendor."No.";
                        ApplicationArea = NPRRetail;
                    }
                    field("Global Dimension 1 Filter"; Dim1Filter)
                    {
                        CaptionClass = '1,1,1';
                        Caption = 'Department Code';
                        ToolTip = 'Specifies Global Dimension 1 Filter';
                        TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
                        ApplicationArea = NPRRetail;
                    }
                    field("Global Dimension 2 Filter"; Dim2Filter)
                    {
                        CaptionClass = '1,1,2';
                        Caption = 'Project Code';
                        ToolTip = 'Specifies Global Dimension 2 Filter';
                        TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }
    }

    labels
    {
        Report_Caption = 'Advanced Sales Statistics';
        Page_Caption = 'Page';
        GlobalDim1_Caption = 'Global Dimension 1 Code:';
        GlobalDim2_Caption = 'Global Dimension 2 Code:';
        ItemCategoryFilter_Caption = 'Item Category filter:';
        Period_Caption = 'Period:';
        No_Caption = 'No.';
        Description_Caption = 'Description';
        SalesQty_Caption = 'Sales qty.';
        SalesQty_LastYr_Caption = 'Last year\Sales qty.';
        SalesLCY_Caption = 'Sales LCY';
        SalesLCY_LastYr_Caption = 'Last year\Sales LCY';
        ProfitLCY_Caption = 'Profit LCY';
        ProfitLCY_LastYr_Caption = 'Last year\Profit LCY';
        ProfitPct_Caption = 'Profit %';
        ProfitPct_LastYr_Caption = 'Last year\Profit %';
        CarriedOver_Caption = 'Carried over';
        CarriedThrough_Caption = 'Carried through';
        Total_Caption = 'Total';
        LastYear_Caption = 'Last Year';
    }

    trigger OnInitReport()
    begin
        Clear(Totals);
    end;

    trigger OnPreReport()
    begin
        CreateRequestPageFiltersText(FiltersText);
        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture);
    end;

    var
        CompanyInformation: Record "Company Information";
        Customer: Record Customer;
        DateRecord: Record Date;
        DimensionValue: Record "Dimension Value";
        _Item: Record Item;
        _ItemCategory: Record "Item Category";
        ItemLedgerEntry: Record "Item Ledger Entry";
        TempBuffer: Record "NPR Advanced Sales Statistics" temporary;
        "Salesperson/Purchaser": Record "Salesperson/Purchaser";
        Vendor: Record Vendor;
        SalesStatisticsByPerson: Query "NPR Sales Statistics By Person";
        ValueEntryWithVendor: Query "NPR Value Entry With Vendor";
        "Record": RecordRef;
        Caption: FieldRef;
        "Field": FieldRef;
        FilterField: FieldRef;
        FilterField2: FieldRef;
        TypeField: FieldRef;
        CustomerNoFilter: Code[20];
        Dim1Filter: Code[20];
        Dim2Filter: Code[20];
        ItemCategoryFilter: Code[20];
        ItemNoFilter: Code[20];
        ProjectCodeEnd: Code[20];
        ProjectCodeStart: Code[20];
        SalespersonFilter: Code[20];
        VendorNoFilter: Code[20];
        DateFilter: Date;
        PeriodEnd: Date;
        PeriodStart: Date;
        TotalAmt: array[8] of Decimal;
        Totals: array[8] of Decimal;
        d: Dialog;
        "Count": Integer;
        Lines: Integer;

        CustomerFilterTitleLbl: Label 'Customer No: ';
        DeptCodeFilterTitleLbl: Label 'Department Code: ';
        DialogText: Label 'Processing No. #1######## @2@@@@@@@@';
        FiltersTextLbl: Label 'Filters: ';
        ItemCatFilterTitleLbl: Label 'Item Category: ';
        ItemFilterTitleLbl: Label 'Item No: ';
        Pct1Lbl: Label '%1..%2', locked = true;
        Pct2Lbl: Label '%1';
        PeriodFilterTitleLbl: Label 'Period: ';
        ProjectCodeFilterTitleLbl: Label 'Project Code: ';
        SalespersonFilterTitleLbl: Label 'Salesperson No: ';
        TitleCustomerLbl: Label 'Customers';
        TitleItemLbl: Label 'Items';
        TitleItemCategoryLbl: Label 'Item Category';
        TitlePeriodLbl: Label 'Period';
        TitleProjectCodeLbl: Label 'Project Code';
        TitleSalespersonLbl: Label 'Salespersons';
        TitleVendorLbl: Label 'Vendors';
        VendorFilterTitleLbl: Label 'Vendor No: ';
        Day: Option Day,Week,Month,Quarter,Year;
        SortBy: Option "No.",Description,"Period Start","Sales qty.","Sales qty. last year","Sales LCY","Sales LCY last year","Profit LCY","Profit LCY last year","Profit %","Profit % last year";
        Type: Option Period,Salesperson,ItemCategory,Item,Customer,Vendor,Projectcode;
        FiltersText: Text;
        Title: Text[30];
        CalcLastYear: Text[50];
        PeriodeFilter: Text[255];
        PeriodFilters: Text[255];

    internal procedure SetFiltersOnType(xType: Option Period,Salesperson,ItemCategory,Item,Customer,Vendor,Projectcode; xDay: Option Day,Week,Month,Quarter,Year; GlobalDim1: Code[20]; GlobalDim2: Code[20]; DatoStart: Date; DatoEnd: Date; ItemCategory: Code[20]; LastYearCalc: Text[50]; hide: Boolean)
    begin
        Dim1Filter := GlobalDim1;
        Dim2Filter := GlobalDim2;
        PeriodStart := DatoStart;
        PeriodEnd := DatoEnd;
        ItemCategoryFilter := ItemCategory;
        CalcLastYear := LastYearCalc;
        Day := xDay;
        Type := xType;

        PeriodeFilter := StrSubstNo(Pct1Lbl, PeriodStart, PeriodEnd);
    end;

    internal procedure fillTable()
    var
        CostAmount: Decimal;
        ILEQuantity: Decimal;
        SalesAmount: Decimal;
        NoTypeErr: Label 'No Type selected';
    begin
        TempBuffer.DeleteAll();
        case Type of
            Type::Period:
                begin
                    Record.Open(DATABASE::Date);

                    FilterField := Record.Field(DateRecord.FieldNo("Period Start"));
                    FilterField.SetFilter(StrSubstNo(Pct1Lbl, PeriodStart, PeriodEnd));

                    TypeField := Record.Field(DateRecord.FieldNo("Period Type"));
                    TypeField.SetRange(Day);

                    Field := Record.Field(DateRecord.FieldNo("Period Start"));
                    Caption := Record.Field(DateRecord.FieldNo("Period Start"));

                    Title := TitlePeriodLbl;
                end;

            Type::Item:
                begin
                    Record.Open(DATABASE::Item);

                    if ItemNoFilter <> '' then begin
                        FilterField := Record.Field(_Item.FieldNo("No."));
                        FilterField.SetFilter(Pct2Lbl, ItemNoFilter);
                    end;

                    if ItemCategoryFilter <> '' then begin
                        FilterField2 := Record.Field(_Item.FieldNo("Item Category Code"));
                        FilterField2.SetFilter(Pct2Lbl, ItemCategoryFilter);
                    end;

                    Field := Record.Field(_Item.FieldNo("No."));
                    Caption := Record.Field(_Item.FieldNo(Description));
                    Title := TitleItemLbl;
                end;

            Type::ItemCategory:
                begin
                    Record.Open(DATABASE::"Item Category");

                    if ItemCategoryFilter <> '' then begin
                        FilterField := Record.Field(_ItemCategory.FieldNo(Code));
                        FilterField.SetFilter(StrSubstNo(Pct2Lbl, ItemCategoryFilter));
                    end;

                    Field := Record.Field(_ItemCategory.FieldNo(Code));
                    Caption := Record.Field(_ItemCategory.FieldNo(Description));
                    Title := TitleItemCategoryLbl;
                end;

            Type::Salesperson:
                begin
                    Record.Open(DATABASE::"Salesperson/Purchaser");

                    if SalespersonFilter <> '' then begin
                        FilterField := Record.Field("Salesperson/Purchaser".FieldNo(Code));
                        FilterField.SetFilter(StrSubstNo(Pct2Lbl, SalespersonFilter));
                    end;

                    Field := Record.Field("Salesperson/Purchaser".FieldNo(Code));
                    Caption := Record.Field("Salesperson/Purchaser".FieldNo(Name));
                    Title := TitleSalespersonLbl;
                end;

            Type::Customer:
                begin
                    Record.Open(DATABASE::Customer);

                    if CustomerNoFilter <> '' then begin
                        FilterField := Record.Field(Customer.FieldNo("No."));
                        FilterField.SetFilter(StrSubstNo(Pct2Lbl, CustomerNoFilter));
                    end;

                    Field := Record.Field(Customer.FieldNo("No."));
                    Caption := Record.Field(Customer.FieldNo(Name));
                    Title := TitleCustomerLbl;
                end;

            Type::Vendor:
                begin
                    Record.Open(DATABASE::Vendor);

                    if VendorNoFilter <> '' then begin
                        FilterField := Record.Field(Vendor.FieldNo("No."));
                        FilterField.SetFilter(StrSubstNo(Pct2Lbl, VendorNoFilter));
                    end;

                    Field := Record.Field(Vendor.FieldNo("No."));
                    Caption := Record.Field(Vendor.FieldNo(Name));
                    Title := TitleVendorLbl;
                end;
            Type::Projectcode:
                begin
                    Record.Open(Database::"Dimension Value");

                    FilterField := Record.Field(DimensionValue.FieldNo("Global Dimension No."));
                    FilterField.SetFilter('2');

                    if Dim2Filter <> '' then begin
                        FilterField := Record.Field(DimensionValue.FieldNo(Code));
                        FilterField.SetFilter(Dim2Filter);
                    end;

                    Field := Record.Field(DimensionValue.FieldNo(Code));
                    Caption := Record.Field(DimensionValue.FieldNo(Name));
                    Title := TitleProjectCodeLbl;
                end;
            else
                Error(NoTypeErr);
        end;

        Lines := Record.Count;

        d.Open(DialogText);
        Count := 0;

        if Record.Find('-') then
            repeat
                Count += 1;
                d.Update(1, Format(Field.Value));
                d.Update(2, Round(Count / Lines * 10000, 1, '='));

                SetValueEntryFilter(CostAmount, SalesAmount, false, Format(Field.Value));

                SetItemLedgerEntryFilter(ILEQuantity, false, Format(Field.Value));

                TempBuffer.Init();
                if Type = Type::Period then begin
                    TempBuffer."Date 1" := Field.Value;
                    TempBuffer."No." := Format(Count);
                end else
                    TempBuffer."No." := Format(Field.Value);
                if not (Type = Type::Projectcode) then
                    TempBuffer.Description := Format(Caption.Value)
                else
                    TempBuffer.Description := StrSubstNo(Pct1Lbl, ProjectCodeStart, ProjectCodeEnd);

                TempBuffer."Sales qty." := ILEQuantity;
                TempBuffer."Sales LCY" := SalesAmount;
                TempBuffer."Profit LCY" := SalesAmount + CostAmount;
                if TempBuffer."Sales LCY" <> 0 then
                    TempBuffer."Profit %" := TempBuffer."Profit LCY" / TempBuffer."Sales LCY" * 100
                else
                    TempBuffer."Profit %" := 0;

                SetValueEntryFilter(CostAmount, SalesAmount, true, Format(Field.Value));

                SetItemLedgerEntryFilter(ILEQuantity, true, Format(Field.Value));

                TempBuffer."Sales qty. last year" := ILEQuantity;
                TempBuffer."Sales LCY last year" := SalesAmount;
                TempBuffer."Profit LCY last year" := SalesAmount + CostAmount;
                if TempBuffer."Sales LCY last year" <> 0 then
                    TempBuffer."Profit % last year" := TempBuffer."Profit LCY last year" / TempBuffer."Sales LCY last year" * 100
                else
                    TempBuffer."Profit % last year" := 0;

                TempBuffer.Insert();
            until (Record.Next() = 0) or ((Type = Type::Period) and (Count >= Lines));
        d.Close();
    end;

    internal procedure SetItemLedgerEntryFilter(var ILEQuantity: Decimal; LastYear: Boolean; "Code": Code[20])
    begin
        ILEQuantity := 0;
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Sale);
        SalesStatisticsByPerson.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
        case Type of
            Type::Item:
                ItemLedgerEntry.SetRange("Item No.", Code);
            Type::ItemCategory:
                ItemLedgerEntry.SetRange("Item Category Code", Code);
            Type::Salesperson:
                SalesStatisticsByPerson.SetFilter(Filter_SalesPers_Purch_Code, Code);
            Type::Customer:

                ItemLedgerEntry.SetRange("Source No.", Code);
            Type::Vendor:
                SalesStatisticsByPerson.SetRange(Filter_Vendor_No_, Code);
            Type::Projectcode:

                if (ProjectCodeStart <> '') and (ProjectCodeStart <> '') then
                    ItemLedgerEntry.SetFilter("Global Dimension 2 Code", '%1..%2', ProjectCodeStart, ProjectCodeEnd);
        end;

        if not LastYear then begin
            if Type = Type::Period then begin
                Evaluate(DateFilter, Code);
                ItemLedgerEntry.SetFilter("Posting Date", StrSubstNo(Pct2Lbl, DateFilter));
            end else begin
                ItemLedgerEntry.SetFilter("Posting Date", '%1..%2', PeriodStart, PeriodEnd);
                SalesStatisticsByPerson.SetFilter(Filter_Posting_Date, '%1..%2', PeriodStart, PeriodEnd);
            end;
        end else
            if Type = Type::Period then begin
                Evaluate(DateFilter, Code);
                ItemLedgerEntry.SetFilter("Posting Date", StrSubstNo(Pct2Lbl, CalcDate('<- 1Y>', DateFilter)));
            end else begin
                ItemLedgerEntry.SetFilter("Posting Date", '%1..%2', CalcDate('<- 1Y>', PeriodStart), CalcDate('<- 1Y>', PeriodEnd));
                SalesStatisticsByPerson.SetFilter(Filter_Posting_Date, '%1..%2', CalcDate('<- 1Y>', PeriodStart), CalcDate('<- 1Y>', PeriodEnd));
            end;

        if Type <> Type::ItemCategory then
            if ItemCategoryFilter <> '' then begin
                ItemLedgerEntry.SetFilter("Item Category Code", ItemCategoryFilter);
                SalesStatisticsByPerson.SetFilter(Filter_Item_Category_Code, ItemCategoryFilter);
            end else begin
                ItemLedgerEntry.SetRange("Item Category Code");
                SalesStatisticsByPerson.SetRange(Filter_Item_Category_Code);
            end;

        if Dim1Filter <> '' then begin
            ItemLedgerEntry.SetFilter("Global Dimension 1 Code", Dim1Filter);
            SalesStatisticsByPerson.SetFilter(Filter_Global_Dimension_1_Code, Dim1Filter);
        end else begin
            ItemLedgerEntry.SetRange("Global Dimension 1 Code");
            SalesStatisticsByPerson.SetRange(Filter_Global_Dimension_1_Code);
        end;

        if not (Type = Type::Projectcode) then
            if Dim2Filter <> '' then begin
                ItemLedgerEntry.SetFilter("Global Dimension 2 Code", Dim2Filter);
                SalesStatisticsByPerson.SetFilter(Filter_Global_Dimension_2_Code, Dim2Filter);
            end else begin
                ItemLedgerEntry.SetRange("Global Dimension 2 Code");
                SalesStatisticsByPerson.SetRange(Filter_Global_Dimension_2_Code);
            end;

        if not (Type = Type::Item) then
            if ItemNoFilter <> '' then begin
                ItemLedgerEntry.SetFilter("Item No.", ItemNoFilter);
                SalesStatisticsByPerson.SetFilter(Filter_Item_No_, ItemNoFilter);
            end else begin
                ItemLedgerEntry.SetRange("Item No.");
                SalesStatisticsByPerson.SetRange(Filter_Item_No_);
            end;

        if not (Type = Type::Salesperson) then
            if SalespersonFilter <> '' then
                SalesStatisticsByPerson.SetFilter(Filter_SalesPers_Purch_Code, SalespersonFilter)
            else
                SalesStatisticsByPerson.SetRange(Filter_SalesPers_Purch_Code);

        if not (Type = Type::Customer) then
            if CustomerNoFilter <> '' then
                SalesStatisticsByPerson.SetFilter(Filter_Source_No, CustomerNoFilter)
            else
                SalesStatisticsByPerson.SetRange(Filter_Source_No);

        if not (Type = Type::Vendor) then
            if VendorNoFilter <> '' then
                SalesStatisticsByPerson.SetFilter(Filter_Vendor_No_, VendorNoFilter)
            else
                SalesStatisticsByPerson.SetRange(Filter_Vendor_No_);

        case Type of
            Type::Item, Type::ItemCategory, Type::Customer, Type::Projectcode, Type::Period:
                begin
                    ItemLedgerEntry.CalcSums(Quantity);
                    ILEQuantity := ItemLedgerEntry.Quantity;
                end;
            Type::Salesperson, Type::Vendor:
                begin
                    SalesStatisticsByPerson.Open();
                    while SalesStatisticsByPerson.Read() do
                        ILEQuantity += SalesStatisticsByPerson.Quantity;
                end;
        end;
    end;

    internal procedure SetValueEntryFilter(var CostAmount: Decimal; var SalesAmount: Decimal; LastYear: Boolean; "Code": Code[20])
    begin
        CostAmount := 0;
        SalesAmount := 0;
        ValueEntryWithVendor.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);

        case Type of
            Type::Item:
                ValueEntryWithVendor.SetRange(Filter_Item_No, Code);
            Type::ItemCategory:
                ValueEntryWithVendor.SetRange(Filter_Item_Category_Code, Code);
            Type::Salesperson:
                ValueEntryWithVendor.SetRange(Filter_Salespers_Purch_Code, Code);
            Type::Customer:
                ValueEntryWithVendor.SetRange(Filter_Source_No, Code);
            Type::Vendor:
                ValueEntryWithVendor.SetRange(Filter_Vendor_No, Code);
            Type::Projectcode:

                if (ProjectCodeStart <> '') and (ProjectCodeStart <> '') then
                    ValueEntryWithVendor.SetFilter(Filter_Dim_2_Code, '%1..%2', ProjectCodeStart, ProjectCodeEnd);
        end;

        if not LastYear then begin
            if Type = Type::Period then begin
                Evaluate(DateFilter, Code);
                ValueEntryWithVendor.SetFilter(Filter_DateTime, StrSubstNo(Pct2Lbl, DateFilter));
            end
            else
                ValueEntryWithVendor.SetFilter(Filter_DateTime, '%1..%2', PeriodStart, PeriodEnd);
        end else
            if Type = Type::Period then begin
                Evaluate(DateFilter, Code);
                ValueEntryWithVendor.SetFilter(Filter_DateTime, StrSubstNo(Pct2Lbl, CalcDate('<- 1Y>', DateFilter)));
            end
            else
                ValueEntryWithVendor.SetFilter(Filter_DateTime, '%1..%2', CalcDate('<- 1Y>', PeriodStart), CalcDate('<- 1Y>', PeriodEnd));

        if Type <> Type::ItemCategory then
            if ItemCategoryFilter <> '' then
                ValueEntryWithVendor.SetFilter(Filter_Item_Category_Code, ItemCategoryFilter)
            else
                ValueEntryWithVendor.SetRange(Filter_Item_Category_Code);

        if Dim1Filter <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Dim_1_Code, Dim1Filter)
        else
            ValueEntryWithVendor.SetRange(Filter_Dim_1_Code);

        if not (Type = Type::Projectcode) then
            if Dim2Filter <> '' then
                ValueEntryWithVendor.SetFilter(Filter_Dim_2_Code, Dim2Filter)
            else
                ValueEntryWithVendor.SetRange(Filter_Dim_2_Code);

        if not (Type = Type::Item) then
            if ItemNoFilter <> '' then
                ValueEntryWithVendor.SetFilter(Filter_Item_No, ItemNoFilter)
            else
                ValueEntryWithVendor.SetRange(Filter_Item_No);

        if not (Type = Type::Salesperson) then
            if SalespersonFilter <> '' then
                ValueEntryWithVendor.SetFilter(Filter_SalesPers_Purch_Code, SalespersonFilter)
            else
                ValueEntryWithVendor.SetRange(Filter_SalesPers_Purch_Code);

        if not (Type = Type::Customer) then
            if CustomerNoFilter <> '' then
                ValueEntryWithVendor.SetFilter(Filter_Source_No, CustomerNoFilter)
            else
                ValueEntryWithVendor.SetRange(Filter_Source_No);

        if not (Type = Type::Vendor) then
            if VendorNoFilter <> '' then
                ValueEntryWithVendor.SetFilter(Filter_Vendor_No, VendorNoFilter)
            else
                ValueEntryWithVendor.SetRange(Filter_Vendor_No);

        if not (Type = Type::Projectcode) then
            if Dim2Filter <> '' then
                ValueEntryWithVendor.SetFilter(Filter_Dim_2_Code, Dim2Filter)
            else
                ValueEntryWithVendor.SetRange(Filter_Dim_2_Code);

        ValueEntryWithVendor.Open();
        while ValueEntryWithVendor.Read() do begin
            CostAmount += ValueEntryWithVendor.Sum_Cost_Amount_Actual;
            SalesAmount += ValueEntryWithVendor.Sum_Sales_Amount_Actual;
        end;
    end;

    internal procedure UpdateSortKey()
    begin
        case SortBy of
            SortBy::Description:
                TempBuffer.SetCurrentKey(Description);
            SortBy::"Period Start":
                TempBuffer.SetCurrentKey("Period Start");
            SortBy::"Sales qty.":
                TempBuffer.SetCurrentKey("Sales qty.");
            SortBy::"Sales qty. last year":
                TempBuffer.SetCurrentKey("Sales qty. last year");
            SortBy::"Sales LCY":
                TempBuffer.SetCurrentKey("Sales LCY");
            SortBy::"Sales LCY last year":
                TempBuffer.SetCurrentKey("Sales LCY last year");
            SortBy::"Profit LCY":
                TempBuffer.SetCurrentKey("Profit LCY");
            SortBy::"Profit LCY last year":
                TempBuffer.SetCurrentKey("Profit LCY last year");
            SortBy::"Profit %":
                TempBuffer.SetCurrentKey("Profit %");
            SortBy::"Profit % last year":
                TempBuffer.SetCurrentKey("Profit % last year");
            SortBy::"No.":
                TempBuffer.SetCurrentKey("No.");
        end;
    end;

    local procedure CheckDateFilters()
    var
        EmptyFilterErr: Label 'You must enter a value for Period filters.';
    begin
        if (PeriodEnd = 0D) or (PeriodStart = 0D) then
            Error(EmptyFilterErr);
    end;

    local procedure CreateRequestPageFiltersText(var FiltersTextParam: Text)
    var
        Filter2Lbl: Label '%1 %2';
        FilterLbl: Label ', %1 %2';
    begin
        Clear(FiltersTextParam);

        PeriodFilters := StrSubstNo(Pct1Lbl, PeriodStart, PeriodEnd);
        FiltersTextParam += StrSubstNo(Filter2Lbl, PeriodFilterTitleLbl, PeriodFilters);

        if (SalespersonFilter <> '') then
            FiltersTextParam += StrSubstNo(FilterLbl, SalespersonFilterTitleLbl, SalespersonFilter);

        if (ItemCategoryFilter <> '') then
            FiltersTextParam += StrSubstNo(FilterLbl, ItemCatFilterTitleLbl, ItemCategoryFilter);

        if (ItemNoFilter <> '') then
            FiltersTextParam += StrSubstNo(FilterLbl, ItemFilterTitleLbl, ItemNoFilter);

        if (CustomerNoFilter <> '') then
            FiltersTextParam += StrSubstNo(FilterLbl, CustomerFilterTitleLbl, CustomerNoFilter);

        if (VendorNoFilter <> '') then
            FiltersTextParam += StrSubstNo(FilterLbl, VendorFilterTitleLbl, VendorNoFilter);

        if (Dim1Filter <> '') then
            FiltersTextParam += StrSubstNo(FilterLbl, DeptCodeFilterTitleLbl, Dim1Filter);

        if (Dim2Filter <> '') then
            FiltersTextParam += StrSubstNo(FilterLbl, ProjectCodeFilterTitleLbl, Dim2Filter)
    end;
}