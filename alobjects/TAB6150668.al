table 6150668 "NPRE W.Pad Line Print Category"
{
    // NPR5.53/ALPO/20200102 CASE 360258 Possibility to send to kitchen only selected waiter pad lines or lines of specific print category

    Caption = 'W. Pad Line Print Category';
    DrillDownPageID = "NPRE W.Pad L. Print Categories";
    LookupPageID = "NPRE W.Pad L. Print Categories";

    fields
    {
        field(1;"Waiter Pad No.";Code[20])
        {
            Caption = 'Waiter Pad No.';
            TableRelation = "NPRE Waiter Pad";
        }
        field(2;"Waiter Pad Line No.";Integer)
        {
            Caption = 'Waiter Pad Line No.';
            TableRelation = "NPRE Waiter Pad Line"."Line No." WHERE ("Waiter Pad No."=FIELD("Waiter Pad No."));
        }
        field(4;"Print Category Code";Code[20])
        {
            Caption = 'Print Category Code';
            TableRelation = "NPRE Print Category";
        }
    }

    keys
    {
        key(Key1;"Waiter Pad No.","Waiter Pad Line No.","Print Category Code")
        {
        }
    }

    fieldgroups
    {
    }
}

