page 6059813 "NPR Retail Sales Chart"
{
    Extensible = false;
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
                StyleExpr = true;
                ToolTip = 'Specifies the period on which you want filter data.';
                ApplicationArea = NPRRetail;
                Editable = false;
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
#if not (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC2200)
            usercontrol(Logo; "NPR Welcome Logo")
            {
                ApplicationArea = NPRRetail;
                trigger InsertLogoEvent()
                begin
                end;
            }
#endif
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
                Action(Week)
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
                Action(Month)
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
                Action(Quarter)
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
                Action(Year)
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
            Action(Previous)
            {
                Caption = 'Previous';
                Image = PreviousRecord;

                ToolTip = 'Displays data for the previous period.';
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

                ToolTip = 'Displays data for the next period.';
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
        BackgroundTaskId: Integer;
        ChartIsReady: Boolean;
        BusChartBuf: Record "Business Chart Buffer";
        ChartMgt: Codeunit "NPR Retail Chart Mgt.";
        DimensionType: Option "Dimension 1","Dimension 2";
        ChartDataTrackerMgt: Codeunit "NPR Chart Data Tracker Mgt.";
        StatusText: Text[250];
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period;
        Period: Option " ",Next,Previous;
        FromToLbl: Label '%1 to %2', Locked = true;

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

        if ChartDataTrackerMgt.ShouldUpdateChartFromTable(ChartDataUpdateTracker, Codeunit::"NPR Retail Sales Chart BT", Period, PeriodType, BusChartBuf.GetPeriodLength(), BusChartBuf."Period Filter End Date", DimensionType::"Dimension 1", false) then begin
            UpdateChartFromTable(ChartDataUpdateTracker);
            exit;
        end;

        CurrPage.EnqueueBackgroundTask(BackgroundTaskId, Codeunit::"NPR Retail Sales Chart BT", Parameters);
    end;

    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    begin
        if TaskId <> BackgroundTaskId then
            exit;
        if Results.Count() = 0 then
            exit;

        ChartMgt.TurnOver_Revenue(BusChartBuf, Period, PeriodType, Results);
        BusChartBuf.Update(CurrPage.chart);
        StatusText := StrSubstNo(FromToLbl, BusChartBuf."Period Filter Start Date", BusChartBuf."Period Filter End Date");

        ChartDataTrackerMgt.UpsertTrackerTable(Codeunit::"NPR Retail Sales Chart BT", Period, PeriodType, BusChartBuf."Period Filter Start Date", BusChartBuf."Period Filter End Date", DimensionType::"Dimension 1", false, Results);
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
        ChartMgt.TurnOver_Revenue(BusChartBuf, Period, PeriodType, Results);
        BusChartBuf.Update(CurrPage.chart);
        StatusText := StrSubstNo(FromToLbl, BusChartBuf."Period Filter Start Date", BusChartBuf."Period Filter End Date");
    end;
}