page 6059818 "NPR Retail Sales Chart by Shop"
{
    // NPR5.29/BHR/20170104 CASE 262439 Chart of sales by store
    // NPR5.31/TJ  /20170328 CASE 269797 Switched control addin to use version 10.0.0.0 instead of 9.0.0.0
    // NPR5.50/JAVA/20190619 CASE 359388 Update addins references to point to the correct version (13.0.0.0 => 14.0.0.0).

    Caption = 'Margin/Turnover by Shop';
    PageType = CardPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "Business Chart Buffer";

    layout
    {
        area(content)
        {
            field("Date Range"; StatusText)
            {
                ApplicationArea = All;
                ShowCaption = true;
                Style = Strong;
                StyleExpr = TRUE;
                ToolTip = 'Specifies the value of the StatusText field';
            }
            usercontrol(chart; "Microsoft.Dynamics.Nav.Client.BusinessChart")
            {
                ApplicationArea = All;
                trigger AddInReady()
                begin
                    ChartIsReady := true;
                    UpdateChart;
                end;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("Period Length")
            {
                Caption = 'Period Length';
                Image = Period;
                action(Day)
                {
                    Caption = 'Day';
                    ApplicationArea = All;
                    ToolTip = 'Filters by day';
                    Image = Filter; 

                    trigger OnAction()
                    begin
                        Period := Period::" ";
                        PeriodType := PeriodType::Day;
                        UpdateChart;
                    end;
                }
                action(Week)
                {
                    Caption = 'Week';
                    ApplicationArea = All;
                    ToolTip = 'Filters by week';
                    Image = Filter;

                    trigger OnAction()
                    begin
                        Period := Period::" ";
                        PeriodType := PeriodType::Week;
                        UpdateChart;
                    end;
                }
                action(Month)
                {
                    Caption = 'Month';
                    ApplicationArea = All;
                    ToolTip = 'Filters by month';
                    Image = Filter;

                    trigger OnAction()
                    begin
                        Period := Period::" ";
                        PeriodType := PeriodType::Month;
                        UpdateChart;
                    end;
                }
                action(Quarter)
                {
                    Caption = 'Quarter';
                    ApplicationArea = All;
                    ToolTip = 'Filters by quarter';
                    Image = Filter;

                    trigger OnAction()
                    begin
                        Period := Period::" ";
                        PeriodType := PeriodType::Quarter;
                        UpdateChart;
                    end;
                }
                action(Year)
                {
                    Caption = 'Year';
                    ApplicationArea = All;
                    ToolTip = 'Filters by year';
                    Image = Filter;

                    trigger OnAction()
                    begin
                        Period := Period::" ";
                        PeriodType := PeriodType::Year;
                        UpdateChart;
                    end;
                }
            }
            action(Previous)
            {
                Caption = 'Previous';
                Image = PreviousRecord;
                ApplicationArea = All;
                ToolTip = 'Executes the Previous action';

                trigger OnAction()
                begin
                    Period := Period::Previous;
                    UpdateChart;
                end;
            }
            action("Next")
            {
                Caption = 'Next';
                Image = NextRecord;
                ApplicationArea = All;
                ToolTip = 'Executes the Next action';

                trigger OnAction()
                begin
                    Period := Period::Next;
                    UpdateChart;
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        RetailSetup.Get;
    end;

    var
        ChartIsReady: Boolean;
        BusChartBuf: Record "Business Chart Buffer";
        ChartMgt: Codeunit "NPR Retail Chart Mgt by Shop";
        StatusText: Text[250];
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period;
        Period: Option " ",Next,Previous;
        SalesByPeriod: array[5] of Decimal;
        OrderCount: array[5] of Decimal;
        StartDate: Date;
        Enddate: Date;
        RetailSetup: Record "NPR Retail Setup";

    local procedure UpdateChart()
    begin
        if not ChartIsReady then
            exit;
        case RetailSetup."Margin and Turnover By Shop" of
            RetailSetup."Margin and Turnover By Shop"::" ", RetailSetup."Margin and Turnover By Shop"::Dimension2:
                ChartMgt.TurnOver_RevenuebyDim2(BusChartBuf, Period, PeriodType, StartDate, Enddate);
            RetailSetup."Margin and Turnover By Shop"::Dimension1:
                ChartMgt.TurnOver_RevenuebyDim1(BusChartBuf, Period, PeriodType, StartDate, Enddate);
        end;
        BusChartBuf.Update(CurrPage.chart);
        StatusText := StrSubstNo('%1 to %2', StartDate, Enddate);
    end;
}

