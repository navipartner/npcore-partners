table 6151415 "Magento Item Group Link"
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

    Caption = 'Magento Item Group Link';

    fields
    {
        field(1;"Item No.";Code[20])
        {
            Caption = 'Item no.';
            NotBlank = true;
            TableRelation = Item;

            trigger OnValidate()
            begin
                //-MAG1.18
                //Item.GET("Item No.");
                //"Item Description" := Item.Description;
                //+MAG1.18
            end;
        }
        field(2;"Item Group";Code[20])
        {
            Caption = 'Item Group';
            NotBlank = true;
            TableRelation = "Magento Item Group";

            trigger OnValidate()
            var
                MagentoItemGroup: Record "Magento Item Group";
            begin
                //-MAG1.18
                //ItemGroup.GET("Item Group");
                //"Item Group Name" := ItemGroup.Name;
                //+MAG1.18
            end;
        }
        field(3;"Item Group Name";Text[50])
        {
            CalcFormula = Lookup("Magento Item Group".Name WHERE ("No."=FIELD("Item Group")));
            Caption = 'Item group name';
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
            CalcFormula = Lookup("Magento Item Group"."Root No." WHERE ("No."=FIELD("Item Group")));
            Caption = 'Root No.';
            Description = 'MAG1.21';
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
        key(Key1;"Item No.","Item Group")
        {
        }
        key(Key2;"Item Group")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        MagentoItemGroup: Record "Magento Item Group";
    begin
    end;
}

