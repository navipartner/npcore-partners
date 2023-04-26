page 6014585 "NPR Advanced Sales Stats"
{
    Extensible = False;
    Caption = 'Advanced Sales Statistics Page';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = Date;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            group(Period)
            {
                field(PeriodType; PeriodType)
                {

                    Caption = 'Period Type';
                    OptionCaption = 'Day,Week,Month,Quarter,Year,Period';
                    ToolTip = 'Specifies the period type used as a filter.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        case PeriodType of
                            PeriodType::Day:
                                begin
                                    Day := Day::Day;
                                end;
                            PeriodType::Week:
                                begin
                                    Day := Day::Week;
                                end;
                            PeriodType::Month:
                                begin
                                    Day := Day::Month;
                                end;
                            PeriodType::Quarter:
                                begin
                                    Day := Day::Quarter;
                                end;
                            PeriodType::Year:
                                begin
                                    Day := Day::Year;
                                end;
                            PeriodType::Period:
                                PeriodPeriodTypeOnValidate();
                        end;

                        Calc();
                        CurrPage.Update(false);
                    end;
                }
                field(DateFilter; DateFilter)
                {

                    Caption = 'Period';
                    ToolTip = 'Specifies the period used as a filter.';
                    ApplicationArea = NPRRetail;
                    trigger OnValidate()
                    begin
                        Rec.SetFilter("Period Start", DateFilter);
                        CurrPage.Update(false);
                    end;
                }
                field(DateFilterLastYear; DateFilterLastYear)
                {

                    Caption = 'Period (Last Year)';
                    ToolTip = 'Specifies the last year period used as a filter.';
                    ApplicationArea = NPRRetail;
                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                    end;
                }
                field(HideItemGroup; HideItemGroup)
                {

                    Caption = 'Hide Empty Lines';
                    Visible = false;
                    ToolTip = 'Hide the empty lines from the report.';
                    ApplicationArea = NPRRetail;
                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                    end;
                }
                field(ItemNoFilter; ItemNoFilter)
                {

                    Caption = 'Item No. Filter';
                    TableRelation = Item."No.";
                    ToolTip = 'Specifies the item number used as a filter.';
                    ApplicationArea = NPRRetail;
                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                    end;

                }
                field(ItemCategoryCodeFilter; ItemCategoryCodeFilter)
                {

                    Caption = 'Item Category Code';
                    TableRelation = "Item Category";
                    ToolTip = 'Specifies the item category used as a filter.';
                    ApplicationArea = NPRRetail;
                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                    end;
                }
            }
            group(Control6150631)
            {
                ShowCaption = false;
                field(Dim1Filter; Dim1Filter)
                {
                    CaptionClass = '1,2,1';
                    Caption = 'Dept. Code';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
                    ToolTip = 'Specifies the department used as a filter.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                    end;
                }
                field(Dim2Filter; Dim2Filter)
                {
                    CaptionClass = '1,2,2';
                    Caption = 'Project Code';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
                    ToolTip = 'Specifies the project used as a filter.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                    end;
                }
                field(ShowLastYear; ShowLastYear)
                {

                    Caption = 'Show Previous Year';
                    ToolTip = '"Display sales statistics from the previous year.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        SetShowLastYear();
                    end;
                }
                field(ShowSameWeekday; ShowSameWeekday)
                {

                    Caption = 'Show the Same Weekday from the Previous Year';
                    ToolTip = 'Display sales statistics from the same weekday of the previous year.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        Calc();
                        ShowLastYear := true;
                        SetShowLastYear();
                    end;
                }
            }
            repeater(UpdateControls)
            {
                Editable = false;
                field("Period Name"; Rec."Period Name")
                {

                    ToolTip = 'Specifies the period name.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        ViewPosition := ViewPosition::Period;
                    end;
                }
                field("Period Start"; Rec."Period Start")
                {

                    ToolTip = 'Specifies the beginning of the period.';
                    ApplicationArea = NPRRetail;
                }
                field("-Sale (QTY)"; -"Sale (QTY)")
                {

                    Caption = 'Sale (QTY)';
                    ToolTip = 'Specifies the total quantity of sales.';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        ItemLedgerEntry: Record "Item Ledger Entry";
                        ItemLedgerEntries: Page "Item Ledger Entries";
                    begin

                        SetItemLedgerEntryFilter(ItemLedgerEntry);
                        ItemLedgerEntries.SetTableView(ItemLedgerEntry);
                        ItemLedgerEntries.Editable(false);
                        ItemLedgerEntries.RunModal();
                    end;
                }
                field("-LastYear Sale (QTY)"; -"LastYear Sale (QTY)")
                {

                    Caption = '-> Last Year';
                    Visible = PLYSaleQty;
                    ToolTip = 'Specifies the total quantity of sales for the last year.';
                    ApplicationArea = NPRRetail;
                }
                field("Sale (LCY)"; "Sale (LCY)")
                {

                    Caption = 'Sale(LCY)';
                    ToolTip = 'Specifies the total amount of sales in local currency.';
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
                field("LastYear Sale (LCY)"; "LastYear Sale (LCY)")
                {

                    Caption = 'LastYear Sale (LCY)';
                    Visible = PLYSale;
                    ToolTip = 'Specifies the total amount of sales for the last year in local currency.';
                    ApplicationArea = NPRRetail;
                }
                field("Profit (LCY)"; "Profit (LCY)")
                {

                    Caption = 'Profit (LCY)';
                    ToolTip = 'Specifies the profit in local currency.';
                    ApplicationArea = NPRRetail;
                }
                field("LastYear Profit (LCY)"; "LastYear Profit (LCY)")
                {

                    Caption = 'Last Year Profit(LCY)';
                    Visible = PLYProfit;
                    ToolTip = 'Specifies the profit for the last year in local currency.';
                    ApplicationArea = NPRRetail;
                }
                field("Profit %"; "Profit %")
                {

                    Caption = 'Profit %';
                    ToolTip = 'Specifies profit percentage.';
                    ApplicationArea = NPRRetail;
                }
                field("LastYear Profit %"; "LastYear Profit %")
                {

                    Caption = 'LastYear Profit %';
                    Visible = "PLYProfit%";
                    ToolTip = 'Specifies the percentage of the profit for the last year in local currency.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(reporting)
        {
            group(Reports)
            {
                action("Advanced Sales Statistics")
                {
                    Caption = 'Advanced Sales Statistics';
                    Image = Statistics;

                    ToolTip = 'Displays the Advanced Sales Statistics report.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        SalesStatisticsReport: Report "NPR Advanced Sales Stat.";
                    begin
#if BC17 or BC18
                        SalesStatisticsReport.SetFiltersOnType(ViewPosition, Day, Dim1Filter, Dim2Filter, Rec."Period Start",
                                           Rec."Period End", ItemCategoryCodeFilter, LastYearCalc,
                                           (((ViewPosition = ViewPosition::ItemGroup) and HideItemGroup) or
                                             ((ViewPosition = ViewPosition::Item) and HideItem) or
                                             ((ViewPosition = ViewPosition::Customer) and HideCustomer) or
                                             ((ViewPosition = ViewPosition::Vendor) and HideVendor) or
                                             ((ViewPosition = ViewPosition::Projectcode) and false)));
#else
                        SalesStatisticsReport.SetFiltersOnType(ViewPosition, PeriodToInteger(Day), Dim1Filter, Dim2Filter, Rec."Period Start",
                                           Rec."Period End", ItemCategoryCodeFilter, LastYearCalc,
                                           (((ViewPosition = ViewPosition::ItemGroup) and HideItemGroup) or
                                             ((ViewPosition = ViewPosition::Item) and HideItem) or
                                             ((ViewPosition = ViewPosition::Customer) and HideCustomer) or
                                             ((ViewPosition = ViewPosition::Vendor) and HideVendor) or
                                             ((ViewPosition = ViewPosition::Projectcode) and false)));
#endif
                        SalesStatisticsReport.RunModal();
                    end;
                }
            }
        }
        area(navigation)
        {
            group(RelatedInformation)
            {
                action("Salesperson Stats")
                {
                    Caption = 'Salesperson Statisticts';
                    Image = SalesPerson;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;

                    ToolTip = 'Displays Salesperson Statisticts report.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        SalespersonStatistics: Page "NPR Salesperson Stats Retail";
                    begin
                        SalespersonStatistics.InitForm();
                        SalespersonStatistics.SetFilter(Dim1Filter, Dim2Filter, Rec."Period Start", Rec."Period End", ItemCategoryCodeFilter, LastYearCalc, ItemNoFilter);
                        SalespersonStatistics.ShowLastYear(ShowLastYear);
                        SalespersonStatistics.ChangeEmptyFilter();
                        Sleep(10);
                        SalespersonStatistics.RunModal();
                    end;
                }
                action("Item Statistics")
                {
                    Caption = 'Item Statistics';
                    Image = Item;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;

                    ToolTip = 'Displays the Item Statistics report.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        TempItem: Record Item temporary;
                        ItemStatistics: Page "NPR Item Statistics Subpage";
                    begin
                        TempItem.SetFilter("Date Filter", DateFilter);
                        ItemStatistics.InitForm();
                        ItemStatistics.SetFilter(Dim1Filter, Dim2Filter, TempItem.GetRangeMin("Date Filter"), TempItem.GetRangeMax("Date Filter"), LastYearCalc, ItemCategoryCodeFilter);
                        ItemStatistics.ShowLastYear(ShowLastYear);
                        ItemStatistics.ChangeEmptyFilter();
                        Sleep(10);
                        ItemStatistics.RunModal();
                    end;
                }
                action("Customer Statistics")
                {
                    Caption = 'Customer Statistics';
                    Image = Customer;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;

                    ToolTip = 'Displays the Customer Statistics report.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        CustomerStatistics: Page "NPR Customer Stats Subpage";
                    begin
                        CustomerStatistics.InitForm();
                        CustomerStatistics.SetFilter(Dim1Filter, Dim2Filter, Rec."Period Start", Rec."Period End", ItemCategoryCodeFilter, LastYearCalc);

                        CustomerStatistics.ShowLastYear(ShowLastYear);
                        CustomerStatistics.ChangeEmptyFilter();
                        Sleep(10);
                        CustomerStatistics.RunModal();
                    end;
                }
                action("Vendor Statistics")
                {
                    Caption = 'Vendor Statistics';
                    Image = Vendor;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    ToolTip = 'Displays the Vendor Statistics report.';
                    ApplicationArea = NPRRetail;
                    trigger OnAction()
                    var
                        TempItem: Record Item temporary;
                        VendorStatistics: Page "NPR Vendor Statistics Subpage";
                    begin
                        TempItem.SetFilter("Date Filter", DateFilter);
                        VendorStatistics.InitForm();
                        VendorStatistics.SetFilter(Dim1Filter, Dim2Filter, TempItem.GetRangeMin("Date Filter"), TempItem.GetRangeMax("Date Filter"), ItemCategoryCodeFilter, LastYearCalc);

                        VendorStatistics.ShowLastYear(ShowLastYear);
                        VendorStatistics.ChangeEmptyFilter();
                        Sleep(10);
                        VendorStatistics.RunModal();
                    end;
                }
                action("Item Category Code Statistics")
                {
                    Caption = 'Item Category Code Statistics';
                    Image = ItemLines;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;

                    ToolTip = 'Displays the Item Category Code Statistics report.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        TempItem: Record Item temporary;
                        ItemCategoryStatsSubpage: Page "NPR Item Cat. Code Stats";
                    begin
                        TempItem.SetFilter("Date Filter", DateFilter);
                        ItemCategoryStatsSubpage.InitForm();
                        ItemCategoryStatsSubpage.SetFilter(Dim1Filter, Dim2Filter, TempItem.GetRangeMin("Date Filter"), TempItem.GetRangeMax("Date Filter"), LastYearCalc, ItemCategoryCodeFilter, ItemNoFilter);
                        ItemCategoryStatsSubpage.ShowLastYear(ShowLastYear);
                        ItemCategoryStatsSubpage.ChangeEmptyFilter();
                        Sleep(10);
                        ItemCategoryStatsSubpage.RunModal()
                    end;
                }
                action("Product Group Code Statistics")
                {
                    Caption = 'Product Group Code Statistics';
                    Image = ProductionSetup;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;

                    ToolTip = 'Displays the Product Group Code Statistics report.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        ProdGroupCodeStatsSubpage: Page "NPR Prod. Group Code Stats";
                    begin
                        ProdGroupCodeStatsSubpage.InitForm();
                        ProdGroupCodeStatsSubpage.SetFilter(Dim1Filter, Dim2Filter, Rec."Period Start", Rec."Period End", LastYearCalc, ItemNoFilter, ItemCategoryCodeFilter);
                        ProdGroupCodeStatsSubpage.ShowLastYear(ShowLastYear);
                        ProdGroupCodeStatsSubpage.ChangeEmptyFilter();
                        Sleep(10);
                        ProdGroupCodeStatsSubpage.RunModal()
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        if not (UsingPeriod) then begin
            DateFilter := CopyStr(StrSubstNo(DateFilterLbl, Rec."Period Start", Rec."Period End"), 1, 50);
            DateFilterLastYear := CopyStr(StrSubstNo(DateFilterLbl, CalcDate(LastYearCalc, Rec."Period Start"),
           CalcDate(LastYearCalc, Rec."Period End")), 1, 50);
        end;
    end;

    trigger OnAfterGetRecord()
    begin
        Calc();
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
#if BC17 or BC18
        exit(PeriodFormMan.FindDate(CopyStr(Which, 1, 3), Rec, Day));
#else
        exit(PeriodPageMan.FindDate(CopyStr(Which, 1, 3), Rec, Day));
#endif
    end;

    trigger OnInit()
    begin
        ShowSameWeekday := true;
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin
#if BC17 or BC18
        exit(PeriodFormMan.NextDate(Steps, Rec, Day));
#else
        exit(PeriodPageMan.NextDate(Steps, Rec, Day));
#endif
    end;

    trigger OnOpenPage()
    begin
        ShowLastYear := false;
        SetShowLastYear();
        HideItem := true;
        HideItemGroup := false;
        HideCustomer := true;
        HideVendor := true;
    end;

    var
#if BC17 or BC18
        PeriodFormMan: Codeunit PeriodFormManagement;
        Day: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period;
#else
        PeriodPageMan: Codeunit PeriodPageManagement;
        Day: Enum "Analysis Period Type";
        IncorrectPeriodErr: Label 'Incorrect period: %1';
#endif        
        "Sale (QTY)": Decimal;
        "LastYear Sale (QTY)": Decimal;
        "Sale (LCY)": Decimal;
        "LastYear Sale (LCY)": Decimal;
        "Profit (LCY)": Decimal;
        "LastYear Profit (LCY)": Decimal;
        "Profit %": Decimal;
        "LastYear Profit %": Decimal;
        Dim1Filter: Code[20];
        Dim2Filter: Code[20];
        DateFilter: Text[50];
        ViewPosition: Option Period,Salesperson,ItemGroup,Item,Customer,Vendor,Projectcode;
        HideItem: Boolean;
        HideItemGroup: Boolean;
        HideCustomer: Boolean;
        HideVendor: Boolean;
        LastYear: Boolean;
        ShowLastYear: Boolean;
        LastYearCalc: Text[30];
        ShowSameWeekday: Boolean;
        DateFilterLastYear: Text[50];
        UsingPeriod: Boolean;
        ItemNoFilter: Code[20];
        PLYSaleQty: Boolean;
        PLYSale: Boolean;
        PLYProfit: Boolean;
        "PLYProfit%": Boolean;
        PeriodType: Option Day,Week,Month,Quarter,Year,Period;
        ItemCategoryCodeFilter: Code[20];
        DateFilterLbl: Label '%1..%2', Locked = true;

    internal procedure Calc()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        CostAmount: Decimal;
        SalesAmount: Decimal;
    begin
        CalcCostAndSalesAmountFromVE(CostAmount, SalesAmount);

        SetItemLedgerEntryFilter(ItemLedgerEntry);
        ItemLedgerEntry.CalcSums(Quantity);

        "Sale (QTY)" := ItemLedgerEntry.Quantity;
        "Sale (LCY)" := SalesAmount;
        "Profit (LCY)" := SalesAmount + CostAmount;
        if "Sale (LCY)" <> 0 then
            "Profit %" := "Profit (LCY)" / "Sale (LCY)" * 100
        else
            "Profit %" := 0;

        // Calc last year
        LastYear := true;
        if ((Day = Day::Day) and ShowSameWeekday) or (Day = Day::Week) then
            LastYearCalc := '<-52W>'
        else
            LastYearCalc := '<-1Y>';

        if (Date2DMY(Rec."Period Start", 3) < 1) or (Date2DMY(Rec."Period Start", 3) > 9998) then
            LastYearCalc := '';

        CalcCostAndSalesAmountFromVE(CostAmount, SalesAmount);

        SetItemLedgerEntryFilter(ItemLedgerEntry);
        ItemLedgerEntry.CalcSums(Quantity);

        "LastYear Sale (QTY)" := ItemLedgerEntry.Quantity;
        "LastYear Sale (LCY)" := SalesAmount;
        "LastYear Profit (LCY)" := SalesAmount + CostAmount;
        if "LastYear Sale (LCY)" <> 0 then
            "LastYear Profit %" := "LastYear Profit (LCY)" / "LastYear Sale (LCY)" * 100
        else
            "LastYear Profit %" := 0;

        LastYear := false;
    end;

    internal procedure SetItemLedgerEntryFilter(var ItemLedgerEntry: Record "Item Ledger Entry")
    begin
        ItemLedgerEntry.SetCurrentKey("Entry Type", "Posting Date", "Global Dimension 1 Code", "Global Dimension 2 Code");
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Sale);
        if not LastYear then
            ItemLedgerEntry.SetFilter("Posting Date", '%1..%2', Rec."Period Start", Rec."Period End")
        else
            ItemLedgerEntry.SetFilter("Posting Date", '%1..%2', CalcDate(LastYearCalc, Rec."Period Start"), CalcDate(LastYearCalc, Rec."Period End"));

        if Dim1Filter <> '' then
            ItemLedgerEntry.SetRange("Global Dimension 1 Code", Dim1Filter)
        else
            ItemLedgerEntry.SetRange("Global Dimension 1 Code");

        if Dim2Filter <> '' then
            ItemLedgerEntry.SetRange("Global Dimension 2 Code", Dim2Filter)
        else
            ItemLedgerEntry.SetRange("Global Dimension 2 Code");

        if ItemNoFilter <> '' then
            ItemLedgerEntry.SetFilter("Item No.", ItemNoFilter)
        else
            ItemLedgerEntry.SetRange("Item No.");

        if ItemCategoryCodeFilter <> '' then
            ItemLedgerEntry.SetFilter("Item Category Code", ItemCategoryCodeFilter)
        else
            ItemLedgerEntry.SetRange("Item Category Code");
    end;

    internal procedure SetValueEntryFilter(var ValueEntry: Record "Value Entry")
    begin
        ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
        if not LastYear then
            ValueEntry.SetFilter("Posting Date", '%1..%2', Rec."Period Start", Rec."Period End")
        else
            ValueEntry.SetFilter("Posting Date", '%1..%2', CalcDate(LastYearCalc, Rec."Period Start"), CalcDate(LastYearCalc, Rec."Period End"));

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
        //SetValueEntryFilter
        case ItemCategoryCodeFilter <> '' of
            true:
                begin
                    ValueEntryWithItemCat.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);

                    if not LastYear then
                        ValueEntryWithItemCat.SetFilter(Filter_DateTime, '%1..%2', Rec."Period Start", Rec."Period End")
                    else
                        ValueEntryWithItemCat.SetFilter(Filter_DateTime, '%1..%2', CalcDate(LastYearCalc, Rec."Period Start"), CalcDate(LastYearCalc, Rec."Period End"));

                    ValueEntryWithItemCat.SetRange(Filter_Item_Category_Code, ItemCategoryCodeFilter);

                    if Dim1Filter <> '' then
                        ValueEntryWithItemCat.SetRange(Filter_Dim_1_Code, Dim1Filter)
                    else
                        ValueEntryWithItemCat.SetRange(Filter_Dim_1_Code);

                    if Dim2Filter <> '' then
                        ValueEntryWithItemCat.SetRange(Filter_Dim_2_Code, Dim2Filter)
                    else
                        ValueEntryWithItemCat.SetRange(Filter_Dim_2_Code);
                    if ItemNoFilter <> '' then
                        ValueEntryWithItemCat.SetFilter(Filter_Item_No, ItemNoFilter)
                    else
                        ValueEntryWithItemCat.SetRange(Filter_Item_No);
                    ValueEntryWithItemCat.Open();
                    while ValueEntryWithItemCat.Read() do begin
                        CostAmount += ValueEntryWithItemCat.Sum_Cost_Amount_Actual;
                        SalesAmount += ValueEntryWithItemCat.Sum_Sales_Amount_Actual;
                    end;
                end;
            false:
                begin
                    ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
                    if not LastYear then
                        ValueEntry.SetFilter("Posting Date", '%1..%2', Rec."Period Start", Rec."Period End")
                    else
                        ValueEntry.SetFilter("Posting Date", '%1..%2', CalcDate(LastYearCalc, Rec."Period Start"), CalcDate(LastYearCalc, Rec."Period End"));

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

    local procedure PeriodPeriodTypeOnValidate()
    var
        tblPeriode: Record "NPR Periodes";
    begin
        if not UsingPeriod then
            UsingPeriod := true
        else
            UsingPeriod := false;

        if UsingPeriod then begin
            if PAGE.RunModal(Page::"NPR Periodes", tblPeriode) = ACTION::LookupOK then begin
                Rec."Period Start" := tblPeriode."Start Date";
                Rec."Period End" := tblPeriode."End Date";
                DateFilter := StrSubstNo(DateFilterLbl, Rec."Period Start", Rec."Period End");
                Rec.SetFilter("Period Start", DateFilter);
                DateFilterLastYear := StrSubstNo(DateFilterLbl, tblPeriode."Start Date Last Year", tblPeriode."End Date Last Year");
                Day := Day::Day;
            end;
        end else
            Rec.SetFilter("Period Start", '');
    end;

#if not BC17 and not BC18
    local procedure PeriodToInteger(AnalysisPeriodType: Enum "Analysis Period Type"): Integer
    begin
        case AnalysisPeriodType of
            AnalysisPeriodType::Day:
                exit(PeriodType::Day);
            AnalysisPeriodType::Week:
                exit(PeriodType::Week);
            AnalysisPeriodType::Month:
                exit(PeriodType::Month);
            AnalysisPeriodType::Quarter:
                exit(PeriodType::Quarter);
            AnalysisPeriodType::Year:
                exit(PeriodType::Year);
            else
                Error((StrSubstNo(IncorrectPeriodErr, Format(AnalysisPeriodType))));
        end;
    end;
#endif
    local procedure SetShowLastYear()
    begin
        PLYSaleQty := ShowLastYear;
        PLYSale := ShowLastYear;
        PLYProfit := ShowLastYear;
        "PLYProfit%" := ShowLastYear;
        CurrPage.Update(false);
    end;
}

