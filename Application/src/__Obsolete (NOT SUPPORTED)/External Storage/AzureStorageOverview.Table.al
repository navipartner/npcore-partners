table 6184861 "NPR Azure Storage Overview"
{
    Access = Internal;
    Caption = 'Azure Storage Overview';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Not used';

    fields
    {
        field(1; "Account name"; Text[24])
        {
            Caption = 'Azure Account Name';
            DataClassification = CustomerContent;
        }
        field(10; "Container Name"; Text[63])
        {
            Caption = 'Container Name';
            DataClassification = CustomerContent;
        }
        field(20; "File Name"; Text[250])
        {
            Caption = 'File Name';
            DataClassification = CustomerContent;
        }
        field(30; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Account name", "Container Name", "File Name", Name)
        {
        }
    }

    fieldgroups
    {
    }
}

