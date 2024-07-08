table 6060119 "NPR TM Admis. Schedule Lines"
{
    Access = Internal;

    Caption = 'Admission Schedule Lines';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Admission Code"; Code[20])
        {
            Caption = 'Admission Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Admission";
        }
        field(2; "Schedule Code"; Code[20])
        {
            Caption = 'Schedule Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Admis. Schedule";
        }
        field(10; "Process Order"; Integer)
        {
            Caption = 'Process Order';
            DataClassification = CustomerContent;
        }
        field(11; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if (Rec."Schedule Generated Until" > Today()) then
                    Rec."Schedule Generated Until" := Today();
            end;
        }
        field(40; "Prebook Is Required"; Boolean)
        {
            Caption = 'Prebook Is Required';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                IfAllowOverride();
            end;
        }
        field(41; "Max Capacity Per Sch. Entry"; Integer)
        {
            Caption = 'Max Capacity Per Sch. Entry';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                IfAllowOverride();
            end;
        }
        field(42; "Reserved For Web"; Integer)
        {
            Caption = 'Reserved For Web';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Never implemented. Use field "Visibility On Web"';

            trigger OnValidate()
            begin
                IfAllowOverride();
            end;
        }
        field(43; "Reserved For Members"; Integer)
        {
            Caption = 'Reserved For Members';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Never implemented. Use field "Visibility On Web"';

            trigger OnValidate()
            begin
                IfAllowOverride();
            end;
        }
        field(44; "Capacity Control"; Option)
        {
            Caption = 'Capacity Control';
            DataClassification = CustomerContent;
            OptionCaption = 'None,Sales,Admitted,Admitted & Departed,Seating';
            OptionMembers = "NONE",SALES,ADMITTED,FULL,SEATING;

            trigger OnValidate()
            begin
                IfAllowOverride();
            end;
        }
        field(45; "Prebook From"; DateFormula)
        {
            Caption = 'Prebook From';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                IfAllowOverride();
            end;
        }
        field(46; "Schedule Generated Until"; Date)
        {
            Caption = 'Schedule Generated Until';
            DataClassification = CustomerContent;
        }
        field(47; "Unbookable Before Start (Secs)"; Integer)
        {
            Caption = 'Unbookable Before Start (Secs)';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Use "Event Arrival From Time"';
        }
        field(48; "Bookable Passed Start (Secs)"; Integer)
        {
            Caption = 'Bookable Passed Start (Secs)';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Use "Event Arrival Until Time"';
        }
        field(50; "Schedule Generated At"; Date)
        {
            Caption = 'Schedule Generated At';
            DataClassification = CustomerContent;
        }
        field(60; "Visibility On Web"; Option)
        {
            Caption = 'Visibility On Web';
            DataClassification = CustomerContent;
            OptionCaption = 'Visible,Hidden';
            OptionMembers = VISIBLE,HIDDEN;
        }
        field(70; "Seating Template Code"; Code[20])
        {
            Caption = 'Seating Template Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Seating Setup";
        }
        field(75; "Concurrency Code"; Code[20])
        {
            Caption = 'Concurrency Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Concurrent Admis. Setup";
        }
        field(80; "Pricing Option"; Option)
        {
            Caption = 'Pricing Option';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Fixed Amount,Relative Amount,Percentage';
            OptionMembers = NA,"FIXED",RELATIVE,PERCENT;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Moved to profile  table, used the field Dynamic Price Profile to specify dynamic pricing.';
        }
        field(81; "Price Scope"; Option)
        {
            Caption = 'Price Scope';
            DataClassification = CustomerContent;
            OptionCaption = ' ,API,POS & M2,All';
            OptionMembers = NA,API,POS_M2,API_POS_M2;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Moved to profile  table, used the field Dynamic Price Profile to specify dynamic pricing.';
        }
        field(82; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Moved to profile  table, used the field Dynamic Price Profile to specify dynamic pricing.';
        }
        field(83; Percentage; Decimal)
        {
            Caption = 'Percentage';
            DataClassification = CustomerContent;
            MinValue = -100;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Moved to profile  table, used the field Dynamic Price Profile to specify dynamic pricing.';
        }
        field(85; "Amount Includes VAT"; Boolean)
        {
            Caption = 'Amount Includes VAT';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Moved to profile  table, used the field Dynamic Price Profile to specify dynamic pricing.';
        }
        field(86; "Dynamic Price Profile Code"; Code[10])
        {
            Caption = 'Dynamic Price Profile Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Dynamic Price Profile".ProfileCode;
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
            trigger OnValidate()
            begin
                IfAllowOverride();
            end;
        }
        field(151; "Event Arrival Until Time"; Time)
        {
            Caption = 'Event Arrival Until Time';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                IfAllowOverride();
            end;
        }
        field(160; "Sales From Date (Rel.)"; DateFormula)
        {
            Caption = 'Sales From Date (Rel.)';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                IfAllowOverride();
            end;
        }
        field(162; "Sales From Time"; Time)
        {
            Caption = 'Sales From Time';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                IfAllowOverride();
            end;
        }
        field(163; "Sales Until Date (Rel.)"; DateFormula)
        {
            Caption = 'Sales Until Date (Rel.)';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                IfAllowOverride();
            end;
        }
        field(165; "Sales Until Time"; Time)
        {
            Caption = 'Sales Until Time';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                IfAllowOverride();
            end;
        }
        field(200; "Scheduled Start Time"; Time)
        {
            CalcFormula = Lookup("NPR TM Admis. Schedule"."Start Time" WHERE("Schedule Code" = FIELD("Schedule Code")));
            Caption = 'Scheduled Start Time';
            Editable = false;
            FieldClass = FlowField;
        }
        field(201; "Scheduled Stop Time"; Time)
        {
            CalcFormula = Lookup("NPR TM Admis. Schedule"."Stop Time" WHERE("Schedule Code" = FIELD("Schedule Code")));
            Caption = 'Scheduled Stop Time';
            Editable = false;
            FieldClass = FlowField;
        }
        field(210; "Capacity Limit By"; Enum "NPR TM CapacityLimit")
        {
            CalcFormula = Lookup("NPR TM Admission"."Capacity Limits By" WHERE("Admission Code" = FIELD("Admission Code")));
            Caption = 'Capacity Limit By';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Admission Code", "Schedule Code")
        {
        }
        key(Key2; "Admission Code", "Process Order")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        TMAdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        //-TM1.24 [289293]
        if (not Confirm(ADM_SCH_DELETE, false)) then
            Error('');

        TMAdmissionScheduleEntry.Reset();
        TMAdmissionScheduleEntry.SetCurrentKey("Admission Code", "Schedule Code", "Admission Start Date");
        TMAdmissionScheduleEntry.SetRange("Admission Code", "Admission Code");
        TMAdmissionScheduleEntry.SetRange("Schedule Code", "Schedule Code");
        TMAdmissionScheduleEntry.ModifyAll(Cancelled, true);

        TMAdmissionScheduleEntry.Reset();
        TMAdmissionScheduleEntry.SetCurrentKey("Admission Code", "Schedule Code", "Admission Start Date");
        TMAdmissionScheduleEntry.SetRange("Admission Code", "Admission Code");
        TMAdmissionScheduleEntry.SetRange("Schedule Code", "Schedule Code");
        if (TMAdmissionScheduleEntry.FindSet()) then begin
            repeat
                TMAdmissionScheduleEntry.CalcFields("Initial Entry", "Open Reservations", "Open Admitted", Departed);
                if ((TMAdmissionScheduleEntry."Initial Entry" = 0) and
                    (TMAdmissionScheduleEntry."Open Reservations" = 0) and
                    (TMAdmissionScheduleEntry."Open Admitted" = 0) and
                    (TMAdmissionScheduleEntry.Departed = 0)) then
                    TMAdmissionScheduleEntry.Delete();
            until (TMAdmissionScheduleEntry.Next() = 0);
        end;
        //+TM1.24 [289293]
    end;

    trigger OnInsert()
    var
        Admission: Record "NPR TM Admission";
        AdmissionSchedule: Record "NPR TM Admis. Schedule";
    begin
        Admission.Get("Admission Code");
        SyncAdmissionSettings(Admission);

        AdmissionSchedule.Get("Schedule Code");
        SyncScheduleSettings(AdmissionSchedule);
    end;

    trigger OnModify()
    begin
        //-+TM1.21
        "Schedule Generated At" := 0D;
    end;

    trigger OnRename()
    var
        TextRenameNotAllowed: Label 'Rename not allowed for table %1.';
    begin
        //-TM1.11
        Error(TextRenameNotAllowed, TableCaption);
        //+TM1.11
    end;

    var
        ADM_SCH_DELETE: Label 'This action will cancel (and delete when possible) the linked admission schedule entries created for this admission and schedule.\\Do you want to continue?';

    procedure SyncAdmissionSettings(Admission: Record "NPR TM Admission")
    var
        AdmissionSchedule: Record "NPR TM Admis. Schedule";
    begin
        if (Admission.IsTemporary) then
            exit;

        TestField("Schedule Code");
        AdmissionSchedule.Get("Schedule Code");

        if (Admission."Capacity Limits By" = Admission."Capacity Limits By"::ADMISSION) then begin
            "Prebook Is Required" := Admission."Prebook Is Required";
            "Max Capacity Per Sch. Entry" := Admission."Max Capacity Per Sch. Entry";
            "Capacity Control" := Admission."Capacity Control";
            "Prebook From" := Admission."Prebook From";

            "Event Arrival From Time" := Admission."Event Arrival From Time";
            "Event Arrival Until Time" := Admission."Event Arrival Until Time";

            "Sales From Date (Rel.)" := Admission."Sales From Date (Rel.)";
            "Sales From Time" := Admission."Sales From Time";
            "Sales Until Date (Rel.)" := Admission."Sales Until Date (Rel.)";
            "Sales Until Time" := Admission."Sales Until Time";
        end;
    end;

    procedure SyncScheduleSettings(AdmissionSchedule: Record "NPR TM Admis. Schedule")
    var
        Admission: Record "NPR TM Admission";
    begin
        if (AdmissionSchedule.IsTemporary) then
            exit;

        TestField("Admission Code");
        Admission.Get("Admission Code");

        if (Admission."Capacity Limits By" = Admission."Capacity Limits By"::SCHEDULE) then begin
            "Prebook Is Required" := AdmissionSchedule."Prebook Is Required";
            "Max Capacity Per Sch. Entry" := AdmissionSchedule."Max Capacity Per Sch. Entry";
            "Capacity Control" := AdmissionSchedule."Capacity Control";
            "Prebook From" := AdmissionSchedule."Prebook From";

            "Event Arrival From Time" := AdmissionSchedule."Event Arrival From Time";
            "Event Arrival Until Time" := AdmissionSchedule."Event Arrival Until Time";

            "Sales From Date (Rel.)" := AdmissionSchedule."Sales From Date (Rel.)";
            "Sales From Time" := AdmissionSchedule."Sales From Time";
            "Sales Until Date (Rel.)" := AdmissionSchedule."Sales Until Date (Rel.)";
            "Sales Until Time" := AdmissionSchedule."Sales Until Time";
        end;
    end;

    local procedure IfAllowOverride()
    var
        Admission: Record "NPR TM Admission";
    begin
        // TODO change override
        TestField("Admission Code");
        Admission.Get("Admission Code");
        Admission.TestField("Capacity Limits By", Admission."Capacity Limits By"::OVERRIDE);
    end;

}

