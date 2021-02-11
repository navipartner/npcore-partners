table 6184880 "NPR FTP Setup"
{
    Caption = 'FTP Setup';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(5; "FTP Host"; Text[250])
        {
            Caption = 'FTP Host URI';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; Timeout; Integer)
        {
            Caption = 'Timeout';
            DataClassification = CustomerContent;
            Description = 'Miliseconds';
        }
        field(30; User; Text[50])
        {
            Caption = 'User Name';
            DataClassification = CustomerContent;
        }
        field(40; "Service Password"; Guid)
        {
            Caption = 'Service Password';
            DataClassification = CustomerContent;
        }
        field(45; "Port Number"; Integer)
        {
            Caption = 'Port Number';
            DataClassification = CustomerContent;
            Description = 'NPR5.55 only needed for SSH, for all rest it can be included in the URI';
        }
        field(50; "Storage On Server"; Text[250])
        {
            Caption = 'Server files location';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }
}

