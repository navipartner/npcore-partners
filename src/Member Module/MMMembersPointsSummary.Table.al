table 6151164 "NPR MM Members. Points Summary"
{
    // MM1.45/TSA /20200629 CASE 411768 Initial Version

    Caption = 'MM Membership Points Summary';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Membership Entry No."; Integer)
        {
            Caption = 'Membership Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Relative Period"; Integer)
        {
            Caption = 'Relative Period';
            DataClassification = CustomerContent;
        }
        field(20; "Earn Period Start"; Date)
        {
            Caption = 'Earn Period Start';
            DataClassification = CustomerContent;
        }
        field(21; "Earn Period End"; Date)
        {
            Caption = 'Earn Period End';
            DataClassification = CustomerContent;
        }
        field(30; "Burn Period Start"; Date)
        {
            Caption = 'Burn Period Start';
            DataClassification = CustomerContent;
        }
        field(31; "Burn Period End"; Date)
        {
            Caption = 'Burn Period End';
            DataClassification = CustomerContent;
        }
        field(40; "Points Earned"; Integer)
        {
            Caption = 'Points Earned';
            DataClassification = CustomerContent;
        }
        field(41; "Points Redeemed"; Integer)
        {
            Caption = 'Points Redeemed';
            DataClassification = CustomerContent;
        }
        field(42; "Points Remaining"; Integer)
        {
            Caption = 'Points Remaining';
            DataClassification = CustomerContent;
        }
        field(43; "Points Expired"; Integer)
        {
            Caption = 'Points Expired';
            DataClassification = CustomerContent;
        }
        field(50; "Amount Earned (LCY)"; Decimal)
        {
            Caption = 'Amount Earned (LCY)';
            DataClassification = CustomerContent;
        }
        field(51; "Amount Redeemed (LCY)"; Decimal)
        {
            Caption = 'Amount Redeemed (LCY)';
            DataClassification = CustomerContent;
        }
        field(52; "Amount Remaining (LCY)"; Decimal)
        {
            Caption = 'Amount Remaining (LCY)';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Membership Entry No.", "Relative Period")
        {
        }
    }

    fieldgroups
    {
    }
}

