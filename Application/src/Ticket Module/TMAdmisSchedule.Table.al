table 6060118 "NPR TM Admis. Schedule"
{
    Access = Internal;

    Caption = 'Admission Schedule';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Schedule Code"; Code[20])
        {
            Caption = 'Schedule Code';
            DataClassification = CustomerContent;
        }
        field(2; "Schedule Type"; Option)
        {
            Caption = 'Schedule Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Location,Event';
            OptionMembers = LOCATION,"EVENT";
        }
        field(3; "Admission Is"; Option)
        {
            Caption = 'Admission Is';
            DataClassification = CustomerContent;
            OptionCaption = 'Open,Closed';
            OptionMembers = OPEN,CLOSED;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(11; "Start From"; Date)
        {
            Caption = 'Start From';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateEndAfterDate();
                SetDayOfTheWeek();
            end;
        }
        field(12; "Recurrence Until Pattern"; Option)
        {
            Caption = 'Recurrence Until Pattern';
            DataClassification = CustomerContent;
            OptionCaption = 'No End Date,End After N Occurrences,End By';
            OptionMembers = NO_END_DATE,AFTER_X_OCCURENCES,END_DATE;

            trigger OnValidate()
            begin

                case "Recurrence Until Pattern" of
                    "Recurrence Until Pattern"::NO_END_DATE:
                        begin
                            "End After Date" := 0D;
                            "End After Occurrence Count" := 0;
                        end;
                    "Recurrence Until Pattern"::END_DATE:
                        begin
                            "End After Occurrence Count" := 0;
                        end;
                end;
                UpdateEndAfterDate();

            end;
        }
        field(13; "End After Occurrence Count"; Integer)
        {
            Caption = 'End After Occurrence Count';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin

                UpdateEndAfterDate();

            end;
        }
        field(14; "End After Date"; Date)
        {
            Caption = 'End After Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateRecurrencePattern();
            end;
        }
        field(20; "Recurrence Pattern"; Option)
        {
            Caption = 'Recurrence Pattern';
            DataClassification = CustomerContent;
            OptionCaption = 'Weekly,Daily,Once';
            OptionMembers = WEEKLY,DAILY,ONCE;

            trigger OnValidate()
            begin
                UpdateEndAfterDate();
                SetDayOfTheWeek();
            end;
        }
        field(21; "Recur Every N On"; Integer)
        {
            Caption = 'Recur Every N On';
            DataClassification = CustomerContent;
        }
        field(22; "Start Time"; Time)
        {
            Caption = 'Start Time';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Stop Time" := "Start Time" + "Event Duration";
            end;
        }
        field(23; "Stop Time"; Time)
        {
            Caption = 'Stop Time';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("Stop Time" < "Start Time") then
                    Error(STOP_TIME);
                "Event Duration" := "Stop Time" - "Start Time";
            end;
        }
        field(24; "Recur Duration"; Duration)
        {
            Caption = 'Recur Duration';
            DataClassification = CustomerContent;
        }
        field(25; "Event Duration"; Duration)
        {
            Caption = 'Event Duration';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Stop Time" := "Start Time" + "Event Duration";

            end;
        }
        field(30; Monday; Boolean)
        {
            Caption = 'Monday';
            DataClassification = CustomerContent;
        }
        field(31; Tuesday; Boolean)
        {
            Caption = 'Tuesday';
            DataClassification = CustomerContent;
        }
        field(32; Wednesday; Boolean)
        {
            Caption = 'Wednesday';
            DataClassification = CustomerContent;
        }
        field(33; Thursday; Boolean)
        {
            Caption = 'Thursday';
            DataClassification = CustomerContent;
        }
        field(34; Friday; Boolean)
        {
            Caption = 'Friday';
            DataClassification = CustomerContent;
        }
        field(35; Saturday; Boolean)
        {
            Caption = 'Saturday';
            DataClassification = CustomerContent;
        }
        field(36; Sunday; Boolean)
        {
            Caption = 'Sunday';
            DataClassification = CustomerContent;
        }
        field(40; "Prebook Is Required"; Boolean)
        {
            Caption = 'Prebook Is Required';
            DataClassification = CustomerContent;
        }
        field(41; "Max Capacity Per Sch. Entry"; Integer)
        {
            Caption = 'Max Capacity Per Sch. Entry';
            DataClassification = CustomerContent;
        }
        field(42; "Reserved For Web"; Integer)
        {
            Caption = 'Reserved For Web';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Never implemented. Use field "Visibility On Web"';

        }
        field(43; "Reserved For Members"; Integer)
        {
            Caption = 'Reserved For Members';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Never implemented. Use field "Visibility On Web"';

        }
        field(44; "Capacity Control"; Option)
        {
            Caption = 'Capacity Control';
            DataClassification = CustomerContent;
            OptionCaption = 'None,Sales,Admitted,Admitted & Departed,Seating';
            OptionMembers = "NONE",SALES,ADMITTED,FULL,SEATING;
        }
        field(45; "Prebook From"; DateFormula)
        {
            Caption = 'Prebook From';
            DataClassification = CustomerContent;
        }
        field(47; "Unbookable Before Start (Secs)"; Integer)
        {
            Caption = 'Unbookable Before Start (Secs)';
            DataClassification = CustomerContent;
        }
        field(48; "Bookable Passed Start (Secs)"; Integer)
        {
            Caption = 'Bookable Passed Start (Secs)';
            DataClassification = CustomerContent;
        }
        field(70; "Notify Stakeholder"; Option)
        {
            Caption = 'Notify Stakeholder';
            DataClassification = CustomerContent;
            OptionCaption = ' ,All,Reserve,Reserve & Cancel,Admit,Admit & Depart';
            OptionMembers = NA,ALL,RESERVE,RESERVE_CANCEL,ADMIT,ADMIT_DEPART;
        }

        field(71; "Notify Stakeholder On Sell-Out"; Option)
        {
            Caption = 'Notify Stakeholder On Sell-Out';
            OptionCaption = 'Off,Both,Ticket Capacity,Waiting List Capacity';
            OptionMembers = OFF,BOTH,TICKET,WAITINGLIST;
            DataClassification = CustomerContent;
        }
        field(72; "Notify When Percentage Sold"; Decimal)
        {
            Caption = 'Notify When Percentage Sold';
            InitValue = 95;
            MinValue = 0;
            MaxValue = 100;
            DataClassification = CustomerContent;
        }
        field(100; "Admission Base Calendar Code"; Code[10])
        {
            Caption = 'Admission Base Calendar Code';
            DataClassification = CustomerContent;
            TableRelation = "Base Calendar";
        }
        field(150; "Event Arrival From Time"; Time)
        {
            Caption = 'Event Arrival From Time';
            DataClassification = CustomerContent;
        }
        field(151; "Event Arrival Until Time"; Time)
        {
            Caption = 'Event Arrival Until Time';
            DataClassification = CustomerContent;
        }
        field(160; "Sales From Date (Rel.)"; DateFormula)
        {
            Caption = 'Sales From Date (Rel.)';
            DataClassification = CustomerContent;
        }
        field(162; "Sales From Time"; Time)
        {
            Caption = 'Sales From Time';
            DataClassification = CustomerContent;
        }
        field(163; "Sales Until Date (Rel.)"; DateFormula)
        {
            Caption = 'Sales Until Date (Rel.)';
            DataClassification = CustomerContent;
        }
        field(165; "Sales Until Time"; Time)
        {
            Caption = 'Sales Until Time';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Schedule Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        TMAdmissionScheduleLines: Record "NPR TM Admis. Schedule Lines";
    begin
        TMAdmissionScheduleLines.Reset();
        TMAdmissionScheduleLines.SetRange("Schedule Code", "Schedule Code");
        TMAdmissionScheduleLines.DeleteAll(true);
    end;

    trigger OnModify()
    begin
        UpdateAdmissionScheduleLines();
    end;

    var
        STOP_TIME: Label 'If your intention is to have a stop time on the next day, please specify event duration instead.';

    local procedure UpdateAdmissionScheduleLines()
    var
        AdmissionScheduleLines: Record "NPR TM Admis. Schedule Lines";
    begin
        AdmissionScheduleLines.SetFilter("Schedule Code", '=%1', Rec."Schedule Code");
        if (AdmissionScheduleLines.FindSet()) then begin
            repeat
                AdmissionScheduleLines.SyncScheduleSettings(Rec);
                AdmissionScheduleLines.Modify();
            until (AdmissionScheduleLines.Next() = 0);
        end;
    end;

    internal procedure ConfirmSync(): Boolean
    var
        AdmissionScheduleLines: Record "NPR TM Admis. Schedule Lines";
        Admission: Record "NPR TM Admission";
        StringBuffer: TextBuilder;
        ConfirmChange: Label 'Depending on the "%1" setting on %5, changes will be synchronized to %2 with "%3" value %4. The following %5 are affected: %6.';
    begin
        if (Rec."Schedule Code" = '') then
            exit(true);

        AdmissionScheduleLines.SetFilter("Schedule Code", '=%1', Rec."Schedule Code");
        if (AdmissionScheduleLines.FindSet()) then begin
            repeat
                if (Admission.Get(AdmissionScheduleLines."Admission Code")) then begin
                    if (Admission."Capacity Limits By" = Admission."Capacity Limits By"::Schedule) then
                        if (StringBuffer.ToText() = '') then
                            StringBuffer.Append(Admission."Admission Code")
                        else
                            StringBuffer.Append(StrSubstNo(', %1', Admission."Admission Code"));
                end;
            until (AdmissionScheduleLines.Next() = 0);

            if (StringBuffer.ToText() <> '') then
                exit(Confirm(ConfirmChange, true, Admission.FieldCaption("Capacity Limits By"), AdmissionScheduleLines.TableCaption(), AdmissionScheduleLines.FieldCaption("Schedule Code"), AdmissionScheduleLines."Schedule Code", Admission.TableCaption, StringBuffer.ToText()));
        end;
        exit(true);
    end;

    local procedure UpdateEndAfterDate()
    var
        TMAdmissionSchManagement: Codeunit "NPR TM Admission Sch. Mgt.";
    begin
        if "Recurrence Until Pattern" = "Recurrence Until Pattern"::AFTER_X_OCCURENCES then begin
            "End After Date" := TMAdmissionSchManagement.GetRecurrenceEndDate("Start From", "End After Occurrence Count", "Recurrence Pattern");
        end;
    end;

    local procedure UpdateRecurrencePattern()
    var
        TMAdmissionSchManagement: Codeunit "NPR TM Admission Sch. Mgt.";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
    begin
        if (Rec."Recurrence Until Pattern" = "Recurrence Until Pattern"::AFTER_X_OCCURENCES) then begin
            if ("End After Date" = 0D) then begin
                Validate("Recurrence Until Pattern", "Recurrence Until Pattern"::NO_END_DATE);
            end else begin
                if (Rec."End After Date" <> TMAdmissionSchManagement.GetRecurrenceEndDate(Rec."Start From", Rec."End After Occurrence Count", Rec."Recurrence Pattern")) then
                    Validate(Rec."Recurrence Until Pattern", Rec."Recurrence Until Pattern"::END_DATE);
            end;
        end;

        if (Rec."End After Date" <> 0D) then begin
            if (Rec."Recurrence Until Pattern" = "Recurrence Until Pattern"::NO_END_DATE) then
                Validate(Rec."Recurrence Until Pattern", Rec."Recurrence Until Pattern"::END_DATE);

            ScheduleLine.SetFilter("Schedule Code", '=%1', Rec."Schedule Code");
            if (ScheduleLine.FindSet()) then begin
                if (ScheduleLine."Schedule Generated Until" > Rec."End After Date") then begin
                    ScheduleLine."Schedule Generated Until" := Rec."End After Date";
                    ScheduleLine.Modify();
                end;
            end
        end;

        if (Rec."End After Date" = 0D) then
            if (Rec."Recurrence Until Pattern" = "Recurrence Until Pattern"::END_DATE) then
                Validate(Rec."Recurrence Until Pattern", Rec."Recurrence Until Pattern"::NO_END_DATE);

    end;

    local procedure SetDayOfTheWeek()
    begin

        if "Recurrence Pattern" = "Recurrence Pattern"::ONCE then begin
            Monday := Date2DWY("Start From", 1) = 1;
            Tuesday := Date2DWY("Start From", 1) = 2;
            Wednesday := Date2DWY("Start From", 1) = 3;
            Thursday := Date2DWY("Start From", 1) = 4;
            Friday := Date2DWY("Start From", 1) = 5;
            Saturday := Date2DWY("Start From", 1) = 6;
            Sunday := Date2DWY("Start From", 1) = 7;
        end;

    end;
}

