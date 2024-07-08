table 6184486 "NPR EFT Integration Type"
{
    Caption = 'EFT Integration Type';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR EFT Integration Types";
    LookupPageID = "NPR EFT Integration Types";

    fields
    {
        field(10; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(20; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(30; "Codeunit ID"; Integer)
        {
            Caption = 'Codeunit ID';
            DataClassification = CustomerContent;
        }
        field(40; "Version 2"; Boolean)
        {
            Caption = 'Legacy';
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

