table 6151429 "NPR Magento Attr. Set Value"
{
    // MAG1.00/MH  /20150113  CASE 199932 Refactored Object from Web Integration
    // MAG1.04/MH  /20150206  CASE 199932 Changed Editable to Yes for field 11 Position
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.17/JDH /20181112  CASE 334163 Added Caption to Object
    // MAG2.18/TS  /20180910  CASE 323934 Added field Attribute Group ID

    Caption = 'Magento Attribute Set Value';
    DataClassification = CustomerContent;
    LookupPageID = "NPR Magento Attr. Set Values";

    fields
    {
        field(1; "Attribute Set ID"; Integer)
        {
            Caption = 'Attribute Set ID';
            DataClassification = CustomerContent;
            TableRelation = "NPR Magento Attribute Set";
        }
        field(2; "Attribute ID"; Integer)
        {
            AutoIncrement = false;
            Caption = 'Attribute ID';
            DataClassification = CustomerContent;
            TableRelation = "NPR Magento Attribute";

            trigger OnValidate()
            var
                MagentoAttribute: Record "NPR Magento Attribute";
            begin
                MagentoAttribute.Get("Attribute ID");
                Description := MagentoAttribute.Description;
                Position := MagentoAttribute.Position;
            end;
        }
        field(3; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; Position; Integer)
        {
            Caption = 'Position';
            DataClassification = CustomerContent;
            Description = 'MAG1.04';
        }
        field(15; "Attribute Group ID"; Integer)
        {
            Caption = 'Attribute Group ID';
            DataClassification = CustomerContent;
            Description = 'MAG2.18';
            TableRelation = "NPR Magento Attribute Group";
        }
        field(1000; "Used by Items"; Integer)
        {
            CalcFormula = Count ("NPR Magento Item Attr. Value" WHERE("Attribute ID" = FIELD("Attribute ID"),
                                                                      Selected = CONST(true)));
            Caption = 'Used by Items';
            Description = 'MAG2.00';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Attribute Set ID", "Attribute ID", "Attribute Group ID")
        {
        }
        key(Key2; Position)
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        MagentoItemAttribute: Record "NPR Magento Item Attr.";
    begin
        //-MAG2.00
        //IF "Used by Item" <>  0 THEN
        if "Used by Items" <> 0 then
            //+MAG2.00
            if not Confirm(Text001, false) then Error('');

        MagentoItemAttribute.SetRange("Attribute Set ID", "Attribute Set ID");
        MagentoItemAttribute.SetRange("Attribute ID", "Attribute ID");
        MagentoItemAttribute.DeleteAll(true);
    end;

    var
        Text001: Label 'Warning. This property is used by products. Do you wish to delete alle occurences of the property?';
}

