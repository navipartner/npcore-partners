table 6151532 "NPR Nc Endpoint Trigger Link"
{
    Access = Internal;
    Caption = 'Nc Endpoint Trigger Link';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'NC Trigger module removed from NpCore. We switched to Job Queue instead of using Task Queue.';

    fields
    {
        field(20; "Endpoint Code"; Code[20])
        {
            Caption = 'Endpoint Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Nc Endpoint";
        }
        field(30; "Trigger Code"; Code[20])
        {
            Caption = 'Trigger Code';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Endpoint Code", "Trigger Code")
        {
        }
        key(Key2; "Trigger Code")
        {
        }
    }
}

