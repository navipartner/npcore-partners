table 6151532 "NPR Nc Endpoint Trigger Link"
{
    Access = Internal;
    Caption = 'Nc Endpoint Trigger Link';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'NC Collector module removed from NpCore. We switched to Job Queue instead of using Task Queue.';
    ObsoleteTag = 'BC 21 - Task Queue deprecating starting from 28/06/2022';

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

