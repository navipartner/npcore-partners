table 6150642 "NPR POS Info Link Table"
{
    // NPR5.26/OSFI/20160810 CASE 246167 Object Created

    Caption = 'POS Info Link Table';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = CustomerContent;
        }
        field(2; "Primary Key"; Text[250])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(3; "POS Info Code"; Code[20])
        {
            Caption = 'POS Info Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Info";
        }
        field(10; "When to Use"; Option)
        {
            Caption = 'When to Use';
            DataClassification = CustomerContent;
            OptionCaption = 'Always,Negative,Positive';
            OptionMembers = Always,Negative,Positive;
        }
    }

    keys
    {
        key(Key1; "Table ID", "Primary Key", "POS Info Code")
        {
        }
    }

    fieldgroups
    {
    }
}

