table 6151128 "NPR NpIa ItemAddOn Line Opt."
{
    Caption = 'Item AddOn Line Option';
    DataClassification = CustomerContent;
    
    fields
    {
        field(1; "AddOn No."; Code[20])
        {
            Caption = 'AddOn No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR NpIa Item AddOn";
        }
        field(5; "AddOn Line No."; Integer)
        {
            Caption = 'AddOn Line No.';
            DataClassification = CustomerContent;
        }
        field(10; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(15; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                if "Item No." = '' then begin
                    Init();
                    exit;
                end;
                Item.Get("Item No.");

                "Unit Price" := Item."Unit Price";
                Description := Item.Description;
                Validate("Variant Code");
            end;
        }
        field(20; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));

            trigger OnValidate()
            var
                ItemVariant: Record "Item Variant";
            begin
                if "Variant Code" <> '' then
                    ItemVariant.Get("Item No.", "Variant Code")
                else
                    Clear(ItemVariant);

                "Description 2" := ItemVariant.Description;
            end;
        }
        field(25; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(30; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            DataClassification = CustomerContent;
        }
        field(35; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            InitValue = 1;

            trigger OnValidate()
            begin
                if Quantity = 0 then
                    TestField("Fixed Quantity", false);
            end;
        }
        field(40; "Fixed Quantity"; Boolean)
        {
            Caption = 'Fixed Quantity';
            DataClassification = CustomerContent;
            Description = 'NPR5.52';

            trigger OnValidate()
            begin
                if "Fixed Quantity" then
                    TestField(Quantity);
            end;
        }
        field(49; "Use Unit Price"; Option)
        {
            Caption = 'Use Unit Price';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
            OptionCaption = 'Non-Zero,Always';
            OptionMembers = "Non-Zero",Always;
        }
        field(50; "Unit Price"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
            Description = 'NPR5.52';
        }
        field(60; "Discount %"; Decimal)
        {
            BlankZero = true;
            Caption = 'Discount %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 1;
            Description = 'NPR5.52';
            MaxValue = 100;
            MinValue = 0;
        }
        field(70; "Per Unit"; Boolean)
        {
            Caption = 'Per unit';
            DataClassification = CustomerContent;
            Description = 'NPR5.52';
        }
    }

    keys
    {
        key(Key1; "AddOn No.", "AddOn Line No.", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

