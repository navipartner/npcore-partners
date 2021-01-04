table 6151596 "NPR NpDc Coupon List Item"
{
    Caption = 'Coupon List Item';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Coupon Type"; Code[20])
        {
            Caption = 'Coupon Type';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpDc Coupon Type";
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Item,Item Group,Item Disc. Group';
            OptionMembers = Item,"Item Group","Item Disc. Group";
        }
        field(15; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST(Item)) Item
            ELSE
            IF (Type = CONST("Item Group")) "NPR Item Group"
            ELSE
            IF (Type = CONST("Item Disc. Group")) "Item Discount Group";

            trigger OnValidate()
            var
                Item: Record Item;
                ItemDiscountGroup: Record "Item Discount Group";
                ItemGroup: Record "NPR Item Group";
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
        field(22; "Max. Discount Amount"; Decimal)
        {
            BlankZero = true;
            Caption = 'Max. Discount Amount per Coupon';
            DataClassification = CustomerContent;
            Description = 'NPR5.45';
        }
        field(25; "Max. Quantity"; Decimal)
        {
            BlankZero = true;
            Caption = 'Max. Quantity per Coupon';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.45';
        }
        field(30; "Validation Quantity"; Decimal)
        {
            Caption = 'Validation Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.46';
        }
        field(35; "Lot Validation"; Boolean)
        {
            Caption = 'Lot Validation';
            DataClassification = CustomerContent;
            Description = 'NPR5.46';
        }
        field(50; Priority; Integer)
        {
            Caption = 'Priority';
            DataClassification = CustomerContent;
        }
        field(100; Description; Text[50])
        {
            Caption = 'Item Description';
            DataClassification = CustomerContent;
        }
        field(105; "Unit Price"; Decimal)
        {
            BlankZero = true;
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
        }
        field(115; "Profit %"; Decimal)
        {
            Caption = 'Profit %';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Coupon Type", "Line No.")
        {
        }
        key(Key2; Priority)
        {
        }
    }
}

