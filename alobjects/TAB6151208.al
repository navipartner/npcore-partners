table 6151208 "NpCs Store Opening Hours Entry"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store
    // NPR5.51/MHA /20190719  CASE 362443 [VLOBJDEL] Object marked for deletion

    Caption = 'Collect Store Opening Hours Entry';
    DrillDownPageID = "NpCs Store Opening Hours";
    LookupPageID = "NpCs Store Opening Hours";

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

