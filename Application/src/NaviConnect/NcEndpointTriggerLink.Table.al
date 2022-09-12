table 6151532 "NPR Nc Endpoint Trigger Link"
{
    Access = Internal;
    Caption = 'Nc Endpoint Trigger Link';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Nc Endpoint Trigger Links";
    LookupPageID = "NPR Nc Endpoint Trigger Links";
    ObsoleteState = Pending;
    ObsoleteReason = 'Task Queue module is about to be removed from NpCore so NC Collector is also going to be removed.';
    ObsoleteTag = 'BC 20 - Task Queue deprecating starting from 28/06/2022';

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
            TableRelation = "NPR Nc Trigger";
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

