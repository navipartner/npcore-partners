table 6150662 "NPRE Seating - Waiter Pad Link"
{
    // NPR5.34/ANEN  /2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.35/ANEN /20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.35/JDH /20170828 CASE 288314 Seating Code changed to code 10

    Caption = 'Seating - Waiter Pad Link';

    fields
    {
        field(1;"Seating Code";Code[10])
        {
            Caption = 'Seating Code';
            TableRelation = "NPRE Seating".Code;
            ValidateTableRelation = true;
        }
        field(2;"Waiter Pad No.";Code[20])
        {
            Caption = 'Waiter Pad No.';
            TableRelation = "NPRE Waiter Pad"."No.";
            ValidateTableRelation = true;
        }
        field(10;"No. Of Waiter Pad For Seating";Integer)
        {
            Caption = 'No. Of Waiter Pad For Seating';
        }
        field(11;"No. Of Seating For Waiter Pad";Integer)
        {
            Caption = 'No. Of Seating For Waiter Pad';
        }
        field(12;"Seating Description FF";Text[50])
        {
            CalcFormula = Lookup("NPRE Seating".Description WHERE (Code=FIELD("Seating Code")));
            Caption = 'Seating Description';
            FieldClass = FlowField;
        }
        field(13;"Waiter Pad Description FF";Text[50])
        {
            CalcFormula = Lookup("NPRE Waiter Pad".Description WHERE ("No."=FIELD("Waiter Pad No.")));
            Caption = 'Waiter Pad Description';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Seating Code","Waiter Pad No.")
        {
        }
    }

    fieldgroups
    {
    }
}

