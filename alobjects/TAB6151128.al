table 6151128 "NpIa Item AddOn Line Option"
{
    // NPR5.48/MHA /20181109  CASE 334922 Object created - Option for Item AddOn Line Type Select
    // NPR5.52/ALPO/20190912  CASE 354309 Possibility to fix the quantity so user would not be able to change it on sale line
    //                                    Possibility to predefine unit price and line discount % for Item AddOn entries set as select options
    //                                    Set whether or not specified quantity is per unit of main item

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
                //-NPR5.52 [354309]-revoked
                //IF "Item No." <> '' THEN
                //  Item.GET("Item No.");
                //+NPR5.52 [354309]-revoked
                //-NPR5.52 [354309]
                if "Item No." = '' then begin
                  Init;
                  exit;
                end;
                Item.Get("Item No.");

                "Unit Price" := Item."Unit Price";
                //+NPR5.52 [354309]
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
                  ItemVariant.Get("Item No.","Variant Code")
                //-NPR5.52 [354309]
                else
                  Clear(ItemVariant);
                //+NPR5.52 [354309]

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

            trigger OnValidate()
            begin
                //-NPR5.52 [354309]
                if Quantity = 0 then
                  TestField("Fixed Quantity",false);
                //+NPR5.52 [354309]
            end;
        }
        field(40;"Fixed Quantity";Boolean)
        {
            Caption = 'Fixed Quantity';
            Description = 'NPR5.52';

            trigger OnValidate()
            begin
                //-NPR5.52 [354309]
                if "Fixed Quantity" then
                  TestField(Quantity);
                //+NPR5.52 [354309]
            end;
        }
        field(50;"Unit Price";Decimal)
        {
            AutoFormatType = 2;
            BlankZero = true;
            Caption = 'Unit Price';
            Description = 'NPR5.52';
        }
        field(60;"Discount %";Decimal)
        {
            BlankZero = true;
            Caption = 'Discount %';
            DecimalPlaces = 0:1;
            Description = 'NPR5.52';
            MaxValue = 100;
            MinValue = 0;
        }
        field(70;"Per Unit";Boolean)
        {
            Caption = 'Per unit';
            Description = 'NPR5.52';
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

