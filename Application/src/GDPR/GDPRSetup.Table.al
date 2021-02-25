table 6151120 "NPR GDPR Setup"
{
    // MM1.29/TSA /20180509 CASE 313795 Initial Version

    Caption = 'GDPR Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(10; "Agreement Nos."; Code[20])
        {
            Caption = 'Agreement Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }
}

