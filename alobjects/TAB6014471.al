table 6014471 "Pacsoft Package Code"
{
    // PS1.00/LS/20141201  CASE 200150 Pacsoft Module

    Caption = 'Pacsoft Package Codes';
    DrillDownPageID = "Pacsoft Package Codes";
    LookupPageID = "Pacsoft Package Codes";

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
        }
        field(2;Description;Text[30])
        {
            Caption = 'Description';
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

