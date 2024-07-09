table 6014628 "NPR Lookup Cache Log"
{
    Access = Internal;
    Caption = 'Lookup Cache Log';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Not used';

    fields
    {
        field(1; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
        }
        field(2; "Last Change"; DateTime)
        {
            Caption = 'Last Change';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Table No.")
        {
        }
    }

    fieldgroups
    {
    }
}

