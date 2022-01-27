table 6151596 "NPR NpDc Coupon List Item"
{
    Access = Internal;
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
        field(10; Type; Enum "NPR NpDc Coupon Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(15; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST(Item)) Item
            ELSE
            IF (Type = CONST("Item Categories")) "Item Category"
            ELSE
            IF (Type = CONST("Item Disc. Group")) "Item Discount Group"
            ELSE
            IF (Type = CONST("Magento Brand")) "NPR Magento Brand";

            trigger OnValidate()
            var
                Item: Record Item;
                ItemDiscountGroup: Record "Item Discount Group";
                ItemCategory: Record "Item Category";
                MagentoBrand: Record "NPR Magento Brand";
            begin
                case Type of
                    Type::Item:
                        begin
                            Item.Get("No.");
                            Description := Item.Description;
                            "Unit Price" := Item."Unit Price";
                            "Profit %" := Item."Profit %";
                        end;
                    Type::"Item Categories":
                        begin
                            ItemCategory.Get("No.");
                            Description := ItemCategory.Description;
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
                    Type::"Magento Brand":
                        begin
                            MagentoBrand.Get("No.");
                            Description := MagentoBrand.Name;
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
        field(100; Description; Text[100])
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

