table 6060122 "NPR TM Admis. Schedule Entry"
{
    // NPR4.16/TSA/20150803 CASE219658 Ticket Initial Version
    // TM1.00/TSA/20151217  CASE 224225 NaviPartner Ticket Management
    // TM1.04/TSA/20160115  CASE 231834 Changed flowfields to sum quantity rather than count lines
    // TM1.11/TSA/20160325  CASE 237486 End date and end time on entries for web
    // TM1.11/TSA/20160404  CASE 232250 Added field 47 and 48
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.17/TSA/20161024  CASE 256205 Added key for startdate and starttime, added field 41"Max Capacity Per Sch. Entry"Integer
    // TM1.20/TSA/20170324  CASE 269171 Added Initial Entry Flowfield
    // TM1.23/TSA/20170623  CASE 280612 Added "Regeneration Mode" option Auto / Manual
    // TM1.24/TSA /20170921 CASE 289293 Regfactored OnDelete trigger
    // TM1.28/TSA /20180221 CASE 306039 Added "Visibility On Web"
    // TM1.37/TSA /20180905 CASE 327324 Added fields for better control of arrival window
    // TM1.45/TSA /20191120 CASE 378212 Added the sales cut-off date and time
    // TM1.45/TSA /20191203 CASE 380754 Added field Allocation By option

    Caption = 'Admission Schedule Entry';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR TM Admis. Schedule Entry";
    LookupPageID = "NPR TM Admis. Schedule Entry";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(3; "External Schedule Entry No."; Integer)
        {
            Caption = 'External Schedule Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Admission Code"; Code[20])
        {
            Caption = 'Admission Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Admission";
        }
        field(11; "Schedule Code"; Code[20])
        {
            Caption = 'Schedule Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Admis. Schedule";
        }
        field(12; Cancelled; Boolean)
        {
            Caption = 'Cancelled';
            DataClassification = CustomerContent;
        }
        field(20; "Admission Start Date"; Date)
        {
            Caption = 'Admission Start Date';
            DataClassification = CustomerContent;
        }
        field(21; "Admission Start Time"; Time)
        {
            Caption = 'Admission Start Time';
            DataClassification = CustomerContent;
        }
        field(22; "Event Duration"; Duration)
        {
            Caption = 'Event Duration';
            DataClassification = CustomerContent;
        }
        field(23; "Admission Is"; Option)
        {
            Caption = 'Admission Is';
            DataClassification = CustomerContent;
            OptionCaption = 'Open,Closed';
            OptionMembers = OPEN,CLOSED;

            trigger OnValidate()
            begin
                "Regenerate With" := "Regenerate With"::MANUAL;
            end;
        }
        field(25; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            DataClassification = CustomerContent;
        }
        field(30; "Admission End Date"; Date)
        {
            Caption = 'Admission End Date';
            DataClassification = CustomerContent;
        }
        field(31; "Admission End Time"; Time)
        {
            Caption = 'Admission End Time';
            DataClassification = CustomerContent;
        }
        field(41; "Max Capacity Per Sch. Entry"; Integer)
        {
            Caption = 'Max Capacity Per Sch. Entry';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Regenerate With" := "Regenerate With"::MANUAL;
            end;
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
        field(50; "Regenerate With"; Option)
        {
            Caption = 'Regenerate With';
            DataClassification = CustomerContent;
            OptionCaption = 'Scheduler,Manual';
            OptionMembers = SCHEDULER,MANUAL;
        }
        field(60; "Visibility On Web"; Option)
        {
            Caption = 'Visibility On Web';
            DataClassification = CustomerContent;
            Description = '//-TM1.28 [306039]';
            OptionCaption = 'Visible,Hidden';
            OptionMembers = VISIBLE,HIDDEN;

            trigger OnValidate()
            begin
                "Regenerate With" := "Regenerate With"::MANUAL;
            end;
        }
        field(100; "Open Reservations"; Decimal)
        {
            CalcFormula = Sum("NPR TM Det. Ticket AccessEntry".Quantity WHERE("External Adm. Sch. Entry No." = FIELD("External Schedule Entry No."),
                                                                            Type = CONST(RESERVATION),
                                                                            Open = CONST(true),
                                                                            "Sales Channel No." = FIELD("Sales Channel Filter")));
            Caption = 'Open Reservations';
            Editable = false;
            FieldClass = FlowField;
        }
        field(101; "Open Admitted"; Decimal)
        {
            CalcFormula = Sum("NPR TM Det. Ticket AccessEntry".Quantity WHERE("External Adm. Sch. Entry No." = FIELD("External Schedule Entry No."),
                                                                            Type = CONST(ADMITTED),
                                                                            Open = CONST(true),
                                                                            "Sales Channel No." = FIELD("Sales Channel Filter")));
            Caption = 'Open Admitted';
            Editable = false;
            FieldClass = FlowField;
        }
        field(102; Departed; Decimal)
        {
            CalcFormula = Sum("NPR TM Det. Ticket AccessEntry".Quantity WHERE("External Adm. Sch. Entry No." = FIELD("External Schedule Entry No."),
                                                                            Type = CONST(DEPARTED),
                                                                            Open = CONST(false),
                                                                            "Sales Channel No." = FIELD("Sales Channel Filter")));
            Caption = 'Departed';
            Editable = false;
            FieldClass = FlowField;
        }
        field(103; "Initial Entry"; Decimal)
        {
            CalcFormula = Sum("NPR TM Det. Ticket AccessEntry".Quantity WHERE("External Adm. Sch. Entry No." = FIELD("External Schedule Entry No."),
                                                                            Type = CONST(INITIAL_ENTRY),
                                                                            Open = CONST(false),
                                                                            "Sales Channel No." = FIELD("Sales Channel Filter")));
            Caption = 'Initial Entry';
            Editable = false;
            FieldClass = FlowField;
        }
        field(104; "Initial Entry (All)"; Decimal)
        {
            CalcFormula = Sum("NPR TM Det. Ticket AccessEntry".Quantity WHERE("External Adm. Sch. Entry No." = FIELD("External Schedule Entry No."),
                                                                            Type = CONST(INITIAL_ENTRY),
                                                                            "Sales Channel No." = FIELD("Sales Channel Filter")));
            Caption = 'Initial Entry (All)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(105; "Open Reservations (All)"; Decimal)
        {
            CalcFormula = Sum("NPR TM Det. Ticket AccessEntry".Quantity WHERE("External Adm. Sch. Entry No." = FIELD("External Schedule Entry No."),
                                                                            Type = CONST(RESERVATION),
                                                                            "Sales Channel No." = FIELD("Sales Channel Filter")));
            Caption = 'Open Reservations (All)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(109; "Sales Channel Filter"; Code[10])
        {
            Caption = 'Sales Channel Filter';
            FieldClass = FlowFilter;
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
        field(161; "Sales From Date"; Date)
        {
            Caption = 'Sales From Date';
            DataClassification = CustomerContent;
        }
        field(162; "Sales From Time"; Time)
        {
            Caption = 'Sales From Time';
            DataClassification = CustomerContent;
        }
        field(164; "Sales Until Date"; Date)
        {
            Caption = 'Sales Until Date';
            DataClassification = CustomerContent;
        }
        field(165; "Sales Until Time"; Time)
        {
            Caption = 'Sales Until Time';
            DataClassification = CustomerContent;
        }
        field(200; "Allocation By"; Option)
        {
            Caption = 'Allocation By';
            DataClassification = CustomerContent;
            OptionCaption = 'Capacity,Waiting List';
            OptionMembers = CAPACITY,WAITINGLIST;
        }
        field(210; "Waiting List Queue"; Integer)
        {
            CalcFormula = Count("NPR TM Ticket Wait. List" WHERE("External Schedule Entry No." = FIELD("External Schedule Entry No."),
                                                                Status = CONST(ACTIVE)));
            Caption = 'Waiting List Queue';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "External Schedule Entry No.")
        {
        }
        key(Key3; "Admission Code", "Schedule Code", "Admission Start Date")
        {
        }
        key(Key4; "Admission Start Date", "Admission Start Time")
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

        if (UserId = 'TSA') then exit;

        //-TM1.24 [289293]
        if (not Cancelled) then
            Error(DELETE_NOT_ALLOWED_2, "Entry No.", TMAdmissionScheduleLines.TableCaption, "Admission Code", "Schedule Code");

        CalcFields("Open Reservations", "Open Admitted", Departed, "Initial Entry");
        if (("Initial Entry" <> 0) or
            ("Open Reservations" <> 0) or
            ("Open Admitted" <> 0) or
            (Departed <> 0)) then
            Error(DELETE_NOT_ALLOWED_1, "Entry No.");
        //+TM1.24 [289293]
    end;

    var
        DELETE_NOT_ALLOWED_1: Label 'Delete of Admission Schedule Entry %1 is not allowed because it has linked ticket activities.';
        DELETE_NOT_ALLOWED_2: Label 'Delete of Admission Schedule Entry %1 is not allowed because it is managed by %2 %3 %4. Delete %2 %3 %4 first.';
}

