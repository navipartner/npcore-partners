table 6014530 "NPR POS Customer Location"
{
    Access = Internal;
    Caption = 'POS Customer Location';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Restaurant module is used instead.';

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
    }

    fieldgroups
    {
    }
}

