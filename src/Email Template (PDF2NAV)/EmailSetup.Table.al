table 6014468 "NPR E-mail Setup"
{
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //   - Refactored module from the "Mail And Document Handler" Module.
    //   - This Table contains the Setups for PDF2NAV.
    // PN1.08/MHA/20151214  CASE 228859 Added field 55 "Username" and 60 "Password"
    // PN1.09/MHA/20160115  CASE 231503 Added field 52 "Mail Server Port" and 65 "Enable Ssl"

    Caption = 'E-mail Setup';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(50; "Mail Server"; Text[250])
        {
            Caption = 'Mail Server';
            Description = 'SMTP Server';
        }
        field(52; "Mail Server Port"; Integer)
        {
            BlankZero = true;
            Caption = 'Mail Server Port';
            Description = 'PN1.09';
            InitValue = 25;
            MinValue = 0;
        }
        field(55; Username; Text[100])
        {
            Caption = 'Username';
            Description = 'PN1.08';
        }
        field(60; Password; Text[100])
        {
            Caption = 'Password';
            Description = 'PN1.08';
        }
        field(65; "Enable Ssl"; Boolean)
        {
            Caption = 'Enable Ssl';
            Description = 'PN1.09';
        }
        field(100; "From E-mail Address"; Text[80])
        {
            Caption = 'From E-mail Address';
            Description = 'Standard from e-mail address if none is defined on template';
        }
        field(101; "From Name"; Text[80])
        {
            Caption = 'From Name';
            Description = 'Standard from name if none is defined on template';
        }
        field(200; "NAS Folder"; Text[250])
        {
            Caption = 'NAS Folder';
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

