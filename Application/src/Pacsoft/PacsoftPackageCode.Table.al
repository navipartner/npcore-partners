table 6014471 "NPR Pacsoft Package Code"
{
    // PS1.00/LS/20141201  CASE 200150 Pacsoft Module

    Caption = 'Pacsoft Package Codes';
    DrillDownPageID = "NPR Pacsoft Package Codes";
    LookupPageID = "NPR Pacsoft Package Codes";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }
}

