page 6150737 "NPR Chart Wrapper"
{
    Caption = 'Retail Performance';
    DeleteAllowed = false;
    Extensible = false;
    PageType = CardPart;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            field("Status Text"; StatusText)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Status Text';
                Editable = false;
                ShowCaption = false;
                Style = StrongAccent;
                StyleExpr = true;
                ToolTip = 'Specifies the status of the resource, such as Completed.';
            }
            field("Date Range"; DateRange)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Date Range';
                Editable = false;
                ShowCaption = true;
                Style = Strong;
                StyleExpr = true;
                ToolTip = 'Specifies the period on which you want filter data.';
            }
            group(Dimensions)
            {
                ShowCaption = false;
                Visible = ChartTypeVisible;
                field(ChartType; ChartType)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Chart type';
                    OptionCaption = 'Dimension 1,Dimension 2';
                    ShowCaption = true;
                    Style = Strong;
                    StyleExpr = true;
                    ToolTip = 'Specifies the value of the Chart type.';

                    trigger OnValidate()
                    begin
                        UpdateChart();
                    end;
                }
            }
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
            usercontrol(chart; BusinessChart)
#ELSE
            usercontrol(chart; "Microsoft.Dynamics.Nav.Client.BusinessChart")
#ENDIF
            {
                ApplicationArea = NPRRetail;

                trigger AddInReady()
                begin
                    ChartIsReady := true;
                    Initialize();
                end;
            }
#if not (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22)
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
        area(Processing)
        {
            action("Select Chart")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Select Chart';
                Image = SelectChart;
                ToolTip = 'Change the chart that is displayed. You can choose from several charts that show data for different performance indicators.';

                trigger OnAction()
                begin
                    RetailChartMgt.SelectChart(SelectedChartDefinition);
                    UpdateChart();
                end;
            }
            action("Previous Chart")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Previous Chart';
                Image = PreviousSet;
                ToolTip = 'View the previous chart.';

                trigger OnAction()
                begin
                    SelectedChartDefinition.SetRange(Enabled, true);
                    SelectedChartDefinition.SetFilter("Code Unit ID", RetailChartMgt.GetCodeunitIDFilter());

                    if SelectedChartDefinition.Next(-1) = 0 then
                        if not SelectedChartDefinition.FindLast() then
                            exit;
                    UpdateChart();
                end;
            }
            action("Next Chart")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Next Chart';
                Image = NextSet;
                ToolTip = 'View the next chart.';

                trigger OnAction()
                begin
                    SelectedChartDefinition.SetRange(Enabled, true);
                    SelectedChartDefinition.SetFilter("Code Unit ID", RetailChartMgt.GetCodeunitIDFilter());

                    if SelectedChartDefinition.Next() = 0 then
                        if not SelectedChartDefinition.FindFirst() then
                            exit;
                    UpdateChart();
                end;
            }
            group("Period Length")
            {
                Caption = 'Period Length';
                Image = Period;

                action(Day)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Day';
                    Image = DueDate;
                    ToolTip = 'Filter by day';

                    trigger OnAction()
                    begin
                        Period := Period::" ";
                        PeriodType := PeriodType::Day;
                        UpdateChart();
                    end;
                }
                action(Week)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Week';
                    Image = DateRange;
                    ToolTip = 'Filter by week';

                    trigger OnAction()
                    begin
                        Period := Period::" ";
                        PeriodType := PeriodType::Week;
                        UpdateChart();
                    end;
                }
                action(Month)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Month';
                    Image = DateRange;
                    ToolTip = 'Filter by month';

                    trigger OnAction()
                    begin
                        Period := Period::" ";
                        PeriodType := PeriodType::Month;
                        UpdateChart();
                    end;
                }
                action(Quarter)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Quarter';
                    Image = DateRange;
                    ToolTip = 'Filter by quarter';

                    trigger OnAction()
                    begin
                        Period := Period::" ";
                        PeriodType := PeriodType::Quarter;
                        UpdateChart();
                    end;
                }
                action(Year)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Year';
                    Image = DateRange;
                    ToolTip = 'Filter by year';

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
                ApplicationArea = NPRRetail;
                Caption = 'Previous';
                Image = PreviousRecord;
                ToolTip = 'Displays data for the previous period.';

                trigger OnAction()
                begin
                    Period := Period::Previous;
                    UpdateChart();
                end;
            }
            action("Next")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Next';
                Image = NextRecord;
                ToolTip = 'Displays data for the next period.';

                trigger OnAction()
                begin
                    Period := Period::Next;
                    UpdateChart();
                end;
            }
            action(ChartInformation)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Chart Information';
                Image = AboutNav;
                ToolTip = 'View a description of the chart.';

                trigger OnAction()
                var
                    Description: Text;
                begin
                    if StatusText = '' then
                        exit;
                    Description := RetailChartMgt.ChartDescription(SelectedChartDefinition);
                    if Description = '' then
                        Message(NoDescriptionMsgLbl)
                    else
                        Message(Description);
                end;
            }
        }
    }

    var
        BusChartBuf: Record "Business Chart Buffer";
        SelectedChartDefinition: Record "Chart Definition";
        ChartDataTrackerMgt: Codeunit "NPR Chart Data Tracker Mgt.";
        RetailChartMgt: Codeunit "NPR Retail Chart Mgt.";
        ChartIsReady: Boolean;
        ChartTypeVisible: Boolean;
        BackgroundTaskId: Integer;
        FromToLbl: Label '%1 to %2', Locked = true;
        NoDescriptionMsgLbl: Label 'A description was not specified for this chart.';
        Period: Option " ",Next,Previous;
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period;
        ChartType: Option "Dimension 1","Dimension 2";
        StatusText: Text;
        DateRange: Text[250];


    local procedure Initialize()
    begin
        BusChartBuf.Initialize();
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        BusChartBuf.UpdateChart(CurrPage.chart);
#ELSE
        BusChartBuf.Update(CurrPage.chart);
#ENDIF
        RetailChartMgt.InitializeChartDefinition(SelectedChartDefinition, UserId());
        UpdateChart();
    end;

    local procedure UpdateChart()
    var
        ChartDataUpdateTracker: Record "NPR Chart Data Update Tracker";
        Parameters: Dictionary of [Text, Text];
    begin
        if not ChartIsReady then
            exit;

        RetailChartMgt.SetBackgroundTaskParameters(SelectedChartDefinition, Period, PeriodType, BusChartBuf.GetPeriodLength(), BusChartBuf."Period Filter End Date", ChartType, Parameters);
        ChartTypeVisible := RetailChartMgt.IsChartTypeUsed(SelectedChartDefinition);
        RetailChartMgt.UpdateStatusText(SelectedChartDefinition, PeriodType, ChartType, StatusText);

        if ChartDataTrackerMgt.ShouldUpdateChartFromTable(ChartDataUpdateTracker, SelectedChartDefinition."Code Unit ID", Period, PeriodType, BusChartBuf.GetPeriodLength(), BusChartBuf."Period Filter End Date", ChartType, RetailChartMgt.IsChartTypeUsed(SelectedChartDefinition)) then begin
            UpdateChartFromTable(ChartDataUpdateTracker);
            exit;
        end;

        EnqueueBackgroundTaskForSelectedChart(BackgroundTaskId, SelectedChartDefinition."Code Unit ID", Parameters);
    end;

    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    begin
        if TaskId <> BackgroundTaskId then
            exit;
        if Results.Count() = 0 then
            exit;

        RetailChartMgt.UpdateChart(SelectedChartDefinition, BusChartBuf, Period, PeriodType, Results);
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        BusChartBuf.UpdateChart(CurrPage.chart);
#ELSE
        BusChartBuf.Update(CurrPage.chart);
#ENDIF
        DateRange := StrSubstNo(FromToLbl, BusChartBuf."Period Filter Start Date", BusChartBuf."Period Filter End Date");

        ChartDataTrackerMgt.UpsertTrackerTable(SelectedChartDefinition."Code Unit ID", Period, PeriodType, BusChartBuf."Period Filter Start Date", BusChartBuf."Period Filter End Date", ChartType, RetailChartMgt.IsChartTypeUsed(SelectedChartDefinition), Results);
    end;

    trigger OnPageBackgroundTaskError(TaskId: Integer; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text; var IsHandled: Boolean)
    var
        BackgrndTaskMgt: Codeunit "NPR Page Background Task Mgt.";
    begin
        if TaskId = BackgroundTaskId then
            BackgrndTaskMgt.FailedTaskError(CurrPage.Caption(), ErrorCode, ErrorText);
    end;

    local procedure EnqueueBackgroundTaskForSelectedChart(var _BackgroundTaskId: Integer; CodeUnitId: Integer; Parameters: Dictionary of [Text, Text])
    begin
        CurrPage.EnqueueBackgroundTask(_BackgroundTaskId, CodeUnitId, Parameters);
    end;

    local procedure UpdateChartFromTable(ChartDataUpdateTracker: Record "NPR Chart Data Update Tracker")
    var
        Results: Dictionary of [Text, Text];
    begin
        ChartDataTrackerMgt.GetResultsFromTable(ChartDataUpdateTracker, Results);
        RetailChartMgt.UpdateChart(SelectedChartDefinition, BusChartBuf, Period, PeriodType, Results);
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        BusChartBuf.UpdateChart(CurrPage.chart);
#ELSE
        BusChartBuf.Update(CurrPage.chart);
#ENDIF
        DateRange := StrSubstNo(FromToLbl, BusChartBuf."Period Filter Start Date", BusChartBuf."Period Filter End Date");
    end;
}