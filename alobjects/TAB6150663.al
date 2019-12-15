table 6150663 "NPRE Print Category"
{
    // NPR5.34/ANEN  /2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.35/ANEN /20170821 CASE 283376 Solution rename to NP Restaurant

    Caption = 'Print Category';
    DrillDownPageID = "NPRE Print Category";
    LookupPageID = "NPRE Print Category";

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
        }
        field(2;"Print Tag";Text[100])
        {
            Caption = 'Print Tag';
        }
        field(11;"Kitchen Order Template";Code[20])
        {
            Caption = 'Kitchen Order Template';
            TableRelation = "RP Template Header".Code;
            ValidateTableRelation = true;
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

