table 6151246 "NP Retail Web Sales"
{

    fields
    {
        field(1; "Campaign Discount List"; Integer)
        {
            CalcFormula = Count ("Period Discount");
            FieldClass = FlowField;
        }
        field(2; "Mix Discount List"; Integer)
        {
            CalcFormula = Count ("Mixed Discount" WHERE("Mix Type" = FILTER(Standard | Combination)));
            FieldClass = FlowField;
        }
        field(3; "Voucher List"; Integer)
        {
            CalcFormula = Count ("NpRv Voucher");
            FieldClass = FlowField;
        }
        field(4; "Coupon List"; Integer)
        {
            CalcFormula = Count ("NpDc Coupon");
            FieldClass = FlowField;
        }
        field(5; No; Integer)
        {
            AutoIncrement = true;
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; No)
        {
        }
    }

    fieldgroups
    {
    }
}

