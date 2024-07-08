codeunit 85089 "NPR Magento Attributes Test"
{
    // // [Feature] Magento Attributes API public access
    Subtype = Test;

    trigger OnRun()
    begin
        Initialized := false;
    end;

    var
        Assert: Codeunit Assert;
        LibraryRandom: Codeunit "Library - Random";
        Initialized: Boolean;

    [Test]
    procedure VerifyAttributesAreCreated()
    var
        AttributeSetMgt: Codeunit "NPR Magento Attr. Set Mgt.";
        SetId, Id, DummyId2, GroupId : Integer;
    begin
        // [SCENARIO] Verify & exercise magento attributes are created
        Initialize();

        // [WHEN] Create Magento Attributes
        Id := CreateMagentoAttribute(123);
        DummyId2 := CreateMagentoAttribute(321);
        CreateMagentoAttributeLabel(Id);
        GroupId := CreateMagentoAttributeGroup();
        SetId := CreateMagentoAttributeSet();
        CreateMagentoAttributeSetValue(SetId, Id, GroupId);

        // [THEN] Verify Magento Attributes exists
        Assert.IsTrue(AttributeSetMgt.MagentoAttributeExists(''), 'Magento Attribute not created');
        Assert.IsTrue(AttributeSetMgt.MagentoAttributeGroupExists(''), 'Magento Attribute Group not created');
        Assert.IsTrue(AttributeSetMgt.MagentoAttributeLabelExists(''), 'Magento Attribute Label not created');
        Assert.IsTrue(AttributeSetMgt.MagentoAttributeSetExists(''), 'Magento Attribute Set not created');
        Assert.IsTrue(AttributeSetMgt.MagentoAttributeSetValuesExists(''), 'Magento Attribute Set Value not created');

        // [THEN] Verify number of created Magento Attributes
        Assert.AreEqual(2, AttributeSetMgt.MagentoAttributeCount(''), 'Created more then one attribute');
        Assert.AreEqual(1, AttributeSetMgt.MagentoAttributeGroupCount(''), 'Created more then one attribute group');
        Assert.AreEqual(1, AttributeSetMgt.MagentoAttributeLabelCount(''), 'Created more then one attribute label');
        Assert.AreEqual(1, AttributeSetMgt.MagentoAttributeSetCount(''), 'Created more then one attribute set');
        Assert.AreEqual(1, AttributeSetMgt.MagentoAttributeSetValuesCount(''), 'Created more then one attribute set value');
    end;

    [Test]
    procedure VerifyAttributesAreUpdated()
    var
        AttributeSetMgt: Codeunit "NPR Magento Attr. Set Mgt.";
        LibraryRandom: Codeunit "Library - Random";
        ExpectedFieldsAttribute, ExpectedFieldsAttributeLabel, ExpectedFieldsAttributeGroup, ExpectedFieldsAttributeSet, ExpectedFieldsAttributeSetValue : Dictionary of [Text, Text];
        ActualFieldsAttribute, ActualFieldsAttributeLabel, ActualFieldsAttributeGroup, ActualFieldsAttributeSet, ActualFieldsAttributeSetValue : Dictionary of [Text, Text];
        FieldsNotUpdated: Dictionary of [Text, Text];
        SetId, Id1, Id2, GroupId1, GroupId2, LabelId11, LabelId21, LabelId12, LabelId22, LabelId32 : Integer;
        SetValue1, SetValue2 : Text;
    begin
        // [SCENARIO] Verify & exercise magento attributes are created
        Initialize();

        // [GIVEN] Magento Attributes
        Id1 := CreateMagentoAttribute(123);
        LabelId11 := CreateMagentoAttributeLabel(Id1);
        LabelId21 := CreateMagentoAttributeLabel(Id1, LibraryRandom.RandText(100));

        Id2 := CreateMagentoAttribute(LibraryRandom.RandText(50));
        LabelId12 := CreateMagentoAttributeLabel(Id2);
        LabelId22 := CreateMagentoAttributeLabel(Id2, LibraryRandom.RandText(100));
        LabelId32 := CreateMagentoAttributeLabel(Id2, LibraryRandom.RandText(100));

        GroupId1 := CreateMagentoAttributeGroup();
        GroupId2 := CreateMagentoAttributeGroup(LibraryRandom.RandText(50));

        SetId := CreateMagentoAttributeSet(LibraryRandom.RandText(50));
        SetValue1 := CreateMagentoAttributeSetValue(SetId, Id1, GroupId2);
        SetValue2 := CreateMagentoAttributeSetValue(SetId, Id2, GroupId2);

        // [WHEN] Update Position, Visibility and Type
        ExpectedFieldsAttribute.Add('Position', Format(LibraryRandom.RandInt(10), 0, 9));
        ExpectedFieldsAttribute.Add('Visible', Format(true, 0, 9));
        ExpectedFieldsAttribute.Add('Type', Format(1, 0, 9));
        AttributeSetMgt.UpdateMagentoAttribute(Id2, ExpectedFieldsAttribute, true, FieldsNotUpdated);

        // [THEN] Verify Position, Visibility and Type are updated
        AttributeSetMgt.GetMagentoAttribute(Id2, ActualFieldsAttribute);
        Assert.IsTrue(ActualFieldsAttribute.ContainsKey('Position'), 'Field Position is not prepared for update');
        Assert.AreEqual(ExpectedFieldsAttribute.Get('Position'), ActualFieldsAttribute.Get('Position'), 'Field Position is not updated');

        Assert.IsTrue(ActualFieldsAttribute.ContainsKey('Visible'), 'Field Visible is not prepared for update');
        Assert.AreEqual(ExpectedFieldsAttribute.Get('Visible'), ActualFieldsAttribute.Get('Visible'), 'Field Visible is not updated');

        Assert.IsTrue(ActualFieldsAttribute.ContainsKey('Type'), 'Field Type is not prepared for update');
        Assert.AreEqual(ExpectedFieldsAttribute.Get('Type'), ActualFieldsAttribute.Get('Type'), 'Field Type is not updated');

        // [WHEN] Update Text Field
        ExpectedFieldsAttributeLabel.Add('Text Field', LibraryRandom.RandText(5000));
        AttributeSetMgt.UpdateMagentoAttributeLabel(Id1, LabelId21, ExpectedFieldsAttributeLabel, true, FieldsNotUpdated);

        // [THEN] Verify Text Field is updated
        AttributeSetMgt.GetMagentoAttributeLabel(Id1, LabelId21, ActualFieldsAttributeLabel);
        Assert.IsTrue(ActualFieldsAttributeLabel.ContainsKey('Text Field'), 'Field Text Field is not prepared for update');
        Assert.AreEqual(ExpectedFieldsAttributeLabel.Get('Text Field'), ActualFieldsAttributeLabel.Get('Text Field'), 'Field Text Field is not updated');

        // [WHEN] Update Sort Order
        ExpectedFieldsAttributeGroup.Add('Sort Order', Format(LibraryRandom.RandInt(10), 0, 9));
        AttributeSetMgt.UpdateMagentoAttributeGroup(GroupId2, ExpectedFieldsAttributeGroup, true, FieldsNotUpdated);

        // [THEN] Verify Sort Order is updated
        AttributeSetMgt.GetMagentoAttributeGroup(GroupId2, ActualFieldsAttributeGroup);
        Assert.IsTrue(ActualFieldsAttributeGroup.ContainsKey('Sort Order'), 'Field Sort Order is not prepared for update');
        Assert.AreEqual(ExpectedFieldsAttributeGroup.Get('Sort Order'), ActualFieldsAttributeGroup.Get('Sort Order'), 'Field Sort Order is not updated');

        // [WHEN] Update Description
        AttributeSetMgt.GetMagentoAttributeSet(SetId, ActualFieldsAttributeSet);
        ExpectedFieldsAttributeSet.Add('Description', LibraryRandom.RandText(50));
        AttributeSetMgt.UpdateMagentoAttributeSet(SetId, ExpectedFieldsAttributeSet, true, FieldsNotUpdated);

        // [THEN] Verify Description is updated
        Assert.AreNotEqual(ExpectedFieldsAttributeSet.Get('Description'), ActualFieldsAttributeSet.Get('Description'), 'Field Description is not updated');

        // [WHEN] Update Position
        ExpectedFieldsAttributeSetValue.Add('Position', Format(LibraryRandom.RandInt(100), 0, 9));
        AttributeSetMgt.UpdateMagentoAttributeSetValue(SetId, Id2, GroupId2, ExpectedFieldsAttributeSetValue, true, FieldsNotUpdated);

        // [THEN] Verify Position is updated 
        AttributeSetMgt.GetMagentoAttributeSetValue(SetId, Id2, GroupId2, ActualFieldsAttributeSetValue);
        Assert.IsTrue(ActualFieldsAttributeSetValue.ContainsKey('Position'), 'Field Position is not prepared for update');
        Assert.AreEqual(ExpectedFieldsAttributeSetValue.Get('Position'), ActualFieldsAttributeSetValue.Get('Position'), 'Field Position is not updated');
    end;

    [Test]
    procedure VerifyAttributesAreNotUpdated()
    var
        AttributeSetMgt: Codeunit "NPR Magento Attr. Set Mgt.";
        LibraryRandom: Codeunit "Library - Random";
        UpdateFieldsAttribute, UpdateFieldsAttributeLabel, UpdateFieldsAttributeGroup, UpdateFieldsAttributeSet, UpdateFieldsAttributeSetValue : Dictionary of [Text, Text];
        FieldsNotUpdatedAttribute, FieldsNotUpdatedAttributeLabel, FieldsNotUpdatedAttributeGroup, FieldsNotUpdatedAttributeSet, FieldsNotUpdatedAttributeSetValue : Dictionary of [Text, Text];
        SetId, Id1, Id2, GroupId1, GroupId2, LabelId11, LabelId21, LabelId12, LabelId22, LabelId32 : Integer;
        SetValue1, SetValue2, FieldName, FieldValue : Text;
    begin
        // [SCENARIO] Verify & exercise magento attributes are created
        Initialize();

        // [GIVEN] Magento Attributes
        Id1 := CreateMagentoAttribute(123);
        LabelId11 := CreateMagentoAttributeLabel(Id1);
        LabelId21 := CreateMagentoAttributeLabel(Id1, LibraryRandom.RandText(100));

        Id2 := CreateMagentoAttribute(LibraryRandom.RandText(50));
        LabelId12 := CreateMagentoAttributeLabel(Id2);
        LabelId22 := CreateMagentoAttributeLabel(Id2, LibraryRandom.RandText(100));
        LabelId32 := CreateMagentoAttributeLabel(Id2, LibraryRandom.RandText(100));

        GroupId1 := CreateMagentoAttributeGroup();
        GroupId2 := CreateMagentoAttributeGroup(LibraryRandom.RandText(50));

        SetId := CreateMagentoAttributeSet(LibraryRandom.RandText(50));
        SetValue1 := CreateMagentoAttributeSetValue(SetId, Id1, GroupId2);
        SetValue2 := CreateMagentoAttributeSetValue(SetId, Id2, GroupId2);

        // [WHEN] Update unknown field and flowfield in Magento Attribute
        FieldName := LibraryRandom.RandText(30);
        //Since field doesn't exist we can forward any value type
        UpdateFieldsAttribute.Add(FieldName, Format(true, 0, 9));
        UpdateFieldsAttribute.Add('Used by Attribute Set', Format(LibraryRandom.RandInt(10), 0, 9));
        AttributeSetMgt.UpdateMagentoAttribute(Id2, UpdateFieldsAttribute, true, FieldsNotUpdatedAttribute);

        // [THEN] Verify unkown field and flowfield are not updated in Magento Attribute
        Assert.AreEqual(2, FieldsNotUpdatedAttribute.Count(), '');
        FieldsNotUpdatedAttribute.Get(FieldName, FieldValue);
        Assert.IsTrue(FieldValue.Contains('was not found in'), 'Unknown field is updated');

        FieldsNotUpdatedAttribute.Get('Used by Attribute Set', FieldValue);
        Assert.IsTrue(FieldValue.Contains('Only Normal fields can be updated'), 'Non normal field is updated');

        // [WHEN] Update unknown field Magento Attribute Label
        UpdateFieldsAttributeLabel.Add(FieldName, Format(true, 0, 9));
        AttributeSetMgt.UpdateMagentoAttributeLabel(Id1, LabelId11, UpdateFieldsAttributeLabel, true, FieldsNotUpdatedAttributeLabel);

        // [THEN] Verify unkown field and flowfield are not updated in Magento Attribute Label
        Assert.AreEqual(1, FieldsNotUpdatedAttributeLabel.Count(), '');
        FieldsNotUpdatedAttributeLabel.Get(FieldName, FieldValue);
        Assert.IsTrue(FieldValue.Contains('was not found in'), 'Unknown field is updated');

        // [WHEN] Update unknown field Magento Attribute Group
        UpdateFieldsAttributeGroup.Add(FieldName, Format(true, 0, 9));
        AttributeSetMgt.UpdateMagentoAttributeGroup(GroupId2, UpdateFieldsAttributeGroup, true, FieldsNotUpdatedAttributeGroup);

        // [THEN] Verify unkown field and flowfield are not updated in Magento Attribute Group
        Assert.AreEqual(1, FieldsNotUpdatedAttributeGroup.Count(), '');
        FieldsNotUpdatedAttributeGroup.Get(FieldName, FieldValue);
        Assert.IsTrue(FieldValue.Contains('was not found in'), 'Unknown field is updated');

        // [WHEN] Update unknown field Magento Attribute Set
        UpdateFieldsAttributeSet.Add(FieldName, Format(true, 0, 9));
        UpdateFieldsAttributeSet.Add('Used by Items', Format(LibraryRandom.RandInt(10), 0, 9));
        AttributeSetMgt.UpdateMagentoAttributeSet(SetId, UpdateFieldsAttributeSet, true, FieldsNotUpdatedAttributeSet);

        // [THEN] Verify unkown field and flowfield are not updated in Magento Attribute Set
        Assert.AreEqual(2, FieldsNotUpdatedAttributeSet.Count(), '');
        FieldsNotUpdatedAttributeSet.Get(FieldName, FieldValue);
        Assert.IsTrue(FieldValue.Contains('was not found in'), 'Unknown field is updated');

        FieldsNotUpdatedAttributeSet.Get('Used by Items', FieldValue);
        Assert.IsTrue(FieldValue.Contains('Only Normal fields can be updated'), 'Non normal field is updated');

        // [WHEN] Update unknown field Magento Attribute Set Value
        UpdateFieldsAttributeSetValue.Add(FieldName, Format(true, 0, 9));
        UpdateFieldsAttributeSetValue.Add('Used by Items', Format(LibraryRandom.RandInt(10), 0, 9));
        AttributeSetMgt.UpdateMagentoAttributeSetValue(SetId, Id1, GroupId2, UpdateFieldsAttributeSetValue, true, FieldsNotUpdatedAttributeSetValue);

        // [THEN] Verify unkown field and flowfield are not updated in Magento Attribute Set Value
        Assert.AreEqual(2, FieldsNotUpdatedAttributeSetValue.Count(), '');
        FieldsNotUpdatedAttributeSetValue.Get(FieldName, FieldValue);
        Assert.IsTrue(FieldValue.Contains('was not found in'), 'Unknown field is updated');

        FieldsNotUpdatedAttributeSetValue.Get('Used by Items', FieldValue);
        Assert.IsTrue(FieldValue.Contains('Only Normal fields can be updated'), 'Non normal field is updated');
    end;

    [Test]
    procedure DeleteMagentoAttribute()
    var
        AttributeSetMgt: Codeunit "NPR Magento Attr. Set Mgt.";
        LibraryRandom: Codeunit "Library - Random";
        FieldsAttribute, FieldsAttributeLabel : Dictionary of [Text, Text];
        Id1, Id2, Id3, Id4, LabelId11, LabelId21, LabelId12, LabelId22, LabelId32 : Integer;
        AttributeDesc1, AttributeDesc2, AttributeDesc3, AttributeDesc4, AttributeLabelValue11, AttributeLabelValue21, AttributeLabelValue22, AttributeLabelValue32 : Text;
    begin
        // [SCENARIO] Verify & exercise magento attributes are created
        Initialize();

        // [GIVEN] Magento Attributes
        Id1 := CreateMagentoAttribute(123);
        LabelId11 := CreateMagentoAttributeLabel(Id1);
        LabelId21 := CreateMagentoAttributeLabel(Id1, LibraryRandom.RandText(100));

        AttributeDesc2 := LibraryRandom.RandText(50);
        Id2 := CreateMagentoAttribute(AttributeDesc2);
        LabelId12 := CreateMagentoAttributeLabel(Id2);
        LabelId22 := CreateMagentoAttributeLabel(Id2, LibraryRandom.RandText(100));
        AttributeSetMgt.GetMagentoAttributeLabel(Id2, LabelId22, FieldsAttributeLabel);
        FieldsAttributeLabel.Get('Value', AttributeLabelValue22);

        LabelId32 := CreateMagentoAttributeLabel(Id2, LowerCase(LibraryRandom.RandText(100)));

        AttributeDesc3 := LibraryRandom.RandText(50);
        Id3 := CreateMagentoAttribute(AttributeDesc3);

        AttributeDesc4 := LowerCase(LibraryRandom.RandText(50));
        Id4 := CreateMagentoAttribute(AttributeDesc4);

        // [WHEN] Delete Magento Attribute
        AttributeSetMgt.GetMagentoAttribute(Id1, FieldsAttribute);
        AttributeSetMgt.DeleteMagentoAttribute(Id1, false);
        AttributeSetMgt.DeleteMagentoAttributes(AttributeDesc3, false);
        AttributeSetMgt.DeleteMagentoAttributes(UpperCase(AttributeDesc4), false);

        // [THEN] Verify deleted Magento Attributes are not found
        FieldsAttribute.Get('Description', AttributeDesc1);
        Assert.IsTrue(not AttributeSetMgt.MagentoAttributeExists(AttributeDesc1), StrSubstNo('Magento Attribute found for value %1', AttributeDesc1));
        Assert.IsTrue(AttributeSetMgt.MagentoAttributeExists(AttributeDesc2), StrSubstNo('Magento Attribute not found for value %1', AttributeDesc2));
        Assert.IsTrue(not AttributeSetMgt.MagentoAttributeExists(AttributeDesc3), StrSubstNo('Magento Attribute found for value %1', AttributeDesc3));
        Assert.IsTrue(not AttributeSetMgt.MagentoAttributeExists(UpperCase(AttributeDesc4)), StrSubstNo('Magento Attribute found for value %1', AttributeDesc4));

        // [WHEN] Delete Magento Attribute Label
        AttributeSetMgt.GetMagentoAttributeLabel(Id1, LabelId11, FieldsAttributeLabel);
        FieldsAttributeLabel.Get('Value', AttributeLabelValue11);
        AttributeSetMgt.DeleteMagentoAttributeLabel(Id1, LabelId11, false);
        AttributeSetMgt.GetMagentoAttributeLabel(Id1, LabelId21, FieldsAttributeLabel);
        FieldsAttributeLabel.Get('Value', AttributeLabelValue21);
        AttributeSetMgt.DeleteMagentoAttributeLabels(AttributeLabelValue21, false);
        AttributeSetMgt.GetMagentoAttributeLabel(Id2, LabelId32, FieldsAttributeLabel);
        FieldsAttributeLabel.Get('Value', AttributeLabelValue32);
        AttributeSetMgt.DeleteMagentoAttributeLabels(UpperCase(AttributeLabelValue32), false);

        // [THEN] Verify deleted Magento Attribute Labels are not found       
        Assert.IsTrue(not AttributeSetMgt.MagentoAttributeLabelExists(AttributeLabelValue11), StrSubstNo('Magento Attribute Label found for value %1', AttributeLabelValue11));
        Assert.IsTrue(not AttributeSetMgt.MagentoAttributeLabelExists(AttributeLabelValue21), StrSubstNo('Magento Attribute Label found for value %1', AttributeLabelValue21));
        Assert.IsTrue(not AttributeSetMgt.MagentoAttributeLabelExists(UpperCase(AttributeLabelValue32)), StrSubstNo('Magento Attribute Label found for value %1', AttributeLabelValue32));
        Assert.IsTrue(AttributeSetMgt.MagentoAttributeLabelExists(AttributeLabelValue22), StrSubstNo('Magento Attribute Label not found for value %1', AttributeLabelValue22));
    end;

    [Test]
    procedure VerifyAttributesCantBeAssignedToItem()
    var
        Item: Record Item;
        AttributeSetMgt: Codeunit "NPR Magento Attr. Set Mgt.";
        LibraryRandom: Codeunit "Library - Random";
        LibraryInventory: Codeunit "Library - Inventory";
        SetId1, SetId2, Id1, Id2, GroupId1, GroupId2, LabelId11, LabelId21, LabelId12, LabelId22, LabelId32 : Integer;
        SetValue11, SetValue21, SetValue12, SetValue22 : Text;
    begin
        // [SCENARIO] Verify & exercise magento attributes are created
        Initialize();

        // [GIVEN] Magento Attributes
        Id1 := CreateMagentoAttribute(123);
        LabelId11 := CreateMagentoAttributeLabel(Id1);
        LabelId21 := CreateMagentoAttributeLabel(Id1, LibraryRandom.RandText(100));

        Id2 := CreateMagentoAttribute(LibraryRandom.RandText(50));
        LabelId12 := CreateMagentoAttributeLabel(Id2);
        LabelId22 := CreateMagentoAttributeLabel(Id2, LibraryRandom.RandText(100));
        LabelId32 := CreateMagentoAttributeLabel(Id2, LibraryRandom.RandText(100));

        GroupId1 := CreateMagentoAttributeGroup();
        GroupId2 := CreateMagentoAttributeGroup(LibraryRandom.RandText(50));

        SetId1 := CreateMagentoAttributeSet(LibraryRandom.RandText(50));
        SetValue11 := CreateMagentoAttributeSetValue(SetId1, Id1, GroupId1);
        SetValue21 := CreateMagentoAttributeSetValue(SetId1, Id2, GroupId1);

        SetId2 := CreateMagentoAttributeSet(LibraryRandom.RandText(50));
        SetValue12 := CreateMagentoAttributeSetValue(SetId2, Id1, GroupId2);
        SetValue22 := CreateMagentoAttributeSetValue(SetId2, Id2, GroupId2);

        // [GIVEN] Item
        LibraryInventory.CreateItem(Item);
        Item."NPR Attribute Set ID" := 0;
        Item.Modify();

        // [WHEN] Map Attributes to Item for unknown Set Id
        // [THEN] Expected error
        asserterror AttributeSetMgt.SetupItemAttributes(Item, '');
    end;

    [Test]
    procedure VerifyAttributesCanBeAssignedToItem()
    var
        Item: Record Item;
        MagentoItemAttribute: Record "NPR Magento Item Attr.";
        MagentoItemAttributeValue: Record "NPR Magento Item Attr. Value";
        AttributeSetMgt: Codeunit "NPR Magento Attr. Set Mgt.";
        LibraryRandom: Codeunit "Library - Random";
        LibraryInventory: Codeunit "Library - Inventory";
        SetId1, SetId2, Id1, Id2, GroupId1, GroupId2, LabelId11, LabelId21, LabelId12, LabelId22, LabelId32 : Integer;
        SetValue11, SetValue21, SetValue12, SetValue22 : Text;
    begin
        // [SCENARIO] Verify & exercise magento attributes are created
        Initialize();

        // [GIVEN] Magento Attributes
        Id1 := CreateMagentoAttribute(123);
        LabelId11 := CreateMagentoAttributeLabel(Id1);
        LabelId21 := CreateMagentoAttributeLabel(Id1, LibraryRandom.RandText(100));

        Id2 := CreateMagentoAttribute(LibraryRandom.RandText(50));
        LabelId12 := CreateMagentoAttributeLabel(Id2);
        LabelId22 := CreateMagentoAttributeLabel(Id2, LibraryRandom.RandText(100));
        LabelId32 := CreateMagentoAttributeLabel(Id2, LibraryRandom.RandText(100));

        GroupId1 := CreateMagentoAttributeGroup();
        GroupId2 := CreateMagentoAttributeGroup(LibraryRandom.RandText(50));

        SetId1 := CreateMagentoAttributeSet(LibraryRandom.RandText(50));
        SetValue11 := CreateMagentoAttributeSetValue(SetId1, Id1, GroupId1);
        SetValue21 := CreateMagentoAttributeSetValue(SetId1, Id2, GroupId1);

        SetId2 := CreateMagentoAttributeSet(LibraryRandom.RandText(50));
        SetValue12 := CreateMagentoAttributeSetValue(SetId2, Id1, GroupId2);
        SetValue22 := CreateMagentoAttributeSetValue(SetId2, Id2, GroupId2);

        // [GIVEN] Item
        LibraryInventory.CreateItem(Item);
        Item."NPR Attribute Set ID" := 0;
        Item.Modify();

        // [WHEN] Map Attributes to Item for unknown Set Id
        Item."NPR Attribute Set ID" := SetId2;
        AttributeSetMgt.SetupItemAttributes(Item, '');

        // [THEN] Verify Magento Attributes are assigned to Item
        Assert.AreEqual(2, MagentoItemAttribute.Count(), 'More or less then 2 Item Attributes has been created');
        Assert.IsTrue(MagentoItemAttribute.Get(SetId2, Id1, Item."No.", ''), StrSubstNo('Item Attribute not found for %1', Id1));
        Assert.IsTrue(MagentoItemAttribute.Get(SetId2, Id2, Item."No.", ''), StrSubstNo('Item Attribute not found for %1', Id2));

        Assert.AreEqual(5, MagentoItemAttributeValue.Count(), 'More or less then 5 Item Attributes has been created');
        Assert.IsTrue(MagentoItemAttributeValue.Get(Id1, Item."No.", '', LabelId11), StrSubstNo('Item Attribute Value not found for %1', LabelId11));
        Assert.IsFalse(MagentoItemAttributeValue.Get(Id1, Item."No.", '', LabelId32), StrSubstNo('Item Attribute Value not found for %1', LabelId11));
        Assert.IsTrue(MagentoItemAttributeValue.Get(Id2, Item."No.", '', LabelId32), StrSubstNo('Item Attribute Value not found for %1', LabelId32));
    end;

    local procedure Initialize()
    begin
        if not Initialized then begin

            Initialized := true;
        end;
        ResetAttributes();
        Commit();
    end;

    local procedure ResetAttributes()
    var
        Attribute: Record "NPR Magento Attribute";
        AttributeGroup: Record "NPR Magento Attribute Group";
        AttributeSetValue: Record "NPR Magento Attr. Set Value";
        AttributeSet: Record "NPR Magento Attribute Set";
        ItemAttribute: Record "NPR Magento Item Attr.";
        Item: Record Item;
    begin
        ItemAttribute.DeleteAll(true);
        AttributeSetValue.DeleteAll(true);
        Attribute.DeleteAll(true);
        AttributeGroup.DeleteAll(true);
        AttributeSet.DeleteAll(true);
        Item.SetFilter("NPR Attribute Set ID", '<>0');
        if not Item.IsEmpty() then
            Item.ModifyAll("NPR Attribute Set ID", 0, false);
    end;


    local procedure CreateMagentoAttribute(AttributeId: Integer): Integer
    var
        MagentoAttributeSetMgt: Codeunit "NPR Magento Attr. Set Mgt.";
    begin
        exit(MagentoAttributeSetMgt.CreateMagentoAttribute(AttributeId, LibraryRandom.RandText(50), false));
    end;

    local procedure CreateMagentoAttribute(AttributeDescription: Text): Integer
    var
        MagentoAttributeSetMgt: Codeunit "NPR Magento Attr. Set Mgt.";
    begin
        exit(MagentoAttributeSetMgt.CreateMagentoAttribute(AttributeDescription, false));
    end;

    local procedure CreateMagentoAttributeLabel(AttributeId: Integer): Integer
    var
        MagentoAttributeSetMgt: Codeunit "NPR Magento Attr. Set Mgt.";
    begin
        exit(MagentoAttributeSetMgt.CreateMagentoAttributeLabel(AttributeId, LibraryRandom.RandInt(100), LibraryRandom.RandText(100), false));
    end;

    local procedure CreateMagentoAttributeLabel(AttributeId: Integer; AttributeLabelValue: Text): Integer
    var
        MagentoAttributeSetMgt: Codeunit "NPR Magento Attr. Set Mgt.";
    begin
        exit(MagentoAttributeSetMgt.CreateMagentoAttributeLabel(AttributeId, AttributeLabelValue, false));
    end;

    local procedure CreateMagentoAttributeGroup(): Integer
    var
        MagentoAttributeSetMgt: Codeunit "NPR Magento Attr. Set Mgt.";
    begin
        exit(MagentoAttributeSetMgt.CreateMagentoAttributeGroup(LibraryRandom.RandInt(100), LibraryRandom.RandText(50), false));
    end;

    local procedure CreateMagentoAttributeGroup(AttributeGroupDescription: Text): Integer
    var
        MagentoAttributeSetMgt: Codeunit "NPR Magento Attr. Set Mgt.";
    begin
        exit(MagentoAttributeSetMgt.CreateMagentoAttributeGroup(AttributeGroupDescription, false));
    end;

    local procedure CreateMagentoAttributeSet(): Integer
    var
        MagentoAttributeSetMgt: Codeunit "NPR Magento Attr. Set Mgt.";
    begin
        exit(MagentoAttributeSetMgt.CreateMagentoAttributeSet(LibraryRandom.RandInt(100), LibraryRandom.RandText(50), false));
    end;

    local procedure CreateMagentoAttributeSet(AttributeSetDescription: Text): Integer
    var
        MagentoAttributeSetMgt: Codeunit "NPR Magento Attr. Set Mgt.";
    begin
        exit(MagentoAttributeSetMgt.CreateMagentoAttributeSet(AttributeSetDescription, false));
    end;

    local procedure CreateMagentoAttributeSetValue(AttroibuteSetId: Integer; AttributeId: Integer; AttributeGroupId: Integer): Text
    var
        MagentoAttributeSetMgt: Codeunit "NPR Magento Attr. Set Mgt.";
    begin
        exit(MagentoAttributeSetMgt.CreateMagentoAttributeSetValue(AttroibuteSetId, AttributeId, AttributeGroupId, LibraryRandom.RandText(50), false));
    end;
}