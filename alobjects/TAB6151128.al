table 6151128 "NpIa Item AddOn Line Option"
{
    // NPR5.48/MHA /20181109  CASE 334922 Object created - Option for Item AddOn Line Type Select

    Caption = 'Item AddOn Line Option';

    fields
    {
        field(1;"AddOn No.";Code[20])
        {
            Caption = 'AddOn No.';
            NotBlank = true;
            TableRelation = "NpIa Item AddOn";
        }
        field(5;"AddOn Line No.";Integer)
        {
            Caption = 'AddOn Line No.';
        }
        field(10;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(15;"Item No.";Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                if "Item No." <> '' then
                  Item.Get("Item No.");

                Description := Item.Description;
                Validate("Variant Code");
            end;
        }
        field(20;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE ("Item No."=FIELD("Item No."));

            trigger OnValidate()
            var
                ItemVariant: Record "Item Variant";
            begin
                if "Variant Code" <> '' then
                  ItemVariant.Get("Item No.","Variant Code");

                "Description 2" := ItemVariant.Description;
            end;
        }
        field(25;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(30;"Description 2";Text[50])
        {
            Caption = 'Description 2';
        }
        field(35;Quantity;Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0:5;
            InitValue = 1;
        }
    }

    keys
    {
        key(Key1;"AddOn No.","AddOn Line No.","Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

