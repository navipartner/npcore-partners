table 6151117 "NPR Managed By App Job Queue"
{
    Caption = 'Monitored Job';
    Access = Internal;
    DataClassification = CustomerContent;

    fields
    {
        field(1; ID; Guid)
        {
            Caption = 'Job Queue ID';
            DataClassification = CustomerContent;
            TableRelation = "Job Queue Entry".ID;
        }
        field(10; "Managed by App"; Boolean)
        {
            Caption = 'Monitored Job';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }
}
