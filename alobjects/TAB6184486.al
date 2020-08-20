table 6184486 "EFT Integration Type"
{
    // NPR5.30/BR  /20170113  CASE 263458 Object Created
    // NPR5.46/MMV /20180720 CASE 290734 EFT Framework refactored

    Caption = 'EFT Integration Type';
    DataClassification = CustomerContent;
    DrillDownPageID = "EFT Integration Types";
    LookupPageID = "EFT Integration Types";

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

