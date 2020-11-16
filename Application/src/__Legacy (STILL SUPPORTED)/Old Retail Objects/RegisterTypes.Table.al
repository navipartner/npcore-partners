table 6014459 "NPR Register Types"
{
    // NPR5.30/TJ  /20170215 CASE 265504 Changed table ENU caption

    Caption = 'Cash Register Type';
    LookupPageID = "NPR Register Types";
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

