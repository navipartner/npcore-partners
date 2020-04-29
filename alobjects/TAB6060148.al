table 6060148 "MM Membership Auto Renew"
{
    // MM1.22/TSA /20170829 CASE 286922 Initial Version
    // MM1.25/TSA /20180108 CASE 301463 Added fields "Posting Date Calculation" and "Due Date Calculation"
    // #334163/JDH /20181109 CASE 334163 Added caption to field Salesperson Code
    // MM1.36/NPKNAV/20190125  CASE 343948 Transport MM1.36 - 25 January 2019

    Caption = 'Membership Auto Renew';
    DrillDownPageID = "MM Membership Auto Renew List";
    LookupPageID = "MM Membership Auto Renew List";

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(10;"Community Code";Code[20])
        {
            Caption = 'Community Code';
            TableRelation = "MM Member Community";
        }
        field(15;"Membership Code";Code[20])
        {
            Caption = 'Membership Code';
            TableRelation = "MM Membership Setup" WHERE ("Community Code"=FIELD("Community Code"));
        }
        field(20;"Valid Until Date";Date)
        {
            Caption = 'Valid Until Date';
        }
        field(100;"Document Date";Date)
        {
            Caption = 'Document Date';
        }
        field(105;"Payment Terms Code";Code[10])
        {
            Caption = 'Payment Terms Code';
            TableRelation = "Payment Terms";
        }
        field(106;"Due Date Calculation";Option)
        {
            Caption = 'Due Date Calculation';
            OptionCaption = 'Payment Terms,Membership Expire Date';
            OptionMembers = PAYMENT_TERMS,MEMBERSHIP_EXPIRE;
        }
        field(110;"Payment Method Code";Code[10])
        {
            Caption = 'Payment Method Code';
            TableRelation = "Payment Method";
        }
        field(115;"Salesperson Code";Code[10])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser";
        }
        field(120;"Post Invoice";Boolean)
        {
            Caption = 'Post Invoice';
        }
        field(125;"Posting Date";Date)
        {
            Caption = 'Posting Date';
        }
        field(126;"Posting Date Calculation";Option)
        {
            Caption = 'Posting Date Calculation';
            OptionCaption = 'Fixed,Membership Expire Date';
            OptionMembers = "FIXED",MEMBERSHIP_EXPIRE_DATE;
        }
        field(500;"Started At";DateTime)
        {
            Caption = 'Started At';
        }
        field(505;"Completed At";DateTime)
        {
            Caption = 'Completed At';
        }
        field(510;"Started By";Text[50])
        {
            Caption = 'Started By';
        }
        field(512;"Auto-Renew Success Count";Integer)
        {
            Caption = 'Auto-Renew Success Count';
        }
        field(515;"Selected Membership Count";Integer)
        {
            Caption = 'Selected Membership Count';
        }
        field(520;"Auto-Renew Fail Count";Integer)
        {
            Caption = 'Auto-Renew Fail Count';
        }
        field(525;"Invoice Create Fail Count";Integer)
        {
            Caption = 'Invoice Create Fail Count';
        }
        field(530;"Invoice Posting Fail Count";Integer)
        {
            Caption = 'Invoice Posting Fail Count';
        }
        field(550;"First Invoice No.";Code[20])
        {
            Caption = 'First Invoice No.';
        }
        field(555;"Last Invoice No.";Code[20])
        {
            Caption = 'Last Invoice No.';
        }
        field(560;"Keep Auto-Renew Entries";Option)
        {
            Caption = 'Keep Auto-Renew Entries';
            OptionCaption = 'No,Failed,All';
            OptionMembers = NO,FAILED,ALL;
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

