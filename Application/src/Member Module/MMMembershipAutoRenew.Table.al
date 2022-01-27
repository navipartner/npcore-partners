table 6060148 "NPR MM Membership Auto Renew"
{
    Access = Internal;

    Caption = 'Membership Auto Renew';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR MM Members. AutoRenew List";
    LookupPageID = "NPR MM Members. AutoRenew List";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Community Code"; Code[20])
        {
            Caption = 'Community Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Member Community";
        }
        field(15; "Membership Code"; Code[20])
        {
            Caption = 'Membership Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Membership Setup" WHERE("Community Code" = FIELD("Community Code"));
        }
        field(20; "Valid Until Date"; Date)
        {
            Caption = 'Valid Until Date';
            DataClassification = CustomerContent;
        }
        field(100; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;
        }
        field(105; "Payment Terms Code"; Code[10])
        {
            Caption = 'Payment Terms Code';
            DataClassification = CustomerContent;
            TableRelation = "Payment Terms";
        }
        field(106; "Due Date Calculation"; Option)
        {
            Caption = 'Due Date Calculation';
            DataClassification = CustomerContent;
            OptionCaption = 'Payment Terms,Membership Expire Date';
            OptionMembers = PAYMENT_TERMS,MEMBERSHIP_EXPIRE;
        }
        field(110; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "Payment Method";
        }
        field(115; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser";
        }
        field(120; "Post Invoice"; Boolean)
        {
            Caption = 'Post Invoice';
            DataClassification = CustomerContent;
        }
        field(125; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(126; "Posting Date Calculation"; Option)
        {
            Caption = 'Posting Date Calculation';
            DataClassification = CustomerContent;
            OptionCaption = 'Fixed,Membership Expire Date';
            OptionMembers = "FIXED",MEMBERSHIP_EXPIRE_DATE;
        }
        field(500; "Started At"; DateTime)
        {
            Caption = 'Started At';
            DataClassification = CustomerContent;
        }
        field(505; "Completed At"; DateTime)
        {
            Caption = 'Completed At';
            DataClassification = CustomerContent;
        }
        field(510; "Started By"; Text[50])
        {
            Caption = 'Started By';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(512; "Auto-Renew Success Count"; Integer)
        {
            Caption = 'Auto-Renew Success Count';
            DataClassification = CustomerContent;
        }
        field(515; "Selected Membership Count"; Integer)
        {
            Caption = 'Selected Membership Count';
            DataClassification = CustomerContent;
        }
        field(520; "Auto-Renew Fail Count"; Integer)
        {
            Caption = 'Auto-Renew Fail Count';
            DataClassification = CustomerContent;
        }
        field(525; "Invoice Create Fail Count"; Integer)
        {
            Caption = 'Invoice Create Fail Count';
            DataClassification = CustomerContent;
        }
        field(530; "Invoice Posting Fail Count"; Integer)
        {
            Caption = 'Invoice Posting Fail Count';
            DataClassification = CustomerContent;
        }
        field(550; "First Invoice No."; Code[20])
        {
            Caption = 'First Invoice No.';
            DataClassification = CustomerContent;
        }
        field(555; "Last Invoice No."; Code[20])
        {
            Caption = 'Last Invoice No.';
            DataClassification = CustomerContent;
        }
        field(560; "Keep Auto-Renew Entries"; Option)
        {
            Caption = 'Keep Auto-Renew Entries';
            DataClassification = CustomerContent;
            OptionCaption = 'No,Failed,All';
            OptionMembers = NO,FAILED,ALL;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

