table 6151247 "NP Retail POS Entry Cue."
{

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
        }
        field(2; "Failed G/L Posting Trans."; Integer)
        {
            CalcFormula = Count ("POS Entry" WHERE("Post Item Entry Status" = FILTER("Error while Posting")));
            FieldClass = FlowField;
        }


        field(3; "Unposted Item Trans."; Integer)
        {
            CalcFormula = Count ("POS Entry" WHERE("Post Item Entry Status" = FILTER(Unposted),
             "Entry Type" = FILTER('Direct Sale' | 'Other' | 'Credit Sale')));
            FieldClass = FlowField;
        }
        field(4; "Unposted G/L Trans."; Integer)
        {
            CalcFormula = Count ("POS Entry" WHERE("Post Entry Status" = FILTER(Unposted)
            , "Entry Type" = FILTER('Direct Sale' | 'Other' | 'Credit Sale')));
            FieldClass = FlowField;
        }



        field(5; "Failed Item Transaction."; Integer)
        {
            CalcFormula = Count ("POS Entry" WHERE("Post Item Entry Status" = FILTER("Error while Posting")));
            FieldClass = FlowField;
        }

        field(6; "POS Entry List"; Integer)
        {
            CalcFormula = count ("POS Entry");
            FieldClass = FlowField;

        }
        field(7; "Campaign Discount List"; Integer)
        {
            CalcFormula = Count ("Period Discount");
            FieldClass = FlowField;
        }
        field(8; "Mix Discount List"; Integer)
        {
            CalcFormula = Count ("Mixed Discount" WHERE("Mix Type" = FILTER(Standard | Combination)));
            FieldClass = FlowField;
        }
        field(9; "Voucher List"; Integer)
        {
            CalcFormula = Count ("NpRv Voucher");
            FieldClass = FlowField;
        }
        field(10; "Coupon List"; Integer)
        {
            CalcFormula = Count ("NpDc Coupon");
            FieldClass = FlowField;
        }

    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    fieldgroups
    {
    }
}

