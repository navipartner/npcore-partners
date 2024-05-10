page 6059988 "NPR Sale Stats Activities"
{
    Extensible = False;
    Caption = 'Sale Statistics';
    PageType = CardPart;
    UsageCategory = None;
    SourceTable = "Business Chart Buffer";

    layout
    {
        area(content)
        {
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
            usercontrol(SalesChart; BusinessChart)
#ELSE
            usercontrol(SalesChart; "Microsoft.Dynamics.Nav.Client.BusinessChart")
#ENDIF
            {
                ApplicationArea = NPRRetail;


                trigger AddInReady()
                begin
                end;
            }
            field("Period Start Filter"; Date.GetFilter("Period Start"))
            {
                ApplicationArea = NPRRetail;
                ShowCaption = false;
                ToolTip = 'Specifies the value of the Period Start filter';
            }
            field("Figure to display"; SelectStr(FigureToDisplay + 1, Text0001))
            {
                ApplicationArea = NPRRetail;
                ShowCaption = false;
                ToolTip = 'Specifies Figure to display';
            }
            field("Period Type"; Date."Period Type")
            {

                ShowCaption = false;
                ToolTip = 'Specifies the value of the Date.Period Type field';
                ApplicationArea = NPRRetail;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("NPR 1")
            {
                Caption = 'Day';

                ToolTip = 'Filters by day';
                Image = Calendar;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    PeriodType := Date."Period Type"::Date;
                    ApplyDateFilter();
                end;
            }
            action("NPR 7")
            {
                Caption = 'Week';

                ToolTip = 'Filters by week';
                Image = Calendar;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    PeriodType := Date."Period Type"::Week;
                    ApplyDateFilter();
                end;
            }
            action("NPR 31")
            {
                Caption = 'Month';

                ToolTip = 'Filters by month';
                Image = Calendar;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    PeriodType := Date."Period Type"::Month;
                    ApplyDateFilter();
                end;
            }
            action("NPR 3")
            {
                Caption = 'Quarter';

                ToolTip = 'Filters by quarter';
                Image = Calendar;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    PeriodType := Date."Period Type"::Quarter;
                    ApplyDateFilter();
                end;
            }
            action("NPR 12")
            {
                Caption = 'Year';

                ToolTip = 'Filters by year';
                Image = Calendar;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    PeriodType := Date."Period Type"::Year;
                    ApplyDateFilter();
                end;
            }
            action(Prev)
            {
                Caption = 'Prev';
                Image = PreviousSet;

                ToolTip = 'Executes the Prev action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Scroll('-');
                end;
            }
            action("Next")
            {
                Caption = 'Next';
                Image = NextSet;

                ToolTip = 'Executes the Next action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Scroll('+');
                end;
            }
            group(ActionGroup6150620)
            {
                Image = Statistics;
                action("Sale (Qty.)")
                {
                    Caption = 'Sale (Qty.)';
                    Image = Sales;

                    ToolTip = 'Executes the Sale (Qty.) action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        FigureToDisplay := FigureToDisplay::"Sale (Qty.)";
                    end;
                }
                action("Sale (LCY)")
                {
                    Caption = 'Sale (LCY)';
                    Image = SalesPrices;

                    ToolTip = 'Executes the Sale (LCY) action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        FigureToDisplay := FigureToDisplay::"Sale (LCY)";
                    end;
                }
                action("Profit (LCY)")
                {
                    Caption = 'Profit (LCY)';
                    Image = Turnover;

                    ToolTip = 'Executes the Profit (LCY) action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        FigureToDisplay := FigureToDisplay::"Profit (LCY)";
                    end;
                }
                action("Profit (Pct.)")
                {
                    Caption = 'Profit (Pct.)';
                    Image = Percentage;

                    ToolTip = 'Executes the Profit (Pct.) action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        FigureToDisplay := FigureToDisplay::"Profit (Pct.)";
                    end;
                }
            }
            group(ActionGroup6150623)
            {
                Image = AnalysisView;
                action(Point)
                {
                    Caption = 'Point';

                    ToolTip = 'Creates a point chart';
                    Image = SelectChart;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::Point;
                    end;
                }
                action(Bubble)
                {
                    Caption = 'Bubble';

                    ToolTip = 'Creates a bubble chart';
                    Image = SelectChart;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::Bubble;
                    end;
                }
                action(Line)
                {
                    Caption = 'Line';

                    ToolTip = 'Creates a line chart';
                    Image = SelectChart;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::Line;
                    end;
                }
                action(StepLine)
                {
                    Caption = 'StepLine';

                    ToolTip = 'Creates a stepline chart';
                    Image = SelectChart;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::StepLine;
                    end;
                }
                action(Column)
                {
                    Caption = 'Column';

                    ToolTip = 'Creates a column chart';
                    Image = SelectChart;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::Column;
                    end;
                }
                action(StackedColumn)
                {
                    Caption = 'StackedColumn';

                    ToolTip = 'Creates a stackedColumn chart';
                    Image = SelectChart;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::StackedColumn;
                    end;
                }
                action(StackedColumn100)
                {
                    Caption = 'StackedColumn100';

                    ToolTip = 'Creates a stackedColumn100 chart';
                    Image = SelectChart;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::StackedColumn100;
                    end;
                }
                action("Area")
                {
                    Caption = 'Area';

                    ToolTip = 'Creates an area chart';
                    Image = SelectChart;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::Area;
                    end;
                }
                action(StackedArea)
                {
                    Caption = 'StackedArea';

                    ToolTip = 'Creates a stackedArea chart';
                    Image = SelectChart;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::StackedArea;
                    end;
                }
                action(StackedArea100)
                {
                    Caption = 'StackedArea100';

                    ToolTip = 'Creates a stackedArea100 chart';
                    Image = SelectChart;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::StackedArea100;
                    end;
                }
                action(Pie)
                {
                    Caption = 'Pie';

                    ToolTip = 'Creates a pie chart';
                    Image = SelectChart;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::Pie;
                    end;
                }
                action(Doughnut)
                {
                    Caption = 'Doughnut';

                    ToolTip = 'Creates a doughnut chart';
                    Image = SelectChart;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::Doughnut;
                    end;
                }
                action(Range)
                {
                    Caption = 'Range';

                    ToolTip = 'Creates a range chart';
                    Image = SelectChart;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::Range;
                    end;
                }
                action(Radar)
                {
                    Caption = 'Radar';

                    ToolTip = 'Creates a radar chart';
                    Image = SelectChart;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::Radar;
                    end;
                }
                action(Funnel)
                {
                    Caption = 'Funnel';

                    ToolTip = 'Creates a funnel chart';
                    Image = SelectChart;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::Funnel;
                    end;
                }
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        UpdateDiagram();
    end;

    trigger OnOpenPage()
    begin
        case true of
            Rec.ID = Context::Retail:
                ;
        end;

        PeriodType := PeriodType::Day;
        ChartType := ChartType::Column;
        ColumnCount := 7;
        ApplyDateFilter();
    end;

    var
        Date: Record Date;
        Dim1Filter: Code[20];
        Dim2Filter: Code[20];
        ItemCategoryFilter: Code[20];
        DateFilter: Text[50];
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period;
        ChartType: Option Point,Bubble,Line,StepLine,Column,StackedColumn,StackedColumn100,"Area",StackedArea,StackedArea100,Pie,Doughnut,Range,Radar,Funnel;
        FigureToDisplay: Option "Sale (LCY)","Sale (Qty.)","Profit (LCY)","Profit (Pct.)";
        Context: Option Retail,Web;
        ColumnCount: Integer;
        SaleQTY: Decimal;
        LastYearSaleQTY: Decimal;
        SaleLCY: Decimal;
        LastYearSaleLCY: Decimal;
        ProfitLCY: Decimal;
        LastYearProfitLCY: Decimal;
        "Profit %": Decimal;
        "LastYear Profit %": Decimal;
        LastYear: Boolean;
        LastYearCalc: Text[30];
        ShowSameWeekday: Boolean;
        Text0001: Label 'Sale (LCY),Sale (Qty.),Profit (LCY),Profit (Pct.)';
        Text0002: Label 'This Year';
        Text0003: Label 'Last Year';
        PeriodNameLbl: Label '%1', Locked = true;

    internal procedure UpdateDiagram()
    var
        Itt: Integer;
    begin
        Rec.Initialize();

        Rec.SetXAxis(SelectStr(FigureToDisplay + 1, Text0001), Rec."Data Type"::String);

        Rec.AddMeasure(Text0002, 0, Rec."Data Type"::Decimal, ChartType);
        Rec.AddMeasure(Text0003, 1, Rec."Data Type"::Decimal, ChartType);

        if Date.FindSet() then
            repeat
                Calc();
                Rec.AddColumn(StrSubstNo(PeriodNameLbl, Date."Period Name"));
                case FigureToDisplay of
                    FigureToDisplay::"Sale (Qty.)":
                        begin
                            Rec.SetValue(Text0002, Itt, -SaleQTY);
                            Rec.SetValue(Text0003, Itt, -LastYearSaleQTY);
                        end;
                    FigureToDisplay::"Sale (LCY)":
                        begin
                            Rec.SetValue(Text0002, Itt, SaleLCY);
                            Rec.SetValue(Text0003, Itt, LastYearSaleLCY);
                        end;
                    FigureToDisplay::"Profit (LCY)":
                        begin
                            Rec.SetValue(Text0002, Itt, ProfitLCY);
                            Rec.SetValue(Text0003, Itt, LastYearProfitLCY);
                        end;
                    FigureToDisplay::"Profit (Pct.)":
                        begin
                            Rec.SetValue(Text0002, Itt, "Profit %");
                            Rec.SetValue(Text0003, Itt, "LastYear Profit %");
                        end;
                end;
                Itt += 1;
            until (Date.Next() = 0) or (Itt = ColumnCount);

#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        Rec.UpdateChart(CurrPage.SalesChart);
#ELSE
        Rec.Update(CurrPage.SalesChart);
#ENDIF
    end;

    local procedure Calc()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        SalesAmountActual: Decimal;
        CostAmountActual: Decimal;
    begin
        //Calc()
        SetValueEntryFilter(CostAmountActual, SalesAmountActual);

        SetItemLedgerEntryFilter(ItemLedgerEntry);
        ItemLedgerEntry.CalcSums(Quantity);

        SaleQTY := ItemLedgerEntry.Quantity;
        SaleLCY := SalesAmountActual;
        ProfitLCY := SalesAmountActual + CostAmountActual;
        if SaleLCY <> 0 then
            "Profit %" := ProfitLCY / SaleLCY * 100
        else
            "Profit %" := 0;

        // Calc last year
        LastYear := true;
        if ((PeriodType = PeriodType::Day) and ShowSameWeekday) or (PeriodType = PeriodType::Week) then
            LastYearCalc := '<-52W>'
        else
            LastYearCalc := '<-1Y>';

        if (Date2DMY(Date."Period Start", 3) < 1) or (Date2DMY(Date."Period Start", 3) > 9998) then
            LastYearCalc := '';

        SetValueEntryFilter(CostAmountActual, SalesAmountActual);

        SetItemLedgerEntryFilter(ItemLedgerEntry);
        ItemLedgerEntry.CalcSums(Quantity);

        LastYearSaleQTY := ItemLedgerEntry.Quantity;
        LastYearSaleLCY := SalesAmountActual;
        LastYearProfitLCY := SalesAmountActual + CostAmountActual;
        if LastYearSaleLCY <> 0 then
            "LastYear Profit %" := LastYearProfitLCY / LastYearSaleLCY * 100
        else
            "LastYear Profit %" := 0;

        LastYear := false;
    end;

    local procedure Scroll(Direction: Text[1])
    var
        DayLbl: Label '<%1%2D>', Locked = true;
        WeekLbl: Label '<%1%2W>', Locked = true;
        MonthLbl: Label '<%1%2M>', Locked = true;
        QuarterLbl: Label '<%1%2Q>', Locked = true;
        YearLbl: Label '<%1%2Y>', Locked = true;
    begin
        Date.FindSet();
        case PeriodType of
            PeriodType::Day:
                Date.SetFilter("Period Start", '%1..', CalcDate(StrSubstNo(DayLbl, Direction, 1), Date."Period Start"));
            PeriodType::Week:
                Date.SetFilter("Period Start", '%1..', CalcDate(StrSubstNo(WeekLbl, Direction, 1), Date."Period Start"));
            PeriodType::Month:
                Date.SetFilter("Period Start", '%1..', CalcDate(StrSubstNo(MonthLbl, Direction, 1), Date."Period Start"));
            PeriodType::Quarter:
                Date.SetFilter("Period Start", '%1..', CalcDate(StrSubstNo(QuarterLbl, Direction, 1), Date."Period Start"));
            PeriodType::Year:
                Date.SetFilter("Period Start", '%1..', CalcDate(StrSubstNo(YearLbl, Direction, 1), Date."Period Start"));
        end;
    end;

    local procedure ApplyDateFilter()
    var
        DayLbl: Label '<CW-1W-%1D+2D>', Locked = true;
        WeekLbl: Label '<CW-%1W>', Locked = true;
        MonthLbl: Label '<CM-%1M>', Locked = true;
        QuarterLbl: Label '<CQ-%1Q>', Locked = true;
        YearLbl: Label '<CY-%1Y>', Locked = true;
    begin
        Date.SetRange("Period Type", PeriodType);
        case PeriodType of
            PeriodType::Day:
                Date.SetFilter("Period Start", '%1..', CalcDate(StrSubstNo(DayLbl, ColumnCount), Today));
            PeriodType::Week:
                Date.SetFilter("Period Start", '%1..', CalcDate(StrSubstNo(WeekLbl, ColumnCount), Today));
            PeriodType::Month:
                Date.SetFilter("Period Start", '%1..', CalcDate(StrSubstNo(MonthLbl, ColumnCount), Today));
            PeriodType::Quarter:
                Date.SetFilter("Period Start", '%1..', CalcDate(StrSubstNo(QuarterLbl, ColumnCount), Today));
            PeriodType::Year:
                Date.SetFilter("Period Start", '%1..', CalcDate(StrSubstNo(YearLbl, ColumnCount), Today));
        end;
    end;

    local procedure SetItemLedgerEntryFilter(var ItemLedgerEntry: Record "Item Ledger Entry")
    begin
        //SetItemLedgerEntryFilter
        ItemLedgerEntry.SetCurrentKey("Entry Type", "Posting Date", "Global Dimension 1 Code", "Global Dimension 2 Code");
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Sale);
        if not LastYear then
            ItemLedgerEntry.SetFilter("Posting Date", '%1..%2', Date."Period Start", Date."Period End")
        else
            ItemLedgerEntry.SetFilter("Posting Date", '%1..%2', CalcDate(LastYearCalc, Date."Period Start"), CalcDate(LastYearCalc, Date."Period End"));

        if ItemCategoryFilter <> '' then
            ItemLedgerEntry.SetRange("Item Category Code", ItemCategoryFilter)
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

    local procedure SetValueEntryFilter(var CostAmount: Decimal; var SalesAmount: Decimal)
    var
        ValueEntry: Record "Value Entry";
        ValueEntryWithItemCat: Query "NPR Value Entry With Item Cat";
    begin
        Clear(SalesAmount);
        Clear(CostAmount);
        //SetValueEntryFilter
        case ItemCategoryFilter <> '' of
            true:
                begin
                    ValueEntryWithItemCat.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
                    if not LastYear then
                        ValueEntryWithItemCat.SetFilter(Filter_DateTime, '%1..%2', Date."Period Start", Date."Period End")
                    else
                        ValueEntryWithItemCat.SetFilter(Filter_DateTime, '%1..%2', CalcDate(LastYearCalc, Date."Period Start"), CalcDate(LastYearCalc, Date."Period End"));

                    ValueEntryWithItemCat.SetRange(Filter_Item_Category_Code, ItemCategoryFilter);

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
                    if not LastYear then
                        ValueEntry.SetFilter("Posting Date", '%1..%2', Date."Period Start", Date."Period End")
                    else
                        ValueEntry.SetFilter("Posting Date", '%1..%2', CalcDate(LastYearCalc, Date."Period Start"), CalcDate(LastYearCalc, Date."Period End"));

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

    internal procedure "-- Public Functions"()
    begin
    end;

    internal procedure SetDim1Filter(Dim1FilterIn: Code[20])
    begin
        Dim1Filter := Dim1FilterIn;
    end;

    internal procedure SetDim2Filter(Dim2FilterIn: Code[20])
    begin
        Dim2Filter := Dim2FilterIn;
    end;

    internal procedure SetItemGroupFilter(ItemGroupFilterIn: Code[20])
    begin
        ItemCategoryFilter := ItemGroupFilterIn;
    end;

    internal procedure SetDateFilter(DateFilterIn: Text[50])
    begin
        DateFilter := DateFilterIn;
    end;

    internal procedure SetPeriodType(PeriodTypeIn: Integer)
    begin
        PeriodType := PeriodTypeIn;
    end;

    internal procedure SetFigureToDisplay(FigureToDisplayIn: Integer)
    begin
        FigureToDisplay := FigureToDisplayIn;
    end;
}

