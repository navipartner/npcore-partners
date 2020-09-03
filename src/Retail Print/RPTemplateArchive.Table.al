table 6014559 "NPR RP Template Archive"
{
    Caption = 'Template Archive';
    LookupPageID = "NPR RP Template Archive List";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            TableRelation = "NPR RP Template Header".Code;
        }
        field(2; Version; Code[50])
        {
            Caption = 'Version';
        }
        field(3; "Archived at"; DateTime)
        {
            Caption = 'Archived at';
        }
        field(4; "Archived by"; Code[50])
        {
            Caption = 'Archived by';
        }
        field(5; "Version Comments"; Text[128])
        {
            Caption = 'Version Comments';
        }
        field(6; Template; BLOB)
        {
            Caption = 'Template';
        }
    }

    keys
    {
        key(Key1; "Code", Version)
        {
        }
        key(Key2; "Archived at")
        {
        }
    }

    fieldgroups
    {
    }
}

