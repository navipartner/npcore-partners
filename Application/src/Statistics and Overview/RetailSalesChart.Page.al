page 6059813 "NPR Retail Sales Chart"
{
    Extensible = False;
    Caption = 'Margin/Turnover by Period';
    PageType = CardPart;
    UsageCategory = None;
    SourceTable = "Business Chart Buffer";

    layout
    {
        area(content)
        {
            field("Date Range"; StatusText)
            {

                Caption = 'Date Range';
                ShowCaption = true;
                Style = Strong;
                StyleExpr = TRUE;
                ToolTip = 'Specifies the value of the StatusText field';
                ApplicationArea = NPRRetail;
            }
            usercontrol(chart; "Microsoft.Dynamics.Nav.Client.BusinessChart")
            {
                ApplicationArea = NPRRetail;

                trigger AddInReady()
                begin
                    ChartIsReady := true;
                    UpdateChart();
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

                    ToolTip = 'Filter by day';
                    Image = Filter;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Period := Period::" ";
                        PeriodType := PeriodType::Day;
                        UpdateChart();
                    end;
                }
                action(Week)
                {
                    Caption = 'Week';

                    ToolTip = 'Filter by week';
                    Image = Filter;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Period := Period::" ";
                        PeriodType := PeriodType::Week;
                        UpdateChart();
                    end;
                }
                action(Month)
                {
                    Caption = 'Month';

                    ToolTip = 'Filter by month';
                    Image = Filter;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Period := Period::" ";
                        PeriodType := PeriodType::Month;
                        UpdateChart();
                    end;
                }
                action(Quarter)
                {
                    Caption = 'Quarter';

                    ToolTip = 'Filter by quarter';
                    Image = Filter;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Period := Period::" ";
                        PeriodType := PeriodType::Quarter;
                        UpdateChart();
                    end;
                }
                action(Year)
                {
                    Caption = 'Year';

                    ToolTip = 'Filter by year';
                    Image = Filter;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Period := Period::" ";
                        PeriodType := PeriodType::Year;
                        UpdateChart();
                    end;
                }
            }
            action(Previous)
            {
                Caption = 'Previous';
                Image = PreviousRecord;

                ToolTip = 'Executes the Previous action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Period := Period::Previous;
                    UpdateChart();
                end;
            }
            action("Next")
            {
                Caption = 'Next';
                Image = NextRecord;

                ToolTip = 'Executes the Next action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Period := Period::Next;
                    UpdateChart();
                end;
            }
        }
    }

    var
        ChartIsReady: Boolean;
        BusChartBuf: Record "Business Chart Buffer";
        ChartMgt: Codeunit "NPR Retail Chart Mgt.";
        StatusText: Text[250];
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period;
        Period: Option " ",Next,Previous;
        FromToLbl: Label '%1 to %2', Locked = true;

    local procedure UpdateChart()
    begin
        if not ChartIsReady then
            exit;

        ChartMgt.TurnOver_Revenue(BusChartBuf, Period, PeriodType);
        BusChartBuf.Update(CurrPage.chart);
        StatusText := StrSubstNo(FromToLbl, BusChartBuf."Period Filter Start Date", BusChartBuf."Period Filter End Date");
    end;
}

