table 6014559 "NPR RP Template Archive"
{
    Access = Internal;
    Caption = 'Template Archive';
    LookupPageID = "NPR RP Template Archive List";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            TableRelation = "NPR RP Template Header".Code;
            DataClassification = CustomerContent;
        }
        field(2; Version; Code[50])
        {
            Caption = 'Version';
            DataClassification = CustomerContent;
        }
        field(3; "Archived at"; DateTime)
        {
            Caption = 'Archived at';
            DataClassification = CustomerContent;
        }
        field(4; "Archived by"; Code[50])
        {
            Caption = 'Archived by';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(5; "Version Comments"; Text[128])
        {
            Caption = 'Version Comments';
            DataClassification = CustomerContent;
        }
        field(6; Template; BLOB)
        {
            Caption = 'Template';
            DataClassification = CustomerContent;
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

