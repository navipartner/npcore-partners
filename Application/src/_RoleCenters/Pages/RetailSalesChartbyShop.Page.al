page 6059816 "NPR Retail Sales Chart by Shop"
{
    Extensible = false;
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
                ToolTip = 'The user can specify the Date Range from which wants to see the data.';
                ApplicationArea = NPRRetail;
                Editable = false;
            }
            field(ChartType; ChartType)
            {

                Caption = 'Chart type';
                OptionCaption = 'Dimension 1,Dimension 2';
                ShowCaption = true;
                Style = Strong;
                StyleExpr = true;
                ToolTip = 'Specifies the value of the Chart type.';
                ApplicationArea = NPRRetail;

                trigger OnValidate()
                begin
                    UpdateChart();
                end;
            }
            usercontrol(chart; "Microsoft.Dynamics.Nav.Client.BusinessChart")
            {
                ApplicationArea = NPRRetail;

                trigger AddInReady()
                begin
                    ChartIsReady := true;
                    Initialize();
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
                Action(Day)
                {

                    Caption = 'Day';
                    Image = ChangeDate;
                    ToolTip = 'Select this filter to visualize data by day.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Period := Period::" ";
                        PeriodType := Periodtype::Day;
                        UpdateChart();
                    end;
                }
                Action(Week)
                {

                    Caption = 'Week';
                    Image = ChangeDate;
                    ToolTip = 'Select this filter to visualize data by week.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Period := Period::" ";
                        PeriodType := Periodtype::Week;
                        UpdateChart();
                    end;
                }
                Action(Month)
                {

                    Caption = 'Month';
                    Image = ChangeDate;
                    ToolTip = 'Select this filter to visualize data by month.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Period := Period::" ";
                        PeriodType := Periodtype::Month;
                        UpdateChart();
                    end;
                }
                Action(Quarter)
                {

                    Caption = 'Quarter';
                    Image = ChangeDate;
                    ToolTip = 'Select this filter to visualize data by quarter.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Period := Period::" ";
                        PeriodType := Periodtype::Quarter;
                        UpdateChart();
                    end;
                }
                Action(Year)
                {

                    Caption = 'Year';
                    Image = ChangeDate;
                    ToolTip = 'Select this filter to visualize data by year.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Period := Period::" ";
                        PeriodType := Periodtype::Year;
                        UpdateChart();
                    end;
                }
            }
            Action(Previous)
            {

                Caption = 'Previous';
                Image = PreviousRecord;
                ToolTip = 'Executes the Previous action.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Period := Period::Previous;
                    UpdateChart();
                end;
            }
            Action("Next")
            {

                Caption = 'Next';
                Image = NextRecord;
                ToolTip = 'Executes the Next action.';
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
        ChartDataTrackerMgt: Codeunit "NPR Chart Data Tracker Mgt.";
        BackgroundTaskId: Integer;
        ChartMgt: Codeunit "NPR Retail Chart Mgt.";
        BusChartBuf: Record "Business Chart Buffer";
        StatusText: Text[250];
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period;
        Period: Option " ",Next,Previous;
        ChartType: Option "Dimension 1","Dimension 2";
        ChartIsReady: Boolean;
        FromToDateLbl: Label '%1 to %2', locked = true;

    trigger OnOpenPage()
    begin
        ChartType := ChartType::"Dimension 1";
    end;

    local procedure Initialize()
    begin
        BusChartBuf.Initialize();
        BusChartBuf.Update(CurrPage.chart);
        UpdateChart();
    end;

    local procedure UpdateChart()
    var
        Parameters: Dictionary of [Text, Text];
        ChartDataUpdateTracker: Record "NPR Chart Data Update Tracker";
    begin
        if not ChartIsReady then
            exit;
        Parameters.Add('Period', Format(Period));
        Parameters.Add('PeriodType', Format(PeriodType));
        Parameters.Add('PeriodLength', Format(BusChartBuf.GetPeriodLength()));
        Parameters.Add('PeriodEndDate', Format(BusChartBuf."Period Filter End Date"));
        Parameters.Add('ChartType', Format(ChartType));

        if ChartDataTrackerMgt.ShouldUpdateChartFromTable(ChartDataUpdateTracker, Codeunit::"NPR Retail Chart by Shop BT", Period, PeriodType, BusChartBuf.GetPeriodLength(), BusChartBuf."Period Filter End Date", ChartType, true) then begin
            UpdateChartFromTable(ChartDataUpdateTracker);
            exit;
        end;

        CurrPage.EnqueueBackgroundTask(BackgroundTaskId, Codeunit::"NPR Retail Chart by Shop BT", Parameters);
    end;

    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    begin
        if TaskId <> BackgroundTaskId then
            exit;
        if Results.Count() = 0 then
            exit;

        ChartMgt.TurnOver_RevenuebyDim(BusChartBuf, Period, PeriodType, Results);

        BusChartBuf.Update(CurrPage.chart);
        StatusText := StrSubstNo(FromToDateLbl, BusChartBuf."Period Filter Start Date", BusChartBuf."Period Filter End Date");

        ChartDataTrackerMgt.UpsertTrackerTable(Codeunit::"NPR Retail Chart by Shop BT", Period, PeriodType, BusChartBuf."Period Filter Start Date", BusChartBuf."Period Filter End Date", ChartType, true, Results);
    end;

    trigger OnPageBackgroundTaskError(TaskId: Integer; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text; var IsHandled: Boolean)
    var
        BackgrndTaskMgt: Codeunit "NPR Page Background Task Mgt.";
    begin
        if TaskId = BackgroundTaskId then
            BackgrndTaskMgt.FailedTaskError(CurrPage.Caption(), ErrorCode, ErrorText);
    end;

    local procedure UpdateChartFromTable(ChartDataUpdateTracker: Record "NPR Chart Data Update Tracker")
    var
        Results: Dictionary of [Text, Text];
    begin
        ChartDataTrackerMgt.GetResultsFromTable(ChartDataUpdateTracker, Results);

        ChartMgt.TurnOver_RevenuebyDim(BusChartBuf, Period, PeriodType, Results);
        BusChartBuf.Update(CurrPage.chart);
        StatusText := StrSubstNo(FromToDateLbl, BusChartBuf."Period Filter Start Date", BusChartBuf."Period Filter End Date");
    end;
}