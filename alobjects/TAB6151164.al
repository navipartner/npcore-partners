table 6151164 "MM Membership Points Summary"
{
    // MM1.45/TSA /20200629 CASE 411768 Initial Version

    Caption = 'MM Membership Points Summary';

    fields
    {
        field(1;"Membership Entry No.";Integer)
        {
            Caption = 'Membership Entry No.';
        }
        field(2;"Relative Period";Integer)
        {
            Caption = 'Relative Period';
        }
        field(20;"Earn Period Start";Date)
        {
            Caption = 'Earn Period Start';
        }
        field(21;"Earn Period End";Date)
        {
            Caption = 'Earn Period End';
        }
        field(30;"Burn Period Start";Date)
        {
            Caption = 'Burn Period Start';
        }
        field(31;"Burn Period End";Date)
        {
            Caption = 'Burn Period End';
        }
        field(40;"Points Earned";Integer)
        {
            Caption = 'Points Earned';
        }
        field(41;"Points Redeemed";Integer)
        {
            Caption = 'Points Redeemed';
        }
        field(42;"Points Remaining";Integer)
        {
            Caption = 'Points Remaining';
        }
        field(43;"Points Expired";Integer)
        {
            Caption = 'Points Expired';
        }
        field(50;"Amount Earned (LCY)";Decimal)
        {
            Caption = 'Amount Earned (LCY)';
        }
        field(51;"Amount Redeemed (LCY)";Decimal)
        {
            Caption = 'Amount Redeemed (LCY)';
        }
        field(52;"Amount Remaining (LCY)";Decimal)
        {
            Caption = 'Amount Remaining (LCY)';
        }
    }

    keys
    {
        key(Key1;"Membership Entry No.","Relative Period")
        {
        }
    }

    fieldgroups
    {
    }
}

