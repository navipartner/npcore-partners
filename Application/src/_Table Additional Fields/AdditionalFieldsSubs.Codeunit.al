codeunit 6059782 "NPR Additional Fields Subs."
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnDelete(var Rec: Record Item)
    begin
        if Rec.IsTemporary() then
            exit;
        Rec.NPR_DeleteItemAdditionalFields();
    end;
}