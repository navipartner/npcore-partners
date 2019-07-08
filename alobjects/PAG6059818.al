page 6059818 "Retail Sales Chart by Shop"
{
    // NPR5.29/BHR/20170104 CASE 262439 Chart of sales by store
    // NPR5.31/TJ  /20170328 CASE 269797 Switched control addin to use version 10.0.0.0 instead of 9.0.0.0
    // NPR5.50/JAVA/20190619 CASE 359388 Update addins references to point to the correct version (13.0.0.0 => 14.0.0.0).

    Caption = 'Margin/Turnover by Shop';
    PageType = CardPart;
    SourceTable = "Business Chart Buffer";

    layout
    {
        area(content)
        {
            field("Date Range";StatusText)
            {
                ShowCaption = true;
                Style = Strong;
                StyleExpr = TRUE;
            }
            usercontrol(chart;"Microsoft.Dynamics.Nav.Client.BusinessChart")
            {

                trigger DataPointClicked(point: DotNet BusinessChartDataPoint)
                begin
                end;

                trigger DataPointDoubleClicked(point: DotNet BusinessChartDataPoint)
                begin
                end;

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

                trigger OnAction()
                begin
                    Period := Period::Previous;
                    UpdateChart;
                end;
            }
            action(Next)
            {
                Caption = 'Next';
                Image = NextRecord;

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
        ChartMgt: Codeunit "Retail Chart Mgt by Shop";
        StatusText: Text[250];
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period;
        Period: Option " ",Next,Previous;
        SalesByPeriod: array [5] of Decimal;
        OrderCount: array [5] of Decimal;
        StartDate: Date;
        Enddate: Date;
        RetailSetup: Record "Retail Setup";

    local procedure UpdateChart()
    begin
        if not ChartIsReady then
          exit;
        case RetailSetup."Margin and Turnover By Shop" of
        RetailSetup."Margin and Turnover By Shop"::" ",RetailSetup."Margin and Turnover By Shop"::Dimension2  :
          ChartMgt.TurnOver_RevenuebyDim2(BusChartBuf,Period,PeriodType,StartDate,Enddate);
        RetailSetup."Margin and Turnover By Shop"::Dimension1  :
        ChartMgt.TurnOver_RevenuebyDim1(BusChartBuf,Period,PeriodType,StartDate,Enddate);
        end;
        BusChartBuf.Update(CurrPage.chart);
        StatusText := StrSubstNo('%1 to %2',StartDate,Enddate);
    end;
}

