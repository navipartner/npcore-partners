table 6151532 "NPR Nc Endpoint Trigger Link"
{
    Caption = 'Nc Endpoint Trigger Link';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Nc Endpoint Trigger Links";
    LookupPageID = "NPR Nc Endpoint Trigger Links";

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

