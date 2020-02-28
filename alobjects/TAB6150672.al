table 6150672 "NPRE W.Pad Print Buffer"
{
    // NPR5.53/ALPO/20200102 CASE 360258 Possibility to send to kitchen only selected waiter pad lines or lines of specific print category

    Caption = 'Waiter Pad Print Buffer';

    fields
    {
        field(1;"Waiter Pad No.";Code[20])
        {
            Caption = 'Waiter Pad No.';
            TableRelation = "NPRE Waiter Pad";
        }
        field(2;"Print Template Code";Code[20])
        {
            Caption = 'Print Template Code';
            TableRelation = "RP Template Header".Code;
        }
        field(3;"Print Category Code";Code[20])
        {
            Caption = 'Print Category Code';
            TableRelation = "NPRE Print Category";
        }
        field(10;"Waiter Pad Line No.";Integer)
        {
            Caption = 'Waiter Pad Line No.';
            TableRelation = "NPRE Waiter Pad Line"."Line No." WHERE ("Waiter Pad No."=FIELD("Waiter Pad No."));
        }
    }

    keys
    {
        key(Key1;"Waiter Pad No.","Print Template Code","Print Category Code","Waiter Pad Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

