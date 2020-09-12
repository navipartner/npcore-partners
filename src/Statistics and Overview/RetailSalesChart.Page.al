page 6059813 "NPR Retail Sales Chart"
{
    // NC1.17/BHR/20150406 CASE 212983  CHART REVENUE-TURNOVER BY PERIOD
    // NC1.17/MH/20150619  CASE 216793 Changed pagename and caption from Revenue to Margin
    // NC1.19/BHR/20150720 CASE 218963 Updated captions
    // NPR5.23.03/MHA/20160726  CASE 242557 Object renamed and re-versioned from NC1.22 to NPR5.23.03
    // NPR5.31/TJ  /20170328 CASE 269797 Switched control addin to use version 10.0.0.0 instead of 9.0.0.0
    // NPR5.50/JAVA/20190619 CASE 359388 Update addins references to point to the correct version (13.0.0.0 => 14.0.0.0).

    Caption = 'Margin/Turnover by Period';
    PageType = CardPart;
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
        SalesByPeriod: array[5] of Decimal;
        OrderCount: array[5] of Decimal;

    local procedure UpdateChart()
    begin
        if not ChartIsReady then
            exit;

        ChartMgt.TurnOver_Revenue(BusChartBuf, Period, PeriodType);
        BusChartBuf.Update(CurrPage.chart);
        StatusText := StrSubstNo('%1 to %2', BusChartBuf."Period Filter Start Date", BusChartBuf."Period Filter End Date");
    end;
}

