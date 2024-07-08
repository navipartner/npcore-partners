table 6150861 "NPR Ticket Profile Upg Buff"
{
    DataClassification = CustomerContent;
    Caption = 'NPR Ticket Profile Upg Buff';
    Access = Internal;
    TableType = Temporary;

    fields
    {
        field(1; "Workflow Set Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }

        field(2; "POS Ticket Profile Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(3; "POS New Ticket Profile Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Workflow Set Code", "POS Ticket Profile Code")
        {
            Clustered = true;
        }
    }
}