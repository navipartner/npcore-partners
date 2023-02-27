table 6059798 "NPR NpGp POS Payment Line"
{
    Access = Internal;
    Caption = 'Global Pos Payment Line';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpGp POS Sales Lines";
    LookupPageID = "NPR NpGp POS Sales Lines";

    fields
    {
        field(1; "POS Entry No."; BigInteger)
        {
            Caption = 'POS Entry No.';
            DataClassification = CustomerContent;
        }
        field(5; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(6; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; "POS Payment Method Code"; Code[10])
        {
            Caption = 'POS Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method";
        }
        field(14; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(33; "Payment Amount"; Decimal)
        {
            Caption = 'Payment Amount';
            DataClassification = CustomerContent;
        }
        field(39; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = Currency;
        }
        field(50; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "POS Entry No.", "Line No.")
        {
        }
    }
}