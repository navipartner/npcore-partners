page 6059988 "NPR Sale Stats Activities"
{
    Caption = 'Sale Statistics';
    PageType = CardPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "Business Chart Buffer";

    layout
    {
        area(content)
        {
            usercontrol(SalesChart; "Microsoft.Dynamics.Nav.Client.BusinessChart")
            {
                ApplicationArea = All;

                trigger AddInReady()
                begin
                end;
            }
            field("Date.GETFILTER(""Period Start"")"; Date.GetFilter("Period Start"))
            {
                ApplicationArea = All;
                ShowCaption = false;
                ToolTip = 'Specifies the value of the Date.GetFilter(Period Start) field';
            }
            field("SELECTSTR(FigureToDisplay+1,Text0001)"; SelectStr(FigureToDisplay + 1, Text0001))
            {
                ApplicationArea = All;
                ShowCaption = false;
                ToolTip = 'Specifies the value of the SelectStr(FigureToDisplay + 1, Text0001) field';
            }
            field("Date.""Period Type"""; Date."Period Type")
            {
                ApplicationArea = All;
                ShowCaption = false;
                ToolTip = 'Specifies the value of the Date.Period Type field';
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
                ApplicationArea = All;
                ToolTip = 'Filters by day';
                Image = Calendar;

                trigger OnAction()
                begin
                    PeriodType := Date."Period Type"::Date;
                    ApplyDateFilter();
                end;
            }
            action("NPR 7")
            {
                Caption = 'Week';
                ApplicationArea = All;
                ToolTip = 'Filters by week';
                Image = Calendar;

                trigger OnAction()
                begin
                    PeriodType := Date."Period Type"::Week;
                    ApplyDateFilter();
                end;
            }
            action("NPR 31")
            {
                Caption = 'Month';
                ApplicationArea = All;
                ToolTip = 'Filters by month';
                Image = Calendar;

                trigger OnAction()
                begin
                    PeriodType := Date."Period Type"::Month;
                    ApplyDateFilter();
                end;
            }
            action("NPR 3")
            {
                Caption = 'Quarter';
                ApplicationArea = All;
                ToolTip = 'Filters by quarter';
                Image = Calendar;

                trigger OnAction()
                begin
                    PeriodType := Date."Period Type"::Quarter;
                    ApplyDateFilter();
                end;
            }
            action("NPR 12")
            {
                Caption = 'Year';
                ApplicationArea = All;
                ToolTip = 'Filters by year';
                Image = Calendar;

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
                ApplicationArea = All;
                ToolTip = 'Executes the Prev action';

                trigger OnAction()
                begin
                    Scroll('-');
                end;
            }
            action("Next")
            {
                Caption = 'Next';
                Image = NextSet;
                ApplicationArea = All;
                ToolTip = 'Executes the Next action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Sale (Qty.) action';

                    trigger OnAction()
                    begin
                        FigureToDisplay := FigureToDisplay::"Sale (Qty.)";
                    end;
                }
                action("Sale (LCY)")
                {
                    Caption = 'Sale (LCY)';
                    Image = SalesPrices;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Sale (LCY) action';

                    trigger OnAction()
                    begin
                        FigureToDisplay := FigureToDisplay::"Sale (LCY)";
                    end;
                }
                action("Profit (LCY)")
                {
                    Caption = 'Profit (LCY)';
                    Image = Turnover;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Profit (LCY) action';

                    trigger OnAction()
                    begin
                        FigureToDisplay := FigureToDisplay::"Profit (LCY)";
                    end;
                }
                action("Profit (Pct.)")
                {
                    Caption = 'Profit (Pct.)';
                    Image = Percentage;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Profit (Pct.) action';

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
                    ApplicationArea = All;
                    ToolTip = 'Creates a point chart';
                    Image = SelectChart;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::Point;
                    end;
                }
                action(Bubble)
                {
                    Caption = 'Bubble';
                    ApplicationArea = All;
                    ToolTip = 'Creates a bubble chart';
                    Image = SelectChart;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::Bubble;
                    end;
                }
                action(Line)
                {
                    Caption = 'Line';
                    ApplicationArea = All;
                    ToolTip = 'Creates a line chart';
                    Image = SelectChart;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::Line;
                    end;
                }
                action(StepLine)
                {
                    Caption = 'StepLine';
                    ApplicationArea = All;
                    ToolTip = 'Creates a stepline chart';
                    Image = SelectChart;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::StepLine;
                    end;
                }
                action(Column)
                {
                    Caption = 'Column';
                    ApplicationArea = All;
                    ToolTip = 'Creates a column chart';
                    Image = SelectChart;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::Column;
                    end;
                }
                action(StackedColumn)
                {
                    Caption = 'StackedColumn';
                    ApplicationArea = All;
                    ToolTip = 'Creates a stackedColumn chart';
                    Image = SelectChart;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::StackedColumn;
                    end;
                }
                action(StackedColumn100)
                {
                    Caption = 'StackedColumn100';
                    ApplicationArea = All;
                    ToolTip = 'Creates a stackedColumn100 chart';
                    Image = SelectChart;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::StackedColumn100;
                    end;
                }
                action("Area")
                {
                    Caption = 'Area';
                    ApplicationArea = All;
                    ToolTip = 'Creates an area chart';
                    Image = SelectChart;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::Area;
                    end;
                }
                action(StackedArea)
                {
                    Caption = 'StackedArea';
                    ApplicationArea = All;
                    ToolTip = 'Creates a stackedArea chart';
                    Image = SelectChart;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::StackedArea;
                    end;
                }
                action(StackedArea100)
                {
                    Caption = 'StackedArea100';
                    ApplicationArea = All;
                    ToolTip = 'Creates a stackedArea100 chart';
                    Image = SelectChart;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::StackedArea100;
                    end;
                }
                action(Pie)
                {
                    Caption = 'Pie';
                    ApplicationArea = All;
                    ToolTip = 'Creates a pie chart';
                    Image = SelectChart;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::Pie;
                    end;
                }
                action(Doughnut)
                {
                    Caption = 'Doughnut';
                    ApplicationArea = All;
                    ToolTip = 'Creates a doughnut chart';
                    Image = SelectChart;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::Doughnut;
                    end;
                }
                action(Range)
                {
                    Caption = 'Range';
                    ApplicationArea = All;
                    ToolTip = 'Creates a range chart';
                    Image = SelectChart;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::Range;
                    end;
                }
                action(Radar)
                {
                    Caption = 'Radar';
                    ApplicationArea = All;
                    ToolTip = 'Creates a radar chart';
                    Image = SelectChart;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::Radar;
                    end;
                }
                action(Funnel)
                {
                    Caption = 'Funnel';
                    ApplicationArea = All;
                    ToolTip = 'Creates a funnel chart';
                    Image = SelectChart;

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
        "Sale (QTY)": Decimal;
        "LastYear Sale (QTY)": Decimal;
        "Sale (LCY)": Decimal;
        "LastYear Sale (LCY)": Decimal;
        "Profit (LCY)": Decimal;
        "LastYear Profit (LCY)": Decimal;
        "Profit %": Decimal;
        "LastYear Profit %": Decimal;
        LastYear: Boolean;
        LastYearCalc: Text[30];
        ShowSameWeekday: Boolean;
        Text0001: Label 'Sale (LCY),Sale (Qty.),Profit (LCY),Profit (Pct.)';
        Text0002: Label 'This Year';
        Text0003: Label 'Last Year';

    procedure UpdateDiagram()
    var
        Itt: Integer;
    begin
        Rec.Initialize;

        Rec.SetXAxis(SelectStr(FigureToDisplay + 1, Text0001), Rec."Data Type"::String);

        Rec.AddMeasure(Text0002, 0, Rec."Data Type"::Decimal, ChartType);
        Rec.AddMeasure(Text0003, 1, Rec."Data Type"::Decimal, ChartType);

        if Date.FindSet() then
            repeat
                Calc();
                Rec.AddColumn(StrSubstNo('%1', Date."Period Name"));
                case FigureToDisplay of
                    FigureToDisplay::"Sale (Qty.)":
                        begin
                            Rec.SetValue(Text0002, Itt, -"Sale (QTY)");
                            Rec.SetValue(Text0003, Itt, -"LastYear Sale (QTY)");
                        end;
                    FigureToDisplay::"Sale (LCY)":
                        begin
                            Rec.SetValue(Text0002, Itt, "Sale (LCY)");
                            Rec.SetValue(Text0003, Itt, "LastYear Sale (LCY)");
                        end;
                    FigureToDisplay::"Profit (LCY)":
                        begin
                            Rec.SetValue(Text0002, Itt, "Profit (LCY)");
                            Rec.SetValue(Text0003, Itt, "LastYear Profit (LCY)");
                        end;
                    FigureToDisplay::"Profit (Pct.)":
                        begin
                            Rec.SetValue(Text0002, Itt, "Profit %");
                            Rec.SetValue(Text0003, Itt, "LastYear Profit %");
                        end;
                end;
                Itt += 1;
            until (Date.Next() = 0) or (Itt = ColumnCount);

        Rec.Update(CurrPage.SalesChart);
    end;

    local procedure Calc()
    var
        AuxValueEntry: Record "NPR Aux. Value Entry";
        AuxItemLedgerEntry: Record "NPR Aux. Item Ledger Entry";
    begin
        //Calc()
        SetValueEntryFilter(AuxValueEntry);
        AuxValueEntry.CalcSums("Cost Amount (Actual)", "Sales Amount (Actual)");

        SetItemLedgerEntryFilter(AuxItemLedgerEntry);
        AuxItemLedgerEntry.CalcSums(Quantity);

        "Sale (QTY)" := AuxItemLedgerEntry.Quantity;
        "Sale (LCY)" := AuxValueEntry."Sales Amount (Actual)";
        "Profit (LCY)" := AuxValueEntry."Sales Amount (Actual)" + AuxValueEntry."Cost Amount (Actual)";
        if "Sale (LCY)" <> 0 then
            "Profit %" := "Profit (LCY)" / "Sale (LCY)" * 100
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

        SetValueEntryFilter(AuxValueEntry);
        AuxValueEntry.CalcSums("Cost Amount (Actual)", "Sales Amount (Actual)");

        SetItemLedgerEntryFilter(AuxItemLedgerEntry);
        AuxItemLedgerEntry.CalcSums(Quantity);

        "LastYear Sale (QTY)" := AuxItemLedgerEntry.Quantity;
        "LastYear Sale (LCY)" := AuxValueEntry."Sales Amount (Actual)";
        "LastYear Profit (LCY)" := AuxValueEntry."Sales Amount (Actual)" + AuxValueEntry."Cost Amount (Actual)";
        if "LastYear Sale (LCY)" <> 0 then
            "LastYear Profit %" := "LastYear Profit (LCY)" / "LastYear Sale (LCY)" * 100
        else
            "LastYear Profit %" := 0;

        LastYear := false;
    end;

    local procedure Scroll(Direction: Text[1])
    begin
        Date.FindSet();
        case PeriodType of
            PeriodType::Day:
                Date.SetFilter("Period Start", '%1..', CalcDate(StrSubstNo('<%1%2D>', Direction, 1), Date."Period Start"));
            PeriodType::Week:
                Date.SetFilter("Period Start", '%1..', CalcDate(StrSubstNo('<%1%2W>', Direction, 1), Date."Period Start"));
            PeriodType::Month:
                Date.SetFilter("Period Start", '%1..', CalcDate(StrSubstNo('<%1%2M>', Direction, 1), Date."Period Start"));
            PeriodType::Quarter:
                Date.SetFilter("Period Start", '%1..', CalcDate(StrSubstNo('<%1%2Q>', Direction, 1), Date."Period Start"));
            PeriodType::Year:
                Date.SetFilter("Period Start", '%1..', CalcDate(StrSubstNo('<%1%2Y>', Direction, 1), Date."Period Start"));
        end;
    end;

    local procedure ApplyDateFilter()
    begin
        Date.SetRange("Period Type", PeriodType);
        case PeriodType of
            PeriodType::Day:
                Date.SetFilter("Period Start", '%1..', CalcDate(StrSubstNo('<CW-1W-%1D+2D>', ColumnCount), Today));
            PeriodType::Week:
                Date.SetFilter("Period Start", '%1..', CalcDate(StrSubstNo('<CW-%1W>', ColumnCount), Today));
            PeriodType::Month:
                Date.SetFilter("Period Start", '%1..', CalcDate(StrSubstNo('<CM-%1M>', ColumnCount), Today));
            PeriodType::Quarter:
                Date.SetFilter("Period Start", '%1..', CalcDate(StrSubstNo('<CQ-%1Q>', ColumnCount), Today));
            PeriodType::Year:
                Date.SetFilter("Period Start", '%1..', CalcDate(StrSubstNo('<CY-%1Y>', ColumnCount), Today));
        end;
    end;

    local procedure SetItemLedgerEntryFilter(var AuxItemLedgerEntry: Record "NPR Aux. Item Ledger Entry")
    begin
        //SetItemLedgerEntryFilter
        AuxItemLedgerEntry.SetCurrentKey("Entry Type", "Posting Date", "Global Dimension 1 Code", "Global Dimension 2 Code");
        AuxItemLedgerEntry.SetRange("Entry Type", AuxItemLedgerEntry."Entry Type"::Sale);
        if not LastYear then
            AuxItemLedgerEntry.SetFilter("Posting Date", '%1..%2', Date."Period Start", Date."Period End")
        else
            AuxItemLedgerEntry.SetFilter("Posting Date", '%1..%2', CalcDate(LastYearCalc, Date."Period Start"), CalcDate(LastYearCalc, Date."Period End"));

        if ItemCategoryFilter <> '' then
            AuxItemLedgerEntry.SetRange("Item Category Code", ItemCategoryFilter)
        else
            AuxItemLedgerEntry.SetRange("Item Category Code");

        if Dim1Filter <> '' then
            AuxItemLedgerEntry.SetRange("Global Dimension 1 Code", Dim1Filter)
        else
            AuxItemLedgerEntry.SetRange("Global Dimension 1 Code");

        if Dim2Filter <> '' then
            AuxItemLedgerEntry.SetRange("Global Dimension 2 Code", Dim2Filter)
        else
            AuxItemLedgerEntry.SetRange("Global Dimension 2 Code");
    end;

    local procedure SetValueEntryFilter(var AuxValueEntry: Record "NPR Aux. Value Entry")
    begin
        //SetValueEntryFilter
        AuxValueEntry.SetRange("Item Ledger Entry Type", AuxValueEntry."Item Ledger Entry Type"::Sale);
        if not LastYear then
            AuxValueEntry.SetFilter("Posting Date", '%1..%2', Date."Period Start", Date."Period End")
        else
            AuxValueEntry.SetFilter("Posting Date", '%1..%2', CalcDate(LastYearCalc, Date."Period Start"), CalcDate(LastYearCalc, Date."Period End"));

        if ItemCategoryFilter <> '' then
            AuxValueEntry.SetRange("Item Category Code", ItemCategoryFilter)
        else
            AuxValueEntry.SetRange("Item Category Code");

        if Dim1Filter <> '' then
            AuxValueEntry.SetRange("Global Dimension 1 Code", Dim1Filter)
        else
            AuxValueEntry.SetRange("Global Dimension 1 Code");

        if Dim2Filter <> '' then
            AuxValueEntry.SetRange("Global Dimension 2 Code", Dim2Filter)
        else
            AuxValueEntry.SetRange("Global Dimension 2 Code");
    end;

    procedure "-- Public Functions"()
    begin
    end;

    procedure SetDim1Filter(Dim1FilterIn: Code[20])
    begin
        Dim1Filter := Dim1FilterIn;
    end;

    procedure SetDim2Filter(Dim2FilterIn: Code[20])
    begin
        Dim2Filter := Dim2FilterIn;
    end;

    procedure SetItemGroupFilter(ItemGroupFilterIn: Code[20])
    begin
        ItemCategoryFilter := ItemGroupFilterIn;
    end;

    procedure SetDateFilter(DateFilterIn: Text[50])
    begin
        DateFilter := DateFilterIn;
    end;

    procedure SetPeriodType(PeriodTypeIn: Integer)
    begin
        PeriodType := PeriodTypeIn;
    end;

    procedure SetFigureToDisplay(FigureToDisplayIn: Integer)
    begin
        FigureToDisplay := FigureToDisplayIn;
    end;
}

