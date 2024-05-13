table 6150853 "NPR Audit Profile Upgrade Buff"
{
    DataClassification = CustomerContent;
    Caption = 'Audit Profile Buffer';
    Access = Internal;
    TableType = Temporary;

    fields
    {
        field(1; "Workflow Set Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }

        field(2; "POS Audit Profile Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }

        field(3; "POS New Audit Profile Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Workflow Set Code", "POS Audit Profile Code")
        {
            Clustered = true;
        }
    }

}