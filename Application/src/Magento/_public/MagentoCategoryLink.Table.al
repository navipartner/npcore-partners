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

        field(6151479; "Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaced by SystemRowVersion';
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
        key(Key3; "Replication Counter")
        {
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
#IF NOT (BC17 or BC18 or BC19 or BC20)
        key(Key4; SystemRowVersion)
        {
        }
#ENDIF
    }
}
