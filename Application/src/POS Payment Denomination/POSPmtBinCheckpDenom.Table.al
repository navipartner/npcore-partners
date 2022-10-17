table 6059791 "NPR POS Pmt. Bin Checkp. Denom"
{
    Access = Internal;
    Caption = 'POS Pmt. Bin Checkp. Denomination';
    DataClassification = CustomerContent;
    LookupPageId = "NPR POS Pmt. Bin Checkp. Denom";
    DrillDownPageId = "NPR POS Pmt. Bin Checkp. Denom";

    fields
    {
        field(1; "POS Pmt. Bin Checkp. Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Bin Checkp."."Entry No.";
        }
        field(2; "Attached-to ID"; Enum "NPR Denomination Target")
        {
            Caption = 'Attached-to ID';
            DataClassification = CustomerContent;
        }
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
        field(20; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = Currency.Code;
        }
        field(30; Quantity; Integer)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Amount := Quantity * Denomination;
            end;
        }
        field(31; Amount; Decimal)
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
        key(PK; "POS Pmt. Bin Checkp. Entry No.", "Attached-to ID", "Denomination Type", Denomination, "Denomination Variant ID")
        {
            Clustered = true;
        }
    }
}