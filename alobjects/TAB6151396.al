table 6151396 "CS Phys. Inventory Handling"
{
    // NPR5.51/CLVA/20190812  CASE 362173 Object created

    Caption = 'CS Phys. Inventory Handling';
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
        field(12; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            DataClassification = CustomerContent;
            TableRelation = "Item Journal Batch".Name WHERE("Journal Template Name" = FIELD("Journal Template Name"));
        }
        field(13; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            DataClassification = CustomerContent;
            TableRelation = "Item Journal Template";
        }
        field(14; "Shelf  No."; Code[10])
        {
            Caption = 'Shelf  No.';
            DataClassification = CustomerContent;
        }
        field(15; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item."No.";

            trigger OnValidate()
            begin
                Validate("Variant Code", '');
            end;
        }
        field(16; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(17; "Item Description"; Text[50])
        {
            CalcFormula = Lookup (Item.Description WHERE("No." = FIELD("Item No.")));
            Caption = 'Item Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(18; "Variant Description"; Text[50])
        {
            CalcFormula = Lookup ("Item Variant".Description WHERE(Code = FIELD("Variant Code"),
                                                                   "Item No." = FIELD("Item No.")));
            Caption = 'Variant Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(19; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;

            trigger OnValidate()
            begin
                // IF "Location Code" <> xRec."Location Code" THEN BEGIN
                //  "Bin Code" := '';
                //  IF CurrFieldNo <> 0 THEN
                //    WMSManagement.CheckItemJnlLineFieldChange(Rec,xRec,FIELDCAPTION("Location Code"));
                //  IF ("Location Code" <> '') AND ("Item No." <> '') THEN BEGIN
                //    GetLocation("Location Code");
                //    IF Location."Bin Mandatory" AND NOT Location."Directed Put-away and Pick" THEN
                //      WMSManagement.GetDefaultBin("Item No.","Variant Code","Location Code","Bin Code");
                //  END;
                // END;
                //
                // VALIDATE("Unit of Measure Code");
            end;
        }
        field(20; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ProdOrderComp: Record "Prod. Order Component";
                WhseIntegrationMgt: Codeunit "Whse. Integration Management";
            begin
            end;
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
        field(105; "Transferred to Journal"; Boolean)
        {
            Caption = 'Transferred to Journal';
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
}

