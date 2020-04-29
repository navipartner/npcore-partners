table 6151163 "MM Loyalty Alter Membership"
{
    // MM1.40/TSA /20190731 CASE 361664 Initial Version

    Caption = 'Loyalty Alter Membership';

    fields
    {
        field(1;"Loyalty Code";Code[20])
        {
            Caption = 'Code';
            TableRelation = "MM Loyalty Setup";
        }
        field(2;"From Membership Code";Code[20])
        {
            Caption = 'From Membership Code';
            TableRelation = "MM Membership Setup";
        }
        field(3;"To Membership Code";Code[20])
        {
            Caption = 'To Membership Code';
            TableRelation = "MM Membership Setup";
        }
        field(5;"Change Direction";Option)
        {
            Caption = 'Change Direction';
            OptionCaption = 'Upgrade,Downgrade';
            OptionMembers = UPGRADE,DOWNGRADE;
        }
        field(10;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(20;Blocked;Boolean)
        {
            Caption = 'Blocked';
        }
        field(40;"Sales Item No.";Code[20])
        {
            Caption = 'Sales Item No.';
            TableRelation = "MM Membership Alteration Setup"."Sales Item No." WHERE ("Alteration Type"=CONST(UPGRADE),
                                                                                     "From Membership Code"=FIELD("From Membership Code"));

            trigger OnValidate()
            var
                MembershipAlterationSetup: Record "MM Membership Alteration Setup";
            begin

                if (MembershipAlterationSetup.Get (MembershipAlterationSetup."Alteration Type"::UPGRADE, "From Membership Code", "Sales Item No.")) then
                  Description := MembershipAlterationSetup.Description;
            end;
        }
        field(50;"Points Threshold";Integer)
        {
            Caption = 'Points Threshold';
            InitValue = 1;
            MinValue = 1;
        }
        field(55;"Defer Change Until";DateFormula)
        {
            Caption = 'Defer Change Until';
        }
    }

    keys
    {
        key(Key1;"Loyalty Code","From Membership Code","To Membership Code","Change Direction")
        {
        }
        key(Key2;"Loyalty Code","From Membership Code","Change Direction","Points Threshold")
        {
        }
    }

    fieldgroups
    {
    }
}

