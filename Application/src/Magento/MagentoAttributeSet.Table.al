table 6151428 "NPR Magento Attribute Set"
{
    Access = Internal;
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
        field(6151479; "Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
    }

    keys
    {
        key(Key1; "Attribute Set ID")
        {
        }
        key(Key2; "Replication Counter")
        {
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
#IF NOT (BC17 or BC18 or BC19 or BC20)
        key(Key3; SystemRowVersion)
        {
        }
#ENDIF
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
