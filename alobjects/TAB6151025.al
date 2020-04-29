table 6151025 "NpRv Partner Relation"
{
    // NPR5.49/MHA /20190228  CASE 342811 Object created - Retail Voucher Partner used with Cross Company vouchers

    Caption = 'Retail Voucher Partner Relation';

    fields
    {
        field(1;"Partner Code";Code[20])
        {
            Caption = 'Partner Code';
            TableRelation = "NpRv Partner";
        }
        field(5;"Voucher Type";Code[20])
        {
            Caption = 'Voucher Type';
            TableRelation = "NpRv Voucher Type";
        }
        field(1000;"Partner Name";Text[50])
        {
            CalcFormula = Lookup("NpRv Partner".Name WHERE (Code=FIELD("Partner Code")));
            Caption = 'Partner Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Partner Code","Voucher Type")
        {
        }
    }

    fieldgroups
    {
    }
}

