page 6059831 "NPR Event Period Distr. Dialog"
{
    // NPR5.55/TJ  /20200326 CASE 397741 New object

    Caption = 'Event Period Distr. Dialog';
    PageType = StandardDialog;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(Control6014401)
            {
                ShowCaption = false;
                field(StartingDate; JobPlanningLineTemp."Planning Date")
                {
                    ApplicationArea = All;
                    Caption = 'Starting Date';
                    ToolTip = 'Specifies the value of the Starting Date field';

                    trigger OnValidate()
                    begin
                        if (JobPlanningLineTemp."Planning Date" <> 0D) and (JobPlanningLineTemp."Planned Delivery Date" = 0D) then
                            JobPlanningLineTemp."Planned Delivery Date" := CalcDate('1D', JobPlanningLineTemp."Planning Date");
                        CheckDate();
                    end;
                }
                field(EndingDate; JobPlanningLineTemp."Planned Delivery Date")
                {
                    ApplicationArea = All;
                    Caption = 'Ending Date';
                    ToolTip = 'Specifies the value of the Ending Date field';

                    trigger OnValidate()
                    begin
                        if (JobPlanningLineTemp."Planned Delivery Date" <> 0D) and (JobPlanningLineTemp."Planning Date" = 0D) then
                            JobPlanningLineTemp."Planning Date" := CalcDate('-1D', JobPlanningLineTemp."Planned Delivery Date");
                        CheckDate();
                    end;
                }
                field(StartingTime; JobPlanningLineTemp."NPR Starting Time")
                {
                    ApplicationArea = All;
                    Caption = 'Starting Time';
                    ToolTip = 'Specifies the value of the Starting Time field';

                    trigger OnValidate()
                    begin
                        CheckTime();
                        EventPlanLineGroupingMgt.CalcTimeQty(JobPlanningLineTemp."NPR Starting Time", JobPlanningLineTemp."NPR Ending Time", JobPlanningLineTemp.Quantity);
                    end;
                }
                field(EndingTime; JobPlanningLineTemp."NPR Ending Time")
                {
                    ApplicationArea = All;
                    Caption = 'Ending Time';
                    ToolTip = 'Specifies the value of the Ending Time field';

                    trigger OnValidate()
                    begin
                        CheckTime();
                        EventPlanLineGroupingMgt.CalcTimeQty(JobPlanningLineTemp."NPR Starting Time", JobPlanningLineTemp."NPR Ending Time", JobPlanningLineTemp.Quantity);
                    end;
                }
                field(UnitOfMeasure; JobPlanningLineTemp."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Caption = 'Unit of Measure';
                    ToolTip = 'Specifies the value of the Unit of Measure field';
                }
                field(Quantity; JobPlanningLineTemp.Quantity)
                {
                    ApplicationArea = All;
                    Caption = 'Quantity';
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field(DaysOfTheWeek; DaysOfWeekOption)
                {
                    ApplicationArea = All;
                    Caption = 'Days Of The Week';
                    ToolTip = 'Specifies the value of the Days Of The Week field';

                    trigger OnValidate()
                    var
                        i: Integer;
                    begin
                        case DaysOfWeekOption of
                            DaysOfWeekOption::All:
                                IncludeAllDays();
                            DaysOfWeekOption::Some:
                                DaysArrayEnabled := true;
                        end;
                    end;
                }
                field(Monday; DaysOfWeek[1])
                {
                    ApplicationArea = All;
                    Caption = 'Monday';
                    Enabled = DaysArrayEnabled;
                    ToolTip = 'Specifies the value of the Monday field';
                }
                field(Tuesday; DaysOfWeek[2])
                {
                    ApplicationArea = All;
                    Caption = 'Tuesday';
                    Enabled = DaysArrayEnabled;
                    ToolTip = 'Specifies the value of the Tuesday field';
                }
                field(Wednesday; DaysOfWeek[3])
                {
                    ApplicationArea = All;
                    Caption = 'Wednesday';
                    Enabled = DaysArrayEnabled;
                    ToolTip = 'Specifies the value of the Wednesday field';
                }
                field(Thursday; DaysOfWeek[4])
                {
                    ApplicationArea = All;
                    Caption = 'Thursday';
                    Enabled = DaysArrayEnabled;
                    ToolTip = 'Specifies the value of the Thursday field';
                }
                field(Friday; DaysOfWeek[5])
                {
                    ApplicationArea = All;
                    Caption = 'Friday';
                    Enabled = DaysArrayEnabled;
                    ToolTip = 'Specifies the value of the Friday field';
                }
                field(Saturday; DaysOfWeek[6])
                {
                    ApplicationArea = All;
                    Caption = 'Saturday';
                    Enabled = DaysArrayEnabled;
                    ToolTip = 'Specifies the value of the Saturday field';
                }
                field(Sunday; DaysOfWeek[7])
                {
                    ApplicationArea = All;
                    Caption = 'Sunday';
                    Enabled = DaysArrayEnabled;
                    ToolTip = 'Specifies the value of the Sunday field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        IncludeAllDays();
    end;

    var
        JobPlanningLineTemp: Record "Job Planning Line" temporary;
        StartDate: Date;
        EndDate: Date;
        StartTime: Time;
        EndTime: Time;
        DaysOfWeek: array[7] of Boolean;
        DateError: Label '%1 must be before %2.';
        DaysOfWeekOption: Option All,Some;
        DaysArrayEnabled: Boolean;
        TimeError: Label '%1 must be earlier than %2.';
        EventPlanLineGroupingMgt: Codeunit "NPR Event Plan.Line Group. Mgt";

    procedure SetParameters(JobPlanningLine: Record "Job Planning Line")
    begin
        JobPlanningLineTemp := JobPlanningLine;
    end;

    procedure GetParameters(var JobPlanningLine2: Record "Job Planning Line"; var DaysOfWeek2: array[7] of Boolean)
    begin
        JobPlanningLine2 := JobPlanningLineTemp;
        CopyArray(DaysOfWeek2, DaysOfWeek, 1);
    end;

    local procedure CheckDate()
    var
        Job: Record Job;
    begin
        if JobPlanningLineTemp."Planning Date" >= JobPlanningLineTemp."Planned Delivery Date" then
            Error(DateError, Job.FieldCaption("Starting Date"), Job.FieldCaption("Ending Date"));
    end;

    local procedure CheckTime()
    var
        Job: Record Job;
    begin
        if JobPlanningLineTemp."Planning Date" = JobPlanningLineTemp."Planned Delivery Date" then
            if (JobPlanningLineTemp."NPR Starting Time" > JobPlanningLineTemp."NPR Ending Time") and (JobPlanningLineTemp."NPR Starting Time" <> 0T) and (JobPlanningLineTemp."NPR Ending Time" <> 0T) then
                Error(TimeError, Job.FieldCaption("NPR Starting Time"), Job.FieldCaption("NPR Ending Time"));
    end;

    local procedure IncludeAllDays()
    var
        i: Integer;
    begin
        DaysArrayEnabled := false;
        for i := 1 to ArrayLen(DaysOfWeek) do
            DaysOfWeek[i] := true;
    end;
}

