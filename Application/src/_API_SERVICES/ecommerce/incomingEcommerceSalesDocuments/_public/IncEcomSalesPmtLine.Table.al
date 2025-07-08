table 6151159 "NPR Inc Ecom Sales Pmt. Line"
{
    DataClassification = CustomerContent;
    Caption = 'Incoming Ecommerce Sales Line';
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    DrillDownPageId = "NPR Inc Ecom Sales Pmt Lines";
    LookupPageId = "NPR Inc Ecom Sales Pmt Lines";
#endif
    fields
    {
        field(10; "External Document No."; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'External Document No.';
        }
        field(20; "Document Type"; Enum "NPR Inc Ecom Sales Doc Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Document Type';
        }
        field(30; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
            BlankZero = true;
        }
        field(40; "External Paymment Type"; Text[50])
        {
            Caption = 'External Payment Type';
            DataClassification = CustomerContent;
        }
        field(41; "Payment Method Type"; enum "NPR Inc Ecom Pmt Method Type")
        {
            Caption = 'Payment Method Type';
            DataClassification = CustomerContent;
            InitValue = "Payment Method";
        }
        field(50; "External Payment Method Code"; Text[50])
        {
            Caption = 'External Payment Method Code';
            DataClassification = CustomerContent;
        }
        field(51; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(60; "Payment Reference"; Text[250])
        {
            Caption = 'Payment Reference';
            DataClassification = CustomerContent;
        }
        field(70; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
            BlankZero = true;
        }
        field(71; "Captured Amount"; Decimal)
        {
            Caption = 'Captured Amount';
            DataClassification = CustomerContent;
            BlankZero = true;
        }
        field(72; "Invoiced Amount"; Decimal)
        {
            Caption = 'Invoiced Amount';
            DataClassification = CustomerContent;
            BlankZero = true;
        }
        field(80; "PAR Token"; Text[50])
        {
            Caption = 'PAR Token';
            DataClassification = CustomerContent;
        }
        field(90; "PSP Token"; Text[64])
        {
            Caption = 'PSP Token';
            DataClassification = CustomerContent;
        }
        field(100; "Card Expiry Date"; Text[50])
        {
            Caption = 'Card Expiry Date';
            DataClassification = CustomerContent;
        }
        field(110; "Card Brand"; Text[30])
        {
            Caption = 'Card Brand';
            DataClassification = CustomerContent;
        }
        field(120; "Masked Card Number"; Text[30])
        {
            Caption = 'Masked Card Number';
            DataClassification = CustomerContent;
        }
        field(130; "Card Alias Token"; Text[80])
        {
            Caption = 'Card Alias Token';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "External Document No.", "Document Type", "Line No.")
        {
            Clustered = true;
        }
    }
}