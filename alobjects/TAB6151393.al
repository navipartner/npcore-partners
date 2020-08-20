table 6151393 "CS Warehouse Shipment Handling"
{
    // NPR5.41/NPKNAV/20180427  CASE 306407 Transport NPR5.41 - 27 April 2018
    // NPR5.43/CLVA/20180605 CASE 304872 Added user info OnInsert
    // NPR5.48/CLVA/20181109 CASE 335606 Added "Unit of Measure"
    // NPR5.50/JAKUBV/20190603  CASE 345567 Transport NPR5.50 - 3 June 2019
    // NPR5.51/CLVA/20190819 CASE 345567 Added field "Vendor Item No."

    Caption = 'CS Warehouse Shipment Handling';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Id; Code[10])
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(3; "Unit of Measure"; Code[10])
        {
            Caption = 'Unit of Measure';
            DataClassification = CustomerContent;
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(10; Barcode; Text[30])
        {
            Caption = 'Barcode';
            DataClassification = CustomerContent;
        }
        field(11; Qty; Decimal)
        {
            Caption = 'Qty';
            DataClassification = CustomerContent;
            InitValue = 1;
        }
        field(14; "Zone Code"; Code[10])
        {
            Caption = 'Zone Code';
            DataClassification = CustomerContent;
            TableRelation = Zone.Code WHERE("Location Code" = FIELD("Location Code"));
        }
        field(21; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(22; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = Location;
        }
        field(23; "Shelf No."; Code[10])
        {
            Caption = 'Shelf No.';
            DataClassification = CustomerContent;
        }
        field(26; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                BinCode: Code[20];
            begin
            end;

            trigger OnValidate()
            var
                BinContent: Record "Bin Content";
                BinType: Record "Bin Type";
                QtyAvail: Decimal;
                QtyOutstanding: Decimal;
                AvailableQty: Decimal;
                UOMCode: Code[10];
                NewBinCode: Code[20];
            begin
            end;
        }
        field(27; "Assignment Date"; Date)
        {
            Caption = 'Assignment Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(32; "Vendor Item No."; Text[20])
        {
            Caption = 'Vendor Item No.';
            DataClassification = CustomerContent;
        }
        field(50; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item."No.";

            trigger OnValidate()
            begin
                Validate("Variant Code", '');
            end;
        }
        field(51; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(52; "Item Description"; Text[50])
        {
            CalcFormula = Lookup (Item.Description WHERE("No." = FIELD("Item No.")));
            Caption = 'Item Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(53; "Variant Description"; Text[50])
        {
            CalcFormula = Lookup ("Item Variant".Description WHERE(Code = FIELD("Variant Code"),
                                                                   "Item No." = FIELD("Item No.")));
            Caption = 'Variant Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(54; "Source Doc. No."; Code[20])
        {
            Caption = 'Source Doc. No.';
            DataClassification = CustomerContent;
        }
        field(100; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
        }
        field(101; "Record Id"; RecordID)
        {
            Caption = 'Record Id';
            DataClassification = CustomerContent;
        }
        field(102; Handled; Boolean)
        {
            Caption = 'Handled';
            DataClassification = CustomerContent;
        }
        field(103; Created; DateTime)
        {
            Caption = 'Created';
            DataClassification = CustomerContent;
        }
        field(104; "Created By"; Code[20])
        {
            Caption = 'Created By';
            DataClassification = CustomerContent;
        }
        field(105; "Transferred to Document"; Boolean)
        {
            Caption = 'Transferred to Worksheet';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Id, "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        //-NPR5.43 [304872]
        Created := CurrentDateTime;
        "Created By" := UserId;
        //+NPR5.43 [304872]
    end;
}

