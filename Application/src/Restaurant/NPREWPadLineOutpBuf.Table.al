table 6150672 "NPR NPRE W.Pad.Line Outp.Buf."
{
    Caption = 'Waiter Pad Line Output Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Waiter Pad No."; Code[20])
        {
            Caption = 'Waiter Pad No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Waiter Pad";
        }
        field(2; "Print Template Code"; Code[20])
        {
            Caption = 'Print Template Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR RP Template Header".Code;
        }
        field(3; "Print Category Code"; Code[20])
        {
            Caption = 'Print Category Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Print/Prod. Cat.";
        }
        field(4; "Serving Step"; Code[10])
        {
            Caption = 'Serving Step';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
            TableRelation = "NPR NPRE Flow Status".Code WHERE("Status Object" = CONST(WaiterPadLineMealFlow));
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
            TableRelation = "NPR NPRE Waiter Pad Line"."Line No." WHERE("Waiter Pad No." = FIELD("Waiter Pad No."));
        }
    }

    keys
    {
        key(Key1; "Output Type", "Waiter Pad No.", "Print Template Code", "Serving Step", "Print Category Code", "Waiter Pad Line No.")
        {
        }
    }
}
