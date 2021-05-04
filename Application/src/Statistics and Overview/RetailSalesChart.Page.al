page 6059813 "NPR Retail Sales Chart"
{
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
                ApplicationArea = All;
                Caption = 'Date Range';
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
                    ToolTip = 'Filter by day';
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
                    ToolTip = 'Filter by week';
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
                    ToolTip = 'Filter by month';
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
                    ToolTip = 'Filter by quarter';
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
                    ToolTip = 'Filter by year';
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

    var
        ChartIsReady: Boolean;
        BusChartBuf: Record "Business Chart Buffer";
        ChartMgt: Codeunit "NPR Retail Chart Mgt.";
        StatusText: Text[250];
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period;
        Period: Option " ",Next,Previous;

    local procedure UpdateChart()
    begin
        if not ChartIsReady then
            exit;

        ChartMgt.TurnOver_Revenue(BusChartBuf, Period, PeriodType);
        BusChartBuf.Update(CurrPage.chart);
        StatusText := StrSubstNo('%1 to %2', BusChartBuf."Period Filter Start Date", BusChartBuf."Period Filter End Date");
    end;
}

