codeunit 6059779 "NPR API - Update Ref. Fields"
{
    Access = Internal;
    [EventSubscriber(ObjectType::Table, Database::"Price List Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReferencedIdsItemVariantOnInsert(var Rec: Record "Price List Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;
        Rec.NPR_UpdateReferencedIds();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Price List Line", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReferencedIdsItemVariantOnRename(var Rec: Record "Price List Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;
        Rec.NPR_UpdateReferencedIds();
    end;

}
