table 6059862 "NPR NpRv ExtVoucherItem Buffer"
{
    Access = Internal;
    Caption = 'NpRv ExtVoucherItem Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            DataClassification = CustomerContent;
        }
        field(10; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(20; "Voucher Reference No."; Text[50])
        {
            Caption = 'Voucher Reference No.';
            DataClassification = CustomerContent;
        }
        field(30; "Item Amount"; Decimal)
        {
            Caption = 'Item Amount';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
        }
    }
}
