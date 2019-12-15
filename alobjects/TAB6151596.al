table 6151596 "NpDc Coupon List Item"
{
    // NPR5.34/MHA /20170720  CASE 282799 Object created - NpDc: NaviPartner Discount Coupon
    // NPR5.45/MHA /20180820  CASE 312991 Added field 25 "Max. Quantity"
    // NPR5.46/MHA /20180925  CASE 327366 Added fields 30 "Validation Quantity", 35 "Lot Validation"

    Caption = 'Coupon List Item';

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
        field(22;"Max. Discount Amount";Decimal)
        {
            BlankZero = true;
            Caption = 'Max. Discount Amount per Coupon';
            Description = 'NPR5.45';
        }
        field(25;"Max. Quantity";Decimal)
        {
            BlankZero = true;
            Caption = 'Max. Quantity per Coupon';
            DecimalPlaces = 0:5;
            Description = 'NPR5.45';
        }
        field(30;"Validation Quantity";Decimal)
        {
            Caption = 'Validation Quantity';
            DecimalPlaces = 0:5;
            Description = 'NPR5.46';
        }
        field(35;"Lot Validation";Boolean)
        {
            Caption = 'Lot Validation';
            Description = 'NPR5.46';
        }
        field(50;Priority;Integer)
        {
            Caption = 'Priority';
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
        key(Key2;Priority)
        {
        }
    }

    fieldgroups
    {
    }
}

