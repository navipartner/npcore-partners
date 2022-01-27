table 6014482 "NPR Report Usage Log Entry"
{
    Access = Internal;
    // NPR5.48/TJ  /20181108 CASE 324444 New object

    Caption = 'Report Usage Log Entry';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Not used anymore';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Database Name"; Text[250])
        {
            Caption = 'Database Name';
            DataClassification = CustomerContent;
        }
        field(20; "Tenant Id"; Text[250])
        {
            Caption = 'Tenant Id';
            DataClassification = CustomerContent;
        }
        field(30; "Company Name"; Text[250])
        {
            Caption = 'Company Name';
            DataClassification = CustomerContent;
        }
        field(40; "Report Id"; Integer)
        {
            Caption = 'Report Id';
            DataClassification = CustomerContent;
        }
        field(50; "User Id"; Text[250])
        {
            Caption = 'User Id';
            DataClassification = CustomerContent;
        }
        field(60; "Used on"; DateTime)
        {
            Caption = 'Used on';
            DataClassification = CustomerContent;
        }
        field(70; "Enabled/Disabled Entry"; Boolean)
        {
            Caption = 'Enabled/Disabled Entry';
            DataClassification = CustomerContent;
        }
        field(80; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

