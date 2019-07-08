table 6151428 "Magento Attribute Set"
{
    // MAG1.00/MH/20150113  CASE 199932 Refactored Object from Web Integration
    // MAG1.02/MH/20150204  CASE 199932 Changed CalcFormula for field 6059807 "Used by Item"
    // MAG1.18/MH/20150714  CASE 218282 Removed restriction on Modifying Description
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.17/JDH /20181112 CASE 334163 Added Caption to Object

    Caption = 'Magento Attribute Set';
    LookupPageID = "Magento Attribute Set List";

    fields
    {
        field(1;"Attribute Set ID";Integer)
        {
            Caption = 'Attribute Set ID';
        }
        field(2;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(1000;"Used by Items";Integer)
        {
            CalcFormula = Count(Item WHERE ("Attribute Set ID"=FIELD("Attribute Set ID")));
            Caption = 'Used by Items';
            Description = 'MAG1.02,MAG2.00';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Attribute Set ID")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        Item: Record Item;
        MagentoAttributeSetValue: Record "Magento Attribute Set Value";
        RecRef: RecordRef;
    begin
        if MagentoAttributeSetMgt.HasProducts(RecRef) then
          Error(Err001);

        MagentoAttributeSetValue.SetRange("Attribute Set ID","Attribute Set ID");
        MagentoAttributeSetValue.DeleteAll;
    end;

    trigger OnInsert()
    begin
        TestField(Description);
    end;

    trigger OnModify()
    var
        RecRef: RecordRef;
    begin
        TestField(Description);

        //-MAG1.18
        //RecRef.GETTABLE(Rec);
        //IF MagentoAttributeSetMgt.HasProducts(RecRef) THEN
        //  ERROR(Err001);
        //++MAG1.18
    end;

    var
        MagentoAttributeSetMgt: Codeunit "Magento Attribute Set Mgt.";
        Err001: Label 'You may not change or delete an attribute which has been assigned to products.';
}

