table 6014547 "NPR EOD Denomination"
{
    Caption = 'NPR EOD Denomination';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Payment Method Code"; Code[10])
        {
            Caption = 'POS Payment Method Code';
            TableRelation = "NPR POS Payment Method".Code;
            DataClassification = CustomerContent;
        }
        field(2; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            TableRelation = "NPR POS Unit"."No.";
            DataClassification = CustomerContent;
        }
        field(10; Denomination; Decimal)
        {
            Caption = 'Denomination';
            DataClassification = CustomerContent;
        }
        field(11; Quantity; Integer)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                Amount := Quantity * Denomination;
            end;
        }
        field(12; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                Quantity := Amount / Denomination;
            end;
        }
    }

    keys
    {
        key(Key1; "POS Payment Method Code", "POS Unit No.", Denomination)
        {
        }
    }

    fieldgroups
    {
    }
}


