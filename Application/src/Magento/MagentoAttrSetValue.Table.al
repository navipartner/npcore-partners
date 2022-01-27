table 6151429 "NPR Magento Attr. Set Value"
{
    Access = Internal;
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
        }
        field(15; "Attribute Group ID"; Integer)
        {
            Caption = 'Attribute Group ID';
            DataClassification = CustomerContent;
            TableRelation = "NPR Magento Attribute Group";
        }
        field(1000; "Used by Items"; Integer)
        {
            CalcFormula = Count("NPR Magento Item Attr. Value" WHERE("Attribute ID" = FIELD("Attribute ID"),
                                                                      Selected = CONST(true)));
            Caption = 'Used by Items';
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

    trigger OnDelete()
    var
        MagentoItemAttribute: Record "NPR Magento Item Attr.";
    begin
        if "Used by Items" <> 0 then
            if not Confirm(Text001, false) then Error('');

        MagentoItemAttribute.SetRange("Attribute Set ID", "Attribute Set ID");
        MagentoItemAttribute.SetRange("Attribute ID", "Attribute ID");
        MagentoItemAttribute.DeleteAll(true);
    end;

    var
        Text001: Label 'Warning. This property is used by products. Do you wish to delete alle occurences of the property?';
}
