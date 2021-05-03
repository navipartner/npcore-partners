table 6151417 "NPR Magento Product Relation"
{

    Caption = 'Magento Product Relation';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Relation Type"; Enum "NPR Mag. Prod. Relation Type")
        {
            BlankZero = true;
            Caption = 'Relation Type';
            DataClassification = CustomerContent;
            InitValue = Relation;
        }
        field(2; "From Item No."; Code[20])
        {
            Caption = 'From Item No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = Item WHERE("NPR Magento Item" = CONST(true));
        }
        field(3; "To Item No."; Code[20])
        {
            Caption = 'To Item No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = Item WHERE("NPR Magento Item" = CONST(true));
        }
        field(4; Position; Integer)
        {
            Caption = 'Position';
            DataClassification = CustomerContent;
        }
        field(10; "To Item Description"; Text[100])
        {
            CalcFormula = Lookup(Item.Description WHERE("No." = FIELD("To Item No.")));
            Caption = 'Description';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Relation Type", "From Item No.", "To Item No.")
        {
        }
    }
}
