table 6151415 "Magento Category Link"
{
    // MAG1.00/MH/20150113     CASE 199932 Refactored Object from Web Integration
    // MAG1.01/MH/20150119     CASE 199932 Restructured Table
    // MAG1.04/MH/20150216     CASE 199932 Removed Item.Priority
    // MAG1.18/MH/20150714     CASE 218282 Changed field 3 "Item Group Name" and 7 "Item Description" to FlowFields
    // MAG1.21/TS/20151118     CASE 227359 Deleted Field Is Used and Added Field Root
    // MAG1.21/MHA/20151118    CASE 227354 Added field 50 Deactivated which will be set based on MagentoStoreItem.Enabled
    // MAG1.22/MHA/20151210    CASE 229273 Change calcformula for field 110 Disabled
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.17/JDH /20181112 CASE 334163 Added Caption to Object
    // MAG2.26/MHA /20200601  CASE 404580 Magento "Item Group" renamed to "Category"

    Caption = 'Magento Category Link';

    fields
    {
        field(1;"Item No.";Code[20])
        {
            Caption = 'Item no.';
            NotBlank = true;
            TableRelation = Item;
        }
        field(2;"Category Id";Code[20])
        {
            Caption = 'Category Id';
            Description = 'MAG2.26';
            NotBlank = true;
            TableRelation = "Magento Category";
        }
        field(3;"Category Name";Text[50])
        {
            CalcFormula = Lookup("Magento Category".Name WHERE (Id=FIELD("Category Id")));
            Caption = 'Category Name';
            Description = 'MAG2.26';
            Editable = false;
            FieldClass = FlowField;
        }
        field(7;"Item Description";Text[50])
        {
            CalcFormula = Lookup(Item.Description WHERE ("No."=FIELD("Item No.")));
            Caption = 'Item Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(10;Position;Integer)
        {
            Caption = 'Position';
        }
        field(100;"Root No.";Code[20])
        {
            CalcFormula = Lookup("Magento Category"."Root No." WHERE (Id=FIELD("Category Id")));
            Caption = 'Root No.';
            Description = 'MAG1.21,MAG2.26';
            Editable = false;
            FieldClass = FlowField;
        }
        field(110;Disabled;Boolean)
        {
            CalcFormula = -Exist("Magento Store Item" WHERE ("Item No."=FIELD("Item No."),
                                                             "Root Item Group No."=FIELD("Root No."),
                                                             Enabled=CONST(true)));
            Caption = 'Disabled';
            Description = 'MAG1.21,MAG1.22';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Item No.","Category Id")
        {
        }
        key(Key2;"Category Id")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        MagentoItemGroup: Record "Magento Category";
    begin
    end;
}

