page 6059831 "NPR Event Period Distr. Dialog"
{
    Caption = 'Event Period Distr. Dialog';
    PageType = StandardDialog;
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            group(Control6014401)
            {
                ShowCaption = false;
                field(StartingDate; TempJobPlanningLine."Planning Date")
                {

                    Caption = 'Starting Date';
                    ToolTip = 'Specifies the value of the Starting Date field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        if (TempJobPlanningLine."Planning Date" <> 0D) and (TempJobPlanningLine."Planned Delivery Date" = 0D) then
                            TempJobPlanningLine."Planned Delivery Date" := CalcDate('<1D>', TempJobPlanningLine."Planning Date");
                        CheckDate();
                    end;
                }
                field(EndingDate; TempJobPlanningLine."Planned Delivery Date")
                {

                    Caption = 'Ending Date';
                    ToolTip = 'Specifies the value of the Ending Date field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        if (TempJobPlanningLine."Planned Delivery Date" <> 0D) and (TempJobPlanningLine."Planning Date" = 0D) then
                            TempJobPlanningLine."Planning Date" := CalcDate('<-1D>', TempJobPlanningLine."Planned Delivery Date");
                        CheckDate();
                    end;
                }
                field(StartingTime; TempJobPlanningLine."NPR Starting Time")
                {

                    Caption = 'Starting Time';
                    ToolTip = 'Specifies the value of the Starting Time field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CheckTime();
                        EventPlanLineGroupingMgt.CalcTimeQty(TempJobPlanningLine."NPR Starting Time", TempJobPlanningLine."NPR Ending Time", TempJobPlanningLine.Quantity);
                    end;
                }
                field(EndingTime; TempJobPlanningLine."NPR Ending Time")
                {

                    Caption = 'Ending Time';
                    ToolTip = 'Specifies the value of the Ending Time field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CheckTime();
                        EventPlanLineGroupingMgt.CalcTimeQty(TempJobPlanningLine."NPR Starting Time", TempJobPlanningLine."NPR Ending Time", TempJobPlanningLine.Quantity);
                    end;
                }
                field(UnitOfMeasure; TempJobPlanningLine."Unit of Measure Code")
                {

                    Caption = 'Unit of Measure';
                    ToolTip = 'Specifies the value of the Unit of Measure field';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; TempJobPlanningLine.Quantity)
                {

                    Caption = 'Quantity';
                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field(DaysOfTheWeek; DaysOfWeekOption)
                {

                    Caption = 'Days Of The Week';
                    OptionCaption = 'All,Some';
                    ToolTip = 'Specifies the value of the Days Of The Week field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
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

                    Caption = 'Monday';
                    Enabled = DaysArrayEnabled;
                    ToolTip = 'Specifies the value of the Monday field';
                    ApplicationArea = NPRRetail;
                }
                field(Tuesday; DaysOfWeek[2])
                {

                    Caption = 'Tuesday';
                    Enabled = DaysArrayEnabled;
                    ToolTip = 'Specifies the value of the Tuesday field';
                    ApplicationArea = NPRRetail;
                }
                field(Wednesday; DaysOfWeek[3])
                {

                    Caption = 'Wednesday';
                    Enabled = DaysArrayEnabled;
                    ToolTip = 'Specifies the value of the Wednesday field';
                    ApplicationArea = NPRRetail;
                }
                field(Thursday; DaysOfWeek[4])
                {

                    Caption = 'Thursday';
                    Enabled = DaysArrayEnabled;
                    ToolTip = 'Specifies the value of the Thursday field';
                    ApplicationArea = NPRRetail;
                }
                field(Friday; DaysOfWeek[5])
                {

                    Caption = 'Friday';
                    Enabled = DaysArrayEnabled;
                    ToolTip = 'Specifies the value of the Friday field';
                    ApplicationArea = NPRRetail;
                }
                field(Saturday; DaysOfWeek[6])
                {

                    Caption = 'Saturday';
                    Enabled = DaysArrayEnabled;
                    ToolTip = 'Specifies the value of the Saturday field';
                    ApplicationArea = NPRRetail;
                }
                field(Sunday; DaysOfWeek[7])
                {

                    Caption = 'Sunday';
                    Enabled = DaysArrayEnabled;
                    ToolTip = 'Specifies the value of the Sunday field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        IncludeAllDays();
    end;

    var
        TempJobPlanningLine: Record "Job Planning Line" temporary;
        DaysOfWeek: array[7] of Boolean;
        DateError: Label '%1 must be before %2.';
        DaysOfWeekOption: Option All,Some;
        DaysArrayEnabled: Boolean;
        TimeError: Label '%1 must be earlier than %2.';
        EventPlanLineGroupingMgt: Codeunit "NPR Event Plan.Line Group. Mgt";

    procedure SetParameters(JobPlanningLine: Record "Job Planning Line")
    begin
        TempJobPlanningLine := JobPlanningLine;
    end;

    procedure GetParameters(var JobPlanningLine2: Record "Job Planning Line"; var DaysOfWeek2: array[7] of Boolean)
    begin
        JobPlanningLine2 := TempJobPlanningLine;
        CopyArray(DaysOfWeek2, DaysOfWeek, 1);
    end;

    local procedure CheckDate()
    var
        Job: Record Job;
    begin
        if TempJobPlanningLine."Planning Date" >= TempJobPlanningLine."Planned Delivery Date" then
            Error(DateError, Job.FieldCaption("Starting Date"), Job.FieldCaption("Ending Date"));
    end;

    local procedure CheckTime()
    var
        Job: Record Job;
    begin
        if TempJobPlanningLine."Planning Date" = TempJobPlanningLine."Planned Delivery Date" then
            if (TempJobPlanningLine."NPR Starting Time" > TempJobPlanningLine."NPR Ending Time") and (TempJobPlanningLine."NPR Starting Time" <> 0T) and (TempJobPlanningLine."NPR Ending Time" <> 0T) then
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

