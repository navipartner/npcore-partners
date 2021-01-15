table 6151016 "NPR NpRv Ret. Vouch. Type"
{
    Caption = 'Return Retail Voucher Type';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Voucher Type"; Code[20])
        {
            Caption = 'Voucher Type';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR NpRv Voucher Type";
        }
        field(5; "Return Voucher Type"; Code[20])
        {
            Caption = 'Return Voucher Type';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpRv Voucher Type";
        }
        field(1000; "Return Voucher Description"; Text[50])
        {
            CalcFormula = Lookup("NPR NpRv Voucher Type".Description WHERE(Code = FIELD("Return Voucher Type")));
            Caption = 'Return Voucher Description';
            Editable = false;
            FieldClass = FlowField;
        }
    }
    keys
    {
        key(Key1; "Voucher Type")
        {
        }
    }
}

