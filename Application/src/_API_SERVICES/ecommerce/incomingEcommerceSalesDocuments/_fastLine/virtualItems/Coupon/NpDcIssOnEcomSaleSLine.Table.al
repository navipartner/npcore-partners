#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
table 6060010 "NPR NpDc Iss.OnEcomSale S.Line"
{
    Access = Internal;
    Caption = 'Issue On-Ecom-Sale Setup Line';
    DataClassification = CustomerContent;
    LookupPageId = "NPR NpDc Iss.OnEcomSale SLines";
    DrillDownPageId = "NPR NpDc Iss.OnEcomSale SLines";

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
            OptionCaption = 'Item';
            OptionMembers = Item;
        }
        field(20; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = IF (Type = CONST(Item)) Item."No.";

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                case Type of
                    Type::Item:
                        begin
                            Item.Get("No.");
                            Description := Item.Description;
                        end;
                end;
            end;
        }
        field(30; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST(Item)) "Item Variant".Code WHERE("Item No." = FIELD("No."));
        }
        field(40; Description; Text[100])
        {
            Caption = 'Item Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Coupon Type", "Line No.") { }
        key(ByLineTypeAndNo; Type, "No.", "Variant Code")
        {
            Clustered = true;
        }
    }
}
#endif