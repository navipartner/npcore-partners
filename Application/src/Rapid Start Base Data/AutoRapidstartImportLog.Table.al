table 6014600 "NPR Auto Rapidstart Import Log"
{
    Access = Internal;
    Caption = 'Auto Rapidstart Import Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Package Name"; Code[20])
        {
            Caption = 'Package Name';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Package Name")
        {
            Clustered = true;
        }
    }

}
