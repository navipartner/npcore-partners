page 6059831 "Event Period Distr. Dialog"
{
    // NPR5.55/TJ  /20200326 CASE 397741 New object

    Caption = 'Event Period Distr. Dialog';
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            group(Control6014401)
            {
                ShowCaption = false;
                field(StartingDate;JobPlanningLineTemp."Planning Date")
                {
                    Caption = 'Starting Date';

                    trigger OnValidate()
                    begin
                        if (JobPlanningLineTemp."Planning Date" <> 0D) and (JobPlanningLineTemp."Planned Delivery Date" = 0D) then
                          JobPlanningLineTemp."Planned Delivery Date" := CalcDate('1D',JobPlanningLineTemp."Planning Date");
                        CheckDate();
                    end;
                }
                field(EndingDate;JobPlanningLineTemp."Planned Delivery Date")
                {
                    Caption = 'Ending Date';

                    trigger OnValidate()
                    begin
                        if (JobPlanningLineTemp."Planned Delivery Date" <> 0D) and (JobPlanningLineTemp."Planning Date" = 0D) then
                          JobPlanningLineTemp."Planning Date" := CalcDate('-1D',JobPlanningLineTemp."Planned Delivery Date");
                        CheckDate();
                    end;
                }
                field(StartingTime;JobPlanningLineTemp."Starting Time")
                {
                    Caption = 'Starting Time';

                    trigger OnValidate()
                    begin
                        CheckTime();
                        EventPlanLineGroupingMgt.CalcTimeQty(JobPlanningLineTemp."Starting Time",JobPlanningLineTemp."Ending Time",JobPlanningLineTemp.Quantity);
                    end;
                }
                field(EndingTime;JobPlanningLineTemp."Ending Time")
                {
                    Caption = 'Ending Time';

                    trigger OnValidate()
                    begin
                        CheckTime();
                        EventPlanLineGroupingMgt.CalcTimeQty(JobPlanningLineTemp."Starting Time",JobPlanningLineTemp."Ending Time",JobPlanningLineTemp.Quantity);
                    end;
                }
                field(UnitOfMeasure;JobPlanningLineTemp."Unit of Measure Code")
                {
                    Caption = 'Unit of Measure';
                }
                field(Quantity;JobPlanningLineTemp.Quantity)
                {
                    Caption = 'Quantity';
                }
                field(DaysOfTheWeek;DaysOfWeekOption)
                {
                    Caption = 'Days Of The Week';

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
                field(Monday;DaysOfWeek[1])
                {
                    Caption = 'Monday';
                    Enabled = DaysArrayEnabled;
                }
                field(Tuesday;DaysOfWeek[2])
                {
                    Caption = 'Tuesday';
                    Enabled = DaysArrayEnabled;
                }
                field(Wednesday;DaysOfWeek[3])
                {
                    Caption = 'Wednesday';
                    Enabled = DaysArrayEnabled;
                }
                field(Thursday;DaysOfWeek[4])
                {
                    Caption = 'Thursday';
                    Enabled = DaysArrayEnabled;
                }
                field(Friday;DaysOfWeek[5])
                {
                    Caption = 'Friday';
                    Enabled = DaysArrayEnabled;
                }
                field(Saturday;DaysOfWeek[6])
                {
                    Caption = 'Saturday';
                    Enabled = DaysArrayEnabled;
                }
                field(Sunday;DaysOfWeek[7])
                {
                    Caption = 'Sunday';
                    Enabled = DaysArrayEnabled;
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
        DaysOfWeek: array [7] of Boolean;
        DateError: Label '%1 must be before %2.';
        DaysOfWeekOption: Option All,Some;
        DaysArrayEnabled: Boolean;
        TimeError: Label '%1 must be earlier than %2.';
        EventPlanLineGroupingMgt: Codeunit "Event Plan. Line Grouping Mgt.";

    procedure SetParameters(JobPlanningLine: Record "Job Planning Line")
    begin
        JobPlanningLineTemp := JobPlanningLine;
    end;

    procedure GetParameters(var JobPlanningLine2: Record "Job Planning Line";var DaysOfWeek2: array [7] of Boolean)
    begin
        JobPlanningLine2 := JobPlanningLineTemp;
        CopyArray(DaysOfWeek2,DaysOfWeek,1);
    end;

    local procedure CheckDate()
    var
        Job: Record Job;
    begin
        if JobPlanningLineTemp."Planning Date" >= JobPlanningLineTemp."Planned Delivery Date" then
          Error(DateError,Job.FieldCaption("Starting Date"),Job.FieldCaption("Ending Date"));
    end;

    local procedure CheckTime()
    var
        Job: Record Job;
    begin
        if JobPlanningLineTemp."Planning Date" = JobPlanningLineTemp."Planned Delivery Date" then
          if (JobPlanningLineTemp."Starting Time" > JobPlanningLineTemp."Ending Time") and (JobPlanningLineTemp."Starting Time" <> 0T) and (JobPlanningLineTemp."Ending Time" <> 0T) then
            Error(TimeError,Job.FieldCaption("Starting Time"),Job.FieldCaption("Ending Time"));
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

