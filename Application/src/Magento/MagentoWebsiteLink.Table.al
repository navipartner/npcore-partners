table 6151403 "NPR Magento Website Link"
{
    Caption = 'Magento Website Link';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Website Code"; Code[32])
        {
            Caption = 'Website Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR Magento Website";
        }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(10; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(100; "Website Name"; Text[250])
        {
            CalcFormula = Lookup("NPR Magento Website".Name WHERE(Code = FIELD("Website Code")));
            Caption = 'Website Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Website Code", "Item No.", "Variant Code")
        {
        }
    }
}