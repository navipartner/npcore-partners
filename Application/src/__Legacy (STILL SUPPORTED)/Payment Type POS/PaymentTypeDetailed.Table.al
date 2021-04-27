table 6014437 "NPR Payment Type - Detailed"
{
    Caption = 'Payment Type - Detailed';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;

    fields
    {
        field(1; "Payment No."; Code[10])
        {
            Caption = 'Payment Type';
            TableRelation = "NPR POS Payment Method".Code;
            DataClassification = CustomerContent;
        }
        field(2; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            TableRelation = IF ("Payment No." = CONST('<>''')) "NPR POS Unit"."No.";
            DataClassification = CustomerContent;
        }
        field(3; Weight; Decimal)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(4; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Quantity := Amount / Weight;
            end;
        }
        field(5; Quantity; Integer)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Amount := Quantity * Weight;
            end;
        }
    }

    keys
    {
        key(Key1; "Payment No.", "Register No.", Weight)
        {
            SumIndexFields = Amount;
        }
    }

    fieldgroups
    {
    }
}

