table 6151211 "NpCs Open. Hour Calendar Entry"
{
    // NPR5.51/MHA /20190719  CASE 362443 Object created - Collect Store Opening Hour Sets

    Caption = 'Collect Store Opening Hour Date';
    DrillDownPageID = "NpCs Open. Hour Calendar";
    LookupPageID = "NpCs Open. Hour Calendar";

    fields
    {
        field(1;"Calendar Date";Date)
        {
            Caption = 'Date';
        }
        field(5;"Start Time";Time)
        {
            Caption = 'Start Time';
        }
        field(10;"End Time";Time)
        {
            Caption = 'End Time';
        }
        field(1000;Weekday;Text[30])
        {
            CalcFormula = Lookup(Date."Period Name" WHERE ("Period Type"=CONST(Date),
                                                           "Period Start"=FIELD("Calendar Date")));
            Caption = 'Weekday';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Calendar Date","Start Time","End Time")
        {
        }
    }

    fieldgroups
    {
    }
}

