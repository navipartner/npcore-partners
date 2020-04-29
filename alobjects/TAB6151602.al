table 6151602 "NpDc Issue On-Sale Setup Line"
{
    // NPR5.36/MHA /20170831  CASE 286812 Object created - Discount Coupon Issue Module

    Caption = 'Issue On-Sale Setup Line';

    fields
    {
        field(1;"Coupon Type";Code[20])
        {
            Caption = 'Coupon Type';
            TableRelation = "NpDc Coupon Type";
        }
        field(5;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(10;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Item,Item Group,Item Disc. Group';
            OptionMembers = Item,"Item Group","Item Disc. Group";
        }
        field(15;"No.";Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
            TableRelation = IF (Type=CONST(Item)) Item
                            ELSE IF (Type=CONST("Item Group")) "Item Group"
                            ELSE IF (Type=CONST("Item Disc. Group")) "Item Discount Group";

            trigger OnValidate()
            var
                Item: Record Item;
                ItemDiscountGroup: Record "Item Discount Group";
                ItemGroup: Record "Item Group";
            begin
                case Type of
                  Type::Item:
                    begin
                      Item.Get("No.");
                      Description := Item.Description;
                      "Unit Price" := Item."Unit Price";
                      "Profit %" := Item."Profit %";
                    end;
                  Type::"Item Group":
                    begin
                      ItemGroup.Get("No.");
                      Description := ItemGroup.Description;
                      "Unit Price" := 0;
                      "Profit %" := 0;
                    end;
                  Type::"Item Disc. Group":
                    begin
                      ItemDiscountGroup.Get("No.");
                      Description := ItemDiscountGroup.Description;
                      "Unit Price" := 0;
                      "Profit %" := 0;
                    end;
                end;
            end;
        }
        field(20;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = IF (Type=CONST(Item)) "Item Variant".Code WHERE ("Item No."=FIELD("No."));
        }
        field(50;"Lot Quantity";Decimal)
        {
            Caption = 'Lot Quantity';
            DecimalPlaces = 0:5;
        }
        field(100;Description;Text[50])
        {
            Caption = 'Item Description';
        }
        field(105;"Unit Price";Decimal)
        {
            BlankZero = true;
            Caption = 'Unit Price';
        }
        field(115;"Profit %";Decimal)
        {
            Caption = 'Profit %';
        }
    }

    keys
    {
        key(Key1;"Coupon Type","Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

