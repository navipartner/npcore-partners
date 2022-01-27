table 6151376 "NPR CS UI Function"
{
    Access = Internal;

    Caption = 'CS UI Function';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Object moved to NP Warehouse App.';


    fields
    {
        field(1; "UI Code"; Code[20])
        {
            Caption = 'UI Code';
            DataClassification = CustomerContent;
        }
        field(2; "Function Code"; Code[20])
        {
            Caption = 'Function Code';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "UI Code", "Function Code")
        {
        }
    }

    fieldgroups
    {
    }
}

