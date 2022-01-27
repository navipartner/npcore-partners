table 6151426 "NPR Magento Attribute"
{
    Access = Internal;
    Caption = 'Magento Attribute';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Magento Attr. List";
    LookupPageID = "NPR Magento Attr. List";

    fields
    {
        field(2; "Attribute ID"; Integer)
        {
            Caption = 'Attribute ID';
            DataClassification = CustomerContent;
        }
        field(3; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(7; Filterable; Boolean)
        {
            Caption = 'Filterable';
            DataClassification = CustomerContent;
        }
        field(11; Position; Integer)
        {
            Caption = 'Position';
            DataClassification = CustomerContent;
        }
        field(15; Visible; Boolean)
        {
            Caption = 'Visible';
            DataClassification = CustomerContent;
        }
        field(20; Type; Enum "NPR Magento Item Attr. Value")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            InitValue = Multiple;
        }
        field(30; "Used by Attribute Set"; Integer)
        {
            CalcFormula = Count("NPR Magento Attr. Set Value" WHERE("Attribute ID" = FIELD("Attribute ID")));
            Caption = 'Used by Attribute Set';
            Editable = false;
            FieldClass = FlowField;
        }
        field(35; "Show Option Images Is Frontend"; Boolean)
        {
            Caption = 'Show Option Images Is Frontend';
            DataClassification = CustomerContent;
        }
        field(40; "Use in Product Listing"; Boolean)
        {
            Caption = 'Use in Product Listing';
            DataClassification = CustomerContent;
        }
        field(50; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(500; "Custom ID"; Boolean)
        {
            Caption = 'Custom ID';
            DataClassification = CustomerContent;
        }
        field(1000; "Used by Items"; Integer)
        {
            CalcFormula = Count("NPR Magento Item Attr." WHERE("Attribute ID" = FIELD("Attribute ID")));
            Caption = 'Used by Items';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Attribute ID")
        {
        }
        key(Key2; Position)
        {
        }
    }

    trigger OnDelete()
    var
        ItemAttributeValue: Record "NPR Magento Item Attr. Value";
        AttributeLabel: Record "NPR Magento Attr. Label";
        AttributeSetValue: Record "NPR Magento Attr. Set Value";
    begin
        CalcFields("Used by Attribute Set", "Used by Items");

        if ("Used by Attribute Set" <> 0) or ("Used by Items" <> 0) then
            if not Confirm(ConfimDeleteUsedAttribute, false) then Error('');

        AttributeLabel.SetRange("Attribute ID", "Attribute ID");
        AttributeLabel.DeleteAll(true);

        AttributeSetValue.SetRange("Attribute ID", "Attribute ID");
        AttributeSetValue.DeleteAll(true);
        ;

        ItemAttributeValue.SetRange("Attribute ID", "Attribute ID");
        ItemAttributeValue.DeleteAll(true);
    end;

    trigger OnInsert()
    begin
        TestField(Description);
    end;

    trigger OnModify()
    begin
        TestField(Description);
    end;

    var
        ConfimDeleteUsedAttribute: Label 'Warning. This property is used by products. Do you wish to delete alle occurences of the property?';
}
