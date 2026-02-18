#if not (BC17 or BC18 or BC19 or BC20 or BC21)
table 6248184 "NPR Digital Doc. Header Buffer"
{
    Access = Internal;
    Caption = 'Digital Document Header Buffer';
    TableType = Temporary;
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "External Order No."; Code[20])
        {
            Caption = 'External Order No.';
            DataClassification = SystemMetadata;
        }
        field(10; "Document Type"; Enum "NPR Digital Document Type")
        {
            Caption = 'Document Type';
            DataClassification = SystemMetadata;
        }
        field(20; "Posted Document No."; Code[20])
        {
            Caption = 'Posted Document No.';
            DataClassification = SystemMetadata;
        }
        field(25; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = SystemMetadata;
            TableRelation = Customer;
        }
        field(30; "Recipient E-mail"; Text[80])
        {
            Caption = 'Recipient E-mail';
            DataClassification = SystemMetadata;
        }
        field(40; "Recipient Name"; Text[100])
        {
            Caption = 'Recipient Name';
            DataClassification = SystemMetadata;
        }
        field(50; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            DataClassification = SystemMetadata;
            TableRelation = Language;
        }
        field(60; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = SystemMetadata;
        }
        field(70; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = SystemMetadata;
            TableRelation = Currency;
        }
        field(80; "Total Amount Excl. VAT"; Decimal)
        {
            Caption = 'Total Amount Excl. VAT';
            DataClassification = SystemMetadata;
            AutoFormatType = 1;
        }
        field(90; "Total Amount Incl. VAT"; Decimal)
        {
            Caption = 'Total Amount Incl. VAT';
            DataClassification = SystemMetadata;
            AutoFormatType = 1;
        }
        field(100; "Invoice Discount Amount"; Decimal)
        {
            Caption = 'Invoice Discount Amount';
            DataClassification = SystemMetadata;
            AutoFormatType = 1;
        }
    }

    keys
    {
        key(PK; "External Order No.")
        {
            Clustered = true;
        }
    }
}
#endif
