table 6151163 "NPR MM Loyalty Alter Members."
{
    // MM1.40/TSA /20190731 CASE 361664 Initial Version

    Caption = 'Loyalty Alter Membership';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Loyalty Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Loyalty Setup";
        }
        field(2; "From Membership Code"; Code[20])
        {
            Caption = 'From Membership Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Membership Setup";
        }
        field(3; "To Membership Code"; Code[20])
        {
            Caption = 'To Membership Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Membership Setup";
        }
        field(5; "Change Direction"; Option)
        {
            Caption = 'Change Direction';
            DataClassification = CustomerContent;
            OptionCaption = 'Upgrade,Downgrade';
            OptionMembers = UPGRADE,DOWNGRADE;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
        field(40; "Sales Item No."; Code[20])
        {
            Caption = 'Sales Item No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Members. Alter. Setup"."Sales Item No." WHERE("Alteration Type" = CONST(UPGRADE),
                                                                                     "From Membership Code" = FIELD("From Membership Code"));

            trigger OnValidate()
            var
                MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
            begin

                if (MembershipAlterationSetup.Get(MembershipAlterationSetup."Alteration Type"::UPGRADE, "From Membership Code", "Sales Item No.")) then
                    Description := MembershipAlterationSetup.Description;
            end;
        }
        field(50; "Points Threshold"; Integer)
        {
            Caption = 'Points Threshold';
            DataClassification = CustomerContent;
            InitValue = 1;
            MinValue = 1;
        }
        field(55; "Defer Change Until"; DateFormula)
        {
            Caption = 'Defer Change Until';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Loyalty Code", "From Membership Code", "To Membership Code", "Change Direction")
        {
        }
        key(Key2; "Loyalty Code", "From Membership Code", "Change Direction", "Points Threshold")
        {
        }
    }

    fieldgroups
    {
    }
}

