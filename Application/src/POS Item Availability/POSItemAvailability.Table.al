table 6014636 "NPR POS Item Availability"
{
    Access = Internal;
    Caption = 'POS Item Availability';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
            DataClassification = CustomerContent;
        }
        field(2; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
            DataClassification = CustomerContent;
        }
        field(3; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
            DataClassification = CustomerContent;
        }
        field(10; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
        }
        field(11; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(12; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Available Inventory"; Decimal)
        {
            Caption = 'Available Inventory';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
        }
        field(21; "Available Inventory (Base)"; Decimal)
        {
            Caption = 'Available Inventory (Base)';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
        }
        field(30; "Available Inventory (Other)"; Decimal)
        {
            Caption = 'Available Inventory (Other)';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
        }
        field(40; "Avail. Inventory, Other (Base)"; Decimal)
        {
            Caption = 'Avail. Inventory, Other (Base)';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
        }
        field(50; "Gross Requirement"; Decimal)
        {
            Caption = 'Gross Requirement';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
        }
        field(60; "Gross Requirement (Base)"; Decimal)
        {
            Caption = 'Gross Requirement (Base)';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
        }
        field(70; "Current Quantity"; Decimal)
        {
            Caption = 'Current Line Quantity';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
        }
        field(80; "Current Quantity (Base)"; Decimal)
        {
            Caption = 'Current Line Quantity (Base)';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
        }
        field(1000; "Inventory Shortage"; Decimal)
        {
            Caption = 'Inventory Shortage';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
        }
        field(1010; "Inventory Shortage (Base)"; Decimal)
        {
            Caption = 'Inventory Shortage';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Item No.", "Variant Code", "Location Code")
        {
            Clustered = true;
        }
    }

    procedure CalcFromBaseQuantities()
    begin
        if "Qty. per Unit of Measure" = 0 then
            "Qty. per Unit of Measure" := 1;

        "Available Inventory" := Round("Available Inventory (Base)" / "Qty. per Unit of Measure", 0.00001);
        "Available Inventory (Other)" := Round("Avail. Inventory, Other (Base)" / "Qty. per Unit of Measure", 0.00001);
        "Current Quantity" := Round("Current Quantity (Base)" / "Qty. per Unit of Measure", 0.00001);
        "Gross Requirement" := Round("Gross Requirement (Base)" / "Qty. per Unit of Measure", 0.00001);
        "Inventory Shortage" := Round("Inventory Shortage (Base)" / "Qty. per Unit of Measure", 0.00001);
    end;
}