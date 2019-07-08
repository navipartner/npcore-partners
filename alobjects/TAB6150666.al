table 6150666 "NPRE Seating Location"
{
    // NPR5.34/ANEN  /2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.35/ANEN /20170821 CASE 283376 Solution rename to NP Restaurant

    Caption = 'Seating Location';
    DrillDownPageID = "NPRE Seating Location";
    LookupPageID = "NPRE Seating Location";

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
        }
        field(2;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(10;Seatings;Integer)
        {
            CalcFormula = Count("NPRE Seating" WHERE ("Seating Location"=FIELD(Code)));
            Caption = 'Seatings';
            FieldClass = FlowField;
        }
        field(11;Seats;Integer)
        {
            CalcFormula = Sum("NPRE Seating".Capacity WHERE ("Seating Location"=FIELD(Code)));
            Caption = 'Seats';
            FieldClass = FlowField;
        }
        field(20;"POS Store";Code[10])
        {
            Caption = 'POS Store';
            TableRelation = "POS Store".Code;
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }
}

