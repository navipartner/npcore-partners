table 6014468 "NPR E-mail Setup"
{
    Caption = 'E-mail Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(50; "Mail Server"; Text[250])
        {
            Caption = 'Mail Server';
            Description = 'SMTP Server';
            DataClassification = CustomerContent;
        }
        field(52; "Mail Server Port"; Integer)
        {
            BlankZero = true;
            Caption = 'Mail Server Port';
            Description = 'PN1.09';
            InitValue = 25;
            MinValue = 0;
            DataClassification = CustomerContent;
        }
        field(55; Username; Text[100])
        {
            Caption = 'Username';
            Description = 'PN1.08';
            DataClassification = CustomerContent;
        }
        field(60; Password; Text[100])
        {
            Caption = 'Password';
            Description = 'PN1.08';
            DataClassification = CustomerContent;
        }
        field(65; "Enable Ssl"; Boolean)
        {
            Caption = 'Enable Ssl';
            Description = 'PN1.09';
            DataClassification = CustomerContent;
        }
        field(100; "From E-mail Address"; Text[80])
        {
            Caption = 'From E-mail Address';
            Description = 'Standard from e-mail address if none is defined on template';
            DataClassification = CustomerContent;
        }
        field(101; "From Name"; Text[80])
        {
            Caption = 'From Name';
            Description = 'Standard from name if none is defined on template';
            DataClassification = CustomerContent;
        }
        field(200; "NAS Folder"; Text[250])
        {
            Caption = 'NAS Folder';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    fieldgroups
    {
    }
}

