codeunit 6014449 "NPR Item Category Event Subs."
{
    #region Database::"Item Category" subscriptions

    [EventSubscriber(ObjectType::Table, Database::"Item Category", 'OnAfterInsertEvent', '', true, true)]
    local procedure ItemCategoryOnAfterInsert(var Rec: Record "Item Category"; RunTrigger: Boolean)
    var
        ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
    begin
        if Rec.IsTemporary() or (not RunTrigger) then
            exit;

        if Rec."Parent Category" = '' then
            exit;

        ItemCategoryMgt.CopyParentItemCategoryDimensions(Rec, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Category", 'OnAfterModifyEvent', '', true, true)]
    local procedure ItemCategoryOnAfterModify(var Rec: Record "Item Category"; var xRec: Record "Item Category"; RunTrigger: Boolean)
    var
        ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
    begin
        if Rec.IsTemporary() or (not RunTrigger) then
            exit;

        if Format(Rec) <> Format(xRec) then
            ItemCategoryMgt.CopySetupToChildren(Rec, true);

        if (Rec."Parent Category" = '') or (Rec."Parent Category" = xRec."Parent Category") then
            exit;

        ItemCategoryMgt.CopyParentItemCategoryDimensions(Rec, xRec."Parent Category" <> '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Category", 'OnAfterValidateEvent', 'Description', false, false)]
    local procedure ItemCategoryOnAfterValidateDescription(var Rec: Record "Item Category"; var xRec: Record "Item Category")
    var
        Item: Record Item;
    begin
        if Rec.IsTemporary() then
            exit;

        if xRec.Description = Rec.Description then
            exit;

        if Item.Get(Rec.Code) then
            if Item."NPR Group sale" then begin
                Item.Validate(Description, Rec.Description);
                Item.Modify(true);
            end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Category", 'OnAfterValidateEvent', 'Parent Category', false, false)]
    local procedure ItemCategoryOnAfterValidateParentCategory(var Rec: Record "Item Category"; var xRec: Record "Item Category")
    var
        ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;

        if (Rec."Parent Category" = xRec."Parent Category") or (Rec."Parent Category" = '') then
            exit;

        if xRec."Parent Category" <> '' then
            ItemCategoryMgt.CopySetupFromParent(Rec, false)
        else
            ItemCategoryMgt.CopySetupFromParent(Rec, true);
    end;
    #endregion

    #region Database::"Config. Template Line" subscriptions

    [EventSubscriber(ObjectType::Table, Database::"Config. Template Line", 'OnAfterModifyEvent', '', false, false)]
    local procedure ConfigTemplateLineOnAfterModify(var Rec: Record "Config. Template Line"; var xRec: Record "Config. Template Line")
    var
        Item: Record Item;
        ItemCategory: Record "Item Category";
        ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
        ItemDiscGroupCode: Code[20];
        xItemDiscGroupCode: Code[20];
    begin
        if Rec.IsTemporary() then
            exit;

        if Rec."Data Template Code" = '' then
            exit;

        if Rec."Default Value" = xRec."Default Value" then
            exit;

        if (Rec."Table ID" = Database::Item) and (Rec."Field ID" = Item.FieldNo("Item Disc. Group")) then begin
            ItemCategory.SetRange("NPR Item Template Code", Rec."Data Template Code");
            if ItemCategory.FindSet() then begin
                Evaluate(ItemDiscGroupCode, Rec."Default Value");
                Evaluate(xItemDiscGroupCode, xRec."Default Value");

                repeat
                    ItemCategoryMgt.UpdateItemDiscGroupOnItems(ItemCategory, ItemDiscGroupCode, xItemDiscGroupCode);
                until ItemCategory.Next() = 0;
            end;
        end;
    end;
    #endregion

    #region Page::"Default Dimensions" subscriptions

    [EventSubscriber(ObjectType::Page, Page::"Default Dimensions", 'OnInsertRecordEvent', '', false, false)]
    local procedure DefaultDimensionsOnInsertRecord(var Rec: Record "Default Dimension"; BelowxRec: Boolean; var xRec: Record "Default Dimension"; var AllowInsert: Boolean)
    var
        ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;

        if Rec."Table ID" <> DATABASE::"Item Category" then
            exit;

        ItemCategoryMgt.ApplyDimensionsToChildren(Rec, false, true);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Default Dimensions", 'OnModifyRecordEvent', '', false, false)]
    local procedure DefaultDimensionsOnModifyRecord(var Rec: Record "Default Dimension"; var xRec: Record "Default Dimension"; var AllowModify: Boolean)
    var
        ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;

        if Rec."Table ID" <> DATABASE::"Item Category" then
            exit;

        if xRec."Dimension Value Code" = Rec."Dimension Value Code" then
            exit;

        ItemCategoryMgt.ApplyDimensionsToChildren(Rec, false, true);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Default Dimensions", 'OnDeleteRecordEvent', '', false, false)]
    local procedure DefaultDimensionsOnDeleteRecord(var Rec: Record "Default Dimension"; var AllowDelete: Boolean)
    var
        ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;

        if Rec."Table ID" <> DATABASE::"Item Category" then
            exit;

        ItemCategoryMgt.ApplyDimensionsToChildren(Rec, true, true);
    end;
    #endregion
}