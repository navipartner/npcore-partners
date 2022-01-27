table 6151387 "NPR CS Devices"
{
    Access = Internal;

    Caption = 'CS Devices';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Object moved to NP Warehouse App.';


    fields
    {
        field(1; "Device Id"; Code[10])
        {
            Caption = 'Device Id';
            DataClassification = CustomerContent;
        }
        field(10; Created; DateTime)
        {
            Caption = 'Created';
            DataClassification = CustomerContent;
        }
        field(11; Heartbeat; DateTime)
        {
            Caption = 'Heartbeat';
            DataClassification = CustomerContent;
        }
        field(12; "Last Download Timestamp"; BigInteger)
        {
            Caption = 'Last Download Timestamp';
            DataClassification = CustomerContent;
        }
        field(13; "Current Download Timestamp"; BigInteger)
        {
            Caption = 'Current Download Timestamp';
            DataClassification = CustomerContent;
        }
        field(14; "Current Tag Count"; Integer)
        {
            Caption = 'Current Tag Count';
            DataClassification = CustomerContent;
        }
        field(15; "Refresh Item Catalog"; Boolean)
        {
            Caption = 'Refresh Item Catalog';
            DataClassification = CustomerContent;
        }
        field(16; Location; Code[20])
        {
            Caption = 'Location';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Device Id")
        {
        }
    }

    fieldgroups
    {
    }


}

