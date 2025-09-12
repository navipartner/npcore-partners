#if not BC17
table 6151225 "NPR Spfy Trans. PSP Details"
{
    Caption = 'Shopify Transaction PSP Details';
    DataClassification = CustomerContent;
    LookupPageId = "NPR Spfy Trans. PSP Details";
    DrillDownPageId = "NPR Spfy Trans. PSP Details";

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(10; "Transaction PSP"; Enum "NPR Spfy Transaction PSP")
        {
            Caption = 'Transaction PSP';
            DataClassification = CustomerContent;
        }
        field(20; "Merchant Account"; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Merchant Account';
        }
        field(30; "Merchant Reference"; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Merchant Reference';
        }
        field(40; "Payment Method"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Payment Method';
        }
        field(50; "Card Summary"; Text[4])
        {
            DataClassification = CustomerContent;
            Caption = 'Card Summary';
        }
        field(60; "Expiry Date"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Expiry Date';
        }
        field(70; "PSP Reference"; Code[16])
        {
            DataClassification = CustomerContent;
            Caption = 'PSP Reference';
        }
        field(80; Amount; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Amount';
        }
        field(90; "Card Added Brand"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Card Added Brand';
        }
        field(100; "Card Function"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Card Function';
        }
        field(110; "Merchant Order Reference"; Text[40])
        {
            DataClassification = CustomerContent;
            Caption = 'Merchant Order Reference';
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key1; "Transaction PSP", "PSP Reference")
        {
        }
        key(Key2; "Transaction PSP", "Merchant Reference")
        {
        }
    }
}
#endif