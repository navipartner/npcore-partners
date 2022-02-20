codeunit 6059782 "NPR Additional Fields Subs."
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterDeleteEvent', '', false, false)]
    local procedure Item_OnDelete(var Rec: Record Item)
    begin
        if Rec.IsTemporary() then
            exit;
        Rec.DeleteItemAdditionalFields();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterDeleteEvent', '', false, false)]
    local procedure SalesHeader_OnDelete(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;
        if Rec.IsTemporary() then
            exit;
        Rec.DeleteSalesHeaderAdditionalFields();
    end;
}