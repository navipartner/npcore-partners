#if not BC17
table 6151214 "NPR Spfy Transaction Buffer"
{
    Access = Internal;
    Caption = 'Spfy Transaction Buffer';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "Transaction ID"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Transaction ID';
        }
        field(10; Kind; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Kind';
        }
        field(20; "Presentment Currency Code"; Text[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Presentment Currency Code';
        }
        field(21; "Amount (PCY)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Amount (PCY)';
        }
        field(30; "Store Currency Code"; Text[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Store Currency Code';
        }
        field(31; "Amount (SCY)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Amount (SCY)';
        }
        field(100; "Transaction Json"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'Transaction Json';
        }
    }
    keys
    {
        key(PK; "Transaction ID")
        {
            Clustered = true;
        }
    }
}
#endif