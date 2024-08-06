table 6150910 "NPR Entry Denomination"
{
    Access = Public;
    Caption = 'Entry Denomination';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(10; "Denomination Type"; Enum "NPR Denomination Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(11; Denomination; Decimal)
        {
            Caption = 'Denomination';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(12; "Denomination Variant ID"; Code[20])
        {
            Caption = 'Denomination Variant ID';
            DataClassification = CustomerContent;
        }
        field(20; "POS Payment Method Code"; Code[10])
        {
            Caption = 'POS Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method".Code;
        }
        field(30; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency.Code;
        }
        field(40; Quantity; Integer)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Amount := Quantity * Denomination;
            end;
        }
        field(50; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;

            trigger OnValidate()
            begin
                TestField(Denomination);
                Validate(Quantity, Round(Amount / Denomination, 1, '<'));
            end;
        }
    }

    keys
    {
        key(PK; "Denomination Type", Denomination, "Denomination Variant ID")
        {
            Clustered = true;
        }
    }
}