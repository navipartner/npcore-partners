table 6151388 "CS Refill Data"
{
    // NPR5.50/CLVA/20190309  CASE 332844 Object created

    Caption = 'CS Refill Data';

    fields
    {
        field(1;"Item No.";Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item."No.";

            trigger OnValidate()
            begin
                Validate("Variant Code",'');
            end;
        }
        field(2;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE ("Item No."=FIELD("Item No."));
        }
        field(3;Location;Code[10])
        {
            Caption = 'Location';
            TableRelation = Location.Code;
        }
        field(4;"Stock-Take Id";Guid)
        {
            Caption = 'Stock-Take Id';
        }
        field(10;"Qty. in Stock";Integer)
        {
            Caption = 'Qty. in Stock';
        }
        field(11;"Qty. in Store";Integer)
        {
            Caption = 'Qty. in Store';
        }
        field(13;"Item Description";Text[50])
        {
            CalcFormula = Lookup(Item.Description WHERE ("No."=FIELD("Item No.")));
            Caption = 'Item Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14;"Variant Description";Text[50])
        {
            CalcFormula = Lookup("Item Variant".Description WHERE (Code=FIELD("Variant Code"),
                                                                   "Item No."=FIELD("Item No.")));
            Caption = 'Variant Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(15;"Item Group Code";Code[10])
        {
            Caption = 'Item Group Code';
            TableRelation = "Item Group";
        }
        field(16;"Item Group Description";Text[50])
        {
            CalcFormula = Lookup("Item Group".Description WHERE ("No."=FIELD("Item Group Code")));
            Caption = 'Item Group Description';
            Editable = false;
            FieldClass = FlowField;

            trigger OnValidate()
            var
                Item: Record Item;
            begin
            end;
        }
        field(17;"Combined key";Code[30])
        {
            Caption = 'Combined key';
        }
        field(18;"Image Url";Text[250])
        {
            Caption = 'Image Url';
        }
        field(19;Refilled;Boolean)
        {
            Caption = 'Refilled';
        }
        field(20;"Refilled By";Code[10])
        {
            Caption = 'Refilled By';
        }
        field(21;"Refilled Date";DateTime)
        {
            Caption = 'Refilled Date';
        }
    }

    keys
    {
        key(Key1;"Item No.","Variant Code",Location,"Stock-Take Id")
        {
        }
    }

    fieldgroups
    {
    }
}

