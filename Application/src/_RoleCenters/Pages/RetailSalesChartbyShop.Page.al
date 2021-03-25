Page 6059816 "NPR Retail Sales Chart by Shop"
{
    Caption = 'Margin/Turnover by Shop';
    PageType = CardPart;
    SourceTable = "Business Chart Buffer";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            field("Date Range"; StatusText)
            {
                ApplicationArea = Basic;
                ShowCaption = true;
                Style = Strong;
                StyleExpr = true;
            }
            field(ChartType; ChartType)
            {
                Caption = 'Chart type';
                ApplicationArea = Basic;
                ShowCaption = true;
                Style = Strong;
                StyleExpr = true;

                trigger OnValidate()
                begin
                    ChartTypeIsChanged := true;
                    UpdateChart();
                end;
            }
            usercontrol(chart; "Microsoft.Dynamics.Nav.Client.BusinessChart")
            {
                ApplicationArea = Basic;

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
                    ApplicationArea = Basic;
                    Caption = 'Day';
                    Image = ChangeDate;

                    trigger OnAction()
                    begin
                        Period := Period::" ";
                        PeriodType := Periodtype::Day;
                        UpdateChart();
                    end;
                }
                action(Week)
                {
                    ApplicationArea = Basic;
                    Caption = 'Week';
                    Image = ChangeDate;

                    trigger OnAction()
                    begin
                        Period := Period::" ";
                        PeriodType := Periodtype::Week;
                        UpdateChart();
                    end;
                }
                action(Month)
                {
                    ApplicationArea = Basic;
                    Caption = 'Month';
                    Image = ChangeDate;

                    trigger OnAction()
                    begin
                        Period := Period::" ";
                        PeriodType := Periodtype::Month;
                        UpdateChart();
                    end;
                }
                action(Quarter)
                {
                    ApplicationArea = Basic;
                    Caption = 'Quarter';
                    Image = ChangeDate;

                    trigger OnAction()
                    begin
                        Period := Period::" ";
                        PeriodType := Periodtype::Quarter;
                        UpdateChart();
                    end;
                }
                action(Year)
                {
                    ApplicationArea = Basic;
                    Caption = 'Year';
                    Image = ChangeDate;

                    trigger OnAction()
                    begin
                        Period := Period::" ";
                        PeriodType := Periodtype::Year;
                        UpdateChart();
                    end;
                }
            }
            action(Previous)
            {
                ApplicationArea = Basic;
                Caption = 'Previous';
                Image = PreviousRecord;

                trigger OnAction()
                begin
                    Period := Period::Previous;
                    UpdateChart();
                end;
            }
            action("Next")
            {
                ApplicationArea = Basic;
                Caption = 'Next';
                Image = NextRecord;

                trigger OnAction()
                begin
                    Period := Period::Next;
                    UpdateChart();
                end;
            }
        }
    }

    var
        ChartMgt: Codeunit "NPR Retail Chart Mgt by Shop";
        BusChartBuf: Record "Business Chart Buffer";
        StatusText: Text[250];
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period;
        Period: Option " ",Next,Previous;
        ChartType: Option "Dimension 1","Dimension 2";
        ChartIsReady: Boolean;
        ChartTypeIsChanged: Boolean;
        StartDate: Date;
        Enddate: Date;

    trigger OnOpenPage()
    begin
        ChartType := ChartType::"Dimension 1";
    end;

    local procedure UpdateChart()
    begin
        if not ChartIsReady then
            exit;
        case ChartType of
            ChartType::"Dimension 2":
                ChartMgt.TurnOver_RevenuebyDim2(BusChartBuf, Period, PeriodType, StartDate, Enddate, ChartTypeIsChanged);
            ChartType::"Dimension 1":
                ChartMgt.TurnOver_RevenuebyDim1(BusChartBuf, Period, PeriodType, StartDate, Enddate, ChartTypeIsChanged);
        end;
        BusChartBuf.Update(CurrPage.chart);
        StatusText := StrSubstNo('%1 to %2', StartDate, Enddate);
        ChartTypeIsChanged := false;
    end;
}