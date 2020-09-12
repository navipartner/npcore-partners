page 6059988 "NPR Sale Stats Activities"
{
    // NPR80.00.01.00/MH/20150217  CASE 199932 Removed Web Reference
    // NPR5.31/TJ  /20170328 CASE 269797 Switched control addin to use version 10.0.0.0 instead of 9.0.0.0
    // NPR5.41/TS  /20180105 CASE 300893 ActionContainers cannot have captions
    // NPR5.50/JAVA/20190619 CASE 359388 Update addins references to point to the correct version (13.0.0.0 => 14.0.0.0).
    // NPR5.55/BHR /20200724 CASE 361515 Comment Key not used in AL

    Caption = 'Sale Statistics';
    PageType = CardPart;
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
            }
            field("SELECTSTR(FigureToDisplay+1,Text0001)"; SelectStr(FigureToDisplay + 1, Text0001))
            {
                ApplicationArea = All;
                ShowCaption = false;
            }
            field("Date.""Period Type"""; Date."Period Type")
            {
                ApplicationArea = All;
                ShowCaption = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("NPR 1")
            {
                Caption = '1';
                ApplicationArea = All;

                trigger OnAction()
                begin
                    PeriodType := Date."Period Type"::Date;
                    ApplyDateFilter();
                end;
            }
            action("NPR 7")
            {
                Caption = '7';
                ApplicationArea = All;

                trigger OnAction()
                begin
                    PeriodType := Date."Period Type"::Week;
                    ApplyDateFilter();
                end;
            }
            action("NPR 31")
            {
                Caption = '31';
                ApplicationArea = All;

                trigger OnAction()
                begin
                    PeriodType := Date."Period Type"::Month;
                    ApplyDateFilter();
                end;
            }
            action("NPR 3")
            {
                Caption = '3';
                ApplicationArea = All;

                trigger OnAction()
                begin
                    PeriodType := Date."Period Type"::Quarter;
                    ApplyDateFilter();
                end;
            }
            action("NPR 12")
            {
                Caption = '12';
                ApplicationArea = All;

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

                    trigger OnAction()
                    begin
                        ChartType := ChartType::Point;
                    end;
                }
                action(Bubble)
                {
                    Caption = 'Bubble';
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::Bubble;
                    end;
                }
                action(Line)
                {
                    Caption = 'Line';
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::Line;
                    end;
                }
                action(StepLine)
                {
                    Caption = 'StepLine';
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::StepLine;
                    end;
                }
                action(Column)
                {
                    Caption = 'Column';
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::Column;
                    end;
                }
                action(StackedColumn)
                {
                    Caption = 'StackedColumn';
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::StackedColumn;
                    end;
                }
                action(StackedColumn100)
                {
                    Caption = 'StackedColumn100';
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::StackedColumn100;
                    end;
                }
                action("Area")
                {
                    Caption = 'Area';
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::Area;
                    end;
                }
                action(StackedArea)
                {
                    Caption = 'StackedArea';
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::StackedArea;
                    end;
                }
                action(StackedArea100)
                {
                    Caption = 'StackedArea100';
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::StackedArea100;
                    end;
                }
                action(Pie)
                {
                    Caption = 'Pie';
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::Pie;
                    end;
                }
                action(Doughnut)
                {
                    Caption = 'Doughnut';
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::Doughnut;
                    end;
                }
                action(Range)
                {
                    Caption = 'Range';
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::Range;
                    end;
                }
                action(Radar)
                {
                    Caption = 'Radar';
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        ChartType := ChartType::Radar;
                    end;
                }
                action(Funnel)
                {
                    Caption = 'Funnel';
                    ApplicationArea = All;

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
            ID = Context::Retail:
                ;
        end;

        PeriodType := PeriodType::Day;
        ChartType := ChartType::Column;
        ColumnCount := 7;
        ApplyDateFilter();
    end;

    var
        Date: Record Date;
        "-- Settings": Integer;
        Dim1Filter: Code[20];
        Dim2Filter: Code[20];
        ItemGroupFilter: Code[20];
        DateFilter: Text[50];
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period;
        ChartType: Option Point,Bubble,Line,StepLine,Column,StackedColumn,StackedColumn100,"Area",StackedArea,StackedArea100,Pie,Doughnut,Range,Radar,Funnel;
        FigureToDisplay: Option "Sale (LCY)","Sale (Qty.)","Profit (LCY)","Profit (Pct.)";
        Context: Option Retail,Web;
        "-- Layout": Integer;
        ColumnCount: Integer;
        "-- Vars": Integer;
        PeriodFormMan: Codeunit PeriodFormManagement;
        "Sale (QTY)": Decimal;
        "LastYear Sale (QTY)": Decimal;
        "Sale (LCY)": Decimal;
        "LastYear Sale (LCY)": Decimal;
        "Profit (LCY)": Decimal;
        "LastYear Profit (LCY)": Decimal;
        "Profit %": Decimal;
        "LastYear Profit %": Decimal;
        LastYear: Boolean;
        ShowLastYear: Boolean;
        LastYearCalc: Text[30];
        ShowSameWeekday: Boolean;
        DateFilterLastYear: Text[50];
        Text0001: Label 'Sale (LCY),Sale (Qty.),Profit (LCY),Profit (Pct.)';
        Text0002: Label 'This Year';
        Text0003: Label 'Last Year';

    procedure UpdateDiagram()
    var
        Itt: Integer;
    begin
        Initialize;

        SetXAxis(SelectStr(FigureToDisplay + 1, Text0001), "Data Type"::String);

        AddMeasure(Text0002, 0, "Data Type"::Decimal, ChartType);
        AddMeasure(Text0003, 1, "Data Type"::Decimal, ChartType);

        if Date.FindSet then
            repeat
                Calc();
                AddColumn(StrSubstNo('%1', Date."Period Name"));
                case FigureToDisplay of
                    FigureToDisplay::"Sale (Qty.)":
                        begin
                            SetValue(Text0002, Itt, -"Sale (QTY)");
                            SetValue(Text0003, Itt, -"LastYear Sale (QTY)");
                        end;
                    FigureToDisplay::"Sale (LCY)":
                        begin
                            SetValue(Text0002, Itt, "Sale (LCY)");
                            SetValue(Text0003, Itt, "LastYear Sale (LCY)");
                        end;
                    FigureToDisplay::"Profit (LCY)":
                        begin
                            SetValue(Text0002, Itt, "Profit (LCY)");
                            SetValue(Text0003, Itt, "LastYear Profit (LCY)");
                        end;
                    FigureToDisplay::"Profit (Pct.)":
                        begin
                            SetValue(Text0002, Itt, "Profit %");
                            SetValue(Text0003, Itt, "LastYear Profit %");
                        end;
                end;
                Itt += 1;
            until (Date.Next = 0) or (Itt = ColumnCount);

        Update(CurrPage.SalesChart);
    end;

    local procedure Calc()
    var
        ValueEntry: Record "Value Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        AuditRoll: Record "NPR Audit Roll";
    begin
        //Calc()
        SetValueEntryFilter(ValueEntry);
        ValueEntry.CalcSums("Cost Amount (Actual)", "Sales Amount (Actual)");

        SetItemLedgerEntryFilter(ItemLedgerEntry);
        ItemLedgerEntry.CalcSums(Quantity);

        "Sale (QTY)" := ItemLedgerEntry.Quantity;
        "Sale (LCY)" := ValueEntry."Sales Amount (Actual)";
        "Profit (LCY)" := ValueEntry."Sales Amount (Actual)" + ValueEntry."Cost Amount (Actual)";
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

        SetValueEntryFilter(ValueEntry);
        ValueEntry.CalcSums("Cost Amount (Actual)", "Sales Amount (Actual)");

        SetItemLedgerEntryFilter(ItemLedgerEntry);
        ItemLedgerEntry.CalcSums(Quantity);

        "LastYear Sale (QTY)" := ItemLedgerEntry.Quantity;
        "LastYear Sale (LCY)" := ValueEntry."Sales Amount (Actual)";
        "LastYear Profit (LCY)" := ValueEntry."Sales Amount (Actual)" + ValueEntry."Cost Amount (Actual)";
        if "LastYear Sale (LCY)" <> 0 then
            "LastYear Profit %" := "LastYear Profit (LCY)" / "LastYear Sale (LCY)" * 100
        else
            "LastYear Profit %" := 0;

        LastYear := false;
    end;

    local procedure Scroll(Direction: Text[1])
    begin
        Date.FindSet;
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

    local procedure SetItemLedgerEntryFilter(var ItemLedgerEntry: Record "Item Ledger Entry")
    begin
        //SetItemLedgerEntryFilter
        ItemLedgerEntry.SetCurrentKey("Entry Type", "Posting Date", "Global Dimension 1 Code", "Global Dimension 2 Code");
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Sale);
        if not LastYear then
            ItemLedgerEntry.SetFilter("Posting Date", '%1..%2', Date."Period Start", Date."Period End")
        else
            ItemLedgerEntry.SetFilter("Posting Date", '%1..%2', CalcDate(LastYearCalc, Date."Period Start"), CalcDate(LastYearCalc, Date."Period End"));

        if ItemGroupFilter <> '' then
            ItemLedgerEntry.SetRange("NPR Item Group No.", ItemGroupFilter)
        else
            ItemLedgerEntry.SetRange("NPR Item Group No.");

        if Dim1Filter <> '' then
            ItemLedgerEntry.SetRange("Global Dimension 1 Code", Dim1Filter)
        else
            ItemLedgerEntry.SetRange("Global Dimension 1 Code");

        if Dim2Filter <> '' then
            ItemLedgerEntry.SetRange("Global Dimension 2 Code", Dim2Filter)
        else
            ItemLedgerEntry.SetRange("Global Dimension 2 Code");
    end;

    local procedure SetValueEntryFilter(var ValueEntry: Record "Value Entry")
    begin
        //SetValueEntryFilter
        //-NPR5.55 [361515]
        //ValueEntry.SETCURRENTKEY( "Item Ledger Entry Type", "Posting Date", "Global Dimension 1 Code", "Global Dimension 2 Code" );
        //+NPR5.55 [361515]
        ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
        if not LastYear then
            ValueEntry.SetFilter("Posting Date", '%1..%2', Date."Period Start", Date."Period End")
        else
            ValueEntry.SetFilter("Posting Date", '%1..%2', CalcDate(LastYearCalc, Date."Period Start"), CalcDate(LastYearCalc, Date."Period End"));

        if ItemGroupFilter <> '' then
            ValueEntry.SetRange("NPR Item Group No.", ItemGroupFilter)
        else
            ValueEntry.SetRange("NPR Item Group No.");

        if Dim1Filter <> '' then
            ValueEntry.SetRange("Global Dimension 1 Code", Dim1Filter)
        else
            ValueEntry.SetRange("Global Dimension 1 Code");

        if Dim2Filter <> '' then
            ValueEntry.SetRange("Global Dimension 2 Code", Dim2Filter)
        else
            ValueEntry.SetRange("Global Dimension 2 Code");
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
        ItemGroupFilter := ItemGroupFilterIn;
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

