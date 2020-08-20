table 6060118 "TM Admission Schedule"
{
    // TM1.00/TSA/20151217  CASE 228982 NaviPartner Ticket Management
    // TM80.1.09/TSA/20160310  CASE 236689 Change field from percentage to absolute
    // TM1.11/TSA/20160325  CASE 237486 End date and end time on entries for web / Captions
    // TM1.11/BR/20160331  CASE 237850 Changed recurrance calculation, Addded check to OnDelete, Added Recurrence Pattern NONE
    // TM1.11/TSA/20160404  CASE 232250 Added field 47 and 48
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.17/TSA /20161025  CASE 256152 Conform to OMA Guidelines
    // TM1.28/TSA /20180131 CASE 303925 Added Admission Base Calendar Code to establish "non-working" days.
    // TM1.37/TSA /20180905 CASE 327324 Added fields for better control of arrival window
    // TM1.41/TSA /20190429 CASE 353352 Stop time and event duration is kept under better sync.
    // TM1.43/TSA /20190903 CASE 357359 Added option to Capacity Control (SEATING)
    // #378212/TSA /20191120 CASE 378212 Added Sales Cut-off dates
    // #378212/TSA /20191120 CASE 378212 Removed default assignment of "Event Arrival From Time", "Event Arrival Until Time"
    // TM1.45/TSA/20200122  CASE 374620 Transport TM1.45 - 22 January 2020

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
                //-TM1.11
                UpdateEndAfterDate;
                SetDayOfTheWeek;
                //+TM1.11
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
                //-TM1.11
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
                UpdateEndAfterDate;
                //+TM1.11
            end;
        }
        field(13; "End After Occurrence Count"; Integer)
        {
            Caption = 'End After Occurrence Count';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                //-TM1.11
                UpdateEndAfterDate;
                //+TM1.11
            end;
        }
        field(14; "End After Date"; Date)
        {
            Caption = 'End After Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                //-NPRx.xx
                UpdateReccurencePattern;
                //+TM1.11
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
                //-NPRx.xx
                UpdateEndAfterDate;
                SetDayOfTheWeek;
                //+TM1.11
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
                //-#378212 [378212]
                // "Event Arrival From Time" := "Start Time";
                //
                // //-TM1.41 [353352]
                // "Stop Time" := "Start Time" + "Event Duration";
                // "Event Arrival Until Time" := "Stop Time";
                // //+TM1.41 [353352]

                "Stop Time" := "Start Time" + "Event Duration";
                //+#378212 [378212]
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

                //-#378212 [378212]
                //"Event Arrival Until Time" := "Stop Time";
                //+#378212 [378212]
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

                //-#378212 [378212]
                // "Event Arrival Until Time" := "Stop Time";
                //+#378212 [378212]
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
        }
        field(43; "Reserved For Members"; Integer)
        {
            Caption = 'Reserved For Members';
            DataClassification = CustomerContent;
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
        TMAdmissionScheduleLines: Record "TM Admission Schedule Lines";
    begin
        //-TM1.11
        TMAdmissionScheduleLines.Reset;
        TMAdmissionScheduleLines.SetRange("Schedule Code", "Schedule Code");
        TMAdmissionScheduleLines.DeleteAll(true);
        //+TM1.11
    end;

    trigger OnModify()
    begin
        UpdateScheduleLines();
    end;

    var
        STOP_TIME: Label 'If your intention is to have a stop time on the next day, please specify event duration instead.';

    local procedure UpdateScheduleLines()
    var
        AdmissionScheduleLines: Record "TM Admission Schedule Lines";
    begin
        AdmissionScheduleLines.SetFilter("Schedule Code", '=%1', "Schedule Code");
        if (AdmissionScheduleLines.FindSet()) then begin
            repeat
                AdmissionScheduleLines.SyncScheduleSettings(Rec);
                AdmissionScheduleLines.Modify();
            until (AdmissionScheduleLines.Next() = 0);
        end;
    end;

    local procedure UpdateEndAfterDate()
    var
        TMAdmissionSchManagement: Codeunit "TM Admission Sch. Management";
    begin
        //-TM1.11
        if "Recurrence Until Pattern" = "Recurrence Until Pattern"::AFTER_X_OCCURENCES then begin
            "End After Date" := TMAdmissionSchManagement.GetRecurrenceEndDate("Start From", "End After Occurrence Count", "Recurrence Pattern");
        end;
        //+TM1.11
    end;

    local procedure UpdateReccurencePattern()
    var
        TMAdmissionSchManagement: Codeunit "TM Admission Sch. Management";
    begin
        //-TM1.11
        if "Recurrence Until Pattern" = "Recurrence Until Pattern"::AFTER_X_OCCURENCES then begin
            if "End After Date" = 0D then begin
                Validate("Recurrence Until Pattern", "Recurrence Until Pattern"::NO_END_DATE);
            end else begin
                if "End After Date" <> TMAdmissionSchManagement.GetRecurrenceEndDate("Start From", "End After Occurrence Count", "Recurrence Pattern") then begin
                    Validate("Recurrence Until Pattern", "Recurrence Until Pattern"::END_DATE);
                end;
            end;
        end;
        //+TM1.11
    end;

    local procedure SetDayOfTheWeek()
    begin
        //-TM1.11
        if "Recurrence Pattern" = "Recurrence Pattern"::ONCE then begin
            Monday := Date2DWY("Start From", 1) = 1;
            Tuesday := Date2DWY("Start From", 1) = 2;
            Wednesday := Date2DWY("Start From", 1) = 3;
            Thursday := Date2DWY("Start From", 1) = 4;
            Friday := Date2DWY("Start From", 1) = 5;
            Saturday := Date2DWY("Start From", 1) = 6;
            Sunday := Date2DWY("Start From", 1) = 7;
        end;
        //+TM1.11
    end;
}

