table 6184881 "NPR FTP Overview"
{
    Caption = 'FTP Overview';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;

    fields
    {
        field(1; "Host Code"; Code[10])
        {
            Caption = 'FTP Host Code';
            DataClassification = CustomerContent;
        }
        field(10; "File Name"; Text[250])
        {
            Caption = 'File Name';
            DataClassification = CustomerContent;
        }
        field(20; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Host Code", "File Name", Name)
        {
        }
    }

    fieldgroups
    {
    }
}

