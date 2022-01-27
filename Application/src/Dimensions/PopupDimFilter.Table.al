table 6014527 "NPR Popup Dim. Filter"
{
    Access = Internal;
    Caption = 'Popup Dimension Filter';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Type; Enum "NPR Dim. Popup Filter Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if Type <> xRec.Type then begin
                    "No." := '';
                    Description := '';
                end;
            end;
        }
        field(2; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = if (Type = const(Item)) Item."No."
            else
            if (Type = const("Item Category")) "Item Category".Code;
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
                    Type::"Item Category":
                        begin
                            ItemCategory.Get("No.");
                            Description := ItemCategory.Description;
                        end;
                end;
            end;
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;

        }
    }
    keys
    {
        key(PK; Type, "No.")
        {
            Clustered = true;
        }
    }

}
