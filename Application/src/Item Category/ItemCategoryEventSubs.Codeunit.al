codeunit 6014560 "NPR Item Category Event Subs."
{
    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterInsertEvent', '', false, false)]
    local procedure NPRDefaultDimensionOnAfterInsert(var Rec: Record "Default Dimension"; RunTrigger: Boolean)
    var
        ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
    begin
        if not RunTrigger then
            exit;

        if Rec.IsTemporary() then
            exit;

        if Rec."Table ID" <> DATABASE::"Item Category" then
            exit;

        ItemCategoryMgt.ApplyDimensionsToChildren(Rec, false, true);
    end;


    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterModifyEvent', '', false, false)]
    local procedure NPRDefaultDimensionOnAfterModify(var Rec: Record "Default Dimension"; var xRec: Record "Default Dimension"; RunTrigger: Boolean)
    var
        ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
    begin
        if not RunTrigger then
            exit;

        if Rec.IsTemporary() then
            exit;

        if Rec."Table ID" <> DATABASE::"Item Category" then
            exit;

        if xRec."Dimension Value Code" = Rec."Dimension Value Code" then
            exit;

        ItemCategoryMgt.ApplyDimensionsToChildren(Rec, false, true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterDeleteEvent', '', false, false)]
    local procedure NPRDefaultDimensionOnAfterDelete(var Rec: Record "Default Dimension"; RunTrigger: Boolean)
    var
        ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
    begin
        if not RunTrigger then
            exit;

        if Rec.IsTemporary() then
            exit;

        if Rec."Table ID" <> DATABASE::"Item Category" then
            exit;

        ItemCategoryMgt.ApplyDimensionsToChildren(Rec, true, true);
    end;
}