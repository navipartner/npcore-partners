table 6014459 "NPR Register Types"
{
    Caption = 'Cash Register Type';
    LookupPageID = "NPR Register Types";
    DataClassification = CustomerContent;
    ObsoleteState = Pending;
    ObsoleteReason = 'This table won''t be used anymore';
    ObsoleteTag = 'NPR Register Types to NPR POS View Profile';

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

