table 6151379 "NPR CS Wareh. Activ. Handling"
{
    
    Caption = 'CS Warehouse Activity Handling';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Object moved to NP Warehouse App.'; 


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
        field(20; "Activity Type"; Option)
        {
            Caption = 'Activity Type';
            DataClassification = CustomerContent;
            Editable = false;
            OptionCaption = ' ,Put-away,Pick,Movement,Invt. Put-away,Invt. Pick,Invt. Movement';
            OptionMembers = " ","Put-away",Pick,Movement,"Invt. Put-away","Invt. Pick","Invt. Movement";
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
        field(24; "Serial No."; Code[20])
        {
            Caption = 'Serial No.';
            DataClassification = CustomerContent;
            
        }
        field(25; "Lot No."; Code[20])
        {
            Caption = 'Lot No.';
            DataClassification = CustomerContent;
            
        }
        field(26; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            DataClassification = CustomerContent;
            
        }
        field(27; "Assignment Date"; Date)
        {
            Caption = 'Assignment Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item."No.";

            
        }
        field(51; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
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
       
       field(140; "Qty. in Stock"; Decimal)
        {
            Caption = 'Qty. in Stock';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.55';
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

