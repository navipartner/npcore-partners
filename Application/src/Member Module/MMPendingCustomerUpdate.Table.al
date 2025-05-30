table 6151064 "NPR MM Pending Customer Update"
{
    Access = Internal;
    Caption = 'Pending Customer Update';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(5; MembershipEntryNo; Integer)
        {
            Caption = 'Membership Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Membership";
        }
        field(10; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(20; "Customer Config. Template Code"; Text[10])
        {
            Caption = 'Customer Config. Template Code';
            DataClassification = CustomerContent;
            TableRelation = "Config. Template Header" WHERE("Table ID" = CONST(18));
        }
        field(25; MembershipCode; Code[20])
        {
            Caption = 'Membership Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Membership Setup";
        }
        field(30; "Valid From Date"; Date)
        {
            Caption = 'Valid From Date';
            DataClassification = CustomerContent;
        }
        field(40; "Update Processed"; Boolean)
        {
            Caption = 'Update Processed';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Valid From Date")
        {
        }
        key(Key3; "Customer No.")
        {
        }

        key(Key4; MembershipEntryNo)
        {
        }
    }
}

