table 6014473 "NPR Store Group"
{
    // NPR4.16/TJ/20151115 CASE 222281 Table Created

    Caption = 'Store Group';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Blank Location"; Boolean)
        {
            Caption = 'Blank Location';
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

