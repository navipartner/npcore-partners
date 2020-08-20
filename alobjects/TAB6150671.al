table 6150671 "NPRE W.Pad Line Prnt Log Entry"
{
    // NPR5.53/ALPO/20200102 CASE 360258 Possibility to send to kitchen only selected waiter pad lines or lines of specific print category
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant
    // NPR5.55/ALPO/20200615 CASE 399170 Restaurant flow change: support for waiter pad related manipulations directly inside a POS sale

    Caption = 'W. Pad Line Send Log Entry';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPRE W.Pad Line Pr.Log Entries";
    LookupPageID = "NPRE W.Pad Line Pr.Log Entries";

    fields
    {
        field(1; "Waiter Pad No."; Code[20])
        {
            Caption = 'Waiter Pad No.';
            DataClassification = CustomerContent;
            TableRelation = "NPRE Waiter Pad";
        }
        field(2; "Waiter Pad Line No."; Integer)
        {
            Caption = 'Waiter Pad Line No.';
            DataClassification = CustomerContent;
            TableRelation = "NPRE Waiter Pad Line"."Line No." WHERE("Waiter Pad No." = FIELD("Waiter Pad No."));
        }
        field(4; "Print Category Code"; Code[20])
        {
            Caption = 'Print Category Code';
            DataClassification = CustomerContent;
            TableRelation = "NPRE Print/Prod. Category";
        }
        field(5; "Flow Status Object"; Option)
        {
            Caption = 'Flow Status Object';
            DataClassification = CustomerContent;
            OptionCaption = 'Seating,Waiter Pad,Waiter Pad Line Meal Flow,Waiter Pad Line Status';
            OptionMembers = Seating,WaiterPad,WaiterPadLineMealFlow,WaiterPadLineStatus;
        }
        field(6; "Flow Status Code"; Code[10])
        {
            Caption = 'Serving Step Code';
            DataClassification = CustomerContent;
            TableRelation = "NPRE Flow Status".Code WHERE("Status Object" = FIELD("Flow Status Object"));
        }
        field(7; "Print Type"; Option)
        {
            Caption = 'Request Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Kitchen Order,Serving Request';
            OptionMembers = "Kitchen Order","Serving Request";
        }
        field(10; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(20; "Output Type"; Option)
        {
            Caption = 'Output Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            OptionCaption = 'Print,KDS';
            OptionMembers = Print,KDS;
        }
        field(30; "Sent Date-Time"; DateTime)
        {
            Caption = 'Sent Date-Time';
            DataClassification = CustomerContent;
        }
        field(40; "Sent Quanity (Base)"; Decimal)
        {
            Caption = 'Sent Quanity (Base)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.55';
        }
        field(50; Context; Option)
        {
            Caption = 'Context';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
            OptionCaption = 'Ordering,Line Splitting';
            OptionMembers = Ordering,"Line Splitting";
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Waiter Pad No.", "Waiter Pad Line No.", "Print Type", "Print Category Code", "Flow Status Object", "Flow Status Code", "Output Type")
        {
            SumIndexFields = "Sent Quanity (Base)";
        }
    }

    fieldgroups
    {
    }
}

