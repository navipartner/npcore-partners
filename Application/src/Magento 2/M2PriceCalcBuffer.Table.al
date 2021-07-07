table 6151145 "NPR M2 Price Calc. Buffer"
{
    Caption = 'Sales Price Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = Item;
        }
        field(2; "Source Code"; Code[20])
        {
            Caption = 'Sales Code';
            DataClassification = CustomerContent;
        }
        field(3; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
        }
        field(4; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
            DataClassification = CustomerContent;
        }
        field(5; "Unit Price"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(6; "Line Discount %"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Line Discount %';
            DataClassification = CustomerContent;
            MaxValue = 100;
            MinValue = 0;
        }
        field(7; "Price Includes VAT"; Boolean)
        {
            Caption = 'Price Includes VAT';
            DataClassification = CustomerContent;
        }
        field(10; "Allow Invoice Disc."; Boolean)
        {
            Caption = 'Allow Invoice Disc.';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(11; "VAT Bus. Posting Gr. (Price)"; Code[20])
        {
            Caption = 'VAT Bus. Posting Gr. (Price)';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";
        }
        field(12; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Product Posting Group";
        }
        field(13; "Source Type"; Enum "NPR M2 Price Calc. Buffer Type")
        {
            Caption = 'Sales Type';
            DataClassification = CustomerContent;
        }
        field(14; "Minimum Quantity"; Decimal)
        {
            Caption = 'Minimum Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(15; "Ending Date"; Date)
        {
            Caption = 'Ending Date';
            DataClassification = CustomerContent;
        }
        field(100; "Total VAT %"; Decimal)
        {
            Caption = 'Total VAT %';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(110; "Request ID"; Text[40])
        {
            Caption = 'Request ID';
            DataClassification = CustomerContent;
        }
        field(120; Priority; Integer)
        {
            Caption = 'Priority';
            DataClassification = CustomerContent;
        }
        field(130; Age; Integer)
        {
            Caption = 'Age';
            DataClassification = CustomerContent;
        }
        field(140; "Unit Price Base"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Price Base';
            DataClassification = CustomerContent;
        }
        field(150; "Show Details"; Boolean)
        {
            Caption = 'Show Details';
            DataClassification = CustomerContent;
        }
        field(160; "Response Message"; Text[250])
        {
            Caption = 'Response Message';
            DataClassification = CustomerContent;
        }
        field(5400; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(5700; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(7001; "Allow Line Disc."; Boolean)
        {
            Caption = 'Allow Line Disc.';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(6151145; "Price End Date"; Date)
        {
            Caption = 'Price End Date';
            DataClassification = CustomerContent;
        }
        field(6151146; "Discount End Date"; Date)
        {
            Caption = 'Discount End Date';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Item No.", "Source Type", "Source Code", "Starting Date", "Currency Code", "Variant Code", "Unit of Measure Code", "Minimum Quantity", "Request ID")
        {
        }
        key(Key2; "Request ID", Priority, Age)
        {
        }
    }

}
