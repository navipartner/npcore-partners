table 6151415 "NPR Magento Category Link"
{
    Caption = 'Magento Category Link';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item no.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = Item;
        }
        field(2; "Category Id"; Code[20])
        {
            Caption = 'Category Id';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR Magento Category";
        }
        field(3; "Category Name"; Text[50])
        {
            CalcFormula = Lookup("NPR Magento Category".Name WHERE(Id = FIELD("Category Id")));
            Caption = 'Category Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(7; "Item Description"; Text[50])
        {
            CalcFormula = Lookup(Item.Description WHERE("No." = FIELD("Item No.")));
            Caption = 'Item Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(10; Position; Integer)
        {
            Caption = 'Position';
            DataClassification = CustomerContent;
        }
        field(100; "Root No."; Code[20])
        {
            CalcFormula = Lookup("NPR Magento Category"."Root No." WHERE(Id = FIELD("Category Id")));
            Caption = 'Root No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(110; Disabled; Boolean)
        {
            CalcFormula = - Exist("NPR Magento Store Item" WHERE("Item No." = FIELD("Item No."),
                                                             "Root Item Group No." = FIELD("Root No."),
                                                             Enabled = CONST(true)));
            Caption = 'Disabled';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Item No.", "Category Id")
        {
        }
        key(Key2; "Category Id")
        {
        }
    }
}
