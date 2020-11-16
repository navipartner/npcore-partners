table 6151392 "NPR CS Stock-Takes Data"
{
    // NPR5.50/CLVA/20190304  CASE 332844 Object created
    // NPR5.52/CLVA/20190909  CASE 364063 Added field Area

    Caption = 'CS Stock-Takes Data';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR CS Stock-Takes Data List";
    LookupPageID = "NPR CS Stock-Takes Data List";

    fields
    {
        field(1; "Stock-Take Id"; Guid)
        {
            Caption = 'Stock-Take Id';
            DataClassification = CustomerContent;
        }
        field(2; "Worksheet Name"; Code[10])
        {
            Caption = 'Worksheet Name';
            DataClassification = CustomerContent;
        }
        field(3; "Tag Id"; Text[30])
        {
            Caption = 'Tag Id';
            DataClassification = CustomerContent;
        }
        field(10; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item."No.";

            trigger OnValidate()
            begin
                Validate("Variant Code", '');
                Validate("Item Group Code", '');
            end;
        }
        field(11; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(12; "Item Group Code"; Code[10])
        {
            Caption = 'Item Group Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Item Group";
        }
        field(13; "Item Description"; Text[50])
        {
            CalcFormula = Lookup (Item.Description WHERE("No." = FIELD("Item No.")));
            Caption = 'Item Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14; "Variant Description"; Text[50])
        {
            CalcFormula = Lookup ("Item Variant".Description WHERE(Code = FIELD("Variant Code"),
                                                                   "Item No." = FIELD("Item No.")));
            Caption = 'Variant Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(15; "Item Group Description"; Text[50])
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
        field(16; Created; DateTime)
        {
            Caption = 'Created';
            DataClassification = CustomerContent;
        }
        field(17; "Created By"; Code[20])
        {
            Caption = 'Created By';
            DataClassification = CustomerContent;
        }
        field(20; Approved; DateTime)
        {
            Caption = 'Handled';
            DataClassification = CustomerContent;
        }
        field(21; "Approved By"; Code[10])
        {
            Caption = 'Approved By';
            DataClassification = CustomerContent;
        }
        field(22; "Transferred To Worksheet"; Boolean)
        {
            Caption = 'Transferred To Worksheet';
            DataClassification = CustomerContent;
        }
        field(23; "Combined key"; Code[30])
        {
            Caption = 'Combined key';
            DataClassification = CustomerContent;
        }
        field(24; "Stock-Take Config Code"; Code[10])
        {
            Caption = 'Stock-Take Config Code';
            DataClassification = CustomerContent;
        }
        field(25; "Area"; Option)
        {
            Caption = 'Area';
            DataClassification = CustomerContent;
            OptionCaption = 'Warehouse,Salesfloor,Stockroom';
            OptionMembers = Warehouse,Salesfloor,Stockroom;
        }
    }

    keys
    {
        key(Key1; "Stock-Take Id", "Worksheet Name", "Tag Id")
        {
        }
        key(Key2; Created)
        {
        }
    }

    fieldgroups
    {
    }
}

