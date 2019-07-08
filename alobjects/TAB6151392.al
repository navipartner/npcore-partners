table 6151392 "CS Stock-Takes Data"
{
    // NPR5.50/CLVA/20190304  CASE 332844 Object created

    Caption = 'CS Stock-Takes Data';

    fields
    {
        field(1;"Stock-Take Id";Guid)
        {
            Caption = 'Stock-Take Id';
        }
        field(2;"Worksheet Name";Code[10])
        {
            Caption = 'Worksheet Name';
        }
        field(3;"Tag Id";Text[30])
        {
            Caption = 'Tag Id';
        }
        field(10;"Item No.";Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item."No.";

            trigger OnValidate()
            begin
                Validate("Variant Code",'');
                Validate("Item Group Code",'');
            end;
        }
        field(11;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE ("Item No."=FIELD("Item No."));
        }
        field(12;"Item Group Code";Code[10])
        {
            Caption = 'Item Group Code';
            TableRelation = "Item Group";
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
        field(15;"Item Group Description";Text[50])
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
        field(16;Created;DateTime)
        {
            Caption = 'Created';
        }
        field(17;"Created By";Code[20])
        {
            Caption = 'Created By';
        }
        field(20;Approved;DateTime)
        {
            Caption = 'Handled';
        }
        field(21;"Approved By";Code[10])
        {
            Caption = 'Approved By';
        }
        field(22;"Transferred To Worksheet";Boolean)
        {
            Caption = 'Transferred To Worksheet';
        }
        field(23;"Combined key";Code[30])
        {
            Caption = 'Combined key';
        }
        field(24;"Stock-Take Config Code";Code[10])
        {
            Caption = 'Stock-Take Config Code';
        }
    }

    keys
    {
        key(Key1;"Stock-Take Id","Worksheet Name","Tag Id")
        {
        }
        key(Key2;Created)
        {
        }
    }

    fieldgroups
    {
    }
}

