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

                Caption = 'Date Range';
                ShowCaption = true;
                Style = Strong;
                StyleExpr = true;
                ToolTip = 'Specifies the value of the Date Range field';
                ApplicationArea = NPRRetail;
            }
            field(ChartType; ChartType)
            {

                Caption = 'Chart type';
                OptionCaption = 'Dimension 1,Dimension 2';
                ShowCaption = true;
                Style = Strong;
                StyleExpr = true;
                ToolTip = 'Specifies the value of the Chart type field';
                ApplicationArea = NPRRetail;

                trigger OnValidate()
                begin
                    ChartTypeIsChanged := true;
                    UpdateChart();
                end;
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
                    Image = ChangeDate;
                    ToolTip = 'Executes the Day action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Period := Period::" ";
                        PeriodType := Periodtype::Day;
                        UpdateChart();
                    end;
                }
                action(Week)
                {

                    Caption = 'Week';
                    Image = ChangeDate;
                    ToolTip = 'Executes the Week action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Period := Period::" ";
                        PeriodType := Periodtype::Week;
                        UpdateChart();
                    end;
                }
                action(Month)
                {

                    Caption = 'Month';
                    Image = ChangeDate;
                    ToolTip = 'Executes the Month action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Period := Period::" ";
                        PeriodType := Periodtype::Month;
                        UpdateChart();
                    end;
                }
                action(Quarter)
                {

                    Caption = 'Quarter';
                    Image = ChangeDate;
                    ToolTip = 'Executes the Quarter action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Period := Period::" ";
                        PeriodType := Periodtype::Quarter;
                        UpdateChart();
                    end;
                }
                action(Year)
                {

                    Caption = 'Year';
                    Image = ChangeDate;
                    ToolTip = 'Executes the Year action';
                    ApplicationArea = NPRRetail;

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
        FromToDateLbl: Label '%1 to %2', locked = true;

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
        StatusText := StrSubstNo(FromToDateLbl, StartDate, Enddate);
        ChartTypeIsChanged := false;
    end;
}