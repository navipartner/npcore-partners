table 6059797 "NPR POS Payment Method Item"
{
    Access = Internal;
    Caption = 'POS Payment Method Item';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Payment Method Code"; Code[10])
        {
            Caption = 'POS Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method";
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; Type; Enum "NPR POS Pmt. Method Item Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(15; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = if (Type = const(Item)) Item
            else
            if (Type = const("Item Categories")) "Item Category";

            trigger OnValidate()
            var
                Item: Record Item;
                ItemCategory: Record "Item Category";
            begin
                case Type of
                    Type::Item:
                        begin
                            Item.Get("No.");
                            Description := Item.Description;
                        end;
                    Type::"Item Categories":
                        begin
                            ItemCategory.Get("No.");
                            Description := ItemCategory.Description;
                        end;
                end;
            end;
        }
        field(100; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "POS Payment Method Code", "Line No.")
        {
        }
        key(Key2; "POS Payment Method Code", Type, "No.")
        {
        }
    }
}

