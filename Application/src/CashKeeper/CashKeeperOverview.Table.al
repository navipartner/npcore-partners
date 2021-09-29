table 6059947 "NPR CashKeeper Overview"
{
    Caption = 'CashKeeper Overview';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Transaction No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Transaction No.';
            DataClassification = CustomerContent;
        }
        field(11; "Register No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
        }
        field(12; "Total Amount"; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(13; "Value In Cents"; Integer)
        {
            Caption = 'Value In Cents';
            DataClassification = CustomerContent;
        }
        field(14; Salesperson; Code[20])
        {
            Caption = 'Salesperson';
            DataClassification = CustomerContent;
        }
        field(15; "User Id"; Code[10])
        {
            Caption = 'User Id';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(16; "Lookup Timestamp"; DateTime)
        {
            Caption = 'Lookup Timestamp';
            DataClassification = CustomerContent;
        }
        field(17; "CashKeeper IP"; Text[20])
        {
            Caption = 'CashKeeper IP';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Transaction No.")
        {
        }
    }
}