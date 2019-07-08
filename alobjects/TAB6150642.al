table 6150642 "POS Info Link Table"
{
    // NPR5.26/OSFI/20160810 CASE 246167 Object Created

    Caption = 'POS Info Link Table';

    fields
    {
        field(1;"Table ID";Integer)
        {
            Caption = 'Table ID';
        }
        field(2;"Primary Key";Text[250])
        {
            Caption = 'Primary Key';
        }
        field(3;"POS Info Code";Code[20])
        {
            Caption = 'POS Info Code';
            TableRelation = "POS Info";
        }
        field(10;"When to Use";Option)
        {
            Caption = 'When to Use';
            OptionCaption = 'Always,Negative,Positive';
            OptionMembers = Always,Negative,Positive;
        }
    }

    keys
    {
        key(Key1;"Table ID","Primary Key","POS Info Code")
        {
        }
    }

    fieldgroups
    {
    }
}

