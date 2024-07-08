table 6150860 "NPR Loyalty Profile Upg Buff"
{
    DataClassification = CustomerContent;
    Caption = 'NPR Loyalty Profile Upg Buff';
    Access = Internal;
    TableType = Temporary;

    fields
    {
        field(1; "Workflow Set Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }

        field(2; "POS Loyalty Profile Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(3; "POS New Loyalty Profile Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Workflow Set Code", "POS Loyalty Profile Code")
        {
            Clustered = true;
        }
    }
}