codeunit 6014475 "NPR Exchange Label Map Ev. Su."
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Access = Internal;
    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterDeleteEvent', '', false, false)]
    local procedure PurchaseLineOnAfterDelete(var Rec: Record "Purchase Line")
    var
        ExchangeLabelTableMap: Record "NPR Exchange Label Map";
    begin
        if Rec.IsTemporary() then
            exit;

        if ExchangeLabelTableMap.Get(Database::"Purchase Line", Rec.SystemId) then
            ExchangeLabelTableMap.Delete();
    end;
}
