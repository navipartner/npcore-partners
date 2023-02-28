codeunit 6151412 "NPR Magento Attr. Set Mgt."
{
    var
        SetIdAlreadyAssignedErr: Label 'Attribute Set ID %1 and Attribute Group Name %2 already exist.', Comment = '%1="NPR Magento Attribute Group"."Attribute Set ID";%2="NPR Magento Attribute Group".Description';

    internal procedure EditItemAttributes(ItemNo: Code[20]; VariantCode: Code[10])
    var
        Item: Record Item;
        MagentoItemAttributes: Page "NPR Magento Item Attr.";
    begin
        Item.Get(ItemNo);
        Commit();
        MagentoItemAttributes.SetValues(Item."No.", Item."NPR Attribute Set ID", VariantCode);
        MagentoItemAttributes.RunModal();
    end;

    /// <summary>
    /// Creates Magento Attribute
    /// </summary>
    /// <param name="AttributeId">Specifies unique Magento Attrubute identifier</param>
    /// <param name="AttributeDescription">Specifies name/description of Magento Attribute</param>
    /// <param name="RunTrigger">Specifies whether trigger should be executed when creating Magento Attribute</param>
    /// <returns>Attribute Id of Magento Attribute</returns>
    procedure CreateMagentoAttribute(AttributeId: Integer; AttributeDescription: Text; RunTrigger: Boolean): Integer
    var
        MagentoAttribute: Record "NPR Magento Attribute";
    begin
        MagentoAttribute."Attribute ID" := AttributeId;
        MagentoAttribute.Init();
        MagentoAttribute.Description := CopyStr(AttributeDescription, 1, MaxStrLen(MagentoAttribute.Description));
        MagentoAttribute.Insert(RunTrigger);
        exit(MagentoAttribute."Attribute ID");
    end;

    /// <summary>
    /// Creates Magento Attribute if it does not exist
    /// </summary>
    /// <param name="AttributeDescription">Specifies name/description of Magento Attribute</param>
    /// <param name="RunTrigger">Specifies whether trigger should be executed when creating Magento Attribute</param>
    /// <returns>Attribute Id of Magento Attribute</returns>
    procedure CreateMagentoAttribute(AttributeDescription: Text; RunTrigger: Boolean): Integer
    var
        MagentoAttribute: Record "NPR Magento Attribute";
    begin
        MagentoAttribute.SetFilter(Description, '@' + AttributeDescription);
        if not MagentoAttribute.FindFirst() then begin
            Clear(MagentoAttribute);
            exit(CreateMagentoAttribute(FindLastAttributeId() + 10000, AttributeDescription, RunTrigger));
        end;
        exit(MagentoAttribute."Attribute ID");
    end;

    local procedure FindLastAttributeId(): Integer
    var
        MagentoAttribute: Record "NPR Magento Attribute";
    begin
        if MagentoAttribute.FindLast() then
            exit(MagentoAttribute."Attribute ID");
    end;

    /// <summary>
    /// Gets Magento Attribute values
    /// </summary>
    /// <param name="AttributeId">Specifies Magento Attribute unique identifier</param>
    /// <returns>Values of current record</returns>
    procedure GetMagentoAttribute(AttributeId: Integer; var AttributeFields: Dictionary of [Text, Text])
    var
        MagentoAttribute: Record "NPR Magento Attribute";
        RecRef: RecordRef;
        DataTypeMgt: Codeunit "Data Type Management";
    begin
        MagentoAttribute.Get(AttributeId);
        DataTypeMgt.GetRecordRef(MagentoAttribute, RecRef);
        GetRecordFields(RecRef, AttributeFields);
    end;

    /// <summary>
    /// Specifies whether Magento Attribute exist for the search criteria
    /// </summary>
    /// <param name="AttributeDescriptionFilter">A filter string that is applied to the "Description" field.</param>
    /// <remarks>AttributeDescription with ignoring case will be used as a search criteria if string is not empty</remarks>
    /// <returns>True/False</returns>
    procedure MagentoAttributeExists(AttributeDescriptionFilter: Text): Boolean
    var
        MagentoAttribute: Record "NPR Magento Attribute";
    begin
        if AttributeDescriptionFilter <> '' then
            MagentoAttribute.SetFilter(Description, AttributeDescriptionFilter);
        exit(not MagentoAttribute.IsEmpty());
    end;

    /// <summary>
    /// Gets Magento Attribute count for the search criteria
    /// </summary>
    /// <param name="AttributeDescriptionFilter">A filter string that is applied to the "Description" field.</param>
    /// <remarks>AttributeDescription with ignoring case will be used as a search criteria if string is not empty</remarks>
    /// <returns>Number of Magento Attributes</returns>
    procedure MagentoAttributeCount(AttributeDescriptionFilter: Text): Integer
    var
        MagentoAttribute: Record "NPR Magento Attribute";
    begin
        if AttributeDescriptionFilter <> '' then
            MagentoAttribute.SetFilter(Description, AttributeDescriptionFilter);
        exit(MagentoAttribute.Count());
    end;

    /// <summary>
    /// Gets Magento Attribute ID for the search criteria
    /// </summary>
    /// <param name="AttributeDescriptionFilter">A filter string that is applied to the "Description" field.</param>
    /// <remarks>AttributeDescription with ignoring case will be used as a search criteria if string is not empty</remarks>
    /// <returns>Magento Attribute ID</returns>
    procedure GetMagentoAttributeID(AttributeDescriptionFilter: Text): Integer
    var
        MagentoAttribute: Record "NPR Magento Attribute";
    begin
        if AttributeDescriptionFilter = '' then
            exit(0);

        MagentoAttribute.SetFilter(Description, AttributeDescriptionFilter);
        if MagentoAttribute.FindFirst() then
            exit(MagentoAttribute."Attribute ID");

        exit(0);
    end;

    /// <summary>
    /// Updates Magento Attribute
    /// </summary>
    /// <param name="AttributeId">Specifies unique Magento Attrubute identifier</param>
    /// <param name="UpdateFields">Specifies key/value pair of fields which will be updated</param>
    /// <param name="RunTrigger">Specifies whether trigger should be executed when updating Magento Attribute</param>
    /// <param name="FieldsNotUpdated">Specifies key/value pair of fields with specific reason why field is not updated</param>
    /// <returns>List of key/value reasons why specific field is not updated</returns>
    procedure UpdateMagentoAttribute(AttributeId: Integer; UpdateFields: Dictionary of [Text, Text]; RunTrigger: Boolean; var FieldsNotUpdated: Dictionary of [Text, Text])
    var
        MagentoAttribute: Record "NPR Magento Attribute";
        DataTypeMgt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not MagentoAttribute.Get(AttributeId) then
            exit;
        DataTypeMgt.GetRecordRef(MagentoAttribute, RecRef);
        UpdateTableFields(RecRef, UpdateFields, RunTrigger, FieldsNotUpdated);
    end;

    /// <summary>
    /// Deletes Magento Attribute
    /// </summary>
    /// <param name="AttributeId">Specifies unique Magento Attrubute identifier</param>
    /// <param name="RunTrigger">Specifies whether trigger should be executed when deleting Magento Attribute</param>
    procedure DeleteMagentoAttribute(AttributeId: Integer; RunTrigger: Boolean)
    var
        MagentoAttribute: Record "NPR Magento Attribute";
    begin
        if not MagentoAttribute.Get(AttributeId) then
            exit;
        MagentoAttribute.Delete(RunTrigger);
    end;

    /// <summary>
    /// Deletes Magento Attributes
    /// </summary>
    /// <param name="AttributeDescriptionFilter">A filter string that is applied to the "Description" field.</param>
    /// <param name="RunTrigger">Specifies whether trigger should be executed when deleting Magento Attributes</param>
    /// <remarks>AttributeDescription with ignoring case will be used as a search criteria if string is not empty</remarks>
    procedure DeleteMagentoAttributes(AttributeDescriptionFilter: Text; RunTrigger: Boolean)
    var
        MagentoAttribute: Record "NPR Magento Attribute";
    begin
        if AttributeDescriptionFilter <> '' then
            MagentoAttribute.SetFilter(Description, AttributeDescriptionFilter);
        if MagentoAttribute.IsEmpty() then
            exit;
        MagentoAttribute.DeleteAll(RunTrigger);
    end;

    /// <summary>
    /// Creates Magento Attribute Gorup
    /// </summary>
    /// <param name="AttributeGroupId">Specifies unique Magento Attrubute Group identifier</param>
    /// <param name="AttributeGroupDescription">Specifies name/description of Magento Attribute Group</param>
    /// <param name="RunTrigger">Specifies whether trigger should be executed when creating Magento Attribute Group</param>
    /// <returns>Attribute Group Id of Magento Attribute Group</returns>
    procedure CreateMagentoAttributeGroup(AttributeGroupId: Integer; AttributeGroupDescription: Text; RunTrigger: Boolean): Integer
    var
        MagentoAttributeGroup: Record "NPR Magento Attribute Group";
    begin
        MagentoAttributeGroup."Attribute Group ID" := AttributeGroupId;
        MagentoAttributeGroup.Init();
        MagentoAttributeGroup.Description := CopyStr(AttributeGroupDescription, 1, MaxStrLen(MagentoAttributeGroup.Description));
        MagentoAttributeGroup.Insert(RunTrigger);
        exit(MagentoAttributeGroup."Attribute Group ID");
    end;

    /// <summary>
    /// Creates Magento Attribute if it does not exist
    /// </summary>
    /// <param name="AttributeGroupDescription">Specifies name/description of Magento Attribute Group</param>
    /// <param name="RunTrigger">Specifies whether trigger should be executed when creating Magento Attribute Group</param>
    /// <returns>Attribute Group Id of Magento Attribute Group</returns>
    procedure CreateMagentoAttributeGroup(AttributeGroupDescription: Text; RunTrigger: Boolean): Integer
    var
        MagentoAttributeGroup: Record "NPR Magento Attribute Group";
    begin
        MagentoAttributeGroup.SetFilter(Description, '@' + AttributeGroupDescription);
        if not MagentoAttributeGroup.FindFirst() then begin
            Clear(MagentoAttributeGroup);
            exit(CreateMagentoAttributeGroup(FindLastAttributeGroupId() + 10000, AttributeGroupDescription, RunTrigger));
        end;
        exit(MagentoAttributeGroup."Attribute Group ID");
    end;

    local procedure FindLastAttributeGroupId(): Integer
    var
        MagentoAttributeGroup: Record "NPR Magento Attribute Group";
    begin
        if MagentoAttributeGroup.FindLast() then
            exit(MagentoAttributeGroup."Attribute Group ID");
    end;

    /// <summary>
    /// Gets Magento Attribute Group values
    /// </summary>
    /// <param name="AttributeGroupId">Specifies Magento Attribute Group unique identifier</param>
    /// <returns>Values of current record</returns>
    procedure GetMagentoAttributeGroup(AttributeGroupId: Integer; var AttributeFields: Dictionary of [Text, Text])
    var
        MagentoAttributeGroup: Record "NPR Magento Attribute Group";
        RecRef: RecordRef;
        DataTypeMgt: Codeunit "Data Type Management";
    begin
        MagentoAttributeGroup.Get(AttributeGroupId);
        DataTypeMgt.GetRecordRef(MagentoAttributeGroup, RecRef);
        GetRecordFields(RecRef, AttributeFields);
    end;

    /// <summary>
    /// Specifies whether Magento Attribute Group exist for the search criteria
    /// </summary>
    /// <param name="AttributeGroupDescriptionFilter">A filter string that is applied to the "Description" field.</param>
    /// <remarks>AttributeGroupDescription with ignoring case will be used as a search criteria if string is not empty</remarks>
    /// <returns>True/False</returns>
    procedure MagentoAttributeGroupExists(AttributeGroupDescriptionFilter: Text): Boolean
    var
        MagentoAttributeGroup: Record "NPR Magento Attribute Group";
    begin
        if AttributeGroupDescriptionFilter <> '' then
            MagentoAttributeGroup.SetFilter(Description, AttributeGroupDescriptionFilter);
        exit(not MagentoAttributeGroup.IsEmpty());
    end;

    /// <summary>
    /// Gets Magento Attribute Group count for the search criteria
    /// </summary>
    /// <param name="AttributeDescriptionFilter">A filter string that is applied to the "Description" field.</param>
    /// <remarks>AttributeGroupDescription with ignoring case will be used as a search criteria if string is not empty</remarks>
    /// <returns>Number of Magento Attribute Groups</returns>
    procedure MagentoAttributeGroupCount(AttributeGroupDescriptionFilter: Text): Integer
    var
        MagentoAttributeGroup: Record "NPR Magento Attribute Group";
    begin
        if AttributeGroupDescriptionFilter <> '' then
            MagentoAttributeGroup.SetFilter(Description, AttributeGroupDescriptionFilter);
        exit(MagentoAttributeGroup.Count());
    end;

    /// <summary>
    /// Updates Magento Attribute Group
    /// </summary>
    /// <param name="AttributeGroupId">Specifies unique Magento Attrubute Group identifier</param>
    /// <param name="UpdateFields">Specifies key/value pair of fields which will be updated</param>
    /// <param name="RunTrigger">Specifies whether trigger should be executed when updating Magento Attribute Group</param>
    /// <param name="FieldsNotUpdated">Specifies key/value pair of fields with specific reason why field is not updated</param>
    /// <returns>List of key/value reasons why specific field is not updated</returns>
    procedure UpdateMagentoAttributeGroup(AttributeGroupId: Integer; UpdateFields: Dictionary of [Text, Text]; RunTrigger: Boolean; var FieldsNotUpdated: Dictionary of [Text, Text])
    var
        MagentoAttributeGroup: Record "NPR Magento Attribute Group";
        DataTypeMgt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not MagentoAttributeGroup.Get(AttributeGroupId) then
            exit;
        DataTypeMgt.GetRecordRef(MagentoAttributeGroup, RecRef);
        UpdateTableFields(RecRef, UpdateFields, RunTrigger, FieldsNotUpdated);
    end;

    /// <summary>
    /// Deletes Magento Attribute Group
    /// </summary>
    /// <param name="AttributeGroupId">Specifies unique Magento Attrubute Group identifier</param>
    /// <param name="RunTrigger">Specifies whether trigger should be executed when deleting Magento Attribute Group</param>
    procedure DeleteMagentoAttributeGroup(AttributeGroupId: Integer; RunTrigger: Boolean)
    var
        MagentoAttributeGroup: Record "NPR Magento Attribute Group";
    begin
        if not MagentoAttributeGroup.Get(AttributeGroupId) then
            exit;
        MagentoAttributeGroup.Delete(RunTrigger);
    end;

    /// <summary>
    /// Deletes Magento Attributes
    /// </summary>
    /// <param name="AttributeGroupDescriptionFilter">A filter string that is applied to the "Description" field.</param>
    /// <param name="RunTrigger">Specifies whether trigger should be executed when deleting Magento Attribute Groups</param>
    /// <remarks>AttributeGroupDescription with ignoring case will be used as a search criteria if string is not empty</remarks>
    procedure DeleteMagentoAttributeGroups(AttributeGroupDescriptionFilter: Text; RunTrigger: Boolean)
    var
        MagentoAttributeGroup: Record "NPR Magento Attribute Group";
    begin
        if AttributeGroupDescriptionFilter <> '' then
            MagentoAttributeGroup.SetFilter(Description, AttributeGroupDescriptionFilter);
        if MagentoAttributeGroup.IsEmpty() then
            exit;
        MagentoAttributeGroup.DeleteAll(RunTrigger);
    end;

    /// <summary>
    /// Creates Magento Attribute Label
    /// </summary>
    /// <param name="AttributeId">Specifies Magento Attrubute identifier</param>
    /// <param name="LabelLineNo">Specifies Magento Attrubute Label unique </param>
    /// <param name="AttributeValue">Specifies value of Magento Attribute Label</param>
    /// <param name="RunTrigger">Specifies whether trigger should be executed when creating Magento Attribute Label</param>
    /// <returns>Line No. of Magento Attribute Label</returns>
    procedure CreateMagentoAttributeLabel(AttributeId: Integer; LabelLineNo: Integer; AttributeValue: Text; RunTrigger: Boolean): Integer
    var
        MagentoAttributeLabel: Record "NPR Magento Attr. Label";
    begin
        MagentoAttributeLabel."Attribute ID" := AttributeId;
        MagentoAttributeLabel."Line No." := LabelLineNo;
        MagentoAttributeLabel.Init();
        MagentoAttributeLabel.Value := CopyStr(AttributeValue, 1, MaxStrLen(MagentoAttributeLabel.Value));
        MagentoAttributeLabel.Insert(RunTrigger);
        exit(MagentoAttributeLabel."Line No.");
    end;

    /// <summary>
    /// Creates Magento Attribute Label if it does not exist
    /// </summary>
    /// <param name="AttributeId">Specifies Magento Attrubute identifier</param>
    /// <param name="AttributeValue">Specifies value of Magento Attribute Label</param>
    /// <param name="RunTrigger">Specifies whether trigger should be executed when creating Magento Attribute Label</param>
    /// <returns>Line No. of Magento Attribute Label</returns>
    /// <remarks>Value 10000 is used for incrementing Line No.</remarks>
    procedure CreateMagentoAttributeLabel(AttributeId: Integer; AttributeValue: Text; RunTrigger: Boolean): Integer
    var
        MagentoAttributeLabel: Record "NPR Magento Attr. Label";
        AttributeLabelLineNo: Integer;
    begin
        MagentoAttributeLabel.SetRange("Attribute ID", AttributeId);
        MagentoAttributeLabel.SetFilter(Value, '@' + AttributeValue);
        if not MagentoAttributeLabel.FindFirst() then begin
            Clear(MagentoAttributeLabel);
            AttributeLabelLineNo := FindLastMagentoAttributeLabelLineNo(AttributeId) + 10000;
            exit(CreateMagentoAttributeLabel(AttributeId, AttributeLabelLineNo, AttributeValue, RunTrigger));
        end;
        exit(MagentoAttributeLabel."Line No.");
    end;

    local procedure FindLastMagentoAttributeLabelLineNo(AttributeId: Integer): Integer
    var
        MagentoAttributeLabel: Record "NPR Magento Attr. Label";
    begin
        MagentoAttributeLabel.SetRange("Attribute ID", AttributeId);
        if MagentoAttributeLabel.FindLast() then
            exit(MagentoAttributeLabel."Line No.");
    end;

    /// <summary>
    /// Gets Magento Attribute Label values
    /// </summary>
    /// <param name="AttributeId">Specifies Magento Attribute identifier</param>
    /// <param name="LabelLineNo">Specifies Magento Attribute Label unique identifier</param>
    /// <returns>Label values</returns>
    procedure GetMagentoAttributeLabel(AttributeId: Integer; LabelLineNo: Integer; var AttributeFields: Dictionary of [Text, Text])
    var
        MagentoAttributeLabel: Record "NPR Magento Attr. Label";
        DataTypeMgt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        MagentoAttributeLabel.get(AttributeId, LabelLineNo);
        DataTypeMgt.GetRecordRef(MagentoAttributeLabel, RecRef);
        GetRecordFields(RecRef, AttributeFields);
    end;

    /// <summary>
    /// Gets Magento Attribute Label Line No.
    /// </summary>
    /// <param name="AttributeId">Specifies Magento Attribute identifier</param>
    /// <param name="LabelLineNo">Specifies Magento Attribute Label Value filter</param>
    /// <returns>Line No.</returns>
    procedure GetMagentoAttributeLabelLineNo(AttributeId: Integer; AttributeValueFilter: Text): Integer
    var
        MagentoAttributeLabel: Record "NPR Magento Attr. Label";
    begin
        MagentoAttributeLabel.SetRange("Attribute ID", AttributeId);
        MagentoAttributeLabel.SetFilter(Value, AttributeValueFilter);
        if MagentoAttributeLabel.FindFirst() then
            exit(MagentoAttributeLabel."Line No.");

        exit(0);
    end;

    /// <summary>
    /// Specifies whether Magento Attribute Label exist for the search criteria
    /// </summary>
    /// <param name="AttributeValueFilter">A filter string that is used as search criteria</param>
    /// <remarks>AttributeValue with ignoring case will be used as a search criteria if string is not empty</remarks>
    /// <returns>True/False</returns>
    procedure MagentoAttributeLabelExists(AttributeValueFilter: Text): Boolean
    var
        MagentoAttributeLabel: Record "NPR Magento Attr. Label";
    begin
        if AttributeValueFilter <> '' then
            MagentoAttributeLabel.SetFilter(Value, AttributeValueFilter);
        exit(not MagentoAttributeLabel.IsEmpty());
    end;

    /// <summary>
    /// Gets Magento Attribute Label count for the search criteria
    /// </summary>
    /// <param name="AttributeValueFilter">A filter string used as search criteria</param>
    /// <remarks>AttributeValue with ignoring case will be used as a search criteria if string is not empty</remarks>
    /// <returns>Number of Magento Attribute Labels</returns>
    procedure MagentoAttributeLabelCount(AttributeValueFilter: Text): Integer
    var
        MagentoAttributeLabel: Record "NPR Magento Attr. Label";
    begin
        if AttributeValueFilter <> '' then
            MagentoAttributeLabel.SetFilter(Value, AttributeValueFilter);
        exit(MagentoAttributeLabel.Count());
    end;

    /// <summary>
    /// Updates Magento Attribute Label
    /// </summary>
    /// <param name="AttributeId">Specifies Magento Attrubute identifier</param>
    /// <param name="LabelLineNo">Specifies Magento Attribute Label unique identifier</param>
    /// <param name="UpdateFields">Specifies key/value pair of fields which will be updated</param>
    /// <param name="RunTrigger">Specifies whether trigger should be executed when updating Magento Attribute Label</param>
    /// <param name="FieldsNotUpdated">Specifies key/value pair of fields with specific reason why field is not updated</param>
    /// <returns>List of key/value reasons why specific field is not updated</returns>
    procedure UpdateMagentoAttributeLabel(AttributeId: Integer; LabelLineNo: Integer; UpdateFields: Dictionary of [Text, Text]; RunTrigger: Boolean; var FieldsNotUpdated: Dictionary of [Text, Text])
    var
        MagentoAttributeLabel: Record "NPR Magento Attr. Label";
        DataTypeMgt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not MagentoAttributeLabel.Get(AttributeId, LabelLineNo) then
            exit;
        DataTypeMgt.GetRecordRef(MagentoAttributeLabel, RecRef);
        UpdateTableFields(RecRef, UpdateFields, RunTrigger, FieldsNotUpdated);
    end;

    /// <summary>
    /// Updates Magento Attribute Label Value field
    /// </summary>
    /// <param name="AttributeId">Specifies Magento Attrubute identifier</param>
    /// <param name="NewAttributeValue">Specifies the NEW value of Magento Attribute Label</param>
    /// <param name="OldAttributeValue">Specifies the OLD value of Magento Attribute Label</param>
    /// <param name="RunTrigger">Specifies whether trigger should be executed when creating Magento Attribute Label</param>
    /// <returns>Line No. of Magento Attribute Label</returns>
    procedure UpdateMagentoAttributeLabelValue(AttributeId: Integer; NewAttributeValue: Text; OldAttributeValue: Text; RunTrigger: Boolean): Integer
    var
        MagentoAttributeLabel: Record "NPR Magento Attr. Label";
    begin
        MagentoAttributeLabel.SetRange("Attribute ID", AttributeId);
        MagentoAttributeLabel.SetFilter(Value, '@' + OldAttributeValue);
        if not MagentoAttributeLabel.FindFirst() then
            exit(0);

        MagentoAttributeLabel.Value := CopyStr(NewAttributeValue, 1, MaxStrLen(MagentoAttributeLabel.Value));
        MagentoAttributeLabel.Modify(RunTrigger);
        exit(MagentoAttributeLabel."Line No.")
    end;

    /// <summary>
    /// Updates Magento Attribute Label Value field or creates a new entry
    /// </summary>
    /// <param name="AttributeId">Specifies Magento Attrubute identifier</param>
    /// <param name="NewAttributeValue">Specifies the NEW value of Magento Attribute Label</param>
    /// <param name="OldAttributeValue">Specifies the OLD value of Magento Attribute Label</param>
    /// <param name="RunTrigger">Specifies whether trigger should be executed when creating Magento Attribute Label</param>
    /// <returns>Line No. of Magento Attribute Label</returns>
    /// <remarks>Value 10000 is used for incrementing Line No.</remarks>
    procedure CreateUpdateMagentoAttributeLabelValue(AttributeId: Integer; NewAttributeValue: Text; OldAttributeValue: Text; RunTrigger: Boolean): Integer
    var
        AttributeLabelLineNo: Integer;
    begin
        AttributeLabelLineNo := UpdateMagentoAttributeLabelValue(AttributeId, NewAttributeValue, OldAttributeValue, RunTrigger);

        if AttributeLabelLineNo <> 0 then
            exit(AttributeLabelLineNo);

        AttributeLabelLineNo := FindLastMagentoAttributeLabelLineNo(AttributeId) + 10000;
        exit(CreateMagentoAttributeLabel(AttributeId, AttributeLabelLineNo, NewAttributeValue, RunTrigger));
    end;

    /// <summary>
    /// Deletes Magento Attribute Label
    /// </summary>
    /// <param name="AttributeId">Specifies Magento Attrubute identifier</param>
    /// <param name="LabelLineNo">Specifies Magento Attribute Label unique identifier</param>
    /// <param name="RunTrigger">Specifies whether trigger should be executed when deleting Magento Attribute Label</param>
    procedure DeleteMagentoAttributeLabel(AttributeId: Integer; LabelLineNo: Integer; RunTrigger: Boolean)
    var
        MagentoAttributeLabel: Record "NPR Magento Attr. Label";
    begin
        if not MagentoAttributeLabel.Get(AttributeId, LabelLineNo) then
            exit;
        MagentoAttributeLabel.Delete(RunTrigger);
    end;

    /// <summary>
    /// Deletes Magento Attribute Labels
    /// </summary>
    /// <param name="AttributeId">Specifies Magento Attrubute identifier used in the search criteria</param>
    /// <param name="RunTrigger">Specifies whether trigger should be executed when deleting Magento Attribute Label</param>
    procedure DeleteMagentoAttributeLabel(AttributeId: Integer; RunTrigger: Boolean)
    var
        MagentoAttributeLabel: Record "NPR Magento Attr. Label";
    begin
        MagentoAttributeLabel.SetRange("Attribute ID", AttributeId);
        if MagentoAttributeLabel.IsEmpty() then
            exit;
        MagentoAttributeLabel.DeleteAll(RunTrigger);
    end;

    /// <summary>
    /// Deletes Magento Attribute Labels
    /// </summary>
    /// <param name="AttributeValueFilter">A filter used as the search criteria when deleting values</param>
    /// <param name="RunTrigger">Specifies whether trigger should be executed when deleting Magento Attribute Label</param>
    /// <remarks>AttributeValue with ignoring case will be used as a search criteria if string is not empty</remarks>
    procedure DeleteMagentoAttributeLabels(AttributeValueFilter: Text; RunTrigger: Boolean)
    var
        MagentoAttributeLabel: Record "NPR Magento Attr. Label";
    begin
        if AttributeValueFilter <> '' then
            MagentoAttributeLabel.SetFilter(Value, AttributeValueFilter);
        if MagentoAttributeLabel.IsEmpty() then
            exit;
        MagentoAttributeLabel.DeleteAll(RunTrigger);
    end;

    /// <summary>
    /// Creates Magento Attribute Set
    /// </summary>
    /// <param name="AttributeSetId">Specifies unique Magento Attrubute Set identifier</param>
    /// <param name="AttributeSetDescription">Specifies name/description of Magento Attribute Set</param>
    /// <param name="RunTrigger">Specifies whether trigger should be executed when creating Magento Attribute Set</param>
    /// <returns>Attribute Set Id of Magento Attribute Set</returns>
    procedure CreateMagentoAttributeSet(AttributeSetId: Integer; AttributeSetDescription: Text; RunTrigger: Boolean): Integer
    var
        MagentoAttributeSet: Record "NPR Magento Attribute Set";
    begin
        MagentoAttributeSet."Attribute Set ID" := AttributeSetId;
        MagentoAttributeSet.Init();
        MagentoAttributeSet.Description := CopyStr(AttributeSetDescription, 1, MaxStrLen(MagentoAttributeSet.Description));
        MagentoAttributeSet.Insert(RunTrigger);
        exit(MagentoAttributeSet."Attribute Set ID");
    end;

    /// <summary>
    /// Creates Magento Attribute Set if it does not exist
    /// </summary>
    /// <param name="AttributeSetDescription">Specifies name/description of Magento Attribute Set</param>
    /// <param name="RunTrigger">Specifies whether trigger should be executed when creating Magento Attribute Set</param>
    /// <returns>Attribute Set Id of Magento Attribute</returns>
    procedure CreateMagentoAttributeSet(AttributeSetDescription: Text; RunTrigger: Boolean): Integer
    var
        MagentoAttributeSet: Record "NPR Magento Attribute Set";
    begin
        MagentoAttributeSet.SetFilter(Description, '@' + AttributeSetDescription);
        if not MagentoAttributeSet.FindFirst() then begin
            Clear(MagentoAttributeSet);
            exit(CreateMagentoAttributeSet(FindLastAttributeSetId() + 10000, AttributeSetDescription, RunTrigger));
        end;
        exit(MagentoAttributeSet."Attribute Set ID");
    end;

    /// <summary>
    /// Gets Magento Attribute Set values
    /// </summary>
    /// <param name="AttributeSetId">Specifies Magento Attribute Set unique identifier</param>
    /// <returns>Values of current record</returns>
    procedure GetMagentoAttributeSet(AttributeSetId: Integer; var AttributeFields: Dictionary of [Text, Text])
    var
        MagentoAttributeSet: Record "NPR Magento Attribute Set";
        RecRef: RecordRef;
        DataTypeMgt: Codeunit "Data Type Management";
    begin
        MagentoAttributeSet.Get(AttributeSetId);
        DataTypeMgt.GetRecordRef(MagentoAttributeSet, RecRef);
        GetRecordFields(RecRef, AttributeFields);
    end;

    local procedure FindLastAttributeSetId(): Integer
    var
        MagentoAttributeSet: Record "NPR Magento Attribute Set";
    begin
        if MagentoAttributeSet.FindLast() then
            exit(MagentoAttributeSet."Attribute Set ID");
    end;

    /// <summary>
    /// Updates Magento Attribute Set
    /// </summary>
    /// <param name="AttributeSetId">Specifies unique Magento Attrubute Set identifier</param>
    /// <param name="UpdateFields">Specifies key/value pair of fields which will be updated</param>
    /// <param name="RunTrigger">Specifies whether trigger should be executed when updating Magento Attribute Set</param>
    /// <param name="FieldsNotUpdated">Specifies key/value pair of fields with specific reason why field is not updated</param>
    /// <returns>List of key/value reasons why specific field is not updated</returns>
    procedure UpdateMagentoAttributeSet(AttributeSetId: Integer; UpdateFields: Dictionary of [Text, Text]; RunTrigger: Boolean; var FieldsNotUpdated: Dictionary of [Text, Text])
    var
        MagentoAttributeSet: Record "NPR Magento Attribute Set";
        DataTypeMgt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not MagentoAttributeSet.Get(AttributeSetId) then
            exit;
        DataTypeMgt.GetRecordRef(MagentoAttributeSet, RecRef);
        UpdateTableFields(RecRef, UpdateFields, RunTrigger, FieldsNotUpdated);
    end;

    /// <summary>
    /// Deletes Magento Attribute Set
    /// </summary>
    /// <param name="AttributeSetId">Specifies unique Magento Attrubute Set identifier</param>
    /// <param name="RunTrigger">Specifies whether trigger should be executed when deleting Magento Attribute Set</param>
    procedure DeleteMagentoAttributeSet(AttributeSetId: Integer; RunTrigger: Boolean)
    var
        MagentoAttributeSet: Record "NPR Magento Attribute Set";
    begin
        if not MagentoAttributeSet.Get(AttributeSetId) then
            exit;
        MagentoAttributeSet.Delete(RunTrigger);
    end;

    /// <summary>
    /// Deletes Magento Attribute Sets
    /// </summary>
    /// <param name="AttributeSetDescriptionFilter">A filter string used as search criteria on the Attribute Set Description</param>
    /// <param name="RunTrigger">Specifies whether trigger should be executed when deleting Magento Attribute Sets</param>
    procedure DeleteMagentoAttributeSets(AttributeSetDescriptionFilter: Text; RunTrigger: Boolean)
    var
        MagentoAttributeSet: Record "NPR Magento Attribute Set";
    begin
        MagentoAttributeSet.SetFilter(Description, AttributeSetDescriptionFilter);
        if MagentoAttributeSet.IsEmpty() then
            exit;
        MagentoAttributeSet.DeleteAll(RunTrigger);
    end;

    /// <summary>
    /// Specifies whether Magento Attribute Sets exist for the search criteria
    /// </summary>
    /// <param name="AttributeSetDescriptionFilter">A filter string used as search criteria on Attribute Set Description</param>
    /// <remarks>AttributeSetDescription with ignoring case will be used as a search criteria if string is not empty</remarks>
    /// <returns>True/False</returns>
    procedure MagentoAttributeSetExists(AttributeSetDescriptionFilter: Text): Boolean
    var
        MagentoAttributeSet: Record "NPR Magento Attribute Set";
    begin
        if AttributeSetDescriptionFilter <> '' then
            MagentoAttributeSet.SetFilter(Description, AttributeSetDescriptionFilter);
        exit(not MagentoAttributeSet.IsEmpty());
    end;

    /// <summary>
    /// Gets number of Magento Attribute Sets
    /// </summary>
    /// <param name="AttributeSetDescriptionFilter">A filter string used as search criteria</param>
    /// <remarks>AttributeSetDescription with ignoring case will be used as a search criteria if string is not empty</remarks>
    /// <returns>Number of Magento Attribute Sets</returns>
    procedure MagentoAttributeSetCount(AttributeSetDescriptionFilter: Text): Integer
    var
        MagentoAttributeSet: Record "NPR Magento Attribute Set";
    begin
        if AttributeSetDescriptionFilter <> '' then
            MagentoAttributeSet.SetFilter(Description, AttributeSetDescriptionFilter);
        exit(MagentoAttributeSet.Count());
    end;

    /// <summary>
    /// Creates Magento Attribute Set Value
    /// </summary>
    /// <param name="AttributeSetId">Specifies Magento Attrubute Set identifier</param>
    /// <param name="AttributeId">Specifies Magento Attrubute identifier</param>
    /// <param name="AttributeGroupId">Specifies Magento Attrubute Group identifier</param>
    /// <param name="AttributeSetValueDescription">Specifies name/description of Magento Attribute Set Value</param>
    /// <param name="RunTrigger">Specifies whether trigger should be executed when creating Magento Attribute Set Value</param>
    /// <returns>Description of Magento Attribute Set Value</returns>
    procedure CreateMagentoAttributeSetValue(AttributeSetId: Integer; AttributeId: Integer; AttributeGroupId: Integer; AttributeSetValueDescription: Text; RunTrigger: Boolean): Text
    var
        MagentoAttributeSetValue: Record "NPR Magento Attr. Set Value";
    begin
        MagentoAttributeSetValue.Validate("Attribute Set ID", AttributeSetId);
        MagentoAttributeSetValue.Validate("Attribute ID", AttributeId);
        MagentoAttributeSetValue.Validate("Attribute Group ID", AttributeGroupId);
        MagentoAttributeSetValue.Init();
        MagentoAttributeSetValue.Description := CopyStr(AttributeSetValueDescription, 1, MaxStrLen(MagentoAttributeSetValue.Description));
        MagentoAttributeSetValue.Insert(RunTrigger);
        exit(MagentoAttributeSetValue.Description);
    end;

    /// <summary>
    /// Gets Magento Attribute Set Values
    /// </summary>
    /// <param name="AttributeSetId">Specifies Magento Attribute Set identifier</param>
    /// <param name="AttributeId">Specifies Magento Attribute identifier</param>
    /// <param name="AttributeGroupId">Specifies Magento Attribute Group identifier</param>
    /// <returns>Values of current record</returns>
    procedure GetMagentoAttributeSetValue(AttributeSetId: Integer; AttributeId: Integer; AttributeGroupId: Integer; var AttributeFields: Dictionary of [Text, Text])
    var
        MagentoAttributeSetValue: Record "NPR Magento Attr. Set Value";
        RecRef: RecordRef;
        DataTypeMgt: Codeunit "Data Type Management";
    begin
        MagentoAttributeSetValue.Get(AttributeSetId, AttributeId, AttributeGroupId);
        DataTypeMgt.GetRecordRef(MagentoAttributeSetValue, RecRef);
        GetRecordFields(RecRef, AttributeFields);
    end;

    /// <summary>
    /// Gets first Magento Attribute Set Value unique identifier
    /// </summary>
    /// <param name="AttributeSetValueDescription">Specifies name/description used in search criteria</param>
    /// <remarks>AttributeSetValueDescription with ignoring case will be used as a search criteria if string is not empty</remarks>
    /// <returns>First occurence of Attribute Set Id, Attribute Id and Attribute Group Id</returns>
    procedure GetMagentoAttributeSetValueIds(AttributeSetValueDescription: Text; var AttributeSetId: Integer; var AttributeId: Integer; var AttributeGroupId: Integer): Text
    var
        MagentoAttributeSetValue: Record "NPR Magento Attr. Set Value";
    begin
        AttributeSetId := 0;
        AttributeId := 0;
        AttributeGroupId := 0;
        if AttributeSetValueDescription <> '' then
            MagentoAttributeSetValue.SetFilter(Description, '@' + AttributeSetValueDescription);
        if MagentoAttributeSetValue.FindFirst() then begin
            AttributeSetId := MagentoAttributeSetValue."Attribute Set ID";
            AttributeId := MagentoAttributeSetValue."Attribute ID";
            AttributeGroupId := MagentoAttributeSetValue."Attribute Group ID";
        end;
    end;

    /// <summary>
    /// Updates Magento Attribute Set Value
    /// </summary>
    /// <param name="AttributeSetId">Specifies Magento Attrubute Set identifier</param>
    /// <param name="AttributeId">Specifies Magento Attribute identifier</param>
    /// <param name="AttributeGroupId">Specifies Magento Attribute Group identifier</param>
    /// <param name="UpdateFields">Specifies key/value pair of fields which will be updated</param>
    /// <param name="RunTrigger">Specifies whether trigger should be executed when updating Magento Attribute Set Value</param>
    /// <param name="FieldsNotUpdated">Specifies key/value pair of fields with specific reason why field is not updated</param>
    /// <returns>List of key/value reasons why specific field is not updated</returns>
    procedure UpdateMagentoAttributeSetValue(AttributeSetId: Integer; AttributeId: Integer; AttributeGroupId: Integer; UpdateFields: Dictionary of [Text, Text]; RunTrigger: Boolean; var FieldsNotUpdated: Dictionary of [Text, Text])
    var
        MagentoAttributeSetValue: Record "NPR Magento Attr. Set Value";
        DataTypeMgt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not MagentoAttributeSetValue.Get(AttributeSetId, AttributeId, AttributeGroupId) then
            exit;
        DataTypeMgt.GetRecordRef(MagentoAttributeSetValue, RecRef);
        UpdateTableFields(RecRef, UpdateFields, RunTrigger, FieldsNotUpdated);
    end;

    /// <summary>
    /// Deletes Magento Attribute Set Value
    /// </summary>
    /// <param name="AttributeSetId">Specifies Magento Attrubute Set identifier</param>
    /// <param name="AttributeId">Specifies Magento Attribute identifier</param>
    /// <param name="AttributeGroupId">Specifies Magento Attribute Group identifier</param>
    /// <param name="RunTrigger">Specifies whether trigger should be executed when deleting Magento Attribute Set Value</param>
    procedure DeleteMagentoAttributeSetValue(AttributeSetId: Integer; AttributeId: Integer; AttributeGroupId: Integer; RunTrigger: Boolean)
    var
        MagentoAttributeSetValue: Record "NPR Magento Attr. Set Value";
    begin
        if not MagentoAttributeSetValue.Get(AttributeSetId, AttributeId, AttributeGroupId) then
            exit;
        MagentoAttributeSetValue.Delete(RunTrigger);
    end;

    /// <summary>
    /// Deletes Magento Attribute Set Values
    /// </summary>
    /// <param name="AttributeSetValueDescriptionFilter">A filter string used as the search criteria</param>
    /// <param name="RunTrigger">Specifies whether trigger should be executed when deleting Magento Attribute Set Values</param>
    procedure DeleteMagentoAttributeSetValues(AttributeSetValueDescriptionFilter: Text; RunTrigger: Boolean)
    var
        MagentoAttributeSetValue: Record "NPR Magento Attr. Set Value";
    begin
        MagentoAttributeSetValue.SetFilter(Description, AttributeSetValueDescriptionFilter);
        if MagentoAttributeSetValue.IsEmpty() then
            exit;
        MagentoAttributeSetValue.DeleteAll(RunTrigger);
    end;

    /// <summary>
    /// Deletes Magento Attribute Set Values
    /// </summary>
    /// <param name="AttributeSetId">Specifies Magent Attribute Set identifier used in the search criteria</param>
    /// <param name="RunTrigger">Specifies whether trigger should be executed when deleting Magento Attribute Set Values</param>
    procedure DeleteMagentoAttributeSetValuesInSet(AttributeSetId: Integer; RunTrigger: Boolean)
    var
        MagentoAttributeSetValue: Record "NPR Magento Attr. Set Value";
    begin
        MagentoAttributeSetValue.SetRange("Attribute Set ID", AttributeSetId);
        if MagentoAttributeSetValue.IsEmpty() then
            exit;
        MagentoAttributeSetValue.DeleteAll(RunTrigger);
    end;

    /// <summary>
    /// Deletes Magento Attribute Set Values
    /// </summary>
    /// <param name="AttributeGroupId">Specifies Magent Attribute Group identifier used in the search criteria</param>
    /// <param name="RunTrigger">Specifies whether trigger should be executed when deleting Magento Attribute Set Values</param>
    procedure DeleteMagentoAttributeSetValuesInGroup(AttributeGroupId: Integer; RunTrigger: Boolean)
    var
        MagentoAttributeSetValue: Record "NPR Magento Attr. Set Value";
    begin
        MagentoAttributeSetValue.SetRange("Attribute Group ID", AttributeGroupId);
        if MagentoAttributeSetValue.IsEmpty() then
            exit;
        MagentoAttributeSetValue.DeleteAll(RunTrigger);
    end;

    /// <summary>
    /// Deletes Magento Attribute Set Values
    /// </summary>
    /// <param name="AttributeId">Specifies Magent Attribute identifier used in the search criteria</param>
    /// <param name="RunTrigger">Specifies whether trigger should be executed when deleting Magento Attribute Set Values</param>
    procedure DeleteMagentoAttributeSetValuesForAttribute(AttributeId: Integer; RunTrigger: Boolean)
    var
        MagentoAttributeSetValue: Record "NPR Magento Attr. Set Value";
    begin
        MagentoAttributeSetValue.SetRange("Attribute ID", AttributeId);
        if MagentoAttributeSetValue.IsEmpty() then
            exit;
        MagentoAttributeSetValue.DeleteAll(RunTrigger);
    end;

    /// <summary>
    /// Specifies whether Magento Attribute Set Values exist for the search criteria
    /// </summary>
    /// <param name="AttributeSetValueDescriptionFilter">A filter string used as search criteria</param>
    /// <remarks>AttributeSetValueDescription with ignoring case will be used as a search criteria if string is not empty</remarks>
    /// <returns>True/False</returns>
    procedure MagentoAttributeSetValuesExists(AttributeSetValueDescriptionFilter: Text): Boolean
    var
        MagentoAttributeSetValue: Record "NPR Magento Attr. Set Value";
    begin
        if AttributeSetValueDescriptionFilter <> '' then
            MagentoAttributeSetValue.SetFilter(Description, AttributeSetValueDescriptionFilter);
        exit(not MagentoAttributeSetValue.IsEmpty());
    end;

    /// <summary>
    /// Gets number of Magento Attribute Set Values
    /// </summary>
    /// <param name="AttributeSetValueDescriptionFilter">A filter string used as search criteria</param>
    /// <remarks>AttributeSetValueDescription with ignoring case will be used as a search criteria if string is not empty</remarks>
    /// <returns>Number of Magento Set Values</returns>
    procedure MagentoAttributeSetValuesCount(AttributeSetValueDescriptionFilter: Text): Integer
    var
        MagentoAttributeSetValue: Record "NPR Magento Attr. Set Value";
    begin
        if AttributeSetValueDescriptionFilter <> '' then
            MagentoAttributeSetValue.SetFilter(Description, AttributeSetValueDescriptionFilter);
        exit(MagentoAttributeSetValue.Count());
    end;

    local procedure GetRecordFields(RecRef: RecordRef; var RecordValues: Dictionary of [Text, Text])
    var
        FieldRec: Record Field;
        DataTypeMgt: Codeunit "Data Type Management";
        TempBlob: Codeunit "Temp Blob";
        FieldReference: FieldRef;
        InStr: InStream;
        ValueText: Text;
    begin
        Clear(RecordValues);
        FieldRec.SetRange(TableNo, RecRef.Number());
        if FieldRec.FindSet() then
            repeat
                if DataTypeMgt.FindFieldByName(RecRef, FieldReference, FieldRec.FieldName) then begin
                    case true of
                        UpperCase(Format(FieldReference.Class())) = 'FLOWFIELD':
                            begin
                                FieldReference.CalcField();
                                RecordValues.Add(FieldReference.Name(), Format(FieldReference.Value(), 0, 9));
                            end;
                        UpperCase(Format(FieldReference.Type)) = 'BLOB':
                            begin
                                Clear(ValueText);
                                FieldReference.CalcField();
                                TempBlob.FromFieldRef(FieldReference);
                                if TempBlob.HasValue() then begin
                                    TempBlob.CreateInStream(InStr);
                                    InStr.ReadText(ValueText);
                                end;
                                RecordValues.Add(FieldReference.Name(), ValueText);
                            end;
                        else
                            RecordValues.Add(FieldReference.Name(), Format(FieldReference.Value(), 0, 9));
                    end;
                end;
            until FieldRec.Next() = 0;
    end;

    local procedure UpdateTableFields(RecRef: RecordRef; UpdateFields: Dictionary of [Text, Text]; RunTrigger: Boolean; var FieldsNotUpdated: Dictionary of [Text, Text])
    var
        DataTypeMgt: Codeunit "Data Type Management";
        ConvertHelper: Codeunit "NPR Convert Helper";
        TempBlob: Codeunit "Temp Blob";
        DummyJObject: JsonObject;
        DummyJToken: JsonToken;
        FieldReference: FieldRef;
        InStr: InStream;
        OutStr: OutStream;
        FieldNotFoundLbl: Label 'Field "%1" was not found in "%2"', Comment = '%1=FieldCaption();%2=TableCaption()';
        FieldClassLbl: Label 'Field "%1" class is %2. Only Normal fields can be updated', Comment = '%1=FieldCaption();%2=FieldReference.Class()';
        UpdateFieldName, UpdateFieldWithValue, xFieldReferenceValue : Text;
        IsModified: Boolean;
    begin
        Clear(FieldsNotUpdated);
        foreach UpdateFieldName in UpdateFields.Keys() do begin
            if UpdateFields.Get(UpdateFieldName, UpdateFieldWithValue) then begin
                if DataTypeMgt.FindFieldByName(RecRef, FieldReference, UpdateFieldName) then begin
                    if UpperCase(Format(FieldReference.Class())) = 'NORMAL' then begin
                        if UpperCase(Format(FieldReference.Type)) = 'BLOB' then begin
                            Clear(xFieldReferenceValue);
                            FieldReference.CalcField();
                            TempBlob.FromFieldRef(FieldReference);
                            if TempBlob.HasValue() then begin
                                TempBlob.CreateInStream(InStr);
                                InStr.ReadText(xFieldReferenceValue);
                            end;
                            Clear(TempBlob);
                            TempBlob.CreateOutStream(OutStr);
                            OutStr.WriteText(UpdateFieldWithValue);
                            TempBlob.ToFieldRef(FieldReference);
                        end else begin
                            xFieldReferenceValue := Format(FieldReference.Value());
                            DummyJObject.Add(UpdateFieldName, UpdateFieldWithValue);
                            DummyJObject.Get(UpdateFieldName, DummyJToken);
                            ConvertHelper.JValueToFieldRef(DummyJToken.AsValue(), FieldReference);
                        end;
                        if Format(FieldReference.Value()) <> xFieldReferenceValue then
                            IsModified := true;
                    end else
                        FieldsNotUpdated.Add(Format(FieldReference.Name()), StrSubstNo(FieldClassLbl, FieldReference.Caption(), FieldReference.Class()));
                end else
                    FieldsNotUpdated.Add(UpdateFieldName, StrSubstNo(FieldNotFoundLbl, UpdateFieldName, RecRef.Caption()));
            end;
        end;

        if IsModified then
            RecRef.Modify(RunTrigger);
    end;

    /// <summary>
    /// Map Magento Attributes with Item
    /// </summary>
    /// <param name="Item">Specifies attribute set id for which mapping will be performed</param>
    /// <param name="VariantCode">Specifies Variant Code</param>
    procedure SetupItemAttributes(var Item: Record Item; VariantCode: Code[10])
    var
        MagentoAttribute: Record "NPR Magento Attribute";
        MagentoAttributeSetValue: Record "NPR Magento Attr. Set Value";
        MagentoAttributeLabel: Record "NPR Magento Attr. Label";
        MagentoItemAttribute: Record "NPR Magento Item Attr.";
        MagentoItemAttributeValue: Record "NPR Magento Item Attr. Value";
    begin
        Item.TestField("NPR Attribute Set ID");

        MagentoAttributeSetValue.SetRange("Attribute Set ID", Item."NPR Attribute Set ID");
        if MagentoAttributeSetValue.FindSet() then
            repeat
                MagentoAttribute.Get(MagentoAttributeSetValue."Attribute ID");
                if not MagentoItemAttribute.Get(MagentoAttributeSetValue."Attribute Set ID", MagentoAttributeSetValue."Attribute ID", Item."No.", VariantCode) then begin
                    MagentoItemAttribute.Init();
                    MagentoItemAttribute."Attribute Set ID" := Item."NPR Attribute Set ID";
                    MagentoItemAttribute."Attribute ID" := MagentoAttributeSetValue."Attribute ID";
                    MagentoItemAttribute."Item No." := Item."No.";
                    MagentoItemAttribute."Variant Code" := VariantCode;
                    MagentoItemAttribute.Insert(true);
                end;

                MagentoAttributeLabel.SetRange("Attribute ID", MagentoAttributeSetValue."Attribute ID");
                if MagentoAttributeLabel.FindSet() then
                    repeat
                        if not MagentoItemAttributeValue.Get(MagentoItemAttribute."Attribute ID", Item."No.", VariantCode, MagentoAttributeLabel."Line No.") then begin
                            MagentoItemAttributeValue.Init();
                            MagentoItemAttributeValue."Attribute ID" := MagentoItemAttribute."Attribute ID";
                            MagentoItemAttributeValue."Item No." := Item."No.";
                            MagentoItemAttributeValue."Variant Code" := VariantCode;
                            MagentoItemAttributeValue."Attribute Label Line No." := MagentoAttributeLabel."Line No.";
                            MagentoItemAttributeValue.Type := MagentoAttribute.Type;
                            MagentoItemAttributeValue."Attribute Set ID" := MagentoAttributeSetValue."Attribute Set ID";
                            MagentoItemAttributeValue.Picture := MagentoAttributeLabel.Image;
                            MagentoItemAttributeValue.Selected := false;
                            MagentoItemAttributeValue.Insert();
                        end else
                            if MagentoItemAttributeValue."Attribute Set ID" <> MagentoAttributeSetValue."Attribute Set ID" then begin
                                MagentoItemAttributeValue."Attribute Set ID" := MagentoAttributeSetValue."Attribute Set ID";
                                MagentoItemAttributeValue.Modify(true);
                            end;
                    until MagentoAttributeLabel.Next() = 0;
            until MagentoAttributeSetValue.Next() = 0;
    end;

    internal procedure HasProducts(RecRef: RecordRef): Boolean
    var
        Item: Record Item;
        MagentoAttributeSet: Record "NPR Magento Attribute Set";
    begin
        case RecRef.Number of
            DATABASE::"NPR Magento Attribute Set":
                begin
                    RecRef.SetTable(MagentoAttributeSet);
                    MagentoAttributeSet.Find();
                    Item.SetRange("NPR Attribute Set ID", MagentoAttributeSet."Attribute Set ID");
                    exit(Item.FindFirst());
                end;
        end;

        exit(false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Attribute Group", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnInsertCheckAttributeGroupDuplicate(var Rec: Record "NPR Magento Attribute Group"; RunTrigger: Boolean)
    var
        MagentoAttributeGroup: Record "NPR Magento Attribute Group";
    begin
        if Rec.IsTemporary() then
            exit;
        if Rec.Description = '' then
            exit;
        MagentoAttributeGroup.SetFilter(Description, '%1', Rec.Description);
        MagentoAttributeGroup.SetRange("Attribute Set ID", Rec."Attribute Set ID");
        if not MagentoAttributeGroup.IsEmpty() then
            Error(SetIdAlreadyAssignedErr, Rec."Attribute Set ID", Rec.Description);
    end;
}
