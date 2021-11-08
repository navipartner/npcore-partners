table 6151087 "NPR RIS Retail Inv. Buffer"
{
    Caption = 'Retail Inventory Buffer';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR RIS Retail Inv. Buffer";
    LookupPageID = "NPR RIS Retail Inv. Buffer";
    TableType = Temporary;

    fields
    {
        field(1; "Set Code"; Code[20])
        {
            Caption = 'Set Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR RIS Retail Inv. Set";
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; "Item Filter"; Code[20])
        {
            Caption = 'Item Filter';
            DataClassification = CustomerContent;
        }
        field(11; "Global Dimension 1 Filter"; Code[20])
        {
            CaptionClass = '1,3,1';
            Caption = 'Global Dimension 1 Filter';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
            DataClassification = CustomerContent;
        }
        field(12; "Global Dimension 2 Filter"; Code[20])
        {
            CaptionClass = '1,3,2';
            Caption = 'Global Dimension 2 Filter';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            DataClassification = CustomerContent;
        }
        field(13; "Drop Shipment Filter"; Boolean)
        {
            AccessByPermission = TableData "Drop Shpt. Post. Buffer" = R;
            Caption = 'Drop Shipment Filter';
            DataClassification = CustomerContent;
        }
        field(14; "Unit of Measure Filter"; Code[10])
        {
            Caption = 'Unit of Measure Filter';
            TableRelation = "Unit of Measure";
            DataClassification = CustomerContent;
        }
        field(15; "Variant Filter"; Code[10])
        {
            Caption = 'Variant Filter';
            DataClassification = CustomerContent;
        }
        field(16; "Lot No. Filter"; Code[50])
        {
            Caption = 'Lot No. Filter';
            DataClassification = CustomerContent;
        }
        field(17; "Serial No. Filter"; Code[50])
        {
            Caption = 'Serial No. Filter';
            DataClassification = CustomerContent;
        }
        field(18; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            DataClassification = CustomerContent;
        }
        field(20; "Location Filter"; Code[10])
        {
            Caption = 'Location Filter';
            DataClassification = CustomerContent;
        }
        field(100; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = Company;
        }
        field(105; Inventory; Decimal)
        {
            Caption = 'Inventory';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(106; "Phys. Inventory"; Decimal)
        {
            Caption = 'Physical Inventory';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(110; "Processing Error"; Boolean)
        {
            Caption = 'Processing Error';
            DataClassification = CustomerContent;
        }
        field(115; "Processing Error Message"; Text[250])
        {
            Caption = 'Processing Error Message';
            DataClassification = CustomerContent;
        }
        field(120; "Qty. on Sales Order"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Qty. on Sales Order';
            DecimalPlaces = 0 : 5;
        }
        field(121; "Qty. on Sales Return"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Qty. on Sales Return';
            DecimalPlaces = 0 : 5;
        }
        field(122; "Qty. on Purch. Order"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Qty. on Purch. Order';
            DecimalPlaces = 0 : 5;
        }
        field(123; "Qty. on Purch. Return"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Qty. on Purch. Return';
            DecimalPlaces = 0 : 5;
        }
    }

    keys
    {
        key(Key1; "Set Code", "Line No.")
        {
        }
    }
}
