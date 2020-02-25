table 6150671 "NPRE W.Pad Line Prnt Log Entry"
{
    // NPR5.53/ALPO/20200102 CASE 360258 Possibility to send to kitchen only selected waiter pad lines or lines of specific print category

    Caption = 'W. Pad Line Print Log Entry';
    DrillDownPageID = "NPRE W.Pad Line Pr.Log Entries";
    LookupPageID = "NPRE W.Pad Line Pr.Log Entries";

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
        field(5;"Flow Status Object";Option)
        {
            Caption = 'Flow Status Object';
            OptionCaption = 'Seating,Waiter Pad,Waiter Pad Line Meal Flow,Waiter Pad Line Status';
            OptionMembers = Seating,WaiterPad,WaiterPadLineMealFlow,WaiterPadLineStatus;
        }
        field(6;"Flow Status Code";Code[10])
        {
            Caption = 'Flow Status Code';
            TableRelation = "NPRE Flow Status".Code WHERE ("Status Object"=FIELD("Flow Status Object"));
        }
        field(7;"Print Type";Option)
        {
            Caption = 'Print Type';
            OptionCaption = 'Kitchen Order,Serving Request';
            OptionMembers = "Kitchen Order","Serving Request";
        }
        field(10;"Entry No.";BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(30;"Sent Date-Time";DateTime)
        {
            Caption = 'Sent Date-Time';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Waiter Pad No.","Waiter Pad Line No.","Print Type","Print Category Code","Flow Status Object","Flow Status Code")
        {
        }
    }

    fieldgroups
    {
    }
}

