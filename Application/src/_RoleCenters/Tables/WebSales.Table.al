table 6151246 "NPR Web Sales"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Campaign Discount List"; Integer)
        {
            CalcFormula = Count("NPR Period Discount");
            FieldClass = FlowField;
        }
        field(2; "Mix Discount List"; Integer)
        {
            CalcFormula = Count("NPR Mixed Discount" WHERE("Mix Type" = FILTER(Standard | Combination)));
            FieldClass = FlowField;
        }
        field(3; "Voucher List"; Integer)
        {
            CalcFormula = Count("NPR NpRv Voucher");
            FieldClass = FlowField;
        }
        field(4; "Coupon List"; Integer)
        {
            CalcFormula = Count("NPR NpDc Coupon");
            FieldClass = FlowField;
        }
        field(5; No; Integer)
        {
            AutoIncrement = true;
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; No)
        {
        }
    }
}

