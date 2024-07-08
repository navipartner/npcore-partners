table 6059848 "NPR Price Change History"
{
    Access = Internal;
    Caption = 'Price Change History';
    DataClassification = CustomerContent;
    LookupPageId = "NPR Price Change History";
    DrillDownPageId = "NPR Price Change History";

    fields
    {
        field(39; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            DataClassification = CustomerContent;
        }
        field(1; "Price List Code"; Code[20])
        {
            Caption = 'Price List Code';
            DataClassification = CustomerContent;
            TableRelation = "Price List Header";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(3; "Source Type"; Enum "Price Source Type")
        {
            Caption = 'Assign-to Type';
            DataClassification = CustomerContent;
        }
        field(4; "Source No."; Code[20])
        {
            Caption = 'Assign-to No. (custom)';
            DataClassification = CustomerContent;
        }
        field(5; "Parent Source No."; Code[20])
        {
            Caption = 'Assign-to Parent No. (custom)';
            DataClassification = CustomerContent;
        }
        field(6; "Source ID"; Guid)
        {
            Caption = 'Assign-to ID';
            DataClassification = CustomerContent;
        }
        field(7; "Asset Type"; Enum "Price Asset Type")
        {
            Caption = 'Product Type';
            DataClassification = CustomerContent;
            InitValue = Item;
        }
        field(8; "Asset No."; Code[20])
        {
            Caption = 'Product No. (custom)';
            DataClassification = CustomerContent;
        }
        field(9; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code (custom)';
            DataClassification = CustomerContent;
        }
        field(10; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
        }
        field(11; "Work Type Code"; Code[10])
        {
            Caption = 'Work Type Code';
            DataClassification = CustomerContent;
            TableRelation = "Work Type";
        }
        field(12; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
            DataClassification = CustomerContent;
        }
        field(13; "Ending Date"; Date)
        {
            Caption = 'Ending Date';
            DataClassification = CustomerContent;
        }
        field(14; "Minimum Quantity"; Decimal)
        {
            Caption = 'Minimum Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(15; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code (custom)';
            DataClassification = CustomerContent;
        }
        field(16; "Amount Type"; Enum "Price Amount Type")
        {
            Caption = 'Defines';
            DataClassification = CustomerContent;
        }
        field(17; "Unit Price"; Decimal)
        {
            DataClassification = CustomerContent;
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Price';
            MinValue = 0;
        }
        field(18; "Cost Factor"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Cost Factor';
        }
        field(19; "Unit Cost"; Decimal)
        {
            DataClassification = CustomerContent;
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Cost';
            MinValue = 0;
        }
        field(20; "Line Discount %"; Decimal)
        {
            DataClassification = CustomerContent;
            AutoFormatType = 2;
            Caption = 'Line Discount %';
            MaxValue = 100;
            MinValue = 0;
        }
        field(21; "Allow Line Disc."; Boolean)
        {
            Caption = 'Allow Line Disc.';
            DataClassification = CustomerContent;
        }
        field(22; "Allow Invoice Disc."; Boolean)
        {
            Caption = 'Allow Invoice Disc.';
            DataClassification = CustomerContent;
        }
        field(23; "Price Includes VAT"; Boolean)
        {
            Caption = 'Price Includes VAT';
            DataClassification = CustomerContent;
        }
        field(24; "VAT Bus. Posting Gr. (Price)"; Code[20])
        {
            Caption = 'VAT Bus. Posting Gr. (Price)';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";
        }
        field(25; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Product Posting Group";
        }
        field(26; "Asset ID"; Guid)
        {
            Caption = 'Asset ID';
            DataClassification = CustomerContent;
        }
        field(27; "Line Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Line Amount';
            MinValue = 0;
            Editable = false;
        }
        field(28; "Price Type"; Enum "Price Type")
        {
            Caption = 'Price Type';
            DataClassification = CustomerContent;
        }
        field(29; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(30; Status; Enum "Price Status")
        {
            Caption = 'Price Status';
            DataClassification = CustomerContent;
        }
        field(31; "Direct Unit Cost"; Decimal)
        {
            DataClassification = CustomerContent;
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Direct Unit Cost';
            MinValue = 0;
        }
        field(32; "Source Group"; Enum "Price Source Group")
        {
            Caption = 'Source Group';
            DataClassification = CustomerContent;
        }
        field(33; "Product No."; Code[20])
        {
            Caption = 'Product No.';
            DataClassification = CustomerContent;
        }
        field(34; "Assign-to No."; Code[20])
        {
            Caption = 'Assign-to No.';
            DataClassification = CustomerContent;
        }
        field(35; "Assign-to Parent No."; Code[20])
        {
            Caption = 'Assign-to Parent No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Source Type" = CONST("Job Task")) Job;
            ValidateTableRelation = false;
        }
        field(36; "Variant Code Lookup"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = IF ("Asset Type" = CONST(Item)) "Item Variant".Code WHERE("Item No." = FIELD("Asset No."));
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(37; "Unit of Measure Code Lookup"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
        }
        field(38; "Price Change Date"; DateTime)
        {
            Caption = 'Price Change Date';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
        }
        key(key1; "Product No.", "Unit of Measure Code", "Variant Code")
        {
        }
        key(key2; "Price Change Date")
        {
        }
    }
}