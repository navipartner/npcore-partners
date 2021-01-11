table 6150907 "NPR POS HC Endpoint Setup"
{
    Caption = 'Endpoint Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(5; Active; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Credentials Type"; Option)
        {
            Caption = 'Credentials Type';
            DataClassification = CustomerContent;
            OptionCaption = 'System,Named';
            OptionMembers = SYSTEM,NAMED;
        }
        field(21; "User Domain"; Text[100])
        {
            Caption = 'User Domain';
            DataClassification = CustomerContent;
            Description = 'NPR5.45';
        }
        field(22; "User Account"; Text[100])
        {
            Caption = 'User Account';
            DataClassification = CustomerContent;
            Description = 'NPR5.45';
        }
        field(23; "User Password"; Text[100])
        {
            Caption = 'User Password';
            DataClassification = CustomerContent;
            Description = 'NPR5.45';
        }
        field(30; "Endpoint URI"; Text[200])
        {
            Caption = 'Endpoint URI';
            DataClassification = CustomerContent;
        }
        field(50; "Connection Timeout (ms)"; Integer)
        {
            Caption = 'Connection Timeout (ms)';
            DataClassification = CustomerContent;
            InitValue = 4000;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }
}

