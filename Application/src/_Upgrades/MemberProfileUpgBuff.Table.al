table 6150854 "NPR Member Profile Upg Buff"
{
    DataClassification = CustomerContent;
    Caption = 'NPR Member Profile Upg Buff';
    Access = Internal;
    TableType = Temporary;

    fields
    {
        field(1; "Workflow Set Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }

        field(2; "POS Member Profile Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(3; "POS New Member Profile Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Workflow Set Code", "POS Member Profile Code")
        {
            Clustered = true;
        }
    }

}