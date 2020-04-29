table 6151120 "GDPR Setup"
{
    // MM1.29/TSA /20180509 CASE 313795 Initial Version

    Caption = 'GDPR Setup';

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
        }
        field(10;"Agreement Nos.";Code[10])
        {
            Caption = 'Agreement Nos.';
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }
}

