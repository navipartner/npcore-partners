table 6151428 "NPR Magento Attribute Set"
{
    Caption = 'Magento Attribute Set';
    DataClassification = CustomerContent;
    LookupPageID = "NPR Magento Attribute Set List";

    fields
    {
        field(1; "Attribute Set ID"; Integer)
        {
            Caption = 'Attribute Set ID';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(1000; "Used by Items"; Integer)
        {
            CalcFormula = Count(Item WHERE("NPR Attribute Set ID" = FIELD("Attribute Set ID")));
            Caption = 'Used by Items';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Attribute Set ID")
        {
        }
    }

    trigger OnDelete()
    var
        MagentoAttributeSetValue: Record "NPR Magento Attr. Set Value";
        RecRef: RecordRef;
    begin
        if MagentoAttributeSetMgt.HasProducts(RecRef) then
            Error(Err001);

        MagentoAttributeSetValue.SetRange("Attribute Set ID", "Attribute Set ID");
        MagentoAttributeSetValue.DeleteAll();
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
        MagentoAttributeSetMgt: Codeunit "NPR Magento Attr. Set Mgt.";
        Err001: Label 'You may not change or delete an attribute which has been assigned to products.';
}