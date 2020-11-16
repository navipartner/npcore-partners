table 6151388 "NPR CS Refill Data"
{
    // NPR5.50/CLVA/20190309  CASE 332844 Object created
    // NPR5.52/CLVA/20190916 CASE 368484 Added page lookup
    // NPR5.54/CLVA/20200310 CASE 384506 Changed "Item Description" and "Variant Description" to FieldClass Normal

    Caption = 'CS Refill Data';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR CS Refill Data";
    LookupPageID = "NPR CS Refill Data";

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item."No.";

            trigger OnValidate()
            begin
                Validate("Variant Code", '');
            end;
        }
        field(2; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(3; Location; Code[10])
        {
            Caption = 'Location';
            DataClassification = CustomerContent;
            TableRelation = Location.Code;
        }
        field(4; "Stock-Take Id"; Guid)
        {
            Caption = 'Stock-Take Id';
            DataClassification = CustomerContent;
        }
        field(10; "Qty. in Stock"; Integer)
        {
            Caption = 'Qty. in Stock';
            DataClassification = CustomerContent;
        }
        field(11; "Qty. in Store"; Integer)
        {
            Caption = 'Qty. in Store';
            DataClassification = CustomerContent;
        }
        field(13; "Item Description"; Text[50])
        {
            Caption = 'Item Description';
            DataClassification = CustomerContent;
            Editable = false;
            FieldClass = Normal;
        }
        field(14; "Variant Description"; Text[50])
        {
            Caption = 'Variant Description';
            DataClassification = CustomerContent;
            Editable = false;
            FieldClass = Normal;
        }
        field(15; "Item Group Code"; Code[10])
        {
            Caption = 'Item Group Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Item Group";
        }
        field(16; "Item Group Description"; Text[50])
        {
            CalcFormula = Lookup ("NPR Item Group".Description WHERE("No." = FIELD("Item Group Code")));
            Caption = 'Item Group Description';
            Editable = false;
            FieldClass = FlowField;

            trigger OnValidate()
            var
                Item: Record Item;
            begin
            end;
        }
        field(17; "Combined key"; Code[30])
        {
            Caption = 'Combined key';
            DataClassification = CustomerContent;
        }
        field(18; "Image Url"; Text[250])
        {
            Caption = 'Image Url';
            DataClassification = CustomerContent;
        }
        field(19; Refilled; Boolean)
        {
            Caption = 'Refilled';
            DataClassification = CustomerContent;
        }
        field(20; "Refilled By"; Code[10])
        {
            Caption = 'Refilled By';
            DataClassification = CustomerContent;
        }
        field(21; "Refilled Date"; DateTime)
        {
            Caption = 'Refilled Date';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Item No.", "Variant Code", Location, "Stock-Take Id")
        {
        }
    }

    fieldgroups
    {
    }
}

