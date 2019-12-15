table 6060080 "MCS Recommendations Setup"
{
    // NPR5.30/BR  /20170215  CASE 252646 Object Created

    Caption = 'MCS Recommendations Setup';

    fields
    {
        field(1;"Primary Key";Code[10])
        {
            Caption = 'Primary Key';
        }
        field(10;"Max. History Records per Call";Integer)
        {
            Caption = 'Max. History Records per Call';
            InitValue = 10000;
            MinValue = 500;
        }
        field(20;"Online Recommendations Model";Code[10])
        {
            Caption = 'Online Recommendations Model';
            TableRelation = "MCS Recommendations Model" WHERE (Enabled=CONST(true));
        }
        field(30;"Background Send POS Lines";Boolean)
        {
            Caption = 'Background Send POS Lines';
        }
        field(40;"Background Send Sales Lines";Boolean)
        {
            Caption = 'Background Send Sales Lines';
        }
        field(50;"Max. Rec. per Sales Document";Integer)
        {
            Caption = 'Max. Rec. per Sales Document';
            InitValue = 3;
            MinValue = 1;
        }
    }

    keys
    {
        key(Key1;"Primary Key")
        {
        }
    }

    fieldgroups
    {
    }
}

