table 6014567 "NPR RP Data Join Field Map"
{
    Access = Internal;
    Caption = 'RP Data Join Field Map';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Data Item Name"; Text[50])
        {
            Caption = 'Data Item Name';
            DataClassification = CustomerContent;
        }
        field(2; "Data Item Field No."; Integer)
        {
            Caption = 'Data Item Field No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Data Item Name", "Data Item Field No.")
        {
        }
    }

    fieldgroups
    {
    }
}

