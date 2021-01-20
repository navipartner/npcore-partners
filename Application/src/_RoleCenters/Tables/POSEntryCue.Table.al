table 6151247 "NPR POS Entry Cue."
{
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(2; "Failed G/L Posting Trans."; Integer)
        {
            CalcFormula = Count("NPR POS Entry" WHERE("Post Item Entry Status" = FILTER("Error while Posting")));
            FieldClass = FlowField;
        }
        field(3; "Unposted Item Trans."; Integer)
        {
            CalcFormula = Count("NPR POS Entry" WHERE("Post Item Entry Status" = FILTER(Unposted),
             "Entry Type" = FILTER('Direct Sale' | 'Other' | 'Credit Sale')));
            FieldClass = FlowField;
        }
        field(4; "Unposted G/L Trans."; Integer)
        {
            CalcFormula = Count("NPR POS Entry" WHERE("Post Entry Status" = FILTER(Unposted)
            , "Entry Type" = FILTER('Direct Sale' | 'Other' | 'Credit Sale')));
            FieldClass = FlowField;
        }
        field(5; "Failed Item Transaction."; Integer)
        {
            CalcFormula = Count("NPR POS Entry" WHERE("Post Item Entry Status" = FILTER("Error while Posting")));
            FieldClass = FlowField;
        }
        field(6; "POS Entry List"; Integer)
        {
            CalcFormula = count("NPR POS Entry");
            FieldClass = FlowField;
        }
        field(7; "Campaign Discount List"; Integer)
        {
            CalcFormula = Count("NPR Period Discount");
            FieldClass = FlowField;
        }
        field(8; "Mix Discount List"; Integer)
        {
            CalcFormula = Count("NPR Mixed Discount" WHERE("Mix Type" = FILTER(Standard | Combination)));
            FieldClass = FlowField;
        }
        field(9; "Voucher List"; Integer)
        {
            CalcFormula = Count("NPR NpRv Voucher");
            FieldClass = FlowField;
        }
        field(10; "Coupon List"; Integer)
        {
            CalcFormula = Count("NPR NpDc Coupon");
            FieldClass = FlowField;
        }
    }
    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }
}

