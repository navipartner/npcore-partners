table 6151016 "NpRv Return Voucher Type"
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher

    Caption = 'Return Retail Voucher Type';

    fields
    {
        field(1;"Voucher Type";Code[20])
        {
            Caption = 'Voucher Type';
            NotBlank = true;
            TableRelation = "NpRv Voucher Type";
        }
        field(5;"Return Voucher Type";Code[20])
        {
            Caption = 'Return Voucher Type';
            TableRelation = "NpRv Voucher Type";
        }
        field(1000;"Return Voucher Description";Text[50])
        {
            CalcFormula = Lookup("NpRv Voucher Type".Description WHERE (Code=FIELD("Return Voucher Type")));
            Caption = 'Return Voucher Description';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Voucher Type")
        {
        }
    }

    fieldgroups
    {
    }
}

