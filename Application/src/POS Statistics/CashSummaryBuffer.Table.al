table 6059847 "NPR Cash Summary Buffer"
{
    Access = Internal;
    Caption = 'Cash Summary Buffer';
    DataClassification = CustomerContent;
    Extensible = false;
    TableType = Temporary;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
        }
        field(3; "Payment Method Code"; Text[50])
        {
            Caption = 'Payment Method Code';
            DataClassification = CustomerContent;
        }
        field(10; Status; Text[50])
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(20; "Payment Bin No."; Code[10])
        {
            Caption = 'Payment Bin No.';
            DataClassification = CustomerContent;
        }
        field(30; "Transaction Amount"; Decimal)
        {
            Caption = 'Transaction Amount';
            DataClassification = CustomerContent;
        }
        field(40; "Transaction Amount (LCY)"; Decimal)
        {
            Caption = 'Transaction Amount (LCY)';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Payment Bin No.", "Payment Method Code")
        {
        }
    }
}