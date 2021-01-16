page 6151482 "NPR Magento Sales Chart"
{
    // MAG1.17/BHR/20150406 CASE 212983  CHART REVENUE-TURNOVER BY PERIOD
    // MAG1.17/MH/20150619  CASE 216793 Changed pagename and caption from Revenue to Margin
    // MAG1.19/BHR/20150720 CASE 218963 Updated captions
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // NPR5.50/JAVA/20190619 CASE 359388 Update addins references to point to the correct version (13.0.0.0 => 14.0.0.0).

    Caption = 'Margin/Turnover by Period';
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

                trigger Refresh()
                begin
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
                    ToolTip = 'Executes the Day action';
                    Image = Calendar;

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
                    ToolTip = 'Executes the Week action';
                    Image = Calendar;

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
                    ToolTip = 'Executes the Month action';
                    Image = Calendar;

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
                    ToolTip = 'Executes the Quarter action';
                    Image = Calendar;

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
                    ToolTip = 'Executes the Year action';
                    Image = Calendar;

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
        ChartMgt: Codeunit "NPR Magento Chart Mgt.";
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

