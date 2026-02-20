table 6151260 "NPR Ecom Sales Pmt. Line"
{
    DataClassification = CustomerContent;
    Caption = 'Ecommerce Sales Line';
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    DrillDownPageId = "NPR Ecom Sales Pmt Lines";
    LookupPageId = "NPR Ecom Sales Pmt Lines";
#endif
    fields
    {
        field(1; "Document Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
            Caption = 'Document Entry No.';
            BlankZero = true;
            TableRelation = "NPR Ecom Sales Header"."Entry No.";
        }
        field(10; "External Document No."; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'External Document No.';
        }
        field(20; "Document Type"; Enum "NPR Ecom Sales Doc Type")
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
        field(40; "External Payment Type"; Text[50])
        {
            Caption = 'External Payment Type';
            DataClassification = CustomerContent;
        }
        field(41; "Payment Method Type"; enum "NPR Ecom Pmt Method Type")
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
        field(140; "Processing Payment Amount"; Decimal)
        {
            Caption = 'Processing Payment Amount';
            FieldClass = FlowField;
            CalcFormula = sum("NPR Magento Payment Line".Amount where("NPR Inc Ecom Sales Pmt Line Id" = field(SystemId)));
            Editable = false;
        }
#if not BC17
        field(150; "Store Currency Code"; Code[10])
        {
            Caption = 'Store Currency Code';
            DataClassification = CustomerContent;
        }
        field(160; "Amount (Store Currency)"; Decimal)
        {
            Caption = 'Amount (Store Currency)';
            DataClassification = CustomerContent;
            AutoFormatExpression = "Store Currency Code";
            AutoFormatType = 1;
        }
        field(170; "External Payment Gateway"; Text[100])
        {
            Caption = 'External Payment Gateway';
            DataClassification = CustomerContent;
        }
        field(180; "Expires At"; DateTime)
        {
            Caption = 'Expires At';
            DataClassification = CustomerContent;
        }
        field(190; "Date Authorized"; Date)
        {
            Caption = 'Date Authorized';
            DataClassification = CustomerContent;
        }
        field(200; "Shopify ID"; Text[30])
        {
            Caption = 'Shopify ID';
            DataClassification = CustomerContent;
        }
#endif
        field(210; "Points Payment"; Boolean)
        {
            Caption = 'Points Payment';
            DataClassification = CustomerContent;
        }
    }


    keys
    {
        key(Key1; "Document Entry No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "External Document No.", "Document Type")
        {
        }
        key(Key3; "Document Entry No.", "Points Payment")
        {
        }
    }
}