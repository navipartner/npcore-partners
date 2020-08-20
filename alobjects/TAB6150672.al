table 6150672 "NPRE W.Pad Line Output Buffer"
{
    // NPR5.53/ALPO/20200102 CASE 360258 Possibility to send to kitchen only selected waiter pad lines or lines of specific print category
    // NPR5.55/ALPO/20200708 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)
    //                                   - fields Output Type, "Serving Step" added to primary key

    Caption = 'Waiter Pad Line Output Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Waiter Pad No."; Code[20])
        {
            Caption = 'Waiter Pad No.';
            DataClassification = CustomerContent;
            TableRelation = "NPRE Waiter Pad";
        }
        field(2; "Print Template Code"; Code[20])
        {
            Caption = 'Print Template Code';
            DataClassification = CustomerContent;
            TableRelation = "RP Template Header".Code;
        }
        field(3; "Print Category Code"; Code[20])
        {
            Caption = 'Print Category Code';
            DataClassification = CustomerContent;
            TableRelation = "NPRE Print/Prod. Category";
        }
        field(4; "Serving Step"; Code[10])
        {
            Caption = 'Serving Step';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
            TableRelation = "NPRE Flow Status".Code WHERE("Status Object" = CONST(WaiterPadLineMealFlow));
        }
        field(5; "Output Type"; Option)
        {
            Caption = 'Output Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
            OptionCaption = 'Print,KDS';
            OptionMembers = Print,KDS;
        }
        field(10; "Waiter Pad Line No."; Integer)
        {
            Caption = 'Waiter Pad Line No.';
            DataClassification = CustomerContent;
            TableRelation = "NPRE Waiter Pad Line"."Line No." WHERE("Waiter Pad No." = FIELD("Waiter Pad No."));
        }
    }

    keys
    {
        key(Key1; "Output Type", "Waiter Pad No.", "Print Template Code", "Serving Step", "Print Category Code", "Waiter Pad Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

